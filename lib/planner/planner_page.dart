import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../premium/premium_scope.dart';
import '../premium/premium_ui.dart';
import '../providers/favourites_provider.dart';
import '../validators/study_plan_validator.dart';

enum PlannerFilter { all, active, completed, highPriority }

class PlannerTemplate {
  final String title;
  final String subtitle;
  final String subject;
  final int days;

  const PlannerTemplate({
    required this.title,
    required this.subtitle,
    required this.subject,
    required this.days,
  });
}

class PlannerPage extends StatefulWidget {
  final List<dynamic> plans; // expects List<StudyPlan>
  final List<String> subjects;

  final void Function({
    required String topic,
    required String subject,
    required int totalDays,
  })
  onCreatePlan;

  final Future<void> Function(dynamic plan) onOpenPlan; // StudyPlan
  final void Function(String planId) onDeletePlan;

  const PlannerPage({
    super.key,
    required this.plans,
    required this.subjects,
    required this.onCreatePlan,
    required this.onOpenPlan,
    required this.onDeletePlan,
  });

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage>
    with SingleTickerProviderStateMixin {
  PlannerFilter _filter = PlannerFilter.all;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      setState(() {
        _filter = PlannerFilter.values[_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<dynamic> _filteredPlans() {
    final plans = widget.plans;
    switch (_filter) {
      case PlannerFilter.all:
        return plans;
      case PlannerFilter.active:
        return plans.where((p) => !p.isCompleted).toList();
      case PlannerFilter.completed:
        return plans.where((p) => p.isCompleted).toList();
      case PlannerFilter.highPriority:
        return plans.where((p) => _isHighPriority(p)).toList();
    }
  }

  bool _isHighPriority(dynamic plan) {
    // Heuristic: active + low progress.
    if (plan.isCompleted) return false;
    final progress = plan.progressValue as double? ?? 0;
    return progress < 0.35;
  }

  dynamic _suggestedPlan() {
    // Suggested: first active plan; fallback to newest plan.
    for (final p in widget.plans) {
      if (!p.isCompleted) return p;
    }
    return widget.plans.isNotEmpty ? widget.plans.first : null;
  }

  dynamic _mostUrgentPlan() {
    // Urgent: active plan with lowest progress.
    final active = widget.plans.where((p) => !p.isCompleted).toList();
    if (active.isEmpty) return null;
    active.sort(
      (a, b) =>
          (a.progressValue as double).compareTo(b.progressValue as double),
    );
    return active.first;
  }

  dynamic _fallingBehindPlan() {
    // Falling behind: high priority plan if any.
    final hp = widget.plans.where((p) => _isHighPriority(p)).toList();
    if (hp.isEmpty) return null;
    hp.sort(
      (a, b) =>
          (a.progressValue as double).compareTo(b.progressValue as double),
    );
    return hp.first;
  }

  int _activePlansCount() => widget.plans.where((p) => !p.isCompleted).length;

  int _completedPlansCount() => widget.plans.where((p) => p.isCompleted).length;

  int _completedDaysCount() =>
      widget.plans.fold<int>(0, (sum, p) => sum + (p.completedCount as int));

  int _totalDaysCount() =>
      widget.plans.fold<int>(0, (sum, p) => sum + (p.items.length as int));

  String _todayTargetText() {
    final suggested = _suggestedPlan();
    final next = suggested?.nextIncomplete;
    if (next == null) return 'Create a plan to get a target';
    return 'Day ${next.day}: ${next.title}';
  }

  List<PlannerTemplate> _templates() {
    return const [
      PlannerTemplate(
        title: 'Exam Prep',
        subtitle: 'Balanced revision + practice + recap',
        subject: 'Math',
        days: 7,
      ),
      PlannerTemplate(
        title: 'Assignment Rush',
        subtitle: 'Fast breakdown to ship a clean draft',
        subject: 'UI Design',
        days: 5,
      ),
      PlannerTemplate(
        title: 'Weekly Revision',
        subtitle: 'Small daily blocks to stay consistent',
        subject: 'SQL',
        days: 7,
      ),
      PlannerTemplate(
        title: 'Language Learning',
        subtitle: 'Vocabulary + listening + writing rotation',
        subject: 'English',
        days: 10,
      ),
    ];
  }

  Future<void> _openCreatePlanSheet({PlannerTemplate? template}) async {
    final result = await Navigator.of(context).push<Map<String, Object>>(
      MaterialPageRoute(
        builder: (_) =>
            _CreateStudyPlanPage(subjects: widget.subjects, template: template),
      ),
    );

    if (result == null || !mounted) return;

    final topic = result['topic'] as String;
    final subject = result['subject'] as String;
    final totalDays = result['totalDays'] as int;

    widget.onCreatePlan(topic: topic, subject: subject, totalDays: totalDays);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Created study plan for $topic'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF0F162A) : Colors.white;
    final surfaceSoft = isDark
        ? const Color(0xFF161F36)
        : const Color(0xFFF8FAFC);
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    final fav = context.watch<FavouritesProvider>();

    final activePlans = _activePlansCount();
    final completedPlans = _completedPlansCount();
    final completedDays = _completedDaysCount();
    final totalDays = _totalDaysCount();
    final overallPercent = totalDays == 0
        ? 0
        : ((completedDays / totalDays) * 100).round();

    final filtered = _filteredPlans();
    final suggested = _suggestedPlan();
    final urgent = _mostUrgentPlan();
    final behind = _fallingBehindPlan();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Study Planner',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: PremiumBadge(compact: true)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreatePlanSheet(),
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New plan'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        children: [
          _HeroStats(
            isDark: isDark,
            activePlans: activePlans,
            completedPlans: completedPlans,
            completedDays: completedDays,
            overallPercent: overallPercent,
            todayTarget: _todayTargetText(),
          ),
          const SizedBox(height: 16),
          _SectionHeader(
            title: 'Smart planner',
            subtitle: 'What to focus on right now',
          ),
          const SizedBox(height: 10),
          if (widget.plans.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
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
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use the purple + New plan button to create your first study plan.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                if (suggested != null)
                  _SmartPlanCard(
                    surface: surface,
                    label: 'Suggested focus',
                    insight:
                        'Your first active plan — a simple “what should I open next?” suggestion.',
                    plan: suggested,
                    accent: const Color(0xFF8B5CF6),
                    onTap: () => widget.onOpenPlan(suggested),
                  ),
                if (urgent != null) ...[
                  const SizedBox(height: 12),
                  _SmartPlanCard(
                    surface: surface,
                    label: 'Most urgent',
                    insight:
                        'Among active plans, the one with the lowest overall progress — worth tackling soon.',
                    plan: urgent,
                    accent: const Color(0xFFF97316),
                    onTap: () => widget.onOpenPlan(urgent),
                  ),
                ],
                if (behind != null) ...[
                  const SizedBox(height: 12),
                  PremiumGate(
                    title: 'Adaptive catch-up plan',
                    subtitle:
                        'Premium: rebuild remaining days if you miss sessions.',
                    lockedChild: _PremiumFeatureCard(
                      surface: surface,
                      title: 'Catch-up planner',
                      subtitle: 'Locked — tap to upgrade',
                      icon: Icons.lock_rounded,
                    ),
                    child: _PremiumFeatureCard(
                      surface: surface,
                      title: 'Catch-up planner',
                      subtitle:
                          'Rebuild the remaining plan days realistically.',
                      icon: Icons.auto_awesome_rounded,
                    ),
                  ),
                ],
              ],
            ),
          const SizedBox(height: 18),
          _SectionHeader(
            title: 'Your plans',
            subtitle: 'Everything in one place',
          ),
          const SizedBox(height: 10),
          Container(
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
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF7C3AED),
              unselectedLabelColor: textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900),
              indicatorColor: const Color(0xFF7C3AED),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Active'),
                Tab(text: 'Completed'),
                Tab(text: 'High Priority'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: surfaceSoft,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nothing here yet',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use the purple + New plan button to create a study plan.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            ...filtered.map(
              (plan) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PlanOverviewCard(
                  surface: surface,
                  plan: plan,
                  onOpen: () => widget.onOpenPlan(plan),
                  onDelete: () => widget.onDeletePlan(plan.id),
                  isFavorite: fav.isFavorite(plan.id),
                  onToggleFavorite: () => fav.toggle(plan.id),
                ),
              ),
            ),
          const SizedBox(height: 18),
          _SectionHeader(
            title: 'Templates',
            subtitle: 'Premium planners that feel smarter',
            trailing: TextButton(
              onPressed: () => showUpgradeBottomSheet(context),
              child: const Text('Upgrade'),
            ),
          ),
          const SizedBox(height: 10),
          ..._templates().map(
            (template) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PremiumGate(
                title: 'Use "${template.title}" template',
                subtitle: 'Premium: create smarter plans from templates.',
                lockedChild: _TemplateCard(
                  surface: surface,
                  template: template,
                  locked: true,
                  onTap: () => showUpgradeBottomSheet(context),
                ),
                child: _TemplateCard(
                  surface: surface,
                  template: template,
                  locked: false,
                  onTap: () => showUpgradeBottomSheet(context),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            PremiumScope.of(context).isPremium
                ? 'Premium enabled: templates can be expanded into smarter breakdowns next.'
                : 'Free users can preview templates. Tap to upgrade to use them.',
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _HeroStats extends StatelessWidget {
  final bool isDark;
  final int activePlans;
  final int completedPlans;
  final int completedDays;
  final int overallPercent;
  final String todayTarget;

  const _HeroStats({
    required this.isDark,
    required this.activePlans,
    required this.completedPlans,
    required this.completedDays,
    required this.overallPercent,
    required this.todayTarget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
            'Planner stats',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Stat(label: 'Active', value: '$activePlans'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Stat(label: 'Completed', value: '$completedPlans'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Stat(label: 'Days done', value: '$completedDays'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '$overallPercent% overall progress',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(18),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today’s target',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        todayTarget,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              blurRadius: 12,
                              color: Colors.black.withAlpha(30),
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tip: finish your target first, then do deadlines.',
            style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(220)),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
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

class _PlanOverviewCard extends StatelessWidget {
  final Color surface;
  final dynamic plan;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const _PlanOverviewCard({
    required this.surface,
    required this.plan,
    required this.onOpen,
    required this.onDelete,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    final next = plan.nextIncomplete;
    final nextText = next == null
        ? 'No next task'
        : 'Next: Day ${next.day} — ${next.title}';

    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(26),
      child: Container(
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
          border: Border.all(
            color: isDark ? const Color(0xFF25304B) : const Color(0xFFE5E7EB),
          ),
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
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: isFavorite
                      ? 'Remove from favourites'
                      : 'Add to favourites',
                  onPressed: onToggleFavorite,
                  icon: Icon(
                    isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: isFavorite
                        ? const Color(0xFFFBBF24)
                        : textSecondary,
                  ),
                ),
                IconButton(
                  tooltip: 'Delete plan',
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${plan.subject} • ${plan.totalDays} days',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 12),
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
            Row(
              children: [
                Text(
                  '${plan.completedCount} / ${plan.items.length} done',
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (plan.isCompleted
                                ? const Color(0xFF10B981)
                                : const Color(0xFF8B5CF6))
                            .withAlpha(18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color:
                          (plan.isCompleted
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF8B5CF6))
                              .withAlpha(90),
                    ),
                  ),
                  child: Text(
                    plan.isCompleted ? 'COMPLETED' : 'ACTIVE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: plan.isCompleted
                          ? const Color(0xFF10B981)
                          : const Color(0xFF8B5CF6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              nextText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmartPlanCard extends StatelessWidget {
  final Color surface;
  final String label;
  final String? insight;
  final dynamic plan;
  final Color accent;
  final VoidCallback onTap;

  const _SmartPlanCard({
    required this.surface,
    required this.label,
    this.insight,
    required this.plan,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    final next = plan.nextIncomplete;
    final nextLine = next == null
        ? 'No next task'
        : 'Next: Day ${next.day} — ${next.title}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: accent.withAlpha(110)),
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
                color: accent.withAlpha(18),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(Icons.auto_awesome_rounded, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withAlpha(18),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: accent.withAlpha(90)),
                        ),
                        child: Text(
                          label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 0.4,
                            fontWeight: FontWeight.w900,
                            color: accent,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${((plan.progressValue as double) * 100).round()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (insight != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      insight!,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.3,
                        color: textSecondary.withAlpha(200),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    plan.topic,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF7C3AED)),
          ],
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final Color surface;
  final PlannerTemplate template;
  final bool locked;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.surface,
    required this.template,
    required this.locked,
    required this.onTap,
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
              child: Icon(
                locked ? Icons.lock_rounded : Icons.auto_awesome_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MiniTag(
                        label: template.subject,
                        color: const Color(0xFF8B5CF6),
                      ),
                      _MiniTag(
                        label: '${template.days} days',
                        color: const Color(0xFF06B6D4),
                      ),
                      if (locked)
                        _MiniTag(
                          label: 'Premium',
                          color: const Color(0xFFF97316),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF7C3AED)),
          ],
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniTag({required this.label, required this.color});

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
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
          color: color,
        ),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                    height: 1.35,
                  ),
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

class _CreateStudyPlanPage extends StatefulWidget {
  final List<String> subjects;
  final PlannerTemplate? template;

  const _CreateStudyPlanPage({required this.subjects, this.template});

  @override
  State<_CreateStudyPlanPage> createState() => _CreateStudyPlanPageState();
}

class _CreateStudyPlanPageState extends State<_CreateStudyPlanPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _topicController;
  late String _subject;
  late double _days;

  @override
  void initState() {
    super.initState();

    _topicController = TextEditingController(
      text: widget.template?.title ?? '',
    );

    _subject =
        widget.template?.subject ??
        (widget.subjects.isNotEmpty ? widget.subjects.first : 'Math');

    _days = (widget.template?.days ?? 7).toDouble();
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop({
      'topic': _topicController.text.trim(),
      'subject': _subject,
      'totalDays': _days.round(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Study Plan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Plan your study work',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose what you want to study and how many days StudyFlow should divide it into.',
              style: TextStyle(color: textSecondary),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _topicController,
              decoration: _decoration('Topic or assignment name'),
              validator: (value) => validateStudyPlanTopic(value ?? ''),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _subject,
              decoration: _decoration('Subject'),
              items: widget.subjects
                  .map(
                    (subject) =>
                        DropdownMenuItem(value: subject, child: Text(subject)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _subject = value;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Days to finish',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${_days.round()} days',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),
            Slider(
              value: _days,
              min: 3,
              max: 14,
              divisions: 11,
              activeColor: const Color(0xFF7C3AED),
              onChanged: (value) {
                setState(() {
                  _days = value;
                });
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.add_task_rounded),
              label: const Text('Create study plan'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
