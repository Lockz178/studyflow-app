import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow_app/validators/study_plan_validator.dart';

void main() {
  group('validateStudyPlanTopic', () {
    test('returns error when topic is empty', () {
      expect(
        validateStudyPlanTopic(''),
        'Please enter a topic or assignment name.',
      );
    });

    test('returns error when topic is too short', () {
      expect(
        validateStudyPlanTopic('AI'),
        'Topic must be at least 3 characters.',
      );
    });

    test('returns error when topic is too long', () {
      expect(
        validateStudyPlanTopic('A' * 61),
        'Topic must be 60 characters or less.',
      );
    });

    test('returns null when topic is valid', () {
      expect(validateStudyPlanTopic('Math exam revision'), isNull);
    });
  });
}
