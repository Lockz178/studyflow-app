import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow_app/main.dart';

void main() {
  testWidgets('StudyFlow home screen shows main texts', (WidgetTester tester) async {
    await tester.pumpWidget(const StudyFlowApp());

    expect(find.text('StudyFlow'), findsOneWidget);
    expect(find.text('Welcome back 👋'), findsOneWidget);
    expect(find.text('Upcoming Deadlines'), findsOneWidget);
  });
}