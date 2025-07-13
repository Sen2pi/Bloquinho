import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'dart:async';

import '../models/page_model.dart';
import '../models/bloquinho_slash_command.dart';
import '../providers/pages_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../screens/bloco_editor_screen.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../shared/providers/workspace_provider.dart';
import 'bloquinho_slash_menu.dart';
import 'bloquinho_format_menu.dart';
import 'enhanced_markdown_preview_widget.dart';

class PageContentWidget extends ConsumerStatefulWidget {
  final String pageId;
  final bool isEditing;

  const PageContentWidget({
    super.key,
    required this.pageId,
    this.isEditing = false,
  });

  @override
  ConsumerState<PageContentWidget> createState() => _PageContentWidgetState();
}

class _PageContentWidgetState extends ConsumerState<PageContentWidget> {
  late TextEditingController _textController;
  Timer? _autoSaveTimer;
  bool _isSaving = false;
  bool _editing = false;
  OverlayEntry? _slashMenuOverlay;
  OverlayEntry? _formatMenuOverlay;
  final FocusNode _editorFocusNode = FocusNode();
  int _slashPosition = -1;
  String _slashQuery = '';
  bool _slashMenuLocked = false;
  TextSelection? _selectedText;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _editing = widget.isEditing;
    _loadContentFromFile();
    _editorFocusNode.addListener(_onFocusChange);

    // Adicionar listener para detectar seleção de texto
    _textController.addListener(_onTextSelectionChanged);
  }

  Future<void> _loadContentFromFile() async {
    // Busca o método do editor principal para carregar o conteúdo
    final state = context.findAncestorStateOfType<BlocoEditorScreenState>();
    if (state != null) {
      final content = await state.loadPageContent(widget.pageId);
      setState(() {
        _textController.text =
            content.isNotEmpty ? content : getPageContent(widget.pageId);
      });
    }
  }

  @override
  void didUpdateWidget(covariant PageContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageId != widget.pageId) {
      _textController.text = getPageContent(widget.pageId);
      // _editing NÃO deve ser alterado aqui!
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _autoSaveTimer?.cancel();
    _editorFocusNode.dispose();
    _removeSlashMenu();
    _removeFormatMenu(); // Limpar o menu de formatação
    super.dispose();
  }

  void _onFocusChange() {
    if (!_editorFocusNode.hasFocus && _slashMenuOverlay == null) {
      _removeSlashMenu();
    } else if (!_editorFocusNode.hasFocus) {
      // Não remover o menu se ele estiver ativo
    }
  }

  void _onTextChanged(String text) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      _autoSaveContent(text);
    });
    _detectSlashCommand();
  }

  void _onTextSelectionChanged() {
    final selection = _textController.selection;
    if (selection.isCollapsed) {
      // Sem seleção, remover menu de formatação
      _removeFormatMenu();
      _selectedText = null;
    } else {
      // Há seleção de texto, mostrar menu de formatação
      _selectedText = selection;
      _showFormatMenu();
    }
  }

  void _autoSaveContent(String content) async {
    setState(() {
      _isSaving = true;
    });
    updatePageContent(widget.pageId, content);
    // Salvar em arquivo .md
    final state = context.findAncestorStateOfType<BlocoEditorScreenState>();
    if (state != null) {
      await state.savePageContent(widget.pageId, content);
    }
    setState(() {
      _isSaving = false;
      // NÃO alterar _editing aqui - manter no modo edição
    });
  }

  void _detectSlashCommand() {
    final cursor = _textController.selection.baseOffset;
    if (cursor > 0 && _textController.text[cursor - 1] == '/') {
      _slashPosition = cursor - 1;
      _slashQuery = '';
      _showSlashMenu();
    } else if (_slashPosition != -1) {
      final textAfterSlash =
          _textController.text.substring(_slashPosition + 1, cursor);
      if (textAfterSlash.contains(' ')) {
        _removeSlashMenu();
      } else {
        _slashQuery = textAfterSlash;
        _updateSlashMenu();
      }
    } else if (_slashMenuOverlay != null) {
      _removeSlashMenu();
    }
  }

  void _showSlashMenu() {
    _removeSlashMenu(force: true); // força remoção anterior
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    _slashMenuLocked = false;
    _slashMenuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx + 40,
        top: offset.dy + 80,
        child: Material(
          color: Colors.transparent,
          child: BloquinhoSlashMenu(
            searchQuery: _slashQuery,
            onCommandSelected: (command) {
              _slashMenuLocked = true;
              _insertSlashCommand(command);
            },
            onDismiss: () {
              _removeSlashMenu();
            },
          ),
        ),
      ),
    );
    overlay.insert(_slashMenuOverlay!);
  }

  void _updateSlashMenu() {
    if (_slashMenuOverlay != null) {
      _slashMenuOverlay!.markNeedsBuild();
    }
  }

  void _removeSlashMenu({bool force = false}) {
    if (_slashMenuOverlay != null) {
      if (_slashMenuLocked && !force) {
        return;
      }
      _slashMenuOverlay!.remove();
      _slashMenuOverlay = null;
    }
    _slashPosition = -1;
    _slashQuery = '';
    _slashMenuLocked = false;
    // Garantir que o foco volte para o editor
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_editorFocusNode.canRequestFocus && !_editorFocusNode.hasFocus) {
        _editorFocusNode.requestFocus();
      }
    });
  }

  void _insertSlashCommand(BloquinhoSlashCommand command) {
    final text = _textController.text;
    final cursor = _textController.selection.baseOffset;
    final slashPos = _slashPosition >= 0 ? _slashPosition : cursor - 1;
    final before = text.substring(0, slashPos);
    final after = text.substring(cursor);
    final newText = before + command.markdownTemplate + after;
    _textController.text = newText;
    final newCursorPosition = slashPos + command.markdownTemplate.length;
    _textController.selection =
        TextSelection.collapsed(offset: newCursorPosition);
    _removeSlashMenu(force: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_editorFocusNode.canRequestFocus) {
        _editorFocusNode.requestFocus();
      }
    });
  }

  void _showFormatMenu() {
    if (_selectedText == null) return;

    _removeFormatMenu();
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    _formatMenuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx + 40,
        top: offset.dy + 80,
        child: Material(
          color: Colors.transparent,
          child: BloquinhoFormatMenu(
            onFormatApplied: _applyTextFormat,
            onDismiss: _removeFormatMenu,
          ),
        ),
      ),
    );
    overlay.insert(_formatMenuOverlay!);
  }

  void _removeFormatMenu() {
    if (_formatMenuOverlay != null) {
      _formatMenuOverlay!.remove();
      _formatMenuOverlay = null;
    }
  }

  void _applyTextFormat(String formatType,
      {String? color, String? backgroundColor, String? alignment}) {
    if (_selectedText == null) return;

    final text = _textController.text;
    final start = _selectedText!.start;
    final end = _selectedText!.end;
    final selectedText = text.substring(start, end);

    String formattedText = selectedText;

    switch (formatType) {
      case 'bold':
        formattedText = '**$selectedText**';
        break;
      case 'italic':
        formattedText = '*$selectedText*';
        break;
      case 'strikethrough':
        formattedText = '~~$selectedText~~';
        break;
      case 'code':
        formattedText = '`$selectedText`';
        break;
      case 'underline':
        formattedText = '<u>$selectedText</u>';
        break;
      case 'highlight':
        formattedText = '==$selectedText==';
        break;
      case 'subscript':
        formattedText = '<sub>$selectedText</sub>';
        break;
      case 'superscript':
        formattedText = '<sup>$selectedText</sup>';
        break;
      case 'textColor':
        if (color != null) {
          formattedText = '<color value="$color">$selectedText</color>';
        }
        break;
      case 'backgroundColor':
        if (backgroundColor != null) {
          formattedText = '<bg color="$backgroundColor">$selectedText</bg>';
        }
        break;
      case 'alignment':
        if (alignment != null) {
          formattedText = '<align value="$alignment">$selectedText</align>';
        }
        break;
      default:
        return; // Não aplicar formatação desconhecida
    }

    final newText =
        text.substring(0, start) + formattedText + text.substring(end);
    _textController.text = newText;

    // Manter a seleção do texto formatado
    final newSelection = TextSelection(
      baseOffset: start,
      extentOffset: start + formattedText.length,
    );
    _textController.selection = newSelection;

    _removeFormatMenu();
  }

  void _saveContent(String content) async {
    setState(() {
      _isSaving = true;
    });
    updatePageContent(widget.pageId, content);
    // Salvar em arquivo .md
    final state = context.findAncestorStateOfType<BlocoEditorScreenState>();
    if (state != null) {
      await state.savePageContent(widget.pageId, content);
    }
    setState(() {
      _isSaving = false;
      _editing = false; // Só sai do modo edição quando clicar no botão salvar
    });
  }

  String getPageContent(String pageId) {
    final currentProfile = ref.read(currentProfileProvider);
    final currentWorkspace = ref.read(currentWorkspaceProvider);

    List<PageModel> pages = [];
    if (currentProfile != null && currentWorkspace != null) {
      pages = ref.read(pagesProvider((
        profileName: currentProfile.name,
        workspaceName: currentWorkspace.name
      )));
    }
    final page = pages.firstWhere(
      (p) => p.id == pageId,
      orElse: () => PageModel.create(title: 'Página não encontrada'),
    );
    return page.content;
  }

  void updatePageContent(String pageId, String content) {
    final currentProfile = ref.read(currentProfileProvider);
    final currentWorkspace = ref.read(currentWorkspaceProvider);

    if (currentProfile != null && currentWorkspace != null) {
      final pagesNotifier = ref.read(pagesNotifierProvider((
        profileName: currentProfile.name,
        workspaceName: currentWorkspace.name
      )));
      pagesNotifier.updatePageContent(pageId, content);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentProfile = ref.watch(currentProfileProvider);
    final currentWorkspace = ref.watch(currentWorkspaceProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    PageModel page;
    if (currentProfile != null && currentWorkspace != null) {
      final pages = ref.watch(pagesProvider((
        profileName: currentProfile.name,
        workspaceName: currentWorkspace.name
      )));
      page = pages.firstWhere(
        (p) => p.id == widget.pageId,
        orElse: () => PageModel.create(title: 'Página não encontrada'),
      );
    } else {
      page = PageModel.create(title: 'Página não encontrada');
    }

    return Column(
      children: [
        // Header com controles
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
            border: Border(
              bottom: BorderSide(
                color:
                    isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Botão de editar/salvar
              IconButton(
                icon: Icon(_editing
                    ? PhosphorIcons.floppyDisk()
                    : PhosphorIcons.pencil()),
                tooltip: _editing ? 'Salvar' : 'Editar',
                onPressed: () {
                  if (_editing) {
                    _saveContent(_textController.text);
                  } else {
                    setState(() {
                      _editing = true;
                    });
                  }
                },
              ),

              const SizedBox(width: 8),

              // Título da página
              Expanded(
                child: Text(
                  page.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Status de salvamento
              if (_isSaving)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Salvando...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.checkCircle(),
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Salvo',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Conteúdo
        Expanded(
          child:
              _editing ? _buildEditor(isDarkMode) : _buildPreview(isDarkMode),
        ),
      ],
    );
  }

  Widget _buildEditor(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _textController,
        focusNode: _editorFocusNode,
        onChanged: _onTextChanged,
        onTap: () {
          // Garantir foco ao tocar no editor
          if (!_editorFocusNode.hasFocus) {
            _editorFocusNode.requestFocus();
          }
        },
        maxLines: null,
        expands: true,
        style: TextStyle(
          fontSize: 16,
          height: 1.6,
          color: isDarkMode
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          fontFamily: 'monospace',
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Digite / para ver comandos disponíveis...',
          hintStyle: TextStyle(
            color: isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(bool isDarkMode) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 1400, // Muito mais larga - tipo folha A3
        ),
        child: EnhancedMarkdownPreviewWidget(
          markdown: _textController.text,
          enableHtmlEnhancements: true,
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          padding: const EdgeInsets.all(32),
          baseTextStyle: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: isDarkMode
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}

// Custom builder para tabelas com links de página
class _PageTableBuilder extends MarkdownElementBuilder {
  final void Function(String pageId) onPageLinkTap;
  _PageTableBuilder({required this.onPageLinkTap});

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // Parsing real da tabela markdown
    final rows = <TableRow>[];
    final headerCells = <String>[];
    int? pageColIdx;

    // Cabeçalho
    final header = element.children?.firstWhere(
        (e) => e is md.Element && e.tag == 'thead',
        orElse: () => md.Element.empty('')) as md.Element?;
    if (header != null && header.tag == 'thead') {
      final headerRow = header.children?.firstWhere(
          (e) => e is md.Element && e.tag == 'tr',
          orElse: () => md.Element.empty('')) as md.Element?;
      if (headerRow != null && headerRow.tag == 'tr') {
        for (final cell in headerRow.children ?? []) {
          if (cell is md.Element && cell.tag == 'th') {
            final text = cell.textContent.trim();
            headerCells.add(text);
          }
        }
        // Identifica coluna de página
        pageColIdx = headerCells.indexWhere((h) =>
            h.toLowerCase() == 'pagina' ||
            h.toLowerCase() == 'page' ||
            h.toLowerCase() == 'página');
      }
      rows.add(TableRow(
        children: headerCells
            .map((h) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(h,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ))
            .toList(),
      ));
    }

    // Corpo
    final body = element.children?.firstWhere(
        (e) => e is md.Element && e.tag == 'tbody',
        orElse: () => md.Element.empty('')) as md.Element?;
    if (body != null && body.tag == 'tbody') {
      for (final row in body.children ?? []) {
        if (row is md.Element && row.tag == 'tr') {
          final cells = <Widget>[];
          int colIdx = 0;
          for (final cell in row.children ?? []) {
            if (cell is md.Element && (cell.tag == 'td' || cell.tag == 'th')) {
              final text = cell.textContent.trim();
              // Se for coluna de página e for link markdown
              if (colIdx == pageColIdx && text.contains('](')) {
                final match = RegExp(r'\[(.*?)\]\((.*?)\)').firstMatch(text);
                if (match != null) {
                  final label = match.group(1)!;
                  final pageId = match.group(2)!;
                  cells.add(GestureDetector(
                    onTap: () => onPageLinkTap(pageId),
                    child: Text(label,
                        style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline)),
                  ));
                } else {
                  cells.add(Text(text));
                }
              } else {
                cells.add(Text(text));
              }
              colIdx++;
            }
          }
          rows.add(TableRow(children: cells));
        }
      }
    }

    return Table(
      border: TableBorder.all(color: Colors.grey[300]!),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows,
    );
  }
}
