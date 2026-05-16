import '../models/study_plan.dart';
import '../models/plan_item.dart';
import '../widgets/plan_day_tile.dart';
import 'package:flutter/material.dart';

class PlanDetailPage extends StatefulWidget {
  final StudyPlan plan;
  final VoidCallback? onDeletePlan;
  final VoidCallback? onPlanChanged;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  const PlanDetailPage({
    super.key,
    required this.plan,
    this.onDeletePlan,
    this.onPlanChanged,
    this.isFavorite = false,
    this.onToggleFavorite,
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
    widget.onPlanChanged?.call();

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
          if (widget.onToggleFavorite != null)
            IconButton(
              tooltip: widget.isFavorite
                  ? 'Remove from favourites'
                  : 'Add to favourites',
              onPressed: widget.onToggleFavorite,
              icon: Icon(
                widget.isFavorite
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: widget.isFavorite
                    ? const Color(0xFFFBBF24)
                    : null,
              ),
            ),
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
                  style: const TextStyle(color: Colors.white, fontSize: 14),
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
              child: PlanDayTile(item: item, onToggle: () => _toggleItem(item)),
            ),
          ),
          if (widget.plan.isCompleted)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF171F33)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                'You completed this plan. You can still uncheck any day if you want to update it.',
                style: TextStyle(color: textSecondary, height: 1.45),
              ),
            ),
        ],
      ),
    );
  }
}
