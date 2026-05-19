import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/user_provider.dart';
import '../../study_plan_provider.dart';
import '../../widgets/day_selector.dart';
import '../../widgets/subject_card.dart';

class PlanDetailScreen extends ConsumerWidget {
  const PlanDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(studyPlanProvider);
    final user = ref.watch(userProvider);

    if (plan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study Plan')),
        body: const Center(child: Text('No plan selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.displayTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed('/plan');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'AI Study Assistant',
            onPressed: () => Navigator.pushNamed(context, '/chat'),
          ),
          IconButton(
            icon: const Icon(Icons.trending_up),
            tooltip: 'Progress',
            onPressed: () => Navigator.pushNamed(context, '/progress'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user?.name.split(' ').first ?? 'Student'}!',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Exam: ${plan.examDate} · ${plan.totalDays} days · '
                  '${(plan.completionRate * 100).toStringAsFixed(0)}% complete',
                  style: const TextStyle(color: AppColors.textGrey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: plan.completionRate,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Material(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.pushNamed(context, '/chat'),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                              SizedBox(width: 6),
                              Text(
                                'Ask AI',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const DaySelector(),
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final dayIndex = ref.watch(selectedDayProvider);
                if (dayIndex >= plan.schedule.length) return const SizedBox();
                final day = plan.schedule[dayIndex];
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    ...day.sessions.asMap().entries.map(
                          (e) => SubjectCard(
                            task: e.value,
                            dayIndex: dayIndex,
                            sessionIndex: e.key,
                          ),
                        ),
                    const SizedBox(height: 80),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) {
            Navigator.popUntil(context, ModalRoute.withName('/plan'));
          } else if (i == 1) {
            Navigator.pushNamed(context, '/progress');
          } else if (i == 2) {
            Navigator.pushNamed(context, '/pomodoro');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Pomodoro'),
        ],
      ),
    );
  }
}
