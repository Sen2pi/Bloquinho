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

import '../models/cartao_fidelizacao.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_action_button.dart';
import 'documento_grid_card.dart';

class CartaoFidelizacaoListWidget extends StatelessWidget {
  final List<CartaoFidelizacao> cartoes;
  final bool isLoading;
  final VoidCallback onAdd;
  final Function(CartaoFidelizacao) onEdit;
  final Function(String) onDelete;

  const CartaoFidelizacaoListWidget({
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
              text: 'Adicionar Cartão de Fidelização',
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
                childAspectRatio: 0.8,
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
            PhosphorIcons.star(),
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum cartão de fidelização',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione seu primeiro cartão de fidelização',
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

  Widget _buildCartaoGridCard(BuildContext context, CartaoFidelizacao cartao) {
    String informacaoSecundaria = cartao.empresa;
    if (cartao.pontosAtuais != null) {
      informacaoSecundaria += ' • ${cartao.pontosAtuais} pts';
    }
    
    return DocumentoGridCard(
      imagemPath: cartao.imagemPath,
      titulo: cartao.nome,
      subtitulo: cartao.nomeTipo,
      informacaoSecundaria: informacaoSecundaria,
      corPrimaria: cartao.corTipo,
      iconePadrao: cartao.iconeTipo,
      isVencido: cartao.vencido || cartao.pontosExpiram,
      onEdit: () => onEdit(cartao),
      onDelete: () => onDelete(cartao.id),
    );
  }
}
