import '../models/study_plan.dart';
import '../widgets/study_plan_card.dart';
import 'plan_detail_page.dart';
import 'package:flutter/material.dart';

class ProgressPage extends StatefulWidget {
  final List<StudyPlan> plans;
  final void Function(String planId)? onDeletePlan;

  const ProgressPage({super.key, required this.plans, this.onDeletePlan});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  Future<void> _openPlan(StudyPlan plan) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanDetailPage(
          plan: plan,
          onDeletePlan: widget.onDeletePlan == null
              ? null
              : () => widget.onDeletePlan!(plan.id),
        ),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final completedPlanList = widget.plans
        .where((plan) => plan.isCompleted)
        .toList();
    final completedPlans = completedPlanList.length;
    final completedDays = completedPlanList.fold<int>(
      0,
      (sum, plan) => sum + plan.completedCount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Progress',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
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
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your progress',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$completedPlans completed plan${completedPlans == 1 ? '' : 's'} • $completedDays days done',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This page only shows study plans you finished (100%).',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (completedPlanList.isEmpty)
            Text(
              'No completed plans yet. Finish a plan to see it here.',
              style: TextStyle(fontSize: 15, color: textSecondary),
            )
          else
            ...completedPlanList.map(
              (plan) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StudyPlanCard(
                  plan: plan,
                  onTap: () => _openPlan(plan),
                  onDelete: widget.onDeletePlan == null
                      ? null
                      : () => widget.onDeletePlan!(plan.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
