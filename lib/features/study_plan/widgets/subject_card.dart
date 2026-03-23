import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/study_task_model.dart';
import '../study_plan_provider.dart';

class SubjectCard extends ConsumerWidget {
  final StudyTaskModel task;
  final int dayIndex, sessionIndex;
  const SubjectCard({super.key, required this.task, required this.dayIndex, required this.sessionIndex});

  Color get _diffColor {
    switch (task.difficulty) {
      case 'easy': return AppColors.easy;
      case 'hard': return AppColors.hard;
      default:     return AppColors.medium;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _diffColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(task.difficulty.toUpperCase(),
                  style: TextStyle(fontSize: 11, color: _diffColor, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            Text(task.subject, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
            const Spacer(),
            Text('\${task.durationMinutes}m', style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 8),
          Text(task.topic, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.lightbulb_outline, size: 14, color: AppColors.medium),
            const SizedBox(width: 4),
            Expanded(child: Text(task.tip, style: const TextStyle(fontSize: 13, color: AppColors.textGrey))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              icon: const Icon(Icons.timer_outlined, size: 16),
              label: const Text('Timer'),
              onPressed: () => Navigator.pushNamed(context, '/pomodoro'),
            )),
            const SizedBox(width: 8),
            if (!task.isCompleted)
              Expanded(child: ElevatedButton.icon(
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Done'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.easy),
                onPressed: () => ref.read(studyPlanProvider.notifier).markTaskDone(dayIndex, sessionIndex),
              ))
            else
              const Expanded(child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.check_circle, color: AppColors.easy, size: 18),
                SizedBox(width: 6),
                Text('Completed', style: TextStyle(color: AppColors.easy, fontWeight: FontWeight.w500)),
              ]))),
          ]),
        ]),
      ),
    );
  }
}
