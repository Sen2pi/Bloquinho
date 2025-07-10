import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/notion_block.dart';
import '../../../core/theme/app_colors.dart';

/// Widget principal do editor de blocos similar ao Notion
class NotionBlockEditor extends ConsumerStatefulWidget {
  final List<NotionBlock> blocks;
  final Function(List<NotionBlock>) onBlocksChanged;
  final bool isDarkMode;

  const NotionBlockEditor({
    super.key,
    required this.blocks,
    required this.onBlocksChanged,
    this.isDarkMode = false,
  });

  @override
  ConsumerState<NotionBlockEditor> createState() => _NotionBlockEditorState();
}

class _NotionBlockEditorState extends ConsumerState<NotionBlockEditor> {
  final FocusNode _focusNode = FocusNode();
  int? _selectedBlockIndex;
  bool _showSlashMenu = false;
  bool _showContextMenu = false;
  String _slashQuery = '';
  Offset _menuPosition = Offset.zero;
  late List<NotionBlock> _blocks;

  @override
  void initState() {
    super.initState();
    _blocks = List.from(widget.blocks);

    // Se não há blocos, criar um bloco de texto inicial
    if (_blocks.isEmpty) {
      _blocks.add(NotionBlock.create());
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        child: Container(
          constraints: const BoxConstraints(minHeight: 400),
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              // Editor principal
              _buildMainEditor(),

              // Menu de comandos slash
              if (_showSlashMenu) _buildSlashMenu(),

              // Menu contextual
              if (_showContextMenu) _buildContextMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainEditor() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _blocks.length,
      itemBuilder: (context, index) {
        return _buildBlockEditor(index);
      },
    );
  }

  Widget _buildBlockEditor(int index) {
    final block = _blocks[index];
    final isSelected = _selectedBlockIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle de drag (6 pontos)
          _buildDragHandle(index, isSelected),

          // Botão de adicionar bloco
          _buildAddBlockButton(index, isSelected),

          // Editor do bloco
          Expanded(
            child: _buildBlockContent(index, block, isSelected),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle(int index, bool isSelected) {
    return GestureDetector(
      onPanStart: (_) => _startDrag(index),
      child: AnimatedOpacity(
        opacity: isSelected ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(right: 4, top: 8),
          child: Icon(
            PhosphorIcons.dotsSixVertical(),
            size: 16,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildAddBlockButton(int index, bool isSelected) {
    return GestureDetector(
      onTap: () => _insertBlockAfter(index),
      child: AnimatedOpacity(
        opacity: isSelected ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(right: 8, top: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            PhosphorIcons.plus(),
            size: 12,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockContent(int index, NotionBlock block, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectBlock(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (widget.isDarkMode
                  ? AppColors.blockBackgroundDark
                  : AppColors.blockBackground)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: isSelected
              ? Border.all(color: AppColors.primary.withOpacity(0.3))
              : null,
        ),
        child: _buildBlockByType(index, block),
      ),
    );
  }

  Widget _buildBlockByType(int index, NotionBlock block) {
    switch (block.type) {
      case NotionBlockType.heading1:
        return _buildHeadingEditor(index, block, 1);
      case NotionBlockType.heading2:
        return _buildHeadingEditor(index, block, 2);
      case NotionBlockType.heading3:
        return _buildHeadingEditor(index, block, 3);
      case NotionBlockType.bulletList:
        return _buildListEditor(index, block, '•');
      case NotionBlockType.numberedList:
        return _buildListEditor(index, block, '1.');
      case NotionBlockType.todoList:
        return _buildTodoEditor(index, block);
      case NotionBlockType.quote:
        return _buildQuoteEditor(index, block);
      case NotionBlockType.codeBlock:
        return _buildCodeEditor(index, block);
      case NotionBlockType.divider:
        return _buildDividerEditor(index, block);
      case NotionBlockType.callout:
        return _buildCalloutEditor(index, block);
      case NotionBlockType.text:
      case NotionBlockType.paragraph:
      default:
        return _buildTextEditor(index, block);
    }
  }

  Widget _buildTextEditor(int index, NotionBlock block) {
    return TextField(
      controller: TextEditingController(text: block.content),
      onChanged: (value) => _updateBlockContent(index, value),
      onSubmitted: (_) => _handleEnterKey(index),
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Digite \'/\' para comandos',
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      minLines: 1,
      maxLines: null,
    );
  }

  Widget _buildHeadingEditor(int index, NotionBlock block, int level) {
    TextStyle style;
    switch (level) {
      case 1:
        style = Theme.of(context).textTheme.displayMedium!;
        break;
      case 2:
        style = Theme.of(context).textTheme.displaySmall!;
        break;
      case 3:
        style = Theme.of(context).textTheme.headlineMedium!;
        break;
      default:
        style = Theme.of(context).textTheme.bodyLarge!;
    }

    return TextField(
      controller: TextEditingController(text: block.content),
      onChanged: (value) => _updateBlockContent(index, value),
      onSubmitted: (_) => _handleEnterKey(index),
      style: style.copyWith(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: 'Título $level',
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      minLines: 1,
      maxLines: null,
    );
  }

  Widget _buildListEditor(int index, NotionBlock block, String prefix) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            prefix,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: block.content),
            onChanged: (value) => _updateBlockContent(index, value),
            onSubmitted: (_) => _handleEnterKey(index),
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: const InputDecoration(
              hintText: 'Item da lista',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            minLines: 1,
            maxLines: null,
          ),
        ),
      ],
    );
  }

  Widget _buildTodoEditor(int index, NotionBlock block) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _toggleTodo(index),
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(right: 8, top: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4),
              color: block.properties.checked
                  ? AppColors.primary
                  : Colors.transparent,
            ),
            child: block.properties.checked
                ? Icon(
                    PhosphorIcons.check(),
                    size: 14,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: block.content),
            onChanged: (value) => _updateBlockContent(index, value),
            onSubmitted: (_) => _handleEnterKey(index),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  decoration: block.properties.checked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
            decoration: const InputDecoration(
              hintText: 'Tarefa',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            minLines: 1,
            maxLines: null,
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteEditor(int index, NotionBlock block) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppColors.primary,
            width: 4,
          ),
        ),
      ),
      padding: const EdgeInsets.only(left: 16),
      child: TextField(
        controller: TextEditingController(text: block.content),
        onChanged: (value) => _updateBlockContent(index, value),
        onSubmitted: (_) => _handleEnterKey(index),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
            ),
        decoration: const InputDecoration(
          hintText: 'Citação',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        minLines: 1,
        maxLines: null,
      ),
    );
  }

  Widget _buildCodeEditor(int index, NotionBlock block) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? AppColors.codeBlockBgDark
            : AppColors.codeBlockBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: TextEditingController(text: block.content),
        onChanged: (value) => _updateBlockContent(index, value),
        onSubmitted: (_) => _handleEnterKey(index),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              color: widget.isDarkMode ? Colors.white : Colors.green[800],
            ),
        decoration: const InputDecoration(
          hintText: 'Código',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        minLines: 1,
        maxLines: null,
      ),
    );
  }

  Widget _buildDividerEditor(int index, NotionBlock block) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.grey[300],
    );
  }

  Widget _buildCalloutEditor(int index, NotionBlock block) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? AppColors.quoteBlockBgDark
            : AppColors.quoteBlockBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            block.properties.icon ?? '💡',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: block.content),
              onChanged: (value) => _updateBlockContent(index, value),
              onSubmitted: (_) => _handleEnterKey(index),
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Destaque importante',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              minLines: 1,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlashMenu() {
    final commands = SlashCommands.search(_slashQuery);

    return Positioned(
      left: _menuPosition.dx,
      top: _menuPosition.dy,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 300,
          height: 200,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comandos',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: commands.length,
                  itemBuilder: (context, index) {
                    final command = commands[index];
                    return ListTile(
                      dense: true,
                      leading: Text(command.icon),
                      title: Text(command.displayName),
                      subtitle: Text(command.description),
                      onTap: () => _insertBlock(command),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContextMenu() {
    return Positioned(
      left: _menuPosition.dx,
      top: _menuPosition.dy,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Formatação de texto
              ...ContextualActions.textFormatting.map(
                (action) => ListTile(
                  dense: true,
                  leading: Text(action.icon),
                  title: Text(action.displayName),
                  trailing: action.shortcut != null
                      ? Text(action.shortcut!,
                          style: const TextStyle(fontSize: 12))
                      : null,
                  onTap: () => _applyFormatting(action.action),
                ),
              ),
              const Divider(),
              // Transformações de bloco
              ...ContextualActions.blockTransforms.take(4).map(
                    (action) => ListTile(
                      dense: true,
                      leading: Text(action.icon),
                      title: Text(action.displayName),
                      onTap: () => _transformBlock(action.action),
                    ),
                  ),
              const Divider(),
              // Ações do bloco
              ...ContextualActions.blockActions.map(
                (action) => ListTile(
                  dense: true,
                  leading: Text(action.icon),
                  title: Text(action.displayName),
                  onTap: () => _performBlockAction(action.action),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Event handlers
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      // Enter para criar novo bloco
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_selectedBlockIndex != null) {
          _handleEnterKey(_selectedBlockIndex!);
          return KeyEventResult.handled;
        }
      }

      // Backspace para deletar bloco vazio
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_selectedBlockIndex != null) {
          final block = _blocks[_selectedBlockIndex!];
          if (block.content.isEmpty && _blocks.length > 1) {
            _deleteBlock(_selectedBlockIndex!);
            return KeyEventResult.handled;
          }
        }
      }

      // Tab para indentar
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        if (_selectedBlockIndex != null) {
          _indentBlock(_selectedBlockIndex!);
          return KeyEventResult.handled;
        }
      }

      // Setas para navegar
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _navigateUp();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _navigateDown();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  void _selectBlock(int index) {
    setState(() {
      _selectedBlockIndex = index;
      _showSlashMenu = false;
      _showContextMenu = false;
    });
  }

  void _updateBlockContent(int index, String content) {
    // Detectar comandos slash
    if (content.startsWith('/')) {
      _showSlashMenu = true;
      _slashQuery = content.substring(1);
      setState(() {});
      return;
    } else {
      _showSlashMenu = false;
    }

    setState(() {
      _blocks[index] = _blocks[index].copyWith(content: content);
    });

    widget.onBlocksChanged(_blocks);
  }

  void _handleEnterKey(int index) {
    _insertBlockAfter(index);
  }

  void _insertBlockAfter(int index) {
    setState(() {
      _blocks.insert(
        index + 1,
        NotionBlock.create(),
      );
      _selectedBlockIndex = index + 1;
    });

    widget.onBlocksChanged(_blocks);
  }

  void _insertBlock(SlashCommand command) {
    if (_selectedBlockIndex != null) {
      final newBlock = NotionBlock.create(
        type: command.blockType,
        properties: command.defaultProperties ?? const NotionBlockProperties(),
      );

      setState(() {
        _blocks[_selectedBlockIndex!] = newBlock;
        _showSlashMenu = false;
      });

      widget.onBlocksChanged(_blocks);
    }
  }

  void _deleteBlock(int index) {
    if (_blocks.length > 1) {
      setState(() {
        _blocks.removeAt(index);
        if (_selectedBlockIndex == index) {
          _selectedBlockIndex = index > 0 ? index - 1 : 0;
        }
      });

      widget.onBlocksChanged(_blocks);
    }
  }

  void _toggleTodo(int index) {
    final block = _blocks[index];
    setState(() {
      _blocks[index] = block.copyWith(
        properties: block.properties.copyWith({
          'checked': !block.properties.checked,
        }),
      );
    });

    widget.onBlocksChanged(_blocks);
  }

  void _startDrag(int index) {
    // Implementar drag and drop
  }

  void _indentBlock(int index) {
    // Implementar indentação
  }

  void _navigateUp() {
    if (_selectedBlockIndex != null && _selectedBlockIndex! > 0) {
      setState(() {
        _selectedBlockIndex = _selectedBlockIndex! - 1;
      });
    }
  }

  void _navigateDown() {
    if (_selectedBlockIndex != null &&
        _selectedBlockIndex! < _blocks.length - 1) {
      setState(() {
        _selectedBlockIndex = _selectedBlockIndex! + 1;
      });
    }
  }

  void _applyFormatting(FormatAction action) {
    // Implementar formatação de texto
    setState(() {
      _showContextMenu = false;
    });
  }

  void _transformBlock(FormatAction action) {
    if (_selectedBlockIndex != null) {
      NotionBlockType? newType;

      switch (action) {
        case FormatAction.turnIntoHeading1:
          newType = NotionBlockType.heading1;
          break;
        case FormatAction.turnIntoHeading2:
          newType = NotionBlockType.heading2;
          break;
        case FormatAction.turnIntoHeading3:
          newType = NotionBlockType.heading3;
          break;
        case FormatAction.turnIntoBulletList:
          newType = NotionBlockType.bulletList;
          break;
        case FormatAction.turnIntoNumberedList:
          newType = NotionBlockType.numberedList;
          break;
        case FormatAction.turnIntoTodo:
          newType = NotionBlockType.todoList;
          break;
        case FormatAction.turnIntoQuote:
          newType = NotionBlockType.quote;
          break;
        case FormatAction.turnIntoCode:
          newType = NotionBlockType.codeBlock;
          break;
        default:
          break;
      }

      if (newType != null) {
        setState(() {
          _blocks[_selectedBlockIndex!] =
              _blocks[_selectedBlockIndex!].copyWith(
            type: newType,
          );
          _showContextMenu = false;
        });

        widget.onBlocksChanged(_blocks);
      }
    }
  }

  void _performBlockAction(FormatAction action) {
    if (_selectedBlockIndex != null) {
      switch (action) {
        case FormatAction.duplicate:
          final blockToDuplicate = _blocks[_selectedBlockIndex!];
          setState(() {
            _blocks.insert(
              _selectedBlockIndex! + 1,
              blockToDuplicate.copyWith(id: null), // Novo ID será gerado
            );
          });
          break;
        case FormatAction.delete:
          _deleteBlock(_selectedBlockIndex!);
          break;
        default:
          break;
      }
    }

    setState(() {
      _showContextMenu = false;
    });

    widget.onBlocksChanged(_blocks);
  }
}
