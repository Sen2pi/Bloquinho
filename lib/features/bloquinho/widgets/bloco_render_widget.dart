import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/bloco_base_model.dart';
import '../models/bloco_tipo_enum.dart';
import '../providers/blocos_provider.dart';
import '../providers/editor_controller_provider.dart';
import '../widgets/bloco_block_widgets.dart';
import '../widgets/bloco_menu_widget.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';

/// Widget principal para renderizar e gerenciar uma lista de blocos
class BlocoRenderWidget extends ConsumerStatefulWidget {
  final String? documentId;
  final bool isReadOnly;
  final Function(BlocoBase)? onBlockAdded;
  final Function(BlocoBase)? onBlockUpdated;
  final Function(String)? onBlockDeleted;
  final Function(List<String>)? onSelectionChanged;
  final EdgeInsets? padding;
  final bool showLineNumbers;
  final bool showBlockHandles;
  final bool enableDragAndDrop;
  final double blockSpacing;

  const BlocoRenderWidget({
    super.key,
    this.documentId,
    this.isReadOnly = false,
    this.onBlockAdded,
    this.onBlockUpdated,
    this.onBlockDeleted,
    this.onSelectionChanged,
    this.padding,
    this.showLineNumbers = false,
    this.showBlockHandles = true,
    this.enableDragAndDrop = true,
    this.blockSpacing = 8.0,
  });

  @override
  ConsumerState<BlocoRenderWidget> createState() => _BlocoRenderWidgetState();
}

class _BlocoRenderWidgetState extends ConsumerState<BlocoRenderWidget> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _containerFocusNode = FocusNode();

  Set<String> _selectedBlockIds = {};
  String? _focusedBlockId;
  bool _isMultiSelecting = false;
  bool _isDragging = false;
  int? _dragOverIndex;
  int? _insertIndex;

  // Menu "/" state
  bool _showSlashMenu = false;
  Offset? _slashMenuPosition;
  String? _slashMenuTriggerBlockId;
  String _slashMenuQuery = '';

  @override
  void initState() {
    super.initState();
    _containerFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _containerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final blocosState = ref.watch(blocosProvider);
    final blocos = blocosState.filteredBlocos;

    return Container(
      padding: widget.padding ?? const EdgeInsets.all(16),
      child: Focus(
        focusNode: _containerFocusNode,
        onKeyEvent: _handleKeyEvent,
        child: GestureDetector(
          onTap: () => _clearSelection(),
          child: Stack(
            children: [
              // Lista principal de blocos
              _buildBlocksList(isDarkMode, blocos),

              // Menu "/" flutuante
              if (_showSlashMenu) _buildSlashMenu(isDarkMode),

              // Indicador de inserção durante drag
              if (_insertIndex != null) _buildInsertionIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlocksList(bool isDarkMode, List<BlocoBase> blocos) {
    if (blocos.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return ReorderableListView.builder(
      scrollController: _scrollController,
      onReorder: (oldIndex, newIndex) {
        if (widget.enableDragAndDrop) {
          _handleReorder(oldIndex, newIndex);
        }
      },
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: blocos.length,
      itemBuilder: (context, index) {
        final bloco = blocos[index];
        final isSelected = _selectedBlockIds.contains(bloco.id);
        final isFocused = _focusedBlockId == bloco.id;

        return _buildBlockContainer(
          key: ValueKey(bloco.id),
          bloco: bloco,
          index: index,
          isSelected: isSelected,
          isFocused: isFocused,
          isDarkMode: isDarkMode,
        );
      },
    );
  }

  Widget _buildBlockContainer({
    required Key key,
    required BlocoBase bloco,
    required int index,
    required bool isSelected,
    required bool isFocused,
    required bool isDarkMode,
  }) {
    return Container(
      key: key,
      margin: EdgeInsets.only(bottom: widget.blockSpacing),
      child: DragTarget<String>(
        onWillAcceptWithDetails: (details) {
          if (!widget.enableDragAndDrop) return false;
          setState(() {
            _dragOverIndex = index;
          });
          return true;
        },
        onLeave: (_) {
          setState(() {
            _dragOverIndex = null;
          });
        },
        onAcceptWithDetails: (details) {
          _handleDropOnBlock(details.data, index);
        },
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: _dragOverIndex == index
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Numeração de linha (opcional)
                if (widget.showLineNumbers)
                  _buildLineNumber(index + 1, isDarkMode),

                // Handle de drag (opcional)
                if (widget.showBlockHandles && !widget.isReadOnly)
                  _buildDragHandle(bloco, isDarkMode),

                // Conteúdo do bloco
                Expanded(
                  child: _buildBlockContent(
                    bloco: bloco,
                    index: index,
                    isSelected: isSelected,
                    isFocused: isFocused,
                    isDarkMode: isDarkMode,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLineNumber(int lineNumber, bool isDarkMode) {
    return Container(
      width: 40,
      padding: const EdgeInsets.only(right: 8, top: 12),
      child: Text(
        '$lineNumber',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
          fontFamily: 'Courier',
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _buildDragHandle(BlocoBase bloco, bool isDarkMode) {
    return Draggable<String>(
      data: bloco.id,
      onDragStarted: () {
        setState(() {
          _isDragging = true;
        });
      },
      onDragEnd: (_) {
        setState(() {
          _isDragging = false;
          _dragOverIndex = null;
        });
      },
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getBlockPreview(bloco),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      child: Container(
        width: 24,
        padding: const EdgeInsets.only(right: 8, top: 8),
        child: Icon(
          PhosphorIcons.dotsSixVertical(),
          size: 16,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildBlockContent({
    required BlocoBase bloco,
    required int index,
    required bool isSelected,
    required bool isFocused,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: () => _handleBlockTap(bloco.id, index),
      onLongPress: () => _handleBlockLongPress(bloco.id),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : isFocused
                  ? (isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.05))
                  : Colors.transparent,
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1)
              : isFocused
                  ? Border.all(
                      color: AppColors.primary.withOpacity(0.3), width: 1)
                  : null,
        ),
        child: Stack(
          children: [
            // Widget do bloco
            BlocoWidget(
              bloco: bloco,
              isSelected: isSelected,
              isEditable: !widget.isReadOnly,
              onTap: () => _handleBlockTap(bloco.id, index),
              onLongPress: () => _handleBlockLongPress(bloco.id),
              onUpdated: (updatedBloco) => _handleBlockUpdated(updatedBloco),
              onDelete: () => _handleBlockDeleted(bloco.id),
            ),

            // Overlay para capturar eventos de teclado
            if (isFocused)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    // Manter foco no bloco
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.note(),
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum bloco criado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Digite "/" para inserir um bloco ou clique no botão +',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (!widget.isReadOnly)
            ElevatedButton.icon(
              onPressed: _showAddBlockMenu,
              icon: Icon(PhosphorIcons.plus()),
              label: const Text('Adicionar Bloco'),
            ),
        ],
      ),
    );
  }

  Widget _buildSlashMenu(bool isDarkMode) {
    if (_slashMenuPosition == null) return const SizedBox();

    return Positioned(
      left: _slashMenuPosition!.dx,
      top: _slashMenuPosition!.dy,
      child: BlocoMenuWidget(
        searchQuery: _slashMenuQuery,
        onBlockSelected: _handleSlashMenuBlockSelected,
        onDismiss: _hideSlashMenu,
      ),
    );
  }

  Widget _buildInsertionIndicator() {
    return Positioned(
      left: 0,
      right: 0,
      top: (_insertIndex ?? 0) * (48 + widget.blockSpacing) - 2,
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // Event Handlers

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // Atalhos globais
    if (HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.keyA:
          _selectAllBlocks();
          return KeyEventResult.handled;

        case LogicalKeyboardKey.keyC:
          _copySelectedBlocks();
          return KeyEventResult.handled;

        case LogicalKeyboardKey.keyV:
          _pasteBlocks();
          return KeyEventResult.handled;

        case LogicalKeyboardKey.keyZ:
          if (HardwareKeyboard.instance.isShiftPressed) {
            _redo();
          } else {
            _undo();
          }
          return KeyEventResult.handled;
      }
    }

    // Navegação entre blocos
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        _navigateToBlock(-1);
        return KeyEventResult.handled;

      case LogicalKeyboardKey.arrowDown:
        _navigateToBlock(1);
        return KeyEventResult.handled;

      case LogicalKeyboardKey.enter:
        if (_focusedBlockId != null) {
          _insertBlockAfter(_focusedBlockId!);
        }
        return KeyEventResult.handled;

      case LogicalKeyboardKey.delete:
      case LogicalKeyboardKey.backspace:
        if (_selectedBlockIds.isNotEmpty) {
          _deleteSelectedBlocks();
          return KeyEventResult.handled;
        }
        break;

      case LogicalKeyboardKey.slash:
        if (_focusedBlockId != null) {
          _showSlashMenuForBlock(_focusedBlockId!);
          return KeyEventResult.handled;
        }
        break;

      case LogicalKeyboardKey.escape:
        _clearSelection();
        _hideSlashMenu();
        return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _handleBlockTap(String blockId, int index) {
    if (HardwareKeyboard.instance.isShiftPressed) {
      _handleShiftClick(blockId);
    } else if (HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed) {
      _toggleBlockSelection(blockId);
    } else {
      _selectSingleBlock(blockId);
    }

    _setFocusedBlock(blockId);
  }

  void _handleBlockLongPress(String blockId) {
    if (!_selectedBlockIds.contains(blockId)) {
      _selectSingleBlock(blockId);
    }
    _showBlockContextMenu(blockId);
  }

  void _handleBlockUpdated(BlocoBase updatedBloco) {
    ref
        .read(blocosProvider.notifier)
        .updateBloco(updatedBloco.id, updatedBloco);
    widget.onBlockUpdated?.call(updatedBloco);
  }

  void _handleBlockDeleted(String blockId) {
    ref.read(blocosProvider.notifier).removeBloco(blockId);
    _selectedBlockIds.remove(blockId);
    if (_focusedBlockId == blockId) {
      _focusedBlockId = null;
    }
    widget.onBlockDeleted?.call(blockId);
    _updateSelectionCallback();
  }

  void _handleReorder(int oldIndex, int newIndex) {
    ref.read(blocosProvider.notifier).reorderBlocos(oldIndex, newIndex);
  }

  void _handleDropOnBlock(String draggedBlockId, int targetIndex) {
    final blocos = ref.read(blocosProvider).blocos;
    final draggedIndex = blocos.indexWhere((b) => b.id == draggedBlockId);

    if (draggedIndex != -1 && draggedIndex != targetIndex) {
      _handleReorder(draggedIndex, targetIndex);
    }

    setState(() {
      _dragOverIndex = null;
      _insertIndex = null;
    });
  }

  void _handleSlashMenuBlockSelected(BlocoBase newBloco) {
    if (_slashMenuTriggerBlockId != null) {
      final blocos = ref.read(blocosProvider).blocos;
      final triggerIndex =
          blocos.indexWhere((b) => b.id == _slashMenuTriggerBlockId);

      if (triggerIndex != -1) {
        ref
            .read(blocosProvider.notifier)
            .insertBloco(triggerIndex + 1, newBloco);
        widget.onBlockAdded?.call(newBloco);
      }
    } else {
      ref.read(blocosProvider.notifier).addBloco(newBloco);
      widget.onBlockAdded?.call(newBloco);
    }

    _hideSlashMenu();
    _setFocusedBlock(newBloco.id);
  }

  // Selection Management

  void _selectSingleBlock(String blockId) {
    setState(() {
      _selectedBlockIds = {blockId};
    });
    _updateSelectionCallback();
  }

  void _toggleBlockSelection(String blockId) {
    setState(() {
      if (_selectedBlockIds.contains(blockId)) {
        _selectedBlockIds.remove(blockId);
      } else {
        _selectedBlockIds.add(blockId);
      }
    });
    _updateSelectionCallback();
  }

  void _handleShiftClick(String blockId) {
    if (_selectedBlockIds.isEmpty) {
      _selectSingleBlock(blockId);
      return;
    }

    final blocos = ref.read(blocosProvider).blocos;
    final clickedIndex = blocos.indexWhere((b) => b.id == blockId);
    final lastSelectedId = _selectedBlockIds.last;
    final lastSelectedIndex = blocos.indexWhere((b) => b.id == lastSelectedId);

    if (clickedIndex != -1 && lastSelectedIndex != -1) {
      final startIndex =
          clickedIndex < lastSelectedIndex ? clickedIndex : lastSelectedIndex;
      final endIndex =
          clickedIndex > lastSelectedIndex ? clickedIndex : lastSelectedIndex;

      setState(() {
        _selectedBlockIds
            .addAll(blocos.sublist(startIndex, endIndex + 1).map((b) => b.id));
      });
      _updateSelectionCallback();
    }
  }

  void _selectAllBlocks() {
    final blocos = ref.read(blocosProvider).blocos;
    setState(() {
      _selectedBlockIds = blocos.map((b) => b.id).toSet();
    });
    _updateSelectionCallback();
  }

  void _clearSelection() {
    setState(() {
      _selectedBlockIds.clear();
      _focusedBlockId = null;
    });
    _updateSelectionCallback();
  }

  void _setFocusedBlock(String blockId) {
    setState(() {
      _focusedBlockId = blockId;
    });
  }

  void _updateSelectionCallback() {
    widget.onSelectionChanged?.call(_selectedBlockIds.toList());
  }

  // Navigation

  void _navigateToBlock(int direction) {
    final blocos = ref.read(blocosProvider).blocos;
    if (blocos.isEmpty) return;

    int newIndex;
    if (_focusedBlockId == null) {
      newIndex = direction > 0 ? 0 : blocos.length - 1;
    } else {
      final currentIndex = blocos.indexWhere((b) => b.id == _focusedBlockId);
      newIndex = (currentIndex + direction).clamp(0, blocos.length - 1);
    }

    final newBlockId = blocos[newIndex].id;
    _setFocusedBlock(newBlockId);
    _selectSingleBlock(newBlockId);

    // Scroll para o bloco se necessário
    _scrollToBlock(newIndex);
  }

  void _scrollToBlock(int index) {
    final blockHeight = 48 + widget.blockSpacing;
    final targetOffset = index * blockHeight;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  // Slash Menu

  void _showSlashMenuForBlock(String blockId) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    setState(() {
      _slashMenuTriggerBlockId = blockId;
      _slashMenuPosition = const Offset(100, 100); // Posição básica
      _slashMenuQuery = '';
      _showSlashMenu = true;
    });
  }

  void _showAddBlockMenu() {
    showBlocoMenuModal(
      context,
      onBlockSelected: (bloco) {
        ref.read(blocosProvider.notifier).addBloco(bloco);
        widget.onBlockAdded?.call(bloco);
        _setFocusedBlock(bloco.id);
      },
    );
  }

  void _hideSlashMenu() {
    setState(() {
      _showSlashMenu = false;
      _slashMenuPosition = null;
      _slashMenuTriggerBlockId = null;
      _slashMenuQuery = '';
    });
  }

  // Block Operations

  void _insertBlockAfter(String blockId) {
    final blocos = ref.read(blocosProvider).blocos;
    final index = blocos.indexWhere((b) => b.id == blockId);

    if (index != -1) {
      _showSlashMenuForBlock(blockId);
    }
  }

  void _copySelectedBlocks() {
    if (_selectedBlockIds.isEmpty) return;

    final blocos = ref.read(blocosProvider).blocos;
    final selectedBlocks =
        blocos.where((b) => _selectedBlockIds.contains(b.id)).toList();

    // Converter para texto ou JSON para clipboard
    final text = selectedBlocks.map((b) => _getBlockText(b)).join('\n\n');
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${selectedBlocks.length} bloco(s) copiado(s)')),
    );
  }

  Future<void> _pasteBlocks() async {
    await ref.read(blocosProvider.notifier).pasteFromClipboard();
  }

  void _deleteSelectedBlocks() {
    if (_selectedBlockIds.isEmpty) return;

    ref.read(blocosProvider.notifier).removeBlocos(_selectedBlockIds.toList());

    for (final blockId in _selectedBlockIds) {
      widget.onBlockDeleted?.call(blockId);
    }

    _clearSelection();
  }

  void _undo() {
    ref.read(blocosProvider.notifier).undo();
  }

  void _redo() {
    ref.read(blocosProvider.notifier).redo();
  }

  // Context Menu

  void _showBlockContextMenu(String blockId) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem<String>(
          value: 'duplicate',
          child: Row(
            children: [
              Icon(PhosphorIcons.copy()),
              const SizedBox(width: 8),
              const Text('Duplicar'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'copy',
          child: Row(
            children: [
              Icon(PhosphorIcons.clipboard()),
              const SizedBox(width: 8),
              const Text('Copiar'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(PhosphorIcons.trash(), color: Colors.red),
              const SizedBox(width: 8),
              const Text('Excluir', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _handleContextMenuAction(value, blockId);
      }
    });
  }

  void _handleContextMenuAction(String action, String blockId) {
    switch (action) {
      case 'duplicate':
        ref.read(blocosProvider.notifier).duplicateBloco(blockId);
        break;
      case 'copy':
        _selectSingleBlock(blockId);
        _copySelectedBlocks();
        break;
      case 'delete':
        _handleBlockDeleted(blockId);
        break;
    }
  }

  // Utility Methods

  String _getBlockPreview(BlocoBase bloco) {
    switch (bloco.tipo) {
      case BlocoTipo.texto:
        return (bloco as BlocoTexto).conteudo;
      case BlocoTipo.titulo:
        return (bloco as BlocoTitulo).conteudo;
      case BlocoTipo.codigo:
        return 'Código: ${(bloco as BlocoCodigo).linguagem}';
      case BlocoTipo.tabela:
        return 'Tabela (${(bloco as BlocoTabela).cabecalhos.length} colunas)';
      default:
        return bloco.tipo.toString();
    }
  }

  String _getBlockText(BlocoBase bloco) {
    switch (bloco.tipo) {
      case BlocoTipo.texto:
        return (bloco as BlocoTexto).conteudo;
      case BlocoTipo.titulo:
        final titulo = bloco as BlocoTitulo;
        return '${'#' * titulo.nivel} ${titulo.conteudo}';
      case BlocoTipo.lista:
        final lista = bloco as BlocoLista;
        return lista.itens.map((item) => '- $item').join('\n');
      case BlocoTipo.codigo:
        final codigo = bloco as BlocoCodigo;
        return '``````';
      default:
        return bloco.toString();
    }
  }
}

/// Widget compacto para renderizar blocos sem funcionalidades de edição
class CompactBlocoRenderWidget extends ConsumerWidget {
  final List<BlocoBase> blocos;
  final bool showLineNumbers;
  final EdgeInsets? padding;

  const CompactBlocoRenderWidget({
    super.key,
    required this.blocos,
    this.showLineNumbers = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: ListView.separated(
        itemCount: blocos.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final bloco = blocos[index];

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showLineNumbers)
                Container(
                  width: 40,
                  padding: const EdgeInsets.only(right: 8, top: 4),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontFamily: 'Courier',
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              Expanded(
                child: BlocoWidget(
                  bloco: bloco,
                  isSelected: false,
                  isEditable: false,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Extensões para facilitar uso
extension BlocoRenderWidgetExtension on WidgetRef {
  /// Renderizar blocos em um widget
  Widget renderBlocos(
    List<BlocoBase> blocos, {
    bool isReadOnly = false,
    bool showLineNumbers = false,
    EdgeInsets? padding,
  }) {
    if (blocos.isEmpty) {
      return const Center(
        child: Text('Nenhum bloco para exibir'),
      );
    }

    if (isReadOnly) {
      return CompactBlocoRenderWidget(
        blocos: blocos,
        showLineNumbers: showLineNumbers,
        padding: padding,
      );
    }

    return BlocoRenderWidget(
      isReadOnly: isReadOnly,
      showLineNumbers: showLineNumbers,
      padding: padding,
    );
  }
}
