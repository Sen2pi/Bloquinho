import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'dart:async';

import '../models/page_model.dart';
import '../providers/pages_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../screens/bloco_editor_screen.dart';

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
  final FocusNode _editorFocusNode = FocusNode();
  int _slashPosition = -1;
  final List<Map<String, String>> _slashCommands = [
    {'label': 'Título 1', 'insert': '# '},
    {'label': 'Título 2', 'insert': '## '},
    {'label': 'Título 3', 'insert': '### '},
    {'label': 'Lista', 'insert': '- '},
    {'label': 'Lista numerada', 'insert': '1. '},
    {
      'label': 'Tabela',
      'insert': '| Coluna 1 | Coluna 2 |\n| --- | --- |\n|  |  |'
    },
    {'label': 'Citação', 'insert': '> '},
    {'label': 'Código', 'insert': '```\n\n```'},
    {'label': 'Divisor', 'insert': '---'},
    {'label': 'Checkbox', 'insert': '- [ ] '},
    {'label': 'Link', 'insert': '[Texto](url)'},
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _editing = widget.isEditing;
    _loadContentFromFile();
    _editorFocusNode.addListener(_onFocusChange);
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
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _autoSaveTimer?.cancel();
    _editorFocusNode.dispose();
    _removeSlashMenu();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_editorFocusNode.hasFocus) {
      _removeSlashMenu();
    }
  }

  void _onTextChanged(String text) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      _saveContent(text);
    });
    _detectSlashCommand();
  }

  void _detectSlashCommand() {
    final cursor = _textController.selection.baseOffset;
    if (cursor > 0 && _textController.text[cursor - 1] == '/') {
      _slashPosition = cursor - 1;
      _showSlashMenu();
    } else if (_slashMenuOverlay != null) {
      _removeSlashMenu();
    }
  }

  void _showSlashMenu() {
    _removeSlashMenu();
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    _slashMenuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx + 40,
        top: offset.dy + 80,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 220,
            child: ListView(
              shrinkWrap: true,
              children: _slashCommands.map((cmd) {
                return ListTile(
                  title: Text(cmd['label']!),
                  onTap: () {
                    _insertSlashCommand(cmd['insert']!);
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_slashMenuOverlay!);
  }

  void _removeSlashMenu() {
    _slashMenuOverlay?.remove();
    _slashMenuOverlay = null;
  }

  void _insertSlashCommand(String insert) {
    final text = _textController.text;
    final cursor = _textController.selection.baseOffset;
    final before = text.substring(0, _slashPosition);
    final after = text.substring(cursor);
    _textController.text = before + insert + after;
    _textController.selection =
        TextSelection.collapsed(offset: (before + insert).length);
    _removeSlashMenu();
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
      _editing = false;
    });
  }

  String getPageContent(String pageId) {
    final pages = ref.read(pagesProvider);
    final page = pages.firstWhere(
      (p) => p.id == pageId,
      orElse: () => PageModel.create(title: 'Página não encontrada'),
    );
    return page.content;
  }

  void updatePageContent(String pageId, String content) {
    ref.read(pagesProvider.notifier).updatePageContent(pageId, content);
  }

  @override
  Widget build(BuildContext context) {
    final page = ref.watch(pagesProvider).firstWhere(
          (p) => p.id == widget.pageId,
          orElse: () => PageModel.create(title: 'Página não encontrada'),
        );

    return Column(
      children: [
        Row(
          children: [
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
            Text(
              page.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            if (_isSaving)
              Row(
                children: [
                  Icon(PhosphorIcons.circle(), size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text('Salvando...',
                      style:
                          TextStyle(fontSize: 12, color: Colors.orange[700])),
                ],
              )
            else
              Row(
                children: [
                  Icon(PhosphorIcons.checkCircle(),
                      size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text('Salvo',
                      style: TextStyle(fontSize: 12, color: Colors.green[700])),
                ],
              ),
          ],
        ),
        const Divider(),
        Expanded(
          child: _editing
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _textController,
                    focusNode: _editorFocusNode,
                    onChanged: _onTextChanged,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Digite em Markdown...'),
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: MarkdownBody(
                      data: _textController.text,
                      styleSheet:
                          MarkdownStyleSheet.fromTheme(Theme.of(context)),
                      builders: {
                        'table': _PageTableBuilder(onPageLinkTap: (pageId) {
                          final state = context.findAncestorStateOfType<
                              BlocoEditorScreenState>();
                          if (state != null) {
                            state.setPage(pageId);
                          }
                        }),
                      },
                    ),
                  ),
                ),
        ),
      ],
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
