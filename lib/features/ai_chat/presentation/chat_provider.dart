import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_provider.dart';
import '../../study_plan/study_plan_provider.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  const ChatMessage({required this.text, required this.isUser});
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;
  ChatNotifier(this._ref) : super(const [
    ChatMessage(text: "Hi! I'm your Prepwise AI assistant. Ask me anything about your study plan or topics!", isUser: false),
  ]);

  bool _loading = false;
  bool get isLoading => _loading;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    state = [...state, ChatMessage(text: text, isUser: true)];
    _loading = true;
    final plan = _ref.read(studyPlanProvider);
    final context = plan != null
        ? 'Exam: \${plan.examDate}, Subjects: \${plan.subjects.join(", ")}, \${plan.totalDays} days'
        : 'No plan yet';
    final reply = await _ref.read(geminiServiceProvider).chat(text, context);
    _loading = false;
    state = [...state, ChatMessage(text: reply, isUser: false)];
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) => ChatNotifier(ref));
