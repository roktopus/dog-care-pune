import 'package:dog_help_pune/src/models.dart';
import 'package:dog_help_pune/src/photo_check.dart';
import 'package:dog_help_pune/src/pmc/area_index.dart';
import 'package:dog_help_pune/src/pmc/mapping.dart';
import 'package:dog_help_pune/src/pmc/pmc_api.dart';
import 'package:dog_help_pune/src/store.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ward and prabhag from location', () {
    late AreaIndex index;

    setUpAll(() async {
      final raw = await rootBundle.loadString('assets/data/pmc_prabhag_boundaries.json');
      index = AreaIndex.parse(raw);
    });

    test('a Kothrud boundary point returns the Kothrud ward name', () {
      final hit = index.find(18.50875, 73.78326);
      expect(hit, isNotNull);
      expect(hit!.ward.toUpperCase(), contains('KOTHRUD'));
      expect(hit.prabhag.toLowerCase(), contains('bavdhan'));
      expect(hit.distanceKm, 0);
    });

    test('a point far from Pune has no PMC area', () {
      expect(index.find(19.2, 72.8), isNull);
    });

    test('bundled ward names match live PMC ward labels', () {
      const live = {
        '2': 'Aundh - Baner',
        '4': 'Bibwewadi',
        '5': 'Dhankawadi - Katraj - Ambegaon',
        '6': 'Dhole Pati Road',
        '8': 'Hadapsar - Manjari',
        '12': 'Sinhgad Road',
        '14': 'Warje - Karvenagar',
        '16': 'Wanawadi',
        '20': 'Kothrud - Bavdhan',
        '21': 'Kondhwa - Undri',
      };
      expect(matchAreaName('KOTHRUD-BAVDHAN', live), '20');
      expect(matchAreaName('AUNDH-BANER', live), '2');
      expect(matchAreaName('KONDHWA-YEWALEWADI', live), '21');
      expect(matchAreaName('BIBVEWADI', live), '4');
      expect(matchAreaName('WANAVADI-RAMTEKDI', live), '16');
      expect(matchAreaName('SINHGAD ROAD', live), '12');
    });

    test('numbered live prabhag names still match the GIS label', () {
      const live = {
        '45': '41 Mahamadwadi - Undri',
        '62': '40 Kondhwa Budruk - Yewalewadi',
        '10': 'Bavdhan - Kothrud Depot',
      };
      expect(matchAreaName('Kondhwa Budruk - Yewalewadi', live), '62');
      expect(matchAreaName('Bavdhan - Kothrud Depot', live), '10');
      expect(matchAreaName('Mahamadwadi - Undri', live), '45');
    });

    test('placeAt fills ward and prabhag from a Kothrud point', () async {
      final store = AppStore(gateway: _FakePmc());
      await store.placeAt(18.50875, 73.78326, label: 'Current location');
      expect(store.draft.locationChosen, isTrue);
      expect(store.draft.wardId, '20');
      expect(store.draft.wardName, 'Kothrud - Bavdhan');
      expect(store.prabhags, isNotEmpty);
      expect(store.draft.prabhagId, isNotNull);
      expect(store.draft.prabhagName.toLowerCase(), contains('bavdhan'));
      expect(store.draft.location, contains('Current location'));
      expect(store.draft.location.toLowerCase(), isNot(contains('pinned on map')));
      expect(store.draft.area.toLowerCase(), contains('kothrud'));
    });

    test('placeAt matches Bibvewadi GIS name onto Bibwewadi PMC ward', () async {
      final store = AppStore(gateway: FakePmcGateway());
      await store.placeAt(18.49175, 73.86957, label: 'Pinned on map');
      expect(store.draft.wardId, '4');
      expect(store.draft.wardName, 'Bibwewadi');
      expect(store.draft.location.toLowerCase(), isNot(contains('pinned on map')));
      expect(store.wards.length, greaterThan(10));
      expect(store.wards.any((w) => w.name.contains('Bibwewadi')), isTrue);
      expect(store.wards.any((w) => w.name.contains('Aundh')), isTrue);
    });

    test('changing location clears the old ward before matching the new one', () async {
      final store = AppStore(gateway: _FakePmc());
      await store.placeAt(18.50875, 73.78326, label: 'Kothrud');
      expect(store.draft.wardId, '20');
      final firstPrabhag = store.draft.prabhagId;

      await store.placeAt(18.44763, 73.88568, label: 'Kondhwa');
      expect(store.draft.wardId, '21');
      expect(store.draft.wardName, 'Kondhwa - Undri');
      expect(store.draft.prabhagId, isNot(firstPrabhag));
      expect(store.draft.prabhagName.toLowerCase(), anyOf(contains('kondhwa'), contains('yewalewadi')));
    });

    test('a location outside Pune clears ward and prabhag', () async {
      final store = AppStore(gateway: _FakePmc());
      await store.placeAt(18.50875, 73.78326, label: 'Kothrud');
      expect(store.draft.wardId, isNotNull);

      await store.placeAt(19.2, 72.8, label: 'Outside');
      expect(store.draft.wardId, isNull);
      expect(store.draft.prabhagId, isNull);
      expect(store.prabhags, isEmpty);
      expect(store.areaNote, contains('outside'));
    });

    test('selectWard reloads prabhags for that ward', () async {
      final store = AppStore(gateway: _FakePmc());
      await store.loadAreas();
      await store.selectWard('21');
      expect(store.draft.wardId, '21');
      expect(store.draft.prabhagId, isNull);
      expect(store.prabhags.length, greaterThanOrEqualTo(2));
      store.selectPrabhag(store.prabhags.first.id);
      expect(store.draft.prabhagId, store.prabhags.first.id);
    });
  });

  test('maps dog issues onto live PMC subcategory names', () {
    const options = [
      PmcSubcategory(id: '180', name: 'Stray Dogs - Unsterilised Dogs'),
      PmcSubcategory(id: '181', name: 'Treatment for Injured / Sick Dogs'),
      PmcSubcategory(id: '182', name: 'Voilent / Suspected Rabies dogs'),
      PmcSubcategory(id: '183', name: 'other (Stray Dogs)'),
    ];
    expect(subcategoryFor(IssueType.unsterilised, options)?.id, '180');
    expect(subcategoryFor(IssueType.injured, options)?.id, '181');
    expect(subcategoryFor(IssueType.sick, options)?.id, '181');
    expect(subcategoryFor(IssueType.aggressive, options)?.id, '182');
    expect(subcategoryFor(IssueType.bite, options)?.id, '182');
    expect(subcategoryFor(IssueType.pack, options)?.id, '183');
  });

  test('parses complaint references without assuming one list key', () {
    final parsed = parseComplaints({
      'lstGrievance': [
        {'tokenNo': 'PC45011', 'grievanceStatus': 'InProcess'},
      ],
    });
    expect(parsed.single.reference, 'PC45011');
    expect(parsed.single.status, 'InProcess');
  });

  test('draft requires a Pune pin and a ward before submit', () async {
    final store = AppStore(gateway: _FakePmc());
    expect(store.reports, isEmpty);
    expect(store.draftError(), 'Add a photo of the dog.');
    store
      ..photoVerdict = const PhotoVerdict(clear: true, showsDog: true, detail: 'ok')
      ..draft.filePath = '/tmp/dog.jpg';
    store.draft
      ..locationChosen = true
      ..latitude = 18.52
      ..longitude = 73.85
      ..wardId = '21'
      ..prabhagId = '62';
    expect(store.draftError(), isNull);
  });

  test('an unregistered number cannot receive a code or enter the app', () async {
    var otpSent = false;
    final store = AppStore(gateway: _FakePmc(onOtp: () => otpSent = true, state: 'unregistered'));
    store.mobile = '9000000000';
    final message = await store.requestCode();
    expect(store.needsPmcAccount, isTrue);
    expect(store.signedIn, isFalse);
    expect(store.codeSent, isFalse);
    expect(otpSent, isFalse);
    expect(message, contains('PMC CARE'));
    expect(store.registrationUrl, pmcRegisterUrl);
  });

  test('submit stores the reference PMC returns', () async {
    final store = AppStore(gateway: _FakePmc());
    await store.loadAreas();
    store.photoVerdict = const PhotoVerdict(clear: true, showsDog: true, detail: 'ok');
    store.draft
      ..filePath = '/tmp/dog.jpg'
      ..locationChosen = true
      ..latitude = 18.52
      ..longitude = 73.85
      ..issue = IssueType.pack
      ..wardId = '16'
      ..wardName = 'Wanawadi'
      ..prabhagId = '1'
      ..prabhagName = 'Wanawadi';
    store.mobile = '9000000000';
    expect(await store.requestCode(), isNull);
    expect(await store.verifyCode('1234'), isNull);
    final report = await store.submitDraft();
    expect(report.reference, 'PC90001');
    expect(store.reports.single.area, contains('Wanawadi'));
  });
}

class _FakePmc implements PmcGateway {
  _FakePmc({this.onOtp, this.state = 'registered'});

  final void Function()? onOtp;
  final String state;

  @override
  Future<PmcCatalog> catalog() async => const PmcCatalog(
        categoryId: '34',
        subcategories: [PmcSubcategory(id: '183', name: 'other (Stray Dogs)')],
        wards: [
          PmcWard(id: '2', name: 'Aundh - Baner'),
          PmcWard(id: '4', name: 'Bibwewadi'),
          PmcWard(id: '16', name: 'Wanawadi'),
          PmcWard(id: '20', name: 'Kothrud - Bavdhan'),
          PmcWard(id: '21', name: 'Kondhwa - Undri'),
        ],
      );

  @override
  Future<String> lookupMobile(String mobile) async => state;

  @override
  Future<List<RemoteComplaint>> myComplaints({required String mobile, required String token}) async => const [];

  @override
  Future<List<PmcPrabhag>> prabhags(String wardId) async {
    if (wardId == '20') {
      return const [
        PmcPrabhag(id: '10', name: 'Bavdhan - Kothrud Depot'),
        PmcPrabhag(id: '11', name: 'Erandwane - Happy Colony'),
      ];
    }
    if (wardId == '21') {
      return const [
        PmcPrabhag(id: '45', name: '41 Mahamadwadi - Undri'),
        PmcPrabhag(id: '62', name: '40 Kondhwa Budruk - Yewalewadi'),
      ];
    }
    return const [PmcPrabhag(id: '1', name: 'Wanawadi')];
  }

  @override
  Future<void> requestOtp(String mobile) async => onOtp?.call();

  @override
  Future<String> submit(Map<String, dynamic> body, {required String token}) async {
    expect(body['currentLocation'], 'Pune');
    expect(body['attachment'], isEmpty);
    return 'PC90001';
  }

  @override
  Future<PmcSession> verifyOtp({required String mobile, required String code}) async {
    return PmcSession(token: 't', userId: 'u', name: 'Citizen', email: '', mobile: mobile);
  }
}
