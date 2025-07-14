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
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/page_model.dart';
import '../../../core/l10n/app_strings.dart';

/// Serviço para exportação de PDF
class PdfExportService {
  /// Exportar página para PDF
  Future<File> exportPageToPdf({
    required PageModel page,
    required Widget contentWidget,
    required AppStrings strings,
    String? customTitle,
    bool includeHeader = true,
    bool includeFooter = true,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    try {
      // Capturar o widget como imagem
      final imageBytes = await _captureWidgetAsImage(contentWidget);

      // Converter imagem para PDF
      final pdf = pw.Document();

      // Adicionar página ao PDF
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                if (includeHeader) ...[
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        customTitle ?? page.title,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Exportado em: ${DateTime.now().toString().split('.')[0]}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey,
                        ),
                      ),
                    ],
                  ),
                  pw.Divider(),
                  pw.SizedBox(height: 20),
                ],

                // Conteúdo principal
                pw.Expanded(
                  child: pw.Image(
                    pw.MemoryImage(imageBytes),
                    fit: pw.BoxFit.contain,
                  ),
                ),

                // Rodapé
                if (includeFooter) ...[
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Bloquinho',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey,
                        ),
                      ),
                      pw.Text(
                        'Página 1',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      );

      // Salvar PDF em arquivo temporário
      final output = await getTemporaryDirectory();
      final file = File(
          '${output.path}/${page.title.replaceAll(RegExp(r'[^\w\s-]'), '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf');

      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      throw Exception('Erro ao exportar PDF: $e');
    }
  }

  /// Exportar múltiplas páginas para PDF
  Future<File> exportPagesToPdf({
    required List<PageModel> pages,
    required List<Widget> contentWidgets,
    required AppStrings strings,
    String? customTitle,
    bool includeHeader = true,
    bool includeFooter = true,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    try {
      final pdf = pw.Document();

      for (int i = 0; i < pages.length; i++) {
        final page = pages[i];
        final contentWidget = contentWidgets[i];

        // Capturar o widget como imagem
        final imageBytes = await _captureWidgetAsImage(contentWidget);

        // Adicionar página ao PDF
        pdf.addPage(
          pw.Page(
            pageFormat: pageFormat,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Cabeçalho
                  if (includeHeader) ...[
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          page.title,
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Exportado em: ${DateTime.now().toString().split('.')[0]}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey,
                          ),
                        ),
                      ],
                    ),
                    pw.Divider(),
                    pw.SizedBox(height: 20),
                  ],

                  // Conteúdo principal
                  pw.Expanded(
                    child: pw.Image(
                      pw.MemoryImage(imageBytes),
                      fit: pw.BoxFit.contain,
                    ),
                  ),

                  // Rodapé
                  if (includeFooter) ...[
                    pw.SizedBox(height: 20),
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Bloquinho',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey,
                          ),
                        ),
                        pw.Text(
                          'Página ' +
                              (i + 1).toString() +
                              ' de ' +
                              pages.length.toString(),
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        );
      }

      // Salvar PDF em arquivo temporário
      final output = await getTemporaryDirectory();
      final file = File(
          '${output.path}/bloquinho_export_${DateTime.now().millisecondsSinceEpoch}.pdf');

      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      throw Exception('Erro ao exportar PDF: $e');
    }
  }

  /// Capturar widget como imagem
  Future<Uint8List> _captureWidgetAsImage(Widget widget) async {
    // ATENÇÃO: Para capturar um widget como imagem, ele precisa estar na árvore de widgets
    // e ser envolvido por um RepaintBoundary com GlobalKey. Não é possível capturar widgets
    // arbitrários fora da árvore de widgets nesta função isolada.
    throw Exception(
        'A captura de imagem de widget deve ser feita a partir de um widget já renderizado com GlobalKey.');
  }

  /// Exportar conteúdo markdown para PDF
  Future<File> exportMarkdownToPdf({
    required String markdownContent,
    required String title,
    required AppStrings strings,
    bool includeHeader = true,
    bool includeFooter = true,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    try {
      final pdf = pw.Document();

      // Converter markdown para HTML simples
      final htmlContent = _convertMarkdownToHtml(markdownContent);

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                if (includeHeader) ...[
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Divider(),
                  pw.SizedBox(height: 20),
                ],

                // Conteúdo markdown
                pw.Expanded(
                  child: pw.Text(
                    markdownContent,
                    style: pw.TextStyle(
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),

                // Rodapé
                if (includeFooter) ...[
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Bloquinho',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey,
                        ),
                      ),
                      pw.Text(
                        'Exportado em: ${DateTime.now().toString().split('.')[0]}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      );

      // Salvar PDF em arquivo temporário
      final output = await getTemporaryDirectory();
      final file = File(
          '${output.path}/${title.replaceAll(RegExp(r'[^\w\s-]'), '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf');

      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      throw Exception('Erro ao exportar PDF: $e');
    }
  }

  /// Exportar imagem PNG para PDF
  Future<File> exportImageToPdf({
    required Uint8List imageBytes,
    required String title,
    required AppStrings strings,
    bool includeHeader = true,
    bool includeFooter = true,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (includeHeader) ...[
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Divider(),
                  pw.SizedBox(height: 20),
                ],
                pw.Expanded(
                  child: pw.Image(
                    pw.MemoryImage(imageBytes),
                    fit: pw.BoxFit.contain,
                  ),
                ),
                if (includeFooter) ...[
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Bloquinho',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey,
                        ),
                      ),
                      pw.Text(
                        'Exportado em: ${DateTime.now().toString().split('.')[0]}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      );
      final output = await getTemporaryDirectory();
      final file = File(
          '${output.path}/${title.replaceAll(RegExp(r'[^ -\u007F]+'), '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      throw Exception('Erro ao exportar PDF: $e');
    }
  }

  /// Converter markdown para HTML simples
  String _convertMarkdownToHtml(String markdown) {
    // Implementação simples de conversão markdown para HTML
    String html = markdown;

    // Títulos
    html = html.replaceAllMapped(
        RegExp(r'^### (.*$)', multiLine: true), (m) => '<h3>${m[1]}</h3>');
    html = html.replaceAllMapped(
        RegExp(r'^## (.*$)', multiLine: true), (m) => '<h2>${m[1]}</h2>');
    html = html.replaceAllMapped(
        RegExp(r'^# (.*$)', multiLine: true), (m) => '<h1>${m[1]}</h1>');
    html = html.replaceAllMapped(
        RegExp(r'\\*\\*(.*?)\\*\\*'), (m) => '<strong>${m[1]}</strong>');
    html = html.replaceAllMapped(
        RegExp(r'\\*(.*?)\\*'), (m) => '<em>${m[1]}</em>');
    html = html.replaceAllMapped(RegExp(r'\\[([^\\]]+)\\]\\(([^)]+)\\)'),
        (m) => '<a href=\"${m[2]}\">${m[1]}</a>');
    html = html.replaceAllMapped(
        RegExp(r'^- (.*$)', multiLine: true), (m) => '<li>${m[1]}</li>');
    html = html.replaceAllMapped(
        RegExp(r'^\\d+\\. (.*$)', multiLine: true), (m) => '<li>${m[1]}</li>');
    // Quebras de linha
    html = html.replaceAll(RegExp(r'\n\n'), '</p><p>');
    html = '<p>$html</p>';

    return html;
  }
}
