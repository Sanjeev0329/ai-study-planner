import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static final String geminiApiKey =
      dotenv.env['GEMINI_API_KEY'] ?? '';

  static const String _base =
      'https://generativelanguage.googleapis.com/v1beta/models';

  static const List<String> geminiModelCandidates = [
    'gemini-2.0-flash',
    'gemini-1.5-flash-latest',
    'gemini-2.5-flash',
  ];

  static String geminiEndpointForModel(String model) =>
      '$_base/$model:generateContent?key=$geminiApiKey';
}
