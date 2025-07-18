/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/custom_pdf_template.dart';

/// Serviço para armazenamento persistente de templates
class TemplateStorageService {
  static TemplateStorageService? _instance;
  static TemplateStorageService get instance =>
      _instance ??= TemplateStorageService._();

  TemplateStorageService._();

  /// Obtém o diretório de templates
  Future<Directory> get _templatesDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final templatesDir = Directory('${appDir.path}/Bloquinho/Templates');
    if (!await templatesDir.exists()) {
      await templatesDir.create(recursive: true);
    }
    return templatesDir;
  }

  /// Obtém o diretório de headers
  Future<Directory> get _headersDirectory async {
    final templatesDir = await _templatesDirectory;
    final headersDir = Directory('${templatesDir.path}/Header');
    if (!await headersDir.exists()) {
      await headersDir.create(recursive: true);
    }
    return headersDir;
  }

  /// Obtém o diretório de footers
  Future<Directory> get _footersDirectory async {
    final templatesDir = await _templatesDirectory;
    final footersDir = Directory('${templatesDir.path}/Footer');
    if (!await footersDir.exists()) {
      await footersDir.create(recursive: true);
    }
    return footersDir;
  }

  /// Salva um template
  Future<void> saveTemplate(CustomPdfTemplate template) async {
    try {
      final templatesDir = await _templatesDirectory;
      final templateFile = File('${templatesDir.path}/${template.id}.json');

      final templateJson = {
        'id': template.id,
        'name': template.name,
        'description': template.description,
        'icon': template.icon.codePoint,
        'previewColor': template.previewColor.value,
        'header': _headerToJson(template.header),
        'footer': _footerToJson(template.footer),
        'createdAt': template.createdAt.toIso8601String(),
      };

      await templateFile.writeAsString(json.encode(templateJson));

      // Salvar logo do header se existir
      if (template.header.logoBytes != null) {
        await _saveLogo('header_${template.id}', template.header.logoBytes!);
      }

      // Salvar logo do footer se existir
      if (template.footer.logoBytes != null) {
        await _saveLogo('footer_${template.id}', template.footer.logoBytes!);
      }
    } catch (e) {
      print('Erro ao salvar template: $e');
      rethrow;
    }
  }

  /// Carrega todos os templates
  Future<List<CustomPdfTemplate>> loadTemplates() async {
    try {
      final templatesDir = await _templatesDirectory;
      final templates = <CustomPdfTemplate>[];

      if (!await templatesDir.exists()) {
        return templates;
      }

      final files = templatesDir
          .listSync()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .cast<File>();

      for (final file in files) {
        try {
          final content = await file.readAsString();
          final templateJson = json.decode(content) as Map<String, dynamic>;

          final template = await _templateFromJson(templateJson);
          templates.add(template);
        } catch (e) {
          print('Erro ao carregar template ${file.path}: $e');
        }
      }

      return templates;
    } catch (e) {
      print('Erro ao carregar templates: $e');
      return [];
    }
  }

  /// Remove um template
  Future<void> deleteTemplate(String templateId) async {
    try {
      final templatesDir = await _templatesDirectory;
      final templateFile = File('${templatesDir.path}/$templateId.json');

      if (await templateFile.exists()) {
        await templateFile.delete();
      }

      // Remover logos associados
      await _deleteLogo('header_$templateId');
      await _deleteLogo('footer_$templateId');
    } catch (e) {
      print('Erro ao deletar template: $e');
      rethrow;
    }
  }

  /// Salva um logo
  Future<void> _saveLogo(String logoId, Uint8List logoBytes) async {
    try {
      final headersDir = await _headersDirectory;
      final logoFile = File('${headersDir.path}/$logoId.png');
      await logoFile.writeAsBytes(logoBytes);
    } catch (e) {
      print('Erro ao salvar logo: $e');
    }
  }

  /// Carrega um logo
  Future<Uint8List?> _loadLogo(String logoId) async {
    try {
      final headersDir = await _headersDirectory;
      final logoFile = File('${headersDir.path}/$logoId.png');

      if (await logoFile.exists()) {
        return await logoFile.readAsBytes();
      }
      return null;
    } catch (e) {
      print('Erro ao carregar logo: $e');
      return null;
    }
  }

  /// Remove um logo
  Future<void> _deleteLogo(String logoId) async {
    try {
      final headersDir = await _headersDirectory;
      final logoFile = File('${headersDir.path}/$logoId.png');

      if (await logoFile.exists()) {
        await logoFile.delete();
      }
    } catch (e) {
      print('Erro ao deletar logo: $e');
    }
  }

  /// Converte header para JSON
  Map<String, dynamic> _headerToJson(CustomHeaderConfig header) {
    return {
      'enabled': header.enabled,
      'title': header.title,
      'showLogo': header.showLogo,
      'showDate': header.showDate,
      'showPageNumber': header.showPageNumber,
      'backgroundColor': header.backgroundColor,
      'textColor': header.textColor,
      'fontSize': header.fontSize,
      'showBorder': header.showBorder,
      'borderColor': header.borderColor,
      'height': header.height,
      'logoSize': header.logoSize.name,
    };
  }

  /// Converte footer para JSON
  Map<String, dynamic> _footerToJson(CustomFooterConfig footer) {
    return {
      'enabled': footer.enabled,
      'text': footer.text,
      'showLogo': footer.showLogo,
      'showPageNumber': footer.showPageNumber,
      'showExportedText': footer.showExportedText,
      'backgroundColor': footer.backgroundColor,
      'textColor': footer.textColor,
      'fontSize': footer.fontSize,
      'showBorder': footer.showBorder,
      'borderColor': footer.borderColor,
      'height': footer.height,
      'logoSize': footer.logoSize.name,
    };
  }

  /// Converte JSON para template
  Future<CustomPdfTemplate> _templateFromJson(Map<String, dynamic> json) async {
    final id = json['id'] as String;

    // Carregar logos se existirem
    final headerLogoBytes = await _loadLogo('header_$id');
    final footerLogoBytes = await _loadLogo('footer_$id');

    final header = CustomHeaderConfig(
      enabled: json['header']['enabled'] as bool,
      title: json['header']['title'] as String,
      showLogo: json['header']['showLogo'] as bool,
      showDate: json['header']['showDate'] as bool,
      showPageNumber: json['header']['showPageNumber'] as bool,
      backgroundColor: json['header']['backgroundColor'] as String,
      textColor: json['header']['textColor'] as String,
      fontSize: (json['header']['fontSize'] as num).toDouble(),
      showBorder: json['header']['showBorder'] as bool,
      borderColor: json['header']['borderColor'] as String,
      height: (json['header']['height'] as num).toDouble(),
      logoSize: LogoSize.values.firstWhere(
        (e) => e.name == json['header']['logoSize'],
        orElse: () => LogoSize.small,
      ),
      logoBytes: headerLogoBytes,
    );

    final footer = CustomFooterConfig(
      enabled: json['footer']['enabled'] as bool,
      text: json['footer']['text'] as String,
      showLogo: json['footer']['showLogo'] as bool,
      showPageNumber: json['footer']['showPageNumber'] as bool,
      showExportedText: json['footer']['showExportedText'] as bool,
      backgroundColor: json['footer']['backgroundColor'] as String,
      textColor: json['footer']['textColor'] as String,
      fontSize: (json['footer']['fontSize'] as num).toDouble(),
      showBorder: json['footer']['showBorder'] as bool,
      borderColor: json['footer']['borderColor'] as String,
      height: (json['footer']['height'] as num).toDouble(),
      logoSize: LogoSize.values.firstWhere(
        (e) => e.name == json['footer']['logoSize'],
        orElse: () => LogoSize.small,
      ),
      logoBytes: footerLogoBytes,
    );

    return CustomPdfTemplate(
      id: id,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      previewColor: Color(json['previewColor'] as int),
      header: header,
      footer: footer,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
