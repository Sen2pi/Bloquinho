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
import 'dart:typed_data';

/// Enumeração para tamanhos de logo
enum LogoSize {
  small, // 1 linha
  medium, // 2 linhas
  large, // 3 linhas
}

/// Configuração para header customizado
class CustomHeaderConfig {
  final bool enabled;
  final String title;
  final bool showLogo;
  final bool showDate;
  final bool showPageNumber;
  final String backgroundColor;
  final String textColor;
  final double fontSize;
  final bool showBorder;
  final String borderColor;
  final double height;
  final LogoSize logoSize;
  final Uint8List? logoBytes;

  const CustomHeaderConfig({
    this.enabled = false,
    this.title = 'Documento',
    this.showLogo = true,
    this.showDate = false,
    this.showPageNumber = false,
    this.backgroundColor = '#FFFFFF',
    this.textColor = '#000000',
    this.fontSize = 12,
    this.showBorder = false,
    this.borderColor = '#CCCCCC',
    this.height = 40,
    this.logoSize = LogoSize.small,
    this.logoBytes,
  });

  CustomHeaderConfig copyWith({
    bool? enabled,
    String? title,
    bool? showLogo,
    bool? showDate,
    bool? showPageNumber,
    String? backgroundColor,
    String? textColor,
    double? fontSize,
    bool? showBorder,
    String? borderColor,
    double? height,
    LogoSize? logoSize,
    Uint8List? logoBytes,
  }) {
    return CustomHeaderConfig(
      enabled: enabled ?? this.enabled,
      title: title ?? this.title,
      showLogo: showLogo ?? this.showLogo,
      showDate: showDate ?? this.showDate,
      showPageNumber: showPageNumber ?? this.showPageNumber,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      fontSize: fontSize ?? this.fontSize,
      showBorder: showBorder ?? this.showBorder,
      borderColor: borderColor ?? this.borderColor,
      height: height ?? this.height,
      logoSize: logoSize ?? this.logoSize,
      logoBytes: logoBytes ?? this.logoBytes,
    );
  }
}

/// Configuração para footer customizado
class CustomFooterConfig {
  final bool enabled;
  final String text;
  final bool showLogo;
  final bool showPageNumber;
  final bool showExportedText;
  final String backgroundColor;
  final String textColor;
  final double fontSize;
  final bool showBorder;
  final String borderColor;
  final double height;
  final LogoSize logoSize;
  final Uint8List? logoBytes;

  const CustomFooterConfig({
    this.enabled = true,
    this.text = 'Exported with Bloquinho',
    this.showLogo = true,
    this.showPageNumber = true,
    this.showExportedText = true,
    this.backgroundColor = '#FFFFFF',
    this.textColor = '#5C4033',
    this.fontSize = 10,
    this.showBorder = false,
    this.borderColor = '#CCCCCC',
    this.height = 25,
    this.logoSize = LogoSize.small,
    this.logoBytes,
  });

  CustomFooterConfig copyWith({
    bool? enabled,
    String? text,
    bool? showLogo,
    bool? showPageNumber,
    bool? showExportedText,
    String? backgroundColor,
    String? textColor,
    double? fontSize,
    bool? showBorder,
    String? borderColor,
    double? height,
    LogoSize? logoSize,
    Uint8List? logoBytes,
  }) {
    return CustomFooterConfig(
      enabled: enabled ?? this.enabled,
      text: text ?? this.text,
      showLogo: showLogo ?? this.showLogo,
      showPageNumber: showPageNumber ?? this.showPageNumber,
      showExportedText: showExportedText ?? this.showExportedText,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      fontSize: fontSize ?? this.fontSize,
      showBorder: showBorder ?? this.showBorder,
      borderColor: borderColor ?? this.borderColor,
      height: height ?? this.height,
      logoSize: logoSize ?? this.logoSize,
      logoBytes: logoBytes ?? this.logoBytes,
    );
  }
}

/// Template PDF customizado
class CustomPdfTemplate {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color previewColor;
  final CustomHeaderConfig header;
  final CustomFooterConfig footer;
  final DateTime createdAt;

  const CustomPdfTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.previewColor,
    required this.header,
    required this.footer,
    required this.createdAt,
  });

  CustomPdfTemplate copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? previewColor,
    CustomHeaderConfig? header,
    CustomFooterConfig? footer,
    DateTime? createdAt,
  }) {
    return CustomPdfTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      previewColor: previewColor ?? this.previewColor,
      header: header ?? this.header,
      footer: footer ?? this.footer,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Cria o header do template customizado
  pw.Widget? createHeader({
    required int pageNumber,
    required int totalPages,
    required bool isDark,
    required pw.MemoryImage? logo,
    required pw.Font font,
  }) {
    if (!header.enabled) return null;

    final bgColor = PdfColor.fromHex(header.backgroundColor);
    final textColor = PdfColor.fromHex(header.textColor);

    // Determinar tamanho do logo baseado na configuração
    double logoWidth;
    double logoHeight;
    switch (header.logoSize) {
      case LogoSize.small:
        logoWidth = 18;
        logoHeight = 18;
        break;
      case LogoSize.medium:
        logoWidth = 36;
        logoHeight = 36;
        break;
      case LogoSize.large:
        logoWidth = 54;
        logoHeight = 54;
        break;
    }

    // Usar logo personalizado se disponível, senão usar o logo padrão
    pw.MemoryImage? logoToUse;
    if (header.logoBytes != null) {
      logoToUse = pw.MemoryImage(header.logoBytes!);
    } else if (header.showLogo && logo != null) {
      logoToUse = logo;
    }

    // Dividir título em linhas se necessário
    final titleLines = header.title.split('\n');

    return pw.Container(
      height: header.height,
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: pw.BoxDecoration(
        color: bgColor,
        border: header.showBorder
            ? pw.Border(
                bottom: pw.BorderSide(
                  color: PdfColor.fromHex(header.borderColor),
                  width: 1,
                ),
              )
            : null,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              if (logoToUse != null) ...[
                pw.Container(
                  width: logoWidth,
                  height: logoHeight,
                  child: pw.Image(logoToUse),
                ),
                pw.SizedBox(width: 10),
              ],
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: titleLines
                    .map((line) => pw.Text(
                          line.trim(),
                          style: pw.TextStyle(
                            fontSize: header.fontSize,
                            fontWeight: pw.FontWeight.bold,
                            color: textColor,
                            font: font,
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
          pw.Row(
            children: [
              if (header.showDate) ...[
                pw.Text(
                  DateTime.now().toLocal().toString().split(' ')[0],
                  style: pw.TextStyle(
                    fontSize: header.fontSize - 2,
                    color: textColor,
                    font: font,
                  ),
                ),
                if (header.showPageNumber) pw.SizedBox(width: 15),
              ],
              if (header.showPageNumber)
                pw.Text(
                  'Página $pageNumber',
                  style: pw.TextStyle(
                    fontSize: header.fontSize - 2,
                    color: textColor,
                    font: font,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Cria o footer do template customizado
  pw.Widget? createFooter({
    required int pageNumber,
    required int totalPages,
    required bool isDark,
    required pw.MemoryImage? logo,
    required pw.Font font,
  }) {
    if (!footer.enabled) return null;

    final bgColor = PdfColor.fromHex(footer.backgroundColor);
    final textColor = PdfColor.fromHex(footer.textColor);

    // Determinar tamanho do logo baseado na configuração
    double logoWidth;
    double logoHeight;
    switch (footer.logoSize) {
      case LogoSize.small:
        logoWidth = 16;
        logoHeight = 16;
        break;
      case LogoSize.medium:
        logoWidth = 32;
        logoHeight = 32;
        break;
      case LogoSize.large:
        logoWidth = 48;
        logoHeight = 48;
        break;
    }

    // Usar logo personalizado se disponível, senão usar o logo padrão
    pw.MemoryImage? logoToUse;
    if (footer.logoBytes != null) {
      logoToUse = pw.MemoryImage(footer.logoBytes!);
    } else if (footer.showLogo && logo != null) {
      logoToUse = logo;
    }

    // Dividir texto em linhas se necessário
    final textLines = footer.text.split('\n');

    return pw.Container(
      height: footer.height,
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: pw.BoxDecoration(
        color: bgColor,
        border: footer.showBorder
            ? pw.Border(
                top: pw.BorderSide(
                  color: PdfColor.fromHex(footer.borderColor),
                  width: 1,
                ),
              )
            : null,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              if (logoToUse != null) ...[
                pw.Container(
                  width: logoWidth,
                  height: logoHeight,
                  child: pw.Image(logoToUse),
                ),
                pw.SizedBox(width: 8),
              ],
              if (footer.showExportedText)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: textLines
                      .map((line) => pw.Text(
                            line.trim(),
                            style: pw.TextStyle(
                              fontSize: footer.fontSize,
                              color: textColor,
                              font: font,
                            ),
                          ))
                      .toList(),
                ),
            ],
          ),
          if (footer.showPageNumber)
            pw.Text(
              'pág $pageNumber',
              style: pw.TextStyle(
                fontSize: footer.fontSize,
                color: textColor,
                font: font,
              ),
            ),
        ],
      ),
    );
  }

  /// Altura do header
  double get headerHeight => header.enabled ? header.height : 0;

  /// Altura do footer
  double get footerHeight => footer.enabled ? footer.height : 0;
}

/// Ícones disponíveis para templates customizados
class TemplateIcons {
  static const List<IconData> icons = [
    Icons.description,
    Icons.article,
    Icons.note,
    Icons.document_scanner,
    Icons.text_snippet,
    Icons.library_books,
    Icons.menu_book,
    Icons.bookmark,
    Icons.folder,
    Icons.file_copy,
    Icons.assignment,
    Icons.receipt,
    Icons.contact_page,
    Icons.business,
    Icons.school,
    Icons.work,
    Icons.home,
    Icons.star,
    Icons.favorite,
    Icons.lightbulb,
    Icons.palette,
    Icons.brush,
    Icons.design_services,
    Icons.auto_awesome,
    Icons.science,
    Icons.psychology,
    Icons.build,
    Icons.settings,
    Icons.dashboard,
    Icons.analytics,
  ];
}

/// Cores disponíveis para templates customizados
class TemplateColors {
  static const List<Color> colors = [
    Color(0xFF5C4033), // Bloquinho brown
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.blueGrey,
    Colors.grey,
  ];
}
