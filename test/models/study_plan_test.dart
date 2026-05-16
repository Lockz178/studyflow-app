import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow_app/models/plan_item.dart';
import 'package:studyflow_app/models/study_plan.dart';

void main() {
  group('StudyPlan JSON', () {
    test('round-trips through toJson and fromJson', () {
      final original = StudyPlan(
        id: 'plan-1',
        topic: 'Exam prep',
        subject: 'Math',
        totalDays: 2,
        createdAt: DateTime.utc(2026, 5, 10, 12, 30),
        items: [
          PlanItem(day: 1, title: 'Review', details: 'Formulas', completed: true),
          PlanItem(day: 2, title: 'Practice', details: 'Problem set'),
        ],
        completionCelebrated: true,
      );

      final json = original.toJson();
      final restored = StudyPlan.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.topic, original.topic);
      expect(restored.subject, original.subject);
      expect(restored.totalDays, original.totalDays);
      expect(restored.createdAt, original.createdAt);
      expect(restored.completionCelebrated, original.completionCelebrated);
      expect(restored.items.length, 2);
      expect(restored.items[0].completed, isTrue);
      expect(restored.items[1].completed, isFalse);
    });
  });

  group('PlanItem JSON', () {
    test('fromJson uses defaults for completed', () {
      final item = PlanItem.fromJson({
        'day': 3,
        'title': 'Read',
        'details': 'Chapter 2',
      });
      expect(item.completed, isFalse);
    });
  });
}
