import 'package:flutter/material.dart';

class AppColors {
  // Cores primárias azuis
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
}
