import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/study_event.dart';
import '../models/study_plan.dart';
import '../providers/favourites_provider.dart';
import '../providers/study_flow_controller.dart';
import '../services/mock_data_service.dart';
import '../widgets/month_calendar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/info_card.dart';
import '../widgets/study_plan_card.dart';
import '../widgets/home/learning_tip_card.dart';
import '../widgets/home/recommended_today_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  void _showDayEvents(
    BuildContext context,
    DateTime date,
    List<StudyEvent> events,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF10172A) : Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Events for ${_formatDate(date)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              if (events.isEmpty)
                Text(
                  'No deadlines or activities on this day.',
                  style: TextStyle(fontSize: 15, color: textSecondary),
                )
              else
                ...events.map(
                  (event) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF171E33)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: event.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event.course,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openPlanDetail(BuildContext context, StudyPlan plan) async {
    final c = context.read<StudyFlowController>();
    await context.push('/plan/${plan.id}', extra: plan);
    if (context.mounted) {
      c.notifyPlansUpdated();
    }
  }

  void _deletePlan(BuildContext context, String planId) {
    context.read<StudyFlowController>().deletePlanById(planId);
    context.read<FavouritesProvider>().remove(planId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Study plan deleted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavouritesProvider>();
    final c = context.watch<StudyFlowController>();

    if (c.isLoadingSeedData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (c.seedDataError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('StudyFlow')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 42),
                const SizedBox(height: 12),
                const Text(
                  'Could not load study data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(c.seedDataError!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => c.loadSeedData(DateTime.now()),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceSoft = isDark
        ? const Color(0xFF161F36)
        : const Color(0xFFF8FAFC);
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    final todayDeadlines = c.deadlinesToday();
    final windowDeadlines = c.deadlinesForWindow(c.deadlineWindowDays);
    final nextDeadline = c.nextDeadline();
    final activePlan = c.firstActivePlan();
    final todayPlanItem = activePlan?.nextIncomplete;

    final plans = c.plans;
    final totalPlans = plans.length;
    final completedPlans = plans.where((plan) => plan.isCompleted).length;
    final completedDays = plans.fold<int>(
      0,
      (sum, plan) => sum + plan.completedCount,
    );
    final totalDays = plans.fold<int>(
      0,
      (sum, plan) => sum + plan.items.length,
    );
    final overallProgressPercent = totalDays == 0
        ? 0
        : ((completedDays / totalDays) * 100).round();

    return Scaffold(
      drawer: AppDrawer(
        onOpenDashboard: () {
          context.pop();
        },
        onOpenSchedule: () {
          context.pop();
          context.push('/schedule');
        },
        onOpenPlanner: () {
          context.pop();
          context.push('/planner');
        },
        onOpenTips: () {
          context.pop();
          context.push('/tips');
        },
        onOpenFavourites: () {
          context.pop();
          context.push('/favourites');
        },
        onOpenProgress: () {
          context.pop();
          context.push('/progress');
        },
        onOpenSettings: () {
          context.pop();
          context.push('/settings');
        },
        onOpenAbout: () {
          context.pop();
          context.push('/about');
        },
        onOpenHelp: () {
          context.pop();
          context.push('/help');
        },
      ),
      appBar: AppBar(
        title: const Text(
          'StudyFlow',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            LearningTipCard(learningTip: c.learningTip),
            const SizedBox(height: 18),
            RecommendedTodayCard(
              todayPlanItem: todayPlanItem,
              activePlan: activePlan,
              deadlineWindowDays: c.deadlineWindowDays,
              onWindowChanged: (days) => c.setDeadlineWindowDays(days),
              completedDays: completedDays,
              totalDays: totalDays,
              completedPlans: completedPlans,
              totalPlans: totalPlans,
              overallProgressPercent: overallProgressPercent,
              todayDeadlines: todayDeadlines,
              windowDeadlines: windowDeadlines,
              nextDeadline: nextDeadline,
              formatDate: _formatDate,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: InfoCard(
                    title: 'Courses',
                    value: '${MockDataService.subjects.length}',
                    icon: Icons.menu_book_rounded,
                    accent: const Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: InfoCard(
                    title: 'Tasks',
                    value: '${windowDeadlines.length}',
                    icon: Icons.check_circle_outline_rounded,
                    accent: const Color(0xFFEC4899),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            MonthCalendar(
              displayedMonth: c.displayedMonth,
              onPreviousMonth: c.previousMonth,
              onNextMonth: c.nextMonth,
              events: c.eventsForMonth(c.displayedMonth),
              onDayTap: (d, ev) => _showDayEvents(context, d, ev),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(
                  'My Study Plans',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                ),
                const Spacer(),
                if (plans.isNotEmpty)
                  TextButton(
                    onPressed: () => context.push('/planner'),
                    child: const Text('See all'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (plans.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surfaceSoft,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No study plans yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Open the Study Planner to create your first day-by-day study plan.',
                      style: TextStyle(fontSize: 14, color: textSecondary),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () => context.push('/planner'),
                      icon: const Icon(Icons.auto_awesome_motion_rounded),
                      label: const Text('Open Study Planner'),
                    ),
                  ],
                ),
              )
            else
              ...plans.take(3).map(
                (plan) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: StudyPlanCard(
                    plan: plan,
                    isFavorite: fav.isFavorite(plan.id),
                    onToggleFavorite: () => fav.toggle(plan.id),
                    onTap: () => _openPlanDetail(context, plan),
                    onDelete: () => _deletePlan(context, plan.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
