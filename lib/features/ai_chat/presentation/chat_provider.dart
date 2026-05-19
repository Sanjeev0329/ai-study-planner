import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/study_plan.dart';
import '../../../providers/app_provider.dart';
import '../../study_plan/study_plan_provider.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  const ChatMessage({required this.text, required this.isUser});
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;
  ChatNotifier(this._ref) : super(const []);

  bool _loading = false;
  bool get isLoading => _loading;

  void ensureWelcome() {
    if (state.isNotEmpty) return;
    state = const [
      ChatMessage(
        text:
            "Hi! I'm your Prepwise AI assistant. Open a study plan and ask me anything about your schedule or topics!",
        isUser: false,
      ),
    ];
  }

  void resetForPlan(StudyPlanModel plan) {
    state = [
      ChatMessage(
        text:
            "Hi! I'm your Prepwise AI assistant for ${plan.displayTitle}. "
            'Ask me about topics, study tips, or anything in your day-wise plan!',
        isUser: false,
      ),
    ];
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    state = [...state, ChatMessage(text: text, isUser: true)];
    _loading = true;

    final plan = _ref.read(studyPlanProvider);
    final context = plan != null
        ? _buildPlanContext(plan, _ref.read(selectedDayProvider))
        : 'No plan selected';

    final reply = await _ref.read(geminiServiceProvider).chat(text, context);
    _loading = false;
    state = [...state, ChatMessage(text: reply, isUser: false)];
  }

  static String _buildPlanContext(StudyPlanModel plan, int selectedDayIndex) {
    final buffer = StringBuffer()
      ..writeln('Study plan: ${plan.displayTitle}')
      ..writeln('Exam date: ${plan.examDate}')
      ..writeln('Total days: ${plan.totalDays}, Daily hours: ${plan.dailyHours}')
      ..writeln('Subjects: ${plan.subjects.join(", ")}')
      ..writeln(
        'Overall progress: ${plan.completedTaskCount}/${plan.totalTaskCount} tasks completed.',
      );

    if (selectedDayIndex >= 0 && selectedDayIndex < plan.schedule.length) {
      final day = plan.schedule[selectedDayIndex];
      buffer.writeln('\nCurrently viewing Day ${day.day} (${day.date}):');
      for (final session in day.sessions) {
        buffer.writeln(
          '- ${session.subject} | ${session.topic} | ${session.difficulty} | '
          '${session.durationMinutes} min | ${session.isCompleted ? "completed" : "pending"} | tip: ${session.tip}',
        );
      }
    }

    buffer.writeln('\nFull schedule summary:');
    for (final day in plan.schedule) {
      buffer.writeln('Day ${day.day} (${day.date}):');
      for (final session in day.sessions) {
        buffer.writeln(
          '  • ${session.subject}: ${session.topic} '
          '(${session.durationMinutes}m, ${session.isCompleted ? "done" : "todo"})',
        );
      }
    }

    return buffer.toString();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>(
  (ref) => ChatNotifier(ref),
);
