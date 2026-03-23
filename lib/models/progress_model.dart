class ProgressModel {
  final String userId;
  final Map<String, int> completedPerSubject, totalPerSubject;
  final int currentStreak, totalMinutesStudied;
  final List<String> completedDates;
  const ProgressModel({required this.userId, required this.completedPerSubject,
    required this.totalPerSubject, required this.currentStreak,
    required this.totalMinutesStudied, required this.completedDates});
  factory ProgressModel.empty(String uid) =>
      ProgressModel(userId: uid, completedPerSubject: {}, totalPerSubject: {},
          currentStreak: 0, totalMinutesStudied: 0, completedDates: []);
  factory ProgressModel.fromMap(Map<String, dynamic> m) => ProgressModel(
      userId: m['userId'] ?? '',
      completedPerSubject: Map<String, int>.from(m['completedPerSubject'] ?? {}),
      totalPerSubject: Map<String, int>.from(m['totalPerSubject'] ?? {}),
      currentStreak: m['currentStreak'] ?? 0,
      totalMinutesStudied: m['totalMinutesStudied'] ?? 0,
      completedDates: List<String>.from(m['completedDates'] ?? []));
  Map<String, dynamic> toMap() => {'userId': userId, 'completedPerSubject': completedPerSubject,
    'totalPerSubject': totalPerSubject, 'currentStreak': currentStreak,
    'totalMinutesStudied': totalMinutesStudied, 'completedDates': completedDates};
  double completionPercent(String subject) {
    final total = totalPerSubject[subject] ?? 0;
    if (total == 0) return 0;
    return (completedPerSubject[subject] ?? 0) / total;
  }
}
