import 'package:flutter_test/flutter_test.dart';
import 'package:dog_help_pune/main.dart';
import 'package:dog_help_pune/src/store.dart';

void main() {
  testWidgets('Welcome screen shows Get Started', (tester) async {
    await tester.pumpWidget(DogHelpApp(store: AppStore()));
    expect(find.text('I already have an account'), findsOneWidget);
    expect(find.text('I don’t have a PMC CARE account'), findsOneWidget);
    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();
    expect(find.text('Sign In'), findsOneWidget);
  });
}