import 'package:flutter/material.dart';

class NoteEditorPage extends StatefulWidget {
  final String? initialValue;
  final String title;

  const NoteEditorPage({
    super.key,
    this.initialValue,
    this.title = 'Editar Nota',
  });

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _controller;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasChanges = _controller.text != (widget.initialValue ?? '');
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  void _save() {
    Navigator.of(context).pop(_controller.text);
  }

  void _cancel() {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Descartar alterações?'),
          content: const Text(
              'Tem certeza que deseja sair sem salvar as alterações?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar dialog
                Navigator.of(context).pop(); // Fechar página
              },
              child: const Text('Descartar'),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _cancel,
        ),
        actions: [
          TextButton(
            onPressed: _hasChanges ? _save : null,
            child: Text(
              'Salvar',
              style: TextStyle(
                color: _hasChanges
                    ? theme.colorScheme.primary
                    : theme.disabledColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar de formatação
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.format_bold),
                  onPressed: () => _insertText('**', '**'),
                  tooltip: 'Negrito',
                ),
                IconButton(
                  icon: const Icon(Icons.format_italic),
                  onPressed: () => _insertText('*', '*'),
                  tooltip: 'Itálico',
                ),
                IconButton(
                  icon: const Icon(Icons.format_list_bulleted),
                  onPressed: () => _insertText('- ', ''),
                  tooltip: 'Lista',
                ),
                IconButton(
                  icon: const Icon(Icons.format_list_numbered),
                  onPressed: () => _insertText('1. ', ''),
                  tooltip: 'Lista numerada',
                ),
                const VerticalDivider(),
                IconButton(
                  icon: const Icon(Icons.link),
                  onPressed: () => _insertText('[', '](url)'),
                  tooltip: 'Link',
                ),
                IconButton(
                  icon: const Icon(Icons.code),
                  onPressed: () => _insertText('`', '`'),
                  tooltip: 'Código',
                ),
              ],
            ),
          ),
          // Editor de texto
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Digite sua nota aqui...',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                style: const TextStyle(fontSize: 16, height: 1.5),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                autofocus: true,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              '${_controller.text.length} caracteres',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            if (_hasChanges)
              Text(
                'Não salvo',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _insertText(String before, String after) {
    final selection = _controller.selection;
    final text = _controller.text;

    if (selection.isValid) {
      final selectedText = selection.textInside(text);
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$before$selectedText$after',
      );

      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start +
              before.length +
              selectedText.length +
              after.length,
        ),
      );
    } else {
      // Se não há seleção, inserir no final
      final newText = '${text}$before$after';
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: newText.length - after.length,
        ),
      );
    }
  }
}
