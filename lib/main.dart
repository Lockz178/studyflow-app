import 'dart:math';

import 'package:flutter/material.dart';
import 'package:studyflow_app/premium/premium_controller.dart';
import 'package:studyflow_app/premium/premium_scope.dart';
import 'package:studyflow_app/premium/premium_ui.dart';
import 'package:studyflow_app/schedule/schedule_page.dart';
import 'package:studyflow_app/planner/planner_page.dart';

void main() {
  runApp(const StudyFlowApp());
}

class StudyFlowApp extends StatefulWidget {
  const StudyFlowApp({super.key});

  @override
  State<StudyFlowApp> createState() => _StudyFlowAppState();
}

class _StudyFlowAppState extends State<StudyFlowApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  late final PremiumController _premiumController;

  @override
  void initState() {
    super.initState();
    _premiumController = PremiumController(isPremium: false);
  }

  @override
  void dispose() {
    _premiumController.dispose();
    super.dispose();
  }

  void _changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScope(
      controller: _premiumController,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'StudyFlow',
        themeMode: _themeMode,
        theme: _lightTheme(),
        darkTheme: _darkTheme(),
        home: HomeScreen(
          themeMode: _themeMode,
          onThemeChanged: _changeTheme,
        ),
      ),
    );
  }
}

ThemeData _lightTheme() {
  const primary = Color(0xFF7C3AED);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F7FB),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      foregroundColor: Color(0xFF111827),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

ThemeData _darkTheme() {
  const primary = Color(0xFF8B5CF6);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF070B17),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF0C1224),
      surfaceTintColor: Colors.transparent,
    ),
  );
}

class StudyEvent {
  final String title;
  final String course;
  final DateTime date;
  final Color color;

  const StudyEvent({
    required this.title,
    required this.course,
    required this.date,
    required this.color,
  });
}

class PlanTemplate {
  final String title;
  final String details;

  const PlanTemplate({
    required this.title,
    required this.details,
  });
}

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
  final List<String> _subjects = [
    'Math',
    'SQL',
    'Programming',
    'UI Design',
    'English',
  ];

  final TextEditingController _topicController = TextEditingController();

  final List<String> _learningTips = [
    'Use active recall before rereading. Try to answer from memory first, then check your notes.',
    'For harder subjects, study in short focused blocks and finish each block with one quick recap.',
    'A premium study routine is simple: one clear goal, one distraction-free block, one short review.',
    'When a task feels too big, break it into review, practice, and recap. Small wins reduce stress.',
    'Track visible progress. A clear plan and a moving progress bar make it easier to stay consistent.',
    'Do the most mentally difficult task first while your energy is still high.',
  ];

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
    _learningTip = _learningTips[Random().nextInt(_learningTips.length)];
    _allEvents = _buildEventsAroundNow(now);
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  List<StudyEvent> _buildEventsAroundNow(DateTime now) {
    final currentMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final previousMonth = DateTime(now.year, now.month - 1, 1);

    return [
      ..._seedMonthEvents(previousMonth),
      ..._seedMonthEvents(currentMonth),
      ..._seedMonthEvents(nextMonth),
    ]..sort((a, b) => a.date.compareTo(b.date));
  }

  List<StudyEvent> _seedMonthEvents(DateTime month) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

    int safeDay(int day) => min(max(day, 1), daysInMonth);

    return [
      StudyEvent(
        title: 'Database assignment submission',
        course: 'SQL Basics',
        date: DateTime(month.year, month.month, safeDay(2)),
        color: const Color(0xFFF97316),
      ),
      StudyEvent(
        title: 'UI workshop revision',
        course: 'Mobile App Design',
        date: DateTime(month.year, month.month, safeDay(4)),
        color: const Color(0xFF8B5CF6),
      ),
      StudyEvent(
        title: 'Math practice set',
        course: 'Calculus',
        date: DateTime(month.year, month.month, safeDay(9)),
        color: const Color(0xFFF97316),
      ),
      StudyEvent(
        title: 'Pair discussion meeting',
        course: 'Communication Skills',
        date: DateTime(month.year, month.month, safeDay(13)),
        color: const Color(0xFFEC4899),
      ),
      StudyEvent(
        title: 'Submit programming homework',
        course: 'Programming',
        date: DateTime(month.year, month.month, safeDay(18)),
        color: const Color(0xFF06B6D4),
      ),
      StudyEvent(
        title: 'Server lab checkpoint',
        course: 'Server Technologies',
        date: DateTime(month.year, month.month, safeDay(24)),
        color: const Color(0xFFF97316),
      ),
      StudyEvent(
        title: 'Security week review',
        course: 'Cybersecurity',
        date: DateTime(month.year, month.month, safeDay(26)),
        color: const Color(0xFF8B5CF6),
      ),
      StudyEvent(
        title: 'HTTPS practice task',
        course: 'Web Services',
        date: DateTime(month.year, month.month, safeDay(30)),
        color: const Color(0xFFF97316),
      ),
    ];
  }

  List<PlanTemplate> _templatesForSubject(String subject) {
    switch (subject) {
      case 'Math':
        return const [
          PlanTemplate(
            title: 'Review key formulas',
            details: 'Go through the main formulas and summary notes for 45 minutes.',
          ),
          PlanTemplate(
            title: 'Solve easy exercises',
            details: 'Warm up with simple questions and focus on correct method.',
          ),
          PlanTemplate(
            title: 'Medium practice set',
            details: 'Solve mixed problems without checking notes too early.',
          ),
          PlanTemplate(
            title: 'Fix weak areas',
            details: 'Review mistakes and rewrite full correct solution steps.',
          ),
          PlanTemplate(
            title: 'Timed problem session',
            details: 'Simulate a short test and manage time more carefully.',
          ),
          PlanTemplate(
            title: 'Formula recap',
            details: 'Condense the important formulas into one clean review page.',
          ),
          PlanTemplate(
            title: 'Final revision',
            details: 'Mix theory, formulas, and harder problems in one session.',
          ),
        ];
      case 'SQL':
        return const [
          PlanTemplate(
            title: 'Review SQL basics',
            details: 'Study SELECT, WHERE, ORDER BY, and LIMIT with examples.',
          ),
          PlanTemplate(
            title: 'Filtering practice',
            details: 'Write queries with conditions, sorting, and pattern matching.',
          ),
          PlanTemplate(
            title: 'Joins focus',
            details: 'Practice INNER JOIN and LEFT JOIN on sample tables.',
          ),
          PlanTemplate(
            title: 'Aggregation day',
            details: 'Use COUNT, AVG, SUM, GROUP BY, and HAVING in exercises.',
          ),
          PlanTemplate(
            title: 'Mini assignment',
            details: 'Complete one realistic database task end to end.',
          ),
          PlanTemplate(
            title: 'Debug wrong queries',
            details: 'Review failed queries and understand the logic behind fixes.',
          ),
          PlanTemplate(
            title: 'Final SQL recap',
            details: 'Mix joins, filters, and aggregates in one focused review.',
          ),
        ];
      case 'Programming':
        return const [
          PlanTemplate(
            title: 'Core syntax review',
            details: 'Refresh variables, conditions, functions, and basic structure.',
          ),
          PlanTemplate(
            title: 'Small coding tasks',
            details: 'Solve short exercises and focus on readable code.',
          ),
          PlanTemplate(
            title: 'Loops and collections',
            details: 'Practice iteration, lists, arrays, and common logic patterns.',
          ),
          PlanTemplate(
            title: 'Build one mini feature',
            details: 'Turn a small idea into working code from start to finish.',
          ),
          PlanTemplate(
            title: 'Debugging session',
            details: 'Find and fix errors slowly, one cause at a time.',
          ),
          PlanTemplate(
            title: 'Refactor session',
            details: 'Clean naming, remove clutter, and improve code structure.',
          ),
          PlanTemplate(
            title: 'Final mixed challenge',
            details: 'Combine several concepts in one realistic practice task.',
          ),
        ];
      case 'UI Design':
        return const [
          PlanTemplate(
            title: 'Layout principles',
            details: 'Study spacing, alignment, and visual hierarchy in mobile UI.',
          ),
          PlanTemplate(
            title: 'Design inspiration review',
            details: 'Analyze modern screens and note what feels premium.',
          ),
          PlanTemplate(
            title: 'Wireframe practice',
            details: 'Sketch rough screens before thinking about colors.',
          ),
          PlanTemplate(
            title: 'Typography and color',
            details: 'Focus on contrast, font scale, and cleaner visual rhythm.',
          ),
          PlanTemplate(
            title: 'Improve one screen',
            details: 'Take one weak screen and redesign it more professionally.',
          ),
          PlanTemplate(
            title: 'Consistency check',
            details: 'Unify buttons, cards, icons, spacing, and corner radius.',
          ),
          PlanTemplate(
            title: 'Final polish pass',
            details: 'Review the whole interface and refine small details.',
          ),
        ];
      default:
        return const [
          PlanTemplate(
            title: 'Vocabulary review',
            details: 'Revise useful academic words and short examples.',
          ),
          PlanTemplate(
            title: 'Reading session',
            details: 'Read an article and highlight difficult expressions.',
          ),
          PlanTemplate(
            title: 'Writing practice',
            details: 'Write one paragraph and improve grammar and clarity.',
          ),
          PlanTemplate(
            title: 'Listening practice',
            details: 'Listen to English content and summarize the main idea.',
          ),
          PlanTemplate(
            title: 'Speaking practice',
            details: 'Explain a topic aloud and work on fluency.',
          ),
          PlanTemplate(
            title: 'Grammar focus',
            details: 'Review one grammar topic and do short exercises.',
          ),
          PlanTemplate(
            title: 'Final recap',
            details: 'Mix vocabulary, reading, and writing in one session.',
          ),
        ];
    }
  }

  StudyPlan _buildPlan({
    required String topic,
    required String subject,
    required int totalDays,
  }) {
    final templates = _templatesForSubject(subject);

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
    return _allEvents.where((event) => DateUtils.isSameDay(event.date, now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<StudyEvent> _deadlinesForWindow(int days) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(Duration(days: days));

    return _allEvents.where((event) {
      final eventDay = DateTime(event.date.year, event.date.month, event.date.day);
      return !eventDay.isBefore(start) && eventDay.isBefore(end);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  StudyEvent? _nextDeadline() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcoming = _allEvents.where((event) {
      final day = DateTime(event.date.year, event.date.month, event.date.day);
      return !day.isBefore(today);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

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
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
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
                  style: TextStyle(
                    fontSize: 15,
                    color: textSecondary,
                  ),
                )
              else
                ...events.map(
                  (event) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF171E33) : const Color(0xFFF8FAFC),
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
        builder: (_) => ProgressPage(
          plans: _plans,
          onDeletePlan: _deletePlanById,
        ),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openPlansPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlansPage(
          plans: _plans,
          onDeletePlan: _deletePlanById,
        ),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openPlannerPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlannerPage(
          plans: _plans,
          subjects: _subjects,
          onCreatePlan: ({
            required String topic,
            required String subject,
            required int totalDays,
          }) {
            final plan = _buildPlan(topic: topic, subject: subject, totalDays: totalDays);
            setState(() {
              _plans.insert(0, plan);
            });
          },
          onOpenPlan: (plan) => _openPlanDetail(plan as StudyPlan),
          onDeletePlan: _deletePlanById,
        ),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openSchedulePage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SchedulePage(
          plans: _plans,
          events: _allEvents,
        ),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  void _openPlaceholder(String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaceholderPage(title: title),
      ),
    );
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
    final surface = isDark ? const Color(0xFF0F162A) : Colors.white;
    final surfaceSoft = isDark ? const Color(0xFF161F36) : const Color(0xFFF8FAFC);
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
    final overallProgressPercent =
        totalDays == 0 ? 0 : ((completedDays / totalDays) * 100).round();

    return Scaffold(
      drawer: AppDrawer(
        onOpenDashboard: () {
          Navigator.pop(context);
        },
        onOpenSchedule: () {
          Navigator.pop(context);
          _openSchedulePage();
        },
        onOpenPlanner: () {
          Navigator.pop(context);
          _openPlannerPage();
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        colors: [Color(0xFF161B33), Color(0xFF251B45)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFFF3E8FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark ? const Color(0xFF263250) : const Color(0xFFE9D5FF),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withAlpha(isDark ? 30 : 20),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withAlpha(28),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.tips_and_updates_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Learning Tip',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _learningTip,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6D28D9),
                    Color(0xFF9333EA),
                    Color(0xFFEC4899),
                  ],
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
                        ? 'Day ${todayPlanItem.day}: ${todayPlanItem.title}'
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
                        ? '${todayPlanItem.details}\nPlan: ${activePlan?.topic}'
                        : 'Set a topic and timeline below, then StudyFlow will build a day-by-day study plan for you.',
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
                        selected: _deadlineWindowDays == 7,
                        onTap: () {
                          setState(() {
                            _deadlineWindowDays = 7;
                          });
                        },
                      ),
                      DeadlineWindowChip(
                        label: '14 days',
                        selected: _deadlineWindowDays == 14,
                        onTap: () {
                          setState(() {
                            _deadlineWindowDays = 14;
                          });
                        },
                      ),
                      DeadlineWindowChip(
                        label: '30 days',
                        selected: _deadlineWindowDays == 30,
                        onTap: () {
                          setState(() {
                            _deadlineWindowDays = 30;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _StatPill(
                        label: 'Days done',
                        value: '$completedDays/$totalDays',
                      ),
                      _StatPill(
                        label: 'Plans completed',
                        value: '$completedPlans/$totalPlans',
                      ),
                      _StatPill(
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
                      'Next deadline: ${windowDeadlines.first.title} • ${_formatDate(windowDeadlines.first.date)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ] else if (nextDeadline != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Next deadline: ${nextDeadline.title} • ${_formatDate(nextDeadline.date)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 18 : 10),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create a Study Plan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can create as many plans as you want. Each plan gets its own daily checklist and progress bar.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _topicController,
                    decoration: _inputDecoration(
                      context,
                      'Topic or assignment name',
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSubject,
                    decoration: _inputDecoration(
                      context,
                      'Choose a subject',
                    ),
                    items: _subjects
                        .map(
                          (subject) => DropdownMenuItem(
                            value: subject,
                            child: Text(subject),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedSubject = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Days to finish',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        '${_selectedDays.round()} days',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _selectedDays,
                    min: 3,
                    max: 14,
                    divisions: 11,
                    activeColor: const Color(0xFF7C3AED),
                    onChanged: (value) {
                      setState(() {
                        _selectedDays = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _createPlan,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF111827),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.add_task_rounded),
                      label: const Text('Create Study Plan'),
                    ),
                  ),
                ],
              ),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
              )
            else
              ..._plans.take(3).map(
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

  InputDecoration _inputDecoration(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark ? const Color(0xFF171F33) : const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF27304B) : const Color(0xFFE5E7EB),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF27304B) : const Color(0xFFE5E7EB),
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final VoidCallback onOpenDashboard;
  final VoidCallback onOpenSchedule;
  final VoidCallback onOpenPlanner;
  final VoidCallback onOpenFavourites;
  final VoidCallback onOpenProgress;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenHelp;

  const AppDrawer({
    super.key,
    required this.onOpenDashboard,
    required this.onOpenSchedule,
    required this.onOpenPlanner,
    required this.onOpenFavourites,
    required this.onOpenProgress,
    required this.onOpenSettings,
    required this.onOpenHelp,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6D28D9),
                    Color(0xFF9333EA),
                    Color(0xFFEC4899),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(28),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'StudyFlow',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Focus smarter. Stress less.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const PremiumBadge(compact: true),
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () => showUpgradeBottomSheet(context),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                              child: const Text(
                                'Upgrade',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    onTap: onOpenDashboard,
                  ),
                  _DrawerItem(
                    icon: Icons.event_note_rounded,
                    title: 'Schedule',
                    onTap: onOpenSchedule,
                  ),
                  _DrawerItem(
                    icon: Icons.auto_awesome_motion_rounded,
                    title: 'Study Planner',
                    onTap: onOpenPlanner,
                  ),
                  _DrawerItem(
                    icon: Icons.favorite_rounded,
                    title: 'Favourites',
                    onTap: onOpenFavourites,
                  ),
                  _DrawerItem(
                    icon: Icons.insights_rounded,
                    title: 'Progress',
                    onTap: onOpenProgress,
                  ),
                  _DrawerItem(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    onTap: onOpenSettings,
                  ),
                  _DrawerItem(
                    icon: Icons.help_center_rounded,
                    title: 'Help & Feedback',
                    onTap: onOpenHelp,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF171F33) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF7C3AED).withAlpha(25),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Student Mode',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            'Keep your semester under control',
                            style: TextStyle(
                              fontSize: 12,
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
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF171F33) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: const Color(0xFF7C3AED)),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}

class MonthCalendar extends StatelessWidget {
  final DateTime displayedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final List<StudyEvent> events;
  final void Function(DateTime day, List<StudyEvent> events) onDayTap;

  const MonthCalendar({
    super.key,
    required this.displayedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.events,
    required this.onDayTap,
  });

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF0F162A) : Colors.white;
    final cellSurface = isDark ? const Color(0xFF171F33) : const Color(0xFFFBFCFF);
    final border = isDark ? const Color(0xFF27304B) : const Color(0xFFE5E7EB);
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    final firstDay = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(displayedMonth.year, displayedMonth.month);
    final offset = firstDay.weekday - 1;
    final totalSlots = ((offset + daysInMonth + 6) ~/ 7) * 7;

    final today = DateTime.now();
    final isCurrentDisplayedMonth =
        today.year == displayedMonth.year && today.month == displayedMonth.month;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 18 : 10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  '${_monthName(displayedMonth.month)} ${displayedMonth.year}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: _weekdays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalSlots,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 86,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              if (index < offset || index >= offset + daysInMonth) {
                return Container(
                  decoration: BoxDecoration(
                    color: cellSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: border),
                  ),
                );
              }

              final dayNumber = index - offset + 1;
              final dayDate = DateTime(displayedMonth.year, displayedMonth.month, dayNumber);
              final dayEvents = events.where((e) => DateUtils.isSameDay(e.date, dayDate)).toList();
              final isToday = isCurrentDisplayedMonth && dayNumber == today.day;

              return InkWell(
                onTap: () => onDayTap(dayDate, dayEvents),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cellSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isToday ? const Color(0xFF7C3AED) : Colors.transparent,
                          ),
                          child: Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isToday ? Colors.white : textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (dayEvents.isEmpty)
                        const Spacer()
                      else
                        ...dayEvents.take(2).map(
                          (event) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    color: event.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF7C3AED),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (dayEvents.length > 2)
                        Text(
                          '+${dayEvents.length - 2} more',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DeadlineWindowChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const DeadlineWindowChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withAlpha(32) : Colors.white.withAlpha(16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? Colors.white : Colors.white.withAlpha(70),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$value ',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
            TextSpan(
              text: label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F162A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 18 : 10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withAlpha(22),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class StudyPlanCard extends StatelessWidget {
  final StudyPlan plan;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const StudyPlanCard({
    super.key,
    required this.plan,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F162A) : Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 18 : 10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.topic,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                ),
                if (onDelete != null) ...[
                  IconButton(
                    tooltip: 'Delete plan',
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 2),
                ],
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF7C3AED),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${plan.subject} • ${plan.totalDays} days',
              style: TextStyle(
                fontSize: 13,
                color: textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: plan.progressValue,
                minHeight: 10,
                backgroundColor: isDark
                    ? const Color(0xFF25304B)
                    : const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF7C3AED)),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${plan.completedCount} / ${plan.items.length} days completed',
              style: TextStyle(
                fontSize: 13,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlanDetailPage extends StatefulWidget {
  final StudyPlan plan;
  final VoidCallback? onDeletePlan;

  const PlanDetailPage({
    super.key,
    required this.plan,
    this.onDeletePlan,
  });

  @override
  State<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends State<PlanDetailPage> {
  Future<void> _confirmDeletePlan() async {
    if (widget.onDeletePlan == null) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF10172A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Text(
            'Delete study plan?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'This will delete "${widget.plan.topic}" and its progress.',
            style: const TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    widget.onDeletePlan?.call();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _toggleItem(PlanItem item) async {
    setState(() {
      item.completed = !item.completed;
    });

    if (!widget.plan.isCompleted) {
      widget.plan.completionCelebrated = false;
      return;
    }

    if (widget.plan.completionCelebrated) return;

    widget.plan.completionCelebrated = true;

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF10172A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Text(
            '🎉 Congrats!',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'You finished the "${widget.plan.topic}" study plan. Nice work.',
            style: const TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Awesome'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.plan.topic,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          if (widget.onDeletePlan != null)
            IconButton(
              tooltip: 'Delete plan',
              onPressed: _confirmDeletePlan,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6D28D9),
                  Color(0xFF9333EA),
                  Color(0xFFEC4899),
                ],
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
                Text(
                  widget.plan.subject,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.plan.topic,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.plan.completedCount} of ${widget.plan.items.length} days completed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: widget.plan.progressValue,
                    minHeight: 12,
                    backgroundColor: Colors.white.withAlpha(40),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Daily plan',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.plan.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PlanDayTile(
                item: item,
                onToggle: () => _toggleItem(item),
              ),
            ),
          ),
          if (widget.plan.isCompleted)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF171F33) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                'You completed this plan. You can still uncheck any day if you want to update it.',
                style: TextStyle(
                  color: textSecondary,
                  height: 1.45,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PlanDayTile extends StatelessWidget {
  final PlanItem item;
  final VoidCallback onToggle;

  const PlanDayTile({
    super.key,
    required this.item,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F162A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 18 : 8),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: item.completed
                      ? const Color(0xFF7C3AED)
                      : (isDark ? const Color(0xFF171F33) : const Color(0xFFF3F4F6)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.completed ? Icons.check_rounded : Icons.circle_outlined,
                  size: 18,
                  color: item.completed ? Colors.white : const Color(0xFF9CA3AF),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day ${item.day}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: item.completed ? textSecondary : textPrimary,
                      decoration:
                          item.completed ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.details,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlansPage extends StatefulWidget {
  final List<StudyPlan> plans;
  final void Function(String planId)? onDeletePlan;

  const PlansPage({
    super.key,
    required this.plans,
    this.onDeletePlan,
  });

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  Future<void> _openPlan(StudyPlan plan) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanDetailPage(
          plan: plan,
          onDeletePlan: widget.onDeletePlan == null
              ? null
              : () => widget.onDeletePlan!(plan.id),
        ),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Study Planner',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: widget.plans.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No plans yet. Create one from the dashboard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: textSecondary,
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              itemCount: widget.plans.length,
              itemBuilder: (context, index) {
                final plan = widget.plans[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: StudyPlanCard(
                    plan: plan,
                    onTap: () => _openPlan(plan),
                    onDelete: widget.onDeletePlan == null
                        ? null
                        : () => widget.onDeletePlan!(plan.id),
                  ),
                );
              },
            ),
    );
  }
}

class ProgressPage extends StatefulWidget {
  final List<StudyPlan> plans;
  final void Function(String planId)? onDeletePlan;

  const ProgressPage({
    super.key,
    required this.plans,
    this.onDeletePlan,
  });

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  Future<void> _openPlan(StudyPlan plan) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanDetailPage(
          plan: plan,
          onDeletePlan: widget.onDeletePlan == null
              ? null
              : () => widget.onDeletePlan!(plan.id),
        ),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final completedPlanList = widget.plans.where((plan) => plan.isCompleted).toList();
    final completedPlans = completedPlanList.length;
    final completedDays = completedPlanList.fold<int>(
      0,
      (sum, plan) => sum + plan.completedCount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Progress',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6D28D9),
                  Color(0xFF9333EA),
                  Color(0xFFEC4899),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your progress',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$completedPlans completed plan${completedPlans == 1 ? '' : 's'} • $completedDays days done',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This page only shows study plans you finished (100%).',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (completedPlanList.isEmpty)
            Text(
              'No completed plans yet. Finish a plan to see it here.',
              style: TextStyle(
                fontSize: 15,
                color: textSecondary,
              ),
            )
          else
            ...completedPlanList.map(
              (plan) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StudyPlanCard(
                  plan: plan,
                  onTap: () => _openPlan(plan),
                  onDelete: widget.onDeletePlan == null
                      ? null
                      : () => widget.onDeletePlan!(plan.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF0F162A) : Colors.white;
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'StudyFlow Plus',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withAlpha(18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                  title: const Text(
                    'Premium status',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text('Local test toggle (no billing yet)'),
                  trailing: const PremiumBadge(compact: true),
                  onTap: () => showUpgradeBottomSheet(context),
                ),
                SwitchListTile(
                  value: PremiumScope.of(context).isPremium,
                  title: const Text('Enable Premium (test)'),
                  subtitle: const Text('Switch between free and premium behavior'),
                  onChanged: (value) => PremiumScope.of(context).setPremium(value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Appearance',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: RadioGroup<ThemeMode>(
              groupValue: widget.currentThemeMode,
              onChanged: (value) {
                if (value == null) return;
                widget.onThemeChanged(value);
                setState(() {});
              },
              child: const Column(
                children: [
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    title: Text('Light mode'),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    title: Text('Dark mode'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'General',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: notificationsEnabled,
                  title: const Text('Notifications'),
                  subtitle: const Text('Remind me about deadlines and study tasks'),
                  onChanged: (value) {
                    setState(() {
                      notificationsEnabled = value;
                    });
                  },
                ),
                const ListTile(
                  title: Text('Version'),
                  subtitle: Text('StudyFlow prototype'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '$title page placeholder.\nWe can build this next.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}