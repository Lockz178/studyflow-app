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
}
