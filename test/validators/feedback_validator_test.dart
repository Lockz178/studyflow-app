import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow_app/validators/feedback_validator.dart';

void main() {
  group('validateFeedbackMessage', () {
    test('rejects short messages', () {
      expect(validateFeedbackMessage('short'), isNotNull);
    });

    test('accepts valid length', () {
      expect(validateFeedbackMessage('This is enough characters here.'), isNull);
    });

    test('rejects overly long messages', () {
      expect(validateFeedbackMessage('x' * 2001), isNotNull);
    });
  });
}
