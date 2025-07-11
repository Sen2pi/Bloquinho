import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/bloco_base_model.dart';
import '../models/bloco_tipo_enum.dart';
import '../providers/blocos_provider.dart';
import '../providers/editor_controller_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';

/// Widget principal para renderizar qualquer tipo de bloco
class BlocoWidget extends ConsumerWidget {
  final BlocoBase bloco;
  final bool isSelected;
  final bool isEditable;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(BlocoBase)? onUpdated;
  final VoidCallback? onDelete;

  const BlocoWidget({
    super.key,
    required this.bloco,
    this.isSelected = false,
    this.isEditable = true,
    this.onTap,
    this.onLongPress,
    this.onUpdated,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border:
            isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle para drag (se editável)
              if (isEditable) _buildDragHandle(isDarkMode),

              // Conteúdo do bloco
              Expanded(
                child: _buildBlocoContent(context, ref, isDarkMode),
              ),

              // Menu de ações
              if (isEditable) _buildActionMenu(context, ref, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle(bool isDarkMode) {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(right: 8, top: 4),
      child: Icon(
        PhosphorIcons.dotsSixVertical(),
        size: 16,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildBlocoContent(
      BuildContext context, WidgetRef ref, bool isDarkMode) {
    switch (bloco.tipo) {
      case BlocoTipo.texto:
        return BlocoTextoWidget(
          bloco: bloco as BlocoTexto,
          isEditable: isEditable,
          onUpdated: onUpdated,
        );

      case BlocoTipo.titulo:
        return BlocoTituloWidget(
          bloco: bloco as BlocoTitulo,
          isEditable: isEditable,
          onUpdated: onUpdated,
        );

      case BlocoTipo.lista:
        return BlocoListaWidget(
          bloco: bloco as BlocoLista,
          isEditable: isEditable,
          onUpdated: onUpdated,
        );

      case BlocoTipo.listaNumerada:
        return BlocoListaNumeradaWidget(
          bloco: bloco as BlocoListaNumerada,
          isEditable: isEditable,
          onUpdated: onUpdated,
        );

      case BlocoTipo.tarefa:
        return BlocoTarefaWidget(
          bloco: bloco as BlocoTarefa,
          isEditable: isEditable,
          onUpdated: onUpdated,
        );

      case BlocoTipo.tabela:
        return BlocoTabelaWidget(
          bloco: bloco as BlocoTabela,
          isEditable: isEditable,
          onUpdated: onUpdated,
        );

      case BlocoTipo.codigo:
        return BlocoCodigoWidget(
          bloco: bloco as BlocoCodigo,
          isEditable: isEditable,
          onUpdated: onUpdated,
        );

      case BlocoTipo.equacao:
        return BlocoEquacaoWidget(
          bloco: bloco as BlocoEquacao,
          isEditable: isEditable,
          onUpdated: onUpdated,
        );

      case BlocoTipo.imagem:
        return BlocoImagemWidget(
          bloco: bloco as BlocoImagem,
          isEditable: isEditable,
          onUpdated: onUpdated,
        );

      case BlocoTipo.video:
        return BlocoVideoWidget(
          bloco: bloco as BlocoVideo,
          isEditable: isEditable,
          onUpdated: onUpdated,
        );

      case BlocoTipo.link:
        return BlocoLinkWidget(
          bloco: bloco as BlocoLink,
          isEditable: isEditable,
          onUpdated: onUpdated,
        );

      case BlocoTipo.divisor:
        return BlocoDivisorWidget(
          bloco: bloco as BlocoDivisor,
          isEditable: isEditable,
          onUpdated: onUpdated,
        );

      case BlocoTipo.coluna:
        return BlocoColunaWidget(
          bloco: bloco as BlocoColuna,
          isEditable: isEditable,
          onUpdated: onUpdated,
        );

      case BlocoTipo.baseDados:
        return BlocoBaseDadosWidget(
          bloco: bloco as BlocoBaseDados,
          isEditable: isEditable,
          onUpdated: onUpdated,
        );

      case BlocoTipo.wiki:
        return BlocoWikiWidget(
          bloco: bloco as BlocoWiki,
          isEditable: isEditable,
          onUpdated: onUpdated,
        );

      case BlocoTipo.pagina:
        return BlocoPaginaWidget(
          bloco: bloco as BlocoPagina,
          isEditable: isEditable,
          onUpdated: onUpdated,
        );

      case BlocoTipo.blocoSincronizado:
        return BlocoBlocoSincronizadoWidget(
          bloco: bloco as BlocoBlocoSincronizado,
          isEditable: isEditable,
          onUpdated: onUpdated,
        );

      default:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Tipo de bloco não suportado: ${bloco.tipo}',
            style: const TextStyle(color: Colors.red),
          ),
        );
    }
  }

  Widget _buildActionMenu(
      BuildContext context, WidgetRef ref, bool isDarkMode) {
    return PopupMenuButton<String>(
      onSelected: (action) => _handleAction(context, ref, action),
      icon: Icon(
        PhosphorIcons.dotsThreeVertical(),
        size: 16,
        color: Colors.grey[400],
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              Icon(PhosphorIcons.copy()),
              const SizedBox(width: 8),
              const Text('Duplicar'),
            ],
          ),
        ),
        PopupMenuItem(
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
        PopupMenuItem(
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
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'duplicate':
        ref.read(blocosProvider.notifier).duplicateBloco(bloco.id);
        break;
      case 'copy':
        Clipboard.setData(ClipboardData(text: _getBlocoText()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bloco copiado')),
        );
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }

  String _getBlocoText() {
    switch (bloco.tipo) {
      case BlocoTipo.texto:
        return (bloco as BlocoTexto).conteudo;
      case BlocoTipo.titulo:
        return (bloco as BlocoTitulo).conteudo;
      case BlocoTipo.codigo:
        return (bloco as BlocoCodigo).codigo;
      default:
        return bloco.toString();
    }
  }
}

/// Widget para bloco de texto
class BlocoTextoWidget extends StatefulWidget {
  final BlocoTexto bloco;
  final bool isEditable;
  final Function(BlocoBase)? onUpdated;

  const BlocoTextoWidget({
    super.key,
    required this.bloco,
    this.isEditable = true,
    this.onUpdated,
  });

  @override
  State<BlocoTextoWidget> createState() => _BlocoTextoWidgetState();
}

class _BlocoTextoWidgetState extends State<BlocoTextoWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.bloco.conteudo);
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _saveChanges();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_controller.text != widget.bloco.conteudo) {
      final updatedBloco = BlocoTexto(
        id: widget.bloco.id,
        conteudo: _controller.text,
        formatacao: widget.bloco.formatacao,
      );
      widget.onUpdated?.call(updatedBloco);
    }
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEditable) {
      return _buildReadOnlyView();
    }

    return _isEditing ? _buildEditingView() : _buildReadOnlyView();
  }

  Widget _buildReadOnlyView() {
    return GestureDetector(
      onTap: widget.isEditable
          ? () {
              setState(() {
                _isEditing = true;
              });
              Future.delayed(const Duration(milliseconds: 100), () {
                _focusNode.requestFocus();
              });
            }
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: _isEditing
            ? BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(4),
              )
            : null,
        child: Text(
          widget.bloco.conteudo.isEmpty
              ? 'Clique para editar...'
              : widget.bloco.conteudo,
          style: TextStyle(
            color: widget.bloco.conteudo.isEmpty ? Colors.grey : null,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildEditingView() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      maxLines: null,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _saveChanges(),
      style: const TextStyle(
        fontSize: 16,
        height: 1.5,
      ),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Digite seu texto...',
        contentPadding: EdgeInsets.all(12),
      ),
    );
  }
}

/// Widget para bloco de título
class BlocoTituloWidget extends StatefulWidget {
  final BlocoTitulo bloco;
  final bool isEditable;
  final Function(BlocoBase)? onUpdated;

  const BlocoTituloWidget({
    super.key,
    required this.bloco,
    this.isEditable = true,
    this.onUpdated,
  });

  @override
  State<BlocoTituloWidget> createState() => _BlocoTituloWidgetState();
}

class _BlocoTituloWidgetState extends State<BlocoTituloWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.bloco.conteudo);
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _saveChanges();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_controller.text != widget.bloco.conteudo) {
      final updatedBloco = BlocoTitulo(
        id: widget.bloco.id,
        conteudo: _controller.text,
        nivel: widget.bloco.nivel,
        formatacao: widget.bloco.formatacao,
      );
      widget.onUpdated?.call(updatedBloco);
    }
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = _getTextStyleForLevel(widget.bloco.nivel);

    if (!widget.isEditable) {
      return _buildReadOnlyView(textStyle);
    }

    return _isEditing
        ? _buildEditingView(textStyle)
        : _buildReadOnlyView(textStyle);
  }

  TextStyle _getTextStyleForLevel(int nivel) {
    switch (nivel) {
      case 1:
        return const TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
      case 2:
        return const TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
      case 3:
        return const TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
      case 4:
        return const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
      case 5:
        return const TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
      case 6:
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
      default:
        return const TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
    }
  }

  Widget _buildReadOnlyView(TextStyle textStyle) {
    return GestureDetector(
      onTap: widget.isEditable
          ? () {
              setState(() {
                _isEditing = true;
              });
              Future.delayed(const Duration(milliseconds: 100), () {
                _focusNode.requestFocus();
              });
            }
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            // Indicador de nível
            Container(
              width: 4,
              height: textStyle.fontSize! * 1.2,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.bloco.conteudo.isEmpty
                    ? 'Título ${widget.bloco.nivel}'
                    : widget.bloco.conteudo,
                style: textStyle.copyWith(
                  color: widget.bloco.conteudo.isEmpty ? Colors.grey : null,
                ),
              ),
            ),
            // Seletor de nível
            if (widget.isEditable)
              PopupMenuButton<int>(
                onSelected: (nivel) => _updateLevel(nivel),
                icon: Icon(
                  PhosphorIcons.textH(),
                  size: 16,
                  color: Colors.grey,
                ),
                itemBuilder: (context) => List.generate(6, (index) {
                  final nivel = index + 1;
                  return PopupMenuItem(
                    value: nivel,
                    child: Text('H$nivel'),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditingView(TextStyle textStyle) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _saveChanges(),
      style: textStyle,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Digite o título...',
        contentPadding: EdgeInsets.all(12),
      ),
    );
  }

  void _updateLevel(int novoNivel) {
    final updatedBloco = BlocoTitulo(
      id: widget.bloco.id,
      conteudo: widget.bloco.conteudo,
      nivel: novoNivel,
      formatacao: widget.bloco.formatacao,
    );
    widget.onUpdated?.call(updatedBloco);
  }
}

/// Widget para bloco de lista
class BlocoListaWidget extends StatefulWidget {
  final BlocoLista bloco;
  final bool isEditable;
  final Function(BlocoBase)? onUpdated;

  const BlocoListaWidget({
    super.key,
    required this.bloco,
    this.isEditable = true,
    this.onUpdated,
  });

  @override
  State<BlocoListaWidget> createState() => _BlocoListaWidgetState();
}

class _BlocoListaWidgetState extends State<BlocoListaWidget> {
  late List<String> _items;
  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.bloco.itens);
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers.clear();
    _focusNodes.clear();

    for (int i = 0; i < _items.length; i++) {
      _controllers.add(TextEditingController(text: _items[i]));
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add('');
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNodes.last.requestFocus();
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items.removeAt(index);
        _controllers[index].dispose();
        _focusNodes[index].dispose();
        _controllers.removeAt(index);
        _focusNodes.removeAt(index);
      });
      _saveChanges();
    }
  }

  void _saveChanges() {
    final updatedItems =
        _controllers.map((controller) => controller.text).toList();
    final updatedBloco = BlocoLista(
      id: widget.bloco.id,
      itens: updatedItems,
      estilo: widget.bloco.estilo,
      indentacao: widget.bloco.indentacao,
    );
    widget.onUpdated?.call(updatedBloco);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _items.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bullet point
                Container(
                  margin: const EdgeInsets.only(top: 12, right: 8),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    shape: BoxShape.circle,
                  ),
                ),
                // Item text
                Expanded(
                  child: widget.isEditable
                      ? TextField(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          onChanged: (_) => _saveChanges(),
                          onSubmitted: (_) {
                            if (i == _items.length - 1) {
                              _addItem();
                            } else {
                              _focusNodes[i + 1].requestFocus();
                            }
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Item da lista...',
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(_items[i]),
                        ),
                ),
                // Remove button
                if (widget.isEditable && _items.length > 1)
                  IconButton(
                    onPressed: () => _removeItem(i),
                    icon: Icon(PhosphorIcons.x(), size: 16),
                    iconSize: 16,
                    constraints:
                        const BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
              ],
            ),
          ),

        // Add item button
        if (widget.isEditable)
          TextButton.icon(
            onPressed: _addItem,
            icon: Icon(PhosphorIcons.plus(), size: 16),
            label: const Text('Adicionar item'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
      ],
    );
  }
}

/// Widget para bloco de lista numerada
class BlocoListaNumeradaWidget extends StatefulWidget {
  final BlocoListaNumerada bloco;
  final bool isEditable;
  final Function(BlocoBase)? onUpdated;

  const BlocoListaNumeradaWidget({
    super.key,
    required this.bloco,
    this.isEditable = true,
    this.onUpdated,
  });

  @override
  State<BlocoListaNumeradaWidget> createState() =>
      _BlocoListaNumeradaWidgetState();
}

class _BlocoListaNumeradaWidgetState extends State<BlocoListaNumeradaWidget> {
  late List<String> _items;
  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.bloco.itens);
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers.clear();
    _focusNodes.clear();

    for (int i = 0; i < _items.length; i++) {
      _controllers.add(TextEditingController(text: _items[i]));
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add('');
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNodes.last.requestFocus();
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items.removeAt(index);
        _controllers[index].dispose();
        _focusNodes[index].dispose();
        _controllers.removeAt(index);
        _focusNodes.removeAt(index);
      });
      _saveChanges();
    }
  }

  void _saveChanges() {
    final updatedItems =
        _controllers.map((controller) => controller.text).toList();
    final updatedBloco = BlocoListaNumerada(
      id: widget.bloco.id,
      itens: updatedItems,
      estilo: widget.bloco.estilo,
      indentacao: widget.bloco.indentacao,
      inicioNumero: widget.bloco.inicioNumero,
    );
    widget.onUpdated?.call(updatedBloco);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _items.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 8),
                  width: 24,
                  child: Text(
                    '${widget.bloco.inicioNumero + i}.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Item text
                Expanded(
                  child: widget.isEditable
                      ? TextField(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          onChanged: (_) => _saveChanges(),
                          onSubmitted: (_) {
                            if (i == _items.length - 1) {
                              _addItem();
                            } else {
                              _focusNodes[i + 1].requestFocus();
                            }
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Item numerado...',
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(_items[i]),
                        ),
                ),
                // Remove button
                if (widget.isEditable && _items.length > 1)
                  IconButton(
                    onPressed: () => _removeItem(i),
                    icon: Icon(PhosphorIcons.x(), size: 16),
                    iconSize: 16,
                    constraints:
                        const BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
              ],
            ),
          ),

        // Add item button
        if (widget.isEditable)
          TextButton.icon(
            onPressed: _addItem,
            icon: Icon(PhosphorIcons.plus(), size: 16),
            label: const Text('Adicionar item'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
      ],
    );
  }
}

/// Widget para bloco de tarefa
class BlocoTarefaWidget extends StatefulWidget {
  final BlocoTarefa bloco;
  final bool isEditable;
  final Function(BlocoBase)? onUpdated;

  const BlocoTarefaWidget({
    super.key,
    required this.bloco,
    this.isEditable = true,
    this.onUpdated,
  });

  @override
  State<BlocoTarefaWidget> createState() => _BlocoTarefaWidgetState();
}

class _BlocoTarefaWidgetState extends State<BlocoTarefaWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.bloco.conteudo);
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _saveChanges();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleCompleted() {
    final updatedBloco = BlocoTarefa(
      id: widget.bloco.id,
      conteudo: widget.bloco.conteudo,
      concluida: !widget.bloco.concluida,
      prazo: widget.bloco.prazo,
      prioridade: widget.bloco.prioridade,
      subtarefas: widget.bloco.subtarefas,
    );
    widget.onUpdated?.call(updatedBloco);
  }

  void _saveChanges() {
    if (_controller.text != widget.bloco.conteudo) {
      final updatedBloco = BlocoTarefa(
        id: widget.bloco.id,
        conteudo: _controller.text,
        concluida: widget.bloco.concluida,
        prazo: widget.bloco.prazo,
        prioridade: widget.bloco.prioridade,
        subtarefas: widget.bloco.subtarefas,
      );
      widget.onUpdated?.call(updatedBloco);
    }
    setState(() {
      _isEditing = false;
    });
  }

  Color _getPriorityColor() {
    switch (widget.bloco.prioridade) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baixa':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checkbox
        Padding(
          padding: const EdgeInsets.only(top: 2, right: 8),
          child: GestureDetector(
            onTap: widget.isEditable ? _toggleCompleted : null,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      widget.bloco.concluida ? AppColors.primary : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
                color: widget.bloco.concluida ? AppColors.primary : null,
              ),
              child: widget.bloco.concluida
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ),
        ),

        // Task content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task text
              widget.isEditable && _isEditing
                  ? TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onSubmitted: (_) => _saveChanges(),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Descrição da tarefa...',
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                      ),
                    )
                  : GestureDetector(
                      onTap: widget.isEditable
                          ? () {
                              setState(() {
                                _isEditing = true;
                              });
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                _focusNode.requestFocus();
                              });
                            }
                          : null,
                      child: Text(
                        widget.bloco.conteudo.isEmpty
                            ? 'Nova tarefa...'
                            : widget.bloco.conteudo,
                        style: TextStyle(
                          decoration: widget.bloco.concluida
                              ? TextDecoration.lineThrough
                              : null,
                          color: widget.bloco.concluida ? Colors.grey : null,
                          fontSize: 16,
                        ),
                      ),
                    ),

              // Metadata
              if (widget.bloco.prazo != null || widget.bloco.prioridade != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      // Priority
                      if (widget.bloco.prioridade != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getPriorityColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.bloco.prioridade!.toUpperCase(),
                            style: TextStyle(
                              color: _getPriorityColor(),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                      // Due date
                      if (widget.bloco.prazo != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.bloco.prazo!.day}/${widget.bloco.prazo!.month}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget para bloco de código
class BlocoCodigoWidget extends ConsumerStatefulWidget {
  final BlocoCodigo bloco;
  final bool isEditable;
  final Function(BlocoBase)? onUpdated;

  const BlocoCodigoWidget({
    super.key,
    required this.bloco,
    this.isEditable = true,
    this.onUpdated,
  });

  @override
  ConsumerState<BlocoCodigoWidget> createState() => _BlocoCodigoWidgetState();
}

class _BlocoCodigoWidgetState extends ConsumerState<BlocoCodigoWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.bloco.codigo);
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _saveChanges();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_controller.text != widget.bloco.codigo) {
      final updatedBloco = BlocoCodigo(
        id: widget.bloco.id,
        codigo: _controller.text,
        linguagem: widget.bloco.linguagem,
        mostrarNumeroLinhas: widget.bloco.mostrarNumeroLinhas,
        tema: widget.bloco.tema,
        destacarSintaxe: widget.bloco.destacarSintaxe,
      );
      widget.onUpdated?.call(updatedBloco);
    }
    setState(() {
      _isEditing = false;
    });
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.bloco.codigo));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código copiado')),
    );
  }

  void _changeLanguage(String? newLanguage) {
    if (newLanguage == null) return;

    final updatedBloco = BlocoCodigo(
      id: widget.bloco.id,
      codigo: widget.bloco.codigo,
      linguagem: newLanguage,
      mostrarNumeroLinhas: widget.bloco.mostrarNumeroLinhas,
      tema: widget.bloco.tema,
      destacarSintaxe: widget.bloco.destacarSintaxe,
    );
    widget.onUpdated?.call(updatedBloco);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                // Language selector
                DropdownButton<String>(
                  value: widget.bloco.linguagem,
                  onChanged: widget.isEditable ? _changeLanguage : null,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'text', child: Text('Text')),
                    DropdownMenuItem(value: 'dart', child: Text('Dart')),
                    DropdownMenuItem(
                        value: 'javascript', child: Text('JavaScript')),
                    DropdownMenuItem(value: 'python', child: Text('Python')),
                    DropdownMenuItem(value: 'java', child: Text('Java')),
                    DropdownMenuItem(value: 'cpp', child: Text('C++')),
                    DropdownMenuItem(value: 'html', child: Text('HTML')),
                    DropdownMenuItem(value: 'css', child: Text('CSS')),
                    DropdownMenuItem(value: 'json', child: Text('JSON')),
                    DropdownMenuItem(value: 'sql', child: Text('SQL')),
                  ],
                ),

                const Spacer(),

                // Copy button
                IconButton(
                  onPressed: _copyCode,
                  icon: Icon(PhosphorIcons.copy(), size: 16),
                  tooltip: 'Copiar código',
                ),

                // Edit button
                if (widget.isEditable)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                      if (_isEditing) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _focusNode.requestFocus();
                        });
                      }
                    },
                    icon: Icon(
                      _isEditing
                          ? PhosphorIcons.check()
                          : PhosphorIcons.pencil(),
                      size: 16,
                    ),
                    tooltip: _isEditing ? 'Salvar' : 'Editar',
                  ),
              ],
            ),
          ),

          // Code content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: _isEditing
                ? TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Insira seu código aqui...',
                    ),
                    onSubmitted: (_) => _saveChanges(),
                  )
                : widget.bloco.destacarSintaxe
                    ? HighlightView(
                        widget.bloco.codigo.isEmpty
                            ? '// Código vazio'
                            : widget.bloco.codigo,
                        language: widget.bloco.linguagem,
                        theme: isDarkMode ? atomOneDarkTheme : githubTheme,
                        padding: EdgeInsets.zero,
                        textStyle: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 14,
                        ),
                      )
                    : Text(
                        widget.bloco.codigo.isEmpty
                            ? '// Código vazio'
                            : widget.bloco.codigo,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 14,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

/// Widget para bloco de equação
class BlocoEquacaoWidget extends StatefulWidget {
  final BlocoEquacao bloco;
  final bool isEditable;
  final Function(BlocoBase)? onUpdated;

  const BlocoEquacaoWidget({
    super.key,
    required this.bloco,
    this.isEditable = true,
    this.onUpdated,
  });

  @override
  State<BlocoEquacaoWidget> createState() => _BlocoEquacaoWidgetState();
}

class _BlocoEquacaoWidgetState extends State<BlocoEquacaoWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.bloco.formula);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_controller.text != widget.bloco.formula) {
      final updatedBloco = BlocoEquacao(
        id: widget.bloco.id,
        formula: _controller.text,
        blocoCompleto: widget.bloco.blocoCompleto,
        configuracoes: widget.bloco.configuracoes,
      );
      widget.onUpdated?.call(updatedBloco);
    }
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(PhosphorIcons.function(), color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Equação Matemática',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.purple,
                ),
              ),
              const Spacer(),
              if (widget.isEditable)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                    if (_isEditing) {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _focusNode.requestFocus();
                      });
                    }
                  },
                  icon: Icon(
                    _isEditing ? PhosphorIcons.check() : PhosphorIcons.pencil(),
                    size: 16,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Math content
          if (_isEditing)
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Digite a fórmula LaTeX (ex: x^2 + y^2 = r^2)',
              ),
              onSubmitted: (_) => _saveChanges(),
            )
          else
            Center(
              child: widget.bloco.formula.isEmpty
                  ? const Text(
                      'Clique para adicionar fórmula',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : Math.tex(
                      widget.bloco.formula,
                      mathStyle: MathStyle.display,
                      textStyle: const TextStyle(fontSize: 18),
                    ),
            ),

          // LaTeX source (when not editing)
          if (!_isEditing && widget.bloco.formula.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'LaTeX: ${widget.bloco.formula}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'Courier',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget para bloco de imagem
class BlocoImagemWidget extends StatelessWidget {
  final BlocoImagem bloco;
  final bool isEditable;
  final Function(BlocoBase)? onUpdated;

  const BlocoImagemWidget({
    super.key,
    required this.bloco,
    this.isEditable = true,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: bloco.url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.image(), size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text(
                        'Erro ao carregar imagem',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Caption
          if (bloco.legenda != null && bloco.legenda!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                bloco.legenda!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget para bloco de vídeo
class BlocoVideoWidget extends StatelessWidget {
  final BlocoVideo bloco;
  final bool isEditable;
  final Function(BlocoBase)? onUpdated;

  const BlocoVideoWidget({
    super.key,
    required this.bloco,
    this.isEditable = true,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video placeholder
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Thumbnail
                  if (bloco.thumbnail != null)
                    CachedNetworkImage(
                      imageUrl: bloco.thumbnail!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),

                  // Play button
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Video info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(PhosphorIcons.videoCamera(),
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        bloco.url,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (bloco.legenda != null && bloco.legenda!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      bloco.legenda!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
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

/// Widget para bloco de link
class BlocoLinkWidget extends StatelessWidget {
  final BlocoLink bloco;
  final bool isEditable;
  final Function(BlocoBase)? onUpdated;

  const BlocoLinkWidget({
    super.key,
    required this.bloco,
    this.isEditable = true,
    this.onUpdated,
  });

  void _openLink() async {
    final uri = Uri.parse(bloco.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openLink,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.blue.withOpacity(0.05),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                PhosphorIcons.link(),
                color: Colors.blue,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bloco.titulo ?? 'Link',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                  if (bloco.descricao != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        bloco.descricao!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      bloco.url,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // External link icon
            Icon(
              PhosphorIcons.arrowSquareOut(),
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para bloco divisor
class BlocoDivisorWidget extends StatelessWidget {
  final BlocoDivisor bloco;
  final bool isEditable;
  final Function(BlocoBase)? onUpdated;

  const BlocoDivisorWidget({
    super.key,
    required this.bloco,
    this.isEditable = true,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        thickness: bloco.espessura,
        color: Color(int.parse(bloco.cor.replaceFirst('#', '0xFF'))),
      ),
    );
  }
}

/// Widget para bloco de tabela
class BlocoTabelaWidget extends StatefulWidget {
  final BlocoTabela bloco;
  final bool isEditable;
  final Function(BlocoBase)? onUpdated;

  const BlocoTabelaWidget({
    super.key,
    required this.bloco,
    this.isEditable = true,
    this.onUpdated,
  });

  @override
  State<BlocoTabelaWidget> createState() => _BlocoTabelaWidgetState();
}

class _BlocoTabelaWidgetState extends State<BlocoTabelaWidget> {
  late List<String> _headers;
  late List<List<String>> _rows;

  @override
  void initState() {
    super.initState();
    _headers = List.from(widget.bloco.cabecalhos);
    _rows = widget.bloco.linhas.map((row) => List<String>.from(row)).toList();
  }

  void _addColumn() {
    setState(() {
      _headers.add('Nova Coluna');
      for (var row in _rows) {
        row.add('');
      }
    });
    _saveChanges();
  }

  void _addRow() {
    setState(() {
      _rows.add(List.filled(_headers.length, ''));
    });
    _saveChanges();
  }

  void _removeColumn(int index) {
    if (_headers.length > 1) {
      setState(() {
        _headers.removeAt(index);
        for (var row in _rows) {
          if (row.length > index) {
            row.removeAt(index);
          }
        }
      });
      _saveChanges();
    }
  }

  void _removeRow(int index) {
    if (_rows.length > 1) {
      setState(() {
        _rows.removeAt(index);
      });
      _saveChanges();
    }
  }

  void _saveChanges() {
    final updatedBloco = BlocoTabela(
      id: widget.bloco.id,
      cabecalhos: _headers,
      linhas: _rows,
      configuracoes: widget.bloco.configuracoes,
    );
    widget.onUpdated?.call(updatedBloco);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              border: TableBorder.all(color: Colors.grey[300]!),
              columns: [
                for (int i = 0; i < _headers.length; i++)
                  DataColumn(
                    label: Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: widget.isEditable
                                ? TextFormField(
                                    initialValue: _headers[i],
                                    onChanged: (value) {
                                      _headers[i] = value;
                                      _saveChanges();
                                    },
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  )
                                : Text(
                                    _headers[i],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                          ),
                          if (widget.isEditable && _headers.length > 1)
                            IconButton(
                              onPressed: () => _removeColumn(i),
                              icon: Icon(PhosphorIcons.x(), size: 14),
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
              rows: [
                for (int i = 0; i < _rows.length; i++)
                  DataRow(
                    cells: [
                      for (int j = 0; j < _headers.length; j++)
                        DataCell(
                          Row(
                            children: [
                              Expanded(
                                child: widget.isEditable
                                    ? TextFormField(
                                        initialValue: j < _rows[i].length
                                            ? _rows[i][j]
                                            : '',
                                        onChanged: (value) {
                                          if (j < _rows[i].length) {
                                            _rows[i][j] = value;
                                            _saveChanges();
                                          }
                                        },
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      )
                                    : Text(
                                        j < _rows[i].length ? _rows[i][j] : ''),
                              ),
                              if (widget.isEditable &&
                                  j == _headers.length - 1 &&
                                  _rows.length > 1)
                                IconButton(
                                  onPressed: () => _removeRow(i),
                                  icon: Icon(PhosphorIcons.x(), size: 14),
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),

          // Add buttons
          if (widget.isEditable)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: _addRow,
                    icon: Icon(PhosphorIcons.plus(), size: 16),
                    label: const Text('Adicionar linha'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _addColumn,
                    icon: Icon(PhosphorIcons.plus(), size: 16),
                    label: const Text('Adicionar coluna'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget placeholder para tipos não implementados ainda
class _PlaceholderBlocoWidget extends StatelessWidget {
  final BlocoBase bloco;
  final String title;
  final IconData icon;
  final Color color;

  const _PlaceholderBlocoWidget({
    required this.bloco,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const Text(
                  'Funcionalidade em desenvolvimento',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
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

// Widgets placeholder para os tipos mais complexos
class BlocoColunaWidget extends StatelessWidget {
  final BlocoColuna bloco;
  final bool isEditable;
  final Function(BlocoBase)? onUpdated;

  const BlocoColunaWidget({
    super.key,
    required this.bloco,
    this.isEditable = true,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return _PlaceholderBlocoWidget(
      bloco: bloco,
      title: 'Layout em Colunas',
      icon: PhosphorIcons.columns(),
      color: Colors.indigo,
    );
  }
}

class BlocoBaseDadosWidget extends StatelessWidget {
  final BlocoBaseDados bloco;
  final bool isEditable;
  final Function(BlocoBase)? onUpdated;

  const BlocoBaseDadosWidget({
    super.key,
    required this.bloco,
    this.isEditable = true,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return _PlaceholderBlocoWidget(
      bloco: bloco,
      title: 'Base de Dados: ${bloco.nome}',
      icon: PhosphorIcons.database(),
      color: Colors.deepPurple,
    );
  }
}

class BlocoWikiWidget extends StatelessWidget {
  final BlocoWiki bloco;
  final bool isEditable;
  final Function(BlocoBase)? onUpdated;

  const BlocoWikiWidget({
    super.key,
    required this.bloco,
    this.isEditable = true,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return _PlaceholderBlocoWidget(
      bloco: bloco,
      title: 'Wiki: ${bloco.titulo}',
      icon: PhosphorIcons.bookOpen(),
      color: Colors.teal,
    );
  }
}

class BlocoPaginaWidget extends StatelessWidget {
  final BlocoPagina bloco;
  final bool isEditable;
  final Function(BlocoBase)? onUpdated;

  const BlocoPaginaWidget({
    super.key,
    required this.bloco,
    this.isEditable = true,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return _PlaceholderBlocoWidget(
      bloco: bloco,
      title: 'Página: ${bloco.titulo}',
      icon: PhosphorIcons.file(),
      color: Colors.green,
    );
  }
}

class BlocoBlocoSincronizadoWidget extends StatelessWidget {
  final BlocoBlocoSincronizado bloco;
  final bool isEditable;
  final Function(BlocoBase)? onUpdated;

  const BlocoBlocoSincronizadoWidget({
    super.key,
    required this.bloco,
    this.isEditable = true,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return _PlaceholderBlocoWidget(
      bloco: bloco,
      title: 'Bloco Sincronizado',
      icon: PhosphorIcons.arrowsClockwise(),
      color: Colors.cyan,
    );
  }
}
