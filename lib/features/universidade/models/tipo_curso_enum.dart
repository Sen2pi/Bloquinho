/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:json_annotation/json_annotation.dart';

enum TipoCurso {
  @JsonValue('licenciatura')
  licenciatura,
  @JsonValue('mestrado')
  mestrado,
  @JsonValue('pos_graduacao')
  posGraduacao,
  @JsonValue('doutoramento')
  doutoramento,
}

extension TipoCursoExtension on TipoCurso {
  String get displayName {
    switch (this) {
      case TipoCurso.licenciatura:
        return 'Licenciatura';
      case TipoCurso.mestrado:
        return 'Mestrado';
      case TipoCurso.posGraduacao:
        return 'Pós-Graduação';
      case TipoCurso.doutoramento:
        return 'Doutoramento';
    }
  }

  String get abreviacao {
    switch (this) {
      case TipoCurso.licenciatura:
        return 'Lic.';
      case TipoCurso.mestrado:
        return 'MSc.';
      case TipoCurso.posGraduacao:
        return 'Esp.';
      case TipoCurso.doutoramento:
        return 'PhD.';
    }
  }

  int get nivelAcademico {
    switch (this) {
      case TipoCurso.licenciatura:
        return 1;
      case TipoCurso.posGraduacao:
        return 2;
      case TipoCurso.mestrado:
        return 3;
      case TipoCurso.doutoramento:
        return 4;
    }
  }

  static TipoCurso fromString(String value) {
    switch (value.toLowerCase()) {
      case 'licenciatura':
        return TipoCurso.licenciatura;
      case 'mestrado':
        return TipoCurso.mestrado;
      case 'pos_graduacao':
      case 'pós-graduação':
        return TipoCurso.posGraduacao;
      case 'doutoramento':
        return TipoCurso.doutoramento;
      default:
        return TipoCurso.licenciatura;
    }
  }
}