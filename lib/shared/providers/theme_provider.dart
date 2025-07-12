import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';
  Box? _box;

  ThemeNotifier() : super(ThemeMode.light) {
    _initHive();
  }

  Future<void> _initHive() async {
    try {
      // Hive já foi inicializado globalmente
      _box = await Hive.openBox('app_settings');

      // Carregar tema salvo
      final savedTheme = _box!.get(_themeKey, defaultValue: 'light');
      if (savedTheme == 'dark') {
        state = ThemeMode.dark;
      } else if (savedTheme == 'system') {
        state = ThemeMode.system;
      } else {
        state = ThemeMode.light;
      }
    } catch (e) {
      debugPrint('Erro ao inicializar ThemeProvider: $e');
      // Em caso de erro, usar tema padrão
      state = ThemeMode.light;
    }
  }

  Future<void> _ensureBoxIsOpen() async {
    if (_box == null || !_box!.isOpen) {
      try {
        _box = await Hive.openBox('app_settings');
      } catch (e) {
        debugPrint('Erro ao reabrir box app_settings: $e');
        // Se não conseguir abrir o box, criar um novo
        await Hive.deleteBoxFromDisk('app_settings');
        _box = await Hive.openBox('app_settings');
      }
    }
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    try {
      state = themeMode;

      // Garantir que o box está aberto antes de salvar
      await _ensureBoxIsOpen();

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

      await _box!.put(_themeKey, themeString);
    } catch (e) {
      debugPrint('Erro ao salvar tema: $e');
      // Mesmo com erro ao salvar, manter o estado atual
    }
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
