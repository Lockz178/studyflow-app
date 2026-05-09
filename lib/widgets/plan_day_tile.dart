import '../models/plan_item.dart';
import 'package:flutter/material.dart';

class PlanDayTile extends StatelessWidget {
  final PlanItem item;
  final VoidCallback onToggle;

  const PlanDayTile({super.key, required this.item, required this.onToggle});

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
                      : (isDark
                            ? const Color(0xFF171F33)
                            : const Color(0xFFF3F4F6)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.completed ? Icons.check_rounded : Icons.circle_outlined,
                  size: 18,
                  color: item.completed
                      ? Colors.white
                      : const Color(0xFF9CA3AF),
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
                      decoration: item.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
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
