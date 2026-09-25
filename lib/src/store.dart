import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'models.dart';
import 'persistence.dart';
import 'photo_check.dart';
import 'pmc/area_index.dart';
import 'pmc/mapping.dart';
import 'pmc/pmc_api.dart';

import 'package:flutter/services.dart';

abstract class LocationSource {
  Future<({double latitude, double longitude})?> current();
}

class DeviceLocation implements LocationSource {
  @override
  Future<({double latitude, double longitude})?> current() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    final position = await Geolocator.getCurrentPosition();
    return (latitude: position.latitude, longitude: position.longitude);
  }
}

class NoLocation implements LocationSource {
  @override
  Future<({double latitude, double longitude})?> current() async => null;
}

class AppStore extends ChangeNotifier {
  AppStore({
    PmcGateway? gateway,
    ReportRepository? reports,
    SessionStore? session,
    LocationSource? location,
  }) : gateway = gateway ?? HttpPmcGateway(),
       reportsRepo = reports ?? MemoryReports(),
       sessionStore = session ?? MemorySession(),
       locationSource = location ?? NoLocation();

  final PmcGateway gateway;
  final ReportRepository reportsRepo;
  final SessionStore sessionStore;
  final LocationSource locationSource;

  bool signedIn = false;
  String mobile = '';
  String name = '';
  String email = '';
  int tab = 0;
  bool codeSent = false;
  bool busy = false;
  String? authMessage;
  String? registrationUrl;
  bool needsPmcAccount = false;
  final ReportDraft draft = ReportDraft();
  final List<DogReport> reports = [];
  List<PmcWard> wards = [];
  List<PmcPrabhag> prabhags = [];
  PmcCatalog? catalog;
  ({double latitude, double longitude})? here;
  PhotoVerdict photoVerdict = PhotoVerdict.pending;
  bool checkingPhoto = false;
  String? areaNote;
  AreaIndex? _areas;
  PmcSession? _session;

  int get openCount => reports.where((r) => r.status.isOpen).length;
  int get resolvedCount =>
      reports.where((r) => r.status == ReportStatus.resolved).length;
  List<DogReport> get recent => reports.take(3).toList();
  String get placeLabel => here == null ? 'Pune' : 'Your location';

  Future<void> restore() async {
    final saved = await reportsRepo.load();
    reports
      ..clear()
      ..addAll(saved);
    _session = await sessionStore.read();
    if (_session != null) {
      signedIn = true;
      name = _session!.name;
      email = _session!.email;
      mobile = _session!.mobile.replaceFirst('+91', '');
    }
    notifyListeners();
  }

  void setTab(int value) {
    tab = value;
    notifyListeners();
  }

  void touch() => notifyListeners();

  Future<String?> requestCode() async {
    final digits = mobile.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return 'Enter a 10-digit mobile number';
    authMessage = null;
    registrationUrl = null;
    needsPmcAccount = false;
    busy = true;
    notifyListeners();
    try {
      final state = await gateway.lookupMobile(pmcMobile(digits));
      if (state == 'unregistered') {
        registrationUrl = pmcRegisterUrl;
        needsPmcAccount = true;
        codeSent = false;
        return 'Create a PMC CARE account with this mobile number before using Dog Help Pune.';
      }
      if (state == 'blocked') return 'PMC CARE has blocked this number.';
      if (state != 'registered') {
        return 'PMC CARE could not look up this number.';
      }
      await gateway.requestOtp(pmcMobile(digits));
      codeSent = true;
      return null;
    } on PmcException catch (error) {
      return error.message;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<String?> verifyCode(String code) async {
    if (!codeSent || needsPmcAccount) {
      return 'Create your PMC CARE account and request a code first.';
    }
    if (code.length != 4) return null;
    busy = true;
    notifyListeners();
    try {
      final session = await gateway.verifyOtp(
        mobile: pmcMobile(mobile),
        code: code,
      );
      _session = session;
      await sessionStore.write(session);
      signedIn = true;
      name = session.name;
      email = session.email;
      codeSent = false;
      authMessage = null;
      return null;
    } on PmcException catch (error) {
      return error.message;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    signedIn = false;
    codeSent = false;
    needsPmcAccount = false;
    registrationUrl = null;
    name = '';
    email = '';
    mobile = '';
    _session = null;
    await sessionStore.clear();
    notifyListeners();
  }

  Future<void> captureLocation() async {
    final point = await locationSource.current();
    if (point == null) {
      areaNote =
          'Location permission is required before a report can be placed.';
      notifyListeners();
      return;
    }
    here = point;
    await placeAt(point.latitude, point.longitude, label: 'Current location');
  }

  Future<void> placeAt(
    double latitude,
    double longitude, {
    required String label,
  }) async {
    draft
      ..latitude = latitude
      ..longitude = longitude
      ..locationChosen = true
      ..location = label
      ..area = '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}'
      ..wardId = null
      ..wardName = ''
      ..prabhagId = null
      ..prabhagName = '';
    prabhags = [];
    areaNote = 'Finding the PMC ward for this place…';
    notifyListeners();
    await loadAreas();
    _areas ??= AreaIndex.parse(
      await rootBundle.loadString('assets/data/pmc_prabhag_boundaries.json'),
    );
    final hit = _areas!.find(latitude, longitude);
    if (hit == null) {
      areaNote = 'This point is outside the PMC area. Move the pin inside Pune.';
      notifyListeners();
      return;
    }
    final placeName = _displayAreaName(hit.prabhag.isNotEmpty ? hit.prabhag : hit.ward);
    final wardLabel = _displayAreaName(hit.ward);
    draft
      ..location = label == 'Current location' ? 'Current location · $placeName' : placeName
      ..area = wardLabel;
    final wardId = matchAreaName(hit.ward, {
      for (final ward in wards) ward.id: ward.name,
    });
    if (wardId == null) {
      areaNote =
          'Nearby area "$wardLabel" did not match a live PMC ward. Choose the ward by hand.';
      notifyListeners();
      return;
    }
    await selectWard(wardId);
    final prabhagId = matchAreaName(hit.prabhag, {
      for (final item in prabhags) item.id: item.name,
    });
    if (prabhagId != null) {
      selectPrabhag(prabhagId);
      areaNote = null;
    } else {
      areaNote =
          'Ward set to ${draft.wardName}. Choose the prabhag for "$placeName".';
      notifyListeners();
    }
  }

  Future<String?> loadAreas() async {
    try {
      // Always refresh so a stale/partial catalog (e.g. old fake build) cannot stick.
      catalog = await gateway.catalog();
      wards = List.of(catalog!.wards)..sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
      return null;
    } on PmcException catch (error) {
      return error.message;
    }
  }

  Future<void> selectWard(String? wardId) async {
    final ward = wards.where((item) => item.id == wardId).firstOrNull;
    draft
      ..wardId = ward?.id
      ..wardName = ward?.name ?? ''
      ..prabhagId = null
      ..prabhagName = '';
    prabhags = [];
    notifyListeners();
    if (ward == null) return;
    prabhags = await gateway.prabhags(ward.id);
    notifyListeners();
  }

  void selectPrabhag(String? prabhagId) {
    final prabhag = prabhags.where((item) => item.id == prabhagId).firstOrNull;
    draft
      ..prabhagId = prabhag?.id
      ..prabhagName = prabhag?.name ?? '';
    notifyListeners();
  }

  String? draftError() {
    if (draft.filePath == null) return 'Add a photo of the dog.';
    if (!draft.locationChosen) {
      return 'Allow location, or set the pin from your current position.';
    }
    if (photoVerdict.accepted == false) return photoVerdict.detail;
    if (draft.wardId == null || draft.prabhagId == null) {
      return areaNote ??
          'The ward and prabhag could not be filled from this location.';
    }
    return null;
  }

  Future<DogReport> submitDraft() async {
    final problem = draftError();
    if (problem != null) throw PmcException(problem);
    final session = _session;
    final areas = catalog;
    if (session == null || areas == null) {
      throw PmcException('Sign in to PMC CARE before sending a report.');
    }
    final sub = subcategoryFor(draft.issue, areas.subcategories);
    if (sub == null) {
      throw PmcException(
        'PMC has no matching stray-dog category for this issue.',
      );
    }
    if (busy) throw PmcException('A report is already being sent.');
    busy = true;
    notifyListeners();
    try {
      final description = [
        draft.issue.label,
        'Dogs: ${draft.dogCount}',
        if (draft.note.trim().isNotEmpty) draft.note.trim(),
        'Location: ${draft.location}. ${draft.area}',
      ].join('\n');
      final reference = await gateway.submit({
        'userId': session.userId,
        'citMobileNumber': session.mobile,
        'citEmail': session.email,
        'citFirstName': session.name,
        'citMiddleName': 'NA',
        'citLastName': 'NA',
        'categoryDetailId': _requireInt(sub.id, 'issue category'),
        'categoryId': _requireInt(areas.categoryId, 'category'),
        'wardOfficeId1': _requireInt(draft.wardId, 'ward'),
        'gisWardName': draft.wardName,
        'gisWardName_mar': '',
        'prabhagId1': _requireInt(draft.prabhagId, 'prabhag'),
        'gisPrabhagName': draft.prabhagName,
        'gisPrabhagName_mar': '',
        'pethId1': null,
        'gisPethName': 'Select',
        'gisPethName_mar': '',
        'gisBPPethNo': '',
        'description': description,
        'currentLocation': 'Pune',
        'location': draft.area.isEmpty
            ? draft.location
            : '${draft.location}, ${draft.area}',
        'landmark': '',
        'latitude': draft.latitude,
        'longitude': draft.longitude,
        'image': '',
        'image1': '',
        'attachment': <Map<String, String>>[],
        'applicationType': 1,
        'startFrom': '',
        'handleAt': '',
        'artId': 1,
        'startArtId': 1,
      }, token: session.token);
      final photoPath = await _durablePhotoPath(draft.filePath, reference);
      final now = DateTime.now();
      final report = DogReport(
        id: reference,
        title: draft.issue.label,
        location: draft.location,
        area: '${draft.wardName} · ${draft.prabhagName}',
        timeLabel: 'Just now',
        status: ReportStatus.submitted,
        asset: draft.asset,
        issue: draft.issue,
        dogCount: draft.dogCount,
        note: draft.note,
        reference: reference,
        latitude: draft.latitude,
        longitude: draft.longitude,
        filePath: photoPath,
        updates: [
          TimelineEvent(
            title: 'Report sent',
            time: '${now.day}/${now.month}/${now.year}',
            body: 'PMC CARE accepted this report. The photo stays on this phone; PMC received the description and location.',
            done: true,
            current: true,
          ),
        ],
      );
      reports.insert(0, report);
      await reportsRepo.upsert(report);
      return report;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> refreshStatuses() async {
    final session = _session;
    if (session == null || reports.isEmpty) return;
    final remote = await gateway.myComplaints(
      mobile: session.mobile,
      token: session.token,
    );
    final byRef = {for (final item in remote) item.reference: item.status};
    for (final report in reports) {
      final status = byRef[report.reference];
      if (status == null) continue;
      final mapped = _mapStatus(status);
      if (mapped == report.status) continue;
      report.status = mapped;
      report.updates = [
        ...report.updates.map(
          (event) => TimelineEvent(
            title: event.title,
            time: event.time,
            body: event.body,
            done: true,
          ),
        ),
        TimelineEvent(
          title: mapped.label,
          time: 'Updated',
          body: 'PMC CARE status: $status',
          done: true,
          current: true,
        ),
      ];
      await reportsRepo.upsert(report);
    }
    notifyListeners();
  }

  void resetDraft() {
    draft
      ..filePath = null
      ..asset = 'assets/images/dog_street.png'
      ..issue = IssueType.aggressive
      ..dogCount = 1
      ..note = ''
      ..location = ''
      ..area = ''
      ..latitude = here?.latitude ?? 0
      ..longitude = here?.longitude ?? 0
      ..locationChosen = here != null
      ..wardId = null
      ..wardName = ''
      ..prabhagId = null
      ..prabhagName = '';
    if (here != null) {
      draft
        ..location = 'Current location'
        ..area =
            '${here!.latitude.toStringAsFixed(5)}, ${here!.longitude.toStringAsFixed(5)}';
    }
    prabhags = [];
    notifyListeners();
  }
}

Future<String?> _durablePhotoPath(String? sourcePath, String reference) async {
  if (sourcePath == null || sourcePath.isEmpty) return null;
  final source = File(sourcePath);
  if (!source.existsSync()) return sourcePath;
  try {
    return await persistReportPhoto(
      sourcePath,
      id: reference.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_'),
    ).timeout(const Duration(seconds: 3));
  } catch (_) {
    return sourcePath;
  }
}

int _requireInt(String? value, String label) {
  final parsed = int.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    throw PmcException('Invalid $label from PMC. Choose the ward and prabhag again.');
  }
  return parsed;
}

ReportStatus _mapStatus(String raw) {
  final value = raw.toLowerCase().replaceAll(' ', '');
  if (value.contains('resolv') || value.contains('close') || value.contains('complet')) {
    return ReportStatus.resolved;
  }
  if (value.contains('assign')) return ReportStatus.assigned;
  if (value.contains('progress') || value.contains('process') || value.contains('work')) {
    return ReportStatus.inProgress;
  }
  return ReportStatus.submitted;
}

String _displayAreaName(String raw) {
  final cleaned = raw.replaceAll(RegExp(r'[-_]+'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  if (cleaned.isEmpty) return 'Pune';
  return cleaned
      .split(' ')
      .map((part) {
        if (part.isEmpty) return part;
        return '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}';
      })
      .join(' ');
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
