import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../chat_provider.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    // Dark theme: assistant = readable slate surface + light text (never white-on-white).
    final assistantBg = AppColors.bgSecondary;
    const assistantBodyColor = AppColors.textWhite;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : assistantBg,
          border: isUser
              ? null
              : Border.all(color: AppColors.glassBorder),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : assistantBodyColor,
            fontSize: 14,
            height: 1.5,
            fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
