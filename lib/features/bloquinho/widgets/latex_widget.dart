/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/theme_provider.dart';

class LaTeXWidget extends ConsumerWidget {
  final String latex;
  final bool isBlock;
  final double? fontSize;
  final Color? textColor;
  final String? matrixType; // Novo: tipo de matriz (2x2, 3x3, etc.)

  const LaTeXWidget({
    super.key,
    required this.latex,
    this.isBlock = false,
    this.fontSize,
    this.textColor,
    this.matrixType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final color = textColor ??
        (isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    try {
      // Limpar e processar o LaTeX
      String processedLatex = latex.trim();
      
      // Remover quebras de linha desnecessárias em fórmulas de bloco
      if (isBlock) {
        processedLatex = processedLatex.replaceAll(RegExp(r'\s+'), ' ');
      }

      final mathWidget = Math.tex(
        processedLatex,
        textStyle: TextStyle(
          color: color,
          fontSize: fontSize ?? (isBlock ? 20 : 16),
        ),
        mathStyle: isBlock ? MathStyle.display : MathStyle.text,
      );

      if (isBlock) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode 
                ? AppColors.darkSurface.withOpacity(0.3) 
                : AppColors.lightSurface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode 
                  ? AppColors.darkBorder.withOpacity(0.3) 
                  : AppColors.lightBorder.withOpacity(0.5),
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: mathWidget,
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: mathWidget,
      );
    } catch (e) {
      // Fallback para LaTeX inválido
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Text(
          'Erro LaTeX: $latex',
          style: TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
      );
    }
  }

// No enhanced_markdown_preview_widget.dart
  Widget _buildCustomMath(String latex, {bool isBlock = false}) {
    try {
      return LaTeXWidget(
        latex: latex,
        isBlock: isBlock,
        fontSize: isBlock ? 18 : 16,
      );
    } catch (e) {
      // Fallback para LaTeX inválido
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Text(
          'Erro LaTeX: $latex',
          style: const TextStyle(
            color: Colors.red,
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ),
      );
    }
  }

  /// Templates pré-definidos para matrizes
  static const Map<String, String> matrixTemplates = {
    'matrix-2x2': r'\begin{pmatrix} a & b \\ c & d \end{pmatrix}',
    'matrix-3x3':
        r'\begin{pmatrix} a & b & c \\ d & e & f \\ g & h & i \end{pmatrix}',
    'matrix-4x4':
        r'\begin{pmatrix} a & b & c & d \\ e & f & g & h \\ i & j & k & l \\ m & n & o & p \end{pmatrix}',
    'determinant-2x2': r'\begin{vmatrix} a & b \\ c & d \end{vmatrix}',
    'determinant-3x3':
        r'\begin{vmatrix} a & b & c \\ d & e & f \\ g & h & i \end{vmatrix}',
    'system-2x2': r'\begin{cases} ax + by = c \\ dx + ey = f \end{cases}',
    'system-3x3':
        r'\begin{cases} ax + by + cz = d \\ ex + fy + gz = h \\ ix + jy + kz = l \end{cases}',
    'integral': r'\int_{a}^{b} f(x) \, dx',
    'derivative': r'\frac{d}{dx} f(x)',
    'partial': r'\frac{\partial}{\partial x} f(x,y)',
    'limit': r'\lim_{x \to \infty} f(x)',
    'sum': r'\sum_{i=1}^{n} x_i',
    'product': r'\prod_{i=1}^{n} x_i',
    'fraction': r'\frac{a}{b}',
    'sqrt': r'\sqrt{x}',
    'root': r'\sqrt[n]{x}',
    'power': r'x^n',
    'subscript': r'x_n',
    'vector': r'\vec{v} = \begin{pmatrix} x \\ y \\ z \end{pmatrix}',
    'matrix-brackets': r'\begin{bmatrix} a & b \\ c & d \end{bmatrix}',
    'matrix-braces': r'\begin{Bmatrix} a & b \\ c & d \end{Bmatrix}',
  };

  /// Cria um widget LaTeX com template pré-definido
  static LaTeXWidget fromTemplate(
    String templateName, {
    bool isBlock = true,
    double? fontSize,
    Color? textColor,
  }) {
    final template = matrixTemplates[templateName];
    if (template == null) {
      throw ArgumentError('Template "$templateName" não encontrado');
    }

    return LaTeXWidget(
      latex: template,
      isBlock: isBlock,
      fontSize: fontSize,
      textColor: textColor,
      matrixType: templateName,
    );
  }

  /// Lista todos os templates disponíveis
  static List<String> get availableTemplates => matrixTemplates.keys.toList();

  /// Verifica se o LaTeX é válido
  static bool isValidLaTeX(String latex) {
    try {
      // Teste básico - tentar criar um widget Math
      Math.tex(latex);
      return true;
    } catch (e) {
      return false;
    }
  }

// Regex para matemática em bloco ($$...$$)
  static final RegExp _mathBlockRegex = RegExp(
    r'\$\$\s*([\s\S]*?)\s*\$\$',
    multiLine: true,
  );

// Regex para matemática inline ($...$)
  static final RegExp _mathInlineRegex = RegExp(
    r'\$(?!\$)(.*?)\$',
    multiLine: true,
  );

  String _processMathContent(String content) {
    // Processar blocos de matemática primeiro
    content = content.replaceAllMapped(_mathBlockRegex, (match) {
      final latex = match.group(1)?.trim() ?? '';
      return '<math-block>$latex</math-block>';
    });

    // Processar matemática inline
    content = content.replaceAllMapped(_mathInlineRegex, (match) {
      final latex = match.group(1)?.trim() ?? '';
      return '<math-inline>$latex</math-inline>';
    });
    return content;
  }

  /// Formata LaTeX para melhor legibilidade
  static String formatLaTeX(String latex) {
    // Remove espaços extras
    latex = latex.trim();

    // Adiciona espaços em operadores se não existirem
    latex = latex.replaceAllMapped(RegExp(r'([a-zA-Z0-9])([+\-*/=])'),
        (match) => '${match.group(1)} ${match.group(2)}');

    return latex;
  }
}
