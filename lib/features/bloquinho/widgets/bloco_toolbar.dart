/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/bloco_base_model.dart';
import '../models/bloco_tipo_enum.dart';
import '../providers/blocos_provider.dart';
import '../providers/editor_controller_provider.dart';
import '../widgets/bloco_menu_widget.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';

/// Widget principal de toolbar para edição de blocos
class BlocoToolbar extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final Function(BlocoBase)? onBlockInsert;
  final VoidCallback? onToggleFormat;
  final bool isFloating;
  final bool showBlockActions;
  final bool showTextFormatting;
  final bool showInsertActions;
  final EdgeInsets? padding;
  final double? width;
  final Color? backgroundColor;

  const BlocoToolbar({
    super.key,
    required this.isDarkMode,
    this.onBlockInsert,
    this.onToggleFormat,
    this.isFloating = false,
    this.showBlockActions = true,
    this.showTextFormatting = true,
    this.showInsertActions = true,
    this.padding,
    this.width,
    this.backgroundColor,
  });

  @override
  ConsumerState<BlocoToolbar> createState() => _BlocoToolbarState();
}

class _BlocoToolbarState extends ConsumerState<BlocoToolbar> {
  bool _showInsertMenu = false;
  bool _showMoreOptions = false;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFloating) {
      return _buildFloatingToolbar();
    }

    return _buildMainToolbar();
  }

  Widget _buildMainToolbar() {
    return Container(
      width: widget.width,
      padding: widget.padding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            (widget.isDarkMode
                ? AppColors.darkSurface
                : AppColors.lightSurface),
        border: Border(
          bottom: BorderSide(
            color: widget.isDarkMode
                ? AppColors.darkBorder
                : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Formatação de texto
          if (widget.showTextFormatting) ...[
            _buildTextFormattingGroup(),
            _buildDivider(),
          ],

          // Inserção de blocos
          if (widget.showInsertActions) ...[
            _buildInsertActionsGroup(),
            _buildDivider(),
          ],

          // Ações de bloco
          if (widget.showBlockActions) ...[
            _buildBlockActionsGroup(),
            _buildDivider(),
          ],

          const Spacer(),

          // Ações extras
          _buildExtraActionsGroup(),
        ],
      ),
    );
  }

  Widget _buildFloatingToolbar() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      color: widget.backgroundColor ??
          (widget.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToolbarButton(
              icon: PhosphorIcons.textB(),
              tooltip: 'Negrito (Ctrl+B)',
              onPressed: () => _formatText('bold'),
              isToggleable: true,
              isActive: _isFormatActive('bold'),
            ),
            _buildToolbarButton(
              icon: PhosphorIcons.textItalic(),
              tooltip: 'Itálico (Ctrl+I)',
              onPressed: () => _formatText('italic'),
              isToggleable: true,
              isActive: _isFormatActive('italic'),
            ),
            _buildToolbarButton(
              icon: PhosphorIcons.textUnderline(),
              tooltip: 'Sublinhado (Ctrl+U)',
              onPressed: () => _formatText('underline'),
              isToggleable: true,
              isActive: _isFormatActive('underline'),
            ),
            _buildDivider(isVertical: true),
            _buildToolbarButton(
              icon: PhosphorIcons.link(),
              tooltip: 'Inserir Link (Ctrl+K)',
              onPressed: _insertLink,
            ),
            _buildToolbarButton(
              icon: PhosphorIcons.code(),
              tooltip: 'Código Inline',
              onPressed: () => _formatText('code'),
              isToggleable: true,
              isActive: _isFormatActive('code'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormattingGroup() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildToolbarButton(
          icon: PhosphorIcons.textB(),
          tooltip: 'Negrito (Ctrl+B)',
          onPressed: () => _formatText('bold'),
          isToggleable: true,
          isActive: _isFormatActive('bold'),
        ),
        _buildToolbarButton(
          icon: PhosphorIcons.textItalic(),
          tooltip: 'Itálico (Ctrl+I)',
          onPressed: () => _formatText('italic'),
          isToggleable: true,
          isActive: _isFormatActive('italic'),
        ),
        _buildToolbarButton(
          icon: PhosphorIcons.textUnderline(),
          tooltip: 'Sublinhado (Ctrl+U)',
          onPressed: () => _formatText('underline'),
          isToggleable: true,
          isActive: _isFormatActive('underline'),
        ),
        _buildToolbarButton(
          icon: PhosphorIcons.textStrikethrough(),
          tooltip: 'Riscado',
          onPressed: () => _formatText('strikethrough'),
          isToggleable: true,
          isActive: _isFormatActive('strikethrough'),
        ),
        _buildDivider(isVertical: true),
        _buildToolbarButton(
          icon: PhosphorIcons.paintBrush(),
          tooltip: 'Cor do texto',
          onPressed: _showTextColorPicker,
        ),
        _buildToolbarButton(
          icon: PhosphorIcons.paintBucket(),
          tooltip: 'Cor de fundo',
          onPressed: _showBgColorPicker,
        ),
        _buildToolbarButton(
          icon: PhosphorIcons.sealCheck(),
          tooltip: 'Badge',
          onPressed: _showBadgeColorPicker,
        ),
        _buildDivider(isVertical: true),
        _buildToolbarButton(
          icon: PhosphorIcons.code(),
          tooltip: 'Código Inline',
          onPressed: () => _formatText('code'),
          isToggleable: true,
          isActive: _isFormatActive('code'),
        ),
        _buildToolbarButton(
          icon: PhosphorIcons.link(),
          tooltip: 'Inserir Link (Ctrl+K)',
          onPressed: _insertLink,
        ),
      ],
    );
  }

  void _showTextColorPicker() async {
    final color = await _showColorPickerDialog('Escolha a cor do texto');
    if (color != null) {
      _wrapSelectionWithTag('color', color);
    }
  }

  void _showBgColorPicker() async {
    final color = await _showColorPickerDialog('Escolha a cor de fundo');
    if (color != null) {
      _wrapSelectionWithTag('bg', color);
    }
  }

  void _showBadgeColorPicker() async {
    final color = await _showColorPickerDialog('Escolha a cor do badge');
    if (color != null) {
      _wrapSelectionWithTag('badge', color);
    }
  }

  Future<String?> _showColorPickerDialog(String title) async {
    final isDark = widget.isDarkMode;
    final colors = [
      'red',
      'blue',
      'green',
      'yellow',
      'orange',
      'purple',
      'black',
      'white',
      'gray',
      'pink',
      'cyan',
      'teal',
      'indigo',
      'lime',
      'amber',
      'deeporange',
      'lightblue',
      'lightgreen',
    ];
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        title: Text(title),
        content: SizedBox(
          width: 300,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors
                .map((c) => GestureDetector(
                      onTap: () => Navigator.of(context).pop(c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _colorFromName(c),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: isDark ? Colors.white : Colors.black,
                              width: 1),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Color _colorFromName(String name) {
    switch (name) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'gray':
        return Colors.grey;
      case 'pink':
        return Colors.pink;
      case 'cyan':
        return Colors.cyan;
      case 'teal':
        return Colors.teal;
      case 'indigo':
        return Colors.indigo;
      case 'lime':
        return Colors.lime;
      case 'amber':
        return Colors.amber;
      case 'deeporange':
        return Colors.deepOrange;
      case 'lightblue':
        return Colors.lightBlue;
      case 'lightgreen':
        return Colors.lightGreen;
      default:
        return Colors.black;
    }
  }

  void _wrapSelectionWithTag(String tag, String color) {
    // Envolve o texto selecionado com a tag customizada
    final editorState = ref.read(editorControllerProvider);
    final selection = editorState.selection;
    if (selection == null || selection.isCollapsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o texto para aplicar a cor.')),
      );
      return;
    }
    ref
        .read(editorControllerProvider.notifier)
        .wrapSelectionWithTag(tag, color);
  }

  Widget _buildInsertActionsGroup() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildToolbarButton(
          icon: PhosphorIcons.textH(),
          tooltip: 'Título',
          onPressed: _showHeadingMenu,
        ),
        _buildToolbarButton(
          icon: PhosphorIcons.list(),
          tooltip: 'Lista',
          onPressed: _showListMenu,
        ),
        _buildToolbarButton(
          icon: PhosphorIcons.checkSquare(),
          tooltip: 'Tarefa',
          onPressed: _insertTask,
        ),
        _buildToolbarButton(
          icon: PhosphorIcons.table(),
          tooltip: 'Tabela',
          onPressed: _insertTable,
        ),
        _buildToolbarButton(
          icon: PhosphorIcons.image(),
          tooltip: 'Imagem',
          onPressed: _insertImage,
        ),
        _buildToolbarButton(
          icon: PhosphorIcons.code(),
          tooltip: 'Código',
          onPressed: _insertCodeBlock,
        ),
        _buildToolbarButton(
          icon: PhosphorIcons.plus(),
          tooltip: 'Mais blocos',
          onPressed: _showInsertMenuAction,
        ),
      ],
    );
  }

  Widget _buildBlockActionsGroup() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildToolbarButton(
          icon: PhosphorIcons.arrowUp(),
          tooltip: 'Mover para cima',
          onPressed: _moveBlockUp,
        ),
        _buildToolbarButton(
          icon: PhosphorIcons.arrowDown(),
          tooltip: 'Mover para baixo',
          onPressed: _moveBlockDown,
        ),
        _buildToolbarButton(
          icon: PhosphorIcons.copy(),
          tooltip: 'Duplicar',
          onPressed: _duplicateBlock,
        ),
        _buildToolbarButton(
          icon: PhosphorIcons.trash(),
          tooltip: 'Excluir',
          onPressed: _deleteBlock,
        ),
      ],
    );
  }

  Widget _buildExtraActionsGroup() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildToolbarButton(
          icon: PhosphorIcons.magnifyingGlass(),
          tooltip: 'Buscar',
          onPressed: _searchContent,
        ),
        _buildToolbarButton(
          icon: PhosphorIcons.eye(),
          tooltip: 'Visualizar',
          onPressed: _togglePreview,
        ),
        _buildToolbarButton(
          icon: PhosphorIcons.dotsThreeVertical(),
          tooltip: 'Mais opções',
          onPressed: _showMoreOptionsAction,
        ),
      ],
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool isToggleable = false,
    bool isActive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 18,
            color: isActive && isToggleable
                ? Theme.of(context).primaryColor
                : null,
          ),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: const EdgeInsets.all(4),
          style: IconButton.styleFrom(
            backgroundColor: isActive && isToggleable
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider({bool isVertical = false}) {
    return Container(
      width: isVertical ? 1 : 16,
      height: isVertical ? 24 : 1,
      margin: EdgeInsets.symmetric(
        horizontal: isVertical ? 4 : 0,
        vertical: isVertical ? 0 : 4,
      ),
      color: widget.isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }

  // Formatação de texto
  void _formatText(String format) {
    ref.read(editorControllerProvider.notifier).formatText(format);
    widget.onToggleFormat?.call();
  }

  bool _isFormatActive(String format) {
    // TODO: Implementar verificação de formatação ativa
    return false;
  }

  void _insertLink() {
    // TODO: Implementar inserção de link
  }

  // Inserção de blocos
  void _showHeadingMenu() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 100, 100),
      items: [
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(PhosphorIcons.textH()),
              const SizedBox(width: 8),
              const Text('Título 1'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(PhosphorIcons.textH()),
              const SizedBox(width: 8),
              const Text('Título 2'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: [
              Icon(PhosphorIcons.textH()),
              const SizedBox(width: 8),
              const Text('Título 3'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        ref.read(editorControllerProvider.notifier).insertHeading(value);
      }
    });
  }

  void _showListMenu() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 100, 100),
      items: [
        PopupMenuItem(
          value: 'bullet',
          child: Row(
            children: [
              Icon(PhosphorIcons.list()),
              const SizedBox(width: 8),
              const Text('Lista com marcadores'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'numbered',
          child: Row(
            children: [
              Icon(PhosphorIcons.listNumbers()),
              const SizedBox(width: 8),
              const Text('Lista numerada'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'bullet') {
        ref.read(editorControllerProvider.notifier).insertBulletList();
      } else if (value == 'numbered') {
        ref.read(editorControllerProvider.notifier).insertNumberedList();
      }
    });
  }

  void _insertTask() {
    ref.read(editorControllerProvider.notifier).insertTask();
  }

  void _insertTable() {
    // TODO: Implementar inserção de tabela
  }

  void _insertImage() {
    // TODO: Implementar inserção de imagem
  }

  void _insertCodeBlock() {
    // TODO: Implementar inserção de bloco de código
  }

  void _showInsertMenuAction() {
    showModalBottomSheet(
      context: context,
      builder: (context) => BlocoMenuWidget(
        onBlockSelected: (bloco) {
          widget.onBlockInsert?.call(bloco);
          Navigator.of(context).pop();
        },
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  // Ações de bloco
  void _moveBlockUp() {
    // TODO: Implementar mover bloco para cima
  }

  void _moveBlockDown() {
    // TODO: Implementar mover bloco para baixo
  }

  void _duplicateBlock() {
    // TODO: Implementar duplicar bloco
  }

  void _deleteBlock() {
    // TODO: Implementar excluir bloco
  }

  // Ações extras
  void _searchContent() {
    // TODO: Implementar busca
  }

  void _togglePreview() {
    // TODO: Implementar alternar preview
  }

  void _showMoreOptionsAction() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 100, 100),
      items: [
        PopupMenuItem(
          value: 'export',
          child: Row(
            children: [
              Icon(PhosphorIcons.export()),
              const SizedBox(width: 8),
              const Text('Exportar'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(PhosphorIcons.share()),
              const SizedBox(width: 8),
              const Text('Compartilhar'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(PhosphorIcons.gear()),
              const SizedBox(width: 8),
              const Text('Configurações'),
            ],
          ),
        ),
      ],
    ).then((value) {
      // TODO: Implementar ações do menu
    });
  }
}

/// Widget de toolbar compacto para uso em contextos específicos
class CompactBlocoToolbar extends ConsumerWidget {
  final List<ToolbarAction> actions;
  final bool isDarkMode;
  final EdgeInsets? padding;

  const CompactBlocoToolbar({
    super.key,
    required this.actions,
    required this.isDarkMode,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: actions
            .map((action) => _buildActionButton(context, action))
            .toList(),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, ToolbarAction action) {
    return Tooltip(
      message: action.tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: action.onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color:
                  action.isActive ? AppColors.primary.withOpacity(0.15) : null,
            ),
            child: Icon(
              action.icon,
              size: 16,
              color: action.isActive
                  ? AppColors.primary
                  : isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Classe para definir ações da toolbar compacta
class ToolbarAction {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isActive;

  const ToolbarAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isActive = false,
  });
}

// Dialog Widgets

class _LinkInsertDialog extends StatefulWidget {
  final Function(String url, String text) onInsert;

  const _LinkInsertDialog({required this.onInsert});

  @override
  State<_LinkInsertDialog> createState() => _LinkInsertDialogState();
}

class _LinkInsertDialogState extends State<_LinkInsertDialog> {
  final _urlController = TextEditingController();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Inserir Link'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL',
              hintText: 'https://exemplo.com',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Texto do link (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final url = _urlController.text.trim();
            final text = _textController.text.trim();

            if (url.isNotEmpty) {
              widget.onInsert(url, text.isEmpty ? url : text);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Inserir'),
        ),
      ],
    );
  }
}

class _TableInsertDialog extends StatefulWidget {
  final Function(int rows, int columns) onInsert;

  const _TableInsertDialog({required this.onInsert});

  @override
  State<_TableInsertDialog> createState() => _TableInsertDialogState();
}

class _TableInsertDialogState extends State<_TableInsertDialog> {
  int _rows = 3;
  int _columns = 3;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Inserir Tabela'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Linhas'),
                    Slider(
                      value: _rows.toDouble(),
                      min: 2,
                      max: 10,
                      divisions: 8,
                      label: _rows.toString(),
                      onChanged: (value) {
                        setState(() {
                          _rows = value.round();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Colunas'),
                    Slider(
                      value: _columns.toDouble(),
                      min: 2,
                      max: 8,
                      divisions: 6,
                      label: _columns.toString(),
                      onChanged: (value) {
                        setState(() {
                          _columns = value.round();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Tabela: $_rows × $_columns'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onInsert(_rows, _columns);
            Navigator.of(context).pop();
          },
          child: const Text('Inserir'),
        ),
      ],
    );
  }
}

class _ImageInsertDialog extends StatefulWidget {
  final Function(String url, String alt) onInsert;

  const _ImageInsertDialog({required this.onInsert});

  @override
  State<_ImageInsertDialog> createState() => _ImageInsertDialogState();
}

class _ImageInsertDialogState extends State<_ImageInsertDialog> {
  final _urlController = TextEditingController();
  final _altController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _altController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Inserir Imagem'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL da Imagem',
              hintText: 'https://exemplo.com/imagem.jpg',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _altController,
            decoration: const InputDecoration(
              labelText: 'Texto Alternativo',
              hintText: 'Descrição da imagem',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final url = _urlController.text.trim();
            final alt = _altController.text.trim();

            if (url.isNotEmpty) {
              widget.onInsert(url, alt);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Inserir'),
        ),
      ],
    );
  }
}

class _VideoInsertDialog extends StatefulWidget {
  final Function(String url) onInsert;

  const _VideoInsertDialog({required this.onInsert});

  @override
  State<_VideoInsertDialog> createState() => _VideoInsertDialogState();
}

class _VideoInsertDialogState extends State<_VideoInsertDialog> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Inserir Vídeo'),
      content: TextField(
        controller: _urlController,
        decoration: const InputDecoration(
          labelText: 'URL do Vídeo',
          hintText: 'https://youtube.com/watch?v=...',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.url,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final url = _urlController.text.trim();

            if (url.isNotEmpty) {
              widget.onInsert(url);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Inserir'),
        ),
      ],
    );
  }
}

/// Extensões para facilitar uso
extension BlocoToolbarExtension on WidgetRef {
  /// Obter ações rápidas de toolbar
  List<ToolbarAction> getQuickActions() {
    return [
      ToolbarAction(
        icon: PhosphorIcons.textB(),
        tooltip: 'Negrito',
        onPressed: () {},
      ),
      ToolbarAction(
        icon: PhosphorIcons.textItalic(),
        tooltip: 'Itálico',
        onPressed: () {},
      ),
      ToolbarAction(
        icon: PhosphorIcons.link(),
        tooltip: 'Link',
        onPressed: () {},
      ),
    ];
  }
}
