import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/models/app_language.dart';
import '../../core/l10n/app_strings.dart';

class LanguageNotifier extends StateNotifier<AppLanguage> {
  static const String _languageKey = 'app_language';
  late Box _box;

  LanguageNotifier() : super(AppLanguage.defaultLanguage) {
    _initHive();
  }

  Future<void> _initHive() async {
    // Hive já foi inicializado globalmente
    _box = await Hive.openBox('app_settings');

    // Carregar idioma salvo
    final savedLanguageCode = _box.get(_languageKey, defaultValue: 'pt');
    final savedLanguage = AppLanguage.values.firstWhere(
      (lang) => lang.languageCode == savedLanguageCode,
      orElse: () => AppLanguage.defaultLanguage,
    );

    state = savedLanguage;
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    await _box.put(_languageKey, language.languageCode);
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
