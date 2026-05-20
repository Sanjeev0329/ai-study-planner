import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_bar_actions.dart';
import '../../../analytics/presentation/analytics_provider.dart';
import '../../../study_plan/study_plan_provider.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (ref.read(studyPlanProvider) == null) {
        await ref.read(studyPlanProvider.notifier).loadLatestPlan();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(studyPlanProvider);
    final subjectProgress = ref.watch(derivedProgressProvider);

    if (plan == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Progress'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.trending_up, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('No plan selected', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Open a subject plan from home first.',
                style: TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/plan'),
              child: const Text('Go to Home'),
            ),
          ]),
        ),
      );
    }

    final allSessions = plan.schedule.expand((d) => d.sessions).toList();
    final totalTasks = allSessions.length;
    final doneTasks = allSessions.where((s) => s.isCompleted).length;
    final studiedMinutes =
        allSessions.where((s) => s.isCompleted).fold(0, (sum, s) => sum + s.durationMinutes);
    final completionRate = totalTasks == 0 ? 0.0 : doneTasks / totalTasks;

    final examDate = DateTime.tryParse(plan.examDate);
    final daysLeft = examDate == null
        ? null
        : examDate.difference(DateTime.now()).inDays.clamp(0, 9999);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text(plan.displayTitle),
        actions: const [AppBarMenuButton()],
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
      ),
      body: AppBackground(
        child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(alignment: Alignment.center, children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: completionRate,
                    strokeWidth: 10,
                    backgroundColor: AppColors.glassBorder,
                    color: AppColors.primary,
                  ),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    '${(completionRate * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  const Text('Complete', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 24),
          Row(children: [
            _StatTile(
              label: 'Tasks done',
              value: '$doneTasks/$totalTasks',
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            _StatTile(
              label: 'Hours studied',
              value: '${(studiedMinutes / 60).toStringAsFixed(1)}h',
              color: AppColors.easy,
            ),
            const SizedBox(width: 12),
            _StatTile(
              label: 'Days left',
              value: daysLeft == null ? '—' : '$daysLeft',
              color: AppColors.medium,
            ),
          ]),
          const SizedBox(height: 28),
          const Text('By subject', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (subjectProgress.isEmpty)
            const Text('Complete tasks in your plan to see subject progress.',
                style: TextStyle(color: AppColors.textGrey))
          else
            ...subjectProgress.entries.map((e) => _SubjectProgressRow(
                  subject: e.key,
                  progress: e.value,
                )),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/analytics'),
            icon: const Icon(Icons.bar_chart),
            label: const Text('View detailed analytics'),
          ),
        ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _SubjectProgressRow extends StatelessWidget {
  final String subject;
  final double progress;

  const _SubjectProgressRow({required this.subject, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(subject, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text('${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.glassBorder,
            color: AppColors.accentCyan,
          ),
        ),
      ]),
    );
  }
}
