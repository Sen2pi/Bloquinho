/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:screenshot/screenshot.dart';

import '../models/code_theme.dart';
import '../models/bloco_base_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/theme_provider.dart';

/// Widget para renderizar código com syntax highlighting e temas
class CodeHighlightWidget extends ConsumerStatefulWidget {
  final String code;
  final String language;
  final CodeTheme theme;
  final bool showLineNumbers;
  final bool showCopyButton;
  final bool showExportButton;
  final VoidCallback? onCopy;
  final VoidCallback? onExport;

  const CodeHighlightWidget({
    super.key,
    required this.code,
    required this.language,
    required this.theme,
    this.showLineNumbers = true,
    this.showCopyButton = true,
    this.showExportButton = true,
    this.onCopy,
    this.onExport,
  });

  @override
  ConsumerState<CodeHighlightWidget> createState() =>
      _CodeHighlightWidgetState();
}

class _CodeHighlightWidgetState extends ConsumerState<CodeHighlightWidget> {
  late ScrollController _scrollController;
  bool _isHovered = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    return Screenshot(
      controller: _screenshotController,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.theme.borderColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.theme.backgroundColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com ícones de janela e botões sempre visível
            _buildHeader(isDarkMode),
            _buildCodeContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    final language = ProgrammingLanguage.getByCode(widget.language) ??
        ProgrammingLanguage.defaultLanguage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(
            color: widget.theme.borderColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Ícones de janela estilo Mac (vermelho, amarelo, verde)

          // Language info
          Row(
            children: [
              if (language.icon != null)
                Text(
                  language.icon!,
                  style: const TextStyle(fontSize: 18),
                ),
              const SizedBox(width: 8),
              Text(
                language.displayName,
                style: TextStyle(
                  color: widget.theme.headerTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              _buildWindowDot(Colors.red),
              const SizedBox(width: 6),
              _buildWindowDot(Colors.amber),
              const SizedBox(width: 6),
              _buildWindowDot(Colors.green),
              const SizedBox(width: 16),
            ],
          ),
          // Action buttons
          if (widget.showCopyButton)
            _buildActionButton(
              icon: PhosphorIcons.copy(),
              tooltip: 'Copiar código',
              onPressed: _copyCode,
            ),
          if (widget.showExportButton)
            _buildActionButton(
              icon: PhosphorIcons.image(),
              tooltip: 'Exportar como imagem',
              onPressed: _exportAsImage,
            ),
        ],
      ),
    );
  }

  Widget _buildWindowDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isHovered
              ? widget.theme.headerTextColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          tooltip: tooltip,
          color: widget.theme.headerTextColor,
          hoverColor: Colors.transparent,
          padding: const EdgeInsets.all(8),
        ),
      ),
    );
  }

  Widget _buildCodeContent() {
    final lines = widget.code.split('\n');

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent, // Fundo sempre transparente
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showLineNumbers) _buildLineNumbers(lines),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color:
                      Colors.transparent, // Fundo transparente atrás do código
                  child: _buildHighlightedCode(lines),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineNumbers(List<String> lines) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.transparent, // Fundo transparente atrás dos números
        border: Border(
          right: BorderSide(
            color: widget.theme.borderColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: lines.asMap().entries.map((entry) {
          final index = entry.key;
          return Container(
            height: 22,
            alignment: Alignment.centerRight,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: widget.theme.lineNumberColor.withOpacity(0.7),
                fontSize: 12,
                fontFamily: 'Courier',
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHighlightedCode(List<String> lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        return Container(
          height: 22,
          child: _buildHighlightedLine(line),
        );
      }).toList(),
    );
  }

  Widget _buildHighlightedLine(String line) {
    if (line.isEmpty) {
      return const SizedBox(height: 22);
    }

    // Simple syntax highlighting (can be enhanced with a proper parser)
    final highlightedSpans = _highlightSyntax(line);

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: widget.theme.textColor,
          fontSize: 14,
          fontFamily: 'Courier',
          height: 1.5,
        ),
        children: highlightedSpans,
      ),
    );
  }

  List<TextSpan> _highlightSyntax(String line) {
    final spans = <TextSpan>[];
    final words = line.split(' ');

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      Color color = widget.theme.textColor;

      // Simple keyword detection
      if (_isKeyword(word)) {
        color = widget.theme.keywordColor;
      } else if (_isString(word)) {
        color = widget.theme.stringColor;
      } else if (_isNumber(word)) {
        color = widget.theme.numberColor;
      } else if (_isComment(word)) {
        color = widget.theme.commentColor;
      } else if (_isFunction(word)) {
        color = widget.theme.functionColor;
      } else if (_isClass(word)) {
        color = widget.theme.classColor;
      } else if (_isOperator(word)) {
        color = widget.theme.operatorColor;
      } else if (_isPunctuation(word)) {
        color = widget.theme.punctuationColor;
      }

      spans.add(TextSpan(
        text: word,
        style: TextStyle(color: color),
      ));

      // Add space between words (except for the last word)
      if (i < words.length - 1) {
        spans.add(TextSpan(
          text: ' ',
          style: TextStyle(color: widget.theme.textColor),
        ));
      }
    }

    return spans;
  }

  // Simple syntax highlighting rules
  bool _isKeyword(String word) {
    final keywords = [
      'if',
      'else',
      'for',
      'while',
      'do',
      'switch',
      'case',
      'default',
      'break',
      'continue',
      'return',
      'class',
      'struct',
      'enum',
      'interface',
      'public',
      'private',
      'protected',
      'static',
      'final',
      'const',
      'var',
      'let',
      'function',
      'def',
      'import',
      'export',
      'from',
      'as',
      'try',
      'catch',
      'finally',
      'throw',
      'throws',
      'new',
      'delete',
      'typeof',
      'instanceof',
      'void',
      'null',
      'undefined',
      'true',
      'false',
      'this',
      'super',
      'extends',
      'implements',
      'abstract',
      'virtual',
      'override',
      'sealed',
      'readonly',
      'volatile',
      'synchronized',
      'transient',
      'native',
      'strictfp',
      'assert',
      'package',
      'throws',
      'throws',
      'throws',
    ];
    return keywords.contains(word.toLowerCase());
  }

  bool _isString(String word) {
    return (word.startsWith('"') && word.endsWith('"')) ||
        (word.startsWith("'") && word.endsWith("'")) ||
        (word.startsWith('`') && word.endsWith('`'));
  }

  bool _isNumber(String word) {
    return RegExp(r'^\d+\.?\d*$').hasMatch(word) ||
        RegExp(r'^0x[0-9a-fA-F]+$').hasMatch(word) ||
        RegExp(r'^0b[01]+$').hasMatch(word);
  }

  bool _isComment(String word) {
    return word.startsWith('//') ||
        word.startsWith('/*') ||
        word.startsWith('#');
  }

  bool _isFunction(String word) {
    return word.endsWith('()') || word.contains('(');
  }

  bool _isClass(String word) {
    return RegExp(r'^[A-Z][a-zA-Z0-9]*$').hasMatch(word);
  }

  bool _isOperator(String word) {
    final operators = [
      '+',
      '-',
      '*',
      '/',
      '=',
      '==',
      '!=',
      '===',
      '!==',
      '<',
      '>',
      '<=',
      '>=',
      '&&',
      '||',
      '!',
      '&',
      '|',
      '^',
      '<<',
      '>>',
      '>>>',
      '+=',
      '-=',
      '*=',
      '/=',
      '%=',
      '&=',
      '|=',
      '^=',
      '<<=',
      '>>=',
      '>>>=',
      '++',
      '--',
      '?',
      ':',
    ];
    return operators.contains(word);
  }

  bool _isPunctuation(String word) {
    final punctuation = [
      '.',
      ',',
      ';',
      ':',
      '(',
      ')',
      '[',
      ']',
      '{',
      '}',
      '<',
      '>',
      '"',
      "'",
      '`',
      '@',
      '#',
      '%',
      '&',
    ];
    return punctuation.contains(word);
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Código copiado para a área de transferência'),
        backgroundColor: widget.theme.backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
    widget.onCopy?.call();
  }

  void _exportAsImage() async {
    try {
      // Capturar screenshot do widget
      final image = await _screenshotController.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 2.0,
      );

      if (image != null) {
        // Mostrar preview da imagem
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: widget.theme.backgroundColor,
              content: SizedBox(
                width: 600,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Preview da imagem
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: widget.theme.borderColor.withOpacity(0.3),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Botões de ação
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text('Salvar'),
                          onPressed: () async {
                            // TODO: Implementar salvamento de arquivo
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Funcionalidade de salvamento em desenvolvimento'),
                              ),
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.share),
                          label: const Text('Compartilhar'),
                          onPressed: () async {
                            // TODO: Implementar compartilhamento
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Funcionalidade de compartilhamento em desenvolvimento'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar imagem: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Widget para exportar código como imagem
class CodeImageExporter {
  static Future<ui.Image?> exportAsImage({
    required String code,
    required String language,
    required CodeTheme theme,
    required bool showLineNumbers,
    double width = 800,
    double height = 600,
  }) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint();

      // Background transparente
      paint.color = Colors.transparent;
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);

      // TODO: Implement full image rendering
      // This would require a more complex implementation to render
      // the code with proper syntax highlighting as an image

      final picture = recorder.endRecording();
      return await picture.toImage(width.toInt(), height.toInt());
    } catch (e) {
      return null;
    }
  }
}
