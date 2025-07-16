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
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../features/bloquinho/models/code_theme.dart';
import '../../../core/services/pdf_export_service.dart';

// Provider para o tema de código selecionado
final selectedCodeThemeProvider = StateProvider<CodeTheme>((ref) {
  return CodeTheme.defaultTheme;
});

class WindowsCodeBlockWidget extends ConsumerStatefulWidget {
  final String code;
  final String language;
  final bool showLineNumbers;
  final bool showMacOSHeader;
  final String? title;

  const WindowsCodeBlockWidget({
    super.key,
    required this.code,
    required this.language,
    this.showLineNumbers = true,
    this.showMacOSHeader = true,
    this.title,
  });

  @override
  ConsumerState<WindowsCodeBlockWidget> createState() =>
      _WindowsCodeBlockWidgetState();
}

class _WindowsCodeBlockWidgetState
    extends ConsumerState<WindowsCodeBlockWidget> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _copied = false;
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    // Detectar linguagem automaticamente
    final detected = CodeTheme.detectLanguageFromContent(widget.code).code;
    _selectedLanguage = detected.isNotEmpty ? detected : 'javascript';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final selectedTheme = ref.watch(selectedCodeThemeProvider);
    final languageObj = ProgrammingLanguage.getByCode(_selectedLanguage) ??
        ProgrammingLanguage.javascript;

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
              if (widget.showMacOSHeader)
                _buildMacOSHeader(isDarkMode, languageObj, selectedTheme),
              _buildCodeContent(isDarkMode, selectedTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacOSHeader(
      bool isDarkMode, ProgrammingLanguage languageObj, CodeTheme theme) {
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
          // Três círculos do macOS (exatamente como na imagem)
          _buildTrafficLight(const Color(0xFFFF5F57)), // Vermelho
          const SizedBox(width: 8),
          _buildTrafficLight(const Color(0xFFFFBD2E)), // Amarelo
          const SizedBox(width: 8),
          _buildTrafficLight(const Color(0xFF28CA42)), // Verde

          const SizedBox(width: 16),

          // Título da linguagem
          Text(
            languageObj.icon + ' ' + languageObj.displayName,
            style: TextStyle(
              color: theme.headerTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),

          // Dropdown para trocar linguagem
          DropdownButton<String>(
            value: _selectedLanguage,
            dropdownColor: theme.headerBackgroundColor,
            style: TextStyle(
                color: theme.headerTextColor,
                fontSize: 11,
                fontWeight: FontWeight.w600),
            underline: Container(),
            icon: Icon(Icons.arrow_drop_down,
                color: theme.headerTextColor, size: 16),
            items: ProgrammingLanguage.languages
                .map((lang) => DropdownMenuItem(
                      value: lang.code,
                      child: Text(lang.displayName),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedLanguage = value);
              }
            },
          ),

          const SizedBox(width: 12),

          // Botões de ação
          _buildHeaderButton(
            PhosphorIcons.copy(),
            'Copiar código',
            _copyCode,
            theme,
          ),
          const SizedBox(width: 8),
          _buildHeaderButton(
            PhosphorIcons.downloadSimple(),
            'Exportar como arquivo',
            _exportAsFile,
            theme,
          ),
          const SizedBox(width: 8),
          _buildHeaderButton(
            PhosphorIcons.image(),
            'Exportar como imagem',
            _exportAsImage,
            theme,
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

  Widget _buildHeaderButton(
      IconData icon, String tooltip, VoidCallback onPressed, CodeTheme theme) {
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
            color: theme.headerTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildCodeContent(bool isDarkMode, CodeTheme theme) {
    final lines = widget.code.split('\n');
    final lineCount = lines.length;

    return Container(
      color: theme.backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Números de linha (se habilitado)
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
                child: SelectableText.rich(
                  _buildHighlightedCode(theme),
                  style: TextStyle(
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

  TextSpan _buildHighlightedCode(CodeTheme theme) {
    final codeLines = widget.code.split('\n');
    final spans = <TextSpan>[];

    for (int i = 0; i < codeLines.length; i++) {
      final line = codeLines[i];
      spans.add(_highlightLine(line, theme));

      if (i < codeLines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return TextSpan(children: spans);
  }

  TextSpan _highlightLine(String line, CodeTheme theme) {
    // Obter sintaxe da linguagem
    final syntax = CodeThemeSyntaxExt.getSyntax(_selectedLanguage);

    // Regex patterns para diferentes tipos de tokens
    final patterns = {
      'keyword': syntax.keywordPattern,
      'string': syntax.stringPattern,
      'number': syntax.numberPattern,
      'comment': syntax.commentPattern,
      'function': syntax.functionPattern,
      'class': syntax.classPattern,
      'operator': syntax.operatorPattern,
      'punctuation': syntax.punctuationPattern,
    };

    final colors = {
      'keyword': theme.keywordColor,
      'string': theme.stringColor,
      'number': theme.numberColor,
      'comment': theme.commentColor,
      'function': theme.functionColor,
      'class': theme.classColor,
      'operator': theme.operatorColor,
      'punctuation': theme.punctuationColor,
    };

    final spans = <TextSpan>[];
    var currentIndex = 0;

    while (currentIndex < line.length) {
      bool matched = false;

      for (final entry in patterns.entries) {
        final pattern = entry.value;
        if (pattern.pattern.isEmpty) continue; // Pular padrões vazios

        final match = pattern.matchAsPrefix(line, currentIndex);

        if (match != null) {
          final text = match.group(0)!;
          spans.add(TextSpan(
            text: text,
            style: TextStyle(color: colors[entry.key] ?? theme.textColor),
          ));
          currentIndex = match.end;
          matched = true;
          break;
        }
      }

      if (!matched) {
        // Caractere normal
        spans.add(TextSpan(
          text: line[currentIndex],
          style: TextStyle(color: theme.textColor),
        ));
        currentIndex++;
      }
    }

    return TextSpan(children: spans);
  }

  void _copyCode() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código copiado para a área de transferência'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _exportAsFile() async {
    try {
      // Mostrar loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exportando código como arquivo...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Exportar como arquivo
      final pdfService = PdfExportService();
      final filePath = await pdfService.exportCodeAsFile(
        code: widget.code,
        language: _selectedLanguage,
        fileName:
            'codigo_${_selectedLanguage}_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (filePath != null) {
        // Abrir arquivo
        await pdfService.openExportedFile(filePath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Arquivo exportado com sucesso!\nSalvo em: $filePath'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao exportar arquivo'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar arquivo: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _exportAsImage() async {
    try {
      // Mostrar loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exportando código como imagem...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Exportar como imagem
      final pdfService = PdfExportService();
      final filePath = await pdfService.exportWidgetAsImage(
        widgetKey: _repaintBoundaryKey,
        fileName:
            'codigo_${_selectedLanguage}_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (filePath != null) {
        // Abrir arquivo
        await pdfService.openExportedFile(filePath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Imagem exportada com sucesso!\nSalva em: $filePath'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao exportar imagem'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar imagem: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
