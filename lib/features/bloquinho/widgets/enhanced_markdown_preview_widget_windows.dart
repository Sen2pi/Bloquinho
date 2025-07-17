/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/html_enhancement_parser.dart';
import 'advanced_code_block.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
// Windows version - no webview_flutter support
import 'dynamic_colored_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'simple_diagram_widget.dart';
import 'windows_code_block_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'latex_widget.dart';
import 'mermaid_diagram_widget.dart';
import '../../../core/utils/lru_cache.dart';
import '../../../core/services/enhanced_markdown_parser.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'dart:io';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

/// Widget de visualização markdown com enhancements HTML moderno
/// Windows version - simplified without webview_flutter
class EnhancedMarkdownPreviewWidget extends ConsumerWidget {
  final String markdown;
  final bool showLineNumbers;
  final bool enableHtmlEnhancements;
  final TextStyle? baseTextStyle;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final bool showScrollbar;
  final ScrollPhysics? scrollPhysics;

  // Cache otimizado para markdown processado
  static final LRUCache<int, String> _markdownCache = LRUCache(maxSize: 100);
  static final LRUCache<int, Widget> _widgetCache = LRUCache(maxSize: 50);

  EnhancedMarkdownPreviewWidget({
    super.key,
    required this.markdown,
    this.showLineNumbers = false,
    this.enableHtmlEnhancements = true,
    this.baseTextStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
    this.backgroundColor,
    this.showScrollbar = true,
    this.scrollPhysics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textStyle = baseTextStyle ?? theme.textTheme.bodyMedium!;
    final isDark = theme.brightness == Brightness.dark;
    final containerColor =
        backgroundColor ?? (isDark ? Colors.transparent : Colors.white);

    // Sanitizar markdown inteiro antes de processar
    final sanitizedMarkdown = sanitizeUtf16(markdown);

    // Cache de widget completo baseado em hash do conteúdo + configurações
    final cacheKey = _generateWidgetCacheKey(isDark);
    final cachedWidget = _widgetCache.get(cacheKey);
    if (cachedWidget != null) return cachedWidget;

    final widget = Container(
      color: containerColor,
      child: Stack(
        children: [
          Scrollbar(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: padding,
                  sliver: SliverToBoxAdapter(
                    child: SelectionArea(
                      child: _buildOptimizedMarkdown(context, textStyle, ref, sanitizedMarkdown),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Botões de ação otimizados
          _buildOptimizedActionButtons(context, isDark, ref),
        ],
      ),
    );

    // Cache do widget completo
    _widgetCache.put(cacheKey, widget);
    return widget;
  }

  /// Gerar chave de cache para widget
  int _generateWidgetCacheKey(bool isDark) {
    return Object.hash(
      markdown.hashCode,
      showLineNumbers.hashCode,
      enableHtmlEnhancements.hashCode,
      baseTextStyle.hashCode,
      backgroundColor.hashCode,
      isDark.hashCode,
    );
  }

  /// Botões de ação otimizados com RepaintBoundary
  Widget _buildOptimizedActionButtons(
      BuildContext context, bool isDark, WidgetRef ref) {
    return Positioned(
      top: 8,
      right: 8,
      child: RepaintBoundary(
        child: Row(
          children: [
            // Botão de cópia formatada
            _buildActionButton(
              icon: Icons.copy,
              tooltip: 'Copiar texto formatado',
              onPressed: () => _copyFormattedText(context),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  /// Botão de ação reutilizável
  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white70 : Colors.grey[600],
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _copyFormattedText(BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: markdown));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Texto copiado para a área de transferência!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao copiar texto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Construir markdown otimizado
  Widget _buildOptimizedMarkdown(BuildContext context, TextStyle textStyle,
      WidgetRef ref, String sanitizedMarkdown) {
    // Cache de markdown processado
    final cacheKey = sanitizedMarkdown.hashCode;
    final cachedMarkdown = _markdownCache.get(cacheKey);
    final processedMarkdown =
        cachedMarkdown ?? _processMarkdown(sanitizedMarkdown);

    if (cachedMarkdown == null) {
      _markdownCache.put(cacheKey, processedMarkdown);
    }

    return Markdown(
      data: processedMarkdown,
      styleSheet: _buildMarkdownStyleSheet(textStyle),
      builders: _buildMarkdownBuilders(context, ref),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  /// Processar markdown com enhancements
  String _processMarkdown(String rawMarkdown) {
    if (!enableHtmlEnhancements) return rawMarkdown;

    // Windows version - simplified processing
    return rawMarkdown;
  }

  /// Construir style sheet para markdown
  MarkdownStyleSheet _buildMarkdownStyleSheet(TextStyle baseStyle) {
    return MarkdownStyleSheet(
      h1: baseStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: baseStyle.color,
      ),
      h2: baseStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: baseStyle.color,
      ),
      h3: baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: baseStyle.color,
      ),
      h4: baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: baseStyle.color,
      ),
      h5: baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: baseStyle.color,
      ),
      h6: baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: baseStyle.color,
      ),
      p: baseStyle,
      strong: baseStyle.copyWith(fontWeight: FontWeight.bold),
      em: baseStyle.copyWith(fontStyle: FontStyle.italic),
      code: baseStyle.copyWith(
        fontFamily: 'monospace',
        backgroundColor: Colors.grey.withOpacity(0.2),
      ),
      codeblockDecoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      blockquote: baseStyle.copyWith(
        fontStyle: FontStyle.italic,
        color: Colors.grey[600],
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.blue, width: 4),
        ),
        color: Colors.blue.withOpacity(0.1),
      ),
      listBullet: baseStyle,
      tableHead: baseStyle.copyWith(fontWeight: FontWeight.bold),
      tableBody: baseStyle,
    );
  }

  /// Construir builders customizados para markdown
  Map<String, MarkdownElementBuilder> _buildMarkdownBuilders(
      BuildContext context, WidgetRef ref) {
    return {
      'code': CodeElementBuilder(),
      'pre': PreElementBuilder(),
      'math': MathElementBuilder(),
      'diagram': DiagramElementBuilder(),
      'latex': LatexElementBuilder(),
      'mermaid': MermaidElementBuilder(),
      'colored': ColoredTextElementBuilder(),
      'kbd': KbdElementBuilder(),
      'mark': MarkElementBuilder(),
      'sub': SubscriptElementBuilder(),
      'sup': SuperscriptElementBuilder(),
    };
  }
}

/// Remove caracteres inválidos de UTF-16 para evitar crash do Flutter
String sanitizeUtf16(String input) {
  return input.replaceAll(
      RegExp(
          r'([^ -\uD7FF\uE000-\uFFFF]|[\uD800-\uDBFF](?![\uDC00-\uDFFF])|(?<![\uD800-\uDBFF])[\uDC00-\uDFFF])'),
      '');
}

/// Builder para elementos de código
class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final code = sanitizeUtf16(element.textContent);
    final language =
        element.attributes['class']?.replaceAll('language-', '') ?? '';

    return AdvancedCodeBlock(
      code: code,
      language: language,
      showLineNumbers: true,
    );
  }
}

/// Builder para elementos pre
class PreElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final code = sanitizeUtf16(element.textContent);
    return WindowsCodeBlockWidget(
      code: code,
      language: '',
      showLineNumbers: true,
    );
  }
}

/// Builder para elementos matemáticos
class MathElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final math = sanitizeUtf16(element.textContent);
    return Math.tex(
      math,
      textStyle: preferredStyle,
      onErrorFallback: (error) => Text('Erro na fórmula: $error'),
    );
  }
}

/// Builder para diagramas
class DiagramElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final diagram = sanitizeUtf16(element.textContent);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Diagrama: $diagram',
        style: preferredStyle,
      ),
    );
  }
}

/// Builder para LaTeX
class LatexElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final latex = sanitizeUtf16(element.textContent);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'LaTeX: $latex',
        style: preferredStyle,
      ),
    );
  }
}

/// Builder para Mermaid
class MermaidElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final mermaid = sanitizeUtf16(element.textContent);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Mermaid: $mermaid',
        style: preferredStyle,
      ),
    );
  }
}

/// Builder para texto colorido
class ColoredTextElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final text = sanitizeUtf16(element.textContent);
    return Text(
      text,
      style: preferredStyle,
    );
  }
}

/// Builder para teclas
class KbdElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final key = sanitizeUtf16(element.textContent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
      ),
      child: Text(
        key,
        style: preferredStyle?.copyWith(
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Builder para marcação
class MarkElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final text = sanitizeUtf16(element.textContent);
    return Container(
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text,
        style: preferredStyle,
      ),
    );
  }
}

/// Builder para subscrito
class SubscriptElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final text = sanitizeUtf16(element.textContent);
    return Text(
      text,
      style: preferredStyle?.copyWith(
        fontSize: (preferredStyle?.fontSize ?? 14) * 0.7,
      ),
    );
  }
}

/// Builder para sobrescrito
class SuperscriptElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final text = sanitizeUtf16(element.textContent);
    return Text(
      text,
      style: preferredStyle?.copyWith(
        fontSize: (preferredStyle?.fontSize ?? 14) * 0.7,
      ),
    );
  }
}
