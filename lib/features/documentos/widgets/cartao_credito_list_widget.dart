/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/cartao_credito.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_action_button.dart';
import 'documento_grid_card.dart';

class CartaoCreditoListWidget extends StatelessWidget {
  final List<CartaoCredito> cartoes;
  final bool isLoading;
  final VoidCallback onAdd;
  final Function(CartaoCredito) onEdit;
  final Function(String) onDelete;

  const CartaoCreditoListWidget({
    super.key,
    required this.cartoes,
    required this.isLoading,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cartoes.isEmpty) {
      return _buildEmptyState(context);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Botão de adicionar
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            child: AnimatedActionButton(
              text: 'Adicionar Cartão',
              onPressed: onAdd,
              isLoading: false,
              isEnabled: true,
              icon: PhosphorIcons.plus(),
            ),
          ),
          // Grid de cartões
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8, // Ratio para altura ajustável
              ),
              itemCount: cartoes.length,
              itemBuilder: (context, index) {
                final cartao = cartoes[index];
                return _buildCartaoGridCard(context, cartao);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.creditCard(),
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum cartão cadastrado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione seu primeiro cartão de crédito/débito',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 16),
          AnimatedActionButton(
            text: 'Adicionar Cartão',
            onPressed: onAdd,
            isLoading: false,
            isEnabled: true,
            icon: PhosphorIcons.plus(),
          ),
        ],
      ),
    );
  }

  Widget _buildCartaoGridCard(BuildContext context, CartaoCredito cartao) {
    return DocumentoGridCard(
      imagemPath: cartao.imagemPath,
      titulo: cartao.nomeBandeira,
      subtitulo: cartao.numeroMascarado,
      informacaoSecundaria: '${cartao.nomeTipo} • ${cartao.validade}',
      corPrimaria: cartao.corBandeira,
      iconePadrao: cartao.iconeBandeira,
      isVencido: cartao.vencido,
      onEdit: () => onEdit(cartao),
      onDelete: () => onDelete(cartao.id),
    );
  }
}
