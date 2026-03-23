import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/study_plan.dart';
import '../../models/study_task_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/user_provider.dart';

class StudyPlanNotifier extends StateNotifier<StudyPlanModel?> {
  final Ref _ref;
  StudyPlanNotifier(this._ref) : super(null);

  void setPlan(StudyPlanModel plan) => state = plan;

  Future<void> loadLatestPlan() async {
    final user = _ref.read(userProvider);
    if (user == null) return;
    final plan = await _ref.read(firestoreServiceProvider).getLatestPlan(user.uid);
    if (plan != null) state = plan;
  }

  Future<void> markTaskDone(int dayIndex, int sessionIndex) async {
    if (state == null) return;
    final plan = state!;
    final updatedSchedule = List<DaySchedule>.from(plan.schedule);
    final day = updatedSchedule[dayIndex];
    final updatedSessions = List<StudyTaskModel>.from(day.sessions);
    updatedSessions[sessionIndex] = updatedSessions[sessionIndex].copyWith(isCompleted: true);
    updatedSchedule[dayIndex] = DaySchedule(day: day.day, date: day.date, sessions: updatedSessions);
    state = StudyPlanModel(id: plan.id, examDate: plan.examDate, totalDays: plan.totalDays,
        dailyHours: plan.dailyHours, subjects: plan.subjects, schedule: updatedSchedule, createdAt: plan.createdAt);
  }
}

final studyPlanProvider = StateNotifierProvider<StudyPlanNotifier, StudyPlanModel?>((ref) => StudyPlanNotifier(ref));
final selectedDayProvider = StateProvider<int>((_) => 0);
