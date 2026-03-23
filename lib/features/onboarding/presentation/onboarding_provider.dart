import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../models/subject_model.dart';


class OnboardingState {
  final List<SubjectModel> subjects;
  final List<String> weakTopics;      // ← specific weak topics from text field
  final DateTime? examDate;
  final int dailyHours;

  const OnboardingState({
    this.subjects   = const [],
    this.weakTopics = const [],
    this.examDate,
    this.dailyHours = 5,
  });

  OnboardingState copyWith({
    List<SubjectModel>? subjects,
    List<String>? weakTopics,
    DateTime? examDate,
    int? dailyHours,
  }) =>
      OnboardingState(
        subjects:   subjects   ?? this.subjects,
        weakTopics: weakTopics ?? this.weakTopics,
        examDate:   examDate   ?? this.examDate,
        dailyHours: dailyHours ?? this.dailyHours,
      );
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());
  final _uuid = const Uuid();

  // ── Subject methods ───────────────────────────────────────
  void addSubject(String name) {
    if (state.subjects.any(
            (s) => s.name.toLowerCase() == name.toLowerCase())) return;
    state = state.copyWith(
        subjects: [...state.subjects, SubjectModel(id: _uuid.v4(), name: name)]);
  }

  void removeSubject(String id) => state = state.copyWith(
      subjects: state.subjects.where((s) => s.id != id).toList());

  void toggleDifficult(String id) => state = state.copyWith(
      subjects: state.subjects
          .map((s) => s.id == id ? s.copyWith(isDifficult: !s.isDifficult) : s)
          .toList());

  // ── Weak topic methods ────────────────────────────────────
  void addWeakTopic(String topic) {
    if (state.weakTopics.any(
            (t) => t.toLowerCase() == topic.toLowerCase())) return;
    state = state.copyWith(weakTopics: [...state.weakTopics, topic]);
  }

  void removeWeakTopic(String topic) => state = state.copyWith(
      weakTopics: state.weakTopics.where((t) => t != topic).toList());

  // ── Other setters ─────────────────────────────────────────
  void setExamDate(DateTime date) => state = state.copyWith(examDate: date);
  void setDailyHours(int hours)   => state = state.copyWith(dailyHours: hours);
}

final onboardingProvider =
StateNotifierProvider<OnboardingNotifier, OnboardingState>(
        (_) => OnboardingNotifier());