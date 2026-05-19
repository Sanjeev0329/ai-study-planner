import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/study_plan.dart';
import '../../../../providers/user_provider.dart';
import '../../study_plan_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(plansListProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(plansListProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Study Plans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => Navigator.pushNamed(context, '/chat'),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.pushNamed(context, '/analytics'),
          ),
        ],
      ),
      body: plans.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, size: 64, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Hello, ${user?.name.split(' ').first ?? 'Student'}!',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first study plan to get started.',
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/onboarding'),
                    child: const Text('Create Plan'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                Text(
                  'Hello, ${user?.name.split(' ').first ?? 'Student'}!',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select a subject plan to continue studying',
                  style: TextStyle(color: AppColors.textGrey),
                ),
                const SizedBox(height: 20),
                ...plans.map((plan) => _PlanListCard(
                      plan: plan,
                      onTap: () {
                        ref.read(studyPlanProvider.notifier).setPlan(plan);
                        ref.read(selectedDayProvider.notifier).state = 0;
                        Navigator.pushNamed(context, '/plan-detail');
                      },
                    )),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/onboarding'),
        icon: const Icon(Icons.add),
        label: const Text('New Plan'),
        backgroundColor: AppColors.primary,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, '/progress');
          if (i == 2) Navigator.pushNamed(context, '/pomodoro');
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

class _PlanListCard extends StatelessWidget {
  final StudyPlanModel plan;
  final VoidCallback onTap;

  const _PlanListCard({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final percent = (plan.completionRate * 100).round();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_book_outlined, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.displayTitle,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Exam: ${plan.examDate} · ${plan.totalDays} days',
                          style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textGrey),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${plan.completedTaskCount}/${plan.totalTaskCount} tasks',
                    style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                  ),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: plan.completionRate,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
