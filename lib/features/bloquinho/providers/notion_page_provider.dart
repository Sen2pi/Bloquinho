import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notion_block.dart';
import '../services/notion_page_service.dart';

/// Estado das páginas
class NotionPageState {
  final List<NotionPage> pages;
  final NotionPage? currentPage;
  final bool isLoading;
  final String? error;
  final List<NotionPage> recentPages;
  final List<NotionPage> favoritePages;

  const NotionPageState({
    this.pages = const [],
    this.currentPage,
    this.isLoading = false,
    this.error,
    this.recentPages = const [],
    this.favoritePages = const [],
  });

  NotionPageState copyWith({
    List<NotionPage>? pages,
    NotionPage? currentPage,
    bool? isLoading,
    String? error,
    List<NotionPage>? recentPages,
    List<NotionPage>? favoritePages,
    bool clearError = false,
    bool clearCurrentPage = false,
  }) {
    return NotionPageState(
      pages: pages ?? this.pages,
      currentPage: clearCurrentPage ? null : (currentPage ?? this.currentPage),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      recentPages: recentPages ?? this.recentPages,
      favoritePages: favoritePages ?? this.favoritePages,
    );
  }
}

/// Notifier para gerenciar páginas
class NotionPageNotifier extends StateNotifier<NotionPageState> {
  final NotionPageService _pageService;
  String? _currentWorkspaceId;

  NotionPageNotifier(this._pageService) : super(const NotionPageState());

  /// Carregar páginas para um workspace
  Future<void> loadPagesForWorkspace(String workspaceId) async {
    _currentWorkspaceId = workspaceId;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final pages = await _pageService.getPagesForWorkspace(workspaceId);
      final favorites = await _pageService.getFavoritePages(workspaceId);

      // Páginas recentes (últimas 5 modificadas)
      final recent = List<NotionPage>.from(pages)
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt))
        ..take(5);

      state = state.copyWith(
        pages: pages,
        recentPages: recent.toList(),
        favoritePages: favorites,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar páginas: $e',
      );
    }
  }

  /// Obter uma página específica
  Future<NotionPage?> getPage(String pageId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final page = await _pageService.getPage(pageId);
      state = state.copyWith(
        currentPage: page,
        isLoading: false,
      );
      return page;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar página: $e',
      );
      return null;
    }
  }

  /// Criar nova página
  Future<NotionPage?> createPage({
    required String title,
    String emoji = '📄',
    String? parentId,
    List<NotionBlock>? initialBlocks,
  }) async {
    if (_currentWorkspaceId == null) {
      state = state.copyWith(error: 'Nenhum workspace selecionado');
      return null;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final page = await _pageService.createPage(
        title: title,
        emoji: emoji,
        parentId: parentId,
        workspaceId: _currentWorkspaceId!,
        initialBlocks: initialBlocks,
      );

      // Recarregar páginas
      await loadPagesForWorkspace(_currentWorkspaceId!);

      state = state.copyWith(
        currentPage: page,
        isLoading: false,
      );

      return page;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao criar página: $e',
      );
      return null;
    }
  }

  /// Atualizar página
  Future<void> updatePage(NotionPage page) async {
    try {
      await _pageService.updatePage(page);

      // Atualizar no estado local
      final updatedPages = state.pages.map((p) {
        return p.id == page.id ? page : p;
      }).toList();

      state = state.copyWith(
        pages: updatedPages,
        currentPage:
            state.currentPage?.id == page.id ? page : state.currentPage,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao atualizar página: $e',
      );
    }
  }

  /// Atualizar apenas os blocos de uma página
  Future<void> updatePageBlocks(String pageId, List<NotionBlock> blocks) async {
    final page = await _pageService.getPage(pageId);
    if (page != null) {
      final updatedPage = page.copyWith(blocks: blocks);
      await updatePage(updatedPage);
    }
  }

  /// Deletar página
  Future<void> deletePage(String pageId) async {
    try {
      await _pageService.deletePage(pageId);

      if (_currentWorkspaceId != null) {
        await loadPagesForWorkspace(_currentWorkspaceId!);
      }

      // Se a página deletada era a atual, limpar
      if (state.currentPage?.id == pageId) {
        state = state.copyWith(clearCurrentPage: true);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao deletar página: $e',
      );
    }
  }

  /// Duplicar página
  Future<NotionPage?> duplicatePage(String pageId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final duplicatedPage = await _pageService.duplicatePage(pageId);

      if (_currentWorkspaceId != null) {
        await loadPagesForWorkspace(_currentWorkspaceId!);
      }

      state = state.copyWith(
        currentPage: duplicatedPage,
        isLoading: false,
      );

      return duplicatedPage;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao duplicar página: $e',
      );
      return null;
    }
  }

  /// Mover página
  Future<void> movePage(String pageId, String? newParentId) async {
    try {
      await _pageService.movePage(pageId, newParentId);

      if (_currentWorkspaceId != null) {
        await loadPagesForWorkspace(_currentWorkspaceId!);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao mover página: $e',
      );
    }
  }

  /// Alternar favorito
  Future<void> toggleFavorite(String pageId) async {
    try {
      await _pageService.toggleFavorite(pageId);

      if (_currentWorkspaceId != null) {
        await loadPagesForWorkspace(_currentWorkspaceId!);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao alterar favorito: $e',
      );
    }
  }

  /// Buscar páginas
  Future<List<NotionPage>> searchPages(String query) async {
    if (_currentWorkspaceId == null) return [];

    try {
      return await _pageService.searchPages(query, _currentWorkspaceId!);
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao buscar páginas: $e',
      );
      return [];
    }
  }

  /// Obter hierarquia de páginas
  Future<List<NotionPage>> getPageHierarchy() async {
    if (_currentWorkspaceId == null) return [];

    try {
      return await _pageService.getPageHierarchy(_currentWorkspaceId!);
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao obter hierarquia: $e',
      );
      return [];
    }
  }

  /// Obter página raiz do Bloquinho
  NotionPage? get bloquinhoRootPage {
    return state.pages.where((page) => page.isBloquinhoRoot).firstOrNull;
  }

  /// Obter páginas filhas de uma página
  List<NotionPage> getChildPages(String parentId) {
    final parent = state.pages.where((p) => p.id == parentId).firstOrNull;
    if (parent == null) return [];

    return parent.childrenIds
        .map((childId) => state.pages.where((p) => p.id == childId).firstOrNull)
        .where((page) => page != null)
        .cast<NotionPage>()
        .toList();
  }

  /// Obter páginas raiz (sem pai)
  List<NotionPage> get rootPages {
    return state.pages.where((page) => page.isRoot).toList();
  }

  /// Verificar se página tem filhos
  bool hasChildren(String pageId) {
    final page = state.pages.where((p) => p.id == pageId).firstOrNull;
    return page?.hasChildren ?? false;
  }

  /// Limpar erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Exportar workspace
  Future<Map<String, dynamic>?> exportWorkspace() async {
    if (_currentWorkspaceId == null) return null;

    try {
      return await _pageService.exportWorkspace(_currentWorkspaceId!);
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao exportar workspace: $e',
      );
      return null;
    }
  }

  /// Importar workspace
  Future<void> importWorkspace(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _pageService.importWorkspace(data);

      if (_currentWorkspaceId != null) {
        await loadPagesForWorkspace(_currentWorkspaceId!);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao importar workspace: $e',
      );
    }
  }
}

// Providers
final notionPageServiceProvider = Provider<NotionPageService>((ref) {
  return NotionPageService();
});

final notionPageProvider =
    StateNotifierProvider<NotionPageNotifier, NotionPageState>((ref) {
  final service = ref.watch(notionPageServiceProvider);
  return NotionPageNotifier(service);
});

// Providers derivados
final currentNotionPageProvider = Provider<NotionPage?>((ref) {
  return ref.watch(notionPageProvider).currentPage;
});

final notionPagesListProvider = Provider<List<NotionPage>>((ref) {
  return ref.watch(notionPageProvider).pages;
});

final favoriteNotionPagesProvider = Provider<List<NotionPage>>((ref) {
  return ref.watch(notionPageProvider).favoritePages;
});

final recentNotionPagesProvider = Provider<List<NotionPage>>((ref) {
  return ref.watch(notionPageProvider).recentPages;
});

final isNotionPageLoadingProvider = Provider<bool>((ref) {
  return ref.watch(notionPageProvider).isLoading;
});

final notionPageErrorProvider = Provider<String?>((ref) {
  return ref.watch(notionPageProvider).error;
});

final bloquinhoRootPageProvider = Provider<NotionPage?>((ref) {
  return ref.watch(notionPageProvider.notifier).bloquinhoRootPage;
});

final rootNotionPagesProvider = Provider<List<NotionPage>>((ref) {
  return ref.watch(notionPageProvider.notifier).rootPages;
});

// Provider para hierarquia de páginas
final notionPageHierarchyProvider =
    FutureProvider<List<NotionPage>>((ref) async {
  final notifier = ref.watch(notionPageProvider.notifier);
  return await notifier.getPageHierarchy();
});

// Provider para busca de páginas
final searchNotionPagesProvider =
    FutureProvider.family<List<NotionPage>, String>((ref, query) async {
  final notifier = ref.watch(notionPageProvider.notifier);
  return await notifier.searchPages(query);
});

// Provider para páginas filhas
final childNotionPagesProvider =
    Provider.family<List<NotionPage>, String>((ref, parentId) {
  final notifier = ref.watch(notionPageProvider.notifier);
  return notifier.getChildPages(parentId);
});
