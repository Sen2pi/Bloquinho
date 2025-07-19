/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/universidade_provider.dart';
import '../models/avaliacao_model.dart';

class RecentAvaliacoesWidget extends ConsumerWidget {
  const RecentAvaliacoesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avaliacoesAsync = ref.watch(avaliacoesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Próximas Avaliações',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(universidadeDashboardTabProvider.notifier).state = 4;
                  },
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            avaliacoesAsync.when(
              data: (avaliacoes) {
                final proximasAvaliacoes = _getProximasAvaliacoes(avaliacoes);
                
                if (proximasAvaliacoes.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.assignment_turned_in, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Nenhuma avaliação próxima'),
                        ],
                      ),
                    ),
                  );
                }
                
                return Column(
                  children: proximasAvaliacoes.map((avaliacao) => 
                    _buildAvaliacaoItem(context, avaliacao)
                  ).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Erro ao carregar avaliações: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<AvaliacaoModel> _getProximasAvaliacoes(List<AvaliacaoModel> avaliacoes) {
    final now = DateTime.now();
    final proximasAvaliacoes = avaliacoes
        .where((a) => !a.realizada && !a.entregue)
        .where((a) {
          final dataLimite = a.dataAvaliacao ?? a.dataEntrega;
          return dataLimite != null && dataLimite.isAfter(now);
        })
        .toList();
    
    proximasAvaliacoes.sort((a, b) {
      final aData = a.dataAvaliacao ?? a.dataEntrega ?? a.createdAt;
      final bData = b.dataAvaliacao ?? b.dataEntrega ?? b.createdAt;
      return aData.compareTo(bData);
    });
    
    return proximasAvaliacoes.take(5).toList();
  }

  Widget _buildAvaliacaoItem(BuildContext context, AvaliacaoModel avaliacao) {
    final dataLimite = avaliacao.dataAvaliacao ?? avaliacao.dataEntrega;
    final diasRestantes = avaliacao.diasParaEntrega;
    
    Color statusColor = Colors.blue;
    if (diasRestantes <= 1) {
      statusColor = Colors.red;
    } else if (diasRestantes <= 3) {
      statusColor = Colors.orange;
    } else if (diasRestantes <= 7) {
      statusColor = Colors.yellow[700]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.left(color: statusColor, width: 4),
        color: statusColor.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForTipo(avaliacao.tipo),
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  avaliacao.nome,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  avaliacao.tipo.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (dataLimite != null)
                Text(
                  '${dataLimite.day}/${dataLimite.month}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              Text(
                diasRestantes == 1 
                  ? 'Amanhã'
                  : diasRestantes == 0
                    ? 'Hoje'
                    : '$diasRestantes dias',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForTipo(TipoAvaliacao tipo) {
    switch (tipo) {
      case TipoAvaliacao.teste:
        return Icons.quiz;
      case TipoAvaliacao.exame:
        return Icons.school;
      case TipoAvaliacao.trabalho:
        return Icons.assignment;
      case TipoAvaliacao.projeto:
        return Icons.engineering;
      case TipoAvaliacao.apresentacao:
        return Icons.presentation_chart;
      case TipoAvaliacao.laboratorio:
        return Icons.science;
      case TipoAvaliacao.participacao:
        return Icons.forum;
      case TipoAvaliacao.outro:
        return Icons.assignment_outlined;
    }
  }
}