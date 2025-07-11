import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' as math;
import '../models/page_model.dart';

/// Provider para gerenciar páginas
class PagesNotifier extends StateNotifier<List<PageModel>> {
  PagesNotifier() : super([]) {
    _initializePages();
  }

  /// Inicializar páginas padrão
  void _initializePages() {
    final bloquinhoRoot = PageModel.create(
      title: 'Bloquinho',
      content: 'Página raiz do Bloquinho',
    );

    state = [bloquinhoRoot];
  }

  /// Adicionar nova página
  void addPage({
    required String title,
    String? content,
    String? parentId,
  }) {
    final newPage = PageModel.create(
      title: title,
      content: content,
      parentId: parentId,
      order: _getNextOrder(parentId),
    );

    // Atualizar lista de filhos do pai
    if (parentId != null) {
      final parentIndex = state.indexWhere((page) => page.id == parentId);
      if (parentIndex != -1) {
        final parent = state[parentIndex];
        final updatedParent = parent.copyWith(
          childrenIds: [...parent.childrenIds, newPage.id],
        );

        state = [
          ...state.sublist(0, parentIndex),
          updatedParent,
          ...state.sublist(parentIndex + 1),
          newPage,
        ];
      } else {
        state = [...state, newPage];
      }
    } else {
      state = [...state, newPage];
    }
  }

  /// Obter próximo número de ordem
  int _getNextOrder(String? parentId) {
    final siblings = state.where((page) => page.parentId == parentId).toList();
    if (siblings.isEmpty) return 0;
    return siblings.map((page) => page.order).reduce((a, b) => math.max(a, b)) +
        1;
  }

  /// Atualizar página
  void updatePage(
    String pageId, {
    String? title,
    String? content,
    Map<String, dynamic>? metadata,
  }) {
    final pageIndex = state.indexWhere((page) => page.id == pageId);
    if (pageIndex == -1) return;

    final page = state[pageIndex];
    final updatedPage = page.copyWith(
      title: title ?? page.title,
      content: content ?? page.content,
      metadata: metadata ?? page.metadata,
      updatedAt: DateTime.now(),
    );

    state = [
      ...state.sublist(0, pageIndex),
      updatedPage,
      ...state.sublist(pageIndex + 1),
    ];
  }

  /// Remover página
  void removePage(String pageId) {
    final page = state.firstWhere((p) => p.id == pageId);

    // Remover da lista de filhos do pai
    if (page.parentId != null) {
      final parentIndex = state.indexWhere((p) => p.id == page.parentId);
      if (parentIndex != -1) {
        final parent = state[parentIndex];
        final updatedParent = parent.copyWith(
          childrenIds: parent.childrenIds.where((id) => id != pageId).toList(),
        );

        state = [
          ...state.sublist(0, parentIndex),
          updatedParent,
          ...state.sublist(parentIndex + 1),
        ];
      }
    }

    // Remover a página e todos os seus descendentes
    final descendants = _getAllDescendants(pageId);
    final idsToRemove = {pageId, ...descendants.map((p) => p.id)};

    state = state.where((page) => !idsToRemove.contains(page.id)).toList();
  }

  /// Obter todos os descendentes de uma página
  List<PageModel> _getAllDescendants(String pageId) {
    final descendants = <PageModel>[];
    final toProcess = <String>[pageId];

    while (toProcess.isNotEmpty) {
      final currentId = toProcess.removeAt(0);
      final children =
          state.where((page) => page.parentId == currentId).toList();

      for (final child in children) {
        descendants.add(child);
        toProcess.add(child.id);
      }
    }

    return descendants;
  }

  /// Mover página
  void movePage(String pageId, String? newParentId) {
    final pageIndex = state.indexWhere((page) => page.id == pageId);
    if (pageIndex == -1) return;

    final page = state[pageIndex];
    final oldParentId = page.parentId;

    // Verificar se não está tentando mover para um descendente
    if (newParentId != null && _isDescendant(newParentId, pageId)) {
      return;
    }

    // Remover da lista de filhos do pai antigo
    if (oldParentId != null) {
      final oldParentIndex = state.indexWhere((p) => p.id == oldParentId);
      if (oldParentIndex != -1) {
        final oldParent = state[oldParentIndex];
        final updatedOldParent = oldParent.copyWith(
          childrenIds:
              oldParent.childrenIds.where((id) => id != pageId).toList(),
        );

        state = [
          ...state.sublist(0, oldParentIndex),
          updatedOldParent,
          ...state.sublist(oldParentIndex + 1),
        ];
      }
    }

    // Adicionar à lista de filhos do novo pai
    if (newParentId != null) {
      final newParentIndex = state.indexWhere((p) => p.id == newParentId);
      if (newParentIndex != -1) {
        final newParent = state[newParentIndex];
        final updatedNewParent = newParent.copyWith(
          childrenIds: [...newParent.childrenIds, pageId],
        );

        state = [
          ...state.sublist(0, newParentIndex),
          updatedNewParent,
          ...state.sublist(newParentIndex + 1),
        ];
      }
    }

    // Atualizar a página
    final updatedPage = page.copyWith(
      parentId: newParentId,
      order: _getNextOrder(newParentId),
      updatedAt: DateTime.now(),
    );

    final currentPageIndex = state.indexWhere((p) => p.id == pageId);
    if (currentPageIndex != -1) {
      state = [
        ...state.sublist(0, currentPageIndex),
        updatedPage,
        ...state.sublist(currentPageIndex + 1),
      ];
    }
  }

  /// Verificar se uma página é descendente de outra
  bool _isDescendant(String pageId, String ancestorId) {
    final descendants = _getAllDescendants(ancestorId);
    return descendants.any((page) => page.id == pageId);
  }

  /// Buscar páginas
  List<PageModel> searchPages(String query) {
    final lowercaseQuery = query.toLowerCase();
    return state.where((page) {
      return page.title.toLowerCase().contains(lowercaseQuery) ||
          (page.content?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  /// Obter página por ID
  PageModel? getPage(String pageId) {
    try {
      return state.firstWhere((page) => page.id == pageId);
    } catch (e) {
      return null;
    }
  }

  /// Obter filhos de uma página
  List<PageModel> getChildren(String parentId) {
    return state.where((page) => page.parentId == parentId).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Obter páginas raiz
  List<PageModel> getRootPages() {
    return state.where((page) => page.isRoot).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Obter árvore de páginas
  PageTree getPageTree() {
    final bloquinhoRoot = state.firstWhere(
      (page) => page.isBloquinhoRoot,
      orElse: () => state.first,
    );

    return PageTree(
      pages: state,
      rootPageId: bloquinhoRoot.id,
    );
  }

  /// Obter estatísticas
  Map<String, dynamic> getStats() {
    final totalPages = state.length;
    final rootPages = state.where((p) => p.isRoot).length;
    final subPages = state.where((p) => p.isSubPage).length;
    final archivedPages = state.where((p) => p.isArchived).length;

    return {
      'totalPages': totalPages,
      'rootPages': rootPages,
      'subPages': subPages,
      'archivedPages': archivedPages,
      'activePages': totalPages - archivedPages,
    };
  }

  /// Arquivar/desarquivar página
  void toggleArchive(String pageId) {
    final pageIndex = state.indexWhere((page) => page.id == pageId);
    if (pageIndex == -1) return;

    final page = state[pageIndex];
    final updatedPage = page.copyWith(
      isArchived: !page.isArchived,
      updatedAt: DateTime.now(),
    );

    state = [
      ...state.sublist(0, pageIndex),
      updatedPage,
      ...state.sublist(pageIndex + 1),
    ];
  }

  /// Reordenar páginas
  void reorderPages(String parentId, int oldIndex, int newIndex) {
    final children = getChildren(parentId);
    if (oldIndex < 0 ||
        oldIndex >= children.length ||
        newIndex < 0 ||
        newIndex >= children.length) return;

    final reorderedChildren = List<PageModel>.from(children);
    final item = reorderedChildren.removeAt(oldIndex);
    reorderedChildren.insert(newIndex, item);

    // Atualizar ordens
    for (int i = 0; i < reorderedChildren.length; i++) {
      final page = reorderedChildren[i];
      final updatedPage = page.copyWith(order: i);

      final pageIndex = state.indexWhere((p) => p.id == page.id);
      if (pageIndex != -1) {
        state = [
          ...state.sublist(0, pageIndex),
          updatedPage,
          ...state.sublist(pageIndex + 1),
        ];
      }
    }
  }
}

/// Provider para páginas
final pagesProvider = StateNotifierProvider<PagesNotifier, List<PageModel>>(
  (ref) => PagesNotifier(),
);

/// Provider para árvore de páginas
final pageTreeProvider = Provider<PageTree>((ref) {
  final pages = ref.watch(pagesProvider);
  final pagesNotifier = ref.read(pagesProvider.notifier);
  return pagesNotifier.getPageTree();
});

/// Provider para página atual
final currentPageProvider = StateProvider<String?>((ref) => null);

/// Provider para estatísticas das páginas
final pagesStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final pagesNotifier = ref.read(pagesProvider.notifier);
  return pagesNotifier.getStats();
});
