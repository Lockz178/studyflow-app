import '../models/study_plan.dart';
import '../widgets/study_plan_card.dart';
import 'plan_detail_page.dart';
import 'package:flutter/material.dart';

class PlansPage extends StatefulWidget {
  final List<StudyPlan> plans;
  final void Function(String planId)? onDeletePlan;

  const PlansPage({super.key, required this.plans, this.onDeletePlan});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Study Planner',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: widget.plans.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No plans yet. Create one from the dashboard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: textSecondary),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              itemCount: widget.plans.length,
              itemBuilder: (context, index) {
                final plan = widget.plans[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: StudyPlanCard(
                    plan: plan,
                    onTap: () => _openPlan(plan),
                    onDelete: widget.onDeletePlan == null
                        ? null
                        : () => widget.onDeletePlan!(plan.id),
                  ),
                );
              },
            ),
    );
  }
}
