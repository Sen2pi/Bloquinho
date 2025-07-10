import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';
  late Box _box;

  ThemeNotifier() : super(ThemeMode.light) {
    _initHive();
  }

  Future<void> _initHive() async {
    // Hive já foi inicializado globalmente
    _box = await Hive.openBox('app_settings');

    // Carregar tema salvo
    final savedTheme = _box.get(_themeKey, defaultValue: 'light');
    if (savedTheme == 'dark') {
      state = ThemeMode.dark;
    } else if (savedTheme == 'system') {
      state = ThemeMode.system;
    } else {
      state = ThemeMode.light;
    }
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    state = themeMode;

    // Salvar tema
    String themeString;
    switch (themeMode) {
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
      case ThemeMode.light:
      default:
        themeString = 'light';
        break;
    }

    await _box.put(_themeKey, themeString);
  }

  void toggleTheme() {
    if (state == ThemeMode.light) {
      setTheme(ThemeMode.dark);
    } else {
      setTheme(ThemeMode.light);
    }
  }

  bool get isDarkMode => state == ThemeMode.dark;
  bool get isLightMode => state == ThemeMode.light;
  bool get isSystemMode => state == ThemeMode.system;
}

// Provider do tema
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// Provider para verificar se está no modo escuro
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeProvider);
  if (themeMode == ThemeMode.system) {
    // Para modo sistema, precisaríamos do contexto para verificar
    // Por simplicidade, vamos retornar false (claro) como padrão
    return false;
  }
  return themeMode == ThemeMode.dark;
});
