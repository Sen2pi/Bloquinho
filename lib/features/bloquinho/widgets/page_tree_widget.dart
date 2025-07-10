import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../models/page_models.dart';
import '../providers/page_provider.dart';

/// Widget para exibir uma árvore hierárquica de páginas
class PageTreeWidget extends ConsumerWidget {
  final bool isDarkMode;
  final bool isExpanded;
  final VoidCallback? onToggleExpansion;

  const PageTreeWidget({
    super.key,
    required this.isDarkMode,
    this.isExpanded = true,
    this.onToggleExpansion,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageTree = ref.watch(pageTreeProvider);
    final isLoading = ref.watch(isPageLoadingProvider);
    final pageCount = ref.watch(rootPagesCountProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Column(
        children: [
          // Header da seção
          _buildSectionHeader(context, ref, pageCount),

          // Lista de páginas
          if (isExpanded) ...[
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (pageTree.isEmpty)
              _buildEmptyState(context, ref)
            else
              ...pageTree.map((node) => _buildPageNode(context, ref, node)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, WidgetRef ref, int pageCount) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onToggleExpansion,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Ícone da imagem customizada
                Image.asset(
                  'notas.png',
                  width: 18,
                  height: 18,
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.note_outlined,
                      size: 18,
                      color: isDarkMode
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bloquinho',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                if (pageCount > 0) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$pageCount',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Ícone de expansão
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    PhosphorIcons.caretDown(),
                    size: 16,
                    color: isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.darkSurface.withOpacity(0.5)
                  : AppColors.lightSurface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  PhosphorIcons.notePencil(),
                  size: 32,
                  color: Colors.grey[500],
                ),
                const SizedBox(height: 12),
                Text(
                  'Nenhuma página ainda',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Crie sua primeira página',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showCreatePageDialog(context, ref),
                    icon: Icon(PhosphorIcons.plus(), size: 16),
                    label: const Text('Criar Página'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageNode(
      BuildContext context, WidgetRef ref, PageTreeNode node) {
    final page = node.page;
    final hasChildren = node.children.isNotEmpty;
    final isSelected = false; // TODO: Implementar seleção

    return Column(
      children: [
        // Container principal do item da página
        Container(
          margin: EdgeInsets.only(
            left: 4 + (node.level * 12.0), // Indentação mais refinada
            right: 4,
            top: 1,
            bottom: 1,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                _selectPage(ref, page);
                _navigateToPage(context, page);
              },
              onHover: (hovering) {
                // TODO: Implementar estado de hover
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isSelected
                      ? (isDarkMode
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.primary.withOpacity(0.1))
                      : null,
                ),
                child: Row(
                  children: [
                    // Indicador de hierarquia visual
                    if (node.level > 0) ...[
                      SizedBox(
                        width: 12,
                        height: 20,
                        child: CustomPaint(
                          painter: HierarchyLinePainter(
                            color: isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                    ],

                    // Botão de expansão/colapso
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: hasChildren
                          ? GestureDetector(
                              onTap: () => ref
                                  .read(pageProvider.notifier)
                                  .toggleNodeExpansion(page.id),
                              child: AnimatedRotation(
                                turns: node.isExpanded ? 0.25 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  PhosphorIcons.caretRight(),
                                  size: 12,
                                  color: isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                            )
                          : Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDarkMode
                                    ? Colors.grey.shade700.withOpacity(0.3)
                                    : Colors.grey.shade300.withOpacity(0.5),
                              ),
                            ),
                    ),
                    const SizedBox(width: 6),

                    // Emoji da página
                    Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      child: Text(
                        page.emoji,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Título da página
                    Expanded(
                      child: Text(
                        page.title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDarkMode
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary),
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Indicadores de estado
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Indicador de subpáginas
                        if (hasChildren && !node.isExpanded)
                          Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey.shade700.withOpacity(0.5)
                                  : Colors.grey.shade300.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${node.children.length}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        // Indicador de favorito
                        if (page.isFavorite)
                          Container(
                            margin: const EdgeInsets.only(right: 4),
                            child: Icon(
                              PhosphorIcons.star(PhosphorIconsStyle.fill),
                              size: 10,
                              color: Colors.amber.shade600,
                            ),
                          ),

                        // Menu de ações (aparece no hover)
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            PhosphorIcons.dotsThree(),
                            size: 12,
                            color: isDarkMode
                                ? Colors.grey.shade500
                                : Colors.grey.shade600,
                          ),
                          iconSize: 12,
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'addSubpage',
                              child: Row(
                                children: [
                                  Icon(PhosphorIcons.plus(), size: 14),
                                  const SizedBox(width: 8),
                                  const Text('Nova subpágina',
                                      style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem(
                              value: 'favorite',
                              child: Row(
                                children: [
                                  Icon(
                                    page.isFavorite
                                        ? PhosphorIcons.star(
                                            PhosphorIconsStyle.fill)
                                        : PhosphorIcons.star(),
                                    size: 14,
                                    color:
                                        page.isFavorite ? Colors.amber : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    page.isFavorite
                                        ? 'Remover favorito'
                                        : 'Favoritar',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'duplicate',
                              child: Row(
                                children: [
                                  Icon(PhosphorIcons.copy(), size: 14),
                                  const SizedBox(width: 8),
                                  const Text('Duplicar',
                                      style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'rename',
                              child: Row(
                                children: [
                                  Icon(PhosphorIcons.textT(), size: 14),
                                  const SizedBox(width: 8),
                                  const Text('Renomear',
                                      style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(PhosphorIcons.trash(),
                                      size: 14, color: Colors.red),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Deletar',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) =>
                              _handlePageAction(context, ref, page, value),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Renderizar páginas filhas se expandido
        if (hasChildren && node.isExpanded)
          ...node.children.map((child) => _buildPageNode(context, ref, child)),
      ],
    );
  }

  void _selectPage(WidgetRef ref, BloqPage page) {
    ref.read(pageProvider.notifier).setCurrentPage(page);
  }

  void _navigateToPage(BuildContext context, BloqPage page) {
    context.goNamed('page', pathParameters: {'id': page.id});
  }

  void _handlePageAction(
      BuildContext context, WidgetRef ref, BloqPage page, String action) {
    switch (action) {
      case 'addSubpage':
        _showCreatePageDialog(context, ref, parentId: page.id);
        break;
      case 'favorite':
        ref.read(pageProvider.notifier).toggleFavorite(page.id);
        break;
      case 'duplicate':
        _duplicatePage(ref, page);
        break;
      case 'rename':
        _showEditPageDialog(context, ref, page);
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, page);
        break;
    }
  }

  void _showCreatePageDialog(BuildContext context, WidgetRef ref,
      {String? parentId}) {
    showDialog(
      context: context,
      builder: (context) => CreatePageDialog(parentId: parentId),
    );
  }

  void _showEditPageDialog(BuildContext context, WidgetRef ref, BloqPage page) {
    showDialog(
      context: context,
      builder: (context) => EditPageDialog(page: page),
    );
  }

  void _duplicatePage(WidgetRef ref, BloqPage page) async {
    await ref.read(pageProvider.notifier).createPage(
          title: '${page.title} (cópia)',
          emoji: page.emoji,
          parentId: page.parentId,
          tags: page.tags,
        );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, BloqPage page) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar página'),
        content: Text(
            'Tem certeza que deseja deletar "${page.title}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(pageProvider.notifier).deletePage(page.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }
}

/// Dialog para criar nova página
class CreatePageDialog extends ConsumerStatefulWidget {
  final String? parentId;

  const CreatePageDialog({super.key, this.parentId});

  @override
  ConsumerState<CreatePageDialog> createState() => _CreatePageDialogState();
}

class _CreatePageDialogState extends ConsumerState<CreatePageDialog> {
  final _titleController = TextEditingController();
  String _selectedEmoji = '📄';

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
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.parentId != null ? 'Nova Subpágina' : 'Nova Página'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Seletor de emoji
          Row(
            children: [
              const Text('Ícone: '),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showEmojiPicker,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_selectedEmoji,
                      style: const TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Campo de título
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título da página',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _createPage,
          child: const Text('Criar'),
        ),
      ],
    );
  }

  void _showEmojiPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher ícone'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              childAspectRatio: 1,
            ),
            itemCount: _commonEmojis.length,
            itemBuilder: (context, index) {
              final emoji = _commonEmojis[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedEmoji = emoji;
                  });
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: _selectedEmoji == emoji
                        ? Border.all(
                            color: Theme.of(context).primaryColor, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _createPage() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um título')),
      );
      return;
    }

    final page = await ref.read(pageProvider.notifier).createPage(
          title: _titleController.text.trim(),
          emoji: _selectedEmoji,
          parentId: widget.parentId,
        );

    if (page != null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Página criada com sucesso')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

/// Dialog para editar página
class EditPageDialog extends ConsumerStatefulWidget {
  final BloqPage page;

  const EditPageDialog({super.key, required this.page});

  @override
  ConsumerState<EditPageDialog> createState() => _EditPageDialogState();
}

class _EditPageDialogState extends ConsumerState<EditPageDialog> {
  late TextEditingController _titleController;
  late String _selectedEmoji;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.page.title);
    _selectedEmoji = widget.page.emoji;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Página'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Seletor de emoji
          Row(
            children: [
              const Text('Ícone: '),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // Implementar seletor de emoji (similar ao CreatePageDialog)
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_selectedEmoji,
                      style: const TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Campo de título
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título da página',
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
          onPressed: _updatePage,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  void _updatePage() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um título')),
      );
      return;
    }

    final updatedPage = widget.page.copyWith(
      title: _titleController.text.trim(),
      emoji: _selectedEmoji,
    );

    await ref.read(pageProvider.notifier).updatePage(updatedPage);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Página atualizada com sucesso')),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

/// Painter para desenhar linhas hierárquicas na árvore de páginas
class HierarchyLinePainter extends CustomPainter {
  final Color color;

  HierarchyLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Linha vertical conectando ao nível anterior
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height / 2),
      paint,
    );

    // Linha horizontal conectando ao item
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
