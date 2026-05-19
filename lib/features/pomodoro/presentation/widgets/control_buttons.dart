import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../pomodoro_provider.dart';

class ControlButtons extends ConsumerWidget {
  final PomodoroState state;
  const ControlButtons({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(pomodoroProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.refresh, size: 28),
          onPressed: notifier.reset,
          color: AppColors.textGrey,
          tooltip: 'Reset',
        ),
        const SizedBox(width: 24),
        Material(
          color: AppColors.primary,
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: notifier.startPause,
            child: SizedBox(
              width: 72,
              height: 72,
              child: Icon(
                state.isRunning ? Icons.pause : Icons.play_arrow,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        IconButton(
          icon: const Icon(Icons.skip_next, size: 28),
          onPressed: notifier.skip,
          color: AppColors.textGrey,
          tooltip: 'Skip',
        ),
      ],
    );
  }
}
