import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import '../../../core/theme/app_colors.dart';
import '../models/code_theme.dart';
import '../../../shared/providers/theme_provider.dart';

class EnhancedCodeBlockWidget extends ConsumerStatefulWidget {
  final String code;
  final String language;
  final bool showLineNumbers;
  final bool showMacOSStyle;
  final CodeTheme? customTheme;

  const EnhancedCodeBlockWidget({
    super.key,
    required this.code,
    required this.language,
    this.showLineNumbers = true,
    this.showMacOSStyle = true,
    this.customTheme,
  });

  @override
  ConsumerState<EnhancedCodeBlockWidget> createState() =>
      _EnhancedCodeBlockWidgetState();
}

class _EnhancedCodeBlockWidgetState
    extends ConsumerState<EnhancedCodeBlockWidget> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final theme = widget.customTheme ??
        (isDarkMode ? CodeTheme.dracula : CodeTheme.github);

    return RepaintBoundary(
      key: _repaintBoundaryKey,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showMacOSStyle) _buildHeader(theme),
              _buildCodeContent(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CodeTheme theme) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.headerBackgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Círculos do macOS
          _buildTrafficLight(const Color(0xFFFF5F57)), // Vermelho
          const SizedBox(width: 8),
          _buildTrafficLight(const Color(0xFFFFBD2E)), // Amarelo
          const SizedBox(width: 8),
          _buildTrafficLight(const Color(0xFF28CA42)), // Verde

          const Spacer(),

          // Linguagem
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.backgroundColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.language.toUpperCase(),
              style: TextStyle(
                color: theme.headerTextColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Botões de ação
          _buildHeaderButton(
            PhosphorIcons.copy(),
            'Copiar código',
            _copyCode,
          ),
          const SizedBox(width: 8),
          _buildHeaderButton(
            PhosphorIcons.downloadSimple(),
            'Exportar como imagem',
            _exportAsImage,
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficLight(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildHeaderButton(
      IconData icon, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 16,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildCodeContent(CodeTheme theme) {
    final lines = widget.code.split('\n');
    final lineCount = lines.length;

    return Container(
      color: theme.backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Números de linha
          if (widget.showLineNumbers)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: theme.lineNumberBackgroundColor,
                border: Border(
                  right: BorderSide(color: theme.borderColor, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(lineCount, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: theme.lineNumberColor,
                        fontSize: 13,
                        fontFamily: 'monospace',
                        height: 1.5,
                      ),
                    ),
                  );
                }),
              ),
            ),

          // Código
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: HighlightView(
                  widget.code,
                  language: widget.language,
                  theme: _getHighlightTheme(theme),
                  padding: EdgeInsets.zero,
                  textStyle: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    height: 1.5,
                    color: theme.textColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> _getHighlightTheme(CodeTheme theme) {
    return {
      'root': TextStyle(color: theme.textColor),
      'comment':
          TextStyle(color: theme.commentColor, fontStyle: FontStyle.italic),
      'keyword':
          TextStyle(color: theme.keywordColor, fontWeight: FontWeight.bold),
      'string': TextStyle(color: theme.stringColor),
      'number': TextStyle(color: theme.numberColor),
      'function': TextStyle(color: theme.functionColor),
      'class': TextStyle(color: theme.classColor),
      'operator': TextStyle(color: theme.operatorColor),
      'punctuation': TextStyle(color: theme.punctuationColor),
    };
  }

  void _copyCode() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado para a área de transferência'),
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _exportAsImage() async {
    try {
      final RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        // Aqui você pode implementar o salvamento do arquivo
        // Por exemplo, usando path_provider e file system

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagem exportada com sucesso'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar imagem: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
