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

  /// Exportar markdown como PDF
  Future<String?> exportMarkdownAsPdf({
    required String markdown,
    required String title,
    String? author,
    String? subject,
  }) async {
    try {
      // Criar documento PDF
      final pdf = pw.Document();

      // Adicionar metadados
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              pw.Header(
                level: 0,
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Conteúdo markdown convertido
              ..._convertMarkdownToPdfWidgets(markdown),
            ],
          ),
        ),
      );

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

  /// Converter markdown para widgets PDF
  List<pw.Widget> _convertMarkdownToPdfWidgets(String markdown) {
    final widgets = <pw.Widget>[];
    final lines = markdown.split('\n');

    for (final line in lines) {
      if (line.startsWith('# ')) {
        // Título H1
        widgets.add(
          pw.Text(
            line.substring(2),
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );
        widgets.add(pw.SizedBox(height: 10));
      } else if (line.startsWith('## ')) {
        // Título H2
        widgets.add(
          pw.Text(
            line.substring(3),
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );
        widgets.add(pw.SizedBox(height: 8));
      } else if (line.startsWith('### ')) {
        // Título H3
        widgets.add(
          pw.Text(
            line.substring(4),
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );
        widgets.add(pw.SizedBox(height: 6));
      } else if (line.startsWith('```')) {
        // Bloco de código
        widgets.add(
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Text(
              line.substring(3),
              style: pw.TextStyle(
                fontSize: 10,
              ),
            ),
          ),
        );
        widgets.add(pw.SizedBox(height: 8));
      } else if (line.startsWith('- ')) {
        // Lista
        widgets.add(
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('• ', style: pw.TextStyle(fontSize: 12)),
              pw.Expanded(
                child: pw.Text(
                  line.substring(2),
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
        widgets.add(pw.SizedBox(height: 4));
      } else if (line.trim().isNotEmpty) {
        // Texto normal
        widgets.add(
          pw.Text(
            line,
            style: pw.TextStyle(fontSize: 12),
          ),
        );
        widgets.add(pw.SizedBox(height: 4));
      } else {
        // Linha em branco
        widgets.add(pw.SizedBox(height: 8));
      }
    }

    return widgets;
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
