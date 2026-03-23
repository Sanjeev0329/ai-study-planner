import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../study_plan_provider.dart';

class DaySelector extends ConsumerWidget {
  const DaySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(studyPlanProvider);
    final selected = ref.watch(selectedDayProvider);
    if (plan == null) return const SizedBox();

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: plan.schedule.length,
        itemBuilder: (_, i) {
          final day = plan.schedule[i];
          final isSelected = i == selected;
          final allDone = day.sessions.isNotEmpty && day.sessions.every((s) => s.isCompleted);
          return GestureDetector(
            onTap: () => ref.read(selectedDayProvider.notifier).state = i,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : (allDone ? AppColors.easy.withOpacity(0.1) : Colors.transparent),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Day \${day.day}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textDark)),
                if (allDone) Icon(Icons.check_circle, size: 12, color: isSelected ? Colors.white : AppColors.easy),
              ]),
            ),
          );
        },
      ),
    );
  }
}
