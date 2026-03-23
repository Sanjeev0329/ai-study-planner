import 'package:prepwise/models/study_plan.dart';

class AiPlanResponseModel {
  final StudyPlanModel plan;
  final bool success;
  final String? error;
  const AiPlanResponseModel({required this.plan, this.success = true, this.error});
  factory AiPlanResponseModel.failure(String err) => AiPlanResponseModel(
      plan: StudyPlanModel(id: '', examDate: '', totalDays: 0, dailyHours: 0,
          subjects: [], schedule: [], createdAt: DateTime.now()),
      success: false, error: err);
}
