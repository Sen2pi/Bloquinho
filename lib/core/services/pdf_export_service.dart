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
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:open_file/open_file.dart';

/// Serviço para exportação de PDF no Bloquinho
class PdfExportService {
  static final PdfExportService _instance = PdfExportService._internal();
  factory PdfExportService() => _instance;
  PdfExportService._internal();

  /// Exportar markdown como PDF com formatação completa
  Future<String?> exportMarkdownAsPdf({
    required String markdown,
    required String title,
    String? author,
    String? subject,
  }) async {
    try {
      final pdf = pw.Document();

      // Processar markdown para widgets PDF
      final contentWidgets =
          await _processMarkdownToAdvancedPdfWidgets(markdown);

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

  /// Exportar widget como imagem PNG
  Future<String?> exportWidgetAsImage({
    required GlobalKey widgetKey,
    required String fileName,
    double pixelRatio = 2.0,
  }) async {
    try {
      final RenderRepaintBoundary boundary =
          widgetKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final downloadsDir = await _getDownloadsDirectory();
        final sanitizedFileName = _sanitizeFileName(fileName);
        final filePath =
            path.join(downloadsDir.path, '${sanitizedFileName}.png');

        final file = File(filePath);
        await file.writeAsBytes(byteData.buffer.asUint8List());

        return filePath;
      }

      return null;
    } catch (e) {
      debugPrint('Erro ao exportar imagem: $e');
      return null;
    }
  }

  /// Exportar código como arquivo de texto
  Future<String?> exportCodeAsFile({
    required String code,
    required String language,
    required String fileName,
  }) async {
    try {
      final downloadsDir = await _getDownloadsDirectory();
      final sanitizedFileName = _sanitizeFileName(fileName);
      final extension = _getFileExtension(language);
      final filePath =
          path.join(downloadsDir.path, '${sanitizedFileName}.$extension');

      final file = File(filePath);
      await file.writeAsString(code);

      return filePath;
    } catch (e) {
      debugPrint('Erro ao exportar código: $e');
      return null;
    }
  }

  /// Abrir arquivo exportado
  Future<void> openExportedFile(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      debugPrint('Erro ao abrir arquivo: $e');
    }
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

  /// Processar markdown para widgets PDF avançados com suporte completo
  Future<List<pw.Widget>> _processMarkdownToAdvancedPdfWidgets(
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
          widgets.add(_createCodeBlock(codeBlockContent.trim(), codeLanguage));
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
        widgets.add(_createBlockquote(blockquoteContent.trim()));
        widgets.add(pw.SizedBox(height: 16));
        inBlockquote = false;
        blockquoteContent = '';
      }

      // Títulos
      if (line.startsWith('# ')) {
        widgets.add(_createHeading(line.substring(2), 1));
        widgets.add(pw.SizedBox(height: 16));
      } else if (line.startsWith('## ')) {
        widgets.add(_createHeading(line.substring(3), 2));
        widgets.add(pw.SizedBox(height: 14));
      } else if (line.startsWith('### ')) {
        widgets.add(_createHeading(line.substring(4), 3));
        widgets.add(pw.SizedBox(height: 12));
      } else if (line.startsWith('#### ')) {
        widgets.add(_createHeading(line.substring(5), 4));
        widgets.add(pw.SizedBox(height: 10));
      } else if (line.startsWith('##### ')) {
        widgets.add(_createHeading(line.substring(6), 5));
        widgets.add(pw.SizedBox(height: 8));
      } else if (line.startsWith('###### ')) {
        widgets.add(_createHeading(line.substring(7), 6));
        widgets.add(pw.SizedBox(height: 6));
      }
      // Listas
      else if (line.startsWith('- ') ||
          line.startsWith('* ') ||
          line.startsWith('+ ')) {
        widgets.add(_createListItem(line.substring(2)));
        widgets.add(pw.SizedBox(height: 4));
        inList = true;
      }
      // Listas numeradas
      else if (RegExp(r'^\d+\. ').hasMatch(line)) {
        final match = RegExp(r'^\d+\. (.*)').firstMatch(line);
        if (match != null) {
          widgets.add(_createNumberedListItem(match.group(1)!));
          widgets.add(pw.SizedBox(height: 4));
        }
      }
      // Texto normal ou com formatação inline
      else if (line.trim().isNotEmpty) {
        if (inList) {
          widgets.add(pw.SizedBox(height: 8));
          inList = false;
        }
        widgets.add(_createFormattedText(line));
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
      widgets.add(_createBlockquote(blockquoteContent.trim()));
    }

    return widgets;
  }

  /// Dividir conteúdo em páginas A4
  List<List<pw.Widget>> _splitContentIntoPages(
      List<pw.Widget> widgets, String title) {
    final pages = <List<pw.Widget>>[];
    var currentPage = <pw.Widget>[];
    var currentHeight = 0.0;

    // Altura disponível na página A4 (considerando margens e cabeçalho/rodapé)
    const maxPageHeight = 700.0; // Aproximadamente A4 menos margens
    const firstPageMaxHeight = 600.0; // Primeira página tem cabeçalho

    bool isFirstPage = true;
    double pageLimit = firstPageMaxHeight;

    for (final widget in widgets) {
      final estimatedHeight = _estimateWidgetHeight(widget);

      // Se o widget não cabe na página atual, criar nova página
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

    // Adicionar última página se não estiver vazia
    if (currentPage.isNotEmpty) {
      pages.add(currentPage);
    }

    // Se não há páginas, criar uma página vazia
    if (pages.isEmpty) {
      pages.add([pw.Text('Conteúdo vazio')]);
    }

    return pages;
  }

  /// Estimar altura de um widget PDF
  double _estimateWidgetHeight(pw.Widget widget) {
    // Estimativas baseadas no tipo de widget
    if (widget is pw.Text) {
      return 20.0; // Altura média de uma linha de texto
    } else if (widget is pw.SizedBox) {
      return 10.0; // Espaçamento padrão
    } else if (widget is pw.Container) {
      return 40.0; // Blocos de código, etc.
    } else if (widget is pw.Row) {
      return 20.0; // Lista items
    }
    return 20.0; // Padrão
  }

  /// Criar título formatado
  pw.Widget _createHeading(String text, int level) {
    double fontSize;
    switch (level) {
      case 1:
        fontSize = 24.0;
        break;
      case 2:
        fontSize = 20.0;
        break;
      case 3:
        fontSize = 18.0;
        break;
      case 4:
        fontSize = 16.0;
        break;
      case 5:
        fontSize = 14.0;
        break;
      case 6:
        fontSize = 12.0;
        break;
      default:
        fontSize = 12.0;
    }

    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: fontSize,
        fontWeight: pw.FontWeight.bold,
      ),
    );
  }

  /// Criar bloco de código
  pw.Widget _createCodeBlock(String code, String language) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (language.isNotEmpty) ...[
            pw.Text(
              language,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 8),
          ],
          pw.Text(
            code,
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Criar item de lista
  pw.Widget _createListItem(String text) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 4,
          height: 4,
          margin: const pw.EdgeInsets.only(top: 6, right: 8),
          decoration: const pw.BoxDecoration(
            color: PdfColors.black,
            shape: pw.BoxShape.circle,
          ),
        ),
        pw.Expanded(
          child: _createFormattedText(text),
        ),
      ],
    );
  }

  /// Criar item de lista numerada
  pw.Widget _createNumberedListItem(String text) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 20,
          child: pw.Text(
            '•',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          child: _createFormattedText(text),
        ),
      ],
    );
  }

  /// Criar blockquote
  pw.Widget _createBlockquote(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(
            color: PdfColors.blue,
            width: 4,
          ),
        ),
        color: PdfColors.grey50,
      ),
      child: _createFormattedText(text),
    );
  }

  /// Criar texto com formatação inline (negrito, itálico, código inline)
  pw.Widget _createFormattedText(String text) {
    // Processar formatação inline básica
    final spans = <pw.InlineSpan>[];

    // Dividir texto por formatação
    final parts = _parseInlineFormatting(text);

    for (final part in parts) {
      spans.add(
        pw.TextSpan(
          text: part.text,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: part.isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontStyle:
                part.isItalic ? pw.FontStyle.italic : pw.FontStyle.normal,
          ),
        ),
      );
    }

    return pw.RichText(
      text: pw.TextSpan(children: spans),
    );
  }

  /// Analisar formatação inline
  List<_FormattedTextPart> _parseInlineFormatting(String text) {
    final parts = <_FormattedTextPart>[];
    var remaining = text;

    while (remaining.isNotEmpty) {
      // Procurar por código inline `code`
      final codeMatch = RegExp(r'`([^`]+)`').firstMatch(remaining);
      if (codeMatch != null && codeMatch.start == 0) {
        parts.add(_FormattedTextPart(codeMatch.group(1)!, isCode: true));
        remaining = remaining.substring(codeMatch.end);
        continue;
      }

      // Procurar por negrito **text**
      final boldMatch = RegExp(r'\*\*([^*]+)\*\*').firstMatch(remaining);
      if (boldMatch != null && boldMatch.start == 0) {
        parts.add(_FormattedTextPart(boldMatch.group(1)!, isBold: true));
        remaining = remaining.substring(boldMatch.end);
        continue;
      }

      // Procurar por itálico *text*
      final italicMatch = RegExp(r'\*([^*]+)\*').firstMatch(remaining);
      if (italicMatch != null && italicMatch.start == 0) {
        parts.add(_FormattedTextPart(italicMatch.group(1)!, isItalic: true));
        remaining = remaining.substring(italicMatch.end);
        continue;
      }

      // Encontrar próxima formatação ou fim do texto
      var nextFormatPos = remaining.length;
      for (final pattern in [r'`[^`]+`', r'\*\*[^*]+\*\*', r'\*[^*]+\*']) {
        final match = RegExp(pattern).firstMatch(remaining);
        if (match != null && match.start < nextFormatPos) {
          nextFormatPos = match.start;
        }
      }

      if (nextFormatPos > 0) {
        parts.add(_FormattedTextPart(remaining.substring(0, nextFormatPos)));
        remaining = remaining.substring(nextFormatPos);
      } else {
        break;
      }
    }

    if (remaining.isNotEmpty) {
      parts.add(_FormattedTextPart(remaining));
    }

    return parts;
  }

  /// Sanitizar nome de arquivo
  String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  /// Obter extensão de arquivo baseada na linguagem
  String _getFileExtension(String language) {
    final extensions = {
      'javascript': 'js',
      'typescript': 'ts',
      'python': 'py',
      'java': 'java',
      'cpp': 'cpp',
      'c': 'c',
      'csharp': 'cs',
      'php': 'php',
      'ruby': 'rb',
      'go': 'go',
      'rust': 'rs',
      'swift': 'swift',
      'kotlin': 'kt',
      'dart': 'dart',
      'html': 'html',
      'css': 'css',
      'sql': 'sql',
      'json': 'json',
      'xml': 'xml',
      'yaml': 'yaml',
      'markdown': 'md',
      'text': 'txt',
    };

    return extensions[language.toLowerCase()] ?? 'txt';
  }
}

/// Classe auxiliar para partes de texto formatado
class _FormattedTextPart {
  final String text;
  final bool isBold;
  final bool isItalic;
  final bool isCode;

  _FormattedTextPart(
    this.text, {
    this.isBold = false,
    this.isItalic = false,
    this.isCode = false,
  });
}
