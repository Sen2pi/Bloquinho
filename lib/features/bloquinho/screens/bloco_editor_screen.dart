import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';

import '../models/bloco_base_model.dart';
import '../models/bloco_tipo_enum.dart';
import '../providers/editor_controller_provider.dart';
import '../providers/blocos_provider.dart';
import '../widgets/bloco_toolbar.dart';
import '../widgets/bloco_menu_widget.dart';
import '../widgets/bloco_render_widget.dart';
import '../widgets/page_content_widget.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/providers/workspace_provider.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/page_children_list.dart';
import '../widgets/notion_editor.dart';
import '../providers/pages_provider.dart';
import '../models/page_model.dart';
import '../../../core/services/bloquinho_storage_service.dart';

class BlocoEditorScreen extends ConsumerStatefulWidget {
  final String? documentId;
  final String? documentTitle;
  final bool isReadOnly;
  final String? initialPageId;

  const BlocoEditorScreen({
    super.key,
    this.documentId,
    this.documentTitle,
    this.isReadOnly = false,
    this.initialPageId,
  });

  @override
  ConsumerState<BlocoEditorScreen> createState() => BlocoEditorScreenState();
}

class BlocoEditorScreenState extends ConsumerState<BlocoEditorScreen> {
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _contentController = TextEditingController();
  bool _isFullscreen = false;
  bool _showLineNumbers = false;
  double _zoomLevel = 1.0;
  String? _searchQuery;
  bool _isSearchVisible = false;
  String _currentPageId = '';
  List<String> _navigationStack = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeEditor();
    });
  }

  void setPage(String pageId) {
    setState(() {
      _currentPageId = pageId;
      if (!_navigationStack.contains(pageId)) {
        _navigationStack.add(pageId);
      }
    });
  }

  // Métodos para carregar e salvar conteúdo em arquivos .md
  Future<String> loadPageContent(String pageId) async {
    try {
      final currentProfile = ref.read(currentProfileProvider);
      final currentWorkspace = ref.read(currentWorkspaceProvider);

      if (currentProfile == null || currentWorkspace == null) {
        return '';
      }

      final bloquinhoStorage = BloquinhoStorageService();
      await bloquinhoStorage.initialize();

      final page = await bloquinhoStorage.loadPage(
          pageId, currentProfile.name, currentWorkspace.name);

      return page?.content ?? '';
    } catch (e) {
      debugPrint('❌ Erro ao carregar conteúdo da página: $e');
      return '';
    }
  }

  Future<void> savePageContent(String pageId, String content) async {
    try {
      final currentProfile = ref.read(currentProfileProvider);
      final currentWorkspace = ref.read(currentWorkspaceProvider);

      if (currentProfile == null || currentWorkspace == null) {
        return;
      }

      final pages = ref.read(pagesProvider);
      final page = pages.firstWhere(
        (p) => p.id == pageId,
        orElse: () => PageModel.create(title: 'Página não encontrada'),
      );

      final updatedPage = page.copyWith(
        content: content,
        updatedAt: DateTime.now(),
      );

      final bloquinhoStorage = BloquinhoStorageService();
      await bloquinhoStorage.initialize();

      await bloquinhoStorage.savePage(
          updatedPage, currentProfile.name, currentWorkspace.name);

      debugPrint('✅ Conteúdo da página salvo: $pageId');
    } catch (e) {
      debugPrint('❌ Erro ao salvar conteúdo da página: $e');
    }
  }

  @override
  void dispose() {
    _editorFocusNode.dispose();
    _scrollController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _initializeEditor() async {
    try {
      // Se não tem documentId, criar página raiz
      if (widget.documentId == null) {
        final pagesNotifier = ref.read(pagesProvider.notifier);
        final newPage = PageModel.create(
          title: widget.documentTitle ?? 'Nova Página',
        );
        pagesNotifier.state = [...pagesNotifier.state, newPage];
        _currentPageId = newPage.id;
        _navigationStack = [newPage.id];
      } else {
        _currentPageId = widget.documentId!;
        _navigationStack = [widget.documentId!];
      }

      await ref.read(editorControllerProvider.notifier).initialize(
        documentId: _currentPageId,
        documentTitle: widget.documentTitle ?? 'Nova Página',
        isReadOnly: widget.isReadOnly,
        settings: {
          'showLineNumbers': _showLineNumbers,
          'zoomLevel': _zoomLevel,
        },
      );
    } catch (e) {
      _showErrorSnackBar('Erro ao inicializar editor: $e');
    }
  }

  void _navigateToPage(String pageId) {
    setState(() {
      _currentPageId = pageId;
      if (!_navigationStack.contains(pageId)) {
        _navigationStack.add(pageId);
      }
    });
  }

  void _navigateBack() {
    if (_navigationStack.length > 1) {
      setState(() {
        _navigationStack.removeLast();
        _currentPageId = _navigationStack.last;
      });
    }
  }

  void _createSubPage(String parentId) {
    final pagesNotifier = ref.read(pagesProvider.notifier);
    final newPage = PageModel.create(
      title: 'Nova Subpágina',
      parentId: parentId,
    );
    pagesNotifier.state = [...pagesNotifier.state, newPage];
    _navigateToPage(newPage.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final editorState = ref.watch(editorControllerProvider);
    final currentWorkspace = ref.watch(currentWorkspaceProvider);
    final pages = ref.watch(pagesProvider);
    final currentPage = pages.firstWhere(
      (p) => p.id == _currentPageId,
      orElse: () => PageModel.create(title: 'Página não encontrada'),
    );

    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: _isFullscreen
            ? null
            : _buildAppBar(isDarkMode, editorState, currentPage),
        body: _buildBody(isDarkMode, editorState, currentPage),
        floatingActionButton: _buildFloatingActionButton(editorState),
        bottomNavigationBar: _buildBottomBar(isDarkMode, editorState),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode,
      EditorControllerState editorState, PageModel? currentPage) {
    return AppBar(
      elevation: 0,
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      foregroundColor:
          isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      title: _buildTitleSection(editorState, currentPage),
      actions: _buildAppBarActions(isDarkMode, editorState),
      bottom: _isSearchVisible ? _buildSearchBar() : null,
    );
  }

  Widget _buildTitleSection(
      EditorControllerState editorState, PageModel? currentPage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breadcrumb de navegação
        if (_navigationStack.length > 1)
          Row(
            children: [
              IconButton(
                onPressed: _navigateBack,
                icon: Icon(PhosphorIcons.arrowLeft()),
                tooltip: 'Voltar',
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _navigationStack.asMap().entries.map((entry) {
                      final index = entry.key;
                      final pageId = entry.value;
                      final pages = ref.read(pagesProvider.notifier).state;
                      PageModel? page;
                      try {
                        page = pages.firstWhere((p) => p.id == pageId);
                      } catch (e) {
                        page = null;
                      }

                      return Row(
                        children: [
                          if (index > 0)
                            Icon(PhosphorIcons.caretRight(), size: 16),
                          GestureDetector(
                            onTap: () => _navigateToPage(pageId),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: pageId == _currentPageId
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.transparent,
                              ),
                              child: Text(
                                page?.title ?? 'Página',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: pageId == _currentPageId
                                      ? AppColors.primary
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),

        // Título e ícone da página atual
        Row(
          children: [
            // Seletor de ícone
            if (currentPage != null)
              GestureDetector(
                onTap: () => _showIconSelector(currentPage),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                  ),
                  child: Text(
                    currentPage.icon ?? '📄',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),

            const SizedBox(width: 12),

            // Título editável
            Expanded(
              child: GestureDetector(
                onTap: () => _editPageTitle(currentPage),
                child: Text(
                  currentPage?.title ?? 'Página sem título',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showIconSelector(PageModel page) {
    final icons = [
      '📄',
      '📝',
      '📋',
      '📚',
      '📖',
      '📗',
      '📘',
      '📙',
      '📓',
      '📔',
      '📕',
      '📒',
      '📃',
      '📄',
      '📑',
      '🔖',
      '🏷️',
      '📌',
      '📍',
      '🎯',
      '💡',
      '💭',
      '💬',
      '💭',
      '💡',
      '🔍',
      '🔎',
      '📊',
      '📈',
      '📉',
      '📋',
      '✅',
      '❌',
      '⚠️',
      'ℹ️',
      '🔔',
      '🔕',
      '🔒',
      '🔓',
      '🔐',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher Ícone'),
        content: Container(
          width: 300,
          height: 200,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: icons.length,
            itemBuilder: (context, index) {
              final icon = icons[index];
              final isSelected = page.icon == icon;

              return GestureDetector(
                onTap: () {
                  ref.read(pagesProvider.notifier).updatePage(
                        page.id,
                        icon: icon,
                      );
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: TextStyle(
                        fontSize: 20,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                  ),
                ),
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
      ),
    );
  }

  void _editPageTitle(PageModel? page) {
    if (page == null) return;

    final titleController = TextEditingController(text: page.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Título'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Título da página',
            hintText: 'Digite o título...',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                ref.read(pagesProvider.notifier).updatePage(
                      page.id,
                      title: titleController.text.trim(),
                    );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDarkMode, EditorControllerState editorState,
      PageModel? currentPage) {
    if (editorState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (editorState.error != null) {
      return _buildErrorView(editorState.error!);
    }

    if (!editorState.isInitialized) {
      return const Center(
        child: Text('Editor não inicializado'),
      );
    }

    return Column(
      children: [
        // Lista horizontal de subpáginas e botão +
        if (currentPage != null)
          _SubPagesBar(
            parentPage: currentPage,
            onNavigateToPage: _navigateToPage,
            onCreateSubPage: _createSubPage,
          ),

        // Lista de filhos no topo (mantém para navegação vertical)
        if (currentPage != null)
          PageChildrenList(
            currentPageId: currentPage.id,
            onNavigateToPage: _navigateToPage,
            onCreateSubPage: _createSubPage,
          ),

        // Editor de conteúdo com auto-save
        Expanded(
          child: PageContentWidget(
            pageId: currentPage?.id ?? '',
            isEditing: !widget.isReadOnly,
          ),
        ),
      ],
    );
  }

  Widget _buildEditor(bool isDarkMode, EditorControllerState editorState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Transform.scale(
        scale: _zoomLevel,
        child: TextField(
          controller: _contentController,
          focusNode: _editorFocusNode,
          scrollController: _scrollController,
          enabled: editorState.canEdit,
          maxLines: null,
          expands: true,
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Comece a escrever...',
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          onChanged: (value) {
            // TODO: Implementar detecção de mudanças
            ref.read(editorControllerProvider.notifier).state =
                ref.read(editorControllerProvider.notifier).state.copyWith(
                      hasChanges: true,
                      lastModified: DateTime.now(),
                    );
          },
        ),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.warning(),
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro no Editor',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                ref.read(editorControllerProvider.notifier).clearError(),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(EditorControllerState editorState) {
    if (_isFullscreen || !editorState.canEdit) return null;

    return FloatingActionButton(
      onPressed: _showBlockMenu,
      tooltip: 'Inserir bloco',
      child: Icon(PhosphorIcons.plus()),
    );
  }

  Widget? _buildBottomBar(bool isDarkMode, EditorControllerState editorState) {
    if (_isFullscreen) return null;

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Estatísticas do documento
          Text(
            _buildStatsText(editorState),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const Spacer(),
          // Posição do cursor
          if (editorState.selection != null)
            Text(
              'Linha ${editorState.selection!.start + 1}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
        ],
      ),
    );
  }

  String _buildStatsText(EditorControllerState editorState) {
    final stats =
        ref.read(editorControllerProvider.notifier).getDocumentStats();
    final wordCount = stats['wordCount'] ?? 0;
    final charCount = stats['characterCount'] ?? 0;

    return '$wordCount palavras • $charCount caracteres';
  }

  // Event Handlers

  void _insertBlock(BlocoBase bloco) {
    ref.read(editorControllerProvider.notifier).insertBlock(bloco);
  }

  void _formatText(String format) {
    ref.read(editorControllerProvider.notifier).formatText(format);
  }

  void _insertLink() {
    _showLinkDialog();
  }

  void _convertToHeading(int level) {
    ref.read(editorControllerProvider.notifier).insertHeading(level);
  }

  void _convertToBulletList() {
    ref.read(editorControllerProvider.notifier).insertBulletList();
  }

  void _convertToNumberedList() {
    ref.read(editorControllerProvider.notifier).insertNumberedList();
  }

  void _convertToTodoList() {
    ref.read(editorControllerProvider.notifier).insertTask();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });
  }

  void _performSearch(String query) {
    // Implementar busca
  }

  void _showSearchResults(List<Map<String, dynamic>> results) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${results.length} resultados encontrados'),
        action: SnackBarAction(
          label: 'Fechar',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _setZoomLevel(double zoom) {
    setState(() {
      _zoomLevel = zoom;
    });
  }

  void _handleViewOption(String option) {
    switch (option) {
      case 'fullscreen':
        _toggleFullscreen();
        break;
      case 'line_numbers':
        setState(() {
          _showLineNumbers = !_showLineNumbers;
        });
        break;
      case 'reading_mode':
        ref.read(editorControllerProvider.notifier).toggleReadOnlyMode();
        break;
    }
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  void _handleMenuOption(String option) {
    switch (option) {
      case 'save':
        // Implementar salvamento
        break;
      case 'export':
        // Implementar exportação
        break;
    }
  }

  void _showBlockMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => BlocoMenuWidget(
        onBlockSelected: _insertBlock,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _saveDocument() async {
    try {
      await ref.read(editorControllerProvider.notifier).saveDocument();
      _showSuccessSnackBar('Documento salvo com sucesso');
    } catch (e) {
      _showErrorSnackBar('Erro ao salvar documento: $e');
    }
  }

  void _exportDocument() {
    showDialog(
      context: context,
      builder: (context) => _ExportDialog(
        onExport: (format) async {
          try {
            final data = await ref
                .read(editorControllerProvider.notifier)
                .exportDocument(format: format);
            _showSuccessSnackBar('Documento exportado com sucesso');
          } catch (e) {
            _showErrorSnackBar('Erro ao exportar: $e');
          }
        },
      ),
    );
  }

  void _importDocument() {
    // TODO: Implementar importação de documento
    _showInfoSnackBar('Funcionalidade em desenvolvimento');
  }

  void _shareDocument() {
    // TODO: Implementar compartilhamento
    _showInfoSnackBar('Funcionalidade em desenvolvimento');
  }

  void _showSettings() {
    // TODO: Implementar configurações do editor
    _showInfoSnackBar('Funcionalidade em desenvolvimento');
  }

  void _editDocumentTitle(EditorControllerState editorState) {
    showDialog(
      context: context,
      builder: (context) => _TitleEditDialog(
        currentTitle: editorState.documentTitle ?? '',
        onSave: (newTitle) {
          // TODO: Implementar atualização do título
          _showSuccessSnackBar('Título atualizado');
        },
      ),
    );
  }

  void _showLinkDialog() {
    showDialog(
      context: context,
      builder: (context) => _LinkDialog(
        onInsert: (url, text) {
          ref
              .read(editorControllerProvider.notifier)
              .insertLink(url, text: text);
        },
      ),
    );
  }

  // Utility methods

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Fechar',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Fechar',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Fechar',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions(
      bool isDarkMode, EditorControllerState editorState) {
    return [
      // Buscar
      IconButton(
        onPressed: () => _toggleSearch(),
        icon: Icon(PhosphorIcons.magnifyingGlass()),
        tooltip: 'Buscar',
      ),

      // Desfazer/Refazer
      IconButton(
        onPressed: editorState.canUndo
            ? () => ref.read(editorControllerProvider.notifier).undo()
            : null,
        icon: Icon(PhosphorIcons.arrowCounterClockwise()),
        tooltip: 'Desfazer',
      ),
      IconButton(
        onPressed: editorState.canRedo
            ? () => ref.read(editorControllerProvider.notifier).redo()
            : null,
        icon: Icon(PhosphorIcons.arrowClockwise()),
        tooltip: 'Refazer',
      ),

      // Zoom
      PopupMenuButton<double>(
        onSelected: (zoom) => _setZoomLevel(zoom),
        icon: Icon(PhosphorIcons.magnifyingGlassPlus()),
        tooltip: 'Zoom',
        itemBuilder: (context) => [
          const PopupMenuItem(value: 0.75, child: Text('75%')),
          const PopupMenuItem(value: 1.0, child: Text('100%')),
          const PopupMenuItem(value: 1.25, child: Text('125%')),
          const PopupMenuItem(value: 1.5, child: Text('150%')),
        ],
      ),

      // Menu principal
      PopupMenuButton<String>(
        onSelected: _handleMenuOption,
        icon: Icon(PhosphorIcons.dotsThreeVertical()),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'save',
            child: Row(
              children: [
                Icon(PhosphorIcons.floppyDisk()),
                const SizedBox(width: 8),
                const Text('Salvar'),
              ],
            ),
          ),
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
        ],
      ),
    ];
  }

  PreferredSize _buildSearchBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: TextField(
          autofocus: true,
          onChanged: (query) => setState(() => _searchQuery = query),
          onSubmitted: _performSearch,
          decoration: InputDecoration(
            hintText: 'Buscar no documento...',
            prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
            suffixIcon: IconButton(
              onPressed: _toggleSearch,
              icon: Icon(PhosphorIcons.x()),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }
}

// Dialog Widgets

class _ExportDialog extends StatelessWidget {
  final Function(String format) onExport;

  const _ExportDialog({required this.onExport});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exportar Documento'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(PhosphorIcons.fileText()),
            title: const Text('Markdown'),
            subtitle: const Text('Formato de texto simples'),
            onTap: () {
              onExport('markdown');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(PhosphorIcons.filePdf()),
            title: const Text('PDF'),
            subtitle: const Text('Documento portátil'),
            onTap: () {
              onExport('pdf');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(PhosphorIcons.fileHtml()),
            title: const Text('HTML'),
            subtitle: const Text('Página web'),
            onTap: () {
              onExport('html');
              Navigator.of(context).pop();
            },
          ),
        ],
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

class _TitleEditDialog extends StatefulWidget {
  final String currentTitle;
  final Function(String title) onSave;

  const _TitleEditDialog({
    required this.currentTitle,
    required this.onSave,
  });

  @override
  State<_TitleEditDialog> createState() => _TitleEditDialogState();
}

class _TitleEditDialogState extends State<_TitleEditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Título'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Título do documento',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            widget.onSave(value.trim());
            Navigator.of(context).pop();
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final title = _controller.text.trim();
            if (title.isNotEmpty) {
              widget.onSave(title);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _LinkDialog extends StatefulWidget {
  final Function(String url, String text) onInsert;

  const _LinkDialog({required this.onInsert});

  @override
  State<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
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
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'URL',
              hintText: 'https://exemplo.com',
              border: OutlineInputBorder(),
            ),
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

// Widget auxiliar para barra de subpáginas
class _SubPagesBar extends ConsumerWidget {
  final PageModel parentPage;
  final void Function(String pageId) onNavigateToPage;
  final void Function(String parentId) onCreateSubPage;

  const _SubPagesBar({
    required this.parentPage,
    required this.onNavigateToPage,
    required this.onCreateSubPage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = ref.watch(pagesProvider);
    final subPages = pages.where((p) => p.parentId == parentPage.id).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ...subPages.map((page) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  avatar: Text(page.icon ?? '📄',
                      style: const TextStyle(fontSize: 16)),
                  label: Text(page.title, overflow: TextOverflow.ellipsis),
                  onPressed: () => onNavigateToPage(page.id),
                ),
              )),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nova subpágina',
            onPressed: () => onCreateSubPage(parentPage.id),
          ),
        ],
      ),
    );
  }
}
