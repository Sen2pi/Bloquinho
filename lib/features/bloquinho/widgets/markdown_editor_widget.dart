import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/theme_provider.dart';

class MarkdownEditorWidget extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final bool showLineNumbers;
  final bool enableSyntaxHighlighting;

  const MarkdownEditorWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.showLineNumbers = true,
    this.enableSyntaxHighlighting = true,
  });

  @override
  ConsumerState<MarkdownEditorWidget> createState() =>
      _MarkdownEditorWidgetState();
}

class _MarkdownEditorWidgetState extends ConsumerState<MarkdownEditorWidget> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  int _currentLineCount = 1;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateLineCount);
    _updateLineCount();
  }

  void _updateLineCount() {
    final lines = widget.controller.text.split('\n');
    if (lines.length != _currentLineCount) {
      setState(() {
        _currentLineCount = lines.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          _buildToolbar(isDarkMode),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showLineNumbers) _buildLineNumbers(isDarkMode),
                Expanded(child: _buildEditor(isDarkMode)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(bool isDarkMode) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildToolbarButton(PhosphorIcons.textB(), 'Negrito',
              () => _insertFormat('**', '**')),
          _buildToolbarButton(PhosphorIcons.textItalic(), 'Itálico',
              () => _insertFormat('*', '*')),
          _buildToolbarButton(
              PhosphorIcons.code(), 'Código', () => _insertFormat('`', '`')),
          const VerticalDivider(),
          _buildToolbarButton(
              PhosphorIcons.textH(), 'Título', () => _insertAtLineStart('# ')),
          _buildToolbarButton(
              PhosphorIcons.list(), 'Lista', () => _insertAtLineStart('- ')),
          _buildToolbarButton(PhosphorIcons.listNumbers(), 'Lista Numerada',
              () => _insertAtLineStart('1. ')),
          const VerticalDivider(),
          _buildToolbarButton(PhosphorIcons.link(), 'Link', _insertLink),
          _buildToolbarButton(PhosphorIcons.image(), 'Imagem', _insertImage),
          _buildToolbarButton(PhosphorIcons.table(), 'Tabela', _insertTable),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(
      IconData icon, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }

  Widget _buildLineNumbers(bool isDarkMode) {
    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        border: Border(
          right: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_currentLineCount, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
                fontFamily: 'monospace',
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEditor(bool isDarkMode) {
    return Scrollbar(
      controller: _scrollController,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        scrollController: _scrollController,
        maxLines: null,
        expands: true,
        onChanged: widget.onChanged,
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'monospace',
          color: isDarkMode
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: 'Digite seu markdown aqui...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          hintStyle: TextStyle(
            color: isDarkMode
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary,
          ),
        ),
      ),
    );
  }

  void _insertFormat(String before, String after) {
    final selection = widget.controller.selection;
    final text = widget.controller.text;

    if (selection.isValid) {
      final selectedText = text.substring(selection.start, selection.end);
      final newText = '$before$selectedText$after';

      widget.controller.text =
          text.replaceRange(selection.start, selection.end, newText);

      final newSelectionStart = selection.start + before.length;
      final newSelectionEnd = newSelectionStart + selectedText.length;

      widget.controller.selection = TextSelection(
        baseOffset: newSelectionStart,
        extentOffset: newSelectionEnd,
      );
    }
  }

  void _insertAtLineStart(String prefix) {
    final selection = widget.controller.selection;
    final text = widget.controller.text;
    final lines = text.split('\n');

    // Encontrar linha atual
    int currentPos = 0;
    int lineIndex = 0;

    for (int i = 0; i < lines.length; i++) {
      if (currentPos + lines[i].length >= selection.start) {
        lineIndex = i;
        break;
      }
      currentPos += lines[i].length + 1; // +1 para \n
    }

    lines[lineIndex] = prefix + lines[lineIndex];
    widget.controller.text = lines.join('\n');

    // Reposicionar cursor
    widget.controller.selection = TextSelection.collapsed(
      offset: selection.start + prefix.length,
    );
  }

  void _insertLink() {
    _insertFormat('[', '](https://)');
  }

  void _insertImage() {
    _insertFormat('![', '](https://)');
  }

  void _insertTable() {
    const table = '''
| Coluna 1 | Coluna 2 | Coluna 3 |
|----------|----------|----------|
| Valor 1  | Valor 2  | Valor 3  |
| Valor 4  | Valor 5  | Valor 6  |
''';

    final selection = widget.controller.selection;
    final text = widget.controller.text;

    widget.controller.text =
        text.replaceRange(selection.start, selection.end, table);
    widget.controller.selection = TextSelection.collapsed(
      offset: selection.start + table.length,
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateLineCount);
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
