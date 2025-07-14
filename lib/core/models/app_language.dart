/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';

/// Idiomas suportados pela aplicação
enum AppLanguage {
  portuguese('pt', 'BR', 'Português', '🇵🇹'),
  english('en', 'US', 'English', '🇺🇸'),
  french('fr', 'FR', 'Français', '🇫🇷');

  const AppLanguage(
      this.languageCode, this.countryCode, this.displayName, this.flag);

  final String languageCode;
  final String countryCode;
  final String displayName;
  final String flag;

  /// Obter Locale do idioma
  Locale get locale => Locale(languageCode, countryCode);

  /// Obter idioma padrão
  static AppLanguage get defaultLanguage => AppLanguage.portuguese;

  /// Obter idioma a partir do locale
  static AppLanguage fromLocale(Locale locale) {
    for (final language in AppLanguage.values) {
      if (language.languageCode == locale.languageCode) {
        return language;
      }
    }
    return defaultLanguage;
  }

  /// Obter todos os locales suportados
  static List<Locale> get supportedLocales {
    return AppLanguage.values.map((lang) => lang.locale).toList();
  }
}
