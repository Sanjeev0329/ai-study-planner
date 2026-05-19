import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../onboarding/presentation/onboarding_provider.dart';
import '../../ai_planner_provider.dart';
import '../../../study_plan/study_plan_provider.dart';

class GeneratePlanScreen extends ConsumerWidget {
  const GeneratePlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planState = ref.watch(aiPlannerProvider);
    final onboarding = ref.watch(onboardingProvider);

    ref.listen(aiPlannerProvider, (_, next) {
      if (next.status == PlanStatus.success && next.response?.plan != null) {
        ref.read(studyPlanProvider.notifier).setPlan(next.response!.plan);
        ref.read(plansListProvider.notifier).upsert(next.response!.plan);
        Navigator.pushReplacementNamed(context, '/plan-detail');
      }
    });

    if (planState.status == PlanStatus.loading) {
      return const Scaffold(body: LoadingWidget(message: 'Generating your plan...'));
    }

    final hasError = planState.status == PlanStatus.error && planState.error != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Study Summary')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _SummaryCard(icon: Icons.calendar_today, label: 'Exam date',
              value: onboarding.examDate?.toString().split(' ')[0] ?? 'Not set'),
          _SummaryCard(icon: Icons.schedule, label: 'Daily hours',
              value: '${onboarding.dailyHours} hours/day'),
          _SummaryCard(icon: Icons.book_outlined, label: 'Subjects',
              value: onboarding.subjects.map((s) => s.name).join(', ')),
          _SummaryCard(
              icon: Icons.warning_amber_outlined, label: 'Difficult topics',
              value: onboarding.subjects.where((s) => s.isDifficult).map((s) => s.name).join(', ').isNotEmpty
                  ? onboarding.subjects.where((s) => s.isDifficult).map((s) => s.name).join(', ')
                  : 'None marked'),
          if (hasError) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.hard.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.hard.withOpacity(0.3)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.error_outline, color: AppColors.hard, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    planState.error!,
                    style: const TextStyle(color: AppColors.hard, height: 1.4),
                  ),
                ),
              ]),
            ),
          ],
          const Spacer(),
          const Text('Gemini AI will create your personalized plan.',
              textAlign: TextAlign.center, style: TextStyle(color: AppColors.textGrey)),
          const SizedBox(height: 16),
          CustomButton(
            label: hasError ? 'Try Again' : 'Generate My Plan',
            onPressed: () => ref.read(aiPlannerProvider.notifier).generatePlan(),
            isLoading: planState.status == PlanStatus.loading,
          ),
        ]),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _SummaryCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
    ),
  );
}
