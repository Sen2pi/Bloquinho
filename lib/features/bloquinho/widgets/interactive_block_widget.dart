import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../models/page_models.dart';
import '../providers/page_provider.dart';

/// Widget que renderiza um bloco de conteúdo interativo
class InteractiveBlockWidget extends ConsumerStatefulWidget {
  final PageBlock block;
  final bool isDarkMode;
  final Function(PageBlock)? onChanged;
  final VoidCallback? onDelete;
  final Function(PageBlockType)? onTypeChanged;

  const InteractiveBlockWidget({
    super.key,
    required this.block,
    this.isDarkMode = false,
    this.onChanged,
    this.onDelete,
    this.onTypeChanged,
  });

  @override
  ConsumerState<InteractiveBlockWidget> createState() =>
      _InteractiveBlockWidgetState();
}

class _InteractiveBlockWidgetState
    extends ConsumerState<InteractiveBlockWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.block.content;
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_isEditing) {
      final updatedBlock = widget.block.copyWith(content: _controller.text);
      widget.onChanged?.call(updatedBlock);
    }
  }

  void _onFocusChanged() {
    setState(() {
      _isEditing = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Área de controles à esquerda (aparece no hover)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isHovering || _isEditing ? 40 : 0,
              child: _isHovering || _isEditing
                  ? _buildBlockControls()
                  : const SizedBox.shrink(),
            ),

            // Conteúdo principal do bloco
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: _isEditing || _isHovering
                      ? (widget.isDarkMode
                          ? AppColors.darkSurface.withOpacity(0.3)
                          : AppColors.lightSurface.withOpacity(0.3))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _buildBlockContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockControls() {
    return Column(
      children: [
        // Handle para arrastar (drag handle)
        GestureDetector(
          onTap: () {
            // TODO: Implementar reordenação por drag
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              PhosphorIcons.dotsSix(),
              size: 14,
              color: widget.isDarkMode
                  ? AppColors.darkTextSecondary.withOpacity(0.6)
                  : AppColors.lightTextSecondary.withOpacity(0.6),
            ),
          ),
        ),

        // Botão de adicionar bloco
        GestureDetector(
          onTap: _showBlockTypeSelector,
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              PhosphorIcons.plus(),
              size: 14,
              color: widget.isDarkMode
                  ? AppColors.darkTextSecondary.withOpacity(0.6)
                  : AppColors.lightTextSecondary.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlockContent() {
    switch (widget.block.type) {
      case PageBlockType.heading1:
        return _buildHeadingBlock(1);
      case PageBlockType.heading2:
        return _buildHeadingBlock(2);
      case PageBlockType.heading3:
        return _buildHeadingBlock(3);
      case PageBlockType.quote:
        return _buildQuoteBlock();
      case PageBlockType.bulletList:
        return _buildListBlock('•');
      case PageBlockType.numberedList:
        return _buildListBlock('1.');
      case PageBlockType.todoList:
        return _buildTodoBlock();
      case PageBlockType.code:
        return _buildCodeBlock();
      case PageBlockType.divider:
        return _buildDividerBlock();
      case PageBlockType.callout:
        return _buildCalloutBlock();
      default:
        return _buildTextBlock();
    }
  }

  Widget _buildTextBlock() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      maxLines: null,
      style: TextStyle(
        fontSize: 16,
        height: 1.5,
        color: widget.isDarkMode
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Digite "/" para comandos ou comece a escrever...',
        hintStyle: TextStyle(
          color: widget.isDarkMode
              ? AppColors.darkTextSecondary.withOpacity(0.6)
              : AppColors.lightTextSecondary.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildHeadingBlock(int level) {
    double fontSize;
    FontWeight fontWeight;

    switch (level) {
      case 1:
        fontSize = 28;
        fontWeight = FontWeight.bold;
        break;
      case 2:
        fontSize = 24;
        fontWeight = FontWeight.w600;
        break;
      case 3:
        fontSize = 20;
        fontWeight = FontWeight.w500;
        break;
      default:
        fontSize = 18;
        fontWeight = FontWeight.w500;
    }

    return Row(
      children: [
        // Indicador do tipo de heading
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'H$level',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),

        // Campo de texto
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: null,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              height: 1.2,
              color: widget.isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText:
                  'Título ${level == 1 ? 'principal' : level == 2 ? 'secundário' : 'terciário'}',
              hintStyle: TextStyle(
                color: widget.isDarkMode
                    ? AppColors.darkTextSecondary.withOpacity(0.6)
                    : AppColors.lightTextSecondary.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteBlock() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra lateral da citação
        Container(
          width: 4,
          height: 50,
          margin: const EdgeInsets.only(right: 12, top: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.6),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Campo de texto
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: null,
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: widget.isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Citação ou frase inspiradora...',
              hintStyle: TextStyle(
                color: widget.isDarkMode
                    ? AppColors.darkTextSecondary.withOpacity(0.6)
                    : AppColors.lightTextSecondary.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListBlock(String bullet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Marcador da lista
        Container(
          width: 24,
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            bullet,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ),

        // Campo de texto
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: null,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: widget.isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Item da lista...',
              hintStyle: TextStyle(
                color: widget.isDarkMode
                    ? AppColors.darkTextSecondary.withOpacity(0.6)
                    : AppColors.lightTextSecondary.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodoBlock() {
    final isCompleted = widget.block.metadata['completed'] == true;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checkbox
        Container(
          padding: const EdgeInsets.only(top: 4, right: 8),
          child: GestureDetector(
            onTap: () {
              final updatedBlock = widget.block.copyWith(
                metadata: {
                  ...widget.block.metadata,
                  'completed': !isCompleted,
                },
              );
              widget.onChanged?.call(updatedBlock);
            },
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.primary
                      : (widget.isDarkMode
                          ? AppColors.darkBorder
                          : AppColors.lightBorder),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              child: isCompleted
                  ? Icon(
                      PhosphorIcons.check(),
                      size: 10,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
        ),

        // Campo de texto
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: null,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              color: widget.isDarkMode
                  ? (isCompleted
                      ? AppColors.darkTextSecondary
                      : AppColors.darkTextPrimary)
                  : (isCompleted
                      ? AppColors.lightTextSecondary
                      : AppColors.lightTextPrimary),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Tarefa a fazer...',
              hintStyle: TextStyle(
                color: widget.isDarkMode
                    ? AppColors.darkTextSecondary.withOpacity(0.6)
                    : AppColors.lightTextSecondary.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeBlock() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              widget.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: null,
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'monospace',
          height: 1.4,
          color: widget.isDarkMode
              ? Colors.lightBlue.shade300
              : Colors.blue.shade800,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: '// Seu código aqui...',
          hintStyle: TextStyle(
            color: widget.isDarkMode
                ? AppColors.darkTextSecondary.withOpacity(0.6)
                : AppColors.lightTextSecondary.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildDividerBlock() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    widget.isDarkMode
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalloutBlock() {
    final emoji = widget.block.metadata['emoji'] ?? '💡';
    final backgroundColor = widget.block.metadata['backgroundColor'] ?? 'blue';

    Color bgColor;
    switch (backgroundColor) {
      case 'yellow':
        bgColor = Colors.yellow.shade50;
        break;
      case 'red':
        bgColor = Colors.red.shade50;
        break;
      case 'green':
        bgColor = Colors.green.shade50;
        break;
      default:
        bgColor = Colors.blue.shade50;
    }

    if (widget.isDarkMode) {
      bgColor = bgColor.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isDarkMode
              ? AppColors.darkBorder.withOpacity(0.3)
              : AppColors.lightBorder.withOpacity(0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji do callout
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),

          // Campo de texto
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: widget.isDarkMode
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Destaque importante...',
                hintStyle: TextStyle(
                  color: widget.isDarkMode
                      ? AppColors.darkTextSecondary.withOpacity(0.6)
                      : AppColors.lightTextSecondary.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBlockTypeSelector() {
    showDialog(
      context: context,
      builder: (context) => BlockTypeSelectorDialog(
        currentType: widget.block.type,
        isDarkMode: widget.isDarkMode,
        onTypeSelected: (type) {
          widget.onTypeChanged?.call(type);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

/// Dialog para seleção do tipo de bloco
class BlockTypeSelectorDialog extends StatelessWidget {
  final PageBlockType currentType;
  final bool isDarkMode;
  final Function(PageBlockType) onTypeSelected;

  const BlockTypeSelectorDialog({
    super.key,
    required this.currentType,
    required this.isDarkMode,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final blockTypes = [
      {
        'type': PageBlockType.text,
        'icon': PhosphorIcons.textT(),
        'label': 'Texto'
      },
      {
        'type': PageBlockType.heading1,
        'icon': PhosphorIcons.textHOne(),
        'label': 'Título 1'
      },
      {
        'type': PageBlockType.heading2,
        'icon': PhosphorIcons.textHTwo(),
        'label': 'Título 2'
      },
      {
        'type': PageBlockType.heading3,
        'icon': PhosphorIcons.textHThree(),
        'label': 'Título 3'
      },
      {
        'type': PageBlockType.bulletList,
        'icon': PhosphorIcons.listBullets(),
        'label': 'Lista'
      },
      {
        'type': PageBlockType.numberedList,
        'icon': PhosphorIcons.listNumbers(),
        'label': 'Lista numerada'
      },
      {
        'type': PageBlockType.todoList,
        'icon': PhosphorIcons.checkSquare(),
        'label': 'Lista de tarefas'
      },
      {
        'type': PageBlockType.quote,
        'icon': PhosphorIcons.quotes(),
        'label': 'Citação'
      },
      {
        'type': PageBlockType.code,
        'icon': PhosphorIcons.code(),
        'label': 'Código'
      },
      {
        'type': PageBlockType.callout,
        'icon': PhosphorIcons.info(),
        'label': 'Destaque'
      },
      {
        'type': PageBlockType.divider,
        'icon': PhosphorIcons.minus(),
        'label': 'Divisor'
      },
    ];

    return AlertDialog(
      title: const Text('Escolher tipo de bloco'),
      content: SizedBox(
        width: 300,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: blockTypes.length,
          itemBuilder: (context, index) {
            final blockType = blockTypes[index];
            final type = blockType['type'] as PageBlockType;
            final icon = blockType['icon'] as IconData;
            final label = blockType['label'] as String;
            final isSelected = type == currentType;

            return ListTile(
              leading: Icon(icon, size: 20),
              title: Text(label),
              selected: isSelected,
              onTap: () => onTypeSelected(type),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
