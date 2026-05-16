import 'package:flutter/material.dart';

/// List tile for the tips feed: text plus a network image (or icon fallback).
class StudyTipListTile extends StatelessWidget {
  final String tipText;
  final int imageSeedIndex;

  const StudyTipListTile({
    super.key,
    required this.tipText,
    required this.imageSeedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final imageUrl =
        'https://picsum.photos/seed/studyflow_tip_$imageSeedIndex/128/128';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isDark ? const Color(0xFF0F162A) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 64,
                    height: 64,
                    color: const Color(0xFF7C3AED).withAlpha(36),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 32,
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: 64,
                      height: 64,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Study tip',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: textSecondary,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tipText,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
