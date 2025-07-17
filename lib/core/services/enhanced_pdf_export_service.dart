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
    print('🔤 [PDF] Iniciando carregamento de fontes...');
    try {
      if (_notoSansFont == null) {
        print('🔤 [PDF] Carregando NotoSans-Regular.ttf...');
        _notoSansFont = pw.Font.ttf(
            await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
        print('✅ [PDF] NotoSans-Regular.ttf carregado com sucesso');
      }
      if (_notoEmojiFont == null) {
        print('🔤 [PDF] Carregando NotoColorEmoji.ttf...');
        _notoEmojiFont = pw.Font.ttf(
            await rootBundle.load('assets/fonts/NotoColorEmoji.ttf'));
        print('✅ [PDF] NotoColorEmoji.ttf carregado com sucesso');
      }
      print('✅ [PDF] Todas as fontes carregadas com sucesso');
    } catch (e) {
      print('❌ [PDF] Erro ao carregar fontes: $e');
      rethrow;
    }
  }

  /// Obter fonte padrão com fallback para emoji
  pw.Font _getDefaultFont() {
    print(
        '🔤 [PDF] Obtendo fonte padrão: ${_notoSansFont != null ? 'NotoSans' : 'Helvetica'}');
    return _notoSansFont ?? pw.Font.helvetica();
  }

  /// Obter fontes de fallback para emoji
  List<pw.Font> _getFontFallbacks() {
    final fallbacks = _notoEmojiFont != null ? [_notoEmojiFont!] : <pw.Font>[];
    print('🔤 [PDF] Fontes de fallback: ${fallbacks.length} fontes');
    return fallbacks;
  }

  /// Exportar widget como imagem
  Future<String?> exportWidgetAsImage({
    required GlobalKey widgetKey,
    required String fileName,
  }) async {
    print('🖼️ [PDF] Iniciando exportação de widget como imagem...');
    try {
      print('🖼️ [PDF] Obtendo RenderRepaintBoundary...');
      final RenderRepaintBoundary boundary =
          widgetKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      print('🖼️ [PDF] RenderRepaintBoundary obtido com sucesso');

      print('🖼️ [PDF] Convertendo para imagem...');
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      print('🖼️ [PDF] Imagem convertida com sucesso');

      print('🖼️ [PDF] Convertendo para bytes...');
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      print('🖼️ [PDF] Bytes obtidos: ${pngBytes.length} bytes');

      print('🖼️ [PDF] Obtendo diretório de downloads...');
      final downloadsDir = await _getDownloadsDirectory();
      print('🖼️ [PDF] Diretório: ${downloadsDir.path}');

      final sanitizedFileName = _sanitizeFileName(fileName);
      final filePath = path.join(downloadsDir.path, '$sanitizedFileName.png');
      print('🖼️ [PDF] Caminho do arquivo: $filePath');

      print('🖼️ [PDF] Salvando arquivo...');
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);
      print('✅ [PDF] Arquivo salvo com sucesso: $filePath');

      return filePath;
    } catch (e) {
      print('❌ [PDF] Erro ao exportar widget como imagem: $e');
      return null;
    }
  }

  /// Exportar imagem como PDF
  Future<File> exportImageToPdf({
    required Uint8List imageBytes,
    required String title,
    required AppStrings strings,
  }) async {
    print('📄 [PDF] Iniciando exportação de imagem para PDF...');
    try {
      final pdf = pw.Document();
      print('📄 [PDF] Documento PDF criado');

      final image = pw.MemoryImage(imageBytes);
      print('📄 [PDF] Imagem carregada: ${imageBytes.length} bytes');

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image),
            );
          },
        ),
      );
      print('📄 [PDF] Página adicionada ao PDF');

      print('📄 [PDF] Obtendo diretório temporário...');
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/$title.pdf");
      print('📄 [PDF] Caminho do arquivo: ${file.path}');

      print('📄 [PDF] Salvando PDF...');
      await file.writeAsBytes(await pdf.save());
      print('✅ [PDF] PDF salvo com sucesso: ${file.path}');

      return file;
    } catch (e) {
      print('❌ [PDF] Erro ao exportar imagem para PDF: $e');
      rethrow;
    }
  }

  /// Exportar código como arquivo de texto
  Future<String?> exportCodeAsFile({
    required String code,
    required String language,
    required String fileName,
  }) async {
    print('📝 [PDF] Iniciando exportação de código como arquivo...');
    try {
      print('📝 [PDF] Obtendo diretório de downloads...');
      final downloadsDir = await _getDownloadsDirectory();
      final sanitizedFileName = _sanitizeFileName(fileName);
      final extension = _getFileExtension(language);
      final filePath =
          path.join(downloadsDir.path, '$sanitizedFileName.$extension');
      print('📝 [PDF] Caminho do arquivo: $filePath');

      print('📝 [PDF] Salvando arquivo...');
      final file = File(filePath);
      await file.writeAsString(code);
      print('✅ [PDF] Arquivo salvo com sucesso: $filePath');

      return filePath;
    } catch (e) {
      print('❌ [PDF] Erro ao exportar código como arquivo: $e');
      return null;
    }
  }

  /// Abrir arquivo exportado
  Future<void> openExportedFile(String filePath) async {
    print('📂 [PDF] Abrindo arquivo: $filePath');
    try {
      await OpenFile.open(filePath);
      print('✅ [PDF] Arquivo aberto com sucesso');
    } catch (e) {
      print('❌ [PDF] Erro ao abrir arquivo: $e');
    }
  }

  /// Obter diretório de downloads
  Future<Directory> _getDownloadsDirectory() async {
    print('📁 [PDF] Obtendo diretório de downloads...');
    Directory downloadsDir;

    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
      print('📁 [PDF] Android: $downloadsDir');
    } else if (Platform.isIOS) {
      downloadsDir = await getApplicationDocumentsDirectory();
      print('📁 [PDF] iOS: $downloadsDir');
    } else if (Platform.isWindows) {
      downloadsDir =
          Directory('${Platform.environment['USERPROFILE']}\\Downloads');
      print('📁 [PDF] Windows: $downloadsDir');
    } else if (Platform.isMacOS) {
      downloadsDir = Directory('${Platform.environment['HOME']}/Downloads');
      print('📁 [PDF] macOS: $downloadsDir');
    } else {
      downloadsDir = await getApplicationDocumentsDirectory();
      print('📁 [PDF] Outro: $downloadsDir');
    }

    print('📁 [PDF] Diretório final: ${downloadsDir.path}');
    return downloadsDir;
  }

  /// Sanitizar nome de arquivo
  String _sanitizeFileName(String fileName) {
    final sanitized = fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
    print('📝 [PDF] Nome sanitizado: "$fileName" -> "$sanitized"');
    return sanitized;
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

    final extension = extensions[language.toLowerCase()] ?? 'txt';
    print('📝 [PDF] Extensão para linguagem "$language": $extension');
    return extension;
  }

  /// Exportar markdown como PDF
  Future<String?> exportMarkdownAsPdf({
    required String markdown,
    required String title,
    String? author,
    String? subject,
  }) async {
    print('📄 [PDF] ===== INICIANDO EXPORTAÇÃO MARKDOWN PARA PDF =====');
    print('📄 [PDF] Título: $title');
    print('📄 [PDF] Tamanho do markdown: ${markdown.length} caracteres');
    print('📄 [PDF] Autor: $author');
    print('📄 [PDF] Assunto: $subject');

    try {
      print('📄 [PDF] Carregando fontes...');
      await _loadFonts();
      print('✅ [PDF] Fontes carregadas com sucesso');

      print('📄 [PDF] Criando documento PDF...');
      final pdf = pw.Document();
      print('✅ [PDF] Documento PDF criado');

      print('📄 [PDF] Sanitizando markdown...');
      String sanitizedMarkdown = _sanitizeText(markdown);
      print(
          '📄 [PDF] Markdown sanitizado: ${sanitizedMarkdown.length} caracteres');

      print('📄 [PDF] Parsing markdown com EnhancedMarkdownParser...');
      final blocks = EnhancedMarkdownParser.parseMarkdown(sanitizedMarkdown,
          enableHtmlEnhancements: true);
      print('📄 [PDF] Blocos parseados: ${blocks.length} blocos');

      print('📄 [PDF] Convertendo blocos para widgets PDF...');
      final contentWidgets = await _convertBlocksToPdfWidgets(blocks);
      print('📄 [PDF] Widgets convertidos: ${contentWidgets.length} widgets');

      print('📄 [PDF] Dividindo conteúdo em páginas...');
      final pages = _splitContentIntoPages(contentWidgets, title);
      print('📄 [PDF] Páginas criadas: ${pages.length} páginas');

      print('📄 [PDF] Adicionando páginas ao PDF...');
      for (int i = 0; i < pages.length; i++) {
        print('📄 [PDF] Adicionando página ${i + 1}/${pages.length}');
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
      print('✅ [PDF] Todas as páginas adicionadas ao PDF');

      print('📄 [PDF] Obtendo diretório de downloads...');
      final downloadsDir = await _getDownloadsDirectory();
      final fileName =
          '${_sanitizeFileName(title)}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = path.join(downloadsDir.path, fileName);
      print('📄 [PDF] Caminho do arquivo: $filePath');

      print('📄 [PDF] Salvando PDF...');
      final file = File(filePath);
      final pdfBytes = await pdf.save();
      print('📄 [PDF] PDF gerado: ${pdfBytes.length} bytes');

      await file.writeAsBytes(pdfBytes);
      print('✅ [PDF] PDF salvo com sucesso: $filePath');

      return filePath;
    } catch (e, stackTrace) {
      print('❌ [PDF] Erro ao exportar markdown como PDF: $e');
      print('❌ [PDF] Stack trace: $stackTrace');
      return null;
    }
  }

  /// Converter blocos markdown para widgets PDF
  Future<List<pw.Widget>> _convertBlocksToPdfWidgets(
      List<MarkdownBlock> blocks) async {
    print('🔄 [PDF] Convertendo ${blocks.length} blocos para widgets PDF...');
    final widgets = <pw.Widget>[];

    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      print(
          '🔄 [PDF] Processando bloco ${i + 1}/${blocks.length}: ${block.type}');

      try {
        switch (block.type) {
          case BlockType.heading:
            print('🔄 [PDF] Criando heading nível ${block.level}');
            widgets.add(_createHeading(block.content, block.level!));
            widgets.add(pw.SizedBox(height: _getHeadingSpacing(block.level!)));
            break;

          case BlockType.paragraph:
            print('🔄 [PDF] Criando parágrafo');
            widgets.add(_createParagraph(block.content));
            widgets.add(pw.SizedBox(height: 12));
            break;

          case BlockType.listItem:
            print('🔄 [PDF] Criando item de lista');
            widgets.add(_createListItem(block.content, block.listType!));
            widgets.add(pw.SizedBox(height: 4));
            break;

          case BlockType.code:
            print(
                '🔄 [PDF] Criando bloco de código: ${block.language ?? 'text'}');
            widgets.add(_createCodeBlock(block.content, block.language ?? ''));
            widgets.add(pw.SizedBox(height: 16));
            break;

          case BlockType.blockquote:
            print('🔄 [PDF] Criando blockquote');
            widgets.add(_createBlockquote(block.content));
            widgets.add(pw.SizedBox(height: 16));
            break;

          case BlockType.table:
            print('🔄 [PDF] Criando tabela');
            widgets.add(_createTable(block.content));
            widgets.add(pw.SizedBox(height: 16));
            break;

          case BlockType.horizontalRule:
            print('🔄 [PDF] Criando linha horizontal');
            widgets.add(_createHorizontalRule());
            widgets.add(pw.SizedBox(height: 16));
            break;
        }
      } catch (e) {
        print('❌ [PDF] Erro ao processar bloco ${i + 1}: $e');
        // Adicionar widget de erro como fallback
        widgets.add(pw.Text('Erro ao processar conteúdo'));
      }
    }

    print('✅ [PDF] Conversão concluída: ${widgets.length} widgets criados');
    return widgets;
  }

  /// Criar título
  pw.Widget _createHeading(String text, int level) {
    print(
        '📝 [PDF] Criando heading nível $level: "${text.substring(0, text.length > 50 ? 50 : text.length)}..."');
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
    print(
        '📝 [PDF] Criando parágrafo: "${text.substring(0, text.length > 50 ? 50 : text.length)}..."');
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
    print(
        '📝 [PDF] Criando item de lista: "${text.substring(0, text.length > 50 ? 50 : text.length)}..."');
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
    print(
        '📝 [PDF] Criando bloco de código $language: ${code.length} caracteres');
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
    print(
        '📝 [PDF] Criando blockquote: "${text.substring(0, text.length > 50 ? 50 : text.length)}..."');
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
    print('📝 [PDF] Criando tabela: ${tableContent.length} caracteres');
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
    print('📝 [PDF] Criando linha horizontal');
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
    print('📄 [PDF] Dividindo ${widgets.length} widgets em páginas...');
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

    print('📄 [PDF] Páginas criadas: ${pages.length} páginas');
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
    print('🖨️ [PDF] ===== INICIANDO GERAÇÃO DE PDF PARA IMPRESSÃO =====');
    print('🖨️ [PDF] Título: $title');
    print('🖨️ [PDF] Tamanho do markdown: ${markdown.length} caracteres');

    try {
      print('🖨️ [PDF] Carregando fontes...');
      await _loadFonts();
      print('✅ [PDF] Fontes carregadas com sucesso');

      print('🖨️ [PDF] Criando documento PDF...');
      final pdf = pw.Document();
      print('✅ [PDF] Documento PDF criado');

      print('🖨️ [PDF] Sanitizando markdown...');
      String sanitizedMarkdown = _sanitizeText(markdown);
      print(
          '🖨️ [PDF] Markdown sanitizado: ${sanitizedMarkdown.length} caracteres');

      print('🖨️ [PDF] Parsing markdown...');
      final blocks = EnhancedMarkdownParser.parseMarkdown(sanitizedMarkdown,
          enableHtmlEnhancements: true);
      print('🖨️ [PDF] Blocos parseados: ${blocks.length} blocos');

      print('🖨️ [PDF] Convertendo blocos para widgets PDF...');
      final contentWidgets = await _convertBlocksToPdfWidgets(blocks);
      print('🖨️ [PDF] Widgets convertidos: ${contentWidgets.length} widgets');

      print('🖨️ [PDF] Dividindo conteúdo em páginas...');
      final pages = _splitContentIntoPages(contentWidgets, title);
      print('🖨️ [PDF] Páginas criadas: ${pages.length} páginas');

      print('🖨️ [PDF] Adicionando páginas ao PDF...');
      for (int i = 0; i < pages.length; i++) {
        print('🖨️ [PDF] Adicionando página ${i + 1}/${pages.length}');
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
      print('✅ [PDF] Todas as páginas adicionadas ao PDF');

      print('🖨️ [PDF] Gerando bytes do PDF...');
      final pdfBytes = await pdf.save();
      print('✅ [PDF] PDF gerado com sucesso: ${pdfBytes.length} bytes');

      return pdfBytes;
    } catch (e, stackTrace) {
      print('❌ [PDF] Erro ao gerar PDF para impressão: $e');
      print('❌ [PDF] Stack trace: $stackTrace');
      return null;
    }
  }

  /// Sanitizar texto para evitar problemas UTF-16
  String _sanitizeText(String text) {
    print('🧹 [PDF] Sanitizando texto: ${text.length} caracteres');
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

      print('🧹 [PDF] Texto sanitizado: ${sanitized.length} caracteres');
      return sanitized;
    } catch (e) {
      print('❌ [PDF] Erro ao sanitizar texto: $e');
      // Se houver erro, retornar string vazia
      return '';
    }
  }
}
