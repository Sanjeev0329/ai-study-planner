import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/study_plan.dart';
import '../../models/study_task_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/storage/local_storage_service.dart';

class PlansListNotifier extends StateNotifier<List<StudyPlanModel>> {
  final Ref _ref;
  PlansListNotifier(this._ref) : super([]);

  Future<void> load() async {
    final user = _ref.read(userProvider);
    if (user == null) return;
    state = await _ref.read(firestoreServiceProvider).getAllPlans(user.uid);
  }

  void upsert(StudyPlanModel plan) {
    final index = state.indexWhere((p) => p.id == plan.id);
    if (index >= 0) {
      final updated = [...state];
      updated[index] = plan;
      state = updated;
    } else {
      state = [plan, ...state];
    }
  }
}

class StudyPlanNotifier extends StateNotifier<StudyPlanModel?> {
  final Ref _ref;
  StudyPlanNotifier(this._ref) : super(null);

  void setPlan(StudyPlanModel plan) {
    state = plan;
    _ref.read(plansListProvider.notifier).upsert(plan);
    LocalStorageService.cachePlan(plan.toMap());
    LocalStorageService.setActivePlanId(plan.id);
  }

  Future<void> loadLatestPlan() async {
    await _ref.read(plansListProvider.notifier).load();
    final plans = _ref.read(plansListProvider);
    if (plans.isEmpty) return;

    final activeId = await LocalStorageService.getActivePlanId();
    StudyPlanModel? match;
    if (activeId != null) {
      for (final p in plans) {
        if (p.id == activeId) {
          match = p;
          break;
        }
      }
    }
    state = match ?? plans.first;
  }

  Future<void> markTaskDone(int dayIndex, int sessionIndex) async {
    if (state == null) return;
    final user = _ref.read(userProvider);
    if (user == null) return;

    final plan = state!;
    final updatedSchedule = List<DaySchedule>.from(plan.schedule);
    final day = updatedSchedule[dayIndex];
    final updatedSessions = List<StudyTaskModel>.from(day.sessions);
    updatedSessions[sessionIndex] =
        updatedSessions[sessionIndex].copyWith(isCompleted: true);
    updatedSchedule[dayIndex] = DaySchedule(
      day: day.day,
      date: day.date,
      sessions: updatedSessions,
    );

    final updatedPlan = StudyPlanModel(
      id: plan.id,
      examDate: plan.examDate,
      totalDays: plan.totalDays,
      dailyHours: plan.dailyHours,
      subjects: plan.subjects,
      schedule: updatedSchedule,
      createdAt: plan.createdAt,
    );

    state = updatedPlan;
    _ref.read(plansListProvider.notifier).upsert(updatedPlan);
    await _ref.read(firestoreServiceProvider).savePlan(user.uid, updatedPlan);
    await LocalStorageService.cachePlan(updatedPlan.toMap());
  }
}

final plansListProvider =
    StateNotifierProvider<PlansListNotifier, List<StudyPlanModel>>(
        (ref) => PlansListNotifier(ref));

final studyPlanProvider =
    StateNotifierProvider<StudyPlanNotifier, StudyPlanModel?>((ref) => StudyPlanNotifier(ref));

final selectedDayProvider = StateProvider<int>((_) => 0);
