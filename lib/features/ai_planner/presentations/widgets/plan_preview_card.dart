import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/study_plan.dart';

class PlanPreviewCard extends StatelessWidget {
  final StudyPlanModel plan;
  const PlanPreviewCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.auto_awesome, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Plan Generated!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          _row('Total days', '\${plan.totalDays} days'),
          _row('Daily hours', '\${plan.dailyHours}h/day'),
          _row('Subjects', plan.subjects.join(', ')),
          _row('Exam date', plan.examDate),
        ]),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: const TextStyle(color: AppColors.textGrey)),
      Text(v, style: const TextStyle(fontWeight: FontWeight.w500)),
    ]),
  );
}
