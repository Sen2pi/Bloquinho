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

enum TipoAvaliacao {
  @JsonValue('teste')
  teste,
  @JsonValue('exame')
  exame,
  @JsonValue('trabalho')
  trabalho,
  @JsonValue('projeto')
  projeto,
  @JsonValue('apresentacao')
  apresentacao,
  @JsonValue('laboratorio')
  laboratorio,
  @JsonValue('participacao')
  participacao,
  @JsonValue('outro')
  outro,
}

extension TipoAvaliacaoExtension on TipoAvaliacao {
  String get displayName {
    switch (this) {
      case TipoAvaliacao.teste:
        return 'Teste';
      case TipoAvaliacao.exame:
        return 'Exame';
      case TipoAvaliacao.trabalho:
        return 'Trabalho';
      case TipoAvaliacao.projeto:
        return 'Projeto';
      case TipoAvaliacao.apresentacao:
        return 'Apresentação';
      case TipoAvaliacao.laboratorio:
        return 'Laboratório';
      case TipoAvaliacao.participacao:
        return 'Participação';
      case TipoAvaliacao.outro:
        return 'Outro';
    }
  }
}

@JsonSerializable()
class AvaliacaoModel {
  final String id;
  final String nome;
  final String unidadeCurricularId;
  final TipoAvaliacao tipo;
  final double? nota;
  final double notaMaxima;
  final double peso;
  final DateTime? dataAvaliacao;
  final DateTime? dataEntrega;
  final String? descricao;
  final String? observacoes;
  final bool realizada;
  final bool entregue;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AvaliacaoModel({
    required this.id,
    required this.nome,
    required this.unidadeCurricularId,
    required this.tipo,
    this.nota,
    required this.notaMaxima,
    required this.peso,
    this.dataAvaliacao,
    this.dataEntrega,
    this.descricao,
    this.observacoes,
    this.realizada = false,
    this.entregue = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AvaliacaoModel.create({
    required String nome,
    required String unidadeCurricularId,
    required TipoAvaliacao tipo,
    double? nota,
    double notaMaxima = 20.0,
    double peso = 1.0,
    DateTime? dataAvaliacao,
    DateTime? dataEntrega,
    String? descricao,
    String? observacoes,
    bool realizada = false,
    bool entregue = false,
  }) {
    final now = DateTime.now();
    return AvaliacaoModel(
      id: const Uuid().v4(),
      nome: nome,
      unidadeCurricularId: unidadeCurricularId,
      tipo: tipo,
      nota: nota,
      notaMaxima: notaMaxima,
      peso: peso,
      dataAvaliacao: dataAvaliacao,
      dataEntrega: dataEntrega,
      descricao: descricao,
      observacoes: observacoes,
      realizada: realizada,
      entregue: entregue,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory AvaliacaoModel.fromJson(Map<String, dynamic> json) {
    return AvaliacaoModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      unidadeCurricularId: json['unidadeCurricularId'] as String,
      tipo: TipoAvaliacao.values.firstWhere((e) => e.name == json['tipo']),
      nota: (json['nota'] as num?)?.toDouble(),
      notaMaxima: (json['notaMaxima'] as num).toDouble(),
      peso: (json['peso'] as num).toDouble(),
      dataAvaliacao: json['dataAvaliacao'] != null ? DateTime.parse(json['dataAvaliacao']) : null,
      dataEntrega: json['dataEntrega'] != null ? DateTime.parse(json['dataEntrega']) : null,
      descricao: json['descricao'] as String?,
      observacoes: json['observacoes'] as String?,
      realizada: json['realizada'] as bool? ?? false,
      entregue: json['entregue'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'unidadeCurricularId': unidadeCurricularId,
      'tipo': tipo.name,
      'nota': nota,
      'notaMaxima': notaMaxima,
      'peso': peso,
      'dataAvaliacao': dataAvaliacao?.toIso8601String(),
      'dataEntrega': dataEntrega?.toIso8601String(),
      'descricao': descricao,
      'observacoes': observacoes,
      'realizada': realizada,
      'entregue': entregue,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  double get percentualNota {
    if (nota == null || notaMaxima == 0) return 0.0;
    return (nota! / notaMaxima) * 100;
  }

  bool get aprovado {
    if (nota == null) return false;
    return percentualNota >= 50.0;
  }

  String get status {
    if (!realizada && !entregue) {
      if (dataAvaliacao != null && DateTime.now().isAfter(dataAvaliacao!)) {
        return 'Em atraso';
      }
      return 'Pendente';
    }
    if (realizada || entregue) {
      if (nota != null) {
        return aprovado ? 'Aprovado' : 'Reprovado';
      }
      return 'Aguardando correção';
    }
    return 'Não realizada';
  }

  bool get emAtraso {
    if (realizada || entregue) return false;
    if (dataAvaliacao != null) {
      return DateTime.now().isAfter(dataAvaliacao!);
    }
    if (dataEntrega != null) {
      return DateTime.now().isAfter(dataEntrega!);
    }
    return false;
  }

  int get diasParaEntrega {
    if (realizada || entregue) return 0;
    final dataLimite = dataEntrega ?? dataAvaliacao;
    if (dataLimite == null) return -1;
    return dataLimite.difference(DateTime.now()).inDays;
  }

  AvaliacaoModel copyWith({
    String? id,
    String? nome,
    String? unidadeCurricularId,
    TipoAvaliacao? tipo,
    double? nota,
    double? notaMaxima,
    double? peso,
    DateTime? dataAvaliacao,
    DateTime? dataEntrega,
    String? descricao,
    String? observacoes,
    bool? realizada,
    bool? entregue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AvaliacaoModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      unidadeCurricularId: unidadeCurricularId ?? this.unidadeCurricularId,
      tipo: tipo ?? this.tipo,
      nota: nota ?? this.nota,
      notaMaxima: notaMaxima ?? this.notaMaxima,
      peso: peso ?? this.peso,
      dataAvaliacao: dataAvaliacao ?? this.dataAvaliacao,
      dataEntrega: dataEntrega ?? this.dataEntrega,
      descricao: descricao ?? this.descricao,
      observacoes: observacoes ?? this.observacoes,
      realizada: realizada ?? this.realizada,
      entregue: entregue ?? this.entregue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AvaliacaoModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AvaliacaoModel(id: $id, nome: $nome, tipo: ${tipo.displayName})';
  }
}