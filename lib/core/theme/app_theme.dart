/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import '../models/app_theme.dart';

class AppTheme {
  /// Obter tema claro baseado no tipo de tema
  static ThemeData getLightTheme(AppThemeType themeType) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.getPrimaryColor(themeType),
        secondary: AppColors.secondary,
        surface: AppColors.getLightSurfaceColor(themeType),
        background: AppColors.getLightBackgroundColor(themeType),
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.getLightTextPrimaryColor(themeType),
        onBackground: AppColors.getLightTextPrimaryColor(themeType),
        onError: Colors.white,
      ),

      // Configuração da tipografia
      textTheme: _buildTextTheme(AppColors.getLightTextPrimaryColor(themeType)),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.getLightBackgroundColor(themeType),
        foregroundColor: AppColors.getLightTextPrimaryColor(themeType),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.getLightTextPrimaryColor(themeType),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.getPrimaryColor(themeType),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.getPrimaryColor(themeType),
          side: BorderSide(color: AppColors.getPrimaryColor(themeType)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.getPrimaryColor(themeType),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.getLightSurfaceColor(themeType),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: AppColors.getLightBorderColor(themeType)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: AppColors.getLightBorderColor(themeType)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: AppColors.getPrimaryColor(themeType), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Dividers
      dividerTheme: DividerThemeData(
        color: AppColors.getLightBorderColor(themeType),
        space: 1,
        thickness: 1,
      ),

      // Navigation Rail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.sidebarBackground,
        selectedIconTheme: IconThemeData(
            color: AppColors.getPrimaryColor(themeType), size: 24),
        unselectedIconTheme: IconThemeData(
          color: AppColors.getLightTextSecondaryColor(themeType),
          size: 24,
        ),
        selectedLabelTextStyle:
            TextStyle(color: AppColors.getPrimaryColor(themeType)),
        unselectedLabelTextStyle: TextStyle(
          color: AppColors.getLightTextSecondaryColor(themeType),
        ),
      ),

      // Lista
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.getLightSurfaceColor(themeType),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.getPrimaryColor(themeType),
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Switch e Checkbox
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.getPrimaryColor(themeType);
          }
          return AppColors.getLightTextSecondaryColor(themeType);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.getPrimaryColor(themeType).withOpacity(0.3);
          }
          return AppColors.getLightBorderColor(themeType);
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.getPrimaryColor(themeType);
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
      ),

      // Data Table
      dataTableTheme: DataTableThemeData(
        headingRowColor: MaterialStatePropertyAll(AppColors.databaseHeader),
        dataRowColor: MaterialStatePropertyAll(AppColors.databaseRow),
        columnSpacing: 16,
        horizontalMargin: 16,
        headingTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.getLightTextPrimaryColor(themeType),
        ),
      ),
    );
  }

  /// Obter tema escuro baseado no tipo de tema
  static ThemeData getDarkTheme(AppThemeType themeType) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.getPrimaryColor(themeType),
        secondary: AppColors.secondary,
        surface: AppColors.getDarkSurfaceColor(themeType),
        background: AppColors.getDarkBackgroundColor(themeType),
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.getDarkTextPrimaryColor(themeType),
        onBackground: AppColors.getDarkTextPrimaryColor(themeType),
        onError: Colors.white,
      ),

      // Configuração da tipografia
      textTheme: _buildTextTheme(AppColors.getDarkTextPrimaryColor(themeType)),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.getDarkBackgroundColor(themeType),
        foregroundColor: AppColors.getDarkTextPrimaryColor(themeType),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.getDarkTextPrimaryColor(themeType),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.getPrimaryColor(themeType),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.getPrimaryColor(themeType),
          side: BorderSide(color: AppColors.getPrimaryColor(themeType)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.getPrimaryColor(themeType),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.getDarkSurfaceColor(themeType),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: AppColors.getDarkBorderColor(themeType)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: AppColors.getDarkBorderColor(themeType)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: AppColors.getPrimaryColor(themeType), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Dividers
      dividerTheme: DividerThemeData(
        color: AppColors.getDarkBorderColor(themeType),
        space: 1,
        thickness: 1,
      ),

      // Navigation Rail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.sidebarBackgroundDark,
        selectedIconTheme: IconThemeData(
            color: AppColors.getPrimaryColor(themeType), size: 24),
        unselectedIconTheme: IconThemeData(
          color: AppColors.getDarkTextSecondaryColor(themeType),
          size: 24,
        ),
        selectedLabelTextStyle:
            TextStyle(color: AppColors.getPrimaryColor(themeType)),
        unselectedLabelTextStyle:
            TextStyle(color: AppColors.getDarkTextSecondaryColor(themeType)),
      ),

      // Lista
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.getDarkSurfaceColor(themeType),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.getPrimaryColor(themeType),
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Switch e Checkbox
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.getPrimaryColor(themeType);
          }
          return AppColors.getDarkTextSecondaryColor(themeType);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.getPrimaryColor(themeType).withOpacity(0.3);
          }
          return AppColors.getDarkBorderColor(themeType);
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.getPrimaryColor(themeType);
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
      ),

      // Data Table
      dataTableTheme: DataTableThemeData(
        headingRowColor: MaterialStatePropertyAll(AppColors.databaseHeaderDark),
        dataRowColor: MaterialStatePropertyAll(AppColors.databaseRowDark),
        columnSpacing: 16,
        horizontalMargin: 16,
        headingTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.getDarkTextPrimaryColor(themeType),
        ),
      ),
    );
  }

  // Métodos de compatibilidade para manter o tema atual funcionando
  static ThemeData get lightTheme => getLightTheme(AppThemeType.classic);
  static ThemeData get darkTheme => getDarkTheme(AppThemeType.classic);

  static TextTheme _buildTextTheme(Color textColor) {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }
}
