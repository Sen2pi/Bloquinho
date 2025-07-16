/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:open_file/open_file.dart';

/// Serviço de exportação PDF que sincroniza com o Enhanced Markdown Preview
class EnhancedPdfExportService {
  static final EnhancedPdfExportService _instance =
      EnhancedPdfExportService._internal();
  factory EnhancedPdfExportService() => _instance;
  EnhancedPdfExportService._internal();

  /// Exportar markdown como PDF com formatação idêntica ao preview
  Future<String?> exportMarkdownAsPdf({
    required String markdown,
    required String title,
    String? author,
    String? subject,
  }) async {
    try {
      final pdf = pw.Document();

      // Processar markdown usando o mesmo sistema do preview
      final contentWidgets =
          await _processEnhancedMarkdownToPdfWidgets(markdown);

      // Dividir conteúdo em páginas A4
      final pages = _splitContentIntoPages(contentWidgets, title);

      // Adicionar páginas ao PDF
      for (int i = 0; i < pages.length; i++) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            build: (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Cabeçalho apenas na primeira página
                if (i == 0) ...[
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                  pw.SizedBox(height: 20),
                ],

                // Conteúdo da página
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: pages[i],
                  ),
                ),

                // Rodapé
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Bloquinho - $title',
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                    ),
                    pw.Text(
                      'Página ${i + 1} de ${pages.length}',
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }

      // Salvar PDF
      final downloadsDir = await _getDownloadsDirectory();
      final fileName =
          '${_sanitizeFileName(title)}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = path.join(downloadsDir.path, fileName);

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      debugPrint('Erro ao exportar PDF: $e');
      return null;
    }
  }

  /// Processar markdown usando o mesmo sistema do enhanced preview widget
  Future<List<pw.Widget>> _processEnhancedMarkdownToPdfWidgets(
      String markdown) async {
    final widgets = <pw.Widget>[];
    final lines = markdown.split('\n');

    bool inCodeBlock = false;
    String codeBlockContent = '';
    String codeLanguage = '';
    bool inList = false;
    bool inBlockquote = false;
    String blockquoteContent = '';

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Detectar início/fim de bloco de código
      if (line.startsWith('```')) {
        if (inCodeBlock) {
          // Fim do bloco de código
          widgets.add(
              _createEnhancedCodeBlock(codeBlockContent.trim(), codeLanguage));
          widgets.add(pw.SizedBox(height: 16));
          inCodeBlock = false;
          codeBlockContent = '';
          codeLanguage = '';
        } else {
          // Início do bloco de código
          inCodeBlock = true;
          codeLanguage = line.substring(3).trim();
        }
        continue;
      }

      if (inCodeBlock) {
        codeBlockContent += line + '\n';
        continue;
      }

      // Processar LaTeX inline e em bloco PRIMEIRO (antes de outros processamentos)
      if (line.contains('\$')) {
        final processedLine = _processLatexInLine(line, widgets);
        if (processedLine != line) {
          // LaTeX foi processado, continuar para próxima linha
          continue;
        }
      }

      // Detectar blockquotes
      if (line.startsWith('> ')) {
        if (!inBlockquote) {
          inBlockquote = true;
          blockquoteContent = '';
        }
        blockquoteContent += line.substring(2) + '\n';
        continue;
      } else if (inBlockquote) {
        // Fim do blockquote
        widgets.add(_createEnhancedBlockquote(blockquoteContent.trim()));
        widgets.add(pw.SizedBox(height: 16));
        inBlockquote = false;
        blockquoteContent = '';
      }

      // Títulos
      if (line.startsWith('# ')) {
        widgets.add(_createEnhancedHeading(line.substring(2), 1));
        widgets.add(pw.SizedBox(height: 16));
      } else if (line.startsWith('## ')) {
        widgets.add(_createEnhancedHeading(line.substring(3), 2));
        widgets.add(pw.SizedBox(height: 14));
      } else if (line.startsWith('### ')) {
        widgets.add(_createEnhancedHeading(line.substring(4), 3));
        widgets.add(pw.SizedBox(height: 12));
      } else if (line.startsWith('#### ')) {
        widgets.add(_createEnhancedHeading(line.substring(5), 4));
        widgets.add(pw.SizedBox(height: 10));
      } else if (line.startsWith('##### ')) {
        widgets.add(_createEnhancedHeading(line.substring(6), 5));
        widgets.add(pw.SizedBox(height: 8));
      } else if (line.startsWith('###### ')) {
        widgets.add(_createEnhancedHeading(line.substring(7), 6));
        widgets.add(pw.SizedBox(height: 6));
      }
      // Listas
      else if (line.startsWith('- ') ||
          line.startsWith('* ') ||
          line.startsWith('+ ')) {
        widgets.add(_createEnhancedListItem(line.substring(2)));
        widgets.add(pw.SizedBox(height: 4));
        inList = true;
      }
      // Listas numeradas
      else if (RegExp(r'^\d+\. ').hasMatch(line)) {
        final match = RegExp(r'^\d+\. (.*)').firstMatch(line);
        if (match != null) {
          widgets.add(_createEnhancedNumberedListItem(match.group(1)!));
          widgets.add(pw.SizedBox(height: 4));
        }
      }
      // Texto normal ou com formatação inline
      else if (line.trim().isNotEmpty) {
        if (inList) {
          widgets.add(pw.SizedBox(height: 8));
          inList = false;
        }
        widgets.add(_createEnhancedFormattedText(line));
        widgets.add(pw.SizedBox(height: 6));
      }
      // Linha em branco
      else {
        if (inList) {
          widgets.add(pw.SizedBox(height: 8));
          inList = false;
        } else {
          widgets.add(pw.SizedBox(height: 12));
        }
      }
    }

    // Finalizar blockquote se ainda estiver ativo
    if (inBlockquote) {
      widgets.add(_createEnhancedBlockquote(blockquoteContent.trim()));
    }

    return widgets;
  }

  /// Processar LaTeX inline e em bloco na linha
  String _processLatexInLine(String line, List<pw.Widget> widgets) {
    // Detectar LaTeX em bloco $$...$$
    if (line.contains('\$\$')) {
      final blockMatch = RegExp(r'\$\$([^\$]+)\$\$').firstMatch(line);
      if (blockMatch != null) {
        final beforeLatex = line.substring(0, blockMatch.start);
        final latexContent = blockMatch.group(1)!;
        final afterLatex = line.substring(blockMatch.end);

        // Adicionar texto antes do LaTeX
        if (beforeLatex.trim().isNotEmpty) {
          widgets.add(_createEnhancedFormattedText(beforeLatex));
        }

        // Adicionar LaTeX em bloco
        widgets.add(_createLatexBlock(latexContent.trim()));
        widgets.add(pw.SizedBox(height: 12));

        // Processar texto após LaTeX
        if (afterLatex.trim().isNotEmpty) {
          widgets.add(_createEnhancedFormattedText(afterLatex));
        }

        return ''; // Linha foi processada
      }
    }

    return line; // Linha não foi modificada
  }

  /// Criar bloco LaTeX para PDF
  pw.Widget _createLatexBlock(String latex) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Center(
        child: pw.Text(
          latex,
          style: pw.TextStyle(
            fontSize: 14,
            fontStyle: pw.FontStyle.italic,
            color: PdfColors.blue800,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  /// Criar título formatado (mesmo estilo do preview)
  pw.Widget _createEnhancedHeading(String text, int level) {
    // Processar HTML inline no título
    final processedText = _processHtmlInText(text);

    double fontSize;
    switch (level) {
      case 1:
        fontSize = 28.0;
        break;
      case 2:
        fontSize = 24.0;
        break;
      case 3:
        fontSize = 20.0;
        break;
      case 4:
        fontSize = 18.0;
        break;
      case 5:
        fontSize = 16.0;
        break;
      case 6:
        fontSize = 14.0;
        break;
      default:
        fontSize = 14.0;
    }

    return pw.Container(
      width: double.infinity,
      child: pw.RichText(
        text: pw.TextSpan(
          children: _createRichTextSpansFromProcessedText(
              processedText, fontSize, true),
        ),
      ),
    );
  }

  /// Criar bloco de código (mesmo estilo do preview)
  pw.Widget _createEnhancedCodeBlock(String code, String language) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey900,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
        border: pw.Border.all(color: PdfColors.grey700),
        boxShadow: [
          pw.BoxShadow(
            color: PdfColors.black,
            blurRadius: 8,
            offset: const pw.Offset(0.0, 2.0),
          ),
        ],
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (language.isNotEmpty) ...[
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey800,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Text(
                language.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey300,
                ),
              ),
            ),
            pw.SizedBox(height: 12),
          ],
          pw.Text(
            code,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey100,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Criar item de lista (mesmo estilo do preview)
  pw.Widget _createEnhancedListItem(String text) {
    final processedText = _processHtmlInText(text);

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 6,
          height: 6,
          margin: const pw.EdgeInsets.only(top: 8, right: 12),
          decoration: const pw.BoxDecoration(
            color: PdfColors.blue,
            shape: pw.BoxShape.circle,
          ),
        ),
        pw.Expanded(
          child: pw.RichText(
            text: pw.TextSpan(
              children: _createRichTextSpansFromProcessedText(
                  processedText, 14, false),
            ),
          ),
        ),
      ],
    );
  }

  /// Criar item de lista numerada
  pw.Widget _createEnhancedNumberedListItem(String text) {
    final processedText = _processHtmlInText(text);

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 20,
          child: pw.Text(
            '•',
            style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue),
          ),
        ),
        pw.Expanded(
          child: pw.RichText(
            text: pw.TextSpan(
              children: _createRichTextSpansFromProcessedText(
                  processedText, 14, false),
            ),
          ),
        ),
      ],
    );
  }

  /// Criar blockquote (mesmo estilo do preview)
  pw.Widget _createEnhancedBlockquote(String text) {
    final processedText = _processHtmlInText(text);

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(
            color: PdfColors.blue,
            width: 4,
          ),
        ),
        color: PdfColors.blue50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.RichText(
        text: pw.TextSpan(
          children:
              _createRichTextSpansFromProcessedText(processedText, 14, false),
        ),
      ),
    );
  }

  /// Criar texto com formatação inline (mesmo estilo do preview)
  pw.Widget _createEnhancedFormattedText(String text) {
    final processedText = _processHtmlInText(text);

    return pw.RichText(
      text: pw.TextSpan(
        children:
            _createRichTextSpansFromProcessedText(processedText, 14, false),
      ),
    );
  }

  /// Processar HTML inline no texto (cores, estilos, etc.)
  _ProcessedTextPart _processHtmlInText(String text) {
    final parts = <_TextSegment>[];
    String remaining = text;

    while (remaining.isNotEmpty) {
      // Processar <span style="...">...</span>
      final spanMatch =
          RegExp(r'<span style="([^"]*)">(.*?)</span>').firstMatch(remaining);
      if (spanMatch != null && spanMatch.start == 0) {
        final style = spanMatch.group(1)!;
        final content = spanMatch.group(2)!;
        final styleMap = _parseStyleString(style);

        parts.add(_TextSegment(
          text: content,
          color: styleMap['color'],
          backgroundColor: styleMap['backgroundColor'],
          isBold: styleMap['fontWeight'] == 'bold',
          isItalic: styleMap['fontStyle'] == 'italic',
        ));

        remaining = remaining.substring(spanMatch.end);
        continue;
      }

      // Processar LaTeX inline $...$
      final latexMatch = RegExp(r'\$([^\$]+)\$').firstMatch(remaining);
      if (latexMatch != null && latexMatch.start == 0) {
        final latex = latexMatch.group(1)!;
        parts.add(_TextSegment(
          text: latex,
          isLatex: true,
          color: PdfColors.blue800,
          isItalic: true,
        ));
        remaining = remaining.substring(latexMatch.end);
        continue;
      }

      // Processar **texto**
      final boldMatch = RegExp(r'\*\*([^*]+)\*\*').firstMatch(remaining);
      if (boldMatch != null && boldMatch.start == 0) {
        parts.add(_TextSegment(
          text: boldMatch.group(1)!,
          isBold: true,
        ));
        remaining = remaining.substring(boldMatch.end);
        continue;
      }

      // Processar *texto*
      final italicMatch = RegExp(r'\*([^*]+)\*').firstMatch(remaining);
      if (italicMatch != null && italicMatch.start == 0) {
        parts.add(_TextSegment(
          text: italicMatch.group(1)!,
          isItalic: true,
        ));
        remaining = remaining.substring(italicMatch.end);
        continue;
      }

      // Processar `código`
      final codeMatch = RegExp(r'`([^`]+)`').firstMatch(remaining);
      if (codeMatch != null && codeMatch.start == 0) {
        parts.add(_TextSegment(
          text: codeMatch.group(1)!,
          isCode: true,
          backgroundColor: PdfColors.grey200,
          fontFamily: 'monospace',
        ));
        remaining = remaining.substring(codeMatch.end);
        continue;
      }

      // Encontrar próxima formatação ou fim do texto
      var nextFormatPos = remaining.length;
      final patterns = [
        r'<span style="[^"]*">.*?</span>',
        r'\$[^\$]+\$',
        r'\*\*[^*]+\*\*',
        r'\*[^*]+\*',
        r'`[^`]+`'
      ];

      for (final pattern in patterns) {
        final match = RegExp(pattern).firstMatch(remaining);
        if (match != null && match.start < nextFormatPos) {
          nextFormatPos = match.start;
        }
      }

      if (nextFormatPos > 0) {
        parts.add(_TextSegment(text: remaining.substring(0, nextFormatPos)));
        remaining = remaining.substring(nextFormatPos);
      } else {
        break;
      }
    }

    if (remaining.isNotEmpty) {
      parts.add(_TextSegment(text: remaining));
    }

    return _ProcessedTextPart(parts);
  }

  /// Criar spans de texto rico a partir do texto processado
  List<pw.InlineSpan> _createRichTextSpansFromProcessedText(
      _ProcessedTextPart processedText, double fontSize, bool isHeading) {
    final spans = <pw.InlineSpan>[];

    for (final segment in processedText.segments) {
      spans.add(
        pw.TextSpan(
          text: segment.text,
          style: pw.TextStyle(
            fontSize: segment.isLatex ? fontSize * 0.9 : fontSize,
            fontWeight: (segment.isBold || isHeading)
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
            fontStyle:
                segment.isItalic ? pw.FontStyle.italic : pw.FontStyle.normal,
            color: segment.color ?? PdfColors.black,
          ),
        ),
      );
    }

    return spans;
  }

  /// Parse string de estilo CSS
  Map<String, dynamic> _parseStyleString(String style) {
    final map = <String, dynamic>{};
    final props = style.split(';');

    for (final prop in props) {
      final parts = prop.split(':');
      if (parts.length != 2) continue;

      final key = parts[0].trim();
      final value = parts[1].trim();

      switch (key) {
        case 'color':
          map['color'] = _parseColor(value);
          break;
        case 'background-color':
          map['backgroundColor'] = _parseColor(value);
          break;
        case 'font-weight':
          map['fontWeight'] = value;
          break;
        case 'font-style':
          map['fontStyle'] = value;
          break;
      }
    }

    return map;
  }

  /// Parse cor CSS
  PdfColor? _parseColor(String value) {
    if (value.startsWith('#')) {
      final hex = value.substring(1);
      final r = int.parse(hex.substring(0, 2), radix: 16) / 255.0;
      final g = int.parse(hex.substring(2, 4), radix: 16) / 255.0;
      final b = int.parse(hex.substring(4, 6), radix: 16) / 255.0;
      return PdfColor(r, g, b);
    }

    switch (value.toLowerCase()) {
      case 'red':
        return PdfColors.red;
      case 'blue':
        return PdfColors.blue;
      case 'green':
        return PdfColors.green;
      case 'yellow':
        return PdfColors.yellow;
      case 'orange':
        return PdfColors.orange;
      case 'white':
        return PdfColors.white;
      case 'black':
        return PdfColors.black;
      case 'grey':
      case 'gray':
        return PdfColors.grey;
      default:
        return null;
    }
  }

  /// Dividir conteúdo em páginas A4
  List<List<pw.Widget>> _splitContentIntoPages(
      List<pw.Widget> widgets, String title) {
    final pages = <List<pw.Widget>>[];
    var currentPage = <pw.Widget>[];
    var currentHeight = 0.0;

    const maxPageHeight = 700.0;
    const firstPageMaxHeight = 600.0;

    bool isFirstPage = true;
    double pageLimit = firstPageMaxHeight;

    for (final widget in widgets) {
      final estimatedHeight = _estimateWidgetHeight(widget);

      if (currentHeight + estimatedHeight > pageLimit &&
          currentPage.isNotEmpty) {
        pages.add(List.from(currentPage));
        currentPage.clear();
        currentHeight = 0.0;
        isFirstPage = false;
        pageLimit = maxPageHeight;
      }

      currentPage.add(widget);
      currentHeight += estimatedHeight;
    }

    if (currentPage.isNotEmpty) {
      pages.add(currentPage);
    }

    if (pages.isEmpty) {
      pages.add([pw.Text('Conteúdo vazio')]);
    }

    return pages;
  }

  /// Estimar altura de um widget PDF
  double _estimateWidgetHeight(pw.Widget widget) {
    if (widget is pw.Text) {
      return 20.0;
    } else if (widget is pw.RichText) {
      return 20.0;
    } else if (widget is pw.SizedBox) {
      return 10.0;
    } else if (widget is pw.Container) {
      return 60.0; // Blocos de código, blockquotes
    } else if (widget is pw.Row) {
      return 20.0; // Lista items
    }
    return 20.0;
  }

  /// Obter diretório de downloads
  Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    } else if (Platform.isWindows) {
      return Directory('${Platform.environment['USERPROFILE']}\\Downloads');
    } else if (Platform.isMacOS) {
      return Directory('${Platform.environment['HOME']}/Downloads');
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  /// Sanitizar nome de arquivo
  String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  /// Abrir arquivo exportado
  Future<void> openExportedFile(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      debugPrint('Erro ao abrir arquivo: $e');
    }
  }
}

/// Classe para representar parte de texto processado
class _ProcessedTextPart {
  final List<_TextSegment> segments;
  _ProcessedTextPart(this.segments);
}

/// Classe para representar segmento de texto com formatação
class _TextSegment {
  final String text;
  final PdfColor? color;
  final PdfColor? backgroundColor;
  final bool isBold;
  final bool isItalic;
  final bool isCode;
  final bool isLatex;
  final String? fontFamily;

  _TextSegment({
    required this.text,
    this.color,
    this.backgroundColor,
    this.isBold = false,
    this.isItalic = false,
    this.isCode = false,
    this.isLatex = false,
    this.fontFamily,
  });
}
