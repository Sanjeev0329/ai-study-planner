class AiPlanRequestModel {
  final String examDate;
  final List<String> subjects, difficultTopics;
  final int dailyHours;
  const AiPlanRequestModel({required this.examDate, required this.subjects,
    required this.dailyHours, required this.difficultTopics});
}
