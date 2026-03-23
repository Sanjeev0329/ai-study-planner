import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _planKey      = 'cached_plan';
  static const _onboardedKey = 'is_onboarded';
  static const _themeKey     = 'is_dark_theme';

  static Future<void> cachePlan(Map<String, dynamic> map) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_planKey, jsonEncode(map));
  }

  static Future<Map<String, dynamic>?> getCachedPlan() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_planKey);
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  static Future<void> setOnboarded(bool v) async =>
      (await SharedPreferences.getInstance()).setBool(_onboardedKey, v);

  static Future<bool> isOnboarded() async =>
      (await SharedPreferences.getInstance()).getBool(_onboardedKey) ?? false;

  static Future<void> setDarkTheme(bool v) async =>
      (await SharedPreferences.getInstance()).setBool(_themeKey, v);

  static Future<bool> isDarkTheme() async =>
      (await SharedPreferences.getInstance()).getBool(_themeKey) ?? false;

  static Future<void> clearAll() async =>
      (await SharedPreferences.getInstance()).clear();
}
