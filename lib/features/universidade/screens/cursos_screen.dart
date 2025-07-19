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
import '../models/curso_model.dart';
import '../models/tipo_curso_enum.dart';
import '../widgets/add_curso_dialog.dart';
import '../widgets/curso_card.dart';

class CursosScreen extends ConsumerWidget {
  const CursosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cursosAsync = ref.watch(cursosProvider);
    final searchQuery = ref.watch(cursoSearchQueryProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildSearchAndFilters(context, ref),
          Expanded(
            child: cursosAsync.when(
              data: (cursos) {
                final filteredCursos = _filterCursos(cursos, searchQuery);
                
                if (filteredCursos.isEmpty) {
                  return _buildEmptyState(context);
                }
                
                return _buildCursosList(context, ref, filteredCursos);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erro ao carregar cursos: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(cursosProvider),
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
        onPressed: () => _showAddCursoDialog(context, ref),
        tooltip: 'Adicionar Curso',
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
              hintText: 'Buscar cursos...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              ref.read(cursoSearchQueryProvider.notifier).state = value;
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, 'Todos', true, () {}),
                const SizedBox(width: 8),
                ...TipoCurso.values.map((tipo) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _buildFilterChip(context, tipo.displayName, false, () {}),
                )),
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
            Icons.book,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum curso encontrado',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione seu primeiro curso para começar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCursosList(BuildContext context, WidgetRef ref, List<CursoModel> cursos) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: cursos.length,
      itemBuilder: (context, index) {
        final curso = cursos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: CursoCard(
            curso: curso,
            onTap: () => _navigateToCursoDetails(context, curso),
            onEdit: () => _showEditCursoDialog(context, ref, curso),
            onDelete: () => _showDeleteConfirmation(context, ref, curso),
          ),
        );
      },
    );
  }

  List<CursoModel> _filterCursos(List<CursoModel> cursos, String query) {
    if (query.isEmpty) return cursos;
    
    final lowercaseQuery = query.toLowerCase();
    return cursos.where((curso) {
      return curso.nome.toLowerCase().contains(lowercaseQuery) ||
             (curso.codigo?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             curso.tipo.displayName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  void _showAddCursoDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddCursoDialog(
        onSave: (curso) async {
          await ref.read(cursosNotifierProvider.notifier).addCurso(curso);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Curso adicionado com sucesso!')),
            );
          }
        },
      ),
    );
  }

  void _showEditCursoDialog(BuildContext context, WidgetRef ref, CursoModel curso) {
    showDialog(
      context: context,
      builder: (context) => AddCursoDialog(
        curso: curso,
        onSave: (updatedCurso) async {
          await ref.read(cursosNotifierProvider.notifier).updateCurso(updatedCurso);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Curso atualizado com sucesso!')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, CursoModel curso) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir o curso "${curso.nome}"?\n\nEsta ação também excluirá todas as unidades curriculares associadas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(cursosNotifierProvider.notifier).deleteCurso(curso.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Curso excluído com sucesso!')),
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

  void _navigateToCursoDetails(BuildContext context, CursoModel curso) {
    
  }
}