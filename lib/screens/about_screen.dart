import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_contact.dart';

/// Course presentation: author and repository contact details.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final cardColor = isDark ? const Color(0xFF0F162A) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'About',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.school_rounded, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                Text(
                  'StudyFlow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mobile study planner for courses, deadlines, and daily progress.',
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'App preview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              'assets/screenshots/dashboard_dark.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Author',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phan Ngoc Phuoc Loc',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mobile Applications coursework — StudyFlow project.',
                  style: TextStyle(color: textSecondary, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Contact',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LinkRow(
                  icon: Icons.email_outlined,
                  label: kSupportEmail,
                ),
                const SizedBox(height: 14),
                _LinkRow(
                  icon: Icons.code_rounded,
                  label: kRepoWebUrl,
                  subtitle: 'Source repository',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;

  const _LinkRow({
    required this.icon,
    required this.label,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 22, color: const Color(0xFF8B5CF6)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null) ...[
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              SelectableText(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
