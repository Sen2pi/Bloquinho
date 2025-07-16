/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import '../models/app_theme.dart';

class AppColors {
  // Cores primárias azuis (tema clássico)
  static const Color primary = Color(0xFF2563EB); // Azul primário
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // Cores secundárias
  static const Color secondary = Color(0xFF64748B);
  static const Color accent = Color(0xFF0EA5E9);

  // Cores de sucesso, aviso e erro
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // === TEMA CLÁSSICO (ATUAL) ===
  // Modo claro (tons de bege/castanho)
  static const Color lightBackground = Color(0xFFF5E9DA); // Bege claro
  static const Color lightSurface = Color(0xFFFFF8F2); // Creme
  static const Color lightCardBackground =
      Color(0xFFFFF3E6); // Bege mais escuro
  static const Color lightBorder = Color(0xFFD2B48C); // Castanho claro
  static const Color lightTextPrimary = Color(0xFF5C4033); // Castanho escuro
  static const Color lightTextSecondary = Color(0xFF8B6F4E); // Castanho médio
  static const Color lightTextTertiary =
      Color(0xFFBFA074); // Bege/castanho claro
  static const Color lightDivider = Color(0xFFD2B48C); // Castanho claro
  static const Color lightHover = Color(0xFFFFF3E6); // Bege mais escuro
  static const Color lightPressed = Color(0xFFEAD7C0); // Bege pressionado

  // Modo escuro
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCardBackground = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF475569);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF64748B);
  static const Color darkDivider = Color(0xFF475569);
  static const Color darkHover = Color(0xFF475569);
  static const Color darkPressed = Color(0xFF334155);

  // === TEMA MODERNO ===
  static const Color modernPrimary = Color(0xFF6366F1); // Indigo
  static const Color modernLightBackground = Color(0xFFFAFAFA);
  static const Color modernLightSurface = Color(0xFFFFFFFF);
  static const Color modernLightBorder = Color(0xFFE5E7EB);
  static const Color modernLightTextPrimary = Color(0xFF111827);
  static const Color modernLightTextSecondary = Color(0xFF6B7280);
  static const Color modernDarkBackground = Color(0xFF111827);
  static const Color modernDarkSurface = Color(0xFF1F2937);
  static const Color modernDarkBorder = Color(0xFF374151);
  static const Color modernDarkTextPrimary = Color(0xFFF9FAFB);
  static const Color modernDarkTextSecondary = Color(0xFFD1D5DB);

  // === TEMA MINIMAL ===
  static const Color minimalPrimary = Color(0xFF000000); // Preto
  static const Color minimalLightBackground = Color(0xFFFFFFFF);
  static const Color minimalLightSurface = Color(0xFFF8F9FA);
  static const Color minimalLightBorder = Color(0xFFE9ECEF);
  static const Color minimalLightTextPrimary = Color(0xFF212529);
  static const Color minimalLightTextSecondary = Color(0xFF6C757D);
  static const Color minimalDarkBackground = Color(0xFF000000);
  static const Color minimalDarkSurface = Color(0xFF1A1A1A);
  static const Color minimalDarkBorder = Color(0xFF2D2D2D);
  static const Color minimalDarkTextPrimary = Color(0xFFFFFFFF);
  static const Color minimalDarkTextSecondary = Color(0xFFB0B0B0);

  // === TEMA COLORIDO ===
  static const Color colorfulPrimary = Color(0xFFEC4899); // Rosa
  static const Color colorfulLightBackground = Color(0xFFFFF0F6);
  static const Color colorfulLightSurface = Color(0xFFFFF8FC);
  static const Color colorfulLightBorder = Color(0xFFFFB3D1);
  static const Color colorfulLightTextPrimary = Color(0xFF831843);
  static const Color colorfulLightTextSecondary = Color(0xFFBE185D);
  static const Color colorfulDarkBackground = Color(0xFF1F0B1A);
  static const Color colorfulDarkSurface = Color(0xFF2D1B2D);
  static const Color colorfulDarkBorder = Color(0xFF4C1D4C);
  static const Color colorfulDarkTextPrimary = Color(0xFFFCE7F3);
  static const Color colorfulDarkTextSecondary = Color(0xFFF9A8D4);

  // === TEMA PROFISSIONAL ===
  static const Color professionalPrimary = Color(0xFF1E40AF); // Azul escuro
  static const Color professionalLightBackground = Color(0xFFF8FAFC);
  static const Color professionalLightSurface = Color(0xFFFFFFFF);
  static const Color professionalLightBorder = Color(0xFFCBD5E1);
  static const Color professionalLightTextPrimary = Color(0xFF1E293B);
  static const Color professionalLightTextSecondary = Color(0xFF64748B);
  static const Color professionalDarkBackground = Color(0xFF0F172A);
  static const Color professionalDarkSurface = Color(0xFF1E293B);
  static const Color professionalDarkBorder = Color(0xFF334155);
  static const Color professionalDarkTextPrimary = Color(0xFFF1F5F9);
  static const Color professionalDarkTextSecondary = Color(0xFFCBD5E1);

  // === TEMA CRIATIVO ===
  static const Color creativePrimary = Color(0xFF8B5CF6); // Roxo
  static const Color creativeLightBackground = Color(0xFFFAF5FF);
  static const Color creativeLightSurface = Color(0xFFFFF8FF);
  static const Color creativeLightBorder = Color(0xFFE9D5FF);
  static const Color creativeLightTextPrimary = Color(0xFF581C87);
  static const Color creativeLightTextSecondary = Color(0xFF7C3AED);
  static const Color creativeDarkBackground = Color(0xFF1A0B2E);
  static const Color creativeDarkSurface = Color(0xFF2D1B4E);
  static const Color creativeDarkBorder = Color(0xFF4C1D7A);
  static const Color creativeDarkTextPrimary = Color(0xFFF3E8FF);
  static const Color creativeDarkTextSecondary = Color(0xFFC4B5FD);

  // === TEMA NATUREZA ===
  static const Color naturePrimary = Color(0xFF059669); // Verde esmeralda
  static const Color natureLightBackground = Color(0xFFF0FDF4);
  static const Color natureLightSurface = Color(0xFFF7FEF9);
  static const Color natureLightBorder = Color(0xFFBBF7D0);
  static const Color natureLightTextPrimary = Color(0xFF064E3B);
  static const Color natureLightTextSecondary = Color(0xFF047857);
  static const Color natureDarkBackground = Color(0xFF0A1F0A);
  static const Color natureDarkSurface = Color(0xFF1A2E1A);
  static const Color natureDarkBorder = Color(0xFF2D4A2D);
  static const Color natureDarkTextPrimary = Color(0xFFD1FAE5);
  static const Color natureDarkTextSecondary = Color(0xFFA7F3D0);

  // === TEMA TECNOLÓGICO ===
  static const Color techPrimary = Color(0xFF06B6D4); // Ciano
  static const Color techLightBackground = Color(0xFFF0FDFA);
  static const Color techLightSurface = Color(0xFFF7FEFC);
  static const Color techLightBorder = Color(0xFFA5F3FC);
  static const Color techLightTextPrimary = Color(0xFF164E63);
  static const Color techLightTextSecondary = Color(0xFF0891B2);
  static const Color techDarkBackground = Color(0xFF0A1A1F);
  static const Color techDarkSurface = Color(0xFF1A2A2F);
  static const Color techDarkBorder = Color(0xFF2D4A4F);
  static const Color techDarkTextPrimary = Color(0xFFCFFAFE);
  static const Color techDarkTextSecondary = Color(0xFFA5F3FC);

  // === TEMA PÔR DO SOL ===
  static const Color sunsetPrimary = Color(0xFFFF6B35); // Laranja
  static const Color sunsetLightBackground = Color(0xFFFFF5F0);
  static const Color sunsetLightSurface = Color(0xFFFFF8F5);
  static const Color sunsetLightBorder = Color(0xFFFFB366);
  static const Color sunsetLightTextPrimary = Color(0xFF7C2D12);
  static const Color sunsetLightTextSecondary = Color(0xFFEA580C);
  static const Color sunsetDarkBackground = Color(0xFF1F0A00);
  static const Color sunsetDarkSurface = Color(0xFF2D1500);
  static const Color sunsetDarkBorder = Color(0xFF4C2500);
  static const Color sunsetDarkTextPrimary = Color(0xFFFEF3C7);
  static const Color sunsetDarkTextSecondary = Color(0xFFFCD34D);

  // === TEMA OCEANO ===
  static const Color oceanPrimary = Color(0xFF0891B2); // Azul oceano
  static const Color oceanLightBackground = Color(0xFFF0F9FF);
  static const Color oceanLightSurface = Color(0xFFF7FCFF);
  static const Color oceanLightBorder = Color(0xFFA5F3FC);
  static const Color oceanLightTextPrimary = Color(0xFF164E63);
  static const Color oceanLightTextSecondary = Color(0xFF0891B2);
  static const Color oceanDarkBackground = Color(0xFF0A1A1F);
  static const Color oceanDarkSurface = Color(0xFF1A2A2F);
  static const Color oceanDarkBorder = Color(0xFF2D4A4F);
  static const Color oceanDarkTextPrimary = Color(0xFFCFFAFE);
  static const Color oceanDarkTextSecondary = Color(0xFFA5F3FC);

  // === TEMA FLORESTA ===
  static const Color forestPrimary = Color(0xFF059669); // Verde floresta
  static const Color forestLightBackground = Color(0xFFF0FDF4);
  static const Color forestLightSurface = Color(0xFFF7FEF9);
  static const Color forestLightBorder = Color(0xFFBBF7D0);
  static const Color forestLightTextPrimary = Color(0xFF064E3B);
  static const Color forestLightTextSecondary = Color(0xFF047857);
  static const Color forestDarkBackground = Color(0xFF0A1F0A);
  static const Color forestDarkSurface = Color(0xFF1A2E1A);
  static const Color forestDarkBorder = Color(0xFF2D4A2D);
  static const Color forestDarkTextPrimary = Color(0xFFD1FAE5);
  static const Color forestDarkTextSecondary = Color(0xFFA7F3D0);

  // === TEMA DESERTO ===
  static const Color desertPrimary = Color(0xFFD97706); // Amarelo deserto
  static const Color desertLightBackground = Color(0xFFFFFBEB);
  static const Color desertLightSurface = Color(0xFFFFFDF5);
  static const Color desertLightBorder = Color(0xFFFDE68A);
  static const Color desertLightTextPrimary = Color(0xFF78350F);
  static const Color desertLightTextSecondary = Color(0xFFB45309);
  static const Color desertDarkBackground = Color(0xFF1F0A00);
  static const Color desertDarkSurface = Color(0xFF2D1500);
  static const Color desertDarkBorder = Color(0xFF4C2500);
  static const Color desertDarkTextPrimary = Color(0xFFFEF3C7);
  static const Color desertDarkTextSecondary = Color(0xFFFCD34D);

  // === TEMA MEIA-NOITE ===
  static const Color midnightPrimary = Color(0xFF7C3AED); // Roxo meia-noite
  static const Color midnightLightBackground = Color(0xFFFAF5FF);
  static const Color midnightLightSurface = Color(0xFFFFF8FF);
  static const Color midnightLightBorder = Color(0xFFE9D5FF);
  static const Color midnightLightTextPrimary = Color(0xFF581C87);
  static const Color midnightLightTextSecondary = Color(0xFF7C3AED);
  static const Color midnightDarkBackground = Color(0xFF1A0B2E);
  static const Color midnightDarkSurface = Color(0xFF2D1B4E);
  static const Color midnightDarkBorder = Color(0xFF4C1D7A);
  static const Color midnightDarkTextPrimary = Color(0xFFF3E8FF);
  static const Color midnightDarkTextSecondary = Color(0xFFC4B5FD);

  // === TEMA AURORA ===
  static const Color auroraPrimary = Color(0xFFEC4899); // Rosa aurora
  static const Color auroraLightBackground = Color(0xFFFFF0F6);
  static const Color auroraLightSurface = Color(0xFFFFF8FC);
  static const Color auroraLightBorder = Color(0xFFFFB3D1);
  static const Color auroraLightTextPrimary = Color(0xFF831843);
  static const Color auroraLightTextSecondary = Color(0xFFBE185D);
  static const Color auroraDarkBackground = Color(0xFF1F0B1A);
  static const Color auroraDarkSurface = Color(0xFF2D1B2D);
  static const Color auroraDarkBorder = Color(0xFF4C1D4C);
  static const Color auroraDarkTextPrimary = Color(0xFFFCE7F3);
  static const Color auroraDarkTextSecondary = Color(0xFFF9A8D4);

  // === TEMA CYBERPUNK ===
  static const Color cyberpunkPrimary = Color(0xFF00FF88); // Verde neon
  static const Color cyberpunkLightBackground = Color(0xFF0A0A0A);
  static const Color cyberpunkLightSurface = Color(0xFF1A1A1A);
  static const Color cyberpunkLightBorder = Color(0xFF00FF88);
  static const Color cyberpunkLightTextPrimary = Color(0xFF00FF88);
  static const Color cyberpunkLightTextSecondary = Color(0xFF00CC6A);
  static const Color cyberpunkDarkBackground = Color(0xFF000000);
  static const Color cyberpunkDarkSurface = Color(0xFF0A0A0A);
  static const Color cyberpunkDarkBorder = Color(0xFF00FF88);
  static const Color cyberpunkDarkTextPrimary = Color(0xFF00FF88);
  static const Color cyberpunkDarkTextSecondary = Color(0xFF00CC6A);

  // === TEMA VINTAGE ===
  static const Color vintagePrimary = Color(0xFF8B4513); // Marrom vintage
  static const Color vintageLightBackground = Color(0xFFF5F5DC);
  static const Color vintageLightSurface = Color(0xFFFAFAF0);
  static const Color vintageLightBorder = Color(0xFFD2B48C);
  static const Color vintageLightTextPrimary = Color(0xFF654321);
  static const Color vintageLightTextSecondary = Color(0xFF8B4513);
  static const Color vintageDarkBackground = Color(0xFF2F1B0A);
  static const Color vintageDarkSurface = Color(0xFF3D2B1A);
  static const Color vintageDarkBorder = Color(0xFF5D4B3A);
  static const Color vintageDarkTextPrimary = Color(0xFFF5DEB3);
  static const Color vintageDarkTextSecondary = Color(0xFFDEB887);

  // Cores especiais para blocos e editor
  static const Color blockBackground = Color(0xFFF1F5F9);
  static const Color blockBackgroundDark = Color(0xFF1E293B);
  static const Color blockBorder = Color(0xFFE2E8F0);
  static const Color blockBorderDark = Color(0xFF475569);

  // Cores para diferentes tipos de blocos
  static const Color textBlockBg = Color(0xFFFFFFFF);
  static const Color headingBlockBg = Color(0xFFF8FAFC);
  static const Color codeBlockBg = Color(0xFF1E293B);
  static const Color quoteBlockBg = Color(0xFFF0F9FF);
  static const Color tableBlockBg = Color(0xFFFFFFFF);
  static const Color imageBlockBg = Color(0xFFF8FAFC);

  // Versões escuras dos blocos
  static const Color textBlockBgDark = Color(0xFF334155);
  static const Color headingBlockBgDark = Color(0xFF1E293B);
  static const Color codeBlockBgDark = Color(0xFF0F172A);
  static const Color quoteBlockBgDark = Color(0xFF1E293B);
  static const Color tableBlockBgDark = Color(0xFF334155);
  static const Color imageBlockBgDark = Color(0xFF1E293B);

  // Cores para sidebar e navegação
  static const Color sidebarBackground = Color(0xFFF8FAFC);
  static const Color sidebarBackgroundDark = Color(0xFF1E293B);
  static const Color sidebarItemHover = Color(0xFFE2E8F0);
  static const Color sidebarItemHoverDark = Color(0xFF334155);
  static const Color sidebarItemActive = Color(0xFF2563EB);

  // Cores para database e tabelas
  static const Color databaseHeader = Color(0xFFF1F5F9);
  static const Color databaseHeaderDark = Color(0xFF1E293B);
  static const Color databaseRow = Color(0xFFFFFFFF);
  static const Color databaseRowDark = Color(0xFF334155);
  static const Color databaseRowAlternate = Color(0xFFF8FAFC);
  static const Color databaseRowAlternateDark = Color(0xFF475569);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [lightBackground, lightSurface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    colors: [darkBackground, darkSurface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // === MÉTODOS PARA OBTER CORES POR TEMA ===

  /// Obter cor primária baseada no tipo de tema
  static Color getPrimaryColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.classic:
        return primary;
      case AppThemeType.modern:
        return modernPrimary;
      case AppThemeType.minimal:
        return minimalPrimary;
      case AppThemeType.colorful:
        return colorfulPrimary;
      case AppThemeType.professional:
        return professionalPrimary;
      case AppThemeType.creative:
        return creativePrimary;
      case AppThemeType.nature:
        return naturePrimary;
      case AppThemeType.tech:
        return techPrimary;
      case AppThemeType.sunset:
        return sunsetPrimary;
      case AppThemeType.ocean:
        return oceanPrimary;
      case AppThemeType.forest:
        return forestPrimary;
      case AppThemeType.desert:
        return desertPrimary;
      case AppThemeType.midnight:
        return midnightPrimary;
      case AppThemeType.aurora:
        return auroraPrimary;
      case AppThemeType.cyberpunk:
        return cyberpunkPrimary;
      case AppThemeType.vintage:
        return vintagePrimary;
    }
  }

  /// Obter cor de fundo clara baseada no tipo de tema
  static Color getLightBackgroundColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.classic:
        return lightBackground;
      case AppThemeType.modern:
        return modernLightBackground;
      case AppThemeType.minimal:
        return minimalLightBackground;
      case AppThemeType.colorful:
        return colorfulLightBackground;
      case AppThemeType.professional:
        return professionalLightBackground;
      case AppThemeType.creative:
        return creativeLightBackground;
      case AppThemeType.nature:
        return natureLightBackground;
      case AppThemeType.tech:
        return techLightBackground;
      case AppThemeType.sunset:
        return sunsetLightBackground;
      case AppThemeType.ocean:
        return oceanLightBackground;
      case AppThemeType.forest:
        return forestLightBackground;
      case AppThemeType.desert:
        return desertLightBackground;
      case AppThemeType.midnight:
        return midnightLightBackground;
      case AppThemeType.aurora:
        return auroraLightBackground;
      case AppThemeType.cyberpunk:
        return cyberpunkLightBackground;
      case AppThemeType.vintage:
        return vintageLightBackground;
    }
  }

  /// Obter cor de superfície clara baseada no tipo de tema
  static Color getLightSurfaceColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.classic:
        return lightSurface;
      case AppThemeType.modern:
        return modernLightSurface;
      case AppThemeType.minimal:
        return minimalLightSurface;
      case AppThemeType.colorful:
        return colorfulLightSurface;
      case AppThemeType.professional:
        return professionalLightSurface;
      case AppThemeType.creative:
        return creativeLightSurface;
      case AppThemeType.nature:
        return natureLightSurface;
      case AppThemeType.tech:
        return techLightSurface;
      case AppThemeType.sunset:
        return sunsetLightSurface;
      case AppThemeType.ocean:
        return oceanLightSurface;
      case AppThemeType.forest:
        return forestLightSurface;
      case AppThemeType.desert:
        return desertLightSurface;
      case AppThemeType.midnight:
        return midnightLightSurface;
      case AppThemeType.aurora:
        return auroraLightSurface;
      case AppThemeType.cyberpunk:
        return cyberpunkLightSurface;
      case AppThemeType.vintage:
        return vintageLightSurface;
    }
  }

  /// Obter cor de borda clara baseada no tipo de tema
  static Color getLightBorderColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.classic:
        return lightBorder;
      case AppThemeType.modern:
        return modernLightBorder;
      case AppThemeType.minimal:
        return minimalLightBorder;
      case AppThemeType.colorful:
        return colorfulLightBorder;
      case AppThemeType.professional:
        return professionalLightBorder;
      case AppThemeType.creative:
        return creativeLightBorder;
      case AppThemeType.nature:
        return natureLightBorder;
      case AppThemeType.tech:
        return techLightBorder;
      case AppThemeType.sunset:
        return sunsetLightBorder;
      case AppThemeType.ocean:
        return oceanLightBorder;
      case AppThemeType.forest:
        return forestLightBorder;
      case AppThemeType.desert:
        return desertLightBorder;
      case AppThemeType.midnight:
        return midnightLightBorder;
      case AppThemeType.aurora:
        return auroraLightBorder;
      case AppThemeType.cyberpunk:
        return cyberpunkLightBorder;
      case AppThemeType.vintage:
        return vintageLightBorder;
    }
  }

  /// Obter cor de texto primário claro baseada no tipo de tema
  static Color getLightTextPrimaryColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.classic:
        return lightTextPrimary;
      case AppThemeType.modern:
        return modernLightTextPrimary;
      case AppThemeType.minimal:
        return minimalLightTextPrimary;
      case AppThemeType.colorful:
        return colorfulLightTextPrimary;
      case AppThemeType.professional:
        return professionalLightTextPrimary;
      case AppThemeType.creative:
        return creativeLightTextPrimary;
      case AppThemeType.nature:
        return natureLightTextPrimary;
      case AppThemeType.tech:
        return techLightTextPrimary;
      case AppThemeType.sunset:
        return sunsetLightTextPrimary;
      case AppThemeType.ocean:
        return oceanLightTextPrimary;
      case AppThemeType.forest:
        return forestLightTextPrimary;
      case AppThemeType.desert:
        return desertLightTextPrimary;
      case AppThemeType.midnight:
        return midnightLightTextPrimary;
      case AppThemeType.aurora:
        return auroraLightTextPrimary;
      case AppThemeType.cyberpunk:
        return cyberpunkLightTextPrimary;
      case AppThemeType.vintage:
        return vintageLightTextPrimary;
    }
  }

  /// Obter cor de texto secundário claro baseada no tipo de tema
  static Color getLightTextSecondaryColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.classic:
        return lightTextSecondary;
      case AppThemeType.modern:
        return modernLightTextSecondary;
      case AppThemeType.minimal:
        return minimalLightTextSecondary;
      case AppThemeType.colorful:
        return colorfulLightTextSecondary;
      case AppThemeType.professional:
        return professionalLightTextSecondary;
      case AppThemeType.creative:
        return creativeLightTextSecondary;
      case AppThemeType.nature:
        return natureLightTextSecondary;
      case AppThemeType.tech:
        return techLightTextSecondary;
      case AppThemeType.sunset:
        return sunsetLightTextSecondary;
      case AppThemeType.ocean:
        return oceanLightTextSecondary;
      case AppThemeType.forest:
        return forestLightTextSecondary;
      case AppThemeType.desert:
        return desertLightTextSecondary;
      case AppThemeType.midnight:
        return midnightLightTextSecondary;
      case AppThemeType.aurora:
        return auroraLightTextSecondary;
      case AppThemeType.cyberpunk:
        return cyberpunkLightTextSecondary;
      case AppThemeType.vintage:
        return vintageLightTextSecondary;
    }
  }

  /// Obter cor de fundo escura baseada no tipo de tema
  static Color getDarkBackgroundColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.classic:
        return darkBackground;
      case AppThemeType.modern:
        return modernDarkBackground;
      case AppThemeType.minimal:
        return minimalDarkBackground;
      case AppThemeType.colorful:
        return colorfulDarkBackground;
      case AppThemeType.professional:
        return professionalDarkBackground;
      case AppThemeType.creative:
        return creativeDarkBackground;
      case AppThemeType.nature:
        return natureDarkBackground;
      case AppThemeType.tech:
        return techDarkBackground;
      case AppThemeType.sunset:
        return sunsetDarkBackground;
      case AppThemeType.ocean:
        return oceanDarkBackground;
      case AppThemeType.forest:
        return forestDarkBackground;
      case AppThemeType.desert:
        return desertDarkBackground;
      case AppThemeType.midnight:
        return midnightDarkBackground;
      case AppThemeType.aurora:
        return auroraDarkBackground;
      case AppThemeType.cyberpunk:
        return cyberpunkDarkBackground;
      case AppThemeType.vintage:
        return vintageDarkBackground;
    }
  }

  /// Obter cor de superfície escura baseada no tipo de tema
  static Color getDarkSurfaceColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.classic:
        return darkSurface;
      case AppThemeType.modern:
        return modernDarkSurface;
      case AppThemeType.minimal:
        return minimalDarkSurface;
      case AppThemeType.colorful:
        return colorfulDarkSurface;
      case AppThemeType.professional:
        return professionalDarkSurface;
      case AppThemeType.creative:
        return creativeDarkSurface;
      case AppThemeType.nature:
        return natureDarkSurface;
      case AppThemeType.tech:
        return techDarkSurface;
      case AppThemeType.sunset:
        return sunsetDarkSurface;
      case AppThemeType.ocean:
        return oceanDarkSurface;
      case AppThemeType.forest:
        return forestDarkSurface;
      case AppThemeType.desert:
        return desertDarkSurface;
      case AppThemeType.midnight:
        return midnightDarkSurface;
      case AppThemeType.aurora:
        return auroraDarkSurface;
      case AppThemeType.cyberpunk:
        return cyberpunkDarkSurface;
      case AppThemeType.vintage:
        return vintageDarkSurface;
    }
  }

  /// Obter cor de borda escura baseada no tipo de tema
  static Color getDarkBorderColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.classic:
        return darkBorder;
      case AppThemeType.modern:
        return modernDarkBorder;
      case AppThemeType.minimal:
        return minimalDarkBorder;
      case AppThemeType.colorful:
        return colorfulDarkBorder;
      case AppThemeType.professional:
        return professionalDarkBorder;
      case AppThemeType.creative:
        return creativeDarkBorder;
      case AppThemeType.nature:
        return natureDarkBorder;
      case AppThemeType.tech:
        return techDarkBorder;
      case AppThemeType.sunset:
        return sunsetDarkBorder;
      case AppThemeType.ocean:
        return oceanDarkBorder;
      case AppThemeType.forest:
        return forestDarkBorder;
      case AppThemeType.desert:
        return desertDarkBorder;
      case AppThemeType.midnight:
        return midnightDarkBorder;
      case AppThemeType.aurora:
        return auroraDarkBorder;
      case AppThemeType.cyberpunk:
        return cyberpunkDarkBorder;
      case AppThemeType.vintage:
        return vintageDarkBorder;
    }
  }

  /// Obter cor de texto primário escuro baseada no tipo de tema
  static Color getDarkTextPrimaryColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.classic:
        return darkTextPrimary;
      case AppThemeType.modern:
        return modernDarkTextPrimary;
      case AppThemeType.minimal:
        return minimalDarkTextPrimary;
      case AppThemeType.colorful:
        return colorfulDarkTextPrimary;
      case AppThemeType.professional:
        return professionalDarkTextPrimary;
      case AppThemeType.creative:
        return creativeDarkTextPrimary;
      case AppThemeType.nature:
        return natureDarkTextPrimary;
      case AppThemeType.tech:
        return techDarkTextPrimary;
      case AppThemeType.sunset:
        return sunsetDarkTextPrimary;
      case AppThemeType.ocean:
        return oceanDarkTextPrimary;
      case AppThemeType.forest:
        return forestDarkTextPrimary;
      case AppThemeType.desert:
        return desertDarkTextPrimary;
      case AppThemeType.midnight:
        return midnightDarkTextPrimary;
      case AppThemeType.aurora:
        return auroraDarkTextPrimary;
      case AppThemeType.cyberpunk:
        return cyberpunkDarkTextPrimary;
      case AppThemeType.vintage:
        return vintageDarkTextPrimary;
    }
  }

  /// Obter cor de texto secundário escuro baseada no tipo de tema
  static Color getDarkTextSecondaryColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.classic:
        return darkTextSecondary;
      case AppThemeType.modern:
        return modernDarkTextSecondary;
      case AppThemeType.minimal:
        return minimalDarkTextSecondary;
      case AppThemeType.colorful:
        return colorfulDarkTextSecondary;
      case AppThemeType.professional:
        return professionalDarkTextSecondary;
      case AppThemeType.creative:
        return creativeDarkTextSecondary;
      case AppThemeType.nature:
        return natureDarkTextSecondary;
      case AppThemeType.tech:
        return techDarkTextSecondary;
      case AppThemeType.sunset:
        return sunsetDarkTextSecondary;
      case AppThemeType.ocean:
        return oceanDarkTextSecondary;
      case AppThemeType.forest:
        return forestDarkTextSecondary;
      case AppThemeType.desert:
        return desertDarkTextSecondary;
      case AppThemeType.midnight:
        return midnightDarkTextSecondary;
      case AppThemeType.aurora:
        return auroraDarkTextSecondary;
      case AppThemeType.cyberpunk:
        return cyberpunkDarkTextSecondary;
      case AppThemeType.vintage:
        return vintageDarkTextSecondary;
    }
  }
}
