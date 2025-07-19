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
import '../models/universidade_page_model.dart';
import '../providers/universidade_provider.dart';
import '../widgets/add_page_dialog.dart';

class UniversidadePageTreeWidget extends ConsumerWidget {
  final TipoContextoPage? filtroTipo;
  final String? contextoId;

  const UniversidadePageTreeWidget({
    super.key,
    this.filtroTipo,
    this.contextoId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagesAsync = ref.watch(universidadePagesProvider);

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
                  'Páginas e Documentos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddPageDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Nova Página'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: pagesAsync.when(
                data: (pages) {
                  final filteredPages = _filterPages(pages);
                  final rootPages = filteredPages.where((p) => p.isRoot).toList();
                  
                  if (rootPages.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  
                  return ListView.builder(
                    itemCount: rootPages.length,
                    itemBuilder: (context, index) {
                      return _buildPageNode(context, ref, rootPages[index], filteredPages, 0);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Erro ao carregar páginas: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<UniversidadePageModel> _filterPages(List<UniversidadePageModel> pages) {
    if (filtroTipo == null && contextoId == null) return pages;
    
    return pages.where((page) {
      if (filtroTipo != null && page.tipoContexto != filtroTipo) return false;
      if (contextoId != null && page.contextoId != contextoId) return false;
      return true;
    }).toList();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma página encontrada',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Crie sua primeira página para começar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageNode(
    BuildContext context,
    WidgetRef ref,
    UniversidadePageModel page,
    List<UniversidadePageModel> allPages,
    int depth,
  ) {
    final children = allPages.where((p) => p.parentId == page.id).toList();
    final hasChildren = children.isNotEmpty;

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: depth * 20.0),
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasChildren)
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  )
                else
                  SizedBox(width: hasChildren ? 24 : 0),
                Icon(
                  page.icon != null ? IconData(int.parse(page.icon!), fontFamily: 'MaterialIcons') : Icons.description,
                  color: _getContextoColor(page.tipoContexto),
                ),
              ],
            ),
            title: Text(
              page.titulo,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: depth == 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(page.contextoNome),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'add_child':
                    _showAddPageDialog(context, ref, parentId: page.id);
                    break;
                  case 'edit':
                    _showEditPageDialog(context, ref, page);
                    break;
                  case 'delete':
                    _showDeleteConfirmation(context, ref, page);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'add_child',
                  child: Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text('Adicionar subpágina'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Excluir', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => _openPageEditor(context, page),
          ),
        ),
        ...children.map((child) => _buildPageNode(context, ref, child, allPages, depth + 1)),
      ],
    );
  }

  Color _getContextoColor(TipoContextoPage tipo) {
    switch (tipo) {
      case TipoContextoPage.universidade:
        return Colors.blue;
      case TipoContextoPage.curso:
        return Colors.green;
      case TipoContextoPage.unidadeCurricular:
        return Colors.orange;
      case TipoContextoPage.avaliacao:
        return Colors.purple;
      case TipoContextoPage.geral:
        return Colors.grey;
    }
  }

  void _showAddPageDialog(BuildContext context, WidgetRef ref, {String? parentId}) {
    showDialog(
      context: context,
      builder: (context) => AddPageDialog(
        parentId: parentId,
        tipoContexto: filtroTipo,
        contextoId: contextoId,
        onSave: (page) async {
          final service = ref.read(universidadeServiceProvider);
          await service.savePage(page);
          ref.invalidate(universidadePagesProvider);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Página criada com sucesso!')),
            );
          }
        },
      ),
    );
  }

  void _showEditPageDialog(BuildContext context, WidgetRef ref, UniversidadePageModel page) {
    showDialog(
      context: context,
      builder: (context) => AddPageDialog(
        page: page,
        onSave: (updatedPage) async {
          final service = ref.read(universidadeServiceProvider);
          await service.savePage(updatedPage);
          ref.invalidate(universidadePagesProvider);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Página atualizada com sucesso!')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, UniversidadePageModel page) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir a página "${page.titulo}"?\n\nEsta ação também excluirá todas as subpáginas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final service = ref.read(universidadeServiceProvider);
              await service.deletePage(page.id);
              ref.invalidate(universidadePagesProvider);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Página excluída com sucesso!')),
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

  void _openPageEditor(BuildContext context, UniversidadePageModel page) {
    
  }
}