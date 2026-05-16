import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onOpenDashboard;
  final VoidCallback onOpenSchedule;
  final VoidCallback onOpenPlanner;
  final VoidCallback onOpenTips;
  final VoidCallback onOpenFavourites;
  final VoidCallback onOpenProgress;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenAbout;
  final VoidCallback onOpenHelp;

  const AppDrawer({
    super.key,
    required this.onOpenDashboard,
    required this.onOpenSchedule,
    required this.onOpenPlanner,
    required this.onOpenTips,
    required this.onOpenFavourites,
    required this.onOpenProgress,
    required this.onOpenSettings,
    required this.onOpenAbout,
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'StudyFlow',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Focus smarter. Stress less.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
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
                    icon: Icons.library_books_rounded,
                    title: 'Tips library',
                    onTap: onOpenTips,
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
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    onTap: onOpenAbout,
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
                  color: isDark
                      ? const Color(0xFF171F33)
                      : const Color(0xFFF8FAFC),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
        style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary),
      ),
      onTap: onTap,
    );
  }
}
