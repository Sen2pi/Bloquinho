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

  const LaTeXWidget({
    super.key,
    required this.latex,
    this.isBlock = false,
    this.fontSize,
    this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final color = textColor ??
        (isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    try {
      final mathWidget = Math.tex(
        latex,
        textStyle: TextStyle(
          color: color,
          fontSize: fontSize ?? (isBlock ? 18 : 16),
        ),
        mathStyle: isBlock ? MathStyle.display : MathStyle.text,
      );

      if (isBlock) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Center(child: mathWidget),
        );
      }

      return mathWidget;
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
}
