import 'package:cloud_firestore/cloud_firestore.dart';
import 'study_task_model.dart';

class DaySchedule {
  final int day;
  final String date;
  final List<StudyTaskModel> sessions;
  const DaySchedule({required this.day, required this.date, required this.sessions});
  factory DaySchedule.fromMap(Map<String, dynamic> m) => DaySchedule(
      day: m['day'] ?? 1, date: m['date'] ?? '',
      sessions: (m['sessions'] as List? ?? []).map((s) => StudyTaskModel.fromMap(s as Map<String, dynamic>)).toList());
  Map<String, dynamic> toMap() => {'day': day, 'date': date, 'sessions': sessions.map((s) => s.toMap()).toList()};
}

class StudyPlanModel {
  final String id, examDate;
  final int totalDays, dailyHours;
  final List<String> subjects;
  final List<DaySchedule> schedule;
  final DateTime createdAt;
  const StudyPlanModel({required this.id, required this.examDate, required this.totalDays,
    required this.dailyHours, required this.subjects, required this.schedule, required this.createdAt});
  factory StudyPlanModel.fromMap(Map<String, dynamic> m) => StudyPlanModel(
      id: m['id'] ?? '', examDate: m['exam_date'] ?? '', totalDays: m['total_days'] ?? 0,
      dailyHours: m['daily_hours'] ?? 5, subjects: List<String>.from(m['subjects'] ?? []),
      schedule: (m['schedule'] as List? ?? []).map((d) => DaySchedule.fromMap(d as Map<String, dynamic>)).toList(),
      createdAt: _parseDate(m['createdAt']));

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  Map<String, dynamic> toMap() => {'id': id, 'exam_date': examDate, 'total_days': totalDays,
    'daily_hours': dailyHours, 'subjects': subjects, 'schedule': schedule.map((d) => d.toMap()).toList()};

  String get displayTitle =>
      subjects.isEmpty ? 'Study Plan' : '${subjects.join(', ')} Plan';

  double get completionRate {
    final sessions = schedule.expand((d) => d.sessions).toList();
    if (sessions.isEmpty) return 0;
    final done = sessions.where((s) => s.isCompleted).length;
    return done / sessions.length;
  }

  int get completedTaskCount =>
      schedule.expand((d) => d.sessions).where((s) => s.isCompleted).length;

  int get totalTaskCount => schedule.expand((d) => d.sessions).length;
}
