import 'package:dog_help_pune/main.dart';
import 'package:dog_help_pune/src/models.dart';
import 'package:dog_help_pune/src/photo_check.dart';
import 'package:dog_help_pune/src/pmc/pmc_api.dart';
import 'package:dog_help_pune/src/screens/report_flow.dart';
import 'package:dog_help_pune/src/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppStore store;
  late FakePmcGateway pmc;

  setUp(() async {
    pmc = FakePmcGateway();
    store = AppStore(
      gateway: pmc,
      location: _FixedLocation(18.50875, 73.78326),
    );
    store
      ..signedIn = true
      ..name = 'Test User'
      ..mobile = '9000000000'
      ..photoVerdict = const PhotoVerdict(clear: true, showsDog: true, detail: 'ok')
      ..draft.filePath = '/tmp/dog.jpg'
      ..draft.locationChosen = true
      ..draft.latitude = 18.50875
      ..draft.longitude = 73.78326
      ..draft.location = 'Current location'
      ..draft.area = '18.50875, 73.78326';
    await store.loadAreas();
    await store.selectWard('20');
    store.selectPrabhag('10');
  });

  Future<void> openDetails(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      AppScope(
        store: store,
        child: const MaterialApp(home: DetailsStep()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 120, scrollable: find.byType(Scrollable).first);
    await tester.pump();
  }

  testWidgets('POSITIVE dog count plus and minus update the number', (tester) async {
    await openDetails(tester);
    expect(find.text('How Many Dogs?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('dog_count_plus')));
    await tester.pump();
    expect(store.draft.dogCount, 2);
    await tester.tap(find.byKey(const Key('dog_count_minus')));
    await tester.pump();
    expect(store.draft.dogCount, 1);
  });

  testWidgets('POSITIVE issue type chip updates the draft', (tester) async {
    await openDetails(tester);
    await tester.tap(find.text('Injured dog'));
    await tester.pump();
    expect(store.draft.issue, IssueType.injured);
  });

  test('POSITIVE placeAt fills ward and prabhag from a Kothrud point', () async {
    await store.placeAt(18.50875, 73.78326, label: 'Current location');
    expect(store.draft.wardId, '20');
    expect(store.draft.prabhagId, isNotNull);
    expect(store.draft.wardName, contains('Kothrud'));
    expect(store.draft.prabhagName.toLowerCase(), contains('bavdhan'));
  });

  testWidgets('POSITIVE details screen shows matched ward and prabhag', (tester) async {
    await openDetails(tester);
    await reveal(tester, find.text('PMC Area'));
    expect(find.textContaining('Kothrud'), findsWidgets);
    expect(find.textContaining('Bavdhan'), findsWidgets);
  });

  test('NEGATIVE placeAt outside Pune clears ward and prabhag', () async {
    await store.placeAt(18.50875, 73.78326, label: 'Inside');
    expect(store.draft.wardId, isNotNull);
    await store.placeAt(19.2, 72.8, label: 'Outside');
    expect(store.draft.wardId, isNull);
    expect(store.draft.prabhagId, isNull);
    expect(store.areaNote, contains('outside'));
  });

  testWidgets('NEGATIVE details screen shows outside-PMC note', (tester) async {
    store.draft
      ..wardId = null
      ..prabhagId = null
      ..wardName = ''
      ..prabhagName = '';
    store.areaNote = 'This point is outside the PMC area. Move the pin inside Pune.';
    await openDetails(tester);
    await reveal(tester, find.text('PMC Area'));
    expect(find.textContaining('outside'), findsWidgets);
  });

  testWidgets('POSITIVE choosing a ward loads prabhag options', (tester) async {
    await openDetails(tester);
    await store.selectWard('21');
    await tester.pump();
    expect(store.prabhags.length, greaterThanOrEqualTo(2));
    expect(store.draft.prabhagId, isNull);
    await reveal(tester, find.text('PMC Area'));
    expect(find.text('Choose prabhag'), findsOneWidget);
  });

  testWidgets('NEGATIVE next is blocked when ward or prabhag is missing', (tester) async {
    store.draft
      ..wardId = null
      ..prabhagId = null
      ..wardName = ''
      ..prabhagName = '';
    store.prabhags = [];
    await openDetails(tester);
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });

  test('NEGATIVE submit is blocked when photo check failed', () {
    store.photoVerdict = const PhotoVerdict(
      clear: false,
      showsDog: false,
      detail: 'The photo is blurry.',
    );
    expect(store.draftError(), contains('blurry'));
  });

  testWidgets('NEGATIVE unregistered mobile cannot request OTP', (tester) async {
    pmc.unregisteredMobiles.add('9111111111');
    store
      ..signedIn = false
      ..mobile = '9111111111';
    final error = await store.requestCode();
    expect(error, isNotNull);
    expect(store.needsPmcAccount, isTrue);
    expect(pmc.requestOtpCalls, 0);
  });

  testWidgets('POSITIVE registered mobile OTP and fake submit never hit live PMC', (tester) async {
    expect(pmc.submitCalls, 0);
    store.draft.issue = IssueType.pack;
    store.mobile = '9000000000';
    expect(await store.requestCode(), isNull);
    expect(pmc.requestOtpCalls, 1);
    expect(await store.verifyCode('1234'), isNull);
    expect(store.signedIn, isTrue);
    final report = await store.submitDraft();
    expect(report.reference, startsWith('PC-FAKE-'));
    expect(pmc.submitCalls, 1);
  });

  testWidgets('NEGATIVE wrong OTP stays signed out', (tester) async {
    store
      ..signedIn = false
      ..mobile = '9000000000';
    expect(await store.requestCode(), isNull);
    final error = await store.verifyCode('0000');
    expect(error, isNotNull);
    expect(store.signedIn, isFalse);
  });
}

class _FixedLocation implements LocationSource {
  _FixedLocation(this.latitude, this.longitude);
  final double latitude;
  final double longitude;

  @override
  Future<({double latitude, double longitude})?> current() async =>
      (latitude: latitude, longitude: longitude);
}
