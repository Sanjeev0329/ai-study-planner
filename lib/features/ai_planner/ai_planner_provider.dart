import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ai_plan_response_model.dart';
import '../../models/ai_plan_request_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/user_provider.dart';
import '../onboarding/presentation/onboarding_provider.dart';
import 'data/ai_repository.dart';

enum PlanStatus { idle, loading, success, error }

class AiPlannerState {
  final PlanStatus status;
  final AiPlanResponseModel? response;
  final String? error;
  const AiPlannerState({this.status = PlanStatus.idle, this.response, this.error});

  AiPlannerState copyWith({PlanStatus? status, AiPlanResponseModel? response, String? error}) =>
      AiPlannerState(
        status:   status   ?? this.status,
        response: response ?? this.response,
        error:    error    ?? this.error,
      );
}

class AiPlannerNotifier extends StateNotifier<AiPlannerState> {
  final Ref _ref;
  AiPlannerNotifier(this._ref) : super(const AiPlannerState());

  Future<void> generatePlan() async {
    state = state.copyWith(status: PlanStatus.loading);

    final onboarding = _ref.read(onboardingProvider);
    final user       = _ref.read(userProvider);

    if (user == null) {
      state = state.copyWith(status: PlanStatus.error, error: 'Not logged in');
      return;
    }
    if (onboarding.examDate == null) {
      state = state.copyWith(status: PlanStatus.error, error: 'Set exam date first');
      return;
    }
    if (onboarding.subjects.isEmpty) {
      state = state.copyWith(status: PlanStatus.error, error: 'Add at least one subject');
      return;
    }

    // Combine difficult subjects + manually typed weak topics
    final difficultSubjects = onboarding.subjects
        .where((s) => s.isDifficult)
        .map((s) => s.name)
        .toList();

    final allWeakTopics = [
      ...difficultSubjects,
      ...onboarding.weakTopics,        // ← typed weak topics now included
    ].toSet().toList();                 // remove duplicates

    final request = AiPlanRequestModel(
      examDate:       onboarding.examDate.toString().split(' ')[0],
      subjects:       onboarding.subjects.map((s) => s.name).toList(),
      dailyHours:     onboarding.dailyHours,
      difficultTopics: allWeakTopics,
    );

    final repo = AiRepository(
      _ref.read(geminiServiceProvider),
      _ref.read(firestoreServiceProvider),
    );

    final result = await repo.generateAndSave(request, user.uid);

    state = result.success
        ? state.copyWith(status: PlanStatus.success, response: result)
        : state.copyWith(status: PlanStatus.error, error: result.error);
  }
}

final aiPlannerProvider =
StateNotifierProvider<AiPlannerNotifier, AiPlannerState>(
        (ref) => AiPlannerNotifier(ref));