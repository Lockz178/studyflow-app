import 'package:flutter/material.dart';
import '../models/study_event.dart';
import '../models/study_plan.dart';
import '../models/plan_item.dart';
import '../services/mock_data_service.dart';
import '../widgets/month_calendar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/info_card.dart';
import '../widgets/study_plan_card.dart';
import '../widgets/home/learning_tip_card.dart';
import '../widgets/home/recommended_today_card.dart';
import '../widgets/home/create_plan_card.dart';
import 'plan_detail_page.dart';
import 'progress_page.dart';
import 'plans_page.dart';
import 'placeholder_page.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _topicController = TextEditingController();

  late DateTime _displayedMonth;
  late String _learningTip;
  late List<StudyEvent> _allEvents;

  String _selectedSubject = 'Math';
  double _selectedDays = 7;
  int _deadlineWindowDays = 7;

  final List<StudyPlan> _plans = [];

  void _deletePlanById(String planId) {
    setState(() {
      _plans.removeWhere((plan) => plan.id == planId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Study plan deleted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
    _learningTip = MockDataService.getRandomTip();
    _allEvents = MockDataService.buildEventsAroundNow(now);
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  StudyPlan _buildPlan({
    required String topic,
    required String subject,
    required int totalDays,
  }) {
    final templates = MockDataService.templatesForSubject(subject);

    final items = List.generate(totalDays, (index) {
      final template = templates[index % templates.length];
      return PlanItem(
        day: index + 1,
        title: template.title,
        details: template.details,
      );
    });

    return StudyPlan(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      topic: topic,
      subject: subject,
      totalDays: totalDays,
      createdAt: DateTime.now(),
      items: items,
    );
  }

  void _createPlan() {
    final topic = _topicController.text.trim().isEmpty
        ? _selectedSubject
        : _topicController.text.trim();

    final plan = _buildPlan(
      topic: topic,
      subject: _selectedSubject,
      totalDays: _selectedDays.round(),
    );

    setState(() {
      _plans.insert(0, plan);
      _topicController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Created study plan for $topic'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<StudyEvent> _eventsForMonth(DateTime month) {
    return _allEvents.where((event) {
      return event.date.year == month.year && event.date.month == month.month;
    }).toList();
  }

  List<StudyEvent> _deadlinesToday() {
    final now = DateTime.now();
    return _allEvents
        .where((event) => DateUtils.isSameDay(event.date, now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<StudyEvent> _deadlinesForWindow(int days) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(Duration(days: days));

    return _allEvents.where((event) {
      final eventDay = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      return !eventDay.isBefore(start) && eventDay.isBefore(end);
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  StudyEvent? _nextDeadline() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcoming = _allEvents.where((event) {
      final day = DateTime(event.date.year, event.date.month, event.date.day);
      return !day.isBefore(today);
    }).toList()..sort((a, b) => a.date.compareTo(b.date));

    if (upcoming.isEmpty) return null;
    return upcoming.first;
  }

  StudyPlan? _firstActivePlan() {
    for (final plan in _plans) {
      if (!plan.isCompleted) return plan;
    }
    return _plans.isNotEmpty ? _plans.first : null;
  }

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

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
        1,
      );
    });
  }

  void _showDayEvents(DateTime date, List<StudyEvent> events) {
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

  Future<void> _openPlanDetail(StudyPlan plan) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanDetailPage(
          plan: plan,
          onDeletePlan: () => _deletePlanById(plan.id),
        ),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openProgressPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ProgressPage(plans: _plans, onDeletePlan: _deletePlanById),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openPlansPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlansPage(plans: _plans, onDeletePlan: _deletePlanById),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  void _openPlaceholder(String title) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PlaceholderPage(title: title)));
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          currentThemeMode: widget.themeMode,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceSoft = isDark
        ? const Color(0xFF161F36)
        : const Color(0xFFF8FAFC);
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    final todayDeadlines = _deadlinesToday();
    final windowDeadlines = _deadlinesForWindow(_deadlineWindowDays);
    final nextDeadline = _nextDeadline();
    final activePlan = _firstActivePlan();
    final todayPlanItem = activePlan?.nextIncomplete;

    final totalPlans = _plans.length;
    final completedPlans = _plans.where((plan) => plan.isCompleted).length;
    final completedDays = _plans.fold<int>(
      0,
      (sum, plan) => sum + plan.completedCount,
    );
    final totalDays = _plans.fold<int>(
      0,
      (sum, plan) => sum + plan.items.length,
    );
    final overallProgressPercent = totalDays == 0
        ? 0
        : ((completedDays / totalDays) * 100).round();

    return Scaffold(
      drawer: AppDrawer(
        onOpenDashboard: () => Navigator.pop(context),
        onOpenSchedule: () {
          Navigator.pop(context);
          _openPlaceholder('Schedule');
        },
        onOpenPlanner: () {
          Navigator.pop(context);
          _openPlansPage();
        },
        onOpenFavourites: () {
          Navigator.pop(context);
          _openPlaceholder('Favourites');
        },
        onOpenProgress: () {
          Navigator.pop(context);
          _openProgressPage();
        },
        onOpenSettings: () {
          Navigator.pop(context);
          _openSettings();
        },
        onOpenHelp: () {
          Navigator.pop(context);
          _openPlaceholder('Help & Feedback');
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
            LearningTipCard(learningTip: _learningTip),
            const SizedBox(height: 18),
            RecommendedTodayCard(
              todayPlanItem: todayPlanItem,
              activePlan: activePlan,
              deadlineWindowDays: _deadlineWindowDays,
              onWindowChanged: (days) =>
                  setState(() => _deadlineWindowDays = days),
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
                    value: '4',
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
              displayedMonth: _displayedMonth,
              onPreviousMonth: _previousMonth,
              onNextMonth: _nextMonth,
              events: _eventsForMonth(_displayedMonth),
              onDayTap: _showDayEvents,
            ),
            const SizedBox(height: 22),
            CreatePlanCard(
              topicController: _topicController,
              selectedSubject: _selectedSubject,
              subjects: MockDataService.subjects,
              onSubjectChanged: (value) {
                if (value == null) return;
                setState(() => _selectedSubject = value);
              },
              selectedDays: _selectedDays,
              onDaysChanged: (value) => setState(() => _selectedDays = value),
              onCreatePlan: _createPlan,
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
                if (_plans.isNotEmpty)
                  TextButton(
                    onPressed: _openPlansPage,
                    child: const Text('See all'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (_plans.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surfaceSoft,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'No study plans yet. Create your first one above.',
                  style: TextStyle(fontSize: 14, color: textSecondary),
                ),
              )
            else
              ..._plans
                  .take(3)
                  .map(
                    (plan) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StudyPlanCard(
                        plan: plan,
                        onTap: () => _openPlanDetail(plan),
                        onDelete: () => _deletePlanById(plan.id),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
