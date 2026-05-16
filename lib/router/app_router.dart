import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/study_plan.dart';
import '../providers/favourites_provider.dart';
import '../providers/study_flow_controller.dart';
import '../schedule/schedule_page.dart';
import '../planner/planner_page.dart';
import '../screens/favourites_screen.dart';
import '../screens/help_feedback_screen.dart';
import '../screens/about_screen.dart';
import '../screens/home_screen.dart';
import '../screens/plan_detail_page.dart';
import '../screens/progress_page.dart';
import '../screens/settings_screen.dart';
import '../screens/tips_library_screen.dart';
import '../services/mock_data_service.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/tips',
        builder: (context, state) => const TipsLibraryScreen(),
      ),
      GoRoute(
        path: '/progress',
        builder: (context, state) {
          final c = context.watch<StudyFlowController>();
          return ProgressPage(plans: c.plans, onDeletePlan: c.deletePlanById);
        },
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) {
          final c = context.watch<StudyFlowController>();
          return SchedulePage(plans: c.plans, events: c.allEvents);
        },
      ),
      GoRoute(
        path: '/planner',
        builder: (context, state) {
          final c = context.watch<StudyFlowController>();
          return PlannerPage(
            plans: c.plans,
            subjects: MockDataService.subjects,
            onCreatePlan: c.createPlanFromValues,
            onOpenPlan: (plan) async {
              final p = plan as StudyPlan;
              await context.push('/plan/${p.id}', extra: p);
              if (context.mounted) {
                c.notifyPlansUpdated();
              }
            },
            onDeletePlan: c.deletePlanById,
          );
        },
      ),
      GoRoute(
        path: '/favourites',
        builder: (context, state) => const FavouritesScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpFeedbackScreen(),
      ),
      GoRoute(
        path: '/plan/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra;
          final controller = context.read<StudyFlowController>();
          final favourites = context.watch<FavouritesProvider>();
          final plan = extra is StudyPlan ? extra : controller.planById(id);
          if (plan == null) {
            return const _UnknownPlanScreen();
          }
          return PlanDetailPage(
            plan: plan,
            isFavorite: favourites.isFavorite(plan.id),
            onToggleFavorite: () => favourites.toggle(plan.id),
            onDeletePlan: () {
              controller.deletePlanById(plan.id);
              favourites.remove(plan.id);
            },
            onPlanChanged: controller.notifyPlansUpdated,
          );
        },
      ),
    ],
  );
}

class _UnknownPlanScreen extends StatelessWidget {
  const _UnknownPlanScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study plan')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 48),
              const SizedBox(height: 16),
              const Text(
                'This study plan could not be found.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Back to dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
