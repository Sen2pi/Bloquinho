import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/page_models.dart';

/// Serviço para gerenciar páginas do Bloquinho
class PageService {
  static const String _pagesBoxName = 'bloquinho_pages';
  static const String _blocksBoxName = 'bloquinho_blocks';

  Box<Map>? _pagesBox;
  Box<Map>? _blocksBox;

  /// Inicializar o serviço
  Future<void> initialize() async {
    _pagesBox = await Hive.openBox<Map>(_pagesBoxName);
    _blocksBox = await Hive.openBox<Map>(_blocksBoxName);
  }

  /// Garantir que o serviço está inicializado
  Future<void> _ensureInitialized() async {
    if (_pagesBox == null || _blocksBox == null) {
      await initialize();
    }
  }

  /// Obter todas as páginas de um workspace
  Future<List<BloqPage>> getPagesByWorkspace(String workspaceId) async {
    await _ensureInitialized();

    final pages = <BloqPage>[];

    for (final entry in _pagesBox!.values) {
      try {
        final pageData = Map<String, dynamic>.from(entry);
        if (pageData['workspaceId'] == workspaceId) {
          final page = BloqPage.fromJson(pageData);
          pages.add(page);
        }
      } catch (e) {
        print('Erro ao carregar página: $e');
      }
    }

    return pages;
  }

  /// Obter uma página específica por ID
  Future<BloqPage?> getPageById(String pageId) async {
    await _ensureInitialized();

    try {
      final pageData = _pagesBox!.get(pageId);
      if (pageData != null) {
        return BloqPage.fromJson(Map<String, dynamic>.from(pageData));
      }
    } catch (e) {
      print('Erro ao obter página: $e');
    }

    return null;
  }

  /// Criar uma nova página
  Future<BloqPage> createPage(BloqPage page) async {
    await _ensureInitialized();

    try {
      // Salvar a página
      await _pagesBox!.put(page.id, page.toJson());

      // Se tem pai, adicionar aos filhos do pai
      if (page.parentId != null) {
        await _addChildToParent(page.parentId!, page.id);
      }

      return page;
    } catch (e) {
      print('Erro ao criar página: $e');
      rethrow;
    }
  }

  /// Atualizar uma página existente
  Future<BloqPage> updatePage(BloqPage page) async {
    await _ensureInitialized();

    try {
      await _pagesBox!.put(page.id, page.toJson());
      return page;
    } catch (e) {
      print('Erro ao atualizar página: $e');
      rethrow;
    }
  }

  /// Deletar uma página e suas filhas
  Future<void> deletePage(String pageId) async {
    await _ensureInitialized();

    try {
      final page = await getPageById(pageId);
      if (page == null) return;

      // Deletar filhas recursivamente
      for (final childId in page.childrenIds) {
        await deletePage(childId);
      }

      // Remover dos filhos do pai
      if (page.parentId != null) {
        await _removeChildFromParent(page.parentId!, pageId);
      }

      // Deletar blocos da página
      for (final block in page.blocks) {
        await _deleteBlockRecursive(block.id);
      }

      // Deletar a página
      await _pagesBox!.delete(pageId);
    } catch (e) {
      print('Erro ao deletar página: $e');
      rethrow;
    }
  }

  /// Mover uma página para outro pai
  Future<void> movePage(String pageId, String? newParentId) async {
    await _ensureInitialized();

    try {
      final page = await getPageById(pageId);
      if (page == null) return;

      // Remover do pai anterior
      if (page.parentId != null) {
        await _removeChildFromParent(page.parentId!, pageId);
      }

      // Adicionar ao novo pai
      if (newParentId != null) {
        await _addChildToParent(newParentId, pageId);
      }

      // Atualizar a página
      final updatedPage = page.copyWith(parentId: newParentId);
      await updatePage(updatedPage);
    } catch (e) {
      print('Erro ao mover página: $e');
      rethrow;
    }
  }

  /// Obter páginas raiz (sem pai) de um workspace
  Future<List<BloqPage>> getRootPages(String workspaceId) async {
    final allPages = await getPagesByWorkspace(workspaceId);
    return allPages.where((page) => page.isRoot).toList();
  }

  /// Obter filhas de uma página
  Future<List<BloqPage>> getChildPages(String parentId) async {
    await _ensureInitialized();

    final children = <BloqPage>[];

    for (final entry in _pagesBox!.values) {
      try {
        final pageData = Map<String, dynamic>.from(entry);
        if (pageData['parentId'] == parentId) {
          final page = BloqPage.fromJson(pageData);
          children.add(page);
        }
      } catch (e) {
        print('Erro ao carregar página filha: $e');
      }
    }

    return children;
  }

  /// Buscar páginas por título
  Future<List<BloqPage>> searchPagesByTitle(
      String workspaceId, String query) async {
    final allPages = await getPagesByWorkspace(workspaceId);
    final lowerQuery = query.toLowerCase();

    return allPages
        .where((page) => page.title.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Obter páginas favoritas
  Future<List<BloqPage>> getFavoritePages(String workspaceId) async {
    final allPages = await getPagesByWorkspace(workspaceId);
    return allPages.where((page) => page.isFavorite).toList();
  }

  /// Adicionar/remover página dos favoritos
  Future<void> toggleFavorite(String pageId) async {
    final page = await getPageById(pageId);
    if (page != null) {
      final updatedPage = page.copyWith(isFavorite: !page.isFavorite);
      await updatePage(updatedPage);
    }
  }

  /// Salvar bloco de conteúdo
  Future<PageBlock> saveBlock(PageBlock block) async {
    await _ensureInitialized();

    try {
      await _blocksBox!.put(block.id, block.toJson());
      return block;
    } catch (e) {
      print('Erro ao salvar bloco: $e');
      rethrow;
    }
  }

  /// Obter bloco por ID
  Future<PageBlock?> getBlockById(String blockId) async {
    await _ensureInitialized();

    try {
      final blockData = _blocksBox!.get(blockId);
      if (blockData != null) {
        return PageBlock.fromJson(Map<String, dynamic>.from(blockData));
      }
    } catch (e) {
      print('Erro ao obter bloco: $e');
    }

    return null;
  }

  /// Deletar bloco recursivamente
  Future<void> _deleteBlockRecursive(String blockId) async {
    final block = await getBlockById(blockId);
    if (block == null) return;

    // Deletar filhos recursivamente
    for (final child in block.children) {
      await _deleteBlockRecursive(child.id);
    }

    // Deletar o bloco
    await _blocksBox!.delete(blockId);
  }

  /// Adicionar filho ao pai
  Future<void> _addChildToParent(String parentId, String childId) async {
    final parent = await getPageById(parentId);
    if (parent != null) {
      final updatedChildren = [...parent.childrenIds];
      if (!updatedChildren.contains(childId)) {
        updatedChildren.add(childId);
        final updatedParent = parent.copyWith(childrenIds: updatedChildren);
        await updatePage(updatedParent);
      }
    }
  }

  /// Remover filho do pai
  Future<void> _removeChildFromParent(String parentId, String childId) async {
    final parent = await getPageById(parentId);
    if (parent != null) {
      final updatedChildren = [...parent.childrenIds];
      updatedChildren.remove(childId);
      final updatedParent = parent.copyWith(childrenIds: updatedChildren);
      await updatePage(updatedParent);
    }
  }

  /// Exportar páginas de um workspace para JSON
  Future<Map<String, dynamic>> exportWorkspaceData(String workspaceId) async {
    final pages = await getPagesByWorkspace(workspaceId);

    return {
      'workspaceId': workspaceId,
      'exportedAt': DateTime.now().toIso8601String(),
      'pages': pages.map((page) => page.toJson()).toList(),
    };
  }

  /// Importar páginas de JSON
  Future<void> importWorkspaceData(
      Map<String, dynamic> data, String targetWorkspaceId) async {
    final pagesData = data['pages'] as List<dynamic>?;
    if (pagesData == null) return;

    // Mapa para converter IDs antigos para novos
    final idMapping = <String, String>{};

    // Primeira passada: criar páginas com novos IDs
    final pagesToCreate = <BloqPage>[];
    for (final pageData in pagesData) {
      final originalPage =
          BloqPage.fromJson(Map<String, dynamic>.from(pageData));
      final newId = const Uuid().v4();
      idMapping[originalPage.id] = newId;

      final newPage = originalPage.copyWith(
        id: newId,
        workspaceId: targetWorkspaceId,
        parentId: null, // Será atualizado na segunda passada
        childrenIds: [], // Será atualizado na segunda passada
      );

      pagesToCreate.add(newPage);
    }

    // Segunda passada: atualizar relações pai-filho
    for (int i = 0; i < pagesToCreate.length; i++) {
      final originalPage =
          BloqPage.fromJson(Map<String, dynamic>.from(pagesData[i]));
      final newPage = pagesToCreate[i];

      String? newParentId;
      if (originalPage.parentId != null) {
        newParentId = idMapping[originalPage.parentId];
      }

      final newChildrenIds = originalPage.childrenIds
          .map((oldId) => idMapping[oldId])
          .where((newId) => newId != null)
          .cast<String>()
          .toList();

      final updatedPage = newPage.copyWith(
        parentId: newParentId,
        childrenIds: newChildrenIds,
      );

      await createPage(updatedPage);
    }
  }

  /// Limpar todos os dados (para testes)
  Future<void> clearAllData() async {
    await _ensureInitialized();
    await _pagesBox!.clear();
    await _blocksBox!.clear();
  }
}
