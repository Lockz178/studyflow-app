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

  Map<String, dynamic> toJson() => {
    'id': id,
    'topic': topic,
    'subject': subject,
    'totalDays': totalDays,
    'createdAt': createdAt.toIso8601String(),
    'completionCelebrated': completionCelebrated,
    'items': items.map((e) => e.toJson()).toList(),
  };

  factory StudyPlan.fromJson(Map<String, dynamic> json) => StudyPlan(
    id: json['id'] as String,
    topic: json['topic'] as String,
    subject: json['subject'] as String,
    totalDays: json['totalDays'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
    items: (json['items'] as List<dynamic>)
        .map((e) => PlanItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    completionCelebrated: json['completionCelebrated'] as bool? ?? false,
  );
}
