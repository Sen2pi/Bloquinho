/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Enum para identificar templates de PDF
enum PdfTemplateType {
  bloquinho,
  minimal,
  professional,
  academic,
  creative,
  custom,
}

/// Classe para representar um template de PDF
class PdfTemplate {
  final PdfTemplateType type;
  final String name;
  final String description;
  final IconData icon;
  final Color previewColor;

  const PdfTemplate({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.previewColor,
  });

  /// Cria o header do template
  pw.Widget? createHeader({
    required int pageNumber,
    required int totalPages,
    required bool isDark,
    required pw.MemoryImage? logo,
    required pw.Font font,
  }) {
    switch (type) {
      case PdfTemplateType.bloquinho:
        return null; // Sem header
      case PdfTemplateType.minimal:
        return _createMinimalHeader(pageNumber, totalPages, isDark, font);
      case PdfTemplateType.professional:
        return _createProfessionalHeader(
            pageNumber, totalPages, isDark, logo, font);
      case PdfTemplateType.academic:
        return _createAcademicHeader(pageNumber, totalPages, isDark, font);
      case PdfTemplateType.creative:
        return _createCreativeHeader(pageNumber, totalPages, isDark, font);
      case PdfTemplateType.custom:
        return null; // Custom não tem header padrão
    }
  }

  /// Cria o footer do template
  pw.Widget createFooter({
    required int pageNumber,
    required int totalPages,
    required bool isDark,
    required pw.MemoryImage? logo,
    required pw.Font font,
  }) {
    switch (type) {
      case PdfTemplateType.bloquinho:
        return _createBloquinhoFooter(
            pageNumber, totalPages, isDark, logo, font);
      case PdfTemplateType.minimal:
        return _createMinimalFooter(pageNumber, totalPages, isDark, font);
      case PdfTemplateType.professional:
        return _createProfessionalFooter(
            pageNumber, totalPages, isDark, logo, font);
      case PdfTemplateType.academic:
        return _createAcademicFooter(pageNumber, totalPages, isDark, font);
      case PdfTemplateType.creative:
        return _createCreativeFooter(pageNumber, totalPages, isDark, font);
      case PdfTemplateType.custom:
        return pw.SizedBox(); // Custom não tem footer padrão
    }
  }

  /// Retorna a altura do header (0 se não tiver header)
  double get headerHeight {
    switch (type) {
      case PdfTemplateType.bloquinho:
        return 0;
      case PdfTemplateType.minimal:
        return 0;
      case PdfTemplateType.professional:
        return 40;
      case PdfTemplateType.academic:
        return 35;
      case PdfTemplateType.creative:
        return 45;
      case PdfTemplateType.custom:
        return 0;
    }
  }

  /// Retorna a altura do footer
  double get footerHeight {
    switch (type) {
      case PdfTemplateType.bloquinho:
        return 25;
      case PdfTemplateType.minimal:
        return 20;
      case PdfTemplateType.professional:
        return 30;
      case PdfTemplateType.academic:
        return 25;
      case PdfTemplateType.creative:
        return 35;
      case PdfTemplateType.custom:
        return 0;
    }
  }

  // Headers
  pw.Widget _createMinimalHeader(
      int pageNumber, int totalPages, bool isDark, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Divider(
        thickness: 0.5,
        color: isDark ? PdfColors.grey400 : PdfColors.grey600,
      ),
    );
  }

  pw.Widget _createProfessionalHeader(int pageNumber, int totalPages,
      bool isDark, pw.MemoryImage? logo, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: isDark ? PdfColors.grey400 : PdfColors.grey600,
            width: 1,
          ),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              if (logo != null) ...[
                pw.Container(
                  width: 20,
                  height: 20,
                  child: pw.Image(logo),
                ),
                pw.SizedBox(width: 10),
              ],
              pw.Text(
                'Bloquinho Document',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: isDark ? PdfColors.grey200 : PdfColors.grey800,
                  font: font,
                ),
              ),
            ],
          ),
          pw.Text(
            DateTime.now().toLocal().toString().split(' ')[0],
            style: pw.TextStyle(
              fontSize: 10,
              color: isDark ? PdfColors.grey400 : PdfColors.grey600,
              font: font,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _createAcademicHeader(
      int pageNumber, int totalPages, bool isDark, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: pw.Column(
        children: [
          pw.Text(
            'Documento Bloquinho',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: isDark ? PdfColors.grey200 : PdfColors.grey800,
              font: font,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Divider(
            thickness: 1,
            color: isDark ? PdfColors.grey400 : PdfColors.grey600,
          ),
        ],
      ),
    );
  }

  pw.Widget _createCreativeHeader(
      int pageNumber, int totalPages, bool isDark, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [
            isDark ? PdfColors.grey800 : PdfColors.blue50,
            isDark ? PdfColors.grey700 : PdfColors.blue100,
          ],
          begin: pw.Alignment.centerLeft,
          end: pw.Alignment.centerRight,
        ),
        borderRadius: const pw.BorderRadius.only(
          bottomLeft: pw.Radius.circular(15),
          bottomRight: pw.Radius.circular(15),
        ),
      ),
      child: pw.Center(
        child: pw.Text(
          '✨ Bloquinho Creative Document ✨',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: isDark ? PdfColors.grey200 : PdfColors.blue800,
            font: font,
          ),
        ),
      ),
    );
  }

  // Footers
  pw.Widget _createBloquinhoFooter(int pageNumber, int totalPages, bool isDark,
      pw.MemoryImage? logo, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              if (logo != null) ...[
                pw.Container(
                  width: 16,
                  height: 16,
                  child: pw.Image(logo),
                ),
                pw.SizedBox(width: 8),
              ],
              pw.Text(
                'Exported with Bloquinho',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColor.fromHex('#5C4033'),
                  font: font,
                ),
              ),
            ],
          ),
          pw.Text(
            'pág $pageNumber',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor.fromHex('#5C4033'),
              font: font,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _createMinimalFooter(
      int pageNumber, int totalPages, bool isDark, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: pw.Center(
        child: pw.Text(
          '$pageNumber',
          style: pw.TextStyle(
            fontSize: 10,
            color: isDark ? PdfColors.grey400 : PdfColors.grey600,
            font: font,
          ),
        ),
      ),
    );
  }

  pw.Widget _createProfessionalFooter(int pageNumber, int totalPages,
      bool isDark, pw.MemoryImage? logo, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(
            color: isDark ? PdfColors.grey400 : PdfColors.grey600,
            width: 0.5,
          ),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Bloquinho Professional',
            style: pw.TextStyle(
              fontSize: 9,
              color: isDark ? PdfColors.grey400 : PdfColors.grey600,
              font: font,
            ),
          ),
          pw.Text(
            'Página $pageNumber de $totalPages',
            style: pw.TextStyle(
              fontSize: 9,
              color: isDark ? PdfColors.grey400 : PdfColors.grey600,
              font: font,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _createAcademicFooter(
      int pageNumber, int totalPages, bool isDark, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: pw.Column(
        children: [
          pw.Divider(
            thickness: 0.5,
            color: isDark ? PdfColors.grey400 : PdfColors.grey600,
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Documento gerado por Bloquinho',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: isDark ? PdfColors.grey400 : PdfColors.grey600,
                  font: font,
                ),
              ),
              pw.Text(
                '$pageNumber',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: isDark ? PdfColors.grey400 : PdfColors.grey600,
                  font: font,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _createCreativeFooter(
      int pageNumber, int totalPages, bool isDark, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [
            isDark ? PdfColors.grey700 : PdfColors.purple50,
            isDark ? PdfColors.grey800 : PdfColors.purple100,
          ],
          begin: pw.Alignment.centerLeft,
          end: pw.Alignment.centerRight,
        ),
        borderRadius: const pw.BorderRadius.only(
          topLeft: pw.Radius.circular(15),
          topRight: pw.Radius.circular(15),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '🎨 Bloquinho Creative',
            style: pw.TextStyle(
              fontSize: 9,
              color: isDark ? PdfColors.grey200 : PdfColors.purple800,
              font: font,
            ),
          ),
          pw.Text(
            '$pageNumber/$totalPages',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: isDark ? PdfColors.grey200 : PdfColors.purple800,
              font: font,
            ),
          ),
        ],
      ),
    );
  }
}

/// Templates predefinidos
class PdfTemplates {
  static const List<PdfTemplate> templates = [
    PdfTemplate(
      type: PdfTemplateType.bloquinho,
      name: 'Bloquinho',
      description: 'Template padrão do Bloquinho',
      icon: Icons.note,
      previewColor: Color(0xFF5C4033),
    ),
    PdfTemplate(
      type: PdfTemplateType.minimal,
      name: 'Minimalista',
      description: 'Design limpo e simples',
      icon: Icons.minimize,
      previewColor: Colors.grey,
    ),
    PdfTemplate(
      type: PdfTemplateType.professional,
      name: 'Profissional',
      description: 'Para documentos corporativos',
      icon: Icons.business,
      previewColor: Colors.blue,
    ),
    PdfTemplate(
      type: PdfTemplateType.academic,
      name: 'Acadêmico',
      description: 'Para trabalhos e pesquisas',
      icon: Icons.school,
      previewColor: Colors.indigo,
    ),
    PdfTemplate(
      type: PdfTemplateType.creative,
      name: 'Criativo',
      description: 'Design colorido e moderno',
      icon: Icons.palette,
      previewColor: Colors.purple,
    ),
  ];

  static PdfTemplate getTemplate(PdfTemplateType type) {
    return templates.firstWhere((t) => t.type == type);
  }
}
