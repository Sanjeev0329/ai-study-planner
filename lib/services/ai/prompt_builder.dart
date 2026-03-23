import '../../models/ai_plan_request_model.dart';

class PromptBuilder {
  static String buildStudyPlanPrompt(AiPlanRequestModel req) {
    final difficult = req.difficultTopics.isEmpty ? 'None' : req.difficultTopics.join(', ');
    return """
You are an expert study planner. Create a detailed day-by-day study plan.
Exam date: \${req.examDate}
Subjects: \${req.subjects.join(', ')}
Daily hours: \${req.dailyHours}
Difficult topics (extra time): \$difficult
Rules:
1. Distribute topics day by day
2. Give 40 percent more time to difficult topics
3. Last 2 days = full revision
4. Return ONLY valid JSON, no markdown

Structure:
{
  "student_plan": {
    "exam_date": "YYYY-MM-DD",
    "total_days": 0,
    "daily_hours": 0,
    "subjects": [],
    "schedule": [
      {
        "day": 1,
        "date": "YYYY-MM-DD",
        "sessions": [
          {
            "id": "s1",
            "subject": "Subject",
            "topic": "Topic",
            "duration_minutes": 90,
            "difficulty": "easy",
            "tip": "Study tip"
          }
        ]
      }
    ]
  }
}
""";
  }

  static String buildChatPrompt(String message, String planContext) {
    return """You are Prepwise AI, a helpful study assistant.
Student plan: \$planContext
Question: \$message
Answer helpfully in 2-3 sentences.""";
  }
}
