import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/page_provider.dart';
import 'page_tree_widget.dart';

/// Widget para a seção Bloquinho na sidebar
class BloquinhoSectionWidget extends ConsumerWidget {
  final bool isDarkMode;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback? onTap;

  const BloquinhoSectionWidget({
    super.key,
    required this.isDarkMode,
    this.isSelected = false,
    this.isExpanded = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageCount = ref.watch(rootPagesCountProvider);
    final isLoading = ref.watch(isPageLoadingProvider);

    return Column(
      children: [
        // Header principal da seção
        Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected
                      ? (isDarkMode
                          ? AppColors.sidebarItemHoverDark
                          : AppColors.sidebarItemHover)
                      : null,
                ),
                child: Row(
                  children: [
                    // Ícone customizado
                    Image.asset(
                      'notas.png',
                      width: 18,
                      height: 18,
                      color: isSelected
                          ? AppColors.primary
                          : (isDarkMode
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.note_outlined,
                          size: 18,
                          color: isSelected
                              ? AppColors.primary
                              : (isDarkMode
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bloquinho',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isSelected ? AppColors.primary : null,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                      ),
                    ),

                    // Contador de páginas
                    if (pageCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
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

                    // Botão para adicionar nova página
                    GestureDetector(
                      onTap: () => _showCreatePageDialog(context, ref),
                      child: Icon(
                        PhosphorIcons.plus(),
                        size: 16,
                        color: isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),

                    const SizedBox(width: 4),

                    // Ícone de expansão
                    if (pageCount > 0) ...[
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
                  ],
                ),
              ),
            ),
          ),
        ),

        // Árvore de páginas (se expandida)
        if (isExpanded) ...[
          if (isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            PageTreeWidget(
              isDarkMode: isDarkMode,
              isExpanded: true,
              onToggleExpansion: null, // Já gerenciado pelo header principal
            ),
        ],
      ],
    );
  }

  void _showCreatePageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const CreatePageDialog(),
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
    '🎨',
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

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonEmojis.map((emoji) {
                final isSelected = emoji == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                );
              }).toList(),
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
      final page = await ref.read(pageProvider.notifier).createPage(
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
