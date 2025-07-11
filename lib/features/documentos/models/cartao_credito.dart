import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum TipoCartao {
  credito,
  debito,
  prepago,
}

enum BandeiraCartao {
  visa,
  mastercard,
  americanExpress,
  elo,
  hipercard,
  outros,
}

class CartaoCredito {
  final String id;
  final TipoCartao tipo;
  final BandeiraCartao bandeira;
  final String numero;
  final String nomeImpresso;
  final String validade;
  final String codigoSeguranca;
  final String emissor;
  final String? limite;
  final String? faturaAtual;
  final String? dataVencimentoFatura;
  final bool ativo;
  final String? observacoes;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  CartaoCredito({
    String? id,
    required this.tipo,
    required this.bandeira,
    required this.numero,
    required this.nomeImpresso,
    required this.validade,
    required this.codigoSeguranca,
    required this.emissor,
    this.limite,
    this.faturaAtual,
    this.dataVencimentoFatura,
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

  /// Obter código de segurança mascarado
  String get codigoSegurancaMascarado {
    return '***';
  }

  /// Verificar se o cartão está vencido
  bool get vencido {
    try {
      final partes = validade.split('/');
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

  /// Obter cor da bandeira
  Color get corBandeira {
    switch (bandeira) {
      case BandeiraCartao.visa:
        return const Color(0xFF1A1F71);
      case BandeiraCartao.mastercard:
        return const Color(0xFFEB001B);
      case BandeiraCartao.americanExpress:
        return const Color(0xFF006FCF);
      case BandeiraCartao.elo:
        return const Color(0xFF00A4E4);
      case BandeiraCartao.hipercard:
        return const Color(0xFFE31837);
      case BandeiraCartao.outros:
        return Colors.grey;
    }
  }

  /// Obter ícone da bandeira
  IconData get iconeBandeira {
    switch (bandeira) {
      case BandeiraCartao.visa:
        return Icons.credit_card;
      case BandeiraCartao.mastercard:
        return Icons.credit_card;
      case BandeiraCartao.americanExpress:
        return Icons.credit_card;
      case BandeiraCartao.elo:
        return Icons.credit_card;
      case BandeiraCartao.hipercard:
        return Icons.credit_card;
      case BandeiraCartao.outros:
        return Icons.credit_card;
    }
  }

  /// Obter nome da bandeira
  String get nomeBandeira {
    switch (bandeira) {
      case BandeiraCartao.visa:
        return 'Visa';
      case BandeiraCartao.mastercard:
        return 'Mastercard';
      case BandeiraCartao.americanExpress:
        return 'American Express';
      case BandeiraCartao.elo:
        return 'Elo';
      case BandeiraCartao.hipercard:
        return 'Hipercard';
      case BandeiraCartao.outros:
        return 'Outros';
    }
  }

  /// Obter nome do tipo
  String get nomeTipo {
    switch (tipo) {
      case TipoCartao.credito:
        return 'Crédito';
      case TipoCartao.debito:
        return 'Débito';
      case TipoCartao.prepago:
        return 'Pré-pago';
    }
  }

  CartaoCredito copyWith({
    String? id,
    TipoCartao? tipo,
    BandeiraCartao? bandeira,
    String? numero,
    String? nomeImpresso,
    String? validade,
    String? codigoSeguranca,
    String? emissor,
    String? limite,
    String? faturaAtual,
    String? dataVencimentoFatura,
    bool? ativo,
    String? observacoes,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return CartaoCredito(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      bandeira: bandeira ?? this.bandeira,
      numero: numero ?? this.numero,
      nomeImpresso: nomeImpresso ?? this.nomeImpresso,
      validade: validade ?? this.validade,
      codigoSeguranca: codigoSeguranca ?? this.codigoSeguranca,
      emissor: emissor ?? this.emissor,
      limite: limite ?? this.limite,
      faturaAtual: faturaAtual ?? this.faturaAtual,
      dataVencimentoFatura: dataVencimentoFatura ?? this.dataVencimentoFatura,
      ativo: ativo ?? this.ativo,
      observacoes: observacoes ?? this.observacoes,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo.name,
      'bandeira': bandeira.name,
      'numero': numero,
      'nomeImpresso': nomeImpresso,
      'validade': validade,
      'codigoSeguranca': codigoSeguranca,
      'emissor': emissor,
      'limite': limite,
      'faturaAtual': faturaAtual,
      'dataVencimentoFatura': dataVencimentoFatura,
      'ativo': ativo,
      'observacoes': observacoes,
      'criadoEm': criadoEm.toIso8601String(),
      'atualizadoEm': atualizadoEm.toIso8601String(),
    };
  }

  factory CartaoCredito.fromJson(Map<String, dynamic> json) {
    return CartaoCredito(
      id: json['id'] as String?,
      tipo: TipoCartao.values.firstWhere((e) => e.name == json['tipo']),
      bandeira:
          BandeiraCartao.values.firstWhere((e) => e.name == json['bandeira']),
      numero: json['numero'] as String,
      nomeImpresso: json['nomeImpresso'] as String,
      validade: json['validade'] as String,
      codigoSeguranca: json['codigoSeguranca'] as String,
      emissor: json['emissor'] as String,
      limite: json['limite'] as String?,
      faturaAtual: json['faturaAtual'] as String?,
      dataVencimentoFatura: json['dataVencimentoFatura'] as String?,
      ativo: json['ativo'] as bool? ?? true,
      observacoes: json['observacoes'] as String?,
      criadoEm: DateTime.parse(json['criadoEm'] as String),
      atualizadoEm: DateTime.parse(json['atualizadoEm'] as String),
    );
  }
}
