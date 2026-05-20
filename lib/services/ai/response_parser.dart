import 'dart:convert';
import '../../models/study_plan.dart';
import '../../models/study_task_model.dart';

class ResponseParser {
  static StudyPlanModel? parseStudyPlan(String raw) {
    try {
      final payload = _decodeJsonPayload(raw);
      if (payload == null) return null;

      final plan = _resolvePlanMap(payload);
      if (plan == null) return null;

      final schedule = _parseSchedule(plan['schedule'] ?? plan['days']).map((day) {
        final sessions = _parseSessions(day['sessions'] ?? day['tasks'] ?? day['items'])
            .map(_sessionFromMap)
            .where((s) => s.subject.isNotEmpty || s.topic.isNotEmpty)
            .toList();
        return DaySchedule(
          day: _toInt(day['day']) ?? 1,
          date: _str(day['date']),
          sessions: sessions,
        );
      }).where((d) => d.sessions.isNotEmpty).toList();

      if (schedule.isEmpty) return null;

      return StudyPlanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        examDate: _str(plan['exam_date'] ?? plan['examDate']),
        totalDays: _toInt(plan['total_days'] ?? plan['totalDays']) ?? schedule.length,
        dailyHours: _toInt(plan['daily_hours'] ?? plan['dailyHours']) ?? 5,
        subjects: _parseSubjects(plan['subjects']),
        schedule: schedule,
        createdAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  static StudyTaskModel _sessionFromMap(dynamic raw) {
    final sm = _asMap(raw);
    return StudyTaskModel(
      id: _str(sm['id']).isEmpty ? DateTime.now().microsecondsSinceEpoch.toString() : _str(sm['id']),
      subject: _str(sm['subject'] ?? sm['subject_name']),
      topic: _str(sm['topic'] ?? sm['title'] ?? sm['name']),
      durationMinutes: _toInt(sm['duration_minutes'] ?? sm['durationMinutes'] ?? sm['duration']) ?? 60,
      difficulty: _str(sm['difficulty']).isEmpty ? 'medium' : _str(sm['difficulty']),
      tip: _str(sm['tip'] ?? sm['study_tip'] ?? sm['notes']),
    );
  }

  static Map<String, dynamic>? _decodeJsonPayload(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'```json|```', multiLine: true), '').trim();

    final direct = _tryParseMap(cleaned);
    if (direct != null) return direct;

    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start != -1 && end > start) {
      final clipped = cleaned.substring(start, end + 1);
      final clippedMap = _tryParseMap(clipped);
      if (clippedMap != null) return clippedMap;
    }

    return _tryParseMap(_repairTruncatedJson(cleaned));
  }

  static Map<String, dynamic>? _tryParseMap(String source) {
    if (source.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(source);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}

    final closed = _closeOpenBrackets(source);
    if (closed != source) {
      try {
        final decoded = jsonDecode(closed);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }

    return null;
  }

  static String _repairTruncatedJson(String raw) {
    var work = raw.trim();
    if (work.isEmpty) return work;

    // Drop a trailing incomplete object inside an array.
    final trailingBroken = RegExp(r',\s*\{[^}]*$');
    if (trailingBroken.hasMatch(work)) {
      work = work.replaceFirst(trailingBroken, '');
    }

    if (!work.endsWith('}') && !work.endsWith(']')) {
      final lastObjectEnd = work.lastIndexOf('}');
      if (lastObjectEnd != -1) work = work.substring(0, lastObjectEnd + 1);
    }

    return _closeOpenBrackets(work);
  }

  static String _closeOpenBrackets(String input) {
    final stack = <String>[];
    var inString = false;
    var escaped = false;

    for (var i = 0; i < input.length; i++) {
      final ch = input[i];
      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (ch == r'\') {
          escaped = true;
        } else if (ch == '"') {
          inString = false;
        }
        continue;
      }

      if (ch == '"') {
        inString = true;
        continue;
      }
      if (ch == '{') stack.add('}');
      if (ch == '[') stack.add(']');
      if (ch == '}' || ch == ']') {
        if (stack.isNotEmpty && stack.last == ch) stack.removeLast();
      }
    }

    final buffer = StringBuffer(input);
    for (var i = stack.length - 1; i >= 0; i--) {
      buffer.write(stack[i]);
    }
    return buffer.toString();
  }

  static Map<String, dynamic>? _resolvePlanMap(Map<String, dynamic> payload) {
    const wrapperKeys = [
      'student_plan',
      'study_plan',
      'studyPlan',
      'studentPlan',
      'plan',
      'data',
      'result',
    ];

    for (final key in wrapperKeys) {
      final nested = payload[key];
      if (nested is Map<String, dynamic>) {
        if (_hasSchedule(nested)) return nested;
        final inner = _resolvePlanMap(nested);
        if (inner != null) return inner;
      } else if (nested is Map) {
        final map = Map<String, dynamic>.from(nested);
        if (_hasSchedule(map)) return map;
        final inner = _resolvePlanMap(map);
        if (inner != null) return inner;
      }
    }

    if (_hasSchedule(payload)) return payload;
    return _findPlanMapDeep(payload);
  }

  static bool _hasSchedule(Map<String, dynamic> map) =>
      map['schedule'] is List || map['days'] is List;

  static Map<String, dynamic>? _findPlanMapDeep(Map<String, dynamic> node, [int depth = 0]) {
    if (depth > 4) return null;
    if (_hasSchedule(node)) return node;

    for (final value in node.values) {
      if (value is Map<String, dynamic>) {
        final found = _findPlanMapDeep(value, depth + 1);
        if (found != null) return found;
      } else if (value is Map) {
        final found = _findPlanMapDeep(Map<String, dynamic>.from(value), depth + 1);
        if (found != null) return found;
      }
    }
    return null;
  }

  static List<Map<String, dynamic>> _parseSchedule(dynamic value) {
    if (value is! List) return const [];
    return value.map(_asMap).where((m) => m.isNotEmpty).toList();
  }

  static List<Map<String, dynamic>> _parseSessions(dynamic value) {
    if (value is! List) return const [];
    return value.map(_asMap).where((m) => m.isNotEmpty).toList();
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  static List<String> _parseSubjects(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return const [];
  }

  static String _str(dynamic value) => value?.toString().trim() ?? '';

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
