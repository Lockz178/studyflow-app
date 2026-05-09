import 'package:flutter/material.dart';

class CreatePlanCard extends StatelessWidget {
  final TextEditingController topicController;
  final String selectedSubject;
  final List<String> subjects;
  final ValueChanged<String?> onSubjectChanged;
  final double selectedDays;
  final ValueChanged<double> onDaysChanged;
  final VoidCallback onCreatePlan;

  const CreatePlanCard({
    super.key,
    required this.topicController,
    required this.selectedSubject,
    required this.subjects,
    required this.onSubjectChanged,
    required this.selectedDays,
    required this.onDaysChanged,
    required this.onCreatePlan,
  });

  InputDecoration _inputDecoration(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark ? const Color(0xFF171F33) : const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF27304B) : const Color(0xFFE5E7EB),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF27304B) : const Color(0xFFE5E7EB),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF0F162A) : Colors.white;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
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
          Text(
            'Create a Study Plan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can create as many plans as you want. Each plan gets its own daily checklist and progress bar.',
            style: TextStyle(fontSize: 14, height: 1.45, color: textSecondary),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: topicController,
            decoration: _inputDecoration(context, 'Topic or assignment name'),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: selectedSubject,
            decoration: _inputDecoration(context, 'Choose a subject'),
            items: subjects
                .map(
                  (subject) =>
                      DropdownMenuItem(value: subject, child: Text(subject)),
                )
                .toList(),
            onChanged: onSubjectChanged,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Days to finish',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              Text(
                '${selectedDays.round()} days',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
          Slider(
            value: selectedDays,
            min: 3,
            max: 14,
            divisions: 11,
            activeColor: const Color(0xFF7C3AED),
            onChanged: onDaysChanged,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCreatePlan,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF111827),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.add_task_rounded),
              label: const Text('Create Study Plan'),
            ),
          ),
        ],
      ),
    );
  }
}
