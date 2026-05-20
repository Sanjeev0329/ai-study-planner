import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_bar_actions.dart';
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

    final percent = (plan.completionRate * 100).round();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
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
            icon: const Icon(Icons.auto_awesome_outlined),
            tooltip: 'AI Study Assistant',
            onPressed: () => Navigator.pushNamed(context, '/chat'),
          ),
          IconButton(
            icon: const Icon(Icons.trending_up_outlined),
            tooltip: 'Progress',
            onPressed: () => Navigator.pushNamed(context, '/progress'),
          ),
          const AppBarMenuButton(),
        ],
      ),
      body: AppBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.name.split(' ').first ?? 'Student'}!',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Exam ${plan.examDate} · ${plan.totalDays} days left',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentCyan,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${plan.completedTaskCount}/${plan.totalTaskCount} tasks',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: plan.completionRate,
                        minHeight: 8,
                        backgroundColor: AppColors.bgPrimary,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const DaySelector(),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final dayIndex = ref.watch(selectedDayProvider);
                  if (dayIndex >= plan.schedule.length) return const SizedBox();
                  final day = plan.schedule[dayIndex];
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                    children: [
                      ...day.sessions.asMap().entries.map(
                            (e) => SubjectCard(
                              task: e.value,
                              dayIndex: dayIndex,
                              sessionIndex: e.key,
                            ),
                          ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.bgSecondary,
        indicatorColor: AppColors.primary.withValues(alpha: 0.25),
        selectedIndex: 0,
        onDestinationSelected: (i) {
          if (i == 0) {
            Navigator.popUntil(context, ModalRoute.withName('/plan'));
          } else if (i == 1) {
            Navigator.pushNamed(context, '/progress');
          } else if (i == 2) {
            Navigator.pushNamed(context, '/pomodoro');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.trending_up_outlined), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.timer_outlined), label: 'Focus'),
        ],
      ),
    );
  }
}
