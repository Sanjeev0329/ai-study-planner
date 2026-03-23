import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input_field.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatProvider);
    final scrollCtrl = ScrollController();

    ref.listen(chatProvider, (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollCtrl.hasClients) {
          scrollCtrl.animateTo(scrollCtrl.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18)),
          const SizedBox(width: 8),
          const Text('AI Study Assistant'),
        ]),
      ),
      body: Column(children: [
        Expanded(child: ListView.builder(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (_, i) => MessageBubble(message: messages[i]),
        )),
        const ChatInputField(),
      ]),
    );
  }
}
