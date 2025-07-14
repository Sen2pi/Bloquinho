/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/cartao_credito.dart';
import '../../../core/theme/app_colors.dart';

class AddCartaoCreditoDialog extends StatefulWidget {
  final void Function(CartaoCredito) onAdd;
  final CartaoCredito? cartao; // Para edição

  const AddCartaoCreditoDialog({
    super.key,
    required this.onAdd,
    this.cartao,
  });

  @override
  State<AddCartaoCreditoDialog> createState() => _AddCartaoCreditoDialogState();
}

class _AddCartaoCreditoDialogState extends State<AddCartaoCreditoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _nomeImpressoController = TextEditingController();
  final _validadeController = TextEditingController();
  final _codigoSegurancaController = TextEditingController();
  final _emissorController = TextEditingController();
  final _limiteController = TextEditingController();
  final _faturaAtualController = TextEditingController();
  final _dataVencimentoFaturaController = TextEditingController();
  final _observacoesController = TextEditingController();

  TipoCartao _tipo = TipoCartao.credito;
  BandeiraCartao _bandeira = BandeiraCartao.visa;
  bool _ativo = true;

  @override
  void initState() {
    super.initState();
    if (widget.cartao != null) {
      // Modo edição
      final cartao = widget.cartao!;
      _tipo = cartao.tipo;
      _bandeira = cartao.bandeira;
      _numeroController.text = cartao.numero;
      _nomeImpressoController.text = cartao.nomeImpresso;
      _validadeController.text = cartao.validade;
      _codigoSegurancaController.text = cartao.codigoSeguranca;
      _emissorController.text = cartao.emissor;
      _limiteController.text = cartao.limite ?? '';
      _faturaAtualController.text = cartao.faturaAtual ?? '';
      _dataVencimentoFaturaController.text = cartao.dataVencimentoFatura ?? '';
      _observacoesController.text = cartao.observacoes ?? '';
      _ativo = cartao.ativo;
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _nomeImpressoController.dispose();
    _validadeController.dispose();
    _codigoSegurancaController.dispose();
    _emissorController.dispose();
    _limiteController.dispose();
    _faturaAtualController.dispose();
    _dataVencimentoFaturaController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.cartao != null;

    return Dialog(
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.creditCard(),
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? 'Editar Cartão' : 'Novo Cartão',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tipo e Bandeira
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<TipoCartao>(
                              value: _tipo,
                              decoration: const InputDecoration(
                                labelText: 'Tipo',
                                border: OutlineInputBorder(),
                              ),
                              items: TipoCartao.values.map((tipo) {
                                return DropdownMenuItem(
                                  value: tipo,
                                  child: Text(_getTipoName(tipo)),
                                );
                              }).toList(),
                              onChanged: (tipo) {
                                if (tipo != null) setState(() => _tipo = tipo);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<BandeiraCartao>(
                              value: _bandeira,
                              decoration: const InputDecoration(
                                labelText: 'Bandeira',
                                border: OutlineInputBorder(),
                              ),
                              items: BandeiraCartao.values.map((bandeira) {
                                return DropdownMenuItem(
                                  value: bandeira,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: _getBandeiraColor(bandeira),
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(_getBandeiraName(bandeira)),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (bandeira) {
                                if (bandeira != null)
                                  setState(() => _bandeira = bandeira);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Número do cartão
                      TextFormField(
                        controller: _numeroController,
                        decoration: const InputDecoration(
                          labelText: 'Número do Cartão',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.credit_card),
                        ),
                        keyboardType: TextInputType.number,
                        enableInteractiveSelection: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Número é obrigatório';
                          }
                          if (value.length < 13) {
                            return 'Número inválido';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Nome impresso
                      TextFormField(
                        controller: _nomeImpressoController,
                        decoration: const InputDecoration(
                          labelText: 'Nome Impresso',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        textCapitalization: TextCapitalization.words,
                        enableInteractiveSelection: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nome é obrigatório';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Validade e CVV
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _validadeController,
                              decoration: const InputDecoration(
                                labelText: 'Validade (MM/AA)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              keyboardType: TextInputType.number,
                              enableInteractiveSelection: true,
                              autocorrect: false,
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Validade é obrigatória';
                                }
                                if (value.length != 5) {
                                  return 'Formato: MM/AA';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _codigoSegurancaController,
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.security),
                              ),
                              keyboardType: TextInputType.number,
                              enableInteractiveSelection: true,
                              autocorrect: false,
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'CVV é obrigatório';
                                }
                                if (value.length < 3) {
                                  return 'CVV inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Emissor
                      TextFormField(
                        controller: _emissorController,
                        decoration: const InputDecoration(
                          labelText: 'Emissor/Banco',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_balance),
                        ),
                        enableInteractiveSelection: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Emissor é obrigatório';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Limite e Fatura (apenas para crédito)
                      if (_tipo == TipoCartao.credito) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _limiteController,
                                decoration: const InputDecoration(
                                  labelText: 'Limite',
                                  border: OutlineInputBorder(),
                                  prefixIcon:
                                      Icon(Icons.account_balance_wallet),
                                ),
                                keyboardType: TextInputType.number,
                                enableInteractiveSelection: true,
                                autocorrect: false,
                                enableSuggestions: false,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _faturaAtualController,
                                decoration: const InputDecoration(
                                  labelText: 'Fatura Atual',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.receipt),
                                ),
                                keyboardType: TextInputType.number,
                                enableInteractiveSelection: true,
                                autocorrect: false,
                                enableSuggestions: false,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _dataVencimentoFaturaController,
                          decoration: const InputDecoration(
                            labelText: 'Vencimento da Fatura',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.schedule),
                          ),
                          enableInteractiveSelection: true,
                          autocorrect: false,
                          enableSuggestions: false,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Observações
                      TextFormField(
                        controller: _observacoesController,
                        decoration: const InputDecoration(
                          labelText: 'Observações',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 3,
                        enableInteractiveSelection: true,
                        autocorrect: false,
                        enableSuggestions: false,
                      ),

                      const SizedBox(height: 16),

                      // Ativo
                      SwitchListTile(
                        title: const Text('Cartão Ativo'),
                        subtitle:
                            const Text('Desative para cartões cancelados'),
                        value: _ativo,
                        onChanged: (value) {
                          setState(() => _ativo = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDarkMode
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _salvar,
                    icon: Icon(isEditing
                        ? PhosphorIcons.check()
                        : PhosphorIcons.plus()),
                    label: Text(isEditing ? 'Salvar' : 'Adicionar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final cartao = CartaoCredito(
        id: widget.cartao?.id,
        tipo: _tipo,
        bandeira: _bandeira,
        numero: _numeroController.text,
        nomeImpresso: _nomeImpressoController.text,
        validade: _validadeController.text,
        codigoSeguranca: _codigoSegurancaController.text,
        emissor: _emissorController.text,
        limite:
            _limiteController.text.isNotEmpty ? _limiteController.text : null,
        faturaAtual: _faturaAtualController.text.isNotEmpty
            ? _faturaAtualController.text
            : null,
        dataVencimentoFatura: _dataVencimentoFaturaController.text.isNotEmpty
            ? _dataVencimentoFaturaController.text
            : null,
        ativo: _ativo,
        observacoes: _observacoesController.text.isNotEmpty
            ? _observacoesController.text
            : null,
      );

      widget.onAdd(cartao);
      Navigator.of(context).pop();
    }
  }

  String _getTipoName(TipoCartao tipo) {
    switch (tipo) {
      case TipoCartao.credito:
        return 'Crédito';
      case TipoCartao.debito:
        return 'Débito';
      case TipoCartao.prepago:
        return 'Pré-pago';
    }
  }

  String _getBandeiraName(BandeiraCartao bandeira) {
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

  Color _getBandeiraColor(BandeiraCartao bandeira) {
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
}
