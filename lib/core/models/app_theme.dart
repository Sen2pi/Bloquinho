/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';

/// Enum para tipos de tema disponíveis
enum AppThemeType {
  classic,    // Tema clássico (atual)
  modern,     // Tema moderno
  minimal,    // Tema minimalista
  colorful,   // Tema colorido
  professional, // Tema profissional
  creative,   // Tema criativo
  nature,     // Tema natureza
  tech;       // Tema tecnológico

  /// Nome legível do tema
  String get displayName {
    switch (this) {
      case AppThemeType.classic:
        return 'Clássico';
      case AppThemeType.modern:
        return 'Moderno';
      case AppThemeType.minimal:
        return 'Minimalista';
      case AppThemeType.colorful:
        return 'Colorido';
      case AppThemeType.professional:
        return 'Profissional';
      case AppThemeType.creative:
        return 'Criativo';
      case AppThemeType.nature:
        return 'Natureza';
      case AppThemeType.tech:
        return 'Tecnológico';
    }
  }

  /// Descrição do tema
  String get description {
    switch (this) {
      case AppThemeType.classic:
        return 'Tema clássico com cores tradicionais';
      case AppThemeType.modern:
        return 'Design moderno e limpo';
      case AppThemeType.minimal:
        return 'Interface minimalista e focada';
      case AppThemeType.colorful:
        return 'Cores vibrantes e energéticas';
      case AppThemeType.professional:
        return 'Aparência profissional e elegante';
      case AppThemeType.creative:
        return 'Inspirado na criatividade';
      case AppThemeType.nature:
        return 'Cores inspiradas na natureza';
      case AppThemeType.tech:
        return 'Estilo tecnológico e futurista';
    }
  }

  /// Ícone do tema
  IconData get icon {
    switch (this) {
      case AppThemeType.classic:
        return Icons.style;
      case AppThemeType.modern:
        return Icons.design_services;
      case AppThemeType.minimal:
        return Icons.crop_square;
      case AppThemeType.colorful:
        return Icons.palette;
      case AppThemeType.professional:
        return Icons.business;
      case AppThemeType.creative:
        return Icons.brush;
      case AppThemeType.nature:
        return Icons.eco;
      case AppThemeType.tech:
        return Icons.computer;
    }
  }

  /// Verificar se é o tema padrão
  bool get isDefault {
    return this == AppThemeType.classic;
  }
}

/// Configuração de tema da aplicação
class AppThemeConfig {
  final AppThemeType themeType;
  final ThemeMode themeMode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppThemeConfig({
    required this.themeType,
    required this.themeMode,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Criar configuração padrão
  factory AppThemeConfig.defaultConfig() {
    final now = DateTime.now();
    return AppThemeConfig(
      themeType: AppThemeType.classic,
      themeMode: ThemeMode.light,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Criar cópia com alterações
  AppThemeConfig copyWith({
    AppThemeType? themeType,
    ThemeMode? themeMode,
    DateTime? updatedAt,
  }) {
    return AppThemeConfig(
      themeType: themeType ?? this.themeType,
      themeMode: themeMode ?? this.themeMode,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'themeType': themeType.name,
      'themeMode': themeMode.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Criar a partir de JSON
  factory AppThemeConfig.fromJson(Map<String, dynamic> json) {
    return AppThemeConfig(
      themeType: AppThemeType.values.firstWhere(
        (e) => e.name == json['themeType'],
        orElse: () => AppThemeType.classic,
      ),
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => ThemeMode.light,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
} 