import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage/local_storage_service.dart';

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) { _load(); }
  Future<void> _load() async { state = await LocalStorageService.isDarkTheme(); }
  Future<void> toggle() async {
    state = !state;
    await LocalStorageService.setDarkTheme(state);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((_) => ThemeNotifier());
