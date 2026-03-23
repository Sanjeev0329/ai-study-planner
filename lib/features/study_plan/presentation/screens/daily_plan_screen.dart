import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../study_plan_provider.dart';
import '../../widgets/task_title.dart';


class DailyPlanScreen extends ConsumerWidget {
  const DailyPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(studyPlanProvider);
    final dayIndex = ref.watch(selectedDayProvider);
    if (plan == null || dayIndex >= plan.schedule.length) {
      return const Scaffold(body: Center(child: Text('No plan available')));
    }
    final day = plan.schedule[dayIndex];
    final totalMin = day.sessions.fold(0, (s, t) => s + t.durationMinutes);
    final done = day.sessions.where((s) => s.isCompleted).length;

    return Scaffold(
      appBar: AppBar(title: Text('Day \${day.day} — \${day.date}')),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _Stat('Sessions', '\${day.sessions.length}'),
            _Stat('Total', '\${totalMin}m'),
            _Stat('Done', '\$done/\${day.sessions.length}'),
          ]),
        ),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: day.sessions.length,
          itemBuilder: (_, i) => TaskTile(task: day.sessions[i], dayIndex: dayIndex, sessionIndex: i),
        )),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
    Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
  ]);
}
