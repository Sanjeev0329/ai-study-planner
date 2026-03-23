import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../models/ai_plan_request_model.dart';
import '../../models/ai_plan_response_model.dart';
import 'prompt_builder.dart';
import 'response_parser.dart';

class GeminiService {
  Future<AiPlanResponseModel> generateStudyPlan(AiPlanRequestModel request) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConstants.geminiEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': PromptBuilder.buildStudyPlanPrompt(request)}]}],
          'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 4000},
        }),
      ).timeout(const Duration(seconds: 30));
      if (res.statusCode != 200) return AiPlanResponseModel.failure('API error: \${res.statusCode}');
      final data = jsonDecode(res.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
      final plan = ResponseParser.parseStudyPlan(text);
      if (plan == null) return AiPlanResponseModel.failure('Failed to parse response');
      return AiPlanResponseModel(plan: plan);
    } catch (e) {
      return AiPlanResponseModel.failure(e.toString());
    }
  }

  Future<String> chat(String message, String planContext) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConstants.geminiEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': PromptBuilder.buildChatPrompt(message, planContext)}]}],
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 300},
        }),
      ).timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) return 'Sorry, could not respond.';
      final data = jsonDecode(res.body);
      return data['candidates'][0]['content']['parts'][0]['text'] as String;
    } catch (_) { return 'Sorry, something went wrong.'; }
  }
}
