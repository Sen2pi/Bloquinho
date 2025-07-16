/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bloquinho/core/services/data_directory_service.dart';
import 'package:bloquinho/core/models/app_theme.dart';
import 'package:bloquinho/core/theme/app_theme.dart' as theme;

class ThemeNotifier extends StateNotifier<AppThemeConfig> {
  static const String _themeConfigKey = 'theme_config';
  Box? _box;

  ThemeNotifier() : super(AppThemeConfig.defaultConfig()) {
    _initHive();
  }

  Future<void> _initHive() async {
    try {
      // Hive já foi inicializado globalmente
      final dataDir = await DataDirectoryService().initialize();
      final dbPath = await DataDirectoryService().getBasePath();
      _box = await Hive.openBox('app_settings', path: dbPath);

      // Carregar configuração de tema salva
      final savedConfigJson = _box!.get(_themeConfigKey);
      if (savedConfigJson != null) {
        try {
          final savedConfig = AppThemeConfig.fromJson(
              Map<String, dynamic>.from(savedConfigJson));
          state = savedConfig;
        } catch (e) {
          // Se houver erro ao carregar, usar configuração padrão
          state = AppThemeConfig.defaultConfig();
        }
      } else {
        // Se não houver configuração salva, usar padrão
        state = AppThemeConfig.defaultConfig();
      }
    } catch (e) {
      // Em caso de erro, usar configuração padrão
      state = AppThemeConfig.defaultConfig();
    }
  }

  Future<void> _ensureBoxIsOpen() async {
    if (_box == null || !_box!.isOpen) {
      try {
        final dataDir = await DataDirectoryService().initialize();
        final dbPath = await DataDirectoryService().getBasePath();
        _box = await Hive.openBox('app_settings', path: dbPath);
      } catch (e) {
        // Se não conseguir abrir o box, criar um novo
        final dataDir = await DataDirectoryService().initialize();
        final dbPath = await DataDirectoryService().getBasePath();
        await Hive.deleteBoxFromDisk('app_settings', path: dbPath);
        _box = await Hive.openBox('app_settings', path: dbPath);
      }
    }
  }

  /// Definir tipo de tema
  Future<void> setThemeType(AppThemeType themeType) async {
    try {
      final newConfig = state.copyWith(themeType: themeType);
      state = newConfig;

      // Garantir que o box está aberto antes de salvar
      await _ensureBoxIsOpen();

      // Salvar configuração
      await _box!.put(_themeConfigKey, newConfig.toJson());
    } catch (e) {
      // Em caso de erro, não alterar o estado
    }
  }

  /// Definir modo de tema (light/dark/system)
  Future<void> setThemeMode(ThemeMode themeMode) async {
    try {
      final newConfig = state.copyWith(themeMode: themeMode);
      state = newConfig;

      // Garantir que o box está aberto antes de salvar
      await _ensureBoxIsOpen();

      // Salvar configuração
      await _box!.put(_themeConfigKey, newConfig.toJson());
    } catch (e) {
      // Em caso de erro, não alterar o estado
    }
  }

  /// Definir configuração completa de tema
  Future<void> setThemeConfig(AppThemeConfig config) async {
    try {
      state = config;

      // Garantir que o box está aberto antes de salvar
      await _ensureBoxIsOpen();

      // Salvar configuração
      await _box!.put(_themeConfigKey, config.toJson());
    } catch (e) {
      // Em caso de erro, não alterar o estado
    }
  }

  /// Resetar para configuração padrão
  Future<void> resetToDefault() async {
    await setThemeConfig(AppThemeConfig.defaultConfig());
  }

  // Métodos de compatibilidade para manter o sistema atual funcionando
  Future<void> setTheme(ThemeMode themeMode) async {
    await setThemeMode(themeMode);
  }

  /// Alternar entre tema claro e escuro
  Future<void> toggleTheme() async {
    final currentMode = state.themeMode;
    final newMode = currentMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Obter o modo de tema atual (para compatibilidade)
  ThemeMode get themeMode => state.themeMode;

  /// Obter o tipo de tema atual
  AppThemeType get themeType => state.themeType;
}

/// Provider para configuração de tema
final themeConfigProvider =
    StateNotifierProvider<ThemeNotifier, AppThemeConfig>((ref) {
  return ThemeNotifier();
});

/// Provider para modo de tema (compatibilidade)
final themeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeConfigProvider).themeMode;
});

/// Provider para tipo de tema
final themeTypeProvider = Provider<AppThemeType>((ref) {
  return ref.watch(themeConfigProvider).themeType;
});

/// Provider para verificar se é tema escuro
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeProvider);
  final brightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  switch (themeMode) {
    case ThemeMode.light:
      return false;
    case ThemeMode.dark:
      return true;
    case ThemeMode.system:
      return brightness == Brightness.dark;
  }
});

/// Provider para obter tema atual baseado na configuração
final currentThemeProvider = Provider<ThemeData>((ref) {
  final config = ref.watch(themeConfigProvider);
  final isDark = ref.watch(isDarkModeProvider);

  if (isDark) {
    return theme.AppTheme.getDarkTheme(config.themeType);
  } else {
    return theme.AppTheme.getLightTheme(config.themeType);
  }
});

/// Provider para obter tema claro atual
final lightThemeProvider = Provider<ThemeData>((ref) {
  final config = ref.watch(themeConfigProvider);
  return theme.AppTheme.getLightTheme(config.themeType);
});

/// Provider para obter tema escuro atual
final darkThemeProvider = Provider<ThemeData>((ref) {
  final config = ref.watch(themeConfigProvider);
  return theme.AppTheme.getDarkTheme(config.themeType);
});
