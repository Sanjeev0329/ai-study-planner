import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_bar_actions.dart';
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

  Future<void> _confirmDeletePlan(StudyPlanModel plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_outline, color: AppColors.hard, size: 32),
        title: const Text('Delete this plan?'),
        content: Text(
          'Delete "${plan.displayTitle}"? This cannot be undone.',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.hard),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(plansListProvider.notifier).deletePlan(plan.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan deleted'), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete plan. Check connection and try again.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.hard,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(plansListProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('My Study Plans'),
        actions: const [
          AppBarMenuButton(),
        ],
      ),
      body: AppBackground(
        child: plans.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu_book_outlined, size: 56, color: AppColors.primary.withValues(alpha: 0.8)),
                      const SizedBox(height: 16),
                      Text(
                        'Hello, ${user?.name.split(' ').first ?? 'Student'}!',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create your first study plan to get started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/onboarding'),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Plan'),
                      ),
                    ],
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                children: [
                  Text(
                    'Hello, ${user?.name.split(' ').first ?? 'Student'}!',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to open · Long-press to delete',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  ...plans.map((plan) => _PlanListCard(
                        plan: plan,
                        onTap: () {
                          ref.read(studyPlanProvider.notifier).setPlan(plan);
                          ref.read(selectedDayProvider.notifier).state = 0;
                          Navigator.pushNamed(context, '/plan-detail');
                        },
                        onLongPress: () => _confirmDeletePlan(plan),
                      )),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/onboarding'),
        icon: const Icon(Icons.add),
        label: const Text('New Plan'),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.bgSecondary,
        indicatorColor: AppColors.primary.withValues(alpha: 0.25),
        selectedIndex: 0,
        onDestinationSelected: (i) {
          if (i == 1) Navigator.pushNamed(context, '/progress');
          if (i == 2) Navigator.pushNamed(context, '/pomodoro');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.trending_up_outlined), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.timer_outlined), label: 'Focus'),
        ],
      ),
    );
  }
}

class _PlanListCard extends StatelessWidget {
  final StudyPlanModel plan;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _PlanListCard({
    required this.plan,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (plan.completionRate * 100).round();
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school_outlined, color: AppColors.primaryLight),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.displayTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Exam ${plan.examDate} · $percent% done',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: plan.completionRate,
                    minHeight: 4,
                    backgroundColor: AppColors.bgPrimary,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
