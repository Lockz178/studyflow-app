import 'package:flutter/material.dart';

import '../premium/premium_ui.dart';
import '../premium/premium_scope.dart';

// Using existing models from main.dart (StudyPlan / PlanItem / StudyEvent).
// Keep this screen UI-focused and easy to connect to real data later.

enum ScheduleCategory {
  classSession,
  study,
  deadline,
  breakTime,
  revision,
  personal,
}

class ScheduleEntry {
  final DateTime start;
  final DateTime end;
  final ScheduleCategory category;
  final String title;
  final String subtitle;
  final bool isUrgent;

  const ScheduleEntry({
    required this.start,
    required this.end,
    required this.category,
    required this.title,
    required this.subtitle,
    this.isUrgent = false,
  });

  bool get isAllDay => start.hour == 0 && start.minute == 0 && end.difference(start).inHours >= 23;
}

class SchedulePage extends StatefulWidget {
  final List<dynamic> plans; // expects List<StudyPlan>
  final List<dynamic> events; // expects List<StudyEvent>

  const SchedulePage({
    super.key,
    required this.plans,
    required this.events,
  });

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  ScheduleCategory? _categoryFilter;

  DateTime _today(DateTime now) => DateTime(now.year, now.month, now.day);

  dynamic _nextUpcomingEvent(DateTime now) {
    final today = _today(now);
    final upcoming = widget.events.where((event) {
      final d = DateTime(event.date.year, event.date.month, event.date.day);
      return !d.isBefore(today);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  List<dynamic> _deadlinesForDay(DateTime day) {
    return widget.events.where((event) {
      final d = DateTime(event.date.year, event.date.month, event.date.day);
      return d == day;
    }).toList();
  }

  dynamic _firstActivePlan() {
    for (final plan in widget.plans) {
      if (plan.items.isNotEmpty && !plan.isCompleted) return plan;
    }
    return widget.plans.isNotEmpty ? widget.plans.first : null;
  }

  List<ScheduleEntry> _buildMockAndDerivedTimeline(DateTime now) {
    final today = _today(now);

    DateTime at(int hour, int minute) => DateTime(today.year, today.month, today.day, hour, minute);

    final entries = <ScheduleEntry>[
      ScheduleEntry(
        start: at(9, 0),
        end: at(10, 20),
        category: ScheduleCategory.classSession,
        title: 'SQL class',
        subtitle: 'Lecture + mini quiz',
      ),
      ScheduleEntry(
        start: at(10, 30),
        end: at(10, 50),
        category: ScheduleCategory.breakTime,
        title: 'Break',
        subtitle: 'Walk + water',
      ),
      ScheduleEntry(
        start: at(11, 0),
        end: at(12, 0),
        category: ScheduleCategory.study,
        title: 'Math study block',
        subtitle: 'Practice set + fix mistakes',
      ),
      ScheduleEntry(
        start: at(14, 0),
        end: at(15, 15),
        category: ScheduleCategory.deadline,
        title: 'UI assignment work',
        subtitle: 'Ship a clean draft',
        isUrgent: true,
      ),
      ScheduleEntry(
        start: at(18, 0),
        end: at(18, 25),
        category: ScheduleCategory.revision,
        title: 'Review notes',
        subtitle: 'Quick recap + highlight weak points',
      ),
    ];

    final deadlinesToday = _deadlinesForDay(today);
    for (final event in deadlinesToday) {
      entries.add(
        ScheduleEntry(
          start: at(17, 30),
          end: at(18, 0),
          category: ScheduleCategory.deadline,
          title: event.title,
          subtitle: event.course,
          isUrgent: true,
        ),
      );
    }

    final activePlan = _firstActivePlan();
    final nextItem = activePlan?.nextIncomplete;
    if (nextItem != null) {
      entries.add(
        ScheduleEntry(
          start: at(16, 0),
          end: at(17, 0),
          category: ScheduleCategory.study,
          title: 'Focus block: ${nextItem.title}',
          subtitle: 'Plan: ${activePlan.topic}',
        ),
      );
    }

    entries.sort((a, b) => a.start.compareTo(b.start));
    return entries;
  }

  ScheduleEntry? _currentEntry(List<ScheduleEntry> entries, DateTime now) {
    for (final entry in entries) {
      if (!now.isBefore(entry.start) && now.isBefore(entry.end)) return entry;
    }
    return null;
  }

  List<ScheduleEntry> _laterTodayEntries(List<ScheduleEntry> entries, DateTime now) {
    return entries.where((e) => e.start.isAfter(now)).toList();
  }

  List<ScheduleEntry> _tomorrowEntries(DateTime now) {
    final tomorrow = _today(now).add(const Duration(days: 1));
    DateTime at(int hour, int minute) => DateTime(tomorrow.year, tomorrow.month, tomorrow.day, hour, minute);

    final activePlan = _firstActivePlan();
    final nextItem = activePlan?.nextIncomplete;

    final list = <ScheduleEntry>[
      ScheduleEntry(
        start: at(9, 30),
        end: at(10, 45),
        category: ScheduleCategory.classSession,
        title: 'Programming lab',
        subtitle: 'Practice + submit checkpoint',
      ),
      ScheduleEntry(
        start: at(12, 0),
        end: at(12, 30),
        category: ScheduleCategory.breakTime,
        title: 'Lunch',
        subtitle: 'Reset + breathe',
      ),
    ];

    final tomorrowDeadlines = _deadlinesForDay(tomorrow);
    for (final event in tomorrowDeadlines) {
      list.add(
        ScheduleEntry(
          start: at(15, 30),
          end: at(16, 0),
          category: ScheduleCategory.deadline,
          title: event.title,
          subtitle: event.course,
          isUrgent: true,
        ),
      );
    }

    if (nextItem != null) {
      list.add(
        ScheduleEntry(
          start: at(16, 0),
          end: at(17, 10),
          category: ScheduleCategory.study,
          title: 'Focus block: ${nextItem.title}',
          subtitle: 'Plan: ${activePlan.topic}',
        ),
      );
    }

    list.sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  List<_WeekLoad> _buildWeekLoads(DateTime now) {
    final start = _today(now);
    final loads = <_WeekLoad>[];

    for (int i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      final deadlineCount = _deadlinesForDay(day).length;

      int planned = 0;
      for (final plan in widget.plans) {
        planned += plan.items.where((item) => !item.completed).length > 0 ? 1 : 0;
      }

      final score = deadlineCount * 3 + planned;
      loads.add(
        _WeekLoad(
          day: day,
          score: score,
          deadlineCount: deadlineCount,
        ),
      );
    }

    return loads;
  }

  Color _categoryColor(ScheduleCategory category) {
    switch (category) {
      case ScheduleCategory.classSession:
        return const Color(0xFF06B6D4);
      case ScheduleCategory.study:
        return const Color(0xFF8B5CF6);
      case ScheduleCategory.deadline:
        return const Color(0xFFF97316);
      case ScheduleCategory.breakTime:
        return const Color(0xFF10B981);
      case ScheduleCategory.revision:
        return const Color(0xFFEC4899);
      case ScheduleCategory.personal:
        return const Color(0xFF60A5FA);
    }
  }

  String _categoryLabel(ScheduleCategory category) {
    switch (category) {
      case ScheduleCategory.classSession:
        return 'Class';
      case ScheduleCategory.study:
        return 'Study';
      case ScheduleCategory.deadline:
        return 'Deadline';
      case ScheduleCategory.breakTime:
        return 'Break';
      case ScheduleCategory.revision:
        return 'Revision';
      case ScheduleCategory.personal:
        return 'Personal';
    }
  }

  String _formatTime(DateTime date) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(date.hour)}:${two(date.minute)}';
  }

  String _formatDayShort(DateTime date) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[date.weekday - 1];
  }

  String _formatMonthDay(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF0F162A) : Colors.white;
    final surfaceSoft = isDark ? const Color(0xFF161F36) : const Color(0xFFF8FAFC);
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    final now = DateTime.now();
    final weekLoads = _buildWeekLoads(now);
    final timeline = _buildMockAndDerivedTimeline(now);
    final current = _currentEntry(timeline, now);
    final laterToday = _laterTodayEntries(timeline, now);
    final tomorrow = _tomorrowEntries(now);

    final filteredTimeline = _categoryFilter == null
        ? timeline
        : timeline.where((e) => e.category == _categoryFilter).toList();

    final activePlan = _firstActivePlan();
    final nextItem = activePlan?.nextIncomplete;
    final focusSuggestion = nextItem == null
        ? null
        : 'Best focus slot today: 16:00 - 17:00 for ${activePlan.topic}';
    final nextDeadline = _nextUpcomingEvent(now);
    final deadlineLabel = nextDeadline == null
        ? 'No upcoming deadlines'
        : '${nextDeadline.title} • ${_formatMonthDay(nextDeadline.date)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Schedule',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: PremiumBadge(compact: true)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        children: [
          _HeroCard(
            title: 'Today, locked in.',
            subtitle: 'Quick scan your timeline, then focus.',
            chips: [
              _HeroChip(
                icon: Icons.alarm_rounded,
                label: deadlineLabel,
              ),
              if (focusSuggestion != null)
                _HeroChip(
                  icon: Icons.timer_rounded,
                  label: focusSuggestion,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionHeader(
            title: 'Weekly overview',
            subtitle: 'Heavy days pop visually — tap to scan your week',
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 18 : 10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: weekLoads
                  .map(
                    (load) => Expanded(
                      child: _WeekDayPill(
                        label: _formatDayShort(load.day),
                        date: load.day.day,
                        level: load.level,
                        hint: load.deadlineCount > 0
                            ? '${load.deadlineCount} deadline${load.deadlineCount == 1 ? '' : 's'}'
                            : 'No deadlines',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          _SectionHeader(
            title: 'Categories',
            subtitle: 'Filter your day',
            trailing: TextButton(
              onPressed: () => setState(() => _categoryFilter = null),
              child: const Text('Clear'),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ScheduleCategory.values
                .map(
                  (category) => _CategoryChip(
                    label: _categoryLabel(category),
                    color: _categoryColor(category),
                    selected: _categoryFilter == category,
                    onTap: () => setState(() => _categoryFilter = category),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          _SectionHeader(
            title: 'Today timeline',
            subtitle: _formatMonthDay(now),
            trailing: IconButton(
              tooltip: 'Add block (coming soon)',
              onPressed: () => showUpgradeBottomSheet(context),
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
          ),
          const SizedBox(height: 10),
          if (filteredTimeline.isEmpty)
            _EmptyCard(
              surfaceSoft: surfaceSoft,
              title: 'No schedule for today yet',
              subtitle: 'Create focus blocks from your study plans to make your day feel easier.',
              cta: 'Create a plan',
              onTap: () => Navigator.pop(context),
            )
          else
            ...filteredTimeline.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TimelineCard(
                  entry: entry,
                  timeLabel: '${_formatTime(entry.start)} - ${_formatTime(entry.end)}',
                  color: _categoryColor(entry.category),
                ),
              ),
            ),
          const SizedBox(height: 18),
          _SectionHeader(
            title: 'Upcoming',
            subtitle: 'Now • Later Today • Tomorrow',
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
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
              children: [
                _UpcomingRow(
                  label: 'Now',
                  value: current == null
                      ? 'No active block'
                      : '${_formatTime(current.start)} ${current.title}',
                  tagColor: current == null ? null : _categoryColor(current.category),
                ),
                const SizedBox(height: 12),
                _UpcomingRow(
                  label: 'Later today',
                  value: laterToday.isEmpty ? 'Nothing scheduled' : '${laterToday.length} blocks',
                  tagColor: laterToday.isEmpty ? null : const Color(0xFF8B5CF6),
                ),
                const SizedBox(height: 12),
                _UpcomingRow(
                  label: 'Tomorrow',
                  value: tomorrow.isEmpty ? 'Nothing scheduled' : '${tomorrow.length} blocks',
                  tagColor: tomorrow.isEmpty ? null : const Color(0xFF06B6D4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionHeader(
            title: 'Focus block suggestion',
            subtitle: 'Based on your active study plans',
          ),
          const SizedBox(height: 10),
          if (focusSuggestion == null)
            _EmptyCard(
              surfaceSoft: surfaceSoft,
              title: 'No focus suggestion yet',
              subtitle: 'Create a study plan first, then Schedule will suggest focus blocks.',
              cta: 'Create a plan',
              onTap: () => Navigator.pop(context),
            )
          else
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6D28D9), Color(0xFF9333EA), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.timer_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Best focus slot',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          focusSuggestion,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Task: ${nextItem.title}',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),
          _SectionHeader(
            title: 'Premium upgrades',
            subtitle: 'Smarter schedule — zero stress',
          ),
          const SizedBox(height: 10),
          PremiumGate(
            title: 'Auto-generate my daily schedule',
            subtitle: 'Turn deadlines + plans into a realistic day plan with breaks.',
            lockedChild: _PremiumFeatureCard(
              surface: surface,
              title: 'Auto-generated schedule',
              subtitle: 'Locked — tap to upgrade',
              icon: Icons.lock_rounded,
            ),
            child: _PremiumFeatureCard(
              surface: surface,
              title: 'Auto-generated schedule',
              subtitle: 'Build a clean time-blocked day from your plans.',
              icon: Icons.auto_awesome_rounded,
            ),
          ),
          const SizedBox(height: 12),
          PremiumGate(
            title: 'Conflict detection',
            subtitle: 'Spot overlapping blocks and fix them instantly.',
            lockedChild: _PremiumFeatureCard(
              surface: surface,
              title: 'Conflict detection',
              subtitle: 'Locked — tap to upgrade',
              icon: Icons.lock_rounded,
            ),
            child: _PremiumFeatureCard(
              surface: surface,
              title: 'Conflict detection',
              subtitle: 'Detect clashes between class, study, and deadlines.',
              icon: Icons.rule_folder_rounded,
            ),
          ),
          const SizedBox(height: 12),
          PremiumGate(
            title: 'Smart time-blocking',
            subtitle: 'One tap to generate focus blocks around your day.',
            lockedChild: _PremiumFeatureCard(
              surface: surface,
              title: 'Smart time-blocking',
              subtitle: 'Locked — tap to upgrade',
              icon: Icons.lock_rounded,
            ),
            child: _PremiumFeatureCard(
              surface: surface,
              title: 'Smart time-blocking',
              subtitle: 'Schedule focus blocks based on your progress + urgency.',
              icon: Icons.view_timeline_rounded,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            PremiumScope.of(context).isPremium
                ? 'Premium enabled: these features are ready to connect to real scheduling data next.'
                : 'Free users can preview premium schedule features. Tap any locked card to upgrade.',
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
            ],
          ),
        ),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_HeroChip> chips;

  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.chips,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF121A33), Color(0xFF251B45)],
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
            color: const Color(0xFF7C3AED).withAlpha(isDark ? 26 : 16),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withAlpha(20),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.view_timeline_rounded,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                  ],
                ),
              ),
              const PremiumBadge(compact: true),
            ],
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: chips,
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : const Color(0xFF111827)).withAlpha(isDark ? 14 : 8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withAlpha(70),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF8B5CF6)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? color.withAlpha(45) : color.withAlpha(20);
    final border = selected ? color.withAlpha(150) : color.withAlpha(90);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final ScheduleEntry entry;
  final String timeLabel;
  final Color color;

  const _TimelineCard({
    required this.entry,
    required this.timeLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF0F162A) : Colors.white;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: entry.isUrgent ? const Color(0xFFF97316).withAlpha(120) : color.withAlpha(90),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 18 : 10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 56,
            decoration: BoxDecoration(
              color: entry.isUrgent ? const Color(0xFFF97316) : color,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      timeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (entry.isUrgent)
                      _Tag(label: 'URGENT', color: const Color(0xFFF97316))
                    else
                      _Tag(label: 'BLOCK', color: color),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  entry.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.subtitle,
                  style: TextStyle(fontSize: 13, color: textSecondary, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              entry.category == ScheduleCategory.deadline
                  ? Icons.alarm_rounded
                  : entry.category == ScheduleCategory.breakTime
                      ? Icons.coffee_rounded
                      : entry.category == ScheduleCategory.classSession
                          ? Icons.school_rounded
                          : Icons.auto_awesome_rounded,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? tagColor;

  const _UpcomingRow({
    required this.label,
    required this.value,
    required this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w900, color: textPrimary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600),
          ),
        ),
        if (tagColor != null)
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: tagColor, shape: BoxShape.circle),
          ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final Color surfaceSoft;
  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onTap;

  const _EmptyCard({
    required this.surfaceSoft,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceSoft,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF111827),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: Text(cta),
          ),
        ],
      ),
    );
  }
}

class _PremiumFeatureCard extends StatelessWidget {
  final Color surface;
  final String title;
  final String subtitle;
  final IconData icon;

  const _PremiumFeatureCard({
    required this.surface,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 18 : 10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: textSecondary, height: 1.35),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF7C3AED)),
        ],
      ),
    );
  }
}

enum _LoadLevel { light, moderate, heavy }

class _WeekLoad {
  final DateTime day;
  final int score;
  final int deadlineCount;

  const _WeekLoad({
    required this.day,
    required this.score,
    required this.deadlineCount,
  });

  _LoadLevel get level {
    if (score >= 6) return _LoadLevel.heavy;
    if (score >= 3) return _LoadLevel.moderate;
    return _LoadLevel.light;
  }
}

class _WeekDayPill extends StatelessWidget {
  final String label;
  final int date;
  final _LoadLevel level;
  final String hint;

  const _WeekDayPill({
    required this.label,
    required this.date,
    required this.level,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    final base = switch (level) {
      _LoadLevel.light => const Color(0xFF10B981),
      _LoadLevel.moderate => const Color(0xFF8B5CF6),
      _LoadLevel.heavy => const Color(0xFFF97316),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: hint,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: base.withAlpha(isDark ? 26 : 20),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: base.withAlpha(90)),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 18,
                height: 6,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

