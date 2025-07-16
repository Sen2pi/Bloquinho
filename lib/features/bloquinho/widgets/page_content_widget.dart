/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'dart:async';

import '../models/page_model.dart';
import '../models/bloquinho_slash_command.dart';
import '../providers/pages_provider.dart';
import '../providers/editor_controller_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../screens/bloco_editor_screen.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../shared/providers/workspace_provider.dart';
import 'bloquinho_slash_menu.dart';
import 'bloquinho_format_menu.dart';
import 'ai_generation_dialog.dart';
import 'enhanced_markdown_preview_widget.dart';
import 'colored_text_widget.dart';
import 'dynamic_colored_text.dart';

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
  bool _showLivePreview = true; // Novo: controla se mostra live preview
  OverlayEntry? _slashMenuOverlay;
  OverlayEntry? _formatMenuOverlay;
  final FocusNode _editorFocusNode = FocusNode();
  int _slashPosition = -1;
  String _slashQuery = '';
  bool _slashMenuLocked = false;
  TextSelection? _selectedText;
  String _pageContent = ''; // Adicionado para armazenar o conteúdo da página
  Timer? _updateProviderTimer; // Adicionado para debounce

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _editing = false; // Sempre em modo visualização por padrão
    _loadPageContent();
    _initializeEditorContent();
    _editorFocusNode.addListener(_onFocusChange);

    // Adicionar listener para detectar seleção de texto
    _textController.addListener(_onTextSelectionChanged);
  }

  void _initializeEditorContent() {
    // Inicializar o provider com o conteúdo da página para contagem imediata
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pageContent.isNotEmpty) {
        ref.read(editorControllerProvider.notifier).state = ref
            .read(editorControllerProvider.notifier)
            .state
            .copyWith(content: _pageContent);
      }
    });
  }

  Future<void> _loadPageContent() async {
    // Busca o método do editor principal para carregar o conteúdo
    final state = context.findAncestorStateOfType<BlocoEditorScreenState>();
    if (state != null) {
      final content = await state.loadPageContent(widget.pageId);
      final finalContent =
          content.isNotEmpty ? content : getPageContent(widget.pageId);
      setState(() {
        _pageContent = finalContent;
        _textController.text = finalContent;
      });
      // Inicializar provider após carregar o conteúdo
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(editorControllerProvider.notifier).state = ref
              .read(editorControllerProvider.notifier)
              .state
              .copyWith(content: finalContent);
        }
      });
    } else {
      final content = getPageContent(widget.pageId);
      setState(() {
        _pageContent = content;
        _textController.text = content;
      });
      // Inicializar provider após carregar o conteúdo
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(editorControllerProvider.notifier).state = ref
              .read(editorControllerProvider.notifier)
              .state
              .copyWith(content: content);
        }
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
    _autoSaveTimer?.cancel();
    _updateProviderTimer?.cancel();
    _textController.dispose();
    _editorFocusNode.dispose();
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

    // Debounce para evitar múltiplas atualizações do provider
    _updateProviderTimer?.cancel();
    _updateProviderTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        ref.read(editorControllerProvider.notifier).state = ref
            .read(editorControllerProvider.notifier)
            .state
            .copyWith(content: text);
      }
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
    // Tratamento especial para comando de IA
    if (command.trigger == 'ia') {
      _showAIGenerationDialog();
      return;
    }

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

  void _showAIGenerationDialog() {
    _removeSlashMenu(force: true);

    // Remover foco do editor antes de abrir o diálogo
    _editorFocusNode.unfocus();

    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (context) => AIGenerationDialog(
        onContentGenerated: (String generatedContent) {
          // Remove o comando /ia do texto
          final text = _textController.text;
          final cursor = _textController.selection.baseOffset;
          final slashPos = _slashPosition >= 0 ? _slashPosition : cursor - 1;
          final before = text.substring(0, slashPos);
          final after = text.substring(cursor);

          // Insere o conteúdo gerado pela IA
          final newText = before + generatedContent + after;
          _textController.text = newText;

          // Posiciona o cursor após o conteúdo gerado
          final newCursorPosition = slashPos + generatedContent.length;
          _textController.selection =
              TextSelection.collapsed(offset: newCursorPosition);

          // Foca no editor após fechar o diálogo
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_editorFocusNode.canRequestFocus) {
              _editorFocusNode.requestFocus();
            }
          });
        },
      ),
    );
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
      {String? color,
      String? backgroundColor,
      String? alignment,
      String? content}) {
    if (_selectedText == null) return;

    final text = _textController.text;
    final start = _selectedText!.start;
    final end = _selectedText!.end;
    final selectedText = text.substring(start, end);

    String formattedText = selectedText;

    // Permitir combinação de formatações: aplica a tag ao texto já formatado
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
          formattedText = '<span style="color:$color">$selectedText</span>';
        }
        break;
      case 'backgroundColor':
        if (backgroundColor != null) {
          formattedText =
              '<span style="background-color:$backgroundColor">$selectedText</span>';
        }
        break;
      case 'alignment':
        if (alignment != null) {
          formattedText = '<align value="$alignment">$selectedText</align>';
        }
        break;
      case 'latex':
        // color aqui é o conteúdo da fórmula
        final latexContent = color ?? '';
        formattedText = '''
\\(
$latexContent
\\)
''';
        break;
      case 'matrix':
        // color aqui é o template da matriz
        final matrixTemplate = color ?? '';
        formattedText = '''
\\[
$matrixTemplate
\\]
''';
        break;
      case 'mermaid':
        // color aqui é o conteúdo do diagrama
        final mermaidContent = color ?? '';
        formattedText = '```mermaid\n$mermaidContent\n```\n';
        break;
      default:
        return; // Não aplicar formatação desconhecida
    }

    // Se o texto já tem tags, permite aninhar (ex: <color><u>texto</u></color>)
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

  String _sanitizeContent(String content) {
    final buffer = StringBuffer();
    bool foundInvalid = false;

    for (final line in content.split('\n')) {
      try {
        // Tenta acessar runes para forçar validação UTF-16
        line.runes.toList();
        buffer.writeln(line);
      } catch (e) {
        foundInvalid = true;
        // Substituir linha inválida por placeholder
        buffer.writeln('⚠️ [Conteúdo inválido removido]');
      }
    }

    if (foundInvalid) {
      // Conteúdo inválido UTF-16 detectado e removido
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_showLivePreview) {
      // Modo com live preview (50-50)
      return Row(
        children: [
          // Editor (50%)
          Expanded(
            flex: 5,
            child: _buildEditor(isDarkMode),
          ),
          // Separador vertical
          Container(
            width: 1,
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          // Live Preview (50%)
          Expanded(
            flex: 5,
            child: _buildLivePreview(isDarkMode),
          ),
        ],
      );
    } else {
      // Modo apenas editor (100%)
      return _buildEditor(isDarkMode);
    }
  }

  Widget _buildEditor(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barra de ferramentas
          Row(
            children: [
              IconButton(
                icon: Icon(
                    _showLivePreview ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _showLivePreview = !_showLivePreview;
                  });
                },
                tooltip:
                    _showLivePreview ? 'Ocultar Preview' : 'Mostrar Preview',
              ),
              const Spacer(),
              if (_isSaving)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDarkMode ? Colors.white70 : Colors.grey[600]!,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Salvando...',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Editor de texto
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _editorFocusNode,
              maxLines: null,
              expands: true,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontFamily: 'monospace',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Digite seu markdown aqui...',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
              onChanged: _onTextChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivePreview(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.transparent : AppColors.lightSurface,
        border: Border(
          left: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho da preview
          Row(
            children: [
              Icon(Icons.preview, size: 16),
              const SizedBox(width: 8),
              Text(
                'Preview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Conteúdo da preview
          Expanded(
            child: Column(
              children: [
                // Exemplo de texto colorido
                if (_textController.text.contains('{{colored_text}}'))
                  DynamicColoredText(
                    text: 'Este é um exemplo de texto com cores dinâmicas!',
                    showControls: true,
                    onColorsChanged: (textColor, backgroundColor) {
                      // Callback quando as cores mudam
                    },
                  ),

                // Preview markdown normal
                Expanded(
                  child: EnhancedMarkdownPreviewWidget(
                    markdown: _textController.text,
                    enableHtmlEnhancements: true,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ],
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
