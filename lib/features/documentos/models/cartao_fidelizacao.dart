import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum TipoFidelizacao {
  pontos,
  milhas,
  desconto,
  cashback,
  outros,
}

class CartaoFidelizacao {
  final String id;
  final String nome;
  final String empresa;
  final String numero;
  final String? nomeImpresso;
  final String? validade;
  final TipoFidelizacao tipo;
  final String? pontosAtuais;
  final String? pontosExpiracao;
  final String? beneficios;
  final String? website;
  final String? telefone;
  final String? email;
  final bool ativo;
  final String? observacoes;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  CartaoFidelizacao({
    String? id,
    required this.nome,
    required this.empresa,
    required this.numero,
    this.nomeImpresso,
    this.validade,
    required this.tipo,
    this.pontosAtuais,
    this.pontosExpiracao,
    this.beneficios,
    this.website,
    this.telefone,
    this.email,
    this.ativo = true,
    this.observacoes,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  })  : id = id ?? const Uuid().v4(),
        criadoEm = criadoEm ?? DateTime.now(),
        atualizadoEm = atualizadoEm ?? DateTime.now();

  /// Obter número mascarado para exibição
  String get numeroMascarado {
    if (numero.length < 4) return numero;
    return '**** **** **** ${numero.substring(numero.length - 4)}';
  }

  /// Verificar se o cartão está vencido
  bool get vencido {
    if (validade == null) return false;

    try {
      final partes = validade!.split('/');
      if (partes.length != 2) return false;

      final mes = int.parse(partes[0]);
      final ano = int.parse('20${partes[1]}');
      final dataVencimento =
          DateTime(ano, mes + 1, 1).subtract(const Duration(days: 1));

      return DateTime.now().isAfter(dataVencimento);
    } catch (e) {
      return false;
    }
  }

  /// Obter cor do tipo
  Color get corTipo {
    switch (tipo) {
      case TipoFidelizacao.pontos:
        return Colors.blue;
      case TipoFidelizacao.milhas:
        return Colors.orange;
      case TipoFidelizacao.desconto:
        return Colors.green;
      case TipoFidelizacao.cashback:
        return Colors.purple;
      case TipoFidelizacao.outros:
        return Colors.grey;
    }
  }

  /// Obter ícone do tipo
  IconData get iconeTipo {
    switch (tipo) {
      case TipoFidelizacao.pontos:
        return Icons.stars;
      case TipoFidelizacao.milhas:
        return Icons.flight;
      case TipoFidelizacao.desconto:
        return Icons.discount;
      case TipoFidelizacao.cashback:
        return Icons.account_balance_wallet;
      case TipoFidelizacao.outros:
        return Icons.card_giftcard;
    }
  }

  /// Obter nome do tipo
  String get nomeTipo {
    switch (tipo) {
      case TipoFidelizacao.pontos:
        return 'Pontos';
      case TipoFidelizacao.milhas:
        return 'Milhas';
      case TipoFidelizacao.desconto:
        return 'Desconto';
      case TipoFidelizacao.cashback:
        return 'Cashback';
      case TipoFidelizacao.outros:
        return 'Outros';
    }
  }

  /// Verificar se tem pontos expirando
  bool get pontosExpiram {
    if (pontosExpiracao == null) return false;

    try {
      final dataExpiracao = DateTime.parse(pontosExpiracao!);
      final agora = DateTime.now();
      final diasParaExpiracao = dataExpiracao.difference(agora).inDays;

      return diasParaExpiracao <= 30; // Expira em 30 dias ou menos
    } catch (e) {
      return false;
    }
  }

  CartaoFidelizacao copyWith({
    String? id,
    String? nome,
    String? empresa,
    String? numero,
    String? nomeImpresso,
    String? validade,
    TipoFidelizacao? tipo,
    String? pontosAtuais,
    String? pontosExpiracao,
    String? beneficios,
    String? website,
    String? telefone,
    String? email,
    bool? ativo,
    String? observacoes,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return CartaoFidelizacao(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      empresa: empresa ?? this.empresa,
      numero: numero ?? this.numero,
      nomeImpresso: nomeImpresso ?? this.nomeImpresso,
      validade: validade ?? this.validade,
      tipo: tipo ?? this.tipo,
      pontosAtuais: pontosAtuais ?? this.pontosAtuais,
      pontosExpiracao: pontosExpiracao ?? this.pontosExpiracao,
      beneficios: beneficios ?? this.beneficios,
      website: website ?? this.website,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      ativo: ativo ?? this.ativo,
      observacoes: observacoes ?? this.observacoes,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'empresa': empresa,
      'numero': numero,
      'nomeImpresso': nomeImpresso,
      'validade': validade,
      'tipo': tipo.name,
      'pontosAtuais': pontosAtuais,
      'pontosExpiracao': pontosExpiracao,
      'beneficios': beneficios,
      'website': website,
      'telefone': telefone,
      'email': email,
      'ativo': ativo,
      'observacoes': observacoes,
      'criadoEm': criadoEm.toIso8601String(),
      'atualizadoEm': atualizadoEm.toIso8601String(),
    };
  }

  factory CartaoFidelizacao.fromJson(Map<String, dynamic> json) {
    return CartaoFidelizacao(
      id: json['id'] as String?,
      nome: json['nome'] as String,
      empresa: json['empresa'] as String,
      numero: json['numero'] as String,
      nomeImpresso: json['nomeImpresso'] as String?,
      validade: json['validade'] as String?,
      tipo: TipoFidelizacao.values.firstWhere((e) => e.name == json['tipo']),
      pontosAtuais: json['pontosAtuais'] as String?,
      pontosExpiracao: json['pontosExpiracao'] as String?,
      beneficios: json['beneficios'] as String?,
      website: json['website'] as String?,
      telefone: json['telefone'] as String?,
      email: json['email'] as String?,
      ativo: json['ativo'] as bool? ?? true,
      observacoes: json['observacoes'] as String?,
      criadoEm: DateTime.parse(json['criadoEm'] as String),
      atualizadoEm: DateTime.parse(json['atualizadoEm'] as String),
    );
  }
}
