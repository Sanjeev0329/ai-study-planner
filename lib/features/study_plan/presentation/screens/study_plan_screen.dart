import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/user_provider.dart';
import '../../study_plan_provider.dart';
import '../../widgets/day_selector.dart';
import '../../widgets/subject_card.dart';


class StudyPlanScreen extends ConsumerStatefulWidget {
  const StudyPlanScreen({super.key});
  @override ConsumerState<StudyPlanScreen> createState() => _State();
}

class _State extends ConsumerState<StudyPlanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        ref.read(studyPlanProvider.notifier).loadLatestPlan());
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(studyPlanProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Study Plan'),
        actions: [
          IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () => Navigator.pushNamed(context, '/chat')),
          IconButton(icon: const Icon(Icons.bar_chart), onPressed: () => Navigator.pushNamed(context, '/analytics')),
        ],
      ),
      body: plan == null
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.auto_awesome, size: 64, color: AppColors.primary),
        const SizedBox(height: 16),
        const Text('No plan yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: () => Navigator.pushReplacementNamed(context, '/onboarding'),
            child: const Text('Create Plan')),
      ]))
          : Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, ${user?.name.split(' ').first ?? 'Student'}!",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              Text(
                "Exam: ${plan.examDate} · ${plan.totalDays} days",
                style: const TextStyle(color: AppColors.textGrey),
              ),
            ],
          ),
        ),
        const DaySelector(),
        Expanded(child: Consumer(builder: (context, ref, _) {
          final dayIndex = ref.watch(selectedDayProvider);
          if (dayIndex >= plan.schedule.length) return const SizedBox();
          final day = plan.schedule[dayIndex];
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              ...day.sessions.asMap().entries.map((e) =>
                  SubjectCard(task: e.value, dayIndex: dayIndex, sessionIndex: e.key)),
              const SizedBox(height: 80),
            ],
          );
        })),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, '/progress');
          if (i == 2) Navigator.pushNamed(context, '/pomodoro');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Pomodoro'),
        ],
      ),
    );
  }
}
