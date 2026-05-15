import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow_app/main.dart';

void main() {
  testWidgets('StudyFlow home screen shows main dashboard content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StudyFlowApp());
    await tester.pumpAndSettle();

    expect(find.text('StudyFlow'), findsOneWidget);
    expect(find.text('Learning Tip'), findsOneWidget);
    expect(find.text('Recommended for today'), findsOneWidget);
    expect(find.text('Create a study plan to get started'), findsOneWidget);
  });
}