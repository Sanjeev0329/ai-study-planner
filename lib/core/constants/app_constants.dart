class ApiConstants {
  static const geminiApiKey = 'AIzaSyAGntG90ZYP0WgFEvSfGGpYK0W2s2rtpXo';
  static const _base =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  static String get geminiEndpoint => '$_base?key=$geminiApiKey';
}