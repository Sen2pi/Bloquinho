import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: widget.theme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.theme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(isDarkMode),

          // Code content
          _buildCodeContent(),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    final language = ProgrammingLanguage.getByCode(widget.language) ??
        ProgrammingLanguage.defaultLanguage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.theme.headerBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border(
          bottom: BorderSide(
            color: widget.theme.borderColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Language info
          Row(
            children: [
              if (language.icon != null)
                Text(
                  language.icon!,
                  style: const TextStyle(fontSize: 16),
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

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedOpacity(
        opacity: _isHovered ? 1.0 : 0.7,
        duration: const Duration(milliseconds: 200),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
          tooltip: tooltip,
          color: widget.theme.headerTextColor,
          hoverColor: widget.theme.headerTextColor.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildCodeContent() {
    final lines = widget.code.split('\n');

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width *
            0.8, // 80% da largura da área de conteúdo
        constraints: const BoxConstraints(
            minHeight: 100, maxWidth: 900), // Limite máximo para desktop
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: IntrinsicWidth(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Line numbers
                  if (widget.showLineNumbers) _buildLineNumbers(lines),

                  // Code content
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: _buildHighlightedCode(lines),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineNumbers(List<String> lines) {
    return Container(
      width: 60, // Aumentado de 50 para 60
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: widget.theme.lineNumberBackgroundColor,
        border: Border(
          right: BorderSide(
            color: widget.theme.borderColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: lines.asMap().entries.map((entry) {
          final index = entry.key;
          final line = entry.value;

          return Container(
            height: 20,
            alignment: Alignment.centerRight,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: widget.theme.lineNumberColor,
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
          height: 20,
          child: _buildHighlightedLine(line),
        );
      }).toList(),
    );
  }

  Widget _buildHighlightedLine(String line) {
    if (line.isEmpty) {
      return const SizedBox(height: 20);
    }

    // Simple syntax highlighting (can be enhanced with a proper parser)
    final highlightedSpans = _highlightSyntax(line);

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: widget.theme.textColor,
          fontSize: 14,
          fontFamily: 'Courier',
          height: 1.4,
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
    // Renderizar o widget como imagem
    final boundaryKey = GlobalKey();
    final codeWidget = RepaintBoundary(
      key: boundaryKey,
      child: Container(
        decoration: BoxDecoration(
          color: widget.theme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.theme.borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: widget.theme.backgroundColor.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        width: 700,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header estilizado
            Row(
              children: [
                if (ProgrammingLanguage.getByCode(widget.language)?.icon !=
                    null)
                  Text(
                    ProgrammingLanguage.getByCode(widget.language)!.icon!,
                    style: const TextStyle(fontSize: 20),
                  ),
                const SizedBox(width: 8),
                Text(
                  ProgrammingLanguage.getByCode(widget.language)?.displayName ??
                      'Código',
                  style: TextStyle(
                    color: widget.theme.headerTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                Text(
                  widget.theme.displayName,
                  style: TextStyle(
                    color: widget.theme.headerTextColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Código propriamente dito
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.theme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildHighlightedCode(widget.code.split('\n')),
            ),
          ],
        ),
      ),
    );

    // Exibir diálogo de preview e salvar imagem
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: widget.theme.backgroundColor,
          content: SizedBox(
            width: 720,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                codeWidget,
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Salvar como imagem'),
                  onPressed: () async {
                    RenderRepaintBoundary boundary = boundaryKey.currentContext!
                        .findRenderObject() as RenderRepaintBoundary;
                    var image = await boundary.toImage(pixelRatio: 2.0);
                    ByteData? byteData =
                        await image.toByteData(format: ui.ImageByteFormat.png);
                    if (byteData != null) {
                      final pngBytes = byteData.buffer.asUint8List();
                      // Salvar arquivo usando file_picker ou outro método
                      // TODO: Implementar salvar arquivo no sistema
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Imagem gerada! (Salvar em arquivo ainda não implementado)')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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

      // Background
      paint.color = theme.backgroundColor;
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);

      // TODO: Implement full image rendering
      // This would require a more complex implementation to render
      // the code with proper syntax highlighting as an image

      final picture = recorder.endRecording();
      return await picture.toImage(width.toInt(), height.toInt());
    } catch (e) {
      debugPrint('Erro ao exportar código como imagem: $e');
      return null;
    }
  }
}
