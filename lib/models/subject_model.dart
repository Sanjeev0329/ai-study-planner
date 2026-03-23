class SubjectModel {
  final String id, name;
  final bool isDifficult;
  final int priorityLevel;
  const SubjectModel({required this.id, required this.name, this.isDifficult = false, this.priorityLevel = 2});
  factory SubjectModel.fromMap(Map<String, dynamic> m) =>
      SubjectModel(id: m['id'] ?? '', name: m['name'] ?? '', isDifficult: m['isDifficult'] ?? false, priorityLevel: m['priorityLevel'] ?? 2);
  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'isDifficult': isDifficult, 'priorityLevel': priorityLevel};
  SubjectModel copyWith({String? name, bool? isDifficult, int? priorityLevel}) =>
      SubjectModel(id: id, name: name ?? this.name, isDifficult: isDifficult ?? this.isDifficult, priorityLevel: priorityLevel ?? this.priorityLevel);
}
