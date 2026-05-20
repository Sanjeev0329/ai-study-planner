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
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: plan.schedule.length,
        itemBuilder: (_, i) {
          final day = plan.schedule[i];
          final isSelected = i == selected;
          final allDone =
              day.sessions.isNotEmpty && day.sessions.every((s) => s.isCompleted);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => ref.read(selectedDayProvider.notifier).state = i,
                borderRadius: BorderRadius.circular(22),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : allDone
                            ? AppColors.easy.withValues(alpha: 0.12)
                            : AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : allDone
                              ? AppColors.easy.withValues(alpha: 0.4)
                              : AppColors.glassBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Day ${day.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textWhite,
                        ),
                      ),
                      if (allDone) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: isSelected ? Colors.white : AppColors.easy,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
