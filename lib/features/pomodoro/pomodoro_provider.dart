import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PomodoroMode { focus, shortBreak, longBreak }

class PomodoroState {
  final int secondsLeft;
  final bool isRunning;
  final PomodoroMode mode;
  final int sessionsCompleted;

  const PomodoroState({
    this.secondsLeft = 25 * 60,
    this.isRunning = false,
    this.mode = PomodoroMode.focus,
    this.sessionsCompleted = 0,
  });

  int get totalSeconds {
    switch (mode) {
      case PomodoroMode.focus:
        return 25 * 60;
      case PomodoroMode.shortBreak:
        return 5 * 60;
      case PomodoroMode.longBreak:
        return 15 * 60;
    }
  }

  double get progress {
    if (totalSeconds <= 0) return 0;
    return 1 - (secondsLeft / totalSeconds);
  }

  PomodoroState copyWith({
    int? secondsLeft,
    bool? isRunning,
    PomodoroMode? mode,
    int? sessionsCompleted,
  }) =>
      PomodoroState(
        secondsLeft: secondsLeft ?? this.secondsLeft,
        isRunning: isRunning ?? this.isRunning,
        mode: mode ?? this.mode,
        sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      );
}

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  Timer? _timer;
  PomodoroNotifier() : super(const PomodoroState());

  void startPause() {
    if (state.isRunning) {
      _stopTimer();
      state = state.copyWith(isRunning: false);
      return;
    }

    if (state.secondsLeft <= 0) {
      state = state.copyWith(secondsLeft: state.totalSeconds);
    }

    state = state.copyWith(isRunning: true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (state.secondsLeft <= 1) {
      _onComplete();
      return;
    }
    state = state.copyWith(secondsLeft: state.secondsLeft - 1);
  }

  void _onComplete() {
    _stopTimer();
    final newSessions = state.mode == PomodoroMode.focus
        ? state.sessionsCompleted + 1
        : state.sessionsCompleted;
    final nextMode = state.mode == PomodoroMode.focus
        ? (newSessions % 4 == 0 ? PomodoroMode.longBreak : PomodoroMode.shortBreak)
        : PomodoroMode.focus;

    state = PomodoroState(
      mode: nextMode,
      sessionsCompleted: newSessions,
      secondsLeft: _secondsForMode(nextMode),
    );
  }

  void reset() {
    _stopTimer();
    state = PomodoroState(
      mode: state.mode,
      sessionsCompleted: state.sessionsCompleted,
      secondsLeft: state.totalSeconds,
    );
  }

  void setMode(PomodoroMode mode) {
    _stopTimer();
    state = PomodoroState(
      mode: mode,
      sessionsCompleted: state.sessionsCompleted,
      secondsLeft: _secondsForMode(mode),
    );
  }

  void skip() {
    _stopTimer();
    if (state.mode == PomodoroMode.focus) {
      _onComplete();
    } else {
      setMode(PomodoroMode.focus);
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  static int _secondsForMode(PomodoroMode mode) {
    switch (mode) {
      case PomodoroMode.focus:
        return 25 * 60;
      case PomodoroMode.shortBreak:
        return 5 * 60;
      case PomodoroMode.longBreak:
        return 15 * 60;
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

final pomodoroProvider =
    StateNotifierProvider<PomodoroNotifier, PomodoroState>((_) => PomodoroNotifier());
