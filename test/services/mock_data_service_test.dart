import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow_app/services/mock_data_service.dart';

const _minimalJson = '''
{
  "subjects": ["Math"],
  "learningTips": ["Tip one", "Tip two"],
  "eventSeeds": [
    { "title": "Test", "course": "Math", "day": 5, "color": "000000" }
  ],
  "templates": {
    "Math": [
      { "title": "A", "details": "B" }
    ]
  }
}
''';

void main() {
  setUp(() {
    MockDataService.reset();
  });

  group('MockDataService', () {
    test('loadFromJsonString parses seed data', () {
      MockDataService.loadFromJsonString(_minimalJson);

      expect(MockDataService.subjects, ['Math']);
      expect(MockDataService.allLearningTips.length, 2);
      expect(MockDataService.getRandomTip(), isNotEmpty);
    });

    test('templatesForSubject returns subject templates when present', () {
      MockDataService.loadFromJsonString(_minimalJson);

      final templates = MockDataService.templatesForSubject('Math');
      expect(templates, isNotEmpty);
      expect(templates.first.title, 'A');
    });
  });
}
