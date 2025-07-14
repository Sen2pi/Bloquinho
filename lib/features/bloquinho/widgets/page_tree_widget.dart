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
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';

import '../models/page_model.dart';
import '../providers/pages_provider.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../shared/providers/workspace_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';

class PageTreeWidget extends ConsumerStatefulWidget {
  final void Function(String pageId)? onPageSelected;
  final String? pageRootId;
  const PageTreeWidget({super.key, this.onPageSelected, this.pageRootId});

  @override
  ConsumerState<PageTreeWidget> createState() => _PageTreeWidgetState();
}

class _PageTreeWidgetState extends ConsumerState<PageTreeWidget> {
  Set<String> _expandedPageIds = {}; // Múltiplas páginas expandidas
  String? _searchQuery;
  bool _showArchived = false;
  List<String> _detectedCycles = []; // Cache de ciclos detectados
  List<String> _cleanedPages = []; // Cache de páginas limpas

  @override
  void initState() {
    super.initState();
    // Expandir automaticamente páginas que têm filhos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoExpandPages();
    });
  }

  void _autoExpandPages() {
    final currentProfile = ref.read(currentProfileProvider);
    final currentWorkspace = ref.read(currentWorkspaceProvider);

    List<PageModel> pages = [];
    if (currentProfile != null && currentWorkspace != null) {
      pages = ref.read(pagesProvider((
        profileName: currentProfile.name,
        workspaceName: currentWorkspace.name
      )));
    }
    final pagesWithChildren = pages
        .where((page) => pages.any((p) => p.parentId == page.id))
        .map((page) => page.id)
        .toSet();

    setState(() {
      _expandedPageIds.addAll(pagesWithChildren);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentProfile = ref.watch(currentProfileProvider);
    final currentWorkspace = ref.watch(currentWorkspaceProvider);
    var pages = ref.watch(currentPagesProvider);
    String? currentPageId;
    final isDarkMode = ref.watch(isDarkModeProvider);

    // Verificar se há ciclos na estrutura de páginas (apenas uma vez por build)
    if (pages.isNotEmpty) {
      final pagesWithCycles = _detectCycles(pages);
      if (pagesWithCycles.isNotEmpty && pagesWithCycles != _detectedCycles) {
        _detectedCycles = pagesWithCycles;
        // Filtrar páginas com ciclos para evitar recursão infinita
        final safePages =
            pages.where((p) => !pagesWithCycles.contains(p.id)).toList();
        if (safePages.isNotEmpty) {
          pages = safePages;
        }
      }

      // Limpar dados corrompidos - páginas que apontam para si mesmas (apenas uma vez)
      final cleanPages = pages.where((p) => p.parentId != p.id).toList();
      if (cleanPages.length != pages.length && cleanPages != _cleanedPages) {
        _cleanedPages = cleanPages.map((p) => p.id).toList();
        pages = cleanPages;
      }
    }

    // Verificar se há páginas antes de tentar encontrar a root
    if (pages.isEmpty) {
      return Container(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        child: Center(
          child: Text(
            'Nenhuma página encontrada',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      );
    }

    // Encontrar todas as páginas raiz (parentId == null ou isRoot)
    final rootPages =
        pages.where((p) => p.isRoot || p.parentId == null).toList();
    if (rootPages.isEmpty) {
      // Se não há páginas raiz, usar a primeira página como raiz
      rootPages.add(pages.first);
    }

    return Container(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 6), // Reduzido de 8
        itemCount: rootPages.length,
        itemBuilder: (context, index) {
          final rootPage = rootPages[index];
          return _buildPageItem(
            page: rootPage,
            allPages: pages,
            currentPageId: currentPageId,
            isDarkMode: isDarkMode,
            depth: 0,
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.bookOpen(),
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Páginas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _showCreatePageDialog,
            icon: Icon(PhosphorIcons.plus(), size: 16),
            tooltip: 'Nova página',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Buscar páginas...',
          prefixIcon: Icon(PhosphorIcons.magnifyingGlass(), size: 18),
          suffixIcon: _searchQuery?.isNotEmpty == true
              ? IconButton(
                  onPressed: () => setState(() => _searchQuery = null),
                  icon: Icon(PhosphorIcons.x(), size: 16),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
      ),
    );
  }

  Widget _buildPagesTree(
      List<PageModel> pages, String? currentPageId, bool isDarkMode) {
    final filteredPages = _getFilteredPages(pages);
    final rootPages = filteredPages.where((page) => page.isRoot).toList();

    if (rootPages.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: rootPages.length,
      itemBuilder: (context, index) {
        final page = rootPages[index];
        return _buildPageItem(
          page: page,
          allPages: filteredPages,
          currentPageId: currentPageId,
          isDarkMode: isDarkMode,
          depth: 0,
        );
      },
    );
  }

  Widget _buildPageItem({
    required PageModel page,
    required List<PageModel> allPages,
    required String? currentPageId,
    required bool isDarkMode,
    required int depth,
  }) {
    // Proteção contra recursão infinita
    if (depth > 50) {
      return const SizedBox.shrink();
    }

    // Proteção contra auto-referência
    if (page.parentId == page.id) {
      return const SizedBox.shrink();
    }

    final isSelected = currentPageId == page.id;
    final isExpanded = _expandedPageIds.contains(page.id);
    final children = allPages
        .where((p) => p.parentId == page.id && p.id != page.id)
        .toList();
    final hasChildren = children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page item
        Container(
          margin: EdgeInsets.only(
            left: 8.0 + depth * 16.0, // Reduzido de 12.0 + depth * 18.0
            top: 1, // Reduzido de 2
            bottom: 1, // Reduzido de 2
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4), // Reduzido de 6
            color: isSelected
                ? AppColors.primary.withOpacity(0.13)
                : Colors.transparent,
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 1)
                : null,
          ),
          child: ListTile(
            dense: true,
            minLeadingWidth: 0,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 3, // Reduzido de 4
              vertical: 0,
            ),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Expand/collapse button
                if (hasChildren)
                  IconButton(
                    onPressed: () => _toggleExpanded(page.id),
                    icon: Icon(
                      isExpanded
                          ? PhosphorIcons.caretDown()
                          : PhosphorIcons.caretRight(),
                      size: 14, // Reduzido de 16 para 14
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20, // Reduzido de 24 para 20
                      minHeight: 20, // Reduzido de 24 para 20
                    ),
                  )
                else
                  const SizedBox(width: 20), // Reduzido de 24 para 20

                // Emoji do usuário
                Text(
                  page.icon ?? '📄',
                  style:
                      const TextStyle(fontSize: 14), // Reduzido de 18 para 14
                ),
              ],
            ),
            title: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _selectPage(page.id),
                child: Text(
                  page.title,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13, // Reduzido de 15 para 13
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            trailing: _buildPageActions(page, isDarkMode),
            onTap: () => _selectPage(page.id),
            onLongPress: () => _showPageContextMenu(page),
          ),
        ),

        // Children
        if (hasChildren && isExpanded)
          ...children.map((child) => _buildPageItem(
                page: child,
                allPages: allPages,
                currentPageId: currentPageId,
                isDarkMode: isDarkMode,
                depth: depth + 1,
              )),
      ],
    );
  }

  Widget _buildPageActions(PageModel page, bool isDarkMode) {
    return PopupMenuButton<String>(
      onSelected: (action) => _handlePageAction(action, page),
      icon: Icon(
        PhosphorIcons.dotsThreeVertical(),
        size: 12, // Reduzido de 14 para 12
        color: Colors.grey[400],
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(PhosphorIcons.pencil(), size: 14), // Reduzido de 16 para 14
              const SizedBox(width: 8),
              const Text('Editar'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'add_child',
          child: Row(
            children: [
              Icon(PhosphorIcons.plus(), size: 14), // Reduzido de 16 para 14
              const SizedBox(width: 8),
              const Text('Adicionar subpágina'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'move',
          child: Row(
            children: [
              Icon(PhosphorIcons.arrowsOut(),
                  size: 14), // Reduzido de 16 para 14
              const SizedBox(width: 8),
              const Text('Mover'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(PhosphorIcons.trash(),
                  size: 14, color: Colors.red), // Reduzido de 16 para 14
              const SizedBox(width: 8),
              const Text('Excluir', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.bookOpen(),
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma página encontrada',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie sua primeira página',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showCreatePageDialog,
            icon: Icon(PhosphorIcons.plus(), size: 16),
            label: const Text('Nova página'),
          ),
        ],
      ),
    );
  }

  // Helper methods

  List<PageModel> _getFilteredPages(List<PageModel> pages) {
    var filtered = pages;

    // Filter by search query
    if (_searchQuery?.isNotEmpty == true) {
      final query = _searchQuery!.toLowerCase();
      filtered = filtered.where((page) {
        return page.title.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  Icon _getPageIcon(PageModel page) {
    // Usa o emoji definido pelo usuário ou um emoji padrão
    return Icon(
      null,
      size: 0, // Não exibe o ícone do pacote
    );
  }

  Color _getPageColor(PageModel page) {
    if (page.isBloquinhoRoot) return AppColors.primary;
    if (page.isRoot) return Colors.green;
    return Colors.grey[600]!;
  }

  void _toggleExpanded(String pageId) {
    setState(() {
      if (_expandedPageIds.contains(pageId)) {
        _expandedPageIds.remove(pageId);
      } else {
        _expandedPageIds.add(pageId);
      }
    });
  }

  void _selectPage(String pageId) {
    if (widget.onPageSelected != null) {
      widget.onPageSelected!(pageId);
    }
    setState(() {});
  }

  void _showPageContextMenu(PageModel page) {
    // TODO: Implementar menu contextual
  }

  void _handlePageAction(String action, PageModel page) {
    switch (action) {
      case 'edit':
        _showEditPageDialog(page);
        break;
      case 'add_child':
        _showCreatePageDialog(parentId: page.id);
        break;
      case 'move':
        _showMovePageDialog(page);
        break;
      case 'delete':
        _showDeletePageDialog(page);
        break;
    }
  }

  void _showCreatePageDialog({String? parentId}) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Página'),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Título',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                final currentProfile = ref.read(currentProfileProvider);
                final currentWorkspace = ref.read(currentWorkspaceProvider);
                final notifier = ref.read(pagesProvider((
                  profileName: currentProfile?.name,
                  workspaceName: currentWorkspace?.name
                )).notifier);
                notifier.createPage(title: title, parentId: parentId);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showEditPageDialog(PageModel page) {
    final titleController = TextEditingController(text: page.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Página'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Título',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                final currentProfile = ref.read(currentProfileProvider);
                final currentWorkspace = ref.read(currentWorkspaceProvider);
                final notifier = ref.read(pagesProvider((
                  profileName: currentProfile?.name,
                  workspaceName: currentWorkspace?.name
                )).notifier);
                notifier.updatePage(page.id, title: title);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showMovePageDialog(PageModel page) {
    // TODO: Implementar diálogo de mover página
  }

  void _showDeletePageDialog(PageModel page) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Página'),
        content: Text(
          'Tem certeza que deseja excluir "${page.title}"? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final currentProfile = ref.read(currentProfileProvider);
              final currentWorkspace = ref.read(currentWorkspaceProvider);
              final notifier = ref.read(pagesProvider((
                profileName: currentProfile?.name,
                workspaceName: currentWorkspace?.name
              )).notifier);
              notifier.removePage(page.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  /// Detecta ciclos na estrutura de páginas
  List<String> _detectCycles(List<PageModel> pages) {
    final visited = <String>{};
    final recursionStack = <String>{};
    final cycles = <String>[];

    for (final page in pages) {
      if (!visited.contains(page.id)) {
        if (_hasCycle(page.id, pages, visited, recursionStack, cycles)) {
          cycles.add(page.id);
        }
      }
    }

    return cycles;
  }

  bool _hasCycle(String pageId, List<PageModel> pages, Set<String> visited,
      Set<String> recursionStack, List<String> cycles) {
    visited.add(pageId);
    recursionStack.add(pageId);

    final page = pages.firstWhere((p) => p.id == pageId);
    final children = pages.where((p) => p.parentId == pageId && p.id != pageId);

    for (final child in children) {
      if (!visited.contains(child.id)) {
        if (_hasCycle(child.id, pages, visited, recursionStack, cycles)) {
          return true;
        }
      } else if (recursionStack.contains(child.id)) {
        cycles.add(child.id);
        return true;
      }
    }

    recursionStack.remove(pageId);
    return false;
  }
}

ProviderListenable<List<PageModel>> _pagesProviderForContext(WidgetRef ref) {
  final currentProfile = ref.watch(currentProfileProvider);
  final currentWorkspace = ref.watch(currentWorkspaceProvider);
  return pagesProvider((
    profileName: currentProfile?.name,
    workspaceName: currentWorkspace?.name
  )) as ProviderListenable<List<PageModel>>;
}
