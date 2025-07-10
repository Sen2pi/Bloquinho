import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/page_models.dart';
import '../services/page_service.dart';

/// Estado das páginas
class PageState {
  final List<BloqPage> pages;
  final List<PageTreeNode> pageTree;
  final BloqPage? currentPage;
  final bool isLoading;
  final String? error;
  final String? currentWorkspaceId;

  const PageState({
    this.pages = const [],
    this.pageTree = const [],
    this.currentPage,
    this.isLoading = false,
    this.error,
    this.currentWorkspaceId,
  });

  PageState copyWith({
    List<BloqPage>? pages,
    List<PageTreeNode>? pageTree,
    BloqPage? currentPage,
    bool? isLoading,
    String? error,
    String? currentWorkspaceId,
    bool clearError = false,
    bool clearCurrentPage = false,
  }) {
    return PageState(
      pages: pages ?? this.pages,
      pageTree: pageTree ?? this.pageTree,
      currentPage: clearCurrentPage ? null : (currentPage ?? this.currentPage),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentWorkspaceId: currentWorkspaceId ?? this.currentWorkspaceId,
    );
  }
}

/// Notifier para gerenciar páginas
class PageNotifier extends StateNotifier<PageState> {
  final PageService _pageService;

  PageNotifier(this._pageService) : super(const PageState());

  /// Carregar páginas de um workspace
  Future<void> loadPagesForWorkspace(String workspaceId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _pageService.initialize();
      final pages = await _pageService.getPagesByWorkspace(workspaceId);
      final pageTree = PageUtils.buildPageTree(pages);

      state = state.copyWith(
        pages: pages,
        pageTree: pageTree,
        currentWorkspaceId: workspaceId,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar páginas: $e',
      );
    }
  }

  /// Criar nova página
  Future<BloqPage?> createPage({
    required String title,
    String emoji = '📄',
    String? parentId,
    List<String> tags = const [],
  }) async {
    if (state.currentWorkspaceId == null) return null;

    try {
      final page = BloqPage.create(
        title: title,
        emoji: emoji,
        parentId: parentId,
        tags: tags,
        workspaceId: state.currentWorkspaceId!,
      );

      final createdPage = await _pageService.createPage(page);

      // Recarregar páginas para atualizar a árvore
      await loadPagesForWorkspace(state.currentWorkspaceId!);

      return createdPage;
    } catch (e) {
      state = state.copyWith(error: 'Erro ao criar página: $e');
      return null;
    }
  }

  /// Atualizar página
  Future<void> updatePage(BloqPage page) async {
    try {
      await _pageService.updatePage(page);

      // Atualizar na lista local
      final updatedPages = state.pages.map((p) {
        return p.id == page.id ? page : p;
      }).toList();

      final updatedTree = PageUtils.buildPageTree(updatedPages);

      state = state.copyWith(
        pages: updatedPages,
        pageTree: updatedTree,
        currentPage:
            state.currentPage?.id == page.id ? page : state.currentPage,
      );
    } catch (e) {
      state = state.copyWith(error: 'Erro ao atualizar página: $e');
    }
  }

  /// Deletar página
  Future<void> deletePage(String pageId) async {
    try {
      await _pageService.deletePage(pageId);

      // Recarregar páginas
      if (state.currentWorkspaceId != null) {
        await loadPagesForWorkspace(state.currentWorkspaceId!);
      }

      // Limpar página atual se foi deletada
      if (state.currentPage?.id == pageId) {
        state = state.copyWith(clearCurrentPage: true);
      }
    } catch (e) {
      state = state.copyWith(error: 'Erro ao deletar página: $e');
    }
  }

  /// Mover página
  Future<void> movePage(String pageId, String? newParentId) async {
    try {
      await _pageService.movePage(pageId, newParentId);

      // Recarregar páginas para atualizar a árvore
      if (state.currentWorkspaceId != null) {
        await loadPagesForWorkspace(state.currentWorkspaceId!);
      }
    } catch (e) {
      state = state.copyWith(error: 'Erro ao mover página: $e');
    }
  }

  /// Definir página atual
  void setCurrentPage(BloqPage page) {
    state = state.copyWith(currentPage: page);
  }

  /// Carregar página específica
  Future<void> loadPage(String pageId) async {
    try {
      final page = await _pageService.getPageById(pageId);
      if (page != null) {
        state = state.copyWith(currentPage: page);
      }
    } catch (e) {
      state = state.copyWith(error: 'Erro ao carregar página: $e');
    }
  }

  /// Alternar favorito
  Future<void> toggleFavorite(String pageId) async {
    try {
      await _pageService.toggleFavorite(pageId);

      // Atualizar página na lista
      final updatedPages = state.pages.map((page) {
        if (page.id == pageId) {
          return page.copyWith(isFavorite: !page.isFavorite);
        }
        return page;
      }).toList();

      state = state.copyWith(pages: updatedPages);
    } catch (e) {
      state = state.copyWith(error: 'Erro ao alternar favorito: $e');
    }
  }

  /// Buscar páginas
  Future<List<BloqPage>> searchPages(String query) async {
    if (state.currentWorkspaceId == null) return [];

    try {
      return await _pageService.searchPagesByTitle(
          state.currentWorkspaceId!, query);
    } catch (e) {
      state = state.copyWith(error: 'Erro ao buscar páginas: $e');
      return [];
    }
  }

  /// Expandir/colapsar nó na árvore
  void toggleNodeExpansion(String pageId) {
    final updatedTree = PageUtils.toggleNodeExpansion(state.pageTree, pageId);
    state = state.copyWith(pageTree: updatedTree);
  }

  /// Exportar dados do workspace
  Future<Map<String, dynamic>?> exportWorkspaceData() async {
    if (state.currentWorkspaceId == null) return null;

    try {
      return await _pageService.exportWorkspaceData(state.currentWorkspaceId!);
    } catch (e) {
      state = state.copyWith(error: 'Erro ao exportar dados: $e');
      return null;
    }
  }

  /// Importar dados do workspace
  Future<void> importWorkspaceData(Map<String, dynamic> data) async {
    if (state.currentWorkspaceId == null) return;

    try {
      await _pageService.importWorkspaceData(data, state.currentWorkspaceId!);

      // Recarregar páginas
      await loadPagesForWorkspace(state.currentWorkspaceId!);
    } catch (e) {
      state = state.copyWith(error: 'Erro ao importar dados: $e');
    }
  }

  /// Limpar erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider do serviço de páginas
final pageServiceProvider = Provider<PageService>((ref) {
  return PageService();
});

/// Provider principal das páginas
final pageProvider = StateNotifierProvider<PageNotifier, PageState>((ref) {
  final pageService = ref.watch(pageServiceProvider);
  return PageNotifier(pageService);
});

/// Provider derivado: páginas atuais
final currentPagesProvider = Provider<List<BloqPage>>((ref) {
  return ref.watch(pageProvider).pages;
});

/// Provider derivado: árvore de páginas
final pageTreeProvider = Provider<List<PageTreeNode>>((ref) {
  return ref.watch(pageProvider).pageTree;
});

/// Provider derivado: página atual
final currentPageProvider = Provider<BloqPage?>((ref) {
  return ref.watch(pageProvider).currentPage;
});

/// Provider derivado: páginas raiz
final rootPagesProvider = Provider<List<BloqPage>>((ref) {
  final pages = ref.watch(currentPagesProvider);
  return pages.where((page) => page.isRoot).toList();
});

/// Provider derivado: páginas favoritas
final favoritePagesProvider = Provider<List<BloqPage>>((ref) {
  final pages = ref.watch(currentPagesProvider);
  return pages.where((page) => page.isFavorite).toList();
});

/// Provider derivado: se está carregando
final isPageLoadingProvider = Provider<bool>((ref) {
  return ref.watch(pageProvider).isLoading;
});

/// Provider derivado: erro atual
final pageErrorProvider = Provider<String?>((ref) {
  return ref.watch(pageProvider).error;
});

/// Provider de páginas filhas de uma página específica
final childPagesProvider =
    Provider.family<List<BloqPage>, String>((ref, parentId) {
  final pages = ref.watch(currentPagesProvider);
  return pages.where((page) => page.parentId == parentId).toList();
});

/// Provider para contar total de páginas
final pagesTotalCountProvider = Provider<int>((ref) {
  return ref.watch(currentPagesProvider).length;
});

/// Provider para contar páginas raiz
final rootPagesCountProvider = Provider<int>((ref) {
  return ref.watch(rootPagesProvider).length;
});
