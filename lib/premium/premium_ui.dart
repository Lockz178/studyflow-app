import 'package:flutter/material.dart';

import 'premium_scope.dart';

class PremiumBadge extends StatelessWidget {
  final bool compact;
  final EdgeInsets padding;

  const PremiumBadge({
    super.key,
    this.compact = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final isPremium = PremiumScope.of(context).isPremium;
    final label = isPremium ? 'PREMIUM' : 'FREE';
    final background = isPremium
        ? const Color(0xFF10B981)
        : const Color(0xFF7C3AED);

    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 5)
          : padding,
      decoration: BoxDecoration(
        color: background.withAlpha(40),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: background.withAlpha(120)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPremium
                ? Icons.workspace_premium_rounded
                : Icons.lock_open_rounded,
            size: compact ? 14 : 16,
            color: background,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: background,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              fontSize: compact ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showUpgradeBottomSheet(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF10172A)
        : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => const _UpgradeSheet(),
  );
}

class PremiumGate extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? lockedChild;
  final bool enabled;
  final double lockedMinHeight;

  const PremiumGate({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.lockedChild,
    this.enabled = true,
    this.lockedMinHeight = 220,
  });

  @override
  Widget build(BuildContext context) {
    final controller = PremiumScope.of(context);
    final isLocked = enabled && !controller.isPremium;

    if (!isLocked) return child;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: lockedMinHeight),
      child: Stack(
        children: [
          lockedChild ?? child,
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Material(
                color: Colors.black.withAlpha(35),
                child: InkWell(
                  onTap: () => showUpgradeBottomSheet(context),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF0F162A).withAlpha(220)
                            : Colors.white.withAlpha(240),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFF8B5CF6).withAlpha(120),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withAlpha(25),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.lock_rounded,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    height: 1.35,
                                    fontSize: 13,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    FilledButton.icon(
                                      onPressed: () =>
                                          showUpgradeBottomSheet(context),
                                      icon: const Icon(
                                        Icons.workspace_premium_rounded,
                                      ),
                                      label: const Text('Upgrade'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF7C3AED,
                                        ),
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text('Not now'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpgradeSheet extends StatelessWidget {
  const _UpgradeSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final controller = PremiumScope.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.82,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'StudyFlow Premium',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        'Smarter planning, better recommendations, deeper insights.',
                        style: TextStyle(fontSize: 13, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                const PremiumBadge(compact: true),
              ],
            ),
            const SizedBox(height: 14),
            _FeatureRow(
              icon: Icons.auto_awesome_rounded,
              title: 'Adaptive planner',
              subtitle: 'Catch up automatically if you miss days.',
            ),
            _FeatureRow(
              icon: Icons.psychology_alt_rounded,
              title: 'Better recommendations',
              subtitle: 'Based on urgency + incomplete progress.',
            ),
            _FeatureRow(
              icon: Icons.insights_rounded,
              title: 'Premium analytics',
              subtitle: 'Stronger/weakest subjects and completion insights.',
            ),
            _FeatureRow(
              icon: Icons.cloud_sync_rounded,
              title: 'Cloud backup (placeholder)',
              subtitle: 'UI only for now - no backend yet.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final messenger = ScaffoldMessenger.of(context);
                  controller.setPremium(true);
                  Navigator.pop(context);
                  messenger.showSnackBar(
                    SnackBar(
                      content: const Text('Premium enabled (test mode)'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: isDark ? const Color(0xFF111827) : null,
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Enable Premium (test)',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  final messenger = ScaffoldMessenger.of(context);
                  controller.setPremium(false);
                  Navigator.pop(context);
                  messenger.showSnackBar(
                    SnackBar(
                      content: const Text('Premium disabled (test mode)'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: isDark ? const Color(0xFF111827) : null,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: const Color(0xFF7C3AED).withAlpha(140),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text('Stay Free'),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No real billing yet. This is a local test toggle.',
              style: TextStyle(fontSize: 12, color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withAlpha(18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF8B5CF6)),
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
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
