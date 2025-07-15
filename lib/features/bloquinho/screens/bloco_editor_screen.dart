/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

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
import '../widgets/colored_text_widget.dart';
import '../widgets/dynamic_colored_text.dart';
import '../widgets/color_demo_widget.dart';
import '../providers/pages_provider.dart';
import '../models/page_model.dart';
import '../../../core/constants/page_icons.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';
import 'package:flutter/rendering.dart';
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

  // Limite para a pilha de navegação
  static const int _navigationStackLimit = 20;

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
        if (_navigationStack.length > _navigationStackLimit) {
          _navigationStack.removeAt(0);
        }
      }
    });
  }

  // Cache simples para conteúdo de página
  final Map<String, String> _pageContentCache = {};

  // Métodos para carregar e salvar conteúdo em arquivos .md
  Future<String> loadPageContent(String pageId) async {
    if (_pageContentCache.containsKey(pageId)) {
      return _pageContentCache[pageId]!;
    }
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
      final content = page?.content ?? '';
      _pageContentCache[pageId] = content;
      return content;
    } catch (e) {
      return '';
    }
  }

  Future<void> savePageContent(String pageId, String content) async {
    final strings = ref.read(appStringsProvider);
    try {
      final currentProfile = ref.read(currentProfileProvider);
      final currentWorkspace = ref.read(currentWorkspaceProvider);

      if (currentProfile == null || currentWorkspace == null) {
        return;
      }

      final pages = ref.read(pagesProvider((
        profileName: currentProfile.name,
        workspaceName: currentWorkspace.name
      )));
      final page = pages.firstWhere(
        (p) => p.id == pageId,
        orElse: () => PageModel.create(title: strings.pageNotFound),
      );

      final updatedPage = page.copyWith(
        content: content,
        updatedAt: DateTime.now(),
      );

      final bloquinhoStorage = BloquinhoStorageService();
      await bloquinhoStorage.initialize();

      await bloquinhoStorage.savePage(
          updatedPage, currentProfile.name, currentWorkspace.name);
    } catch (e) {
      // Erro ao salvar
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
    final strings = ref.read(appStringsProvider);
    try {
      // Se não tem documentId, criar página raiz
      if (widget.documentId == null) {
        final currentProfile = ref.read(currentProfileProvider);
        final currentWorkspace = ref.read(currentWorkspaceProvider);

        if (currentProfile != null && currentWorkspace != null) {
          final pagesNotifier = ref.read(pagesNotifierProvider((
            profileName: currentProfile.name,
            workspaceName: currentWorkspace.name
          )));
          final newPage = PageModel.create(
            title: widget.documentTitle ?? strings.newPage,
          );
          pagesNotifier.state = [...pagesNotifier.state, newPage];
          _currentPageId = newPage.id;
          _navigationStack = [newPage.id];
        }
      } else {
        _currentPageId = widget.documentId!;
        _navigationStack = [widget.documentId!];
      }

      await ref.read(editorControllerProvider.notifier).initialize(
            documentId: _currentPageId,
            documentTitle: widget.documentTitle ?? strings.newPage,
            isReadOnly: widget.isReadOnly,
            settings: {
              'showLineNumbers': _showLineNumbers,
              'zoomLevel': _zoomLevel,
            },
            strings: strings,
          );
    } catch (e) {
      _showErrorSnackBar('${strings.errorInitializingEditor}: ${e.toString()}');
    }
  }

  void _navigateToPage(String pageId) {
    setState(() {
      _currentPageId = pageId;
      if (!_navigationStack.contains(pageId)) {
        _navigationStack.add(pageId);
        if (_navigationStack.length > _navigationStackLimit) {
          _navigationStack.removeAt(0);
        }
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
    final strings = ref.read(appStringsProvider);
    final currentProfile = ref.read(currentProfileProvider);
    final currentWorkspace = ref.read(currentWorkspaceProvider);

    if (currentProfile != null && currentWorkspace != null) {
      final pagesNotifier = ref.read(pagesNotifierProvider((
        profileName: currentProfile.name,
        workspaceName: currentWorkspace.name
      )));
      final newPage = PageModel.create(
        title: strings.newSubpage,
        parentId: parentId,
      );
      pagesNotifier.state = [...pagesNotifier.state, newPage];
      _navigateToPage(newPage.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final editorState = ref.watch(editorControllerProvider);
    final currentWorkspace = ref.watch(currentWorkspaceProvider);
    final currentProfile = ref.watch(currentProfileProvider);
    final strings = ref.watch(appStringsProvider);

    if (currentProfile != null && currentWorkspace != null) {
      final pages = ref.watch(pagesProvider((
        profileName: currentProfile.name,
        workspaceName: currentWorkspace.name
      )));
      final currentPage = pages.firstWhere(
        (p) => p.id == _currentPageId,
        orElse: () => PageModel.create(title: strings.pageNotFound),
      );

      return Theme(
        data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
        child: Scaffold(
          backgroundColor:
              isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
          appBar: _isFullscreen
              ? null
              : _buildAppBar(isDarkMode, editorState, currentPage, strings),
          body: _buildBody(isDarkMode, editorState, currentPage, strings),
          floatingActionButton:
              _buildFloatingActionButton(editorState, strings),
          bottomNavigationBar:
              _buildBottomBar(isDarkMode, editorState, strings),
        ),
      );
    }

    // Fallback quando não há contexto
    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(title: Text(strings.errorNoContext)),
        body: Center(child: Text(strings.errorProfileOrWorkspaceNotAvailable)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      bool isDarkMode,
      EditorControllerState editorState,
      PageModel? currentPage,
      AppStrings strings) {
    return AppBar(
      elevation: 0,
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      foregroundColor:
          isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: strings.back,
      ),
      titleSpacing: 0,
      title: _buildTitleSection(editorState, currentPage, strings),
      actions: _buildAppBarActions(isDarkMode, editorState, strings),
      bottom: _isSearchVisible ? _buildSearchBar(strings) : null,
      toolbarHeight: 80, // Aumentar altura do header
    );
  }

  Widget _buildTitleSection(EditorControllerState editorState,
      PageModel? currentPage, AppStrings strings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb de navegação
          if (_navigationStack.length > 1)
            Container(
              height: 32,
              child: Row(
                children: [
                  IconButton(
                    onPressed: _navigateBack,
                    icon: Icon(PhosphorIcons.arrowLeft(), size: 16),
                    tooltip: strings.back,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _navigationStack.asMap().entries.map((entry) {
                          final index = entry.key;
                          final pageId = entry.value;
                          final currentProfile =
                              ref.read(currentProfileProvider);
                          final currentWorkspace =
                              ref.read(currentWorkspaceProvider);

                          List<PageModel> pages = [];
                          if (currentProfile != null &&
                              currentWorkspace != null) {
                            pages = ref.read(pagesProvider((
                              profileName: currentProfile.name,
                              workspaceName: currentWorkspace.name
                            )));
                          }
                          PageModel? page;
                          try {
                            page = pages.firstWhere((p) => p.id == pageId);
                          } catch (e) {
                            page = null;
                          }

                          return Row(
                            children: [
                              if (index > 0)
                                Icon(PhosphorIcons.caretRight(), size: 14),
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
                                    page?.title ?? strings.page,
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
            ),

          // Título e ícone da página atual
          Container(
            height: 40,
            child: Row(
              children: [
                // Seletor de ícone
                if (currentPage != null)
                  GestureDetector(
                    onTap: () => _showIconSelector(currentPage, strings),
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
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                const SizedBox(width: 12),

                // Título editável
                Expanded(
                  child: GestureDetector(
                    onTap: () => _editPageTitle(currentPage, strings),
                    child: Text(
                      currentPage?.title ?? strings.untitledPage,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // Status de salvamento
                if (editorState.isSaving)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.orange),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          strings.saving,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (editorState.lastSaved != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIcons.checkCircle(),
                          size: 12,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          strings.saved,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showIconSelector(PageModel page, AppStrings strings) {
    final icons = PageIcons.availableIcons;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.chooseIcon),
        content: Container(
          width: 300,
          height: 400, // Aumentar altura para acomodar mais ícones
          child: SingleChildScrollView(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                    final currentProfile = ref.read(currentProfileProvider);
                    final currentWorkspace = ref.read(currentWorkspaceProvider);

                    if (currentProfile != null && currentWorkspace != null) {
                      final pagesNotifier = ref.read(pagesNotifierProvider((
                        profileName: currentProfile.name,
                        workspaceName: currentWorkspace.name
                      )));
                      pagesNotifier.updatePage(
                        page.id,
                        icon: icon,
                      );
                    }
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
        ],
      ),
    );
  }

  void _editPageTitle(PageModel? page, AppStrings strings) {
    if (page == null) return;

    // Remover foco do editor antes de abrir o diálogo
    FocusScope.of(context).unfocus();

    final titleController = TextEditingController(text: page.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.editTitle),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: strings.pageTitle,
            hintText: strings.typeTitle,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                final currentProfile = ref.read(currentProfileProvider);
                final currentWorkspace = ref.read(currentWorkspaceProvider);

                if (currentProfile != null && currentWorkspace != null) {
                  final pagesNotifier = ref.read(pagesNotifierProvider((
                    profileName: currentProfile.name,
                    workspaceName: currentWorkspace.name
                  )));
                  pagesNotifier.updatePage(
                    page.id,
                    title: titleController.text.trim(),
                  );
                }
                Navigator.of(context).pop();
              }
            },
            child: Text(strings.save),
          ),
        ],
      ),
    ).then((_) {
      // Após fechar o diálogo, devolver o foco ao editor principal
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          FocusScope.of(context).requestFocus(_editorFocusNode);
        }
      });
    });
  }

  Widget _buildBody(bool isDarkMode, EditorControllerState editorState,
      PageModel? currentPage, AppStrings strings) {
    if (editorState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (editorState.error != null) {
      return _buildErrorView(editorState.error!, strings);
    }
    if (!editorState.isInitialized) {
      return Center(
        child: Text(strings.editorNotInitialized),
      );
    }
    // Usar Consumer para granularidade em PageContentWidget
    return Column(
      children: [
        if (currentPage != null)
          _SubPagesBar(
            parentPage: currentPage,
            onNavigateToPage: _navigateToPage,
            onCreateSubPage: _createSubPage,
          ),
        Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              return RepaintBoundary(
                child: PageContentWidget(
                  pageId: currentPage?.id ?? '',
                  isEditing: false,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEditor(
      bool isDarkMode, EditorControllerState editorState, AppStrings strings) {
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
            hintText: strings.startWriting,
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

  Widget _buildErrorView(String error, AppStrings strings) {
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
            strings.editorError,
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
            child: Text(strings.tryAgain),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(
      EditorControllerState editorState, AppStrings strings) {
    if (_isFullscreen || !editorState.canEdit) return null;

    return FloatingActionButton(
      onPressed: _showBlockMenu,
      tooltip: strings.insertBlock,
      child: Icon(PhosphorIcons.plus()),
    );
  }

  Widget? _buildBottomBar(
      bool isDarkMode, EditorControllerState editorState, AppStrings strings) {
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
            _buildStatsText(editorState, strings),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const Spacer(),
          // Posição do cursor
          if (editorState.selection != null)
            Text(
              strings.lineAndColumn(editorState.selection!.start + 1, 0),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
        ],
      ),
    );
  }

  String _buildStatsText(
      EditorControllerState editorState, AppStrings strings) {
    final stats =
        ref.read(editorControllerProvider.notifier).getDocumentStats();
    final wordCount = stats['wordCount'] ?? 0;
    final charCount = stats['characterCount'] ?? 0;
    final lineCount = stats['lineCount'] ?? 0;

    return '${strings.wordAndCharCount(wordCount, charCount)} • Linhas: $lineCount';
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

  void _showSearchResults(
      List<Map<String, dynamic>> results, AppStrings strings) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.resultsFound(results.length)),
        action: SnackBarAction(
          label: strings.closeButton,
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
    final strings = ref.read(appStringsProvider);
    try {
      await ref.read(editorControllerProvider.notifier).saveDocument();
      _showSuccessSnackBar(strings.documentSavedSuccessfully);
    } catch (e) {
      _showErrorSnackBar(strings.errorSavingDocument(e.toString()));
    }
  }

  Future<void> _exportDocumentWithPdfCapture(
      PageModel currentPage, AppStrings strings) async {
    try {
      final key = GlobalKey();
      final widgetToCapture = Material(
        type: MaterialType.transparency,
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(20),
          child: RepaintBoundary(
            key: key,
            child: PageContentWidget(
              pageId: currentPage.id,
              isEditing: false,
            ),
          ),
        ),
      );

      // Renderizar widget offstage
      final boundary = await _captureWidgetAsImage(widgetToCapture, key);
      if (boundary == null) throw Exception('Erro ao capturar widget para PDF');

      // Gerar PDF
      final pdfExportService = ref.read(pdfExportServiceProvider);
      final file = await pdfExportService.exportImageToPdf(
        imageBytes: boundary,
        title: currentPage.title,
        strings: strings,
      );
      _showSuccessSnackBar(
          '${strings.documentExportedSuccessfully} - ${file.path}');
    } catch (e) {
      _showErrorSnackBar('${strings.errorExportingDocument}: ${e.toString()}');
    }
  }

  Future<Uint8List?> _captureWidgetAsImage(Widget widget, GlobalKey key) async {
    final repaintBoundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (repaintBoundary != null) {
      final image = await repaintBoundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    }
    return null;
  }

  void _exportDocument() {
    final strings = ref.read(appStringsProvider);
    final currentProfile = ref.read(currentProfileProvider);
    final currentWorkspace = ref.read(currentWorkspaceProvider);

    if (currentProfile == null || currentWorkspace == null) {
      _showErrorSnackBar(strings.errorProfileOrWorkspaceNotAvailable);
      return;
    }

    final pages = ref.read(pagesProvider((
      profileName: currentProfile.name,
      workspaceName: currentWorkspace.name
    )));
    final currentPage = pages.firstWhere(
      (p) => p.id == _currentPageId,
      orElse: () => PageModel.create(title: strings.pageNotFound),
    );

    showDialog(
      context: context,
      builder: (context) => _ExportDialog(
        onExport: (format) async {
          try {
            if (format == 'pdf') {
              await _exportDocumentWithPdfCapture(currentPage, strings);
            } else {
              // Para outros formatos (markdown, html)
              final data = await ref
                  .read(editorControllerProvider.notifier)
                  .exportDocument(format: format);
              _showSuccessSnackBar(strings.documentExportedSuccessfully);
            }
          } catch (e) {
            _showErrorSnackBar(
                '${strings.errorExportingDocument}: ${e.toString()}');
          }
        },
      ),
    );
  }

  Widget _buildContentWidgetForExport(PageModel page) {
    // Renderizar o preview real da página para exportação PDF
    return Container(
      width: 800, // Largura fixa para PDF
      padding: const EdgeInsets.all(20),
      child: RepaintBoundary(
        child: PageContentWidget(
          pageId: page.id,
          isEditing: false,
        ),
      ),
    );
  }

  void _importDocument() {
    final strings = ref.read(appStringsProvider);
    // TODO: Implementar importação de documento
    _showInfoSnackBar(strings.featureInDevelopment);
  }

  void _shareDocument() {
    final strings = ref.read(appStringsProvider);
    // TODO: Implementar compartilhamento
    _showInfoSnackBar(strings.featureInDevelopment);
  }

  void _showSettings() {
    final strings = ref.read(appStringsProvider);
    // TODO: Implementar configurações do editor
    _showInfoSnackBar(strings.featureInDevelopment);
  }

  void _editDocumentTitle(
      EditorControllerState editorState, AppStrings strings) {
    showDialog(
      context: context,
      builder: (context) => _TitleEditDialog(
        currentTitle: editorState.documentTitle ?? '',
        onSave: (newTitle) {
          // TODO: Implementar atualização do título
          _showSuccessSnackBar(strings.titleUpdatedSuccessfully);
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
    final strings = ref.read(appStringsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: strings.closeButton,
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    final strings = ref.read(appStringsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: strings.closeButton,
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    final strings = ref.read(appStringsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: strings.closeButton,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions(
      bool isDarkMode, EditorControllerState editorState, AppStrings strings) {
    return [
      // Buscar
      IconButton(
        onPressed: () => _toggleSearch(),
        icon: Icon(PhosphorIcons.magnifyingGlass()),
        tooltip: strings.search,
      ),

      // Desfazer/Refazer
      IconButton(
        onPressed: editorState.canUndo
            ? () => ref.read(editorControllerProvider.notifier).undo()
            : null,
        icon: Icon(PhosphorIcons.arrowCounterClockwise()),
        tooltip: strings.undo,
      ),
      IconButton(
        onPressed: editorState.canRedo
            ? () => ref.read(editorControllerProvider.notifier).redo()
            : null,
        icon: Icon(PhosphorIcons.arrowClockwise()),
        tooltip: strings.redo,
      ),

      // Zoom
      PopupMenuButton<double>(
        onSelected: (zoom) => _setZoomLevel(zoom),
        icon: Icon(PhosphorIcons.magnifyingGlassPlus()),
        tooltip: strings.zoom,
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
                Text(strings.save),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'export',
            child: Row(
              children: [
                Icon(PhosphorIcons.export()),
                const SizedBox(width: 8),
                Text(strings.export),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  PreferredSize _buildSearchBar(AppStrings strings) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: TextField(
          autofocus: true,
          onChanged: (query) => setState(() => _searchQuery = query),
          onSubmitted: _performSearch,
          decoration: InputDecoration(
            hintText: strings.searchInDocument,
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

class _ExportDialog extends ConsumerWidget {
  final Function(String format) onExport;

  const _ExportDialog({required this.onExport});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    return AlertDialog(
      title: Text(strings.exportDocument),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(PhosphorIcons.fileText()),
            title: Text(strings.markdown),
            subtitle: Text(strings.plainTextFormat),
            onTap: () {
              onExport('markdown');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(PhosphorIcons.filePdf()),
            title: Text(strings.pdf),
            subtitle: Text(strings.portableDocument),
            onTap: () {
              onExport('pdf');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(PhosphorIcons.fileHtml()),
            title: Text(strings.html),
            subtitle: Text(strings.webPage),
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
          child: Text(strings.cancel),
        ),
      ],
    );
  }
}

class _TitleEditDialog extends ConsumerStatefulWidget {
  final String currentTitle;
  final Function(String title) onSave;

  const _TitleEditDialog({
    required this.currentTitle,
    required this.onSave,
  });

  @override
  ConsumerState<_TitleEditDialog> createState() => _TitleEditDialogState();
}

class _TitleEditDialogState extends ConsumerState<_TitleEditDialog> {
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
    final strings = ref.watch(appStringsProvider);
    return AlertDialog(
      title: Text(strings.editTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: strings.documentTitle,
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
          child: Text(strings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final title = _controller.text.trim();
            if (title.isNotEmpty) {
              widget.onSave(title);
              Navigator.of(context).pop();
            }
          },
          child: Text(strings.save),
        ),
      ],
    );
  }
}

class _LinkDialog extends ConsumerStatefulWidget {
  final Function(String url, String text) onInsert;

  const _LinkDialog({required this.onInsert});

  @override
  ConsumerState<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends ConsumerState<_LinkDialog> {
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
    final strings = ref.watch(appStringsProvider);
    return AlertDialog(
      title: Text(strings.insertLink),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _urlController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'URL',
              hintText: 'https://exemplo.com',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: strings.linkTextOptional,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.cancel),
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
          child: Text(strings.insert),
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
    final currentProfile = ref.watch(currentProfileProvider);
    final currentWorkspace = ref.watch(currentWorkspaceProvider);
    final strings = ref.watch(appStringsProvider);

    List<PageModel> pages = [];
    if (currentProfile != null && currentWorkspace != null) {
      pages = ref.watch(pagesProvider((
        profileName: currentProfile.name,
        workspaceName: currentWorkspace.name
      )));
    }
    final subPages = pages.where((p) => p.parentId == parentPage.id).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...subPages.map((page) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          avatar: Text(page.icon ?? '📄',
                              style: const TextStyle(fontSize: 16)),
                          label:
                              Text(page.title, overflow: TextOverflow.ellipsis),
                          onPressed: () => onNavigateToPage(page.id),
                        ),
                      )),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: strings.newSubpage,
            onPressed: () => onCreateSubPage(parentPage.id),
          ),
        ],
      ),
    );
  }
}
