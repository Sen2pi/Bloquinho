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
import 'package:flutter/widgets.dart' as fw;
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import 'enhanced_markdown_parser.dart';
import '../../../features/bloquinho/widgets/windows_code_block_widget.dart';

class EnhancedPdfExportService {
  pw.Font? _notoSansFont;
  pw.Font? _notoSansBoldFont;
  pw.Font? _notoEmojiFont;

  /// Carregar fontes Unicode e emoji
  Future<void> _loadFonts() async {
    try {
      if (_notoSansFont == null) {
        try {
          _notoSansFont = pw.Font.ttf(
              await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
        } catch (e) {
          _notoSansFont = pw.Font.helvetica();
        }
      }
      if (_notoEmojiFont == null) {
        try {
          _notoEmojiFont = pw.Font.ttf(
              await rootBundle.load('assets/fonts/NotoColorEmoji.ttf'));
        } catch (e) {
          _notoEmojiFont = null;
        }
      }
    } catch (e) {
      _notoSansFont = pw.Font.helvetica();
      _notoEmojiFont = null;
    }
  }

  /// Obter fonte padrão com fallback para emoji
  pw.Font _getDefaultFont() {
    return _notoSansFont ?? pw.Font.helvetica();
  }

  /// Obter fontes de fallback para emoji
  List<pw.Font> _getFontFallbacks() {
    final fallbacks = _notoEmojiFont != null ? [_notoEmojiFont!] : <pw.Font>[];
    return fallbacks;
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
    try {
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
    } catch (e) {
      rethrow;
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
    } catch (e) {}
  }

  /// Obter diretório de downloads
  Future<Directory> _getDownloadsDirectory() async {
    Directory downloadsDir;

    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      downloadsDir = await getApplicationDocumentsDirectory();
    } else if (Platform.isWindows) {
      downloadsDir =
          Directory('${Platform.environment['USERPROFILE']}\\Downloads');
    } else if (Platform.isMacOS) {
      downloadsDir = Directory('${Platform.environment['HOME']}/Downloads');
    } else {
      downloadsDir = await getApplicationDocumentsDirectory();
    }

    return downloadsDir;
  }

  /// Sanitizar nome de arquivo
  String _sanitizeFileName(String fileName) {
    final sanitized = fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
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
    return extension;
  }

  /// Exportar markdown como PDF
  Future<String?> exportMarkdownAsPdf({
    required String markdown,
    required String title,
    required AppStrings strings,
  }) async {
    try {
      await _loadFonts();

      final pdf = pw.Document(
        title: title,
        author: 'Bloquinho App',
        subject: 'Documento exportado do Bloquinho',
      );

      final sanitizedMarkdown = _sanitizeText(markdown);

      final blocks = EnhancedMarkdownParser.parseMarkdown(sanitizedMarkdown);

      final widgets = await _convertBlocksToPdfWidgets(blocks);

      final pages = _splitIntoPages(widgets);

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
                      style: pw.TextStyle(
                        fontSize: 10,
                        font: _getDefaultFont(),
                        fontFallback: _getFontFallbacks(),
                      ),
                    ),
                    pw.Text(
                      'Página ${i + 1} de ${pages.length}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        font: _getDefaultFont(),
                        fontFallback: _getFontFallbacks(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }

      final downloadsDir = await _getDownloadsDirectory();
      final fileName =
          '${_sanitizeFileName(title)}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = path.join(downloadsDir.path, fileName);
      final file = File(filePath);
      final pdfBytes = await pdf.save();
      try {
        await file.writeAsBytes(pdfBytes);
      } catch (e) {
        return null;
      }

      return filePath;
    } catch (e, stackTrace) {
      return null;
    }
  }

  /// Converter blocos markdown para widgets PDF
  Future<List<pw.Widget>> _convertBlocksToPdfWidgets(
      List<MarkdownBlock> blocks) async {
    final widgets = <pw.Widget>[];

    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];

      try {
        switch (block.type) {
          case BlockType.heading:
            widgets.add(_createHeading(
                _replaceEmojisWithText(block.content), block.level!));
            widgets.add(pw.SizedBox(height: _getHeadingSpacing(block.level!)));
            break;

          case BlockType.paragraph:
            widgets
                .add(_createParagraph(_replaceEmojisWithText(block.content)));
            widgets.add(pw.SizedBox(height: 8));
            break;

          case BlockType.code:
            widgets.add(_createCodeBlock(block.content, block.language ?? ''));
            widgets.add(pw.SizedBox(height: 12));
            break;

          case BlockType.listItem:
            widgets.add(_createListItem(_replaceEmojisWithText(block.content)));
            widgets.add(pw.SizedBox(height: 4));
            break;

          case BlockType.blockquote:
            widgets
                .add(_createBlockquote(_replaceEmojisWithText(block.content)));
            widgets.add(pw.SizedBox(height: 16));
            break;

          case BlockType.table:
            widgets.add(_createTable(_replaceEmojisWithText(block.content)));
            widgets.add(pw.SizedBox(height: 16));
            break;

          case BlockType.horizontalRule:
            widgets.add(_createHorizontalRule());
            widgets.add(pw.SizedBox(height: 16));
            break;

          default:
            widgets
                .add(_createParagraph(_replaceEmojisWithText(block.content)));
            widgets.add(pw.SizedBox(height: 8));
            break;
        }
      } catch (e) {
        // Fallback: criar parágrafo simples
        widgets.add(_createParagraph(_replaceEmojisWithText(block.content)));
        widgets.add(pw.SizedBox(height: 8));
      }
    }

    return widgets;
  }

  /// Criar heading
  pw.Widget _createHeading(String content, int level) {
    final fontSize = _getHeadingFontSize(level);
    final fontWeight = _getHeadingFontWeight(level);

    return pw.Text(
      _replaceEmojisWithText(content),
      style: pw.TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        font: _getDefaultFont(),
        fontFallback: _getFontFallbacks(),
      ),
    );
  }

  /// Criar parágrafo
  pw.Widget _createParagraph(String content) {
    return pw.Text(
      _replaceEmojisWithText(content),
      style: pw.TextStyle(
        fontSize: 12,
        font: _getDefaultFont(),
        fontFallback: _getFontFallbacks(),
      ),
    );
  }

  /// Criar bloco de código
  pw.Widget _createCodeBlock(String code, String language) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (language.isNotEmpty)
            pw.Text(
              language.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                font: _getDefaultFont(),
                fontFallback: _getFontFallbacks(),
              ),
            ),
          pw.SizedBox(height: 4),
          pw.Text(
            code,
            style: pw.TextStyle(
              fontSize: 10,
              font: _getDefaultFont(),
              fontFallback: _getFontFallbacks(),
            ),
          ),
        ],
      ),
    );
  }

  /// Criar item de lista
  pw.Widget _createListItem(String content) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 6,
          height: 6,
          margin: const pw.EdgeInsets.only(top: 8, right: 12),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xFF007BFF),
            shape: pw.BoxShape.circle,
          ),
        ),
        pw.Expanded(
          child: pw.RichText(
            text: pw.TextSpan(children: [
              pw.TextSpan(
                text: '•',
                style: pw.TextStyle(
                  fontSize: 12,
                  font: _getDefaultFont(),
                  fontFallback: _getFontFallbacks(),
                ),
              ),
              pw.TextSpan(
                text: _replaceEmojisWithText(content),
                style: pw.TextStyle(
                  fontSize: 12,
                  font: _getDefaultFont(),
                  fontFallback: _getFontFallbacks(),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  /// Criar blockquote
  pw.Widget _createBlockquote(String content) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(
            color: PdfColor.fromInt(0xFF007BFF),
            width: 4,
          ),
        ),
        color: PdfColor.fromInt(0xFF282C34),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.RichText(
        text: pw.TextSpan(children: [
          pw.TextSpan(
            text: '“',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromInt(0xFF888888),
              font: _getDefaultFont(),
              fontFallback: _getFontFallbacks(),
            ),
          ),
          pw.TextSpan(
            text: _replaceEmojisWithText(content),
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColor.fromInt(0xFFE0E0E0),
              height: 1.4,
              font: _getDefaultFont(),
              fontFallback: _getFontFallbacks(),
            ),
          ),
          pw.TextSpan(
            text: '”',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromInt(0xFF888888),
              font: _getDefaultFont(),
              fontFallback: _getFontFallbacks(),
            ),
          ),
        ]),
      ),
    );
  }

  /// Criar linha horizontal
  pw.Widget _createHorizontalRule() {
    return pw.Container(
      height: 1,
      color: PdfColor.fromInt(0xFF44475A),
    );
  }

  /// Criar tabela
  pw.Widget _createTable(String content) {
    final rows = content.split('\n');
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
              color: isHeader ? PdfColor.fromInt(0xFF44475A) : null,
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
      border: pw.TableBorder.all(color: PdfColor.fromInt(0xFF44475A)),
      children: tableRows,
    );
  }

  /// Substitui emojis por texto alternativo
  String _replaceEmojisWithText(String text) {
    String result = text;

    // Primeiro, remover caracteres de controle problemáticos
    result =
        result.replaceAll(RegExp(r'\uFE0F\uFE0E'), ''); // Variation Selectors

    // Substituir emojis conhecidos
    final emojiMap = {
      '📊': '[DIAGRAMA]',
      '🎨': '[ARTE]',
      '💻': '[CÓDIGO]',
      '🔢': '[MATEMÁTICA]',
      '📝': '[DOCUMENTO]',
      '📈': '[GRÁFICO]',
      '🔧': '[FERRAMENTA]',
      '✅': '[OK]',
      '❌': '[ERRO]',
      '⚠️': '[AVISO]',
      '💡': '[IDÉIA]',
      '🚀': '[LANÇAMENTO]',
      '🎯': '[OBJETIVO]',
      '📚': '[LIVRO]',
      '🔍': '[BUSCA]',
      '⚡': '[RÁPIDO]',
      '🌟': '[ESTRELA]',
      '💪': '[FORÇA]',
      '🎉': '[CELEBRAÇÃO]',
      '🔥': '[FOGO]',
      '📱': '[MOBILE]',
      '💻': '[COMPUTADOR]',
      '🌐': '[WEB]',
      '🔐': '[SEGURANÇA]',
      '📊': '[ESTATÍSTICA]',
      '🎮': '[JOGO]',
      '🎵': '[MÚSICA]',
      '📷': '[FOTO]',
      '🎬': '[VÍDEO]',
      '📞': '[TELEFONE]',
      '📧': '[EMAIL]',
      '💼': '[TRABALHO]',
      '🏠': '[CASA]',
      '🚗': '[CARRO]',
      '✈️': '[AVIÃO]',
      '🚇': '[METRÔ]',
      '🚌': '[ÔNIBUS]',
      '🚲': '[BICICLETA]',
      '🏃': '[CORRIDA]',
      '🏋️': '[MUSCULAÇÃO]',
      '⚽': '[FUTEBOL]',
      '🏀': '[BASQUETE]',
      '🎾': '[TÊNIS]',
      '🏊': '[NATAÇÃO]',
      '🎯': '[ALVO]',
      '🎪': '[CIRCO]',
      '🎭': '[TEATRO]',
      '🎤': '[MICROFONE]',
      '🎧': '[FONES]',
      '📺': '[TV]',
      '🎮': '[GAME]',
      '🖥️': '[MONITOR]',
      '⌨️': '[TECLADO]',
      '🖱️': '[MOUSE]',
      '💾': '[DISCO]',
      '📀': '[CD]',
      '💿': '[DVD]',
      '📼': '[FITA]',
      '📷': '[CÂMERA]',
      '📹': '[VÍDEO]',
      '🎥': '[FILME]',
      '📺': '[TV]',
      '📻': '[RÁDIO]',
      '🎙️': '[MICROFONE]',
      '🎚️': '[CONTROLE]',
      '🎛️': '[KNOB]',
      '📱': '[CELULAR]',
      '📲': '[SMARTPHONE]',
      '☎️': '[TELEFONE]',
      '📞': '[TELEFONE]',
      '📟': '[PAGER]',
      '🎞': '[FAX]',
      '🔋': '[BATERIA]',
      '🔌': '[PLUG]',
      '💡': '[LÂMPADA]',
      '🔦': '[LANTERNA]',
      '��️': '[VELA]',
      '🪔': '[DIYA]',
      '🧯': '[EXTINTOR]',
      '🛢️': '[ÓLEO]',
      '💸': '[DINHEIRO]',
      '💵': '[NOTA]',
      '💴': '[YEN]',
      '💶': '[EURO]',
      '💷': '[LIBRA]',
      '💰': '[BOLSA]',
      '💳': '[CARTÃO]',
      '💎': '[DIAMANTE]',
      '⚖️': '[BALANÇA]',
      '🪜': '[ESCADA]',
      '🛠️': '[FERRAMENTAS]',
      '🔨': '[MARTELO]',
      '⚒️': '[MARTELO]',
      '🪛': '[CHAVE]',
      '🔧': '[CHAVE]',
      '⚙️': '[ENGRENAGEM]',
      '🗜️': '[COMPRESSOR]',
      '⚗️': '[BALÃO]',
      '🧪': '[TUBO]',
      '🧫': '[PLACA]',
      '��': '[DNA]',
      '🔬': '[MICROSCÓPIO]',
      '🔭': '[TELESCÓPIO]',
      '📡': '[SATELLITE]',
      '💉': '[SERINGA]',
      '🩸': '[SANGUE]',
      '💊': '[PÍLULA]',
      '🩹': '[CURATIVO]',
      '🩺': '[ESTETOSCÓPIO]',
      '🩻': '[RAIO-X]',
      '🩼': '[MULETA]',
      '🩽': '[CADEIRA]',
      '🩾': '[BRAÇO]',
      '🩿': '[PERNA]',
      '🪖': '[CAPACETE]',
      '🪗': '[ACORDEÃO]',
      '🪘': '[TAMBOR]',
      '🪙': '[MOEDA]',
      '🪚': '[SERRA]',
      '🪛': '[CHAVE]',
      '🪜': '[ESCADA]',
      '🪝': '[GANCHO]',
      '🪞': '[ESPELHO]',
      '🪟': '[JANELA]',
      '🪠': '[DESENTUPIDOR]',
      '🪡': '[AGULHA]',
      '🪢': '[NÓ]',
      '🪣': '[BALDE]',
      '🪤': '[RATOEIRA]',
      '🪥': '[ESCOVA]',
      '🪦': '[TÚMULO]',
      '🪧': '[PLACA]',
      '🪨': '[ROCHA]',
      '🪩': '[DISCO]',
      '🪪': '[IDENTIDADE]',
      '🪫': '[BATERIA]',
      '🪬': '[AMULETO]',
      '🪭': '[LEQUE]',
      '🪮': '[PENTE]',
      '🪯': '[RODA]',
      '🪰': '[MOSCA]',
      '🪱': '[MINHOCA]',
      '🪲': '[BESOURO]',
      '🪳': '[BARATA]',
      '🪴': '[PLANTA]',
      '🪵': '[MADEIRA]',
      '🪶': '[PENA]',
      '🪷': '[LÓTUS]',
      '🪸': '[CORAL]',
      '🪹': '[NINHO]',
      '🪺': '[OVO]',
      '🫀': '[CORAÇÃO]',
      '🫁': '[PULMÃO]',
      '🫂': '[ABRAÇO]',
      '🫃': '[GRAVIDEZ]',
      '🫄': '[GRAVIDEZ]',
      '🫅': '[PESSOA]',
      '🫆': '[PESSOA]',
      '🫇': '[PESSOA]',
      '🫈': '[PESSOA]',
      '🫉': '[PESSOA]',
      '🫊': '[PESSOA]',
      '🫋': '[PESSOA]',
      '🫌': '[PESSOA]',
      '🫍': '[PESSOA]',
      '🫎': '[PESSOA]',
      '🫏': '[PESSOA]',
      '🫐': '[MIRTILO]',
      '🫑': '[PIMENTÃO]',
      '🫒': '[AZEITONA]',
      '🫓': '[PÃO]',
      '🫔': '[TAMALE]',
      '🫕': '[FONDUE]',
      '🫖': '[CHALEIRA]',
      '🫗': '[BEBIDA]',
      '🫘': '[FEIJÃO]',
      '🫙': '[JARRO]',
      '🫚': '[GENGIBRE]',
      '🫛': '[ERVILHA]',
      '🫜': '[FOLHA]',
      '🫝': '[FOLHA]',
      '🫞': '[FOLHA]',
      '🫟': '[FOLHA]',
      '🫠': '[DERRETENDO]',
      '🫡': '[SALUTA]',
      '🫢': '[SURPRESO]',
      '🫣': '[ESPIANDO]',
      '🫤': '[NEUTRO]',
      '🫥': '[LINHA]',
      '🫦': '[MORDENDO]',
      '🫧': '[BOLHAS]',
      '🫨': '[TREMENDO]',
      '🫩': '[PESSOA]',
      '🫪': '[PESSOA]',
      '🫫': '[PESSOA]',
      '🫬': '[PESSOA]',
      '🫭': '[PESSOA]',
      '🫮': '[PESSOA]',
      '🫯': '[PESSOA]',
      '🫰': '[PESSOA]',
      '🫱': '[PESSOA]',
      '🫲': '[PESSOA]',
      '🫳': '[PESSOA]',
      '🫴': '[PESSOA]',
      '🫵': '[PESSOA]',
      '🫶': '[PESSOA]',
      '🫷': '[PESSOA]',
      '🫸': '[PESSOA]',
      '🫹': '[PESSOA]',
      '🫺': '[PESSOA]',
      '🫻': '[PESSOA]',
      '🫼': '[PESSOA]',
      '🫽': '[PESSOA]',
      '🫾': '[PESSOA]',
      '🫿': '[PESSOA]',
      '🬀': '[SÍMBOLO]',
      '🬁': '[SÍMBOLO]',
      '🬂': '[SÍMBOLO]',
      '🬃': '[SÍMBOLO]',
      '🬄': '[SÍMBOLO]',
      '🬅': '[SÍMBOLO]',
      '🬆': '[SÍMBOLO]',
      '🬇': '[SÍMBOLO]',
      '🬈': '[SÍMBOLO]',
      '🬉': '[SÍMBOLO]',
      '🬊': '[SÍMBOLO]',
      '🬋': '[SÍMBOLO]',
      '🬌': '[SÍMBOLO]',
      '🬍': '[SÍMBOLO]',
      '🬎': '[SÍMBOLO]',
      '🬏': '[SÍMBOLO]',
      '🬐': '[SÍMBOLO]',
      '🬑': '[SÍMBOLO]',
      '🬒': '[SÍMBOLO]',
      '🬓': '[SÍMBOLO]',
      '🬔': '[SÍMBOLO]',
      '🬕': '[SÍMBOLO]',
      '🬖': '[SÍMBOLO]',
      '🬗': '[SÍMBOLO]',
      '🬘': '[SÍMBOLO]',
      '🬙': '[SÍMBOLO]',
      '🬚': '[SÍMBOLO]',
      '🬛': '[SÍMBOLO]',
      '🬜': '[SÍMBOLO]',
      '🬝': '[SÍMBOLO]',
      '🬞': '[SÍMBOLO]',
      '🬟': '[SÍMBOLO]',
      '🬠': '[SÍMBOLO]',
      '🬡': '[SÍMBOLO]',
      '🬢': '[SÍMBOLO]',
      '🬣': '[SÍMBOLO]',
      '🬤': '[SÍMBOLO]',
      '🬥': '[SÍMBOLO]',
      '🬦': '[SÍMBOLO]',
      '🬧': '[SÍMBOLO]',
      '🬨': '[SÍMBOLO]',
      '🬩': '[SÍMBOLO]',
      '🬪': '[SÍMBOLO]',
      '🬫': '[SÍMBOLO]',
      '🬬': '[SÍMBOLO]',
      '🬭': '[SÍMBOLO]',
      '🬮': '[SÍMBOLO]',
      '🬯': '[SÍMBOLO]',
      '🬰': '[SÍMBOLO]',
      '🬱': '[SÍMBOLO]',
      '🬲': '[SÍMBOLO]',
      '🬳': '[SÍMBOLO]',
      '🬴': '[SÍMBOLO]',
      '🬵': '[SÍMBOLO]',
      '🬶': '[SÍMBOLO]',
      '🬷': '[SÍMBOLO]',
      '🬸': '[SÍMBOLO]',
      '🬹': '[SÍMBOLO]',
      '🬺': '[SÍMBOLO]',
      '🬻': '[SÍMBOLO]',
      '🬼': '[SÍMBOLO]',
      '🬽': '[SÍMBOLO]',
      '🬾': '[SÍMBOLO]',
      '🬿': '[SÍMBOLO]',
      '🭀': '[SÍMBOLO]',
      '🭁': '[SÍMBOLO]',
      '🭂': '[SÍMBOLO]',
      '🭃': '[SÍMBOLO]',
      '🭄': '[SÍMBOLO]',
      '🭅': '[SÍMBOLO]',
      '🭆': '[SÍMBOLO]',
      '🭇': '[SÍMBOLO]',
      '🭈': '[SÍMBOLO]',
      '🭉': '[SÍMBOLO]',
      '🭊': '[SÍMBOLO]',
      '🭋': '[SÍMBOLO]',
      '🭌': '[SÍMBOLO]',
      '🭍': '[SÍMBOLO]',
      '🭎': '[SÍMBOLO]',
      '🭏': '[SÍMBOLO]',
      '🭐': '[SÍMBOLO]',
      '🭑': '[SÍMBOLO]',
      '🭒': '[SÍMBOLO]',
      '🭓': '[SÍMBOLO]',
      '🭔': '[SÍMBOLO]',
      '🭕': '[SÍMBOLO]',
      '🭖': '[SÍMBOLO]',
      '🭗': '[SÍMBOLO]',
      '🭘': '[SÍMBOLO]',
      '🭙': '[SÍMBOLO]',
      '🭚': '[SÍMBOLO]',
      '🭛': '[SÍMBOLO]',
      '🭜': '[SÍMBOLO]',
      '🭝': '[SÍMBOLO]',
      '🭞': '[SÍMBOLO]',
      '🭟': '[SÍMBOLO]',
      '🭠': '[SÍMBOLO]',
      '🭡': '[SÍMBOLO]',
      '🭢': '[SÍMBOLO]',
      '🭣': '[SÍMBOLO]',
      '🭤': '[SÍMBOLO]',
      '🭥': '[SÍMBOLO]',
      '🭦': '[SÍMBOLO]',
      '🭧': '[SÍMBOLO]',
      '🭨': '[SÍMBOLO]',
      '🭩': '[SÍMBOLO]',
      '🭪': '[SÍMBOLO]',
      '🭫': '[SÍMBOLO]',
      '🭬': '[SÍMBOLO]',
      '🭭': '[SÍMBOLO]',
      '🭮': '[SÍMBOLO]',
      '🭯': '[SÍMBOLO]',
      '🭰': '[SÍMBOLO]',
      '🭱': '[SÍMBOLO]',
      '🭲': '[SÍMBOLO]',
      '🭳': '[SÍMBOLO]',
      '🭴': '[SÍMBOLO]',
      '🭵': '[SÍMBOLO]',
      '🭶': '[SÍMBOLO]',
      '🭷': '[SÍMBOLO]',
      '🭸': '[SÍMBOLO]',
      '🭹': '[SÍMBOLO]',
      '🭺': '[SÍMBOLO]',
      '🭻': '[SÍMBOLO]',
      '🭼': '[SÍMBOLO]',
      '🭽': '[SÍMBOLO]',
      '🭾': '[SÍMBOLO]',
      '🭿': '[SÍMBOLO]',
      '🮀': '[SÍMBOLO]',
      '🮁': '[SÍMBOLO]',
      '🮂': '[SÍMBOLO]',
      '🮃': '[SÍMBOLO]',
      '🮄': '[SÍMBOLO]',
      '🮅': '[SÍMBOLO]',
      '🮆': '[SÍMBOLO]',
      '🮇': '[SÍMBOLO]',
      '🮈': '[SÍMBOLO]',
      '🮉': '[SÍMBOLO]',
      '🮊': '[SÍMBOLO]',
      '🮋': '[SÍMBOLO]',
      '🮌': '[SÍMBOLO]',
      '🮍': '[SÍMBOLO]',
      '🮎': '[SÍMBOLO]',
      '🮏': '[SÍMBOLO]',
      '🮐': '[SÍMBOLO]',
      '🮑': '[SÍMBOLO]',
      '🮒': '[SÍMBOLO]',
      '🮓': '[SÍMBOLO]',
      '🮔': '[SÍMBOLO]',
      '🮕': '[SÍMBOLO]',
      '🮖': '[SÍMBOLO]',
      '🮗': '[SÍMBOLO]',
      '🮘': '[SÍMBOLO]',
      '🮙': '[SÍMBOLO]',
      '🮚': '[SÍMBOLO]',
      '🮛': '[SÍMBOLO]',
      '🮜': '[SÍMBOLO]',
      '🮝': '[SÍMBOLO]',
      '🮞': '[SÍMBOLO]',
      '🮟': '[SÍMBOLO]',
      '🮠': '[SÍMBOLO]',
      '🮡': '[SÍMBOLO]',
      '🮢': '[SÍMBOLO]',
      '🮣': '[SÍMBOLO]',
      '🮤': '[SÍMBOLO]',
      '🮥': '[SÍMBOLO]',
      '🮦': '[SÍMBOLO]',
      '🮧': '[SÍMBOLO]',
      '🮨': '[SÍMBOLO]',
      '🮩': '[SÍMBOLO]',
      '🮪': '[SÍMBOLO]',
      '🮫': '[SÍMBOLO]',
      '🮬': '[SÍMBOLO]',
      '🮭': '[SÍMBOLO]',
      '🮮': '[SÍMBOLO]',
      '🮯': '[SÍMBOLO]',
      '🮰': '[SÍMBOLO]',
      '🮱': '[SÍMBOLO]',
      '🮲': '[SÍMBOLO]',
      '🮳': '[SÍMBOLO]',
      '🮴': '[SÍMBOLO]',
      '🮵': '[SÍMBOLO]',
      '🮶': '[SÍMBOLO]',
      '🮷': '[SÍMBOLO]',
      '🮸': '[SÍMBOLO]',
      '🮹': '[SÍMBOLO]',
      '🮺': '[SÍMBOLO]',
      '🮻': '[SÍMBOLO]',
      '🮼': '[SÍMBOLO]',
      '🮽': '[SÍMBOLO]',
      '🮾': '[SÍMBOLO]',
      '🮿': '[SÍMBOLO]',
      '🯀': '[SÍMBOLO]',
      '🯁': '[SÍMBOLO]',
      '🯂': '[SÍMBOLO]',
      '🯃': '[SÍMBOLO]',
      '🯄': '[SÍMBOLO]',
      '🯅': '[SÍMBOLO]',
      '🯆': '[SÍMBOLO]',
      '🯇': '[SÍMBOLO]',
      '🯈': '[SÍMBOLO]',
      '🯉': '[SÍMBOLO]',
      '🯊': '[SÍMBOLO]',
      '🯋': '[SÍMBOLO]',
      '🯌': '[SÍMBOLO]',
      '🯍': '[SÍMBOLO]',
      '🯎': '[SÍMBOLO]',
      '🯏': '[SÍMBOLO]',
      '🯐': '[SÍMBOLO]',
      '🯑': '[SÍMBOLO]',
      '🯒': '[SÍMBOLO]',
      '🯓': '[SÍMBOLO]',
      '🯔': '[SÍMBOLO]',
      '🯕': '[SÍMBOLO]',
      '🯖': '[SÍMBOLO]',
      '🯗': '[SÍMBOLO]',
      '🯘': '[SÍMBOLO]',
      '🯙': '[SÍMBOLO]',
      '🯚': '[SÍMBOLO]',
      '🯛': '[SÍMBOLO]',
      '🯜': '[SÍMBOLO]',
      '🯝': '[SÍMBOLO]',
      '🯞': '[SÍMBOLO]',
      '🯟': '[SÍMBOLO]',
      '🯠': '[SÍMBOLO]',
      '🯡': '[SÍMBOLO]',
      '🯢': '[SÍMBOLO]',
      '🯣': '[SÍMBOLO]',
      '🯤': '[SÍMBOLO]',
      '🯥': '[SÍMBOLO]',
      '🯦': '[SÍMBOLO]',
      '🯧': '[SÍMBOLO]',
      '🯨': '[SÍMBOLO]',
      '🯩': '[SÍMBOLO]',
      '🯪': '[SÍMBOLO]',
      '🯫': '[SÍMBOLO]',
      '🯬': '[SÍMBOLO]',
      '🯭': '[SÍMBOLO]',
      '🯮': '[SÍMBOLO]',
      '🯯': '[SÍMBOLO]',
      '🯰': '[SÍMBOLO]',
      '🯱': '[SÍMBOLO]',
      '🯲': '[SÍMBOLO]',
      '🯳': '[SÍMBOLO]',
      '🯴': '[SÍMBOLO]',
      '🯵': '[SÍMBOLO]',
      '🯶': '[SÍMBOLO]',
      '🯷': '[SÍMBOLO]',
      '🯸': '[SÍMBOLO]',
      '🯹': '[SÍMBOLO]',
      '🯺': '[SÍMBOLO]',
      '🯻': '[SÍMBOLO]',
      '🯼': '[SÍMBOLO]',
      '🯽': '[SÍMBOLO]',
      '🯾': '[SÍMBOLO]',
      '🯿': '[SÍMBOLO]',
    };

    emojiMap.forEach((emoji, replacement) {
      result = result.replaceAll(emoji, replacement);
    });

    // Remover outros caracteres Unicode problemáticos
    result = result.replaceAll(
        RegExp(r'\u{1F600}-\u{1F64F}]'), '[EMOJI]'); // Emojis faciais
    result = result.replaceAll(
        RegExp(r'\u{1F300}-\u{1F5FF}]'), '[SÍMBOLO]'); // Misc Symbols
    result = result.replaceAll(
        RegExp(r'\u{1F680}-\u{1F6FF}]'), '[TRANSPORTE]'); // Transport
    result = result.replaceAll(
        RegExp(r'\u{1F1}-\u{1FF}'), '[BANDEIRA]'); // Regional Indicators
    result = result.replaceAll(
        RegExp(r'\u{2600}-\u{26FF}'), '[SÍMBOLO]'); // Misc Symbols
    result = result.replaceAll(
        RegExp(r'\u{2700}-\u{27BF}'), '[SÍMBOLO]'); // Dingbats

    return result;
  }

  /// Obter tamanho da fonte para heading
  double _getHeadingFontSize(int level) {
    switch (level) {
      case 1:
        return 24.0;
      case 2:
        return 20.0;
      case 3:
        return 18.0;
      case 4:
        return 16.0;
      case 5:
        return 14.0;
      case 6:
        return 12.0;
      default:
        return 12.0;
    }
  }

  /// Obter peso da fonte para heading
  pw.FontWeight _getHeadingFontWeight(int level) {
    switch (level) {
      case 1:
      case 2:
        return pw.FontWeight.bold;
      default:
        return pw.FontWeight.normal;
    }
  }

  /// Obter espaçamento para heading
  double _getHeadingSpacing(int level) {
    switch (level) {
      case 1:
        return 16.0;
      case 2:
        return 12.0;
      default:
        return 8.0;
    }
  }

  /// Dividir widgets em páginas
  List<List<pw.Widget>> _splitIntoPages(List<pw.Widget> widgets) {
    final pages = <List<pw.Widget>>[];
    final currentPage = <pw.Widget>[];

    for (final widget in widgets) {
      currentPage.add(widget);

      // Simples: dividir a cada 50 widgets (aproximação)
      if (currentPage.length >= 50) {
        pages.add(List.from(currentPage));
        currentPage.clear();
      }
    }

    // Adicionar última página se houver conteúdo
    if (currentPage.isNotEmpty) {
      pages.add(currentPage);
    }

    return pages;
  }

  /// Gerar bytes do PDF para impressão
  Future<Uint8List?> generatePdfBytes({
    required String markdown,
    required String title,
    required AppStrings strings,
  }) async {
    try {
      await _loadFonts();

      final pdf = pw.Document(
        title: title,
        author: 'Bloquinho App',
        subject: 'Documento para impressão',
      );

      final sanitizedMarkdown = _sanitizeText(markdown);

      final blocks = EnhancedMarkdownParser.parseMarkdown(sanitizedMarkdown);

      final widgets = await _convertBlocksToPdfWidgets(blocks);

      final pages = _splitIntoPages(widgets);

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
                      style: pw.TextStyle(
                        fontSize: 10,
                        font: _getDefaultFont(),
                        fontFallback: _getFontFallbacks(),
                      ),
                    ),
                    pw.Text(
                      'Página ${i + 1} de ${pages.length}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        font: _getDefaultFont(),
                        fontFallback: _getFontFallbacks(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }

      final pdfBytes = await pdf.save();

      return pdfBytes;
    } catch (e, stackTrace) {
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

  /// Cria uma imagem de fórmula LaTeX
  Future<pw.Widget?> _createLatexImage(String latex) async {
    // Limpar a fórmula LaTeX
    String cleanLatex = latex.trim();
    if (cleanLatex.startsWith('\$') && cleanLatex.endsWith('\$')) {
      cleanLatex = cleanLatex.substring(1, cleanLatex.length - 1);
    }

    // Usar API MathJax para renderizar LaTeX como SVG
    final response = await http.post(
      Uri.parse('https://mathjax-node.herokuapp.com/mml2svg'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'math': cleanLatex, 'format': 'TeX', 'svg': true, 'width': 600}),
    );

    if (response.statusCode == 200) {
      final svgData = response.body;

      // Converter SVG para imagem PNG usando API
      final pngResponse = await http.post(
        Uri.parse('https://api.kroki.io/svg2png'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'svg': svgData, 'width': 600, 'height': 200}),
      );

      if (pngResponse.statusCode == 200) {
        final pngData = pngResponse.bodyBytes;
        return pw.Image(
          pw.MemoryImage(pngData),
          width: 600,
          height: 200,
          fit: pw.BoxFit.contain,
        );
      }
    }

    // Fallback: mostrar como texto
    return pw.Text(
      'Fórmula: $cleanLatex',
      style: pw.TextStyle(
        font: _getDefaultFont(),
        fontSize: 12,
        fontStyle: pw.FontStyle.italic,
      ),
    );
  }

  /// Cria uma imagem de diagrama Mermaid
  Future<pw.Widget?> _createMermaidImage(String mermaidCode) async {
    // Limpar o código Mermaid
    String cleanMermaid = mermaidCode.trim();

    // Usar API kroki.io para renderizar Mermaid
    final encodedDiagram = base64Encode(utf8.encode(cleanMermaid));
    final url = 'https://kroki.io/mermaid/png/$encodedDiagram';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final pngData = response.bodyBytes;

      return pw.Image(
        pw.MemoryImage(pngData),
        width: 600,
        height: 400,
        fit: pw.BoxFit.contain,
      );
    }

    // Fallback: mostrar como código
    return pw.Container(
      padding: pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF44475A),
        border: pw.Border.all(color: PdfColor.fromInt(0xFF888888)),
      ),
      child: pw.Text(
        'Diagrama Mermaid:\n$cleanMermaid',
        style: pw.TextStyle(
          font: _getDefaultFont(),
          fontSize: 10,
        ),
      ),
    );
  }
}
