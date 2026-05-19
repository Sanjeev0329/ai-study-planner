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
    final label = 'W${(i ~/ 7) + 1}';
    final completed = plan.schedule[i].sessions
        .where((s) => s.isCompleted).fold(0, (sum, s) => sum + s.durationMinutes);
    weeks[label] = (weeks[label] ?? 0) + completed;
  }
  return weeks.entries.map((e) => WeeklyData(e.key, e.value)).toList();
});

final derivedProgressProvider = Provider<Map<String, double>>((ref) {
  final plan = ref.watch(studyPlanProvider);
  if (plan == null) return const {};

  final completedBySubject = <String, int>{};
  final totalBySubject = <String, int>{};

  for (final day in plan.schedule) {
    for (final session in day.sessions) {
      final subject = session.subject.trim();
      if (subject.isEmpty) continue;

      totalBySubject[subject] = (totalBySubject[subject] ?? 0) + 1;
      if (session.isCompleted) {
        completedBySubject[subject] = (completedBySubject[subject] ?? 0) + 1;
      }
    }
  }

  final progress = <String, double>{};
  totalBySubject.forEach((subject, total) {
    if (total <= 0) {
      progress[subject] = 0;
    } else {
      final completed = completedBySubject[subject] ?? 0;
      progress[subject] = completed / total;
    }
  });
  return progress;
});
