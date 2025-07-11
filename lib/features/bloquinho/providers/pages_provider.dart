import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/page_model.dart';
import '../../../core/services/bloquinho_storage_service.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../shared/providers/workspace_provider.dart';

class PagesNotifier extends StateNotifier<List<PageModel>> {
  final BloquinhoStorageService _storageService = BloquinhoStorageService();
  bool _isInitialized = false;

  PagesNotifier() : super([]);

  /// Inicializar provider carregando páginas do armazenamento
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _storageService.initialize();
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao inicializar PagesProvider: $e');
      }
    }
  }

  /// Carregar páginas do workspace atual
  Future<void> loadPagesFromWorkspace() async {
    try {
      await initialize();

      // TODO: Obter perfil e workspace atuais dos providers
      final profileName = 'default'; // Temporário
      final workspaceName = 'default'; // Temporário

      final pages =
          await _storageService.loadAllPages(profileName, workspaceName);
      state = pages;

      if (kDebugMode) {
        print('✅ Páginas carregadas: ${pages.length} páginas');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao carregar páginas: $e');
      }
      state = [];
    }
  }

  PageModel? getById(String id) {
    try {
      return state.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<PageModel> getChildren(String parentId) =>
      state.where((p) => p.parentId == parentId).toList();

  /// Criar nova página e salvar no armazenamento
  Future<void> createPage({
    required String title,
    String? icon,
    String? parentId,
    String content = '',
  }) async {
    try {
      await initialize();

      final page = PageModel.create(
        title: title,
        icon: icon,
        parentId: parentId,
        content: content,
      );

      // Adicionar ao estado
      state = [...state, page];

      // Atualizar parent se necessário
      if (parentId != null) {
        _addChild(parentId, page.id);
      }

      // Salvar no armazenamento
      await _savePageToStorage(page);

      if (kDebugMode) {
        print('✅ Página criada: ${page.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao criar página: $e');
      }
      throw Exception('Erro ao criar página: $e');
    }
  }

  /// Atualizar página e salvar no armazenamento
  Future<void> updatePage(
    String id, {
    String? title,
    String? icon,
    List<dynamic>? blocks,
    String? content,
  }) async {
    try {
      await initialize();

      final updatedPages = [
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

      state = updatedPages;

      // Salvar no armazenamento
      final updatedPage = getById(id);
      if (updatedPage != null) {
        await _savePageToStorage(updatedPage);
      }

      if (kDebugMode) {
        print('✅ Página atualizada: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao atualizar página: $e');
      }
      throw Exception('Erro ao atualizar página: $e');
    }
  }

  /// Auto-save do conteúdo da página
  Future<void> updatePageContent(String id, String content) async {
    try {
      await initialize();

      final updatedPages = [
        for (final p in state)
          if (p.id == id)
            p.copyWith(
              content: content,
              updatedAt: DateTime.now(),
            )
          else
            p
      ];

      state = updatedPages;

      // Salvar no armazenamento
      final updatedPage = getById(id);
      if (updatedPage != null) {
        await _savePageToStorage(updatedPage);
      }

      if (kDebugMode) {
        print('✅ Conteúdo da página salvo: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao salvar conteúdo: $e');
      }
    }
  }

  /// Renomear página (arquivo e pasta)
  Future<void> renamePage(String id, String newTitle) async {
    try {
      await initialize();

      final page = getById(id);
      if (page == null) {
        throw Exception('Página não encontrada');
      }

      // TODO: Obter perfil e workspace atuais
      final profileName = 'default';
      final workspaceName = 'default';

      // Renomear no armazenamento
      await _storageService.renamePage(
          id, newTitle, profileName, workspaceName);

      // Atualizar estado
      await updatePage(id, title: newTitle);

      if (kDebugMode) {
        print('✅ Página renomeada: ${page.title} -> $newTitle');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao renomear página: $e');
      }
      throw Exception('Erro ao renomear página: $e');
    }
  }

  /// Remover página e todas as suas subpáginas
  Future<void> removePage(String id) async {
    try {
      await initialize();

      final page = getById(id);
      if (page == null) return;

      // Remover filhos recursivamente
      for (final childId in page.childrenIds) {
        await removePage(childId);
      }

      // Remover do estado
      state = state.where((p) => p.id != id).toList();

      // Remover do parent se necessário
      if (page.parentId != null) {
        _removeChild(page.parentId!, id);
      }

      // Deletar do armazenamento
      final profileName = 'default';
      final workspaceName = 'default';
      await _storageService.deletePage(id, profileName, workspaceName);

      if (kDebugMode) {
        print('✅ Página removida: ${page.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao remover página: $e');
      }
      throw Exception('Erro ao remover página: $e');
    }
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

  /// Salvar página no armazenamento
  Future<void> _savePageToStorage(PageModel page) async {
    try {
      // TODO: Obter perfil e workspace atuais dos providers
      final profileName = 'default';
      final workspaceName = 'default';

      await _storageService.savePage(page, profileName, workspaceName);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao salvar página no armazenamento: $e');
      }
    }
  }

  /// Importar páginas de uma pasta do Notion
  Future<List<PageModel>> importFromNotionFolder(String folderPath) async {
    try {
      await initialize();

      // TODO: Obter perfil e workspace atuais
      final profileName = 'default';
      final workspaceName = 'default';

      final importedPages = await _storageService.importFromNotionFolder(
          folderPath, profileName, workspaceName);

      // Adicionar ao estado
      state = [...state, ...importedPages];

      if (kDebugMode) {
        print('✅ Páginas importadas: ${importedPages.length} páginas');
      }
      return importedPages;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao importar páginas: $e');
      }
      throw Exception('Erro ao importar páginas: $e');
    }
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
