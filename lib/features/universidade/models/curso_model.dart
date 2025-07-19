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
import 'tipo_curso_enum.dart';

@JsonSerializable()
class CursoModel {
  final String id;
  final String nome;
  final String universidadeId;
  final TipoCurso tipo;
  final String? codigo;
  final String? descricao;
  final int? duracaoSemestres;
  final double? mediaMinima;
  final double? mediaMaxima;
  final double? mediaAtual;
  final List<String> unidadeCurricularIds;
  final List<String> pageIds;
  final List<String> fileIds;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CursoModel({
    required this.id,
    required this.nome,
    required this.universidadeId,
    required this.tipo,
    this.codigo,
    this.descricao,
    this.duracaoSemestres,
    this.mediaMinima,
    this.mediaMaxima,
    this.mediaAtual,
    required this.unidadeCurricularIds,
    required this.pageIds,
    required this.fileIds,
    this.dataInicio,
    this.dataFim,
    this.ativo = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CursoModel.create({
    required String nome,
    required String universidadeId,
    required TipoCurso tipo,
    String? codigo,
    String? descricao,
    int? duracaoSemestres,
    double? mediaMinima,
    double? mediaMaxima,
    List<String>? unidadeCurricularIds,
    List<String>? pageIds,
    List<String>? fileIds,
    DateTime? dataInicio,
    DateTime? dataFim,
    bool ativo = true,
  }) {
    final now = DateTime.now();
    return CursoModel(
      id: const Uuid().v4(),
      nome: nome,
      universidadeId: universidadeId,
      tipo: tipo,
      codigo: codigo,
      descricao: descricao,
      duracaoSemestres: duracaoSemestres,
      mediaMinima: mediaMinima ?? 9.5,
      mediaMaxima: mediaMaxima ?? 20.0,
      mediaAtual: null,
      unidadeCurricularIds: unidadeCurricularIds ?? [],
      pageIds: pageIds ?? [],
      fileIds: fileIds ?? [],
      dataInicio: dataInicio,
      dataFim: dataFim,
      ativo: ativo,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory CursoModel.fromJson(Map<String, dynamic> json) {
    return CursoModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      universidadeId: json['universidadeId'] as String,
      tipo: TipoCurso.values.firstWhere((e) => e.toString() == 'TipoCurso.${json['tipo']}'),
      codigo: json['codigo'] as String?,
      descricao: json['descricao'] as String?,
      duracaoSemestres: json['duracaoSemestres'] as int?,
      mediaMinima: (json['mediaMinima'] as num?)?.toDouble(),
      mediaMaxima: (json['mediaMaxima'] as num?)?.toDouble(),
      mediaAtual: (json['mediaAtual'] as num?)?.toDouble(),
      unidadeCurricularIds: List<String>.from(json['unidadeCurricularIds'] ?? []),
      pageIds: List<String>.from(json['pageIds'] ?? []),
      fileIds: List<String>.from(json['fileIds'] ?? []),
      dataInicio: json['dataInicio'] != null ? DateTime.parse(json['dataInicio']) : null,
      dataFim: json['dataFim'] != null ? DateTime.parse(json['dataFim']) : null,
      ativo: json['ativo'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'universidadeId': universidadeId,
      'tipo': tipo.name,
      'codigo': codigo,
      'descricao': descricao,
      'duracaoSemestres': duracaoSemestres,
      'mediaMinima': mediaMinima,
      'mediaMaxima': mediaMaxima,
      'mediaAtual': mediaAtual,
      'unidadeCurricularIds': unidadeCurricularIds,
      'pageIds': pageIds,
      'fileIds': fileIds,
      'dataInicio': dataInicio?.toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
      'ativo': ativo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  double calcularMedia(List<double> medias) {
    if (medias.isEmpty) return 0.0;
    return medias.reduce((a, b) => a + b) / medias.length;
  }

  bool get aprovado {
    if (mediaAtual == null || mediaMinima == null) return false;
    return mediaAtual! >= mediaMinima!;
  }

  String get statusCurso {
    if (!ativo) return 'Inativo';
    if (dataFim != null && DateTime.now().isAfter(dataFim!)) return 'Concluído';
    if (dataInicio != null && DateTime.now().isBefore(dataInicio!)) return 'Não Iniciado';
    return 'Em Curso';
  }

  CursoModel copyWith({
    String? id,
    String? nome,
    String? universidadeId,
    TipoCurso? tipo,
    String? codigo,
    String? descricao,
    int? duracaoSemestres,
    double? mediaMinima,
    double? mediaMaxima,
    double? mediaAtual,
    List<String>? unidadeCurricularIds,
    List<String>? pageIds,
    List<String>? fileIds,
    DateTime? dataInicio,
    DateTime? dataFim,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CursoModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      universidadeId: universidadeId ?? this.universidadeId,
      tipo: tipo ?? this.tipo,
      codigo: codigo ?? this.codigo,
      descricao: descricao ?? this.descricao,
      duracaoSemestres: duracaoSemestres ?? this.duracaoSemestres,
      mediaMinima: mediaMinima ?? this.mediaMinima,
      mediaMaxima: mediaMaxima ?? this.mediaMaxima,
      mediaAtual: mediaAtual ?? this.mediaAtual,
      unidadeCurricularIds: unidadeCurricularIds ?? this.unidadeCurricularIds,
      pageIds: pageIds ?? this.pageIds,
      fileIds: fileIds ?? this.fileIds,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CursoModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CursoModel(id: $id, nome: $nome, tipo: ${tipo.displayName})';
  }
}