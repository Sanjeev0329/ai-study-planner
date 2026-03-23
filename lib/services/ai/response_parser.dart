import 'dart:convert';
import '../../models/study_plan.dart';
import '../../models/study_task_model.dart';

class ResponseParser {
  static StudyPlanModel? parseStudyPlan(String raw) {
    try {
      final clean = raw.replaceAll(RegExp(r'```json|```'), '').trim();
      final json = jsonDecode(clean) as Map<String, dynamic>;
      final plan = json['student_plan'] as Map<String, dynamic>;
      final schedule = (plan['schedule'] as List).map((d) {
        final day = d as Map<String, dynamic>;
        final sessions = (day['sessions'] as List).map((s) {
          final sm = s as Map<String, dynamic>;
          return StudyTaskModel(
            id: sm['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            subject: sm['subject'] ?? '',
            topic: sm['topic'] ?? '',
            durationMinutes: sm['duration_minutes'] ?? 60,
            difficulty: sm['difficulty'] ?? 'medium',
            tip: sm['tip'] ?? '',
          );
        }).toList();
        return DaySchedule(day: day['day'] ?? 1, date: day['date'] ?? '', sessions: sessions);
      }).toList();
      return StudyPlanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        examDate: plan['exam_date'] ?? '',
        totalDays: plan['total_days'] ?? schedule.length,
        dailyHours: plan['daily_hours'] ?? 5,
        subjects: List<String>.from(plan['subjects'] ?? []),
        schedule: schedule,
        createdAt: DateTime.now(),
      );
    } catch (_) { return null; }
  }
}
