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

part 'unidade_curricular_model.g.dart';

@JsonSerializable()
class ConfiguracaoMedia {
  final Map<String, double> percentagens;
  final double notaMinima;
  final double notaMaxima;

  const ConfiguracaoMedia({
    required this.percentagens,
    required this.notaMinima,
    required this.notaMaxima,
  });

  factory ConfiguracaoMedia.fromJson(Map<String, dynamic> json) =>
      _$ConfiguracaoMediaFromJson(json);

  Map<String, dynamic> toJson() => _$ConfiguracaoMediaToJson(this);

  ConfiguracaoMedia copyWith({
    Map<String, double>? percentagens,
    double? notaMinima,
    double? notaMaxima,
  }) {
    return ConfiguracaoMedia(
      percentagens: percentagens ?? this.percentagens,
      notaMinima: notaMinima ?? this.notaMinima,
      notaMaxima: notaMaxima ?? this.notaMaxima,
    );
  }
}

@JsonSerializable()
class UnidadeCurricularModel {
  final String id;
  final String nome;
  final String cursoId;
  final String? codigo;
  final String? professor;
  final String? descricao;
  final int? creditos;
  final int? semestre;
  final int? anoLetivo;
  final ConfiguracaoMedia configuracaoMedia;
  final double? mediaAtual;
  final List<String> avaliacaoIds;
  final List<String> pageIds;
  final List<String> fileIds;
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UnidadeCurricularModel({
    required this.id,
    required this.nome,
    required this.cursoId,
    this.codigo,
    this.professor,
    this.descricao,
    this.creditos,
    this.semestre,
    this.anoLetivo,
    required this.configuracaoMedia,
    this.mediaAtual,
    required this.avaliacaoIds,
    required this.pageIds,
    required this.fileIds,
    this.ativo = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UnidadeCurricularModel.create({
    required String nome,
    required String cursoId,
    String? codigo,
    String? professor,
    String? descricao,
    int? creditos,
    int? semestre,
    int? anoLetivo,
    ConfiguracaoMedia? configuracaoMedia,
    List<String>? avaliacaoIds,
    List<String>? pageIds,
    List<String>? fileIds,
    bool ativo = true,
  }) {
    final now = DateTime.now();
    return UnidadeCurricularModel(
      id: const Uuid().v4(),
      nome: nome,
      cursoId: cursoId,
      codigo: codigo,
      professor: professor,
      descricao: descricao,
      creditos: creditos,
      semestre: semestre,
      anoLetivo: anoLetivo,
      configuracaoMedia: configuracaoMedia ?? 
          const ConfiguracaoMedia(
            percentagens: {},
            notaMinima: 9.5,
            notaMaxima: 20.0,
          ),
      mediaAtual: null,
      avaliacaoIds: avaliacaoIds ?? [],
      pageIds: pageIds ?? [],
      fileIds: fileIds ?? [],
      ativo: ativo,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory UnidadeCurricularModel.fromJson(Map<String, dynamic> json) =>
      _$UnidadeCurricularModelFromJson(json);

  Map<String, dynamic> toJson() => _$UnidadeCurricularModelToJson(this);

  bool get aprovado {
    if (mediaAtual == null) return false;
    return mediaAtual! >= configuracaoMedia.notaMinima;
  }

  String get status {
    if (!ativo) return 'Inativa';
    if (mediaAtual == null) return 'Sem avaliações';
    if (aprovado) return 'Aprovado';
    return 'Reprovado';
  }

  double calcularMediaComPercentagens(Map<String, double> notas) {
    if (notas.isEmpty || configuracaoMedia.percentagens.isEmpty) return 0.0;
    
    double mediaFinal = 0.0;
    double totalPercentagem = 0.0;
    
    for (final entry in configuracaoMedia.percentagens.entries) {
      final tipoAvaliacao = entry.key;
      final percentagem = entry.value;
      
      if (notas.containsKey(tipoAvaliacao)) {
        mediaFinal += notas[tipoAvaliacao]! * (percentagem / 100);
        totalPercentagem += percentagem;
      }
    }
    
    if (totalPercentagem > 0) {
      return (mediaFinal / totalPercentagem) * 100;
    }
    
    return 0.0;
  }

  UnidadeCurricularModel copyWith({
    String? id,
    String? nome,
    String? cursoId,
    String? codigo,
    String? professor,
    String? descricao,
    int? creditos,
    int? semestre,
    int? anoLetivo,
    ConfiguracaoMedia? configuracaoMedia,
    double? mediaAtual,
    List<String>? avaliacaoIds,
    List<String>? pageIds,
    List<String>? fileIds,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UnidadeCurricularModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cursoId: cursoId ?? this.cursoId,
      codigo: codigo ?? this.codigo,
      professor: professor ?? this.professor,
      descricao: descricao ?? this.descricao,
      creditos: creditos ?? this.creditos,
      semestre: semestre ?? this.semestre,
      anoLetivo: anoLetivo ?? this.anoLetivo,
      configuracaoMedia: configuracaoMedia ?? this.configuracaoMedia,
      mediaAtual: mediaAtual ?? this.mediaAtual,
      avaliacaoIds: avaliacaoIds ?? this.avaliacaoIds,
      pageIds: pageIds ?? this.pageIds,
      fileIds: fileIds ?? this.fileIds,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnidadeCurricularModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UnidadeCurricularModel(id: $id, nome: $nome, semestre: $semestre)';
  }
}