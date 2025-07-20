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
  @JsonValue('modulo')
  modulo,
  @JsonValue('avaliacao')
  avaliacao,
  @JsonValue('geral')
  geral,
}

enum TipoModulo {
  @JsonValue('teorica')
  teorica,
  @JsonValue('pratica')
  pratica,
  @JsonValue('laboratorio')
  laboratorio,
  @JsonValue('projeto')
  projeto,
  @JsonValue('seminario')
  seminario,
  @JsonValue('exercicios')
  exercicios,
}

@JsonSerializable()
class ArquivoAnexo {
  final String id;
  final String nome;
  final String tipo; // pdf, doc, ppt, etc.
  final String caminho;
  final int tamanho; // em bytes
  final String? descricao;
  final DateTime dataUpload;
  final String uploadedBy; // professor ou estudante

  const ArquivoAnexo({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.caminho,
    required this.tamanho,
    this.descricao,
    required this.dataUpload,
    required this.uploadedBy,
  });

  factory ArquivoAnexo.create({
    required String nome,
    required String tipo,
    required String caminho,
    required int tamanho,
    String? descricao,
    required String uploadedBy,
  }) {
    return ArquivoAnexo(
      id: const Uuid().v4(),
      nome: nome,
      tipo: tipo,
      caminho: caminho,
      tamanho: tamanho,
      descricao: descricao,
      dataUpload: DateTime.now(),
      uploadedBy: uploadedBy,
    );
  }

  factory ArquivoAnexo.fromJson(Map<String, dynamic> json) {
    return ArquivoAnexo(
      id: json['id'] as String,
      nome: json['nome'] as String,
      tipo: json['tipo'] as String,
      caminho: json['caminho'] as String,
      tamanho: json['tamanho'] as int,
      descricao: json['descricao'] as String?,
      dataUpload: DateTime.parse(json['dataUpload']),
      uploadedBy: json['uploadedBy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'caminho': caminho,
      'tamanho': tamanho,
      'descricao': descricao,
      'dataUpload': dataUpload.toIso8601String(),
      'uploadedBy': uploadedBy,
    };
  }

  String get tamanhoFormatado {
    if (tamanho < 1024) return '$tamanho B';
    if (tamanho < 1024 * 1024) return '${(tamanho / 1024).toStringAsFixed(1)} KB';
    if (tamanho < 1024 * 1024 * 1024) return '${(tamanho / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(tamanho / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
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
  final TipoModulo? tipoModulo;
  final List<ArquivoAnexo> arquivos;
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
    this.tipoModulo,
    this.arquivos = const [],
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
    TipoModulo? tipoModulo,
    List<ArquivoAnexo>? arquivos,
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
      tipoModulo: tipoModulo,
      arquivos: arquivos ?? [],
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
      tipoModulo: json['tipoModulo'] != null 
        ? TipoModulo.values.firstWhere((e) => e.name == json['tipoModulo'])
        : null,
      arquivos: (json['arquivos'] as List<dynamic>?)
        ?.map((e) => ArquivoAnexo.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
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
      'tipoModulo': tipoModulo?.name,
      'arquivos': arquivos.map((e) => e.toJson()).toList(),
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
      case TipoContextoPage.modulo:
        return 'Módulo';
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
    TipoModulo? tipoModulo,
    List<ArquivoAnexo>? arquivos,
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
      tipoModulo: tipoModulo ?? this.tipoModulo,
      arquivos: arquivos ?? this.arquivos,
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

extension TipoModuloExtension on TipoModulo {
  String get displayName {
    switch (this) {
      case TipoModulo.teorica:
        return 'Teórica';
      case TipoModulo.pratica:
        return 'Prática';
      case TipoModulo.laboratorio:
        return 'Laboratório';
      case TipoModulo.projeto:
        return 'Projeto';
      case TipoModulo.seminario:
        return 'Seminário';
      case TipoModulo.exercicios:
        return 'Exercícios';
    }
  }
}