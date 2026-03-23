class StudyTaskModel {
  final String id, subject, topic, difficulty, tip;
  final int durationMinutes;
  bool isCompleted;
  StudyTaskModel({required this.id, required this.subject, required this.topic,
    required this.durationMinutes, required this.difficulty, required this.tip, this.isCompleted = false});
  factory StudyTaskModel.fromMap(Map<String, dynamic> m) => StudyTaskModel(
      id: m['id']?.toString() ?? '', subject: m['subject'] ?? '', topic: m['topic'] ?? '',
      durationMinutes: m['duration_minutes'] ?? 60, difficulty: m['difficulty'] ?? 'medium',
      tip: m['tip'] ?? '', isCompleted: m['isCompleted'] ?? false);
  Map<String, dynamic> toMap() => {'id': id, 'subject': subject, 'topic': topic,
    'duration_minutes': durationMinutes, 'difficulty': difficulty, 'tip': tip, 'isCompleted': isCompleted};
  StudyTaskModel copyWith({bool? isCompleted}) => StudyTaskModel(
      id: id, subject: subject, topic: topic, durationMinutes: durationMinutes,
      difficulty: difficulty, tip: tip, isCompleted: isCompleted ?? this.isCompleted);
}
