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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.assignment,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Próximas Avaliações',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  ref.read(universidadeDashboardTabProvider.notifier).state = 4;
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Ver todas'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          avaliacoesAsync.when(
            data: (avaliacoes) {
              final proximasAvaliacoes = _getProximasAvaliacoes(avaliacoes);

              if (proximasAvaliacoes.isEmpty) {
                return _buildEmptyState(context);
              }

              return Column(
                children: proximasAvaliacoes
                    .map((avaliacao) =>
                        _buildModernAvaliacaoItem(context, avaliacao))
                    .toList(),
              );
            },
            loading: () => _buildLoadingState(context),
            error: (error, stack) => _buildErrorState(context, error),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.assignment_turned_in,
              size: 48,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhuma avaliação próxima',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Erro ao carregar avaliações: $error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red[400],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<AvaliacaoModel> _getProximasAvaliacoes(List<AvaliacaoModel> avaliacoes) {
    final now = DateTime.now();
    final proximasAvaliacoes =
        avaliacoes.where((a) => !a.realizada && !a.entregue).where((a) {
      final dataLimite = a.dataAvaliacao ?? a.dataEntrega;
      return dataLimite != null && dataLimite.isAfter(now);
    }).toList();

    proximasAvaliacoes.sort((a, b) {
      final aData = a.dataAvaliacao ?? a.dataEntrega ?? a.createdAt;
      final bData = b.dataAvaliacao ?? b.dataEntrega ?? b.createdAt;
      return aData.compareTo(bData);
    });

    return proximasAvaliacoes.take(5).toList();
  }

  Widget _buildModernAvaliacaoItem(
      BuildContext context, AvaliacaoModel avaliacao) {
    final dataLimite = avaliacao.dataAvaliacao ?? avaliacao.dataEntrega;
    final diasRestantes = avaliacao.diasParaEntrega;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusColor = const Color(0xFF4F46E5);
    if (diasRestantes <= 1) {
      statusColor = const Color(0xFFEF4444);
    } else if (diasRestantes <= 3) {
      statusColor = const Color(0xFFF59E0B);
    } else if (diasRestantes <= 7) {
      statusColor = const Color(0xFFEAB308);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconForTipo(avaliacao.tipo),
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  avaliacao.nome,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  avaliacao.tipo.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                ),
                
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (dataLimite != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${dataLimite.day.toString().padLeft(2, '0')}/${dataLimite.month.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                  ),
                ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  diasRestantes == 1
                      ? 'Amanhã'
                      : diasRestantes == 0
                          ? 'Hoje'
                          : '$diasRestantes dias',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
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
        return Icons.present_to_all;
      case TipoAvaliacao.laboratorio:
        return Icons.science;
      case TipoAvaliacao.participacao:
        return Icons.forum;
      case TipoAvaliacao.outro:
        return Icons.assignment_outlined;
    }
  }
}
