import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../study_plan/study_plan_provider.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/subject_performance_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(studyPlanProvider);
    if (plan == null) return const Scaffold(body: Center(child: Text('No plan yet')));

    final allSessions = plan.schedule.expand((d) => d.sessions);
    final total = allSessions.length;
    final done  = allSessions.where((s) => s.isCompleted).length;
    final mins  = allSessions.where((s) => s.isCompleted).fold(0, (s, t) => s + t.durationMinutes);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          _StatCard('Done', '\$done/\$total', AppColors.primary),
          const SizedBox(width: 12),
          _StatCard('Hours', '\${(mins / 60).toStringAsFixed(1)}h', AppColors.easy),
          const SizedBox(width: 12),
          _StatCard('Rate', '\${total == 0 ? 0 : (done / total * 100).toStringAsFixed(0)}%', AppColors.medium),
        ]),
        const SizedBox(height: 24),
        const Text('Weekly study time', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        const WeeklyChart(),
        const SizedBox(height: 24),
        const Text('Subject performance', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        const SubjectPerformanceChart(),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
    child: Column(children: [
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey), textAlign: TextAlign.center),
    ]),
  ));
}
