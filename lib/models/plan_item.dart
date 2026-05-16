class PlanItem {
  final int day;
  final String title;
  final String details;
  bool completed;

  PlanItem({
    required this.day,
    required this.title,
    required this.details,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
    'day': day,
    'title': title,
    'details': details,
    'completed': completed,
  };

  factory PlanItem.fromJson(Map<String, dynamic> json) => PlanItem(
    day: json['day'] as int,
    title: json['title'] as String,
    details: json['details'] as String,
    completed: json['completed'] as bool? ?? false,
  );
}
