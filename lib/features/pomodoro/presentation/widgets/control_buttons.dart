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
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      IconButton(icon: const Icon(Icons.refresh, size: 28), onPressed: notifier.reset, color: AppColors.textGrey),
      const SizedBox(width: 16),
      ElevatedButton(
        onPressed: notifier.startPause,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
            shape: const CircleBorder(), padding: const EdgeInsets.all(20)),
        child: Icon(state.isRunning ? Icons.pause : Icons.play_arrow, size: 32, color: Colors.white),
      ),
      const SizedBox(width: 16),
      IconButton(
        icon: const Icon(Icons.skip_next, size: 28),
        onPressed: () => notifier.setMode(state.mode == PomodoroMode.focus ? PomodoroMode.shortBreak : PomodoroMode.focus),
        color: AppColors.textGrey,
      ),
    ]);
  }
}
