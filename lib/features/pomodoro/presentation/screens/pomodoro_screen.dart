import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../pomodoro_provider.dart';
import '../widgets/timer_display.dart';
import '../widgets/control_buttons.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pomodoroProvider);
    final modeColor = state.mode == PomodoroMode.focus ? AppColors.primary
        : state.mode == PomodoroMode.shortBreak ? AppColors.easy : AppColors.secondary;

    return Scaffold(
      appBar: AppBar(title: const Text('Focus Timer')),
      body: Column(children: [
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: PomodoroMode.values.map((m) {
          final labels = {PomodoroMode.focus: 'Focus', PomodoroMode.shortBreak: '5 min', PomodoroMode.longBreak: '15 min'};
          final selected = m == state.mode;
          return GestureDetector(
            onTap: () => ref.read(pomodoroProvider.notifier).setMode(m),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? modeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? modeColor : Colors.grey.shade300),
              ),
              child: Text(labels[m]!, style: TextStyle(color: selected ? Colors.white : AppColors.textGrey, fontWeight: FontWeight.w500)),
            ),
          );
        }).toList()),
        const Spacer(),
        TimerDisplay(state: state, color: modeColor),
        const SizedBox(height: 12),
        Text(state.mode == PomodoroMode.focus ? 'Time to focus!' : 'Take a break!',
            style: TextStyle(fontSize: 16, color: modeColor, fontWeight: FontWeight.w500)),
        const Spacer(),
        ControlButtons(state: state),
        const SizedBox(height: 16),
        Text('Sessions today: \${state.sessionsCompleted}', style: const TextStyle(color: AppColors.textGrey)),
        const SizedBox(height: 40),
      ]),
    );
  }
}
