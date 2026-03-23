import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/study_task_model.dart';
import '../study_plan_provider.dart';

class TaskTile extends ConsumerWidget {
  final StudyTaskModel task;
  final int dayIndex, sessionIndex;
  const TaskTile({super.key, required this.task, required this.dayIndex, required this.sessionIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        activeColor: AppColors.primary,
        onChanged: task.isCompleted ? null : (_) =>
            ref.read(studyPlanProvider.notifier).markTaskDone(dayIndex, sessionIndex),
      ),
      title: Text(task.topic,
          style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
      subtitle: Text('\${task.subject} · \${task.durationMinutes}min · \${task.difficulty}'),
    );
  }
}
