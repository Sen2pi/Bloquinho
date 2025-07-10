import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/page_models.dart';
import '../providers/page_provider.dart';
import '../../../core/theme/app_colors.dart';

/// Widget que renderiza um link para uma página interna no estilo Notion
class PageLinkWidget extends ConsumerWidget {
  final String pageId;
  final bool isDarkMode;
  final VoidCallback? onTap;

  const PageLinkWidget({
    super.key,
    required this.pageId,
    this.isDarkMode = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = ref.watch(currentPagesProvider);
    final page = pages.firstWhere(
      (p) => p.id == pageId,
      orElse: () => BloqPage.create(
        title: 'Página não encontrada',
        emoji: '❓',
        workspaceId: 'default',
      ),
    );

    final bool pageExists = pages.any((p) => p.id == pageId);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap ?? () => _navigateToPage(context, pageId),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkMode
                  ? AppColors.darkBorder.withOpacity(0.3)
                  : AppColors.lightBorder.withOpacity(0.5),
              width: 1,
            ),
            color: pageExists
                ? (isDarkMode
                    ? AppColors.blockBackgroundDark
                    : AppColors.blockBackground)
                : (isDarkMode
                    ? Colors.red.withOpacity(0.1)
                    : Colors.red.withOpacity(0.05)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji/Ícone da página
              Text(
                page.emoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),

              // Título da página
              Flexible(
                child: Text(
                  page.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: pageExists
                            ? (isDarkMode
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary)
                            : (isDarkMode
                                ? Colors.red.shade300
                                : Colors.red.shade600),
                        decoration:
                            pageExists ? null : TextDecoration.lineThrough,
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 4),

              // Ícone de link externo
              Icon(
                PhosphorIcons.arrowSquareOut(),
                size: 14,
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, String pageId) {
    context.pushNamed('page', pathParameters: {'id': pageId});
  }
}

/// Widget inline para links de páginas dentro do texto
class InlinePageLinkWidget extends ConsumerWidget {
  final String pageId;
  final bool isDarkMode;

  const InlinePageLinkWidget({
    super.key,
    required this.pageId,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = ref.watch(currentPagesProvider);
    final page = pages.firstWhere(
      (p) => p.id == pageId,
      orElse: () => BloqPage.create(
        title: 'Página não encontrada',
        emoji: '❓',
        workspaceId: 'default',
      ),
    );

    final bool pageExists = pages.any((p) => p.id == pageId);

    return GestureDetector(
      onTap: () => _navigateToPage(context, pageId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: pageExists
              ? (isDarkMode
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1))
              : (isDarkMode
                  ? Colors.red.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1)),
          border: Border.all(
            color: pageExists
                ? AppColors.primary.withOpacity(0.3)
                : Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              page.emoji,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 4),
            Text(
              page.title,
              style: TextStyle(
                fontSize: 14,
                color: pageExists
                    ? AppColors.primary
                    : (isDarkMode ? Colors.red.shade300 : Colors.red.shade600),
                decoration: pageExists ? null : TextDecoration.lineThrough,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, String pageId) {
    context.pushNamed('page', pathParameters: {'id': pageId});
  }
}

/// Dialog para selecionar uma página para criar link
class PageLinkSelectorDialog extends ConsumerStatefulWidget {
  final Function(String pageId) onPageSelected;

  const PageLinkSelectorDialog({
    super.key,
    required this.onPageSelected,
  });

  @override
  ConsumerState<PageLinkSelectorDialog> createState() =>
      _PageLinkSelectorDialogState();
}

class _PageLinkSelectorDialogState
    extends ConsumerState<PageLinkSelectorDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<BloqPage> _filteredPages = [];

  @override
  void initState() {
    super.initState();
    _updateFilteredPages();
    _searchController.addListener(_updateFilteredPages);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilteredPages() {
    final pages = ref.read(currentPagesProvider);
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredPages = pages;
      } else {
        _filteredPages = pages
            .where((page) => page.title.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecionar página para link',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Campo de busca
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar páginas...',
                prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lista de páginas
            Expanded(
              child: ListView.builder(
                itemCount: _filteredPages.length,
                itemBuilder: (context, index) {
                  final page = _filteredPages[index];
                  return ListTile(
                    leading: Text(
                      page.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    title: Text(page.title),
                    subtitle: page.parentId != null ? Text('Subpágina') : null,
                    onTap: () {
                      widget.onPageSelected(page.id);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),

            // Botões
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
