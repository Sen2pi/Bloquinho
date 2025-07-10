import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/notion_page_provider.dart';
import '../services/notion_page_service.dart';
import '../../../shared/providers/workspace_provider.dart';

/// Widget da árvore de páginas do sistema Notion-like
class NotionTreeWidget extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final bool isExpanded;
  final VoidCallback? onToggleExpansion;

  const NotionTreeWidget({
    super.key,
    required this.isDarkMode,
    this.isExpanded = false,
    this.onToggleExpansion,
  });

  @override
  ConsumerState<NotionTreeWidget> createState() => _NotionTreeWidgetState();
}

class _NotionTreeWidgetState extends ConsumerState<NotionTreeWidget> {
  final Set<String> _expandedPages = <String>{};
  final Set<String> _hoveredPages = <String>{};

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  void _loadPages() {
    final currentWorkspace = ref.read(currentWorkspaceProvider);
    if (currentWorkspace != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(notionPageProvider.notifier)
            .loadPagesForWorkspace(currentWorkspace.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = ref.watch(notionPagesListProvider);
    final isLoading = ref.watch(isNotionPageLoadingProvider);
    final error = ref.watch(notionPageErrorProvider);

    if (isLoading && pages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              PhosphorIcons.warning(),
              color: Colors.red,
              size: 20,
            ),
            const SizedBox(height: 8),
            Text(
              'Erro ao carregar páginas',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (pages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              PhosphorIcons.files(),
              color: widget.isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              'Nenhuma página ainda',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: widget.isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _showCreatePageDialog(context),
              icon: Icon(PhosphorIcons.plus(), size: 16),
              label: const Text('Criar primeira página'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }

    return _buildPageTree(pages);
  }

  Widget _buildPageTree(List<NotionPage> pages) {
    // Organizar páginas em hierarquia
    final rootPages = pages.where((page) => page.isRoot).toList();

    // Ordenar: Bloquinho primeiro, depois por data de criação
    rootPages.sort((a, b) {
      if (a.isBloquinhoRoot) return -1;
      if (b.isBloquinhoRoot) return 1;
      return a.createdAt.compareTo(b.createdAt);
    });

    return Column(
      children:
          rootPages.map((page) => _buildPageNode(page, pages, 0)).toList(),
    );
  }

  Widget _buildPageNode(NotionPage page, List<NotionPage> allPages, int level) {
    final isExpanded = _expandedPages.contains(page.id);
    final isHovered = _hoveredPages.contains(page.id);
    final hasChildren = page.hasChildren;
    final indentation = level * 12.0;

    // Obter páginas filhas
    final childPages = page.childrenIds
        .map((childId) => allPages.where((p) => p.id == childId).firstOrNull)
        .where((child) => child != null)
        .cast<NotionPage>()
        .toList();

    return Column(
      children: [
        // Nó da página
        MouseRegion(
          onEnter: (_) => setState(() => _hoveredPages.add(page.id)),
          onExit: (_) => setState(() => _hoveredPages.remove(page.id)),
          child: GestureDetector(
            onTap: () => _openPage(page),
            onSecondaryTap: () => _showContextMenu(page),
            child: Container(
              margin: EdgeInsets.only(left: indentation, bottom: 2),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: isHovered
                    ? (widget.isDarkMode
                        ? AppColors.sidebarItemHoverDark
                        : AppColors.sidebarItemHover)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  // Botão de expansão
                  if (hasChildren)
                    GestureDetector(
                      onTap: () => _toggleExpansion(page.id),
                      child: AnimatedRotation(
                        turns: isExpanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          PhosphorIcons.caretRight(),
                          size: 12,
                          color: widget.isDarkMode
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 12),

                  const SizedBox(width: 4),

                  // Emoji da página
                  Text(
                    page.emoji,
                    style: const TextStyle(fontSize: 14),
                  ),

                  const SizedBox(width: 8),

                  // Título da página
                  Expanded(
                    child: Text(
                      page.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: page.isBloquinhoRoot
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color:
                                page.isBloquinhoRoot ? AppColors.primary : null,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Indicadores
                  if (page.isFavorite) ...[
                    Icon(
                      PhosphorIcons.star(PhosphorIconsStyle.fill),
                      size: 12,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                  ],

                  if (hasChildren && isHovered) ...[
                    Text(
                      '${childPages.length}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: widget.isDarkMode
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                          ),
                    ),
                    const SizedBox(width: 4),
                  ],

                  // Menu de opções (aparece no hover)
                  if (isHovered && !page.isBloquinhoRoot)
                    GestureDetector(
                      onTap: () => _showContextMenu(page),
                      child: Icon(
                        PhosphorIcons.dotsThreeVertical(),
                        size: 12,
                        color: widget.isDarkMode
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Páginas filhas (se expandida)
        if (isExpanded && hasChildren)
          ...childPages
              .map((child) => _buildPageNode(child, allPages, level + 1)),
      ],
    );
  }

  void _toggleExpansion(String pageId) {
    setState(() {
      if (_expandedPages.contains(pageId)) {
        _expandedPages.remove(pageId);
      } else {
        _expandedPages.add(pageId);
      }
    });
  }

  void _openPage(NotionPage page) {
    context.pushNamed('notion_editor', pathParameters: {
      'pageId': page.id,
    });
  }

  void _showContextMenu(NotionPage page) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildContextMenu(page),
    );
  }

  Widget _buildContextMenu(NotionPage page) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabeçalho
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(page.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    page.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Opções do menu
          _buildMenuOption(
            icon: PhosphorIcons.plus(),
            title: 'Adicionar subpágina',
            onTap: () {
              Navigator.of(context).pop();
              _showCreatePageDialog(context, parentId: page.id);
            },
          ),

          _buildMenuOption(
            icon: page.isFavorite
                ? PhosphorIcons.star(PhosphorIconsStyle.fill)
                : PhosphorIcons.star(),
            title: page.isFavorite
                ? 'Remover dos favoritos'
                : 'Adicionar aos favoritos',
            onTap: () {
              Navigator.of(context).pop();
              ref.read(notionPageProvider.notifier).toggleFavorite(page.id);
            },
          ),

          _buildMenuOption(
            icon: PhosphorIcons.copy(),
            title: 'Duplicar',
            onTap: () {
              Navigator.of(context).pop();
              _duplicatePage(page);
            },
          ),

          _buildMenuOption(
            icon: PhosphorIcons.arrowsOutCardinal(),
            title: 'Mover',
            onTap: () {
              Navigator.of(context).pop();
              _showMoveDialog(page);
            },
          ),

          _buildMenuOption(
            icon: PhosphorIcons.export(),
            title: 'Exportar',
            onTap: () {
              Navigator.of(context).pop();
              _exportPage(page);
            },
          ),

          if (!page.isBloquinhoRoot) ...[
            const Divider(height: 1),
            _buildMenuOption(
              icon: PhosphorIcons.trash(),
              title: 'Deletar',
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteDialog(page);
              },
              isDestructive: true,
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 20,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  void _showCreatePageDialog(BuildContext context, {String? parentId}) {
    showDialog(
      context: context,
      builder: (context) => NotionCreatePageDialog(parentId: parentId),
    );
  }

  void _duplicatePage(NotionPage page) async {
    final duplicated =
        await ref.read(notionPageProvider.notifier).duplicatePage(page.id);

    if (duplicated != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Página "${page.title}" duplicada'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showMoveDialog(NotionPage page) {
    // TODO: Implementar dialog de mover página
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _exportPage(NotionPage page) {
    // TODO: Implementar exportação de página
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _showDeleteDialog(NotionPage page) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar página'),
        content: Text(
          'Tem certeza que deseja deletar "${page.title}"? '
          '${page.hasChildren ? 'Todas as subpáginas também serão deletadas. ' : ''}'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deletePage(page);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }

  void _deletePage(NotionPage page) async {
    await ref.read(notionPageProvider.notifier).deletePage(page.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Página "${page.title}" deletada'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Dialog para criar nova página no sistema Notion
class NotionCreatePageDialog extends ConsumerStatefulWidget {
  final String? parentId;

  const NotionCreatePageDialog({super.key, this.parentId});

  @override
  ConsumerState<NotionCreatePageDialog> createState() =>
      _NotionCreatePageDialogState();
}

class _NotionCreatePageDialogState
    extends ConsumerState<NotionCreatePageDialog> {
  final _titleController = TextEditingController();
  String _selectedEmoji = '📄';
  final _formKey = GlobalKey<FormState>();

  final List<String> _commonEmojis = [
    '📄',
    '📝',
    '📚',
    '📊',
    '📈',
    '📋',
    '🗂️',
    '📁',
    '💡',
    '🎯',
    '⭐',
    '🔥',
    '⚡',
    '🌟',
    '🚀',
    '💎',
    '🏠',
    '🎨',
    '🔧',
    '⚙️',
    '🎵',
    '📷',
    '🎮',
    '💻',
    '🔬',
    '📖',
    '✏️',
    '📌',
    '🎪',
    '🌍',
    '🎭',
    '❤️',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.parentId != null ? 'Nova Subpágina' : 'Nova Página'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seletor de emoji
            Text(
              'Ícone da página:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 120,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: _commonEmojis.length,
                itemBuilder: (context, index) {
                  final emoji = _commonEmojis[index];
                  final isSelected = emoji == _selectedEmoji;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : null,
                      ),
                      child: Center(
                        child:
                            Text(emoji, style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Campo de título
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título da página',
                border: OutlineInputBorder(),
                hintText: 'Digite o título...',
              ),
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, insira um título';
                }
                return null;
              },
              onFieldSubmitted: (_) => _createPage(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _createPage,
          child: const Text('Criar Página'),
        ),
      ],
    );
  }

  void _createPage() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final page = await ref.read(notionPageProvider.notifier).createPage(
            title: _titleController.text.trim(),
            emoji: _selectedEmoji,
            parentId: widget.parentId,
          );

      if (page != null && mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(_selectedEmoji),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Página "${page.title}" criada com sucesso'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar para a nova página
        context.pushNamed('notion_editor', pathParameters: {
          'pageId': page.id,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar página: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
