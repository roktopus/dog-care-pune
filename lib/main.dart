import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/persistence.dart';
import 'src/pmc/pmc_api.dart';
import 'src/screens/app_shell.dart';
import 'src/store.dart';
import 'src/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  // Production default: live PMC CARE. Tests/simulator may pass --dart-define=FAKE_PMC=true.
  const fakePmc = bool.fromEnvironment('FAKE_PMC');
  final store = AppStore(
    gateway: fakePmc ? FakePmcGateway() : HttpPmcGateway(),
    reports: await SqliteReports.open(),
    session: SecureSession(),
    location: DeviceLocation(),
  );
  await store.restore();
  runApp(DogHelpApp(store: store));
}

class DogHelpApp extends StatelessWidget {
  const DogHelpApp({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: store,
      child: MaterialApp(
        title: 'Dog Help Pune',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const RootPage(),
      ),
    );
  }
}

class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({super.key, required AppStore store, required super.child})
      : super(notifier: store);

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing');
    return scope!.notifier!;
  }
}
