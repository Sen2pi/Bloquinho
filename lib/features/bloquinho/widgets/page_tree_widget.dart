import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';

import '../models/page_model.dart';
import '../providers/pages_provider.dart';
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

  @override
  void initState() {
    super.initState();
    // Expandir automaticamente páginas que têm filhos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoExpandPages();
    });
  }

  void _autoExpandPages() {
    final pages = ref.read(pagesProvider);
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
    final pages = ref.watch(pagesProvider);
    String? currentPageId;
    final isDarkMode = ref.watch(isDarkModeProvider);

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

    // Encontrar a página root (Bloquinho) com verificações de segurança
    PageModel? rootPage;
    try {
      if (widget.pageRootId != null) {
        rootPage = pages.firstWhere(
          (p) => p.id == widget.pageRootId,
          orElse: () => pages.firstWhere(
            (p) => p.isRoot,
            orElse: () => pages.first,
          ),
        );
      } else {
        rootPage = pages.firstWhere(
          (p) => p.isRoot,
          orElse: () => pages.first,
        );
      }
    } catch (e) {
      // Fallback: usar a primeira página disponível
      rootPage = pages.first;
    }

    return Container(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: _buildPageItem(
        page: rootPage,
        allPages: pages,
        currentPageId: currentPageId,
        isDarkMode: isDarkMode,
        depth: 0,
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
    final isSelected = currentPageId == page.id;
    final isExpanded = _expandedPageIds.contains(page.id);
    final children = allPages.where((p) => p.parentId == page.id).toList();
    final hasChildren = children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page item
        Container(
          margin: EdgeInsets.only(
            left: 12.0 + depth * 18.0, // recuo maior para subníveis
            top: 2,
            bottom: 2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
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
              horizontal: 4,
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
                      size: 16,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  )
                else
                  const SizedBox(width: 24),

                // Emoji do usuário
                Text(
                  page.icon ?? '📄',
                  style: const TextStyle(fontSize: 18),
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
                    fontSize: 15,
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
                ref.read(pagesProvider.notifier).createPage(
                      title: title,
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
                ref.read(pagesProvider.notifier).updatePage(
                      page.id,
                      title: title,
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
