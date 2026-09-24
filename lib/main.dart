import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/screens/app_shell.dart';
import 'src/store.dart';
import 'src/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(DogHelpApp(store: AppStore()));
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
