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
import 'package:uuid/uuid.dart';

import '../models/bloco_base_model.dart';
import '../models/bloco_tipo_enum.dart';
import '../providers/blocos_provider.dart';
import '../providers/editor_controller_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';

/// Widget de menu para inserir blocos
class BlocoMenuWidget extends ConsumerStatefulWidget {
  final Function(BlocoBase)? onBlockSelected;
  final VoidCallback? onDismiss;
  final String? searchQuery;
  final bool showAsModal;
  final bool showCategories;

  const BlocoMenuWidget({
    super.key,
    this.onBlockSelected,
    this.onDismiss,
    this.searchQuery,
    this.showAsModal = false,
    this.showCategories = true,
  });

  @override
  ConsumerState<BlocoMenuWidget> createState() => _BlocoMenuWidgetState();
}

class _BlocoMenuWidgetState extends ConsumerState<BlocoMenuWidget> {
  static const _uuid = Uuid();

  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late FocusNode _keyboardFocusNode;
  String _currentQuery = '';
  BlocoCategory? _selectedCategory;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery ?? '');
    _searchFocusNode = FocusNode();
    _keyboardFocusNode = FocusNode();
    _currentQuery = widget.searchQuery ?? '';

    // Auto-focus na busca
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    if (widget.showAsModal) {
      return _buildModal(context, isDarkMode);
    }

    return _buildInlineMenu(context, isDarkMode);
  }

  Widget _buildModal(BuildContext context, bool isDarkMode) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 480,
        height: 520,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header do modal
            _buildModalHeader(isDarkMode),

            // Conteúdo principal
            Expanded(
              child: _buildMenuContent(isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineMenu(BuildContext context, bool isDarkMode) {
    return Container(
      width: 320,
      height: 400,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildMenuContent(isDarkMode),
    );
  }

  Widget _buildModalHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.plus(),
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Inserir Bloco',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onDismiss,
            icon: Icon(PhosphorIcons.x(), size: 20),
            style: IconButton.styleFrom(
              minimumSize: const Size(32, 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuContent(bool isDarkMode) {
    return Column(
      children: [
        // Barra de busca
        _buildSearchBar(isDarkMode),

        // Categorias (se habilitadas)
        if (widget.showCategories) _buildCategoryTabs(isDarkMode),

        // Lista de blocos
        Expanded(
          child: _buildBlockList(isDarkMode),
        ),

        // Footer com dicas
        _buildFooter(isDarkMode),
      ],
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          setState(() {
            _currentQuery = value;
            _selectedIndex = 0; // Reset seleção
          });
        },
        onSubmitted: (value) {
          final filteredBlocks = _getFilteredBlocks();
          if (filteredBlocks.isNotEmpty) {
            _insertBlock(filteredBlocks[_selectedIndex]);
          }
        },
        decoration: InputDecoration(
          hintText: 'Buscar blocos...',
          prefixIcon: Icon(PhosphorIcons.magnifyingGlass(), size: 18),
          suffixIcon: _currentQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _currentQuery = '';
                      _selectedIndex = 0;
                    });
                  },
                  icon: Icon(PhosphorIcons.x(), size: 16),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(bool isDarkMode) {
    final categories = BlocoCategory.values;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1, // +1 para "Todos"
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryTab(
              label: 'Todos',
              isSelected: _selectedCategory == null,
              onTap: () {
                setState(() {
                  _selectedCategory = null;
                  _selectedIndex = 0;
                });
              },
            );
          }

          final category = categories[index - 1];
          return _buildCategoryTab(
            label: category.displayName,
            isSelected: _selectedCategory == category,
            onTap: () {
              setState(() {
                _selectedCategory = category;
                _selectedIndex = 0;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? AppColors.primary : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBlockList(bool isDarkMode) {
    final filteredBlocks = _getFilteredBlocks();

    if (filteredBlocks.isEmpty) {
      return _buildEmptyState();
    }

    return RawKeyboardListener(
      focusNode: _keyboardFocusNode,
      onKey: (event) => _handleKeyEvent(event, filteredBlocks),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: filteredBlocks.length,
        itemBuilder: (context, index) {
          final blockInfo = filteredBlocks[index];
          final isSelected = index == _selectedIndex;

          return _buildBlockItem(
            blockInfo: blockInfo,
            isSelected: isSelected,
            onTap: () => _insertBlock(blockInfo),
          );
        },
      ),
    );
  }

  Widget _buildBlockItem({
    required BlockInfo blockInfo,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 1)
                  : null,
            ),
            child: Row(
              children: [
                // Ícone do bloco
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: blockInfo.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    blockInfo.icon,
                    size: 18,
                    color: blockInfo.color,
                  ),
                ),

                const SizedBox(width: 12),

                // Informações do bloco
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        blockInfo.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Text(
                        blockInfo.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Atalho de teclado
                if (blockInfo.shortcut != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      blockInfo.shortcut!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontFamily: 'Courier',
                          ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.magnifyingGlass(),
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum bloco encontrado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente uma busca diferente',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.lightbulb(),
            size: 14,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Use ↑↓ para navegar e Enter para inserir',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos de lógica

  List<BlockInfo> _getFilteredBlocks() {
    List<BlockInfo> blocks = _getAllBlocks();

    // Filtrar por categoria
    if (_selectedCategory != null) {
      blocks =
          blocks.where((block) => block.category == _selectedCategory).toList();
    }

    // Filtrar por query de busca
    if (_currentQuery.isNotEmpty) {
      final query = _currentQuery.toLowerCase();
      blocks = blocks.where((block) {
        return block.name.toLowerCase().contains(query) ||
            block.description.toLowerCase().contains(query) ||
            (block.keywords
                    ?.any((keyword) => keyword.toLowerCase().contains(query)) ??
                false);
      }).toList();
    }

    return blocks;
  }

  List<BlockInfo> _getAllBlocks() {
    return [
      // Texto e Formatação
      BlockInfo(
        tipo: BlocoTipo.texto,
        name: 'Texto',
        description: 'Parágrafo de texto simples',
        icon: PhosphorIcons.textT(),
        color: Colors.grey,
        category: BlocoCategory.text,
        keywords: ['texto', 'parágrafo', 'escrita'],
      ),
      BlockInfo(
        tipo: BlocoTipo.titulo,
        name: 'Título',
        description: 'Título de seção (H1-H6)',
        icon: PhosphorIcons.textH(),
        color: Colors.blue,
        category: BlocoCategory.text,
        shortcut: '#',
        keywords: ['título', 'cabeçalho', 'h1', 'h2', 'h3'],
      ),

      // Listas
      BlockInfo(
        tipo: BlocoTipo.lista,
        name: 'Lista com Marcadores',
        description: 'Lista com pontos',
        icon: PhosphorIcons.list(),
        color: Colors.orange,
        category: BlocoCategory.lists,
        shortcut: '-',
        keywords: ['lista', 'bullet', 'itens'],
      ),
      BlockInfo(
        tipo: BlocoTipo.listaNumerada,
        name: 'Lista Numerada',
        description: 'Lista com números',
        icon: PhosphorIcons.listNumbers(),
        color: Colors.green,
        category: BlocoCategory.lists,
        shortcut: '1.',
        keywords: ['lista', 'numerada', 'ordenada'],
      ),
      BlockInfo(
        tipo: BlocoTipo.tarefa,
        name: 'Lista de Tarefas',
        description: 'Lista com checkboxes',
        icon: PhosphorIcons.checkSquare(),
        color: Colors.purple,
        category: BlocoCategory.lists,
        shortcut: '[]',
        keywords: ['tarefa', 'todo', 'checkbox', 'lista'],
      ),

      // Mídia
      BlockInfo(
        tipo: BlocoTipo.imagem,
        name: 'Imagem',
        description: 'Inserir imagem',
        icon: PhosphorIcons.image(),
        color: Colors.teal,
        category: BlocoCategory.media,
        keywords: ['imagem', 'foto', 'figura'],
      ),
      BlockInfo(
        tipo: BlocoTipo.video,
        name: 'Vídeo',
        description: 'Incorporar vídeo',
        icon: PhosphorIcons.videoCamera(),
        color: Colors.red,
        category: BlocoCategory.media,
        keywords: ['vídeo', 'filme', 'reprodutor'],
      ),

      // Código e Matemática
      BlockInfo(
        tipo: BlocoTipo.codigo,
        name: 'Código',
        description: 'Bloco de código com syntax highlighting',
        icon: PhosphorIcons.code(),
        color: Colors.indigo,
        category: BlocoCategory.code,
        shortcut: "```",
        keywords: ['código', 'programação', 'syntax'],
      ),
      BlockInfo(
        tipo: BlocoTipo.equacao,
        name: 'Equação',
        description: 'Fórmula matemática LaTeX',
        icon: PhosphorIcons.function(),
        color: Colors.deepPurple,
        category: BlocoCategory.code,
        keywords: ['equação', 'matemática', 'latex', 'fórmula'],
      ),

      // Estrutura
      BlockInfo(
        tipo: BlocoTipo.tabela,
        name: 'Tabela',
        description: 'Tabela com linhas e colunas',
        icon: PhosphorIcons.table(),
        color: Colors.amber,
        category: BlocoCategory.structure,
        keywords: ['tabela', 'linhas', 'colunas', 'dados'],
      ),
      BlockInfo(
        tipo: BlocoTipo.divisor,
        name: 'Divisor',
        description: 'Linha horizontal separadora',
        icon: PhosphorIcons.minus(),
        color: Colors.grey,
        category: BlocoCategory.structure,
        shortcut: '---',
        keywords: ['divisor', 'separador', 'linha'],
      ),
      BlockInfo(
        tipo: BlocoTipo.coluna,
        name: 'Colunas',
        description: 'Layout em colunas',
        icon: PhosphorIcons.columns(),
        color: Colors.blueGrey,
        category: BlocoCategory.structure,
        keywords: ['colunas', 'layout', 'grid'],
      ),

      // Avançado
      BlockInfo(
        tipo: BlocoTipo.link,
        name: 'Link',
        description: 'Link com preview',
        icon: PhosphorIcons.link(),
        color: Colors.lightBlue,
        category: BlocoCategory.advanced,
        keywords: ['link', 'url', 'website'],
      ),
      BlockInfo(
        tipo: BlocoTipo.baseDados,
        name: 'Base de Dados',
        description: 'Tabela interativa tipo Notion',
        icon: PhosphorIcons.database(),
        color: Colors.deepOrange,
        category: BlocoCategory.advanced,
        keywords: ['database', 'dados', 'tabela', 'notion'],
      ),
      BlockInfo(
        tipo: BlocoTipo.wiki,
        name: 'Wiki',
        description: 'Página wiki com referências',
        icon: PhosphorIcons.bookOpen(),
        color: Colors.cyan,
        category: BlocoCategory.advanced,
        keywords: ['wiki', 'página', 'referências'],
      ),
      BlockInfo(
        tipo: BlocoTipo.pagina,
        name: 'Página',
        description: 'Página aninhada',
        icon: PhosphorIcons.file(),
        color: Colors.lime,
        category: BlocoCategory.advanced,
        keywords: ['página', 'subpágina', 'hierarquia'],
      ),
      BlockInfo(
        tipo: BlocoTipo.blocoSincronizado,
        name: 'Bloco Sincronizado',
        description: 'Bloco que sincroniza com outro',
        icon: PhosphorIcons.arrowsClockwise(),
        color: Colors.pink,
        category: BlocoCategory.advanced,
        keywords: ['sincronizado', 'referência', 'espelho'],
      ),
    ];
  }

  void _handleKeyEvent(RawKeyEvent event, List<BlockInfo> filteredBlocks) {
    try {
      if (event is! RawKeyDownEvent) return;
      if (filteredBlocks.isEmpty) return;

      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowDown:
          setState(() {
            _selectedIndex = (_selectedIndex + 1) % filteredBlocks.length;
          });
          break;
        case LogicalKeyboardKey.arrowUp:
          setState(() {
            _selectedIndex = (_selectedIndex - 1 + filteredBlocks.length) %
                filteredBlocks.length;
          });
          break;
        case LogicalKeyboardKey.enter:
          if (_selectedIndex < filteredBlocks.length) {
            _insertBlock(filteredBlocks[_selectedIndex]);
          }
          break;
        case LogicalKeyboardKey.escape:
          widget.onDismiss?.call();
          break;
      }
    } catch (e) {
      // Fallback: reset selected index to prevent out-of-bounds errors
      if (filteredBlocks.isNotEmpty) {
        _selectedIndex = 0;
      }
    }
  }

  void _insertBlock(BlockInfo blockInfo) {
    final bloco = _createBlocoFromType(blockInfo.tipo);
    widget.onBlockSelected?.call(bloco);
    widget.onDismiss?.call();
  }

  BlocoBase _createBlocoFromType(BlocoTipo tipo) {
    final id = _uuid.v4();

    switch (tipo) {
      case BlocoTipo.texto:
        return BlocoTexto(id: id, conteudo: '');

      case BlocoTipo.titulo:
        return BlocoTitulo(id: id, conteudo: '', nivel: 1);

      case BlocoTipo.lista:
        return BlocoLista(id: id, itens: ['']);

      case BlocoTipo.listaNumerada:
        return BlocoListaNumerada(id: id, itens: ['']);

      case BlocoTipo.tarefa:
        return BlocoTarefa(id: id, conteudo: '', concluida: false);

      case BlocoTipo.tabela:
        return BlocoTabela(
          id: id,
          cabecalhos: ['Coluna 1', 'Coluna 2'],
          linhas: [
            ['', '']
          ],
        );

      case BlocoTipo.codigo:
        return BlocoCodigo(id: id, codigo: '', linguagem: 'text');

      case BlocoTipo.equacao:
        return BlocoEquacao(id: id, formula: '');

      case BlocoTipo.imagem:
        return BlocoImagem(id: id, url: '');

      case BlocoTipo.video:
        return BlocoVideo(id: id, url: '');

      case BlocoTipo.link:
        return BlocoLink(id: id, url: '');

      case BlocoTipo.divisor:
        return BlocoDivisor(id: id);

      case BlocoTipo.coluna:
        return BlocoColuna(
          id: id,
          colunas: [[], []],
          proporcoes: [0.5, 0.5],
        );

      case BlocoTipo.baseDados:
        return BlocoBaseDados(
          id: id,
          nome: 'Nova Base de Dados',
          colunas: [],
          linhas: [],
        );

      case BlocoTipo.wiki:
        return BlocoWiki(id: id, titulo: '', conteudo: '');

      case BlocoTipo.pagina:
        return BlocoPagina(id: id, titulo: 'Nova Página');

      case BlocoTipo.blocoSincronizado:
        return BlocoBlocoSincronizado(
          id: id,
          blocoOrigemId: '',
          conteudo: '',
          ultimaAtualizacao: DateTime.now(),
        );
    }
  }
}

/// Categorias de blocos
enum BlocoCategory {
  text,
  lists,
  media,
  code,
  structure,
  advanced,
}

extension BlocoCategoryExtension on BlocoCategory {
  String get displayName {
    switch (this) {
      case BlocoCategory.text:
        return 'Texto';
      case BlocoCategory.lists:
        return 'Listas';
      case BlocoCategory.media:
        return 'Mídia';
      case BlocoCategory.code:
        return 'Código';
      case BlocoCategory.structure:
        return 'Estrutura';
      case BlocoCategory.advanced:
        return 'Avançado';
    }
  }

  Color get color {
    switch (this) {
      case BlocoCategory.text:
        return Colors.blue;
      case BlocoCategory.lists:
        return Colors.green;
      case BlocoCategory.media:
        return Colors.purple;
      case BlocoCategory.code:
        return Colors.orange;
      case BlocoCategory.structure:
        return Colors.teal;
      case BlocoCategory.advanced:
        return Colors.red;
    }
  }
}

/// Informações de um tipo de bloco
class BlockInfo {
  final BlocoTipo tipo;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final BlocoCategory category;
  final String? shortcut;
  final List<String>? keywords;

  const BlockInfo({
    required this.tipo,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    this.shortcut,
    this.keywords,
  });
}

/// Métodos de conveniência para mostrar o menu

/// Mostrar menu como modal
void showBlocoMenuModal(
  BuildContext context, {
  Function(BlocoBase)? onBlockSelected,
}) {
  showDialog(
    context: context,
    builder: (context) => BlocoMenuWidget(
      showAsModal: true,
      onBlockSelected: onBlockSelected,
      onDismiss: () => Navigator.of(context).pop(),
    ),
  );
}

/// Mostrar menu como bottom sheet
void showBlocoMenuBottomSheet(
  BuildContext context, {
  Function(BlocoBase)? onBlockSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: BlocoMenuWidget(
        showAsModal: true,
        onBlockSelected: onBlockSelected,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    ),
  );
}

/// Widget compacto para ações rápidas
class QuickBlocoActions extends StatelessWidget {
  final Function(BlocoBase)? onBlockSelected;

  const QuickBlocoActions({
    super.key,
    this.onBlockSelected,
  });

  @override
  Widget build(BuildContext context) {
    const uuid = Uuid();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Texto
        IconButton(
          onPressed: () => onBlockSelected?.call(
            BlocoTexto(id: uuid.v4(), conteudo: ''),
          ),
          icon: Icon(PhosphorIcons.textT()),
          tooltip: 'Texto',
        ),

        // Lista
        IconButton(
          onPressed: () => onBlockSelected?.call(
            BlocoLista(id: uuid.v4(), itens: ['']),
          ),
          icon: Icon(PhosphorIcons.list()),
          tooltip: 'Lista',
        ),

        // Código
        IconButton(
          onPressed: () => onBlockSelected?.call(
            BlocoCodigo(id: uuid.v4(), codigo: '', linguagem: 'text'),
          ),
          icon: Icon(PhosphorIcons.code()),
          tooltip: 'Código',
        ),

        // Menu completo
        IconButton(
          onPressed: () =>
              showBlocoMenuModal(context, onBlockSelected: onBlockSelected),
          icon: Icon(PhosphorIcons.plus()),
          tooltip: 'Mais blocos',
        ),
      ],
    );
  }
}
