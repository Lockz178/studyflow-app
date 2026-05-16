import 'package:flutter/material.dart';
import '../../models/study_event.dart';
import '../../models/study_plan.dart';
import '../../models/plan_item.dart';
import '../deadline_window_chip.dart';
import '../stat_pill.dart';

class RecommendedTodayCard extends StatelessWidget {
  final PlanItem? todayPlanItem;
  final StudyPlan? activePlan;
  final int deadlineWindowDays;
  final ValueChanged<int> onWindowChanged;
  final int completedDays;
  final int totalDays;
  final int completedPlans;
  final int totalPlans;
  final int overallProgressPercent;
  final List<StudyEvent> todayDeadlines;
  final List<StudyEvent> windowDeadlines;
  final StudyEvent? nextDeadline;
  final String Function(DateTime) formatDate;

  const RecommendedTodayCard({
    super.key,
    required this.todayPlanItem,
    required this.activePlan,
    required this.deadlineWindowDays,
    required this.onWindowChanged,
    required this.completedDays,
    required this.totalDays,
    required this.completedPlans,
    required this.totalPlans,
    required this.overallProgressPercent,
    required this.todayDeadlines,
    required this.windowDeadlines,
    required this.nextDeadline,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6D28D9), Color(0xFF9333EA), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9333EA).withAlpha(70),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended for today',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            todayPlanItem != null
                ? 'Day ${todayPlanItem!.day}: ${todayPlanItem!.title}'
                : 'Create a study plan to get started',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            todayPlanItem != null
                ? '${todayPlanItem!.details}\nPlan: ${activePlan?.topic}'
                : 'Open the Study Planner from the menu to create a plan. StudyFlow will build a day-by-day schedule for you.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DeadlineWindowChip(
                label: '7 days',
                selected: deadlineWindowDays == 7,
                onTap: () => onWindowChanged(7),
              ),
              DeadlineWindowChip(
                label: '14 days',
                selected: deadlineWindowDays == 14,
                onTap: () => onWindowChanged(14),
              ),
              DeadlineWindowChip(
                label: '30 days',
                selected: deadlineWindowDays == 30,
                onTap: () => onWindowChanged(30),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              StatPill(label: 'Days done', value: '$completedDays/$totalDays'),
              StatPill(
                label: 'Plans completed',
                value: '$completedPlans/$totalPlans',
              ),
              StatPill(
                label: 'Overall progress',
                value: '$overallProgressPercent%',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today’s deadlines',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                if (todayDeadlines.isEmpty)
                  const Text(
                    'No deadlines today. Good chance to make progress on your study plans.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  )
                else
                  ...todayDeadlines.map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '• ${event.title} — ${event.course}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (windowDeadlines.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Next deadline: ${windowDeadlines.first.title} • ${formatDate(windowDeadlines.first.date)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ] else if (nextDeadline != null) ...[
            const SizedBox(height: 12),
            Text(
              'Next deadline: ${nextDeadline!.title} • ${formatDate(nextDeadline!.date)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
