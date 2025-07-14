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
                _buildMacOSHeader(isDarkMode, languageObj),
              _buildCodeContent(isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacOSHeader(bool isDarkMode, ProgrammingLanguage languageObj) {
    // Cores exatas como na imagem
    const headerColor = Color(0xFF2D3748); // Cinza escuro como na imagem

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: headerColor,
        border: Border(
          bottom: BorderSide(color: Color(0xFF4A5568), width: 1),
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
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),

          // Dropdown para trocar linguagem
          DropdownButton<String>(
            value: _selectedLanguage,
            dropdownColor: headerColor,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600),
            underline: Container(),
            icon: const Icon(Icons.arrow_drop_down,
                color: Colors.white70, size: 16),
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
          ),
          const SizedBox(width: 8),
          _buildHeaderButton(
            PhosphorIcons.downloadSimple(),
            'Exportar como arquivo',
            _exportAsFile,
          ),
          const SizedBox(width: 8),
          _buildHeaderButton(
            PhosphorIcons.image(),
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

  Widget _buildCodeContent(bool isDarkMode) {
    final lines = widget.code.split('\n');
    final lineCount = lines.length;

    // Cores exatas como na imagem
    const codeBackgroundColor = Color(0xFF1A202C); // Fundo escuro do código
    const lineNumberColor = Color(0xFF4A5568); // Cor dos números das linhas

    return Container(
      color: codeBackgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Números de linha (se habilitado)
          if (widget.showLineNumbers)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF171923), // Fundo dos números
                border: Border(
                  right: BorderSide(color: Color(0xFF2D3748), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(lineCount, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: lineNumberColor,
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
                  _buildHighlightedCode(),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextSpan _buildHighlightedCode() {
    // Implementação simples de syntax highlighting para JavaScript
    // (pode ser expandida para outras linguagens)

    final codeLines = widget.code.split('\n');
    final spans = <TextSpan>[];

    for (int i = 0; i < codeLines.length; i++) {
      final line = codeLines[i];
      spans.add(_highlightLine(line));

      if (i < codeLines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return TextSpan(children: spans);
  }

  TextSpan _highlightLine(String line) {
    // Regex patterns para diferentes tipos de tokens
    final patterns = {
      'keyword': RegExp(
          r'\b(const|let|var|function|return|if|else|for|while|class|export|import|async|await|=>)\b'),
      'string': RegExp(r"['" "].*?['" "]"),
      'number': RegExp(r'\b\d+\.?\d*\b'),
      'comment': RegExp(r'//.*|/\*.*?\*/'),
      'operator': RegExp(r'[+\-*/=<>!&|^%]'),
      'parentheses': RegExp(r'[(){}[\];,.]'),
    };

    final colors = {
      'keyword': const Color(0xFFFF79C6), // Rosa/magenta para palavras-chave
      'string': const Color(0xFFF1FA8C), // Amarelo para strings
      'number': const Color(0xFFBD93F9), // Roxo para números
      'comment': const Color(0xFF6272A4), // Azul acinzentado para comentários
      'operator': const Color(0xFFFF79C6), // Rosa para operadores
      'parentheses': const Color(0xFFF8F8F2), // Branco para parênteses
    };

    final spans = <TextSpan>[];
    var currentIndex = 0;

    while (currentIndex < line.length) {
      bool matched = false;

      for (final entry in patterns.entries) {
        final pattern = entry.value;
        final match = pattern.matchAsPrefix(line, currentIndex);

        if (match != null) {
          final text = match.group(0)!;
          spans.add(TextSpan(
            text: text,
            style: TextStyle(color: colors[entry.key] ?? Colors.white),
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
          style: const TextStyle(color: Colors.white),
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
