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
import '../models/universidade_model.dart';
import '../widgets/add_universidade_dialog.dart';
import '../widgets/universidade_card.dart';

class UniversidadesScreen extends ConsumerWidget {
  const UniversidadesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final universidadesAsync = ref.watch(universidadesProvider);
    final searchQuery = ref.watch(universidadeSearchQueryProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(context, ref),
          Expanded(
            child: universidadesAsync.when(
              data: (universidades) {
                final filteredUniversidades = _filterUniversidades(universidades, searchQuery);
                
                if (filteredUniversidades.isEmpty) {
                  return _buildEmptyState(context);
                }
                
                return _buildUniversidadesList(context, ref, filteredUniversidades);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erro ao carregar universidades: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(universidadesProvider),
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
        onPressed: () => _showAddUniversidadeDialog(context, ref),
        tooltip: 'Adicionar Universidade',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Buscar universidades...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          ref.read(universidadeSearchQueryProvider.notifier).state = value;
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma universidade encontrada',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione sua primeira universidade para começar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUniversidadesList(BuildContext context, WidgetRef ref, List<UniversidadeModel> universidades) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: universidades.length,
      itemBuilder: (context, index) {
        final universidade = universidades[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: UniversidadeCard(
            universidade: universidade,
            onTap: () => _navigateToUniversidadeDetails(context, universidade),
            onEdit: () => _showEditUniversidadeDialog(context, ref, universidade),
            onDelete: () => _showDeleteConfirmation(context, ref, universidade),
          ),
        );
      },
    );
  }

  List<UniversidadeModel> _filterUniversidades(List<UniversidadeModel> universidades, String query) {
    if (query.isEmpty) return universidades;
    
    final lowercaseQuery = query.toLowerCase();
    return universidades.where((universidade) {
      return universidade.nome.toLowerCase().contains(lowercaseQuery) ||
             (universidade.sigla?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (universidade.cidade?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (universidade.pais?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  void _showAddUniversidadeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddUniversidadeDialog(
        onSave: (universidade) async {
          await ref.read(universidadesNotifierProvider.notifier).addUniversidade(universidade);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Universidade adicionada com sucesso!')),
            );
          }
        },
      ),
    );
  }

  void _showEditUniversidadeDialog(BuildContext context, WidgetRef ref, UniversidadeModel universidade) {
    showDialog(
      context: context,
      builder: (context) => AddUniversidadeDialog(
        universidade: universidade,
        onSave: (updatedUniversidade) async {
          await ref.read(universidadesNotifierProvider.notifier).updateUniversidade(updatedUniversidade);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Universidade atualizada com sucesso!')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, UniversidadeModel universidade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir a universidade "${universidade.nome}"?\n\nEsta ação também excluirá todos os cursos associados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(universidadesNotifierProvider.notifier).deleteUniversidade(universidade.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Universidade excluída com sucesso!')),
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

  void _navigateToUniversidadeDetails(BuildContext context, UniversidadeModel universidade) {
    
  }
}