import 'dart:convert';

import 'package:http/http.dart' as http;

const pmcApiBase = 'https://api.pmccare.in';
const pmcRegisterUrl = 'https://www.pmccare.in/Login/enter-mobile-number/register';

class PmcException implements Exception {
  PmcException(this.message, {this.registrationUrl});

  final String message;
  final String? registrationUrl;

  @override
  String toString() => message;
}

class PmcSession {
  const PmcSession({
    required this.token,
    required this.userId,
    required this.name,
    required this.email,
    required this.mobile,
  });

  final String token;
  final String userId;
  final String name;
  final String email;
  final String mobile;
}

class PmcWard {
  const PmcWard({required this.id, required this.name});

  final String id;
  final String name;
}

class PmcPrabhag {
  const PmcPrabhag({required this.id, required this.name});

  final String id;
  final String name;
}

class PmcSubcategory {
  const PmcSubcategory({required this.id, required this.name});

  final String id;
  final String name;
}

class PmcCatalog {
  const PmcCatalog({
    required this.categoryId,
    required this.subcategories,
    required this.wards,
  });

  final String categoryId;
  final List<PmcSubcategory> subcategories;
  final List<PmcWard> wards;
}

class RemoteComplaint {
  const RemoteComplaint({required this.reference, required this.status});

  final String reference;
  final String status;
}

abstract class PmcGateway {
  Future<String> lookupMobile(String mobile);
  Future<void> requestOtp(String mobile);
  Future<PmcSession> verifyOtp({required String mobile, required String code});
  Future<PmcCatalog> catalog();
  Future<List<PmcPrabhag>> prabhags(String wardId);
  Future<String> submit(Map<String, dynamic> body, {required String token});
  Future<List<RemoteComplaint>> myComplaints({required String mobile, required String token});
}

/// In-memory PMC stand-in for simulator and automated tests. Never hits the network.
class FakePmcGateway implements PmcGateway {
  var submitCalls = 0;
  var requestOtpCalls = 0;
  var unregisteredMobiles = <String>{};

  /// Mirrors the live PMC ward list used for GIS → CARE name matching in tests.
  static const fakeWards = <PmcWard>[
    PmcWard(id: '2', name: 'Aundh - Baner'),
    PmcWard(id: '3', name: 'Bhavani Peth'),
    PmcWard(id: '4', name: 'Bibwewadi'),
    PmcWard(id: '5', name: 'Dhankawadi - Katraj - Ambegaon'),
    PmcWard(id: '6', name: 'Dhole Patil Road'),
    PmcWard(id: '7', name: 'Kasba - Vishrambagwada'),
    PmcWard(id: '8', name: 'Hadapsar - Manjari'),
    PmcWard(id: '9', name: 'Nagar Road - Vadgaonsheri'),
    PmcWard(id: '11', name: 'Shivajinagar - Ghole Road'),
    PmcWard(id: '12', name: 'Sinhgad Road'),
    PmcWard(id: '14', name: 'Warje - Karvenagar'),
    PmcWard(id: '15', name: 'Yerwada - Kalas - Dhanori'),
    PmcWard(id: '16', name: 'Wanawadi'),
    PmcWard(id: '20', name: 'Kothrud - Bavdhan'),
    PmcWard(id: '21', name: 'Kondhwa - Undri'),
  ];

  static const _prabhagsByWard = <String, List<PmcPrabhag>>{
    '2': [
      PmcPrabhag(id: '201', name: 'Baner'),
      PmcPrabhag(id: '202', name: 'Aundh'),
    ],
    '4': [
      PmcPrabhag(id: '41', name: 'Salisbury Park - Maharshi Nagar'),
      PmcPrabhag(id: '42', name: 'Bibwewadi'),
    ],
    '20': [
      PmcPrabhag(id: '10', name: 'Bavdhan - Kothrud Depot'),
      PmcPrabhag(id: '11', name: 'Erandwane - Happy Colony'),
    ],
    '21': [
      PmcPrabhag(id: '45', name: '41 Mahamadwadi - Undri'),
      PmcPrabhag(id: '62', name: '40 Kondhwa Budruk - Yewalewadi'),
    ],
  };

  @override
  Future<PmcCatalog> catalog() async => const PmcCatalog(
        categoryId: '34',
        subcategories: [
          PmcSubcategory(id: '180', name: 'injured / sick (Stray Dogs)'),
          PmcSubcategory(id: '181', name: 'rabies / voilent (Stray Dogs)'),
          PmcSubcategory(id: '182', name: 'unsterilised (Stray Dogs)'),
          PmcSubcategory(id: '183', name: 'other (Stray Dogs)'),
        ],
        wards: fakeWards,
      );

  @override
  Future<String> lookupMobile(String mobile) async {
    final digits = mobile.replaceAll(RegExp(r'\D'), '');
    final local = digits.length > 10 ? digits.substring(digits.length - 10) : digits;
    return unregisteredMobiles.contains(local) || unregisteredMobiles.contains(mobile)
        ? 'unregistered'
        : 'registered';
  }

  @override
  Future<List<RemoteComplaint>> myComplaints({required String mobile, required String token}) async =>
      const [];

  @override
  Future<List<PmcPrabhag>> prabhags(String wardId) async {
    final known = _prabhagsByWard[wardId];
    if (known != null) return known;
    final ward = fakeWards.where((item) => item.id == wardId).firstOrNull;
    final label = ward?.name ?? 'Area';
    final base = int.tryParse(wardId) ?? 900;
    return [
      PmcPrabhag(id: '${base * 10 + 1}', name: '$label · Prabhag A'),
      PmcPrabhag(id: '${base * 10 + 2}', name: '$label · Prabhag B'),
    ];
  }

  @override
  Future<void> requestOtp(String mobile) async {
    requestOtpCalls++;
  }

  @override
  Future<String> submit(Map<String, dynamic> body, {required String token}) async {
    submitCalls++;
    final ref = 'PC-FAKE-$submitCalls';
    return ref;
  }

  @override
  Future<PmcSession> verifyOtp({required String mobile, required String code}) async {
    if (code != '1234') {
      throw PmcException('Invalid OTP.');
    }
    return PmcSession(token: 'fake-token', userId: 'fake-user', name: 'Citizen', email: '', mobile: mobile);
  }
}

class HttpPmcGateway implements PmcGateway {
  HttpPmcGateway({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<String> lookupMobile(String mobile) async {
    final data = await _post('/authenticationConfiguration/v1/loginWithPassword', {
      'mobile': mobile,
      'facebookId': null,
      'googleId': null,
      'twitterId': null,
    });
    final state = (data['result'] as Map?)?['userState']?.toString() ?? '';
    if (state.isEmpty) throw PmcException('PMC did not say whether this number is registered.');
    return state;
  }

  @override
  Future<void> requestOtp(String mobile) async {
    await _post('/authenticationConfiguration/v1/verification', {'mobile': mobile});
  }

  @override
  Future<PmcSession> verifyOtp({required String mobile, required String code}) async {
    final data = await _post('/authenticationConfiguration/v1/verification/verify/login', {
      'mobile': mobile,
      'veriCode': code,
      'fcmToken': '',
    });
    final result = data['result'];
    if (result is! Map) throw PmcException('PMC did not return a session.');
    final token = result['token']?.toString() ?? '';
    final userId = result['userId']?.toString() ?? '';
    if (token.isEmpty || userId.isEmpty) throw PmcException('PMC did not return a login token.');
    return PmcSession(
      token: token,
      userId: userId,
      name: (result['firstName']?.toString().trim().isNotEmpty ?? false) ? result['firstName'].toString() : 'Citizen',
      email: result['emailId']?.toString() ?? '',
      mobile: mobile,
    );
  }

  @override
  Future<PmcCatalog> catalog() async {
    final data = await _get('/user/v1/GrievanceCtrl/getNewCategoryList');
    final result = data['result'];
    if (result is! Map) throw PmcException('PMC category list was empty.');
    final categories = (result['lstCategory'] as List? ?? const []);
    Map? stray;
    for (final item in categories) {
      if (item is Map && item['ccmName']?.toString() == 'Stray Dogs') stray = item;
    }
    if (stray == null) throw PmcException('PMC has no Stray Dogs category right now.');
    final categoryId = stray['ccmId'].toString();
    final subsData = await _post('/user/v1/GrievanceCtrl/getNewSubCategoryList', {'categoryId': categoryId});
    final subsResult = subsData['result'];
    final subs = subsResult is Map ? (subsResult['lstCategoryDetails'] as List? ?? const []) : const [];
    final wards = (result['lstWard'] as List? ?? const []);
    return PmcCatalog(
      categoryId: categoryId,
      subcategories: [
        for (final item in subs)
          if (item is Map)
            PmcSubcategory(id: item['ccdId'].toString(), name: item['ccdName']?.toString() ?? ''),
      ],
      wards: [
        for (final item in wards)
          if (item is Map && item['wamName'] != null)
            PmcWard(id: item['wamId'].toString(), name: item['wamName'].toString()),
      ],
    );
  }

  @override
  Future<List<PmcPrabhag>> prabhags(String wardId) async {
    final data = await _post('/user/v1/GrievanceCtrl/getNewPrabhag', {'wardId': wardId});
    final result = data['result'];
    final list = result is Map ? (result['lstPrabhag'] as List? ?? const []) : const [];
    return [
      for (final item in list)
        if (item is Map)
          PmcPrabhag(id: item['prmId'].toString(), name: item['prmName']?.toString() ?? ''),
    ];
  }

  @override
  Future<String> submit(Map<String, dynamic> body, {required String token}) async {
    final data = await _post('/user/v1/GrievanceCtrl/addGrievanceDirectly', body, token: token);
    final result = data['result'];
    final reference = result is String ? result : result?.toString() ?? '';
    if (reference.isEmpty || reference == 'null') {
      throw PmcException(data['message']?.toString() ?? 'PMC did not return a reference number.');
    }
    return reference;
  }

  @override
  Future<List<RemoteComplaint>> myComplaints({required String mobile, required String token}) async {
    final data = await _post(
      '/user/v1/GrievanceCtrl/getGrievanceListByMobile',
      {'citMobileNumber': mobile},
      token: token,
    );
    return parseComplaints(data['result']);
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await _client.get(Uri.parse('$pmcApiBase$path'), headers: _headers());
    return _decode(response);
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body, {String? token}) async {
    final response = await _client.post(
      Uri.parse('$pmcApiBase$path'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Map<String, String> _headers({String? token}) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': 'dog-help-pune',
        if (token != null && token.isNotEmpty) 'authorization': 'jwt $token',
      };

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(response.body);
      data = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      throw PmcException('PMC returned an unreadable response.');
    }
    final code = data['code'];
    if (response.statusCode >= 400 || (code is num && code >= 400)) {
      throw PmcException(data['message']?.toString() ?? 'PMC request failed.');
    }
    return data;
  }
}

List<RemoteComplaint> parseComplaints(Object? result) {
  final raw = <Map>[];
  if (result is List) {
    raw.addAll(result.whereType<Map>());
  } else if (result is Map) {
    for (final value in result.values) {
      if (value is List) raw.addAll(value.whereType<Map>());
    }
  }
  return [
    for (final item in raw)
      if (_reference(item) != null)
        RemoteComplaint(reference: _reference(item)!, status: _status(item)),
  ];
}

String? _reference(Map item) {
  for (final key in ['tokenNo', 'tokenNumber', 'grievanceToken', 'complaintToken']) {
    final value = item[key]?.toString();
    if (value != null && value.isNotEmpty && value != 'null') return value;
  }
  return null;
}

String _status(Map item) {
  for (final key in ['grievanceStatus', 'statusName', 'status']) {
    final value = item[key]?.toString();
    if (value != null && value.isNotEmpty && value != 'null') return value;
  }
  return '';
}

String pmcMobile(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  final local = digits.length > 10 ? digits.substring(digits.length - 10) : digits;
  return '+91$local';
}
