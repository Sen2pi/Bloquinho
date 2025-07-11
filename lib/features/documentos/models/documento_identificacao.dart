import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

enum TipoIdentificacao {
  rg,
  cpf,
  cnh,
  passaporte,
  tituloEleitor,
  carteiraTrabalho,
  outros,
}

class DocumentoIdentificacao {
  final String id;
  final TipoIdentificacao tipo;
  final String numero;
  final String nomeCompleto;
  final String? orgaoEmissor;
  final String? dataEmissao;
  final String? dataVencimento;
  final String? naturalidade;
  final String? nacionalidade;
  final String? nomePai;
  final String? nomeMae;
  final String? observacoes;
  final String? arquivoPdfPath;
  final String? arquivoImagemPath;
  final bool ativo;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  DocumentoIdentificacao({
    String? id,
    required this.tipo,
    required this.numero,
    required this.nomeCompleto,
    this.orgaoEmissor,
    this.dataEmissao,
    this.dataVencimento,
    this.naturalidade,
    this.nacionalidade,
    this.nomePai,
    this.nomeMae,
    this.observacoes,
    this.arquivoPdfPath,
    this.arquivoImagemPath,
    this.ativo = true,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  })  : id = id ?? const Uuid().v4(),
        criadoEm = criadoEm ?? DateTime.now(),
        atualizadoEm = atualizadoEm ?? DateTime.now();

  /// Verificar se o documento está vencido
  bool get vencido {
    if (dataVencimento == null) return false;

    try {
      final dataVencimento = DateTime.parse(this.dataVencimento!);
      return DateTime.now().isAfter(dataVencimento);
    } catch (e) {
      return false;
    }
  }

  /// Verificar se vence em breve (30 dias)
  bool get venceEmBreve {
    if (dataVencimento == null) return false;

    try {
      final dataVencimento = DateTime.parse(this.dataVencimento!);
      final agora = DateTime.now();
      final diasParaVencimento = dataVencimento.difference(agora).inDays;

      return diasParaVencimento <= 30 && diasParaVencimento > 0;
    } catch (e) {
      return false;
    }
  }

  /// Verificar se tem arquivo PDF
  bool get temPdf =>
      arquivoPdfPath != null && File(arquivoPdfPath!).existsSync();

  /// Verificar se tem imagem
  bool get temImagem =>
      arquivoImagemPath != null && File(arquivoImagemPath!).existsSync();

  /// Obter cor do tipo
  Color get corTipo {
    switch (tipo) {
      case TipoIdentificacao.rg:
        return Colors.blue;
      case TipoIdentificacao.cpf:
        return Colors.green;
      case TipoIdentificacao.cnh:
        return Colors.orange;
      case TipoIdentificacao.passaporte:
        return Colors.purple;
      case TipoIdentificacao.tituloEleitor:
        return Colors.red;
      case TipoIdentificacao.carteiraTrabalho:
        return Colors.brown;
      case TipoIdentificacao.outros:
        return Colors.grey;
    }
  }

  /// Obter ícone do tipo
  IconData get iconeTipo {
    switch (tipo) {
      case TipoIdentificacao.rg:
        return Icons.badge;
      case TipoIdentificacao.cpf:
        return Icons.credit_card;
      case TipoIdentificacao.cnh:
        return Icons.drive_eta;
      case TipoIdentificacao.passaporte:
        return Icons.flight;
      case TipoIdentificacao.tituloEleitor:
        return Icons.how_to_vote;
      case TipoIdentificacao.carteiraTrabalho:
        return Icons.work;
      case TipoIdentificacao.outros:
        return Icons.description;
    }
  }

  /// Obter nome do tipo
  String get nomeTipo {
    switch (tipo) {
      case TipoIdentificacao.rg:
        return 'RG';
      case TipoIdentificacao.cpf:
        return 'CPF';
      case TipoIdentificacao.cnh:
        return 'CNH';
      case TipoIdentificacao.passaporte:
        return 'Passaporte';
      case TipoIdentificacao.tituloEleitor:
        return 'Título de Eleitor';
      case TipoIdentificacao.carteiraTrabalho:
        return 'Carteira de Trabalho';
      case TipoIdentificacao.outros:
        return 'Outros';
    }
  }

  /// Obter número formatado
  String get numeroFormatado {
    switch (tipo) {
      case TipoIdentificacao.cpf:
        return _formatarCPF(numero);
      case TipoIdentificacao.rg:
        return _formatarRG(numero);
      default:
        return numero;
    }
  }

  /// Formatar CPF
  String _formatarCPF(String cpf) {
    if (cpf.length != 11) return cpf;
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }

  /// Formatar RG
  String _formatarRG(String rg) {
    if (rg.length < 8) return rg;
    return '${rg.substring(0, 2)}.${rg.substring(2, 5)}.${rg.substring(5, 8)}-${rg.substring(8)}';
  }

  DocumentoIdentificacao copyWith({
    String? id,
    TipoIdentificacao? tipo,
    String? numero,
    String? nomeCompleto,
    String? orgaoEmissor,
    String? dataEmissao,
    String? dataVencimento,
    String? naturalidade,
    String? nacionalidade,
    String? nomePai,
    String? nomeMae,
    String? observacoes,
    String? arquivoPdfPath,
    String? arquivoImagemPath,
    bool? ativo,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return DocumentoIdentificacao(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      numero: numero ?? this.numero,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      orgaoEmissor: orgaoEmissor ?? this.orgaoEmissor,
      dataEmissao: dataEmissao ?? this.dataEmissao,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      naturalidade: naturalidade ?? this.naturalidade,
      nacionalidade: nacionalidade ?? this.nacionalidade,
      nomePai: nomePai ?? this.nomePai,
      nomeMae: nomeMae ?? this.nomeMae,
      observacoes: observacoes ?? this.observacoes,
      arquivoPdfPath: arquivoPdfPath ?? this.arquivoPdfPath,
      arquivoImagemPath: arquivoImagemPath ?? this.arquivoImagemPath,
      ativo: ativo ?? this.ativo,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo.name,
      'numero': numero,
      'nomeCompleto': nomeCompleto,
      'orgaoEmissor': orgaoEmissor,
      'dataEmissao': dataEmissao,
      'dataVencimento': dataVencimento,
      'naturalidade': naturalidade,
      'nacionalidade': nacionalidade,
      'nomePai': nomePai,
      'nomeMae': nomeMae,
      'observacoes': observacoes,
      'arquivoPdfPath': arquivoPdfPath,
      'arquivoImagemPath': arquivoImagemPath,
      'ativo': ativo,
      'criadoEm': criadoEm.toIso8601String(),
      'atualizadoEm': atualizadoEm.toIso8601String(),
    };
  }

  factory DocumentoIdentificacao.fromJson(Map<String, dynamic> json) {
    return DocumentoIdentificacao(
      id: json['id'] as String?,
      tipo: TipoIdentificacao.values.firstWhere((e) => e.name == json['tipo']),
      numero: json['numero'] as String,
      nomeCompleto: json['nomeCompleto'] as String,
      orgaoEmissor: json['orgaoEmissor'] as String?,
      dataEmissao: json['dataEmissao'] as String?,
      dataVencimento: json['dataVencimento'] as String?,
      naturalidade: json['naturalidade'] as String?,
      nacionalidade: json['nacionalidade'] as String?,
      nomePai: json['nomePai'] as String?,
      nomeMae: json['nomeMae'] as String?,
      observacoes: json['observacoes'] as String?,
      arquivoPdfPath: json['arquivoPdfPath'] as String?,
      arquivoImagemPath: json['arquivoImagemPath'] as String?,
      ativo: json['ativo'] as bool? ?? true,
      criadoEm: DateTime.parse(json['criadoEm'] as String),
      atualizadoEm: DateTime.parse(json['atualizadoEm'] as String),
    );
  }
}
