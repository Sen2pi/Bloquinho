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
import '../widgets/add_avaliacao_dialog.dart';
import '../widgets/avaliacao_card.dart';

class AvaliacoesScreen extends ConsumerWidget {
  const AvaliacoesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avaliacoesAsync = ref.watch(avaliacoesProvider);
    final searchQuery = ref.watch(avaliacaoSearchQueryProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildSearchAndFilters(context, ref),
          Expanded(
            child: avaliacoesAsync.when(
              data: (avaliacoes) {
                final filteredAvaliacoes = _filterAvaliacoes(avaliacoes, searchQuery);
                
                if (filteredAvaliacoes.isEmpty) {
                  return _buildEmptyState(context);
                }
                
                return _buildAvaliacoesList(context, ref, filteredAvaliacoes);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erro ao carregar avaliações: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(avaliacoesProvider),
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAvaliacaoDialog(context, ref),
        tooltip: 'Adicionar Avaliação',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar avaliações...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              ref.read(avaliacaoSearchQueryProvider.notifier).state = value;
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, 'Todas', true, () {}),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Pendentes', false, () {}),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Realizadas', false, () {}),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Em Atraso', false, () {}),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Aprovadas', false, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma avaliação encontrada',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione sua primeira avaliação para começar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvaliacoesList(BuildContext context, WidgetRef ref, List<AvaliacaoModel> avaliacoes) {
    final sortedAvaliacoes = List<AvaliacaoModel>.from(avaliacoes);
    sortedAvaliacoes.sort((a, b) {
      final aData = a.dataAvaliacao ?? a.dataEntrega ?? a.createdAt;
      final bData = b.dataAvaliacao ?? b.dataEntrega ?? b.createdAt;
      return aData.compareTo(bData);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedAvaliacoes.length,
      itemBuilder: (context, index) {
        final avaliacao = sortedAvaliacoes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: AvaliacaoCard(
            avaliacao: avaliacao,
            onTap: () => _navigateToAvaliacaoDetails(context, avaliacao),
            onEdit: () => _showEditAvaliacaoDialog(context, ref, avaliacao),
            onDelete: () => _showDeleteConfirmation(context, ref, avaliacao),
          ),
        );
      },
    );
  }

  List<AvaliacaoModel> _filterAvaliacoes(List<AvaliacaoModel> avaliacoes, String query) {
    if (query.isEmpty) return avaliacoes;
    
    final lowercaseQuery = query.toLowerCase();
    return avaliacoes.where((avaliacao) {
      return avaliacao.nome.toLowerCase().contains(lowercaseQuery) ||
             avaliacao.tipo.displayName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  void _showAddAvaliacaoDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddAvaliacaoDialog(
        onSave: (avaliacao) async {
          await ref.read(avaliacoesNotifierProvider.notifier).addAvaliacao(avaliacao);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Avaliação adicionada com sucesso!')),
            );
          }
        },
      ),
    );
  }

  void _showEditAvaliacaoDialog(BuildContext context, WidgetRef ref, AvaliacaoModel avaliacao) {
    showDialog(
      context: context,
      builder: (context) => AddAvaliacaoDialog(
        avaliacao: avaliacao,
        onSave: (updatedAvaliacao) async {
          await ref.read(avaliacoesNotifierProvider.notifier).updateAvaliacao(updatedAvaliacao);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Avaliação atualizada com sucesso!')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, AvaliacaoModel avaliacao) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir a avaliação "${avaliacao.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(avaliacoesNotifierProvider.notifier).deleteAvaliacao(avaliacao.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Avaliação excluída com sucesso!')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _navigateToAvaliacaoDetails(BuildContext context, AvaliacaoModel avaliacao) {
    
  }
}