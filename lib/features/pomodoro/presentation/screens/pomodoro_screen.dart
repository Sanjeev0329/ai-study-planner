import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_bar_actions.dart';
import '../../pomodoro_provider.dart';
import '../widgets/timer_display.dart';
import '../widgets/control_buttons.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  void _goBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/plan');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pomodoroProvider);
    final modeColor = state.mode == PomodoroMode.focus
        ? AppColors.primary
        : state.mode == PomodoroMode.shortBreak
            ? AppColors.easy
            : AppColors.secondary;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Focus Timer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _goBack(context),
        ),
        actions: const [AppBarMenuButton()],
      ),
      body: AppBackground(
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: PomodoroMode.values.map((m) {
                  final labels = {
                    PomodoroMode.focus: 'Focus',
                    PomodoroMode.shortBreak: '5 min',
                    PomodoroMode.longBreak: '15 min',
                  };
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
                        border: Border.all(
                          color: selected ? modeColor : AppColors.glassBorder,
                        ),
                      ),
                      child: Text(
                        labels[m]!,
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TimerDisplay(state: state, color: modeColor),
                    const SizedBox(height: 16),
                    Text(
                      state.isRunning
                          ? (state.mode == PomodoroMode.focus ? 'Stay focused…' : 'Enjoy your break!')
                          : (state.mode == PomodoroMode.focus ? 'Tap start to focus' : 'Tap start for your break'),
                      style: TextStyle(fontSize: 16, color: modeColor, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              ControlButtons(state: state),
              const SizedBox(height: 12),
              Text(
                'Sessions today: ${state.sessionsCompleted}',
                style: const TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
