import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';

import '../models/page_model.dart';
import '../providers/pages_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';

class PageTreeWidget extends ConsumerStatefulWidget {
  const PageTreeWidget({super.key});

  @override
  ConsumerState<PageTreeWidget> createState() => _PageTreeWidgetState();
}

class _PageTreeWidgetState extends ConsumerState<PageTreeWidget> {
  String? _expandedPageId;
  String? _searchQuery;
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final pages = ref.watch(pagesProvider);
    final currentPageId = ref.watch(currentPageProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Container(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(isDarkMode),

          // Search bar
          _buildSearchBar(isDarkMode),

          // Pages tree
          _buildPagesTree(pages, currentPageId, isDarkMode),
        ],
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
    final rootPages = filteredPages.where((page) => page.isRoot).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    if (rootPages.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
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
    final isSelected = currentPageId == page.id;
    final isExpanded = _expandedPageId == page.id;
    final children = allPages.where((p) => p.parentId == page.id).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    final hasChildren = children.isNotEmpty;

    return Column(
      children: [
        // Page item
        Container(
          margin: EdgeInsets.only(
            left: depth * 16.0,
            top: 2,
            bottom: 2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 1)
                : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
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
                      size: 16,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  )
                else
                  const SizedBox(width: 24),

                // Page icon
                Icon(
                  _getPageIcon(page),
                  size: 16,
                  color: _getPageColor(page),
                ),
              ],
            ),
            title: Text(
              page.title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: page.isArchived ? Colors.grey : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: page.content?.isNotEmpty == true
                ? Text(
                    page.content!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Archive indicator
        if (page.isArchived)
          Icon(
            PhosphorIcons.archive(),
            size: 14,
            color: Colors.grey,
          ),

        // More actions
        PopupMenuButton<String>(
          onSelected: (action) => _handlePageAction(action, page),
          icon: Icon(
            PhosphorIcons.dotsThreeVertical(),
            size: 14,
            color: Colors.grey[400],
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(PhosphorIcons.pencil(), size: 16),
                  const SizedBox(width: 8),
                  const Text('Editar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'add_child',
              child: Row(
                children: [
                  Icon(PhosphorIcons.plus(), size: 16),
                  const SizedBox(width: 8),
                  const Text('Adicionar subpágina'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'move',
              child: Row(
                children: [
                  Icon(PhosphorIcons.arrowsOut(), size: 16),
                  const SizedBox(width: 8),
                  const Text('Mover'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'archive',
              child: Row(
                children: [
                  Icon(
                    page.isArchived
                        ? PhosphorIcons.folderOpen()
                        : PhosphorIcons.archive(),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(page.isArchived ? 'Desarquivar' : 'Arquivar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(PhosphorIcons.trash(), size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
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
        return page.title.toLowerCase().contains(query) ||
            (page.content?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filter archived pages
    if (!_showArchived) {
      filtered = filtered.where((page) => !page.isArchived).toList();
    }

    return filtered;
  }

  IconData _getPageIcon(PageModel page) {
    if (page.isBloquinhoRoot) return PhosphorIcons.bookOpen();
    if (page.isRoot) return PhosphorIcons.fileText();
    return PhosphorIcons.file();
  }

  Color _getPageColor(PageModel page) {
    if (page.isBloquinhoRoot) return AppColors.primary;
    if (page.isRoot) return Colors.green;
    return Colors.grey[600]!;
  }

  void _toggleExpanded(String pageId) {
    setState(() {
      if (_expandedPageId == pageId) {
        _expandedPageId = null;
      } else {
        _expandedPageId = pageId;
      }
    });
  }

  void _selectPage(String pageId) {
    ref.read(currentPageProvider.notifier).state = pageId;
    // TODO: Navegar para a página
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
      case 'archive':
        ref.read(pagesProvider.notifier).toggleArchive(page.id);
        break;
      case 'delete':
        _showDeletePageDialog(page);
        break;
    }
  }

  void _showCreatePageDialog({String? parentId}) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Página'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Conteúdo (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
                ref.read(pagesProvider.notifier).addPage(
                      title: title,
                      content: contentController.text.trim(),
                      parentId: parentId,
                    );
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
    final contentController = TextEditingController(text: page.content ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Página'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Conteúdo',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
                ref.read(pagesProvider.notifier).updatePage(
                      page.id,
                      title: title,
                      content: contentController.text.trim(),
                    );
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
              ref.read(pagesProvider.notifier).removePage(page.id);
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
}
