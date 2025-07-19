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
import '../models/unidade_curricular_model.dart';
import '../widgets/add_unidade_curricular_dialog.dart';
import '../widgets/unidade_curricular_card.dart';

class UnidadesCurricularesScreen extends ConsumerWidget {
  const UnidadesCurricularesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unidadesAsync = ref.watch(unidadesCurricularesProvider);
    final searchQuery = ref.watch(unidadeSearchQueryProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildSearchAndFilters(context, ref),
          Expanded(
            child: unidadesAsync.when(
              data: (unidades) {
                final filteredUnidades = _filterUnidades(unidades, searchQuery);
                
                if (filteredUnidades.isEmpty) {
                  return _buildEmptyState(context);
                }
                
                return _buildUnidadesList(context, ref, filteredUnidades);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erro ao carregar disciplinas: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(unidadesCurricularesProvider),
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
        onPressed: () => _showAddUnidadeDialog(context, ref),
        tooltip: 'Adicionar Disciplina',
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
              hintText: 'Buscar disciplinas...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              ref.read(unidadeSearchQueryProvider.notifier).state = value;
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, 'Todas', true, () {}),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Ativas', false, () {}),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Aprovadas', false, () {}),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Reprovadas', false, () {}),
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
            Icons.subject,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma disciplina encontrada',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione sua primeira disciplina para começar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnidadesList(BuildContext context, WidgetRef ref, List<UnidadeCurricularModel> unidades) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: unidades.length,
      itemBuilder: (context, index) {
        final unidade = unidades[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: UnidadeCurricularCard(
            unidade: unidade,
            onTap: () => _navigateToUnidadeDetails(context, unidade),
            onEdit: () => _showEditUnidadeDialog(context, ref, unidade),
            onDelete: () => _showDeleteConfirmation(context, ref, unidade),
          ),
        );
      },
    );
  }

  List<UnidadeCurricularModel> _filterUnidades(List<UnidadeCurricularModel> unidades, String query) {
    if (query.isEmpty) return unidades;
    
    final lowercaseQuery = query.toLowerCase();
    return unidades.where((unidade) {
      return unidade.nome.toLowerCase().contains(lowercaseQuery) ||
             (unidade.codigo?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (unidade.professor?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  void _showAddUnidadeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddUnidadeCurricularDialog(
        onSave: (unidade) async {
          await ref.read(unidadesCurricularesNotifierProvider.notifier).addUnidade(unidade);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Disciplina adicionada com sucesso!')),
            );
          }
        },
      ),
    );
  }

  void _showEditUnidadeDialog(BuildContext context, WidgetRef ref, UnidadeCurricularModel unidade) {
    showDialog(
      context: context,
      builder: (context) => AddUnidadeCurricularDialog(
        unidade: unidade,
        onSave: (updatedUnidade) async {
          await ref.read(unidadesCurricularesNotifierProvider.notifier).updateUnidade(updatedUnidade);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Disciplina atualizada com sucesso!')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, UnidadeCurricularModel unidade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir a disciplina "${unidade.nome}"?\n\nEsta ação também excluirá todas as avaliações associadas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(unidadesCurricularesNotifierProvider.notifier).deleteUnidade(unidade.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Disciplina excluída com sucesso!')),
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

  void _navigateToUnidadeDetails(BuildContext context, UnidadeCurricularModel unidade) {
    
  }
}