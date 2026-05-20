import 'dart:convert';
import '../../models/ai_plan_request_model.dart';

class PromptBuilder {
  static String buildStudyPlanPrompt(AiPlanRequestModel req) {
    final difficult = req.difficultTopics.isEmpty ? 'None' : req.difficultTopics.join(', ');
    final totalDays = _daysUntilExam(req.examDate);

    return """
You are an expert study planner. Create a day-by-day study plan as JSON only.

Exam date: ${req.examDate}
Subjects: ${req.subjects.join(', ')}
Daily study hours: ${req.dailyHours}
Difficult topics (allocate ~40% more time): $difficult

Requirements:
- Include exactly $totalDays days in schedule (day 1 through day $totalDays).
- Max 3 sessions per day.
- Each session: duration_minutes between 30 and 120.
- Last 2 days must be revision-only sessions.
- Keep tip under 10 words.
- Use difficulty: easy, medium, or hard.
- Dates must be consecutive starting from tomorrow (YYYY-MM-DD).

Return ONLY this JSON shape (no markdown, no extra keys):
{
  "student_plan": {
    "exam_date": "${req.examDate}",
    "total_days": $totalDays,
    "daily_hours": ${req.dailyHours},
    "subjects": ${jsonEncode(req.subjects)},
    "schedule": [
      {
        "day": 1,
        "date": "YYYY-MM-DD",
        "sessions": [
          {
            "id": "d1s1",
            "subject": "Subject name",
            "topic": "Topic name",
            "duration_minutes": 60,
            "difficulty": "medium",
            "tip": "Short tip"
          }
        ]
      }
    ]
  }
}
""";
  }

  static int _daysUntilExam(String examDate) {
    final exam = DateTime.tryParse(examDate);
    if (exam == null) return 7;
    final days = exam.difference(DateTime.now()).inDays;
    if (days < 1) return 1;
    return days > 21 ? 21 : days;
  }

  static String buildChatPrompt(String message, String planContext) {
    return """You are Prepwise AI, a helpful study assistant.
Student plan: $planContext
Question: $message
Answer helpfully in 2-3 sentences.""";
  }
}
