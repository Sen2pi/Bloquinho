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
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart' show rootBundle;

import '../../../core/l10n/app_strings.dart';
import 'enhanced_markdown_parser.dart';

class EnhancedPdfExportService {
  pw.Font? _notoSansFont;
  pw.Font? _notoSansBoldFont;
  pw.Font? _notoEmojiFont;

  /// Carregar fontes Unicode e emoji
  Future<void> _loadFonts() async {
    if (_notoSansFont == null) {
      _notoSansFont = pw.Font.ttf(
          await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
    }
    if (_notoEmojiFont == null) {
      _notoEmojiFont =
          pw.Font.ttf(await rootBundle.load('assets/fonts/NotoColorEmoji.ttf'));
    }
  }

  /// Obter fonte padrão com fallback para emoji
  pw.Font _getDefaultFont() {
    return _notoSansFont ?? pw.Font.helvetica();
  }

  /// Obter fontes de fallback para emoji
  List<pw.Font> _getFontFallbacks() {
    return _notoEmojiFont != null ? [_notoEmojiFont!] : <pw.Font>[];
  }

  /// Exportar widget como imagem
  Future<String?> exportWidgetAsImage({
    required GlobalKey widgetKey,
    required String fileName,
  }) async {
    try {
      final RenderRepaintBoundary boundary =
          widgetKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final downloadsDir = await _getDownloadsDirectory();
      final sanitizedFileName = _sanitizeFileName(fileName);
      final filePath = path.join(downloadsDir.path, '$sanitizedFileName.png');

      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      return filePath;
    } catch (e) {
      return null;
    }
  }

  /// Exportar imagem como PDF
  Future<File> exportImageToPdf({
    required Uint8List imageBytes,
    required String title,
    required AppStrings strings,
  }) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/$title.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
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
          path.join(downloadsDir.path, '$sanitizedFileName.$extension');

      final file = File(filePath);
      await file.writeAsString(code);

      return filePath;
    } catch (e) {
      return null;
    }
  }

  /// Abrir arquivo exportado
  Future<void> openExportedFile(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      // Erro ao abrir arquivo
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

  /// Exportar markdown como PDF
  Future<String?> exportMarkdownAsPdf({
    required String markdown,
    required String title,
    String? author,
    String? subject,
  }) async {
    try {
      await _loadFonts();
      final pdf = pw.Document();

      // Usar o parser centralizado para garantir consistência com o preview
      final blocks = EnhancedMarkdownParser.parseMarkdown(markdown,
          enableHtmlEnhancements: true);

      // Converter blocos para widgets PDF
      final contentWidgets = await _convertBlocksToPdfWidgets(blocks);

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
                      font: _getDefaultFont(),
                      fontFallback: _getFontFallbacks(),
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
      return null;
    }
  }

  /// Converter blocos markdown para widgets PDF
  Future<List<pw.Widget>> _convertBlocksToPdfWidgets(
      List<MarkdownBlock> blocks) async {
    final widgets = <pw.Widget>[];

    for (final block in blocks) {
      switch (block.type) {
        case BlockType.heading:
          widgets.add(_createHeading(block.content, block.level!));
          widgets.add(pw.SizedBox(height: _getHeadingSpacing(block.level!)));
          break;

        case BlockType.paragraph:
          widgets.add(_createParagraph(block.content));
          widgets.add(pw.SizedBox(height: 12));
          break;

        case BlockType.listItem:
          widgets.add(_createListItem(block.content, block.listType!));
          widgets.add(pw.SizedBox(height: 4));
          break;

        case BlockType.code:
          widgets.add(_createCodeBlock(block.content, block.language ?? ''));
          widgets.add(pw.SizedBox(height: 16));
          break;

        case BlockType.blockquote:
          widgets.add(_createBlockquote(block.content));
          widgets.add(pw.SizedBox(height: 16));
          break;

        case BlockType.table:
          widgets.add(_createTable(block.content));
          widgets.add(pw.SizedBox(height: 16));
          break;

        case BlockType.horizontalRule:
          widgets.add(_createHorizontalRule());
          widgets.add(pw.SizedBox(height: 16));
          break;
      }
    }

    return widgets;
  }

  /// Criar título
  pw.Widget _createHeading(String text, int level) {
    final fontSize = _getHeadingFontSize(level);
    final fontWeight = pw.FontWeight.bold;

    // Processar elementos inline
    final inlineElements = EnhancedMarkdownParser.parseInlineText(text);
    final spans = <pw.InlineSpan>[];

    for (final element in inlineElements) {
      spans.add(_createInlineSpan(element, fontSize, fontWeight));
    }

    return pw.RichText(
      text: pw.TextSpan(children: spans),
    );
  }

  /// Criar parágrafo
  pw.Widget _createParagraph(String text) {
    // Processar elementos inline
    final inlineElements = EnhancedMarkdownParser.parseInlineText(text);
    final spans = <pw.InlineSpan>[];

    for (final element in inlineElements) {
      spans.add(_createInlineSpan(element, 14, pw.FontWeight.normal));
    }

    return pw.RichText(
      text: pw.TextSpan(children: spans),
    );
  }

  /// Criar item de lista
  pw.Widget _createListItem(String text, ListType listType) {
    final inlineElements = EnhancedMarkdownParser.parseInlineText(text);
    final spans = <pw.InlineSpan>[];

    for (final element in inlineElements) {
      spans.add(_createInlineSpan(element, 14, pw.FontWeight.normal));
    }

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
            text: pw.TextSpan(children: spans),
          ),
        ),
      ],
    );
  }

  /// Criar bloco de código
  pw.Widget _createCodeBlock(String code, String language) {
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
            offset: const PdfPoint(0.0, 2.0),
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
                  font: _getDefaultFont(),
                  fontFallback: _getFontFallbacks(),
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
              font: _getDefaultFont(),
              fontFallback: _getFontFallbacks(),
            ),
          ),
        ],
      ),
    );
  }

  /// Criar blockquote
  pw.Widget _createBlockquote(String text) {
    final inlineElements = EnhancedMarkdownParser.parseInlineText(text);
    final spans = <pw.InlineSpan>[];

    for (final element in inlineElements) {
      spans.add(_createInlineSpan(element, 14, pw.FontWeight.normal));
    }

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
        text: pw.TextSpan(children: spans),
      ),
    );
  }

  /// Criar tabela
  pw.Widget _createTable(String tableContent) {
    final rows = tableContent.split('\n');
    if (rows.isEmpty) return pw.SizedBox.shrink();

    final tableRows = <pw.TableRow>[];

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      final cells = row.split('|').map((cell) => cell.trim()).toList();

      // Remover células vazias no início e fim
      if (cells.isNotEmpty && cells.first.isEmpty) cells.removeAt(0);
      if (cells.isNotEmpty && cells.last.isEmpty)
        cells.removeAt(cells.length - 1);

      final tableCells = <pw.Widget>[];
      for (final cell in cells) {
        final isHeader = i == 0; // Primeira linha é cabeçalho
        tableCells.add(
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: isHeader ? PdfColors.grey100 : null,
            ),
            child: pw.Text(
              cell,
              style: pw.TextStyle(
                fontWeight:
                    isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
                fontSize: 12,
                font: _getDefaultFont(),
                fontFallback: _getFontFallbacks(),
              ),
            ),
          ),
        );
      }

      tableRows.add(pw.TableRow(children: tableCells));
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: tableRows,
    );
  }

  /// Criar linha horizontal
  pw.Widget _createHorizontalRule() {
    return pw.Container(
      height: 1,
      color: PdfColors.grey300,
    );
  }

  /// Criar span inline
  pw.InlineSpan _createInlineSpan(
      InlineElement element, double fontSize, pw.FontWeight fontWeight) {
    switch (element.type) {
      case InlineType.text:
        return pw.TextSpan(
          text: element.content,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: PdfColors.black,
            font: _getDefaultFont(),
            fontFallback: _getFontFallbacks(),
          ),
        );

      case InlineType.bold:
        return pw.TextSpan(
          text: element.content,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
            font: _getDefaultFont(),
            fontFallback: _getFontFallbacks(),
          ),
        );

      case InlineType.italic:
        return pw.TextSpan(
          text: element.content,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontStyle: pw.FontStyle.italic,
            color: PdfColors.black,
            font: _getDefaultFont(),
            fontFallback: _getFontFallbacks(),
          ),
        );

      case InlineType.code:
        return pw.TextSpan(
          text: element.content,
          style: pw.TextStyle(
            fontSize: fontSize - 1,
            fontWeight: fontWeight,
            color: PdfColors.black,
            font: _getDefaultFont(),
            fontFallback: _getFontFallbacks(),
          ),
        );

      case InlineType.latex:
        return pw.TextSpan(
          text: element.content,
          style: pw.TextStyle(
            fontSize: fontSize - 1,
            fontWeight: fontWeight,
            fontStyle: pw.FontStyle.italic,
            color: PdfColors.blue800,
            font: _getDefaultFont(),
            fontFallback: _getFontFallbacks(),
          ),
        );

      case InlineType.span:
        final styleMap = element.style != null
            ? EnhancedMarkdownParser.parseStyle(element.style!)
            : <String, dynamic>{};

        return pw.TextSpan(
          text: element.content,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: styleMap['color'] ?? PdfColors.black,
            fontStyle: styleMap['fontStyle'] ?? pw.FontStyle.normal,
            decoration: styleMap['decoration'] ?? pw.TextDecoration.none,
            font: _getDefaultFont(),
            fontFallback: _getFontFallbacks(),
          ),
        );

      case InlineType.kbd:
        return pw.TextSpan(
          text: element.content,
          style: pw.TextStyle(
            fontSize: fontSize - 1,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
            font: _getDefaultFont(),
            fontFallback: _getFontFallbacks(),
          ),
        );

      case InlineType.mark:
        return pw.TextSpan(
          text: element.content,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: PdfColors.black,
            font: _getDefaultFont(),
            fontFallback: _getFontFallbacks(),
          ),
        );

      case InlineType.subscript:
        return pw.TextSpan(
          text: element.content,
          style: pw.TextStyle(
            fontSize: fontSize * 0.7,
            fontWeight: fontWeight,
            color: PdfColors.black,
            font: _getDefaultFont(),
            fontFallback: _getFontFallbacks(),
          ),
        );

      case InlineType.superscript:
        return pw.TextSpan(
          text: element.content,
          style: pw.TextStyle(
            fontSize: fontSize * 0.7,
            fontWeight: fontWeight,
            color: PdfColors.black,
            font: _getDefaultFont(),
            fontFallback: _getFontFallbacks(),
          ),
        );
    }
  }

  /// Obter tamanho da fonte para títulos
  double _getHeadingFontSize(int level) {
    switch (level) {
      case 1:
        return 28.0;
      case 2:
        return 24.0;
      case 3:
        return 20.0;
      case 4:
        return 18.0;
      case 5:
        return 16.0;
      case 6:
        return 14.0;
      default:
        return 14.0;
    }
  }

  /// Obter espaçamento para títulos
  double _getHeadingSpacing(int level) {
    switch (level) {
      case 1:
        return 20.0;
      case 2:
        return 18.0;
      case 3:
        return 16.0;
      case 4:
        return 14.0;
      case 5:
        return 12.0;
      case 6:
        return 10.0;
      default:
        return 10.0;
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
    } else if (widget is pw.Table) {
      return 40.0; // Tabelas
    }
    return 20.0;
  }

  /// Gerar PDF como bytes em memória (para impressão)
  Future<Uint8List?> generatePdfBytes({
    required String markdown,
    required String title,
    String? author,
    String? subject,
  }) async {
    try {
      await _loadFonts();
      final pdf = pw.Document();

      // Sanitizar markdown para evitar problemas UTF-16
      String sanitizedMarkdown = _sanitizeText(markdown);

      // Usar o parser centralizado
      final blocks = EnhancedMarkdownParser.parseMarkdown(sanitizedMarkdown,
          enableHtmlEnhancements: true);
      final contentWidgets = await _convertBlocksToPdfWidgets(blocks);
      final pages = _splitContentIntoPages(contentWidgets, title);

      // Adicionar páginas ao PDF
      for (int i = 0; i < pages.length; i++) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            build: (pw.Context context) => pw.Column(
              children: [
                // Cabeçalho
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 20),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        title,
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          font: _getDefaultFont(),
                          fontFallback: _getFontFallbacks(),
                        ),
                      ),
                      pw.Text(
                        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey,
                          font: _getDefaultFont(),
                          fontFallback: _getFontFallbacks(),
                        ),
                      ),
                    ],
                  ),
                ),

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

      // Retornar bytes do PDF
      return await pdf.save();
    } catch (e) {
      return null;
    }
  }

  /// Sanitizar texto para evitar problemas UTF-16
  String _sanitizeText(String text) {
    if (text.isEmpty) return text;

    try {
      // Verificar se a string é válida UTF-16
      text.codeUnits;

      // Remover caracteres de controle problemáticos
      String sanitized =
          text.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

      // Garantir que não há caracteres nulos
      sanitized = sanitized.replaceAll('\x00', '');

      // Verificar novamente se é válida
      sanitized.codeUnits;

      return sanitized;
    } catch (e) {
      // Se houver erro, retornar string vazia
      return '';
    }
  }
}
