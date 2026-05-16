import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/study_plan.dart';
import '../providers/favourites_provider.dart';
import '../providers/study_flow_controller.dart';
import '../widgets/study_plan_card.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studyFlow = context.watch<StudyFlowController>();
    final favourites = context.watch<FavouritesProvider>();
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    final validIds = studyFlow.plans.map((p) => p.id).toSet();
    final hasStaleFavourite = favourites.ids.any((id) => !validIds.contains(id));
    if (hasStaleFavourite) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) return;
        await context.read<FavouritesProvider>().pruneMissingPlans(validIds);
      });
    }

    final favouritePlans = <StudyPlan>[];
    for (final id in favourites.ids) {
      final plan = studyFlow.planById(id);
      if (plan != null) favouritePlans.add(plan);
    }
    favouritePlans.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Favourites',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            'Star plans from the dashboard, planner, or plan detail screen. '
            'Favourites are saved on this device.',
            style: TextStyle(fontSize: 14, height: 1.45, color: textSecondary),
          ),
          const SizedBox(height: 18),
          if (favouritePlans.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF161F36)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No favourites yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Open Study Planner or your dashboard and tap the star on a plan you want quick access to.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.push('/planner'),
                    icon: const Icon(Icons.auto_awesome_motion_rounded),
                    label: const Text('Go to Study Planner'),
                  ),
                ],
              ),
            )
          else
            ...favouritePlans.map(
              (plan) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StudyPlanCard(
                  plan: plan,
                  isFavorite: true,
                  onToggleFavorite: () => favourites.remove(plan.id),
                  onTap: () async {
                    await context.push('/plan/${plan.id}', extra: plan);
                    if (context.mounted) {
                      studyFlow.notifyPlansUpdated();
                    }
                  },
                  onDelete: () {
                    studyFlow.deletePlanById(plan.id);
                    favourites.remove(plan.id);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
