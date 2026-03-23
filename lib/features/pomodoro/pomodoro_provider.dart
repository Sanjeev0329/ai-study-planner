import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PomodoroMode { focus, shortBreak, longBreak }

class PomodoroState {
  final int secondsLeft;
  final bool isRunning;
  final PomodoroMode mode;
  final int sessionsCompleted;
  const PomodoroState({this.secondsLeft = 25 * 60, this.isRunning = false,
    this.mode = PomodoroMode.focus, this.sessionsCompleted = 0});
  int get totalSeconds {
    switch (mode) {
      case PomodoroMode.focus:      return 25 * 60;
      case PomodoroMode.shortBreak: return 5 * 60;
      case PomodoroMode.longBreak:  return 15 * 60;
    }
  }
  double get progress => 1 - (secondsLeft / totalSeconds);
  PomodoroState copyWith({int? secondsLeft, bool? isRunning, PomodoroMode? mode, int? sessionsCompleted}) =>
      PomodoroState(secondsLeft: secondsLeft ?? this.secondsLeft, isRunning: isRunning ?? this.isRunning,
          mode: mode ?? this.mode, sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted);
}

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  Timer? _timer;
  PomodoroNotifier() : super(const PomodoroState());

  void startPause() {
    if (state.isRunning) {
      _timer?.cancel();
      state = state.copyWith(isRunning: false);
    } else {
      state = state.copyWith(isRunning: true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (state.secondsLeft <= 0) { _onComplete(); }
        else { state = state.copyWith(secondsLeft: state.secondsLeft - 1); }
      });
    }
  }

  void _onComplete() {
    _timer?.cancel();
    final newSessions = state.mode == PomodoroMode.focus ? state.sessionsCompleted + 1 : state.sessionsCompleted;
    final nextMode = state.mode == PomodoroMode.focus
        ? (newSessions % 4 == 0 ? PomodoroMode.longBreak : PomodoroMode.shortBreak)
        : PomodoroMode.focus;
    state = PomodoroState(mode: nextMode, sessionsCompleted: newSessions);
  }

  void reset() { _timer?.cancel(); state = PomodoroState(mode: state.mode, sessionsCompleted: state.sessionsCompleted); }
  void setMode(PomodoroMode mode) { _timer?.cancel(); state = PomodoroState(mode: mode, sessionsCompleted: state.sessionsCompleted); }

  @override void dispose() { _timer?.cancel(); super.dispose(); }
}

final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroState>((_) => PomodoroNotifier());
