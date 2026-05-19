class ApiConstants {
  static const geminiApiKey = 'AIzaSyCEowc1J8FPbbeEOy6jQfnwPmxHhZ5sFdw';
  static const _base = 'https://generativelanguage.googleapis.com/v1beta/models';

  // Ordered by preference; service will fallback when a model is unavailable.
  static const geminiModelCandidates = <String>[
    'gemini-2.0-flash',
    'gemini-1.5-flash-latest',
    'gemini-2.5-flash',
  ];

  static String geminiEndpointForModel(String model) =>
      '$_base/$model:generateContent?key=$geminiApiKey';
}
