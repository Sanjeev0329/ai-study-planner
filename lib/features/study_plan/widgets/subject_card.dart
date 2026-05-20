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
      case 'easy':
        return AppColors.easy;
      case 'hard':
        return AppColors.hard;
      default:
        return AppColors.medium;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _diffColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.difficulty.toUpperCase(),
                    style: TextStyle(fontSize: 10, color: _diffColor, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Text(task.subject, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const Spacer(),
                Text('${task.durationMinutes}m', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),
            Text(task.topic, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.3)),
            if (task.tip.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                task.tip,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.timer_outlined, size: 16),
                    label: const Text('Timer'),
                    onPressed: () => Navigator.pushNamed(context, '/pomodoro'),
                  ),
                ),
                const SizedBox(width: 8),
                if (!task.isCompleted)
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Done'),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.easy),
                      onPressed: () => ref
                          .read(studyPlanProvider.notifier)
                          .markTaskDone(dayIndex, sessionIndex),
                    ),
                  )
                else
                  const Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: AppColors.easy, size: 18),
                        SizedBox(width: 6),
                        Text('Completed', style: TextStyle(color: AppColors.easy, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
