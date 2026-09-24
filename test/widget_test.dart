import 'package:flutter_test/flutter_test.dart';
import 'package:dog_help_pune/main.dart';
import 'package:dog_help_pune/src/store.dart';

void main() {
  testWidgets('Welcome screen shows Get Started', (tester) async {
    await tester.pumpWidget(DogHelpApp(store: AppStore()));
    await tester.scrollUntilVisible(find.text('Get Started'), 400);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });
}