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

enum StatusAvaliacao {
  @JsonValue('pendente')
  pendente,
  @JsonValue('em_andamento')
  emAndamento,
  @JsonValue('entregue')
  entregue,
  @JsonValue('corrigida')
  corrigida,
  @JsonValue('aprovada')
  aprovada,
  @JsonValue('reprovada')
  reprovada,
  @JsonValue('em_atraso')
  emAtraso,
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

extension StatusAvaliacaoExtension on StatusAvaliacao {
  String get displayName {
    switch (this) {
      case StatusAvaliacao.pendente:
        return 'Pendente';
      case StatusAvaliacao.emAndamento:
        return 'Em Andamento';
      case StatusAvaliacao.entregue:
        return 'Entregue';
      case StatusAvaliacao.corrigida:
        return 'Corrigida';
      case StatusAvaliacao.aprovada:
        return 'Aprovada';
      case StatusAvaliacao.reprovada:
        return 'Reprovada';
      case StatusAvaliacao.emAtraso:
        return 'Em Atraso';
    }
  }
}

@JsonSerializable()
class AvaliacaoModel {
  final String id;
  final String nome;
  final String unidadeCurricularId;
  final TipoAvaliacao tipo;
  final StatusAvaliacao statusAvaliacao;
  final double? nota;
  final double notaMaxima;
  final double peso;
  final DateTime? dataAvaliacao;
  final DateTime? dataEntrega;
  final DateTime? deadline;
  final String? descricao;
  final String? observacoes;
  final bool realizada;
  final bool entregue;
  final String? agendaItemId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AvaliacaoModel({
    required this.id,
    required this.nome,
    required this.unidadeCurricularId,
    required this.tipo,
    this.statusAvaliacao = StatusAvaliacao.pendente,
    this.nota,
    required this.notaMaxima,
    required this.peso,
    this.dataAvaliacao,
    this.dataEntrega,
    this.deadline,
    this.descricao,
    this.observacoes,
    this.realizada = false,
    this.entregue = false,
    this.agendaItemId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AvaliacaoModel.create({
    required String nome,
    required String unidadeCurricularId,
    required TipoAvaliacao tipo,
    StatusAvaliacao statusAvaliacao = StatusAvaliacao.pendente,
    double? nota,
    double notaMaxima = 20.0,
    double peso = 1.0,
    DateTime? dataAvaliacao,
    DateTime? dataEntrega,
    DateTime? deadline,
    String? descricao,
    String? observacoes,
    bool realizada = false,
    bool entregue = false,
    String? agendaItemId,
  }) {
    final now = DateTime.now();
    return AvaliacaoModel(
      id: const Uuid().v4(),
      nome: nome,
      unidadeCurricularId: unidadeCurricularId,
      tipo: tipo,
      statusAvaliacao: statusAvaliacao,
      nota: nota,
      notaMaxima: notaMaxima,
      peso: peso,
      dataAvaliacao: dataAvaliacao,
      dataEntrega: dataEntrega,
      deadline: deadline,
      descricao: descricao,
      observacoes: observacoes,
      realizada: realizada,
      entregue: entregue,
      agendaItemId: agendaItemId,
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
      statusAvaliacao: json['statusAvaliacao'] != null 
        ? StatusAvaliacao.values.firstWhere((e) => e.name == json['statusAvaliacao'])
        : StatusAvaliacao.pendente,
      nota: (json['nota'] as num?)?.toDouble(),
      notaMaxima: (json['notaMaxima'] as num).toDouble(),
      peso: (json['peso'] as num).toDouble(),
      dataAvaliacao: json['dataAvaliacao'] != null ? DateTime.parse(json['dataAvaliacao']) : null,
      dataEntrega: json['dataEntrega'] != null ? DateTime.parse(json['dataEntrega']) : null,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      descricao: json['descricao'] as String?,
      observacoes: json['observacoes'] as String?,
      realizada: json['realizada'] as bool? ?? false,
      entregue: json['entregue'] as bool? ?? false,
      agendaItemId: json['agendaItemId'] as String?,
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
      'statusAvaliacao': statusAvaliacao.name,
      'nota': nota,
      'notaMaxima': notaMaxima,
      'peso': peso,
      'dataAvaliacao': dataAvaliacao?.toIso8601String(),
      'dataEntrega': dataEntrega?.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'descricao': descricao,
      'observacoes': observacoes,
      'realizada': realizada,
      'entregue': entregue,
      'agendaItemId': agendaItemId,
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
    return statusAvaliacao.displayName;
  }

  StatusAvaliacao get statusCalculado {
    final now = DateTime.now();
    
    // Se já foi corrigida com nota
    if (nota != null) {
      return aprovado ? StatusAvaliacao.aprovada : StatusAvaliacao.reprovada;
    }
    
    // Se foi entregue mas ainda não corrigida
    if (entregue || realizada) {
      return StatusAvaliacao.corrigida;
    }
    
    // Verificar se está em atraso
    final dataLimite = deadline ?? dataEntrega ?? dataAvaliacao;
    if (dataLimite != null && now.isAfter(dataLimite)) {
      return StatusAvaliacao.emAtraso;
    }
    
    // Status padrão baseado nas datas
    if (dataAvaliacao != null && now.isAfter(dataAvaliacao!.subtract(const Duration(days: 7)))) {
      return StatusAvaliacao.emAndamento;
    }
    
    return StatusAvaliacao.pendente;
  }

  bool get emAtraso {
    if (realizada || entregue) return false;
    final dataLimite = deadline ?? dataEntrega ?? dataAvaliacao;
    return dataLimite != null && DateTime.now().isAfter(dataLimite);
  }

  int get diasParaEntrega {
    if (realizada || entregue) return 0;
    final dataLimite = deadline ?? dataEntrega ?? dataAvaliacao;
    if (dataLimite == null) return -1;
    return dataLimite.difference(DateTime.now()).inDays;
  }

  DateTime? get dataLimiteEfetiva {
    return deadline ?? dataEntrega ?? dataAvaliacao;
  }

  AvaliacaoModel copyWith({
    String? id,
    String? nome,
    String? unidadeCurricularId,
    TipoAvaliacao? tipo,
    StatusAvaliacao? statusAvaliacao,
    double? nota,
    double? notaMaxima,
    double? peso,
    DateTime? dataAvaliacao,
    DateTime? dataEntrega,
    DateTime? deadline,
    String? descricao,
    String? observacoes,
    bool? realizada,
    bool? entregue,
    String? agendaItemId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AvaliacaoModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      unidadeCurricularId: unidadeCurricularId ?? this.unidadeCurricularId,
      tipo: tipo ?? this.tipo,
      statusAvaliacao: statusAvaliacao ?? this.statusAvaliacao,
      nota: nota ?? this.nota,
      notaMaxima: notaMaxima ?? this.notaMaxima,
      peso: peso ?? this.peso,
      dataAvaliacao: dataAvaliacao ?? this.dataAvaliacao,
      dataEntrega: dataEntrega ?? this.dataEntrega,
      deadline: deadline ?? this.deadline,
      descricao: descricao ?? this.descricao,
      observacoes: observacoes ?? this.observacoes,
      realizada: realizada ?? this.realizada,
      entregue: entregue ?? this.entregue,
      agendaItemId: agendaItemId ?? this.agendaItemId,
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