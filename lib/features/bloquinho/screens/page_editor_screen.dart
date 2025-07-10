import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/page_models.dart';
import '../providers/page_provider.dart';
import '../widgets/page_link_widget.dart';
import '../widgets/markdown_preview_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';

/// Tela principal do editor de páginas
class PageEditorScreen extends ConsumerStatefulWidget {
  final String pageId;

  const PageEditorScreen({
    super.key,
    required this.pageId,
  });

  @override
  ConsumerState<PageEditorScreen> createState() => _PageEditorScreenState();
}

class _PageEditorScreenState extends ConsumerState<PageEditorScreen> {
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _editorFocusNode = FocusNode();

  // Estados
  BloqPage? _currentPage;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  Timer? _saveTimer;
  bool _showPreview = false; // Toggle para mostrar/ocultar preview

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _editorFocusNode.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadPage() async {
    setState(() => _isLoading = true);

    try {
      // Buscar a página pelo ID nos pages carregados
      final pages = ref.read(currentPagesProvider);
      final page = pages.firstWhere(
        (p) => p.id == widget.pageId,
        orElse: () => throw Exception('Página não encontrada'),
      );

      setState(() {
        _currentPage = page;
        _titleController.text = page.title;

        // Converter blocos para texto simples
        final content = _convertBlocksToText(page.blocks);
        _contentController.text = content;

        // Listeners para detectar mudanças
        _titleController.addListener(_onTitleChanged);
        _contentController.addListener(_onContentChanged);
      });
    } catch (e) {
      _showError('Erro ao carregar página: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _convertBlocksToText(List<PageBlock> blocks) {
    if (blocks.isEmpty) return '';

    return blocks.map((block) {
      switch (block.type) {
        case PageBlockType.heading1:
          return '# ${block.content}';
        case PageBlockType.heading2:
          return '## ${block.content}';
        case PageBlockType.heading3:
          return '### ${block.content}';
        case PageBlockType.quote:
          return '> ${block.content}';
        case PageBlockType.bulletList:
          return '• ${block.content}';
        case PageBlockType.numberedList:
          return '1. ${block.content}';
        case PageBlockType.code:
          return '```\n${block.content}\n```';
        case PageBlockType.divider:
          return '---';
        case PageBlockType.pageLink:
          final pageId = block.properties['pageId'] ?? '';
          return '[[${block.content}|$pageId]]';
        default:
          return block.content;
      }
    }).join('\n\n');
  }

  List<PageBlock> _convertTextToBlocks(String text) {
    final blocks = <PageBlock>[];
    final lines = text.split('\n');

    int index = 0;
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      // Detectar links de páginas [[titulo|pageId]]
      final pageLinkRegex = RegExp(r'\[\[([^\|]+)\|([^\]]+)\]\]');
      final pageLinkMatch = pageLinkRegex.firstMatch(trimmedLine);

      if (pageLinkMatch != null) {
        final pageTitle = pageLinkMatch.group(1)!;
        final pageId = pageLinkMatch.group(2)!;

        blocks.add(PageBlock.create(
          type: PageBlockType.pageLink,
          content: pageTitle,
          properties: {'pageId': pageId},
          orderIndex: index,
          parentBlockId: _currentPage?.id,
        ));
        index++;
        continue;
      }

      PageBlockType type = PageBlockType.text;
      String content = trimmedLine;

      // Detectar markdown simples
      if (trimmedLine.startsWith('# ')) {
        type = PageBlockType.heading1;
        content = trimmedLine.substring(2).trim();
      } else if (trimmedLine.startsWith('## ')) {
        type = PageBlockType.heading2;
        content = trimmedLine.substring(3).trim();
      } else if (trimmedLine.startsWith('### ')) {
        type = PageBlockType.heading3;
        content = trimmedLine.substring(4).trim();
      } else if (trimmedLine.startsWith('> ')) {
        type = PageBlockType.quote;
        content = trimmedLine.substring(2).trim();
      } else if (trimmedLine.startsWith('• ')) {
        type = PageBlockType.bulletList;
        content = trimmedLine.substring(2).trim();
      } else if (trimmedLine.startsWith('1. ')) {
        type = PageBlockType.numberedList;
        content = trimmedLine.substring(3).trim();
      } else if (trimmedLine.startsWith('```')) {
        type = PageBlockType.code;
        continue; // Skip code block markers
      } else if (trimmedLine == '---') {
        type = PageBlockType.divider;
        content = '';
      }

      blocks.add(PageBlock.create(
        type: type,
        content: content,
        orderIndex: index,
        parentBlockId: _currentPage?.id,
      ));

      index++;
    }

    return blocks.isEmpty
        ? [PageBlock.create(type: PageBlockType.text)]
        : blocks;
  }

  void _onContentChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
    _scheduleAutoSave();
  }

  void _onTitleChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), () {
      if (_hasUnsavedChanges && !_isSaving) {
        _savePage();
      }
    });
  }

  Future<void> _savePage() async {
    if (_currentPage == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      // Converter texto de volta para blocos
      final blocks = _convertTextToBlocks(_contentController.text);

      final updatedPage = _currentPage!.copyWith(
        title: _titleController.text.trim().isEmpty
            ? 'Sem título'
            : _titleController.text.trim(),
        blocks: blocks,
      );

      await ref.read(pageProvider.notifier).updatePage(updatedPage);

      setState(() {
        _hasUnsavedChanges = false;
        _currentPage = updatedPage;
      });

      _showSaveSuccess();
    } catch (e) {
      _showError('Erro ao salvar página: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showUnsavedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterações não salvas'),
        content: const Text(
          'Você tem alterações não salvas. Deseja salvar antes de sair?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Descartar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _savePage();
              if (mounted) context.pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'save':
        _savePage();
        break;
      case 'export':
        _exportPage();
        break;
      case 'properties':
        _showPropertiesDialog();
        break;
      case 'delete':
        _showDeleteDialog();
        break;
    }
  }

  void _exportPage() {
    if (_currentPage == null) return;

    final content = _convertBlocksToText(_currentPage!.blocks);
    _showError('Exportação: ${content.length} caracteres');
    // TODO: Implementar exportação real para arquivo
  }

  void _showPropertiesDialog() {
    // TODO: Implementar diálogo de propriedades
    _showError('Propriedades em desenvolvimento');
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir página'),
        content: Text(
          'Tem certeza que deseja excluir "${_currentPage?.title}"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(pageProvider.notifier).deletePage(widget.pageId);
              if (mounted) context.pop();
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

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showSaveSuccess() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIcons.check(), color: Colors.white),
              const SizedBox(width: 8),
              const Text('Página salva com sucesso'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _insertMarkdown(String markdown) {
    final text = _contentController.text;
    final selection = _contentController.selection;

    if (selection.isValid) {
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        markdown,
      );

      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + markdown.length,
        ),
      );
    } else {
      _contentController.text = text + markdown;
      _contentController.selection = TextSelection.collapsed(
        offset: _contentController.text.length,
      );
    }

    _editorFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _hasUnsavedChanges) {
          _showUnsavedDialog();
        }
      },
      child: Scaffold(
        backgroundColor: isDarkMode
            ? AppColors.blockBackgroundDark
            : AppColors.blockBackground,
        appBar: _buildAppBar(strings, isDarkMode),
        body: _isLoading ? _buildLoadingState() : _buildEditor(isDarkMode),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppStrings strings, bool isDarkMode) {
    return AppBar(
      backgroundColor: isDarkMode
          ? AppColors.sidebarBackgroundDark
          : AppColors.sidebarBackground,
      elevation: 0,
      leading: IconButton(
        icon: Icon(PhosphorIcons.arrowLeft()),
        onPressed:
            _hasUnsavedChanges ? _showUnsavedDialog : () => context.pop(),
      ),
      title: Row(
        children: [
          if (_currentPage?.emoji.isNotEmpty == true) ...[
            Text(
              _currentPage!.emoji,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: _titleController,
              style: Theme.of(context).textTheme.titleLarge,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Sem título',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
      actions: [
        if (_isSaving) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ] else if (_hasUnsavedChanges) ...[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PhosphorIcons.clockCounterClockwise(),
                  size: 14,
                  color: Colors.orange,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Não salvo',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'save',
              child: ListTile(
                leading: Icon(PhosphorIcons.floppyDisk()),
                title: const Text('Salvar'),
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
              value: 'properties',
              child: ListTile(
                leading: Icon(PhosphorIcons.gear()),
                title: const Text('Propriedades'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(PhosphorIcons.trash(), color: Colors.red),
                title:
                    const Text('Excluir', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Carregando página...'),
        ],
      ),
    );
  }

  Widget _buildEditor(bool isDarkMode) {
    return Column(
      children: [
        // Toolbar melhorada com preview toggle
        Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.sidebarBackgroundDark
                : AppColors.sidebarBackground,
            border: Border(
              bottom: BorderSide(
                color:
                    isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Controles de formatação
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildToolbarButton(
                            '# H1', () => _insertMarkdown('# ')),
                        _buildToolbarButton(
                            '## H2', () => _insertMarkdown('## ')),
                        _buildToolbarButton(
                            '### H3', () => _insertMarkdown('### ')),
                        const SizedBox(width: 16),
                        _buildToolbarButton(
                            '**B**', () => _insertMarkdown('**texto**')),
                        _buildToolbarButton(
                            '*I*', () => _insertMarkdown('*texto*')),
                        const SizedBox(width: 16),
                        _buildToolbarButton(
                            '• Lista', () => _insertMarkdown('• ')),
                        _buildToolbarButton(
                            '1. Núm.', () => _insertMarkdown('1. ')),
                        _buildToolbarButton(
                            '> Quote', () => _insertMarkdown('> ')),
                        const SizedBox(width: 16),
                        _buildToolbarButton(
                            '```Code', () => _insertMarkdown('```\n\n```')),
                        _buildToolbarButton(
                            '---', () => _insertMarkdown('---')),
                        const SizedBox(width: 16),
                        _buildToolbarButton(
                            '🔗 Link', () => _showPageLinkDialog()),
                      ],
                    ),
                  ),
                ),

                // Toggle de preview
                Container(
                  margin: const EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      Text(
                        'Preview',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: _showPreview,
                        onChanged: (value) {
                          setState(() {
                            _showPreview = value;
                          });
                        },
                        activeColor: AppColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Editor principal com preview
        Expanded(
          child: _showPreview
              ? Row(
                  children: [
                    // Editor
                    Expanded(
                      child: _buildTextEditor(isDarkMode),
                    ),

                    // Divisor
                    Container(
                      width: 1,
                      color: isDarkMode
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),

                    // Preview
                    Expanded(
                      child: Container(
                        height: double.infinity,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: MarkdownPreviewWidget(
                            markdown: _contentController.text,
                            isDarkMode: isDarkMode,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : _buildTextEditor(isDarkMode),
        ),
      ],
    );
  }

  Widget _buildTextEditor(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _contentController,
        focusNode: _editorFocusNode,
        maxLines: null,
        expands: true,
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: isDarkMode
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          fontFamily: 'monospace',
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: '''Comece a escrever sua página...

Dicas de formatação:
# Título 1
## Título 2
### Título 3
**negrito** *itálico*
• Lista com marcadores
1. Lista numerada
> Citação em bloco
```
Bloco de código
```
--- (divisor)
[[nome-da-pagina|id]] (link interno)''',
          hintStyle: TextStyle(
            color: (isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary)
                .withOpacity(0.6),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showPageLinkDialog() {
    showDialog(
      context: context,
      builder: (context) => PageLinkSelectorDialog(
        onPageSelected: (pageId) {
          // Buscar a página para obter o título
          final pages = ref.read(currentPagesProvider);
          final page = pages.firstWhere(
            (p) => p.id == pageId,
            orElse: () => BloqPage.create(
              title: 'Página',
              workspaceId: 'default',
            ),
          );

          // Inserir link no formato [[titulo-da-pagina|pageId]]
          final linkMarkdown = '[[${page.title}|$pageId]]';
          _insertMarkdown(linkMarkdown);
        },
      ),
    );
  }

  Widget _buildToolbarButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
