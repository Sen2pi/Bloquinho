/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

enum TipoContextoPage {
  @JsonValue('universidade')
  universidade,
  @JsonValue('curso')
  curso,
  @JsonValue('unidade_curricular')
  unidadeCurricular,
  @JsonValue('avaliacao')
  avaliacao,
  @JsonValue('geral')
  geral,
}

@JsonSerializable()
class UniversidadePageModel {
  final String id;
  final String titulo;
  final String? icon;
  final String? parentId;
  final List<String> childrenIds;
  final String conteudo;
  final List<dynamic> blocks;
  final TipoContextoPage tipoContexto;
  final String? contextoId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UniversidadePageModel({
    required this.id,
    required this.titulo,
    this.icon,
    this.parentId,
    this.childrenIds = const [],
    this.conteudo = '',
    this.blocks = const [],
    required this.tipoContexto,
    this.contextoId,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory UniversidadePageModel.create({
    required String titulo,
    String? icon,
    String? parentId,
    String conteudo = '',
    List<dynamic>? blocks,
    required TipoContextoPage tipoContexto,
    String? contextoId,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return UniversidadePageModel(
      id: const Uuid().v4(),
      titulo: titulo,
      icon: icon,
      parentId: parentId,
      childrenIds: [],
      conteudo: conteudo,
      blocks: blocks ?? [],
      tipoContexto: tipoContexto,
      contextoId: contextoId,
      metadata: metadata ?? {},
      createdAt: now,
      updatedAt: now,
    );
  }

  factory UniversidadePageModel.fromJson(Map<String, dynamic> json) {
    return UniversidadePageModel(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      icon: json['icon'] as String?,
      parentId: json['parentId'] as String?,
      childrenIds: List<String>.from(json['childrenIds'] ?? []),
      conteudo: json['conteudo'] as String? ?? '',
      blocks: json['blocks'] ?? [],
      tipoContexto: TipoContextoPage.values.firstWhere((e) => e.name == json['tipoContexto']),
      contextoId: json['contextoId'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'icon': icon,
      'parentId': parentId,
      'childrenIds': childrenIds,
      'conteudo': conteudo,
      'blocks': blocks,
      'tipoContexto': tipoContexto.name,
      'contextoId': contextoId,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isRoot => parentId == null;
  bool get hasChildren => childrenIds.isNotEmpty;
  bool get isSubPage => parentId != null;

  String get contextoNome {
    switch (tipoContexto) {
      case TipoContextoPage.universidade:
        return 'Universidade';
      case TipoContextoPage.curso:
        return 'Curso';
      case TipoContextoPage.unidadeCurricular:
        return 'Unidade Curricular';
      case TipoContextoPage.avaliacao:
        return 'Avaliação';
      case TipoContextoPage.geral:
        return 'Geral';
    }
  }

  UniversidadePageModel copyWith({
    String? id,
    String? titulo,
    String? icon,
    String? parentId,
    List<String>? childrenIds,
    String? conteudo,
    List<dynamic>? blocks,
    TipoContextoPage? tipoContexto,
    String? contextoId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UniversidadePageModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      icon: icon ?? this.icon,
      parentId: parentId ?? this.parentId,
      childrenIds: childrenIds ?? this.childrenIds,
      conteudo: conteudo ?? this.conteudo,
      blocks: blocks ?? this.blocks,
      tipoContexto: tipoContexto ?? this.tipoContexto,
      contextoId: contextoId ?? this.contextoId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UniversidadePageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UniversidadePageModel(id: $id, titulo: $titulo, contexto: ${tipoContexto.name})';
  }
}