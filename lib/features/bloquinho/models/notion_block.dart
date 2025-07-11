import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'bloco_base_model.dart';
import 'bloco_tipo_enum.dart';
import 'notion_block_type.dart';

import 'package:bloquinho/features/bloquinho/models/bloco_base_model.dart';
import 'package:bloquinho/features/bloquinho/models/bloco_tipo_enum.dart';

class NotionBlock extends BlocoBase {
  NotionBlock({
    required super.id,
    required super.tipo,
  });

  factory NotionBlock.fromJson(Map<String, dynamic> json) {
    return NotionBlock(
      id: json['id'],
      tipo: BlocoTipo.values.firstWhere((e) => e.name == json['tipo']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo.name,
    };
  }

  static NotionBlock create({required BlocoTipo type, String content = ''}) {
     return NotionBlock(
      id: 'new',
      tipo: type,
    );
  }
}


/// Modelo de texto rico do Notion
class NotionRichText {
  final String text;
  final NotionTextFormat format;
  final String? link;

  const NotionRichText({
    required this.text,
    this.format = const NotionTextFormat(),
    this.link,
  });

  factory NotionRichText.fromJson(Map<String, dynamic> json) {
    return NotionRichText(
      text: json['text'] ?? '',
      format: NotionTextFormat.fromJson(json['format'] ?? {}),
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'format': format.toJson(),
      if (link != null) 'link': link,
    };
  }

  NotionRichText copyWith({
    String? text,
    NotionTextFormat? format,
    String? link,
  }) {
    return NotionRichText(
      text: text ?? this.text,
      format: format ?? this.format,
      link: link ?? this.link,
    );
  }
}

/// Modelo de formatação de texto do Notion
class NotionTextFormat {
  final bool bold;
  final bool italic;
  final bool strikethrough;
  final bool underline;
  final bool code;
  final String? color;
  final String? backgroundColor;
  final String? link;

  const NotionTextFormat({
    this.bold = false,
    this.italic = false,
    this.strikethrough = false,
    this.underline = false,
    this.code = false,
    this.color,
    this.backgroundColor,
    this.link,
  });

  factory NotionTextFormat.fromJson(Map<String, dynamic> json) {
    return NotionTextFormat(
      bold: json['bold'] ?? false,
      italic: json['italic'] ?? false,
      strikethrough: json['strikethrough'] ?? false,
      underline: json['underline'] ?? false,
      code: json['code'] ?? false,
      color: json['color'],
      backgroundColor: json['backgroundColor'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bold': bold,
      'italic': italic,
      'strikethrough': strikethrough,
      'underline': underline,
      'code': code,
      if (color != null) 'color': color,
      if (backgroundColor != null) 'backgroundColor': backgroundColor,
      if (link != null) 'link': link,
    };
  }

  NotionTextFormat copyWith({
    bool? bold,
    bool? italic,
    bool? strikethrough,
    bool? underline,
    bool? code,
    String? color,
    String? backgroundColor,
    String? link,
  }) {
    return NotionTextFormat(
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      strikethrough: strikethrough ?? this.strikethrough,
      underline: underline ?? this.underline,
      code: code ?? this.code,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      link: link ?? this.link,
    );
  }
}
