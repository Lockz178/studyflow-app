import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyflow_app/providers/study_flow_controller.dart';
import 'package:studyflow_app/services/mock_data_service.dart';

const _seed = '''
{
  "subjects": ["Math"],
  "learningTips": ["Tip"],
  "eventSeeds": [
    { "title": "E", "course": "Math", "day": 1, "color": "000000" }
  ],
  "templates": {
    "Math": [
      { "title": "Day", "details": "Work" }
    ]
  }
}
''';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    MockDataService.reset();
    MockDataService.loadFromJsonString(_seed);
  });

  test('StudyFlowController addPlan inserts at front', () async {
    final c = StudyFlowController();
    await c.loadSeedData(DateTime.utc(2026, 5, 1));

    expect(c.plans, isEmpty);
    c.addPlan(topic: 'T1', subject: 'Math', totalDays: 1);
    expect(c.plans.length, 1);
    expect(c.plans.first.topic, 'T1');

    c.deletePlanById(c.plans.first.id);
    expect(c.plans, isEmpty);
  });

  test('StudyFlowController persists and restores plans', () async {
    final c = StudyFlowController();
    await c.loadSeedData(DateTime.utc(2026, 5, 1));
    c.addPlan(topic: 'Persist me', subject: 'Math', totalDays: 3);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final c2 = StudyFlowController();
    await c2.initialize();
    expect(c2.plans.any((p) => p.topic == 'Persist me'), isTrue);
  });
}
