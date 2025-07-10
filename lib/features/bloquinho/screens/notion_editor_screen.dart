import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../widgets/notion_block_editor.dart';
import '../providers/notion_page_provider.dart';
import '../services/notion_page_service.dart';
import '../models/notion_block.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/theme_provider.dart';

/// Tela principal do editor similar ao Notion
class NotionEditorScreen extends ConsumerStatefulWidget {
  final String pageId;

  const NotionEditorScreen({
    super.key,
    required this.pageId,
  });

  @override
  ConsumerState<NotionEditorScreen> createState() => _NotionEditorScreenState();
}

class _NotionEditorScreenState extends ConsumerState<NotionEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  Timer? _saveTimer;
  bool _isEditing = false;
  bool _hasUnsavedChanges = false;
  String? _selectedEmoji;

  @override
  void initState() {
    super.initState();
    // Usar Future para evitar modificar provider durante build
    Future(() => _loadPage());
    _titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    _saveTimer?.cancel();
    super.dispose();
  }

  void _loadPage() async {
    await ref.read(notionPageProvider.notifier).getPage(widget.pageId);
    _updateUI();
  }

  void _updateUI() {
    final currentPage = ref.read(currentNotionPageProvider);
    if (currentPage != null && mounted) {
      _titleController.text = currentPage.title;
      _selectedEmoji = currentPage.emoji;
      setState(() {});
    }
  }

  void _onTitleChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
    _debounceSave();
  }

  void _debounceSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), _saveChanges);
  }

  void _saveChanges() async {
    final currentPage = ref.read(currentNotionPageProvider);
    if (currentPage != null && _hasUnsavedChanges) {
      final updatedPage = currentPage.copyWith(
        title: _titleController.text.isNotEmpty
            ? _titleController.text
            : 'Sem título',
        emoji: _selectedEmoji ?? currentPage.emoji,
      );

      await ref.read(notionPageProvider.notifier).updatePage(updatedPage);

      if (mounted) {
        setState(() => _hasUnsavedChanges = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final currentPage = ref.watch(currentNotionPageProvider);
    final isLoading = ref.watch(isNotionPageLoadingProvider);
    final error = ref.watch(notionPageErrorProvider);

    if (isLoading && currentPage == null) {
      return Scaffold(
        backgroundColor:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: _buildAppBar(isDarkMode),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.warning(),
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar página',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadPage,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (currentPage == null) {
      return Scaffold(
        backgroundColor:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: _buildAppBar(isDarkMode),
        body: const Center(
          child: Text('Página não encontrada'),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: _buildAppBar(isDarkMode),
      body: _buildBody(isDarkMode, currentPage),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          PhosphorIcons.arrowLeft(),
          color: isDarkMode
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
      ),
      title: Row(
        children: [
          // Status de salvamento
          _buildSaveStatus(isDarkMode),
          const Spacer(),

          // Ações da página
          _buildPageActions(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildSaveStatus(bool isDarkMode) {
    if (_hasUnsavedChanges) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Salvando...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          PhosphorIcons.check(),
          size: 16,
          color: Colors.green,
        ),
        const SizedBox(width: 4),
        Text(
          'Salvo',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.green,
              ),
        ),
      ],
    );
  }

  Widget _buildPageActions(bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Favoritar
        IconButton(
          onPressed: () => _toggleFavorite(),
          icon: Icon(
            ref.watch(currentNotionPageProvider)?.isFavorite == true
                ? PhosphorIcons.star(PhosphorIconsStyle.fill)
                : PhosphorIcons.star(),
            color: ref.watch(currentNotionPageProvider)?.isFavorite == true
                ? Colors.amber
                : (isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          ),
        ),

        // Menu de opções
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          icon: Icon(
            PhosphorIcons.dotsThreeVertical(),
            color: isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'duplicate',
              child: ListTile(
                leading: Icon(PhosphorIcons.copy()),
                title: const Text('Duplicar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'move',
              child: ListTile(
                leading: Icon(PhosphorIcons.arrowsOutCardinal()),
                title: const Text('Mover para...'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(PhosphorIcons.export()),
                title: const Text('Exportar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(PhosphorIcons.trash(), color: Colors.red),
                title:
                    const Text('Deletar', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(bool isDarkMode, NotionPage page) {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header da página
            _buildPageHeader(isDarkMode, page),

            // Editor de blocos
            _buildBlockEditor(isDarkMode, page),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(bool isDarkMode, NotionPage page) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          _buildBreadcrumb(isDarkMode, page),

          const SizedBox(height: 24),

          // Emoji e título
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji
              GestureDetector(
                onTap: _showEmojiPicker,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selectedEmoji ?? page.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Título
              Expanded(
                child: TextField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                  decoration: InputDecoration(
                    hintText: 'Sem título',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: isDarkMode
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  maxLines: null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Metadados da página
          _buildPageMetadata(isDarkMode, page),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb(bool isDarkMode, NotionPage page) {
    // TODO: Implementar breadcrumb baseado na hierarquia
    return Row(
      children: [
        Icon(
          PhosphorIcons.house(),
          size: 16,
          color: isDarkMode
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          'Bloquinho',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
        ),
        if (page.parentId != null) ...[
          Icon(
            PhosphorIcons.caretRight(),
            size: 12,
            color: isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          Text(
            page.title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildPageMetadata(bool isDarkMode, NotionPage page) {
    return Wrap(
      spacing: 16,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.clock(),
              size: 14,
              color: isDarkMode
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              'Editado em ${_formatDate(page.updatedAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
            ),
          ],
        ),
        if (page.hasChildren) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIcons.tree(),
                size: 14,
                color: isDarkMode
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                '${page.childrenIds.length} subpáginas',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDarkMode
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBlockEditor(bool isDarkMode, NotionPage page) {
    return Container(
      constraints: const BoxConstraints(minHeight: 400),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: NotionBlockEditor(
        blocks: page.blocks,
        onBlocksChanged: _onBlocksChanged,
        isDarkMode: isDarkMode,
      ),
    );
  }

  void _onBlocksChanged(List<NotionBlock> blocks) {
    // Salvar blocos com debounce
    _hasUnsavedChanges = true;
    setState(() {});

    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), () async {
      await ref.read(notionPageProvider.notifier).updatePageBlocks(
            widget.pageId,
            blocks,
          );

      if (mounted) {
        setState(() => _hasUnsavedChanges = false);
      }
    });
  }

  void _toggleFavorite() {
    ref.read(notionPageProvider.notifier).toggleFavorite(widget.pageId);
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'duplicate':
        _duplicatePage();
        break;
      case 'move':
        _showMoveDialog();
        break;
      case 'export':
        _exportPage();
        break;
      case 'delete':
        _showDeleteDialog();
        break;
    }
  }

  void _duplicatePage() async {
    final duplicatedPage = await ref
        .read(notionPageProvider.notifier)
        .duplicatePage(widget.pageId);

    if (duplicatedPage != null && mounted) {
      context.pushReplacementNamed('notion_editor', pathParameters: {
        'pageId': duplicatedPage.id,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Página duplicada com sucesso')),
      );
    }
  }

  void _showMoveDialog() {
    // TODO: Implementar dialog para mover página
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _exportPage() {
    // TODO: Implementar exportação da página
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar página'),
        content: const Text(
          'Tem certeza que deseja deletar esta página? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deletePage();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }

  void _deletePage() async {
    await ref.read(notionPageProvider.notifier).deletePage(widget.pageId);

    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Página deletada')),
      );
    }
  }

  void _showEmojiPicker() {
    // Lista de emojis populares
    const emojis = [
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher emoji'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: emojis.length,
            itemBuilder: (context, index) {
              final emoji = emojis[index];
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedEmoji = emoji);
                  _hasUnsavedChanges = true;
                  _debounceSave();
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _selectedEmoji == emoji
                        ? AppColors.primary.withOpacity(0.1)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'hoje';
    } else if (difference.inDays == 1) {
      return 'ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
