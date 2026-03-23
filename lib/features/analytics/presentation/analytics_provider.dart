import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../study_plan/study_plan_provider.dart';

class WeeklyData {
  final String label;
  final int minutesStudied;
  const WeeklyData(this.label, this.minutesStudied);
}

final weeklyDataProvider = Provider<List<WeeklyData>>((ref) {
  final plan = ref.watch(studyPlanProvider);
  if (plan == null) return [];
  final weeks = <String, int>{};
  for (int i = 0; i < plan.schedule.length; i++) {
    final label = 'W\${(i ~/ 7) + 1}';
    final completed = plan.schedule[i].sessions
        .where((s) => s.isCompleted).fold(0, (sum, s) => sum + s.durationMinutes);
    weeks[label] = (weeks[label] ?? 0) + completed;
  }
  return weeks.entries.map((e) => WeeklyData(e.key, e.value)).toList();
});
