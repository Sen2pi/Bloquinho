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

part 'universidade_model.g.dart';

@JsonSerializable()
class UniversidadeModel {
  final String id;
  final String nome;
  final String? sigla;
  final String? pais;
  final String? cidade;
  final String? website;
  final String? logo;
  final String? descricao;
  final List<String> cursoIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UniversidadeModel({
    required this.id,
    required this.nome,
    this.sigla,
    this.pais,
    this.cidade,
    this.website,
    this.logo,
    this.descricao,
    required this.cursoIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UniversidadeModel.create({
    required String nome,
    String? sigla,
    String? pais,
    String? cidade,
    String? website,
    String? logo,
    String? descricao,
    List<String>? cursoIds,
  }) {
    final now = DateTime.now();
    return UniversidadeModel(
      id: const Uuid().v4(),
      nome: nome,
      sigla: sigla,
      pais: pais,
      cidade: cidade,
      website: website,
      logo: logo,
      descricao: descricao,
      cursoIds: cursoIds ?? [],
      createdAt: now,
      updatedAt: now,
    );
  }

  factory UniversidadeModel.fromJson(Map<String, dynamic> json) =>
      _$UniversidadeModelFromJson(json);

  Map<String, dynamic> toJson() => _$UniversidadeModelToJson(this);

  UniversidadeModel copyWith({
    String? id,
    String? nome,
    String? sigla,
    String? pais,
    String? cidade,
    String? website,
    String? logo,
    String? descricao,
    List<String>? cursoIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UniversidadeModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      sigla: sigla ?? this.sigla,
      pais: pais ?? this.pais,
      cidade: cidade ?? this.cidade,
      website: website ?? this.website,
      logo: logo ?? this.logo,
      descricao: descricao ?? this.descricao,
      cursoIds: cursoIds ?? this.cursoIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UniversidadeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UniversidadeModel(id: $id, nome: $nome, sigla: $sigla)';
  }
}