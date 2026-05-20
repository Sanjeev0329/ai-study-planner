import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../models/ai_plan_request_model.dart';
import '../../models/ai_plan_response_model.dart';
import 'prompt_builder.dart';
import 'response_parser.dart';

class GeminiService {
  static const _maxAttemptsPerModel = 3;
  static const _retryableStatuses = {429, 503};

  static const _studyPlanResponseSchema = {
    'type': 'OBJECT',
    'required': ['student_plan'],
    'properties': {
      'student_plan': {
        'type': 'OBJECT',
        'required': ['exam_date', 'total_days', 'daily_hours', 'subjects', 'schedule'],
        'properties': {
          'exam_date': {'type': 'STRING'},
          'total_days': {'type': 'INTEGER'},
          'daily_hours': {'type': 'INTEGER'},
          'subjects': {
            'type': 'ARRAY',
            'items': {'type': 'STRING'},
          },
          'schedule': {
            'type': 'ARRAY',
            'items': {
              'type': 'OBJECT',
              'required': ['day', 'date', 'sessions'],
              'properties': {
                'day': {'type': 'INTEGER'},
                'date': {'type': 'STRING'},
                'sessions': {
                  'type': 'ARRAY',
                  'items': {
                    'type': 'OBJECT',
                    'required': [
                      'id',
                      'subject',
                      'topic',
                      'duration_minutes',
                      'difficulty',
                      'tip',
                    ],
                    'properties': {
                      'id': {'type': 'STRING'},
                      'subject': {'type': 'STRING'},
                      'topic': {'type': 'STRING'},
                      'duration_minutes': {'type': 'INTEGER'},
                      'difficulty': {'type': 'STRING'},
                      'tip': {'type': 'STRING'},
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
  };

  Future<AiPlanResponseModel> generateStudyPlan(AiPlanRequestModel request) async {
    try {
      final prompt = PromptBuilder.buildStudyPlanPrompt(request);
      var res = await _postWithModelFallback(
        _studyPlanRequestBody(prompt, useSchema: true),
        timeout: const Duration(seconds: 60),
      );
      if (res.statusCode == 400) {
        res = await _postWithModelFallback(
          _studyPlanRequestBody(prompt, useSchema: false),
          timeout: const Duration(seconds: 60),
        );
      }
      if (res.statusCode != 200) {
        return AiPlanResponseModel.failure(_friendlyApiError(res));
      }
      final data = jsonDecode(res.body);
      final text = _extractResponseText(data);
      if (text == null || text.trim().isEmpty) {
        return AiPlanResponseModel.failure('Empty AI response');
      }
      final plan = ResponseParser.parseStudyPlan(text);
      if (plan == null) {
        return AiPlanResponseModel.failure(
          'Could not read the study plan from the AI. Please tap Try Again.',
        );
      }
      return AiPlanResponseModel(plan: plan);
    } catch (e) {
      return AiPlanResponseModel.failure(_friendlyException(e));
    }
  }

  Map<String, dynamic> _studyPlanRequestBody(String prompt, {required bool useSchema}) {
    final config = <String, dynamic>{
      'temperature': 0.2,
      'maxOutputTokens': 8192,
      'responseMimeType': 'application/json',
    };
    if (useSchema) config['responseSchema'] = _studyPlanResponseSchema;

    return {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': config,
    };
  }

  Future<String> chat(String message, String planContext) async {
    try {
      final res = await _postWithModelFallback(
        {
          'contents': [
            {
              'parts': [
                {'text': PromptBuilder.buildChatPrompt(message, planContext)}
              ]
            }
          ],
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 300},
        },
        timeout: const Duration(seconds: 30),
      );
      if (res.statusCode != 200) return _friendlyApiError(res);
      final data = jsonDecode(res.body);
      return _extractResponseText(data) ?? 'Sorry, could not respond.';
    } catch (_) {
      return 'Sorry, something went wrong. Please try again.';
    }
  }

  Future<http.Response> _postWithModelFallback(
    Map<String, dynamic> body, {
    required Duration timeout,
  }) async {
    http.Response? lastResponse;

    for (final model in ApiConstants.geminiModelCandidates) {
      for (var attempt = 0; attempt < _maxAttemptsPerModel; attempt++) {
        final res = await http
            .post(
              Uri.parse(ApiConstants.geminiEndpointForModel(model)),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
            .timeout(timeout);
        lastResponse = res;

        if (res.statusCode == 200) return res;
        if (res.statusCode == 404) break;

        final retryable = _retryableStatuses.contains(res.statusCode);
        if (retryable && attempt < _maxAttemptsPerModel - 1) {
          await Future<void>.delayed(Duration(seconds: 2 * (attempt + 1)));
          continue;
        }
        if (retryable) break;
        return res;
      }
    }

    return lastResponse ??
        http.Response('No Gemini response', 500, request: http.Request('POST', Uri()));
  }

  static String _friendlyApiError(http.Response res) {
    try {
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) {
        final error = data['error'];
        if (error is Map<String, dynamic>) {
          final message = error['message'];
          if (message is String && message.isNotEmpty) return message;
        }
      }
    } catch (_) {}

    if (res.statusCode == 503 || res.statusCode == 429) {
      return 'The AI service is busy right now. Please wait a moment and tap Try Again.';
    }
    return 'Could not reach the AI service (error ${res.statusCode}).';
  }

  static String _friendlyException(Object e) {
    final msg = e.toString();
    if (msg.contains('TimeoutException') || msg.contains('timed out')) {
      return 'The request took too long. Check your connection and try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  String? _extractResponseText(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final candidates = data['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;
    final first = candidates.first;
    if (first is! Map<String, dynamic>) return null;
    final content = first['content'];
    if (content is! Map<String, dynamic>) return null;
    final parts = content['parts'];
    if (parts is! List || parts.isEmpty) return null;

    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is Map<String, dynamic> && part['text'] is String) {
        buffer.write(part['text'] as String);
      }
    }
    final text = buffer.toString().trim();
    return text.isEmpty ? null : text;
  }
}
