import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/page_model.dart';
import '../providers/pages_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../shared/providers/workspace_provider.dart';
import '../../../core/theme/app_colors.dart';

class PageChildrenList extends ConsumerWidget {
  final String currentPageId;
  final Function(String) onNavigateToPage;
  final Function(String) onCreateSubPage;

  const PageChildrenList({
    super.key,
    required this.currentPageId,
    required this.onNavigateToPage,
    required this.onCreateSubPage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final currentProfile = ref.watch(currentProfileProvider);
    final currentWorkspace = ref.watch(currentWorkspaceProvider);

    List<PageModel> pages = [];
    if (currentProfile != null && currentWorkspace != null) {
      pages = ref.watch(pagesProvider((
        profileName: currentProfile.name,
        workspaceName: currentWorkspace.name
      )));
    }
    final currentPage = pages.firstWhere(
      (p) => p.id == currentPageId,
      orElse: () => PageModel.create(title: 'Página não encontrada'),
    );
    final children = pages.where((p) => p.parentId == currentPageId).toList();

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.folders(),
                size: 20,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(width: 8),
              Text(
                'Subpáginas (${children.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showCreateSubPageDialog(context, ref),
                icon: Icon(PhosphorIcons.plus()),
                tooltip: 'Criar subpágina',
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children
              .map((child) => _buildChildItem(context, child, isDarkMode)),
        ],
      ),
    );
  }

  Widget _buildChildItem(
      BuildContext context, PageModel child, bool isDarkMode) {
    return InkWell(
      onTap: () => onNavigateToPage(child.id),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.02),
        ),
        child: Row(
          children: [
            Icon(
              child.icon != null && child.icon!.startsWith('0x')
                  ? IconData(int.parse(child.icon!),
                      fontFamily: 'PhosphorIcons')
                  : PhosphorIcons.fileText(),
              size: 16,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                  ),
                  if (child.hasChildren)
                    Text(
                      '${child.childrenIds.length} subpágina(s)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDarkMode ? Colors.white54 : Colors.black45,
                          ),
                    ),
                ],
              ),
            ),
            Icon(
              PhosphorIcons.caretRight(),
              size: 16,
              color: isDarkMode ? Colors.white54 : Colors.black45,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSubPageDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    // Corrigir: usar ValueNotifier para garantir atualização do ícone
    final selectedIcon = ValueNotifier<String?>(null);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Subpágina'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título da subpágina',
                hintText: 'Digite o título...',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<String?>(
              valueListenable: selectedIcon,
              builder: (context, value, _) => _buildIconSelector(
                context,
                value,
                (icon) => selectedIcon.value = icon,
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
              if (titleController.text.trim().isNotEmpty) {
                final currentProfile = ref.read(currentProfileProvider);
                final currentWorkspace = ref.read(currentWorkspaceProvider);

                if (currentProfile != null && currentWorkspace != null) {
                  final pagesNotifier = ref.read(pagesNotifierProvider((
                    profileName: currentProfile.name,
                    workspaceName: currentWorkspace.name
                  )));
                  pagesNotifier.createPage(
                    title: titleController.text.trim(),
                    icon: selectedIcon.value,
                    parentId: currentPageId,
                  );
                }
                Navigator.of(context).pop();
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelector(BuildContext context, String? selectedIcon,
      Function(String?) onIconChanged) {
    final icons = [
      '📄',
      '📝',
      '📋',
      '📚',
      '📖',
      '📗',
      '📘',
      '📙',
      '📓',
      '📔',
      '📕',
      '📒',
      '📃',
      '📄',
      '📑',
      '🔖',
      '🏷️',
      '📌',
      '📍',
      '🎯',
      '💡',
      '💭',
      '💬',
      '💭',
      '💡',
      '🔍',
      '🔎',
      '📊',
      '📈',
      '📉',
      '📋',
      '✅',
      '❌',
      '⚠️',
      'ℹ️',
      '🔔',
      '🔕',
      '🔒',
      '🔓',
      '🔐',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escolher ícone (opcional)',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: icons.length,
            itemBuilder: (context, index) {
              final icon = icons[index];
              final isSelected = selectedIcon == icon;

              return GestureDetector(
                onTap: () => onIconChanged(isSelected ? null : icon),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
