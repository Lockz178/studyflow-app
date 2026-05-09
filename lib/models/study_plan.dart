import 'plan_item.dart';

class StudyPlan {
  final String id;
  final String topic;
  final String subject;
  final int totalDays;
  final DateTime createdAt;
  final List<PlanItem> items;
  bool completionCelebrated;

  StudyPlan({
    required this.id,
    required this.topic,
    required this.subject,
    required this.totalDays,
    required this.createdAt,
    required this.items,
    this.completionCelebrated = false,
  });

  int get completedCount => items.where((item) => item.completed).length;

  double get progressValue {
    if (items.isEmpty) return 0;
    return completedCount / items.length;
  }

  bool get isCompleted => items.isNotEmpty && completedCount == items.length;

  PlanItem? get nextIncomplete {
    for (final item in items) {
      if (!item.completed) return item;
    }
    return items.isNotEmpty ? items.first : null;
  }
}
