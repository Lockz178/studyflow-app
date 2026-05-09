import '../models/study_plan.dart';
import 'package:flutter/material.dart';

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
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
