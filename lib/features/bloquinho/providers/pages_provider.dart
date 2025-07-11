import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/page_model.dart';

class PagesNotifier extends StateNotifier<List<PageModel>> {
  PagesNotifier() : super([]);

  PageModel? getById(String id) {
    try {
      return state.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<PageModel> getChildren(String parentId) =>
      state.where((p) => p.parentId == parentId).toList();

  void createPage(
      {required String title,
      String? icon,
      String? parentId,
      String content = ''}) {
    final page = PageModel.create(
      title: title,
      icon: icon,
      parentId: parentId,
      content: content,
    );
    state = [...state, page];
    if (parentId != null) {
      _addChild(parentId, page.id);
    }
  }

  void updatePage(String id,
      {String? title, String? icon, List<dynamic>? blocks, String? content}) {
    state = [
      for (final p in state)
        if (p.id == id)
          p.copyWith(
            title: title ?? p.title,
            icon: icon ?? p.icon,
            blocks: blocks ?? p.blocks,
            content: content ?? p.content,
            updatedAt: DateTime.now(),
          )
        else
          p
    ];
  }

  // Auto-save do conteúdo da página
  void updatePageContent(String id, String content) {
    state = [
      for (final p in state)
        if (p.id == id)
          p.copyWith(
            content: content,
            updatedAt: DateTime.now(),
          )
        else
          p
    ];
  }

  // Obter conteúdo de uma página
  String getPageContent(String id) {
    final page = getById(id);
    return page?.content ?? '';
  }

  void _addChild(String parentId, String childId) {
    state = [
      for (final p in state)
        if (p.id == parentId)
          p.copyWith(childrenIds: [...p.childrenIds, childId])
        else
          p
    ];
  }

  void removePage(String id) {
    final page = getById(id);
    if (page == null) return;
    // Remove filhos recursivamente
    for (final childId in page.childrenIds) {
      removePage(childId);
    }
    state = state.where((p) => p.id != id).toList();
    if (page.parentId != null) {
      _removeChild(page.parentId!, id);
    }
  }

  void _removeChild(String parentId, String childId) {
    state = [
      for (final p in state)
        if (p.id == parentId)
          p.copyWith(
              childrenIds: p.childrenIds.where((c) => c != childId).toList())
        else
          p
    ];
  }

  List<PageModel> searchPages(String query) {
    final lowercaseQuery = query.toLowerCase();
    return state.where((page) {
      return page.title.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Map<String, dynamic> getStatistics() {
    final totalPages = state.length;
    final rootPages = state.where((p) => p.isRoot).length;
    final subPages = state.where((p) => p.isSubPage).length;

    return {
      'totalPages': totalPages,
      'rootPages': rootPages,
      'subPages': subPages,
      'activePages': totalPages - subPages,
    };
  }
}

final pagesProvider = StateNotifierProvider<PagesNotifier, List<PageModel>>(
    (ref) => PagesNotifier());
