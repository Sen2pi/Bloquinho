/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

// Modelo de Documento
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum TipoDocumento {
  identificacao,
  cartaoCredito,
  cartaoFidelizacao,
}

class Documento {
  final String id;
  final TipoDocumento tipo;
  final String titulo;
  final DateTime criadoEm;
  // Campos comuns
  final String descricao;
  // Campos específicos
  final String? numero;
  final String? validade;
  final String? nomeImpresso;
  final String? emissor;
  final String? codigoSeguranca;
  final String? programaFidelidade;

  Documento({
    String? id,
    required this.tipo,
    required this.titulo,
    required this.descricao,
    this.numero,
    this.validade,
    this.nomeImpresso,
    this.emissor,
    this.codigoSeguranca,
    this.programaFidelidade,
    DateTime? criadoEm,
  })  : id = id ?? const Uuid().v4(),
        criadoEm = criadoEm ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo.name,
      'titulo': titulo,
      'descricao': descricao,
      'numero': numero,
      'validade': validade,
      'nomeImpresso': nomeImpresso,
      'emissor': emissor,
      'codigoSeguranca': codigoSeguranca,
      'programaFidelidade': programaFidelidade,
      'criadoEm': criadoEm.toIso8601String(),
    };
  }

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      id: json['id'] as String?,
      tipo: TipoDocumento.values.firstWhere((e) => e.name == json['tipo']),
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String,
      numero: json['numero'] as String?,
      validade: json['validade'] as String?,
      nomeImpresso: json['nomeImpresso'] as String?,
      emissor: json['emissor'] as String?,
      codigoSeguranca: json['codigoSeguranca'] as String?,
      programaFidelidade: json['programaFidelidade'] as String?,
      criadoEm: DateTime.parse(json['criadoEm'] as String),
    );
  }
}
