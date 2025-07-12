import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/models/app_language.dart';
import '../../core/l10n/app_strings.dart';

class LanguageNotifier extends StateNotifier<AppLanguage> {
  static const String _languageKey = 'app_language';
  Box? _box;

  LanguageNotifier() : super(AppLanguage.defaultLanguage) {
    _initHive();
  }

  Future<void> _initHive() async {
    try {
      // Hive já foi inicializado globalmente
      _box = await Hive.openBox('app_settings');

      // Carregar idioma salvo
      final savedLanguageCode = _box!.get(_languageKey, defaultValue: 'pt');
      final savedLanguage = AppLanguage.values.firstWhere(
        (lang) => lang.languageCode == savedLanguageCode,
        orElse: () => AppLanguage.defaultLanguage,
      );

      state = savedLanguage;
    } catch (e) {
      debugPrint('Erro ao inicializar LanguageProvider: $e');
      // Em caso de erro, usar idioma padrão
      state = AppLanguage.defaultLanguage;
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

  Future<void> setLanguage(AppLanguage language) async {
    try {
      state = language;

      // Garantir que o box está aberto antes de salvar
      await _ensureBoxIsOpen();
      await _box!.put(_languageKey, language.languageCode);
    } catch (e) {
      debugPrint('Erro ao salvar idioma: $e');
      // Mesmo com erro ao salvar, manter o estado atual
    }
  }

  /// Obter locale atual
  Locale get currentLocale => state.locale;

  /// Verificar se é idioma padrão
  bool get isDefaultLanguage => state == AppLanguage.defaultLanguage;
}

// Provider do idioma
final languageProvider =
    StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});

// Provider derivado: locale atual
final currentLocaleProvider = Provider<Locale>((ref) {
  return ref.watch(languageProvider).locale;
});

// Provider derivado: nome do idioma atual
final currentLanguageNameProvider = Provider<String>((ref) {
  return ref.watch(languageProvider).displayName;
});

// Provider derivado: bandeira do idioma atual
final currentLanguageFlagProvider = Provider<String>((ref) {
  return ref.watch(languageProvider).flag;
});

// Provider derivado: verificar se é idioma padrão
final isDefaultLanguageProvider = Provider<bool>((ref) {
  return ref.watch(languageProvider) == AppLanguage.defaultLanguage;
});

// Provider derivado: strings localizadas
final appStringsProvider = Provider<AppStrings>((ref) {
  final currentLanguage = ref.watch(languageProvider);
  return AppStringsProvider.of(currentLanguage);
});
