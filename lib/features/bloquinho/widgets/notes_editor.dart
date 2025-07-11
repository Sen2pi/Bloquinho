import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../core/theme/app_colors.dart';

/// Editor de notas simples com suporte a markdown
/// Similar ao Typora mas mais simples e funcional
class NotesEditor extends ConsumerStatefulWidget {
  final String initialContent;
  final ValueChanged<String> onChanged;
  final bool isDarkMode;
  final String? placeholder;

  const NotesEditor({
    super.key,
    this.initialContent = '',
    required this.onChanged,
    this.isDarkMode = false,
    this.placeholder,
  });

  @override
  ConsumerState<NotesEditor> createState() => _NotesEditorState();
}

class _NotesEditorState extends ConsumerState<NotesEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  String _content = '';
  bool _isEditing = true;
  bool _showToolbar = false;

  // Estado para seleção
  String _selectedText = '';
  int _selectionStart = 0;
  int _selectionEnd = 0;

  // Comandos markdown disponíveis
  final List<MarkdownCommand> _commands = [
    MarkdownCommand('bold', 'Negrito', '**texto**', PhosphorIcons.textB()),
    MarkdownCommand('italic', 'Itálico', '*texto*', PhosphorIcons.textItalic()),
    MarkdownCommand('strikethrough', 'Riscado', '~~texto~~',
        PhosphorIcons.textStrikethrough()),
    MarkdownCommand('code', 'Código inline', '`código`', PhosphorIcons.code()),
    MarkdownCommand('link', 'Link', '[texto](url)', PhosphorIcons.link()),
    MarkdownCommand('image', 'Imagem', '![alt](url)', PhosphorIcons.image()),
    MarkdownCommand('h1', 'Título 1', '# Título', PhosphorIcons.textH()),
    MarkdownCommand('h2', 'Título 2', '## Título', PhosphorIcons.textH()),
    MarkdownCommand('h3', 'Título 3', '### Título', PhosphorIcons.textH()),
    MarkdownCommand('ul', 'Lista', '- Item', PhosphorIcons.list()),
    MarkdownCommand(
        'ol', 'Lista numerada', '1. Item', PhosphorIcons.listNumbers()),
    MarkdownCommand(
        'task', 'Tarefa', '- [ ] Tarefa', PhosphorIcons.checkSquare()),
    MarkdownCommand('quote', 'Citação', '> Citação', PhosphorIcons.quotes()),
    MarkdownCommand('codeblock', 'Bloco de código', '```\ncódigo\n```',
        PhosphorIcons.code()),
    MarkdownCommand(
        'table',
        'Tabela',
        '| Col1 | Col2 |\n|------|------|\n| Dado | Dado |',
        PhosphorIcons.table()),
    MarkdownCommand('divider', 'Divisor', '---', PhosphorIcons.minus()),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _focusNode = FocusNode();
    _content = widget.initialContent;

    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _content = _controller.text;
    widget.onChanged(_content);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.isDarkMode ? AppColors.darkBackground : Colors.white,
      child: Column(
        children: [
          // Toolbar
          _buildToolbar(),

          // Editor/Preview
          Expanded(
            child: _isEditing ? _buildEditor() : _buildPreview(),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          // Toggle Edit/Preview
          IconButton(
            icon:
                Icon(_isEditing ? PhosphorIcons.eye() : PhosphorIcons.pencil()),
            onPressed: () => setState(() => _isEditing = !_isEditing),
            tooltip: _isEditing ? 'Visualizar' : 'Editar',
          ),

          const VerticalDivider(),

          // Comandos markdown
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    _commands.map((cmd) => _buildToolbarButton(cmd)).toList(),
              ),
            ),
          ),

          const VerticalDivider(),

          // Ações adicionais
          IconButton(
            icon: Icon(PhosphorIcons.copy()),
            onPressed: _copyContent,
            tooltip: 'Copiar',
          ),
          IconButton(
            icon: Icon(PhosphorIcons.download()),
            onPressed: _exportContent,
            tooltip: 'Exportar',
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(MarkdownCommand cmd) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: IconButton(
        icon: Icon(cmd.icon, size: 16),
        onPressed: () => _applyMarkdownCommand(cmd),
        tooltip: '${cmd.label}\n${cmd.syntax}',
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildEditor() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: null,
        expands: true,
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'monospace',
          height: 1.6,
          color: widget.isDarkMode ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.placeholder ??
              '# Bem-vindo ao Editor de Notas!\n\n## Funcionalidades\n- **Negrito** e *itálico*\n- Listas e tabelas\n- Código inline e blocos\n- Citações e divisores\n\nUse os botões da toolbar para formatação...',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
            fontFamily: 'monospace',
          ),
        ),
        onTap: () {
          final selection = _controller.selection;
          if (selection.isValid) {
            _selectedText = selection.textInside(_controller.text);
            _selectionStart = selection.start;
            _selectionEnd = selection.end;
            setState(() {
              _showToolbar = _selectedText.isNotEmpty;
            });
          }
        },
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Markdown(
        data: _content,
        styleSheet: MarkdownStyleSheet(
          h1: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
          h2: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
          h3: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
          p: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
          code: TextStyle(
            fontFamily: 'monospace',
            backgroundColor: Colors.grey.shade200,
            color: Colors.black87,
          ),
          codeblockDecoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          blockquote: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey.shade700,
          ),
          blockquoteDecoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.grey.shade400, width: 4),
            ),
          ),
        ),
      ),
    );
  }

  void _applyMarkdownCommand(MarkdownCommand cmd) {
    final text = _controller.text;
    final selection = _controller.selection;

    String replacement;
    if (_selectedText.isNotEmpty) {
      // Aplicar formatação ao texto selecionado
      switch (cmd.command) {
        case 'bold':
          replacement = '**$_selectedText**';
          break;
        case 'italic':
          replacement = '*$_selectedText*';
          break;
        case 'strikethrough':
          replacement = '~~$_selectedText~~';
          break;
        case 'code':
          replacement = '`$_selectedText`';
          break;
        case 'link':
          replacement = '[$_selectedText](url)';
          break;
        default:
          replacement = cmd.syntax.replaceAll('texto', _selectedText);
      }
    } else {
      // Inserir template
      replacement = cmd.syntax;
    }

    final newText =
        text.replaceRange(_selectionStart, _selectionEnd, replacement);
    _controller.text = newText;

    // Reposicionar cursor
    final newPosition = _selectionStart + replacement.length;
    _controller.selection = TextSelection.collapsed(offset: newPosition);

    _showToolbar = false;
    setState(() {});
  }

  void _copyContent() {
    Clipboard.setData(ClipboardData(text: _content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conteúdo copiado!')),
    );
  }

  void _exportContent() {
    // Implementar exportação
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exportação em desenvolvimento...')),
    );
  }
}

// === CLASSES AUXILIARES ===

class MarkdownCommand {
  final String command;
  final String label;
  final String syntax;
  final IconData icon;

  MarkdownCommand(this.command, this.label, this.syntax, this.icon);
}
