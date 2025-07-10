import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/notion_block.dart';

const _uuid = Uuid();

/// Modelo de página no sistema Notion-like
class NotionPage {
  final String id;
  final String title;
  final String emoji;
  final String? coverUrl;
  final List<NotionBlock> blocks;
  final String? parentId;
  final List<String> childrenIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String workspaceId;
  final bool isFavorite;
  final bool isArchived;
  final Map<String, dynamic> properties;

  const NotionPage({
    required this.id,
    required this.title,
    this.emoji = '📄',
    this.coverUrl,
    this.blocks = const [],
    this.parentId,
    this.childrenIds = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.workspaceId,
    this.isFavorite = false,
    this.isArchived = false,
    this.properties = const {},
  });

  factory NotionPage.create({
    required String title,
    String emoji = '📄',
    String? parentId,
    required String workspaceId,
    List<NotionBlock>? initialBlocks,
  }) {
    final now = DateTime.now();
    return NotionPage(
      id: _uuid.v4(),
      title: title,
      emoji: emoji,
      parentId: parentId,
      workspaceId: workspaceId,
      blocks: initialBlocks ?? [NotionBlock.create()],
      createdAt: now,
      updatedAt: now,
    );
  }

  NotionPage copyWith({
    String? id,
    String? title,
    String? emoji,
    String? coverUrl,
    List<NotionBlock>? blocks,
    String? parentId,
    List<String>? childrenIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workspaceId,
    bool? isFavorite,
    bool? isArchived,
    Map<String, dynamic>? properties,
  }) {
    return NotionPage(
      id: id ?? this.id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      coverUrl: coverUrl ?? this.coverUrl,
      blocks: blocks ?? this.blocks,
      parentId: parentId ?? this.parentId,
      childrenIds: childrenIds ?? this.childrenIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      workspaceId: workspaceId ?? this.workspaceId,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      properties: properties ?? this.properties,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'emoji': emoji,
      'coverUrl': coverUrl,
      'blocks': blocks.map((block) => block.toJson()).toList(),
      'parentId': parentId,
      'childrenIds': childrenIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'workspaceId': workspaceId,
      'isFavorite': isFavorite,
      'isArchived': isArchived,
      'properties': properties,
    };
  }

  factory NotionPage.fromJson(Map<String, dynamic> json) {
    return NotionPage(
      id: json['id'] as String,
      title: json['title'] as String,
      emoji: json['emoji'] as String? ?? '📄',
      coverUrl: json['coverUrl'] as String?,
      blocks: (json['blocks'] as List<dynamic>?)
              ?.map((e) => NotionBlock.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      parentId: json['parentId'] as String?,
      childrenIds: List<String>.from(json['childrenIds'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      workspaceId: json['workspaceId'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
    );
  }

  bool get hasChildren => childrenIds.isNotEmpty;
  bool get isRoot => parentId == null;

  /// Verifica se a página é o Bloquinho (página mãe)
  bool get isBloquinhoRoot => parentId == null && title == 'Bloquinho';

  /// Obtém o nível hierárquico da página (0 = raiz)
  int getLevel(List<NotionPage> allPages) {
    if (isRoot) return 0;

    final parent = allPages.where((p) => p.id == parentId).firstOrNull;
    if (parent == null) return 0;

    return parent.getLevel(allPages) + 1;
  }
}

/// Serviço para gerenciar páginas no sistema Notion-like
class NotionPageService {
  static const String _boxName = 'notion_pages';
  static const String _bloquinhoRootTitle = 'Bloquinho';

  Box<String>? _box;

  /// Inicializar o serviço
  Future<void> initialize() async {
    if (_box == null) {
      await Hive.initFlutter();
      _box = await Hive.openBox<String>(_boxName);
    }
  }

  /// Obter todas as páginas de um workspace
  Future<List<NotionPage>> getPagesForWorkspace(String workspaceId) async {
    await initialize();

    final pages = <NotionPage>[];
    for (final key in _box!.keys) {
      final pageJson = _box!.get(key);
      if (pageJson != null) {
        try {
          final page = NotionPage.fromJson(jsonDecode(pageJson));
          if (page.workspaceId == workspaceId && !page.isArchived) {
            pages.add(page);
          }
        } catch (e) {
          print('Erro ao carregar página $key: $e');
        }
      }
    }

    // Garantir que existe uma página raiz "Bloquinho"
    final bloquinhoRoot = pages.where((p) => p.isBloquinhoRoot).firstOrNull;
    if (bloquinhoRoot == null) {
      final rootPage = await _createBloquinhoRoot(workspaceId);
      pages.add(rootPage);
    }

    // Ordenar por hierarquia e data de criação
    pages.sort((a, b) {
      if (a.isBloquinhoRoot) return -1;
      if (b.isBloquinhoRoot) return 1;
      return a.createdAt.compareTo(b.createdAt);
    });

    return pages;
  }

  /// Criar página raiz "Bloquinho"
  Future<NotionPage> _createBloquinhoRoot(String workspaceId) async {
    final rootPage = NotionPage.create(
      title: _bloquinhoRootTitle,
      emoji: '📝',
      workspaceId: workspaceId,
      initialBlocks: [
        NotionBlock.create(
          type: NotionBlockType.heading1,
          content: 'Bem-vindo ao Bloquinho',
        ),
        NotionBlock.create(
          type: NotionBlockType.paragraph,
          content:
              'Esta é sua página principal. Todas as outras páginas serão organizadas aqui.',
        ),
        NotionBlock.create(
          type: NotionBlockType.paragraph,
          content:
              'Digite \'/\' para ver os comandos disponíveis e começar a criar conteúdo.',
        ),
      ],
    );

    await savePage(rootPage);
    return rootPage;
  }

  /// Obter uma página específica
  Future<NotionPage?> getPage(String pageId) async {
    await initialize();

    final pageJson = _box!.get(pageId);
    if (pageJson != null) {
      try {
        return NotionPage.fromJson(jsonDecode(pageJson));
      } catch (e) {
        print('Erro ao carregar página $pageId: $e');
      }
    }

    return null;
  }

  /// Salvar uma página
  Future<void> savePage(NotionPage page) async {
    await initialize();

    final pageJson = jsonEncode(page.toJson());
    await _box!.put(page.id, pageJson);
  }

  /// Criar uma nova página
  Future<NotionPage> createPage({
    required String title,
    String emoji = '📄',
    String? parentId,
    required String workspaceId,
    List<NotionBlock>? initialBlocks,
  }) async {
    final page = NotionPage.create(
      title: title,
      emoji: emoji,
      parentId: parentId,
      workspaceId: workspaceId,
      initialBlocks: initialBlocks,
    );

    await savePage(page);

    // Se tem pai, adicionar à lista de filhos do pai
    if (parentId != null) {
      await _addChildToParent(parentId, page.id);
    }

    return page;
  }

  /// Adicionar filho ao pai
  Future<void> _addChildToParent(String parentId, String childId) async {
    final parent = await getPage(parentId);
    if (parent != null) {
      final updatedParent = parent.copyWith(
        childrenIds: [...parent.childrenIds, childId],
      );
      await savePage(updatedParent);
    }
  }

  /// Remover filho do pai
  Future<void> _removeChildFromParent(String parentId, String childId) async {
    final parent = await getPage(parentId);
    if (parent != null) {
      final updatedParent = parent.copyWith(
        childrenIds: parent.childrenIds.where((id) => id != childId).toList(),
      );
      await savePage(updatedParent);
    }
  }

  /// Atualizar uma página
  Future<void> updatePage(NotionPage page) async {
    await savePage(page.copyWith()); // Atualiza updatedAt
  }

  /// Mover página para outro pai
  Future<void> movePage(String pageId, String? newParentId) async {
    final page = await getPage(pageId);
    if (page == null) return;

    // Remover do pai antigo
    if (page.parentId != null) {
      await _removeChildFromParent(page.parentId!, pageId);
    }

    // Adicionar ao novo pai
    if (newParentId != null) {
      await _addChildToParent(newParentId, pageId);
    }

    // Atualizar a página
    final updatedPage = page.copyWith(parentId: newParentId);
    await savePage(updatedPage);
  }

  /// Deletar uma página (marca como arquivada)
  Future<void> deletePage(String pageId) async {
    final page = await getPage(pageId);
    if (page == null) return;

    // Não permitir deletar a página raiz Bloquinho
    if (page.isBloquinhoRoot) {
      throw Exception('Não é possível deletar a página raiz Bloquinho');
    }

    // Marcar como arquivada
    final archivedPage = page.copyWith(isArchived: true);
    await savePage(archivedPage);

    // Remover do pai
    if (page.parentId != null) {
      await _removeChildFromParent(page.parentId!, pageId);
    }

    // Arquivar páginas filhas recursivamente
    for (final childId in page.childrenIds) {
      await deletePage(childId);
    }
  }

  /// Restaurar página arquivada
  Future<void> restorePage(String pageId, String? newParentId) async {
    final page = await getPage(pageId);
    if (page == null) return;

    final restoredPage = page.copyWith(
      isArchived: false,
      parentId: newParentId,
    );
    await savePage(restoredPage);

    // Adicionar ao novo pai
    if (newParentId != null) {
      await _addChildToParent(newParentId, pageId);
    }
  }

  /// Duplicar página
  Future<NotionPage> duplicatePage(String pageId) async {
    final originalPage = await getPage(pageId);
    if (originalPage == null) {
      throw Exception('Página não encontrada');
    }

    final duplicatedPage = NotionPage.create(
      title: '${originalPage.title} (Cópia)',
      emoji: originalPage.emoji,
      parentId: originalPage.parentId,
      workspaceId: originalPage.workspaceId,
      initialBlocks: originalPage.blocks
          .map((block) => block.copyWith(id: null) // Novo ID será gerado
              )
          .toList(),
    );

    await savePage(duplicatedPage);

    // Adicionar ao pai se necessário
    if (originalPage.parentId != null) {
      await _addChildToParent(originalPage.parentId!, duplicatedPage.id);
    }

    return duplicatedPage;
  }

  /// Buscar páginas
  Future<List<NotionPage>> searchPages(String query, String workspaceId) async {
    final allPages = await getPagesForWorkspace(workspaceId);

    if (query.isEmpty) return allPages;

    final lowercaseQuery = query.toLowerCase();
    return allPages.where((page) {
      return page.title.toLowerCase().contains(lowercaseQuery) ||
          page.blocks.any(
              (block) => block.content.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// Obter páginas favoritas
  Future<List<NotionPage>> getFavoritePages(String workspaceId) async {
    final allPages = await getPagesForWorkspace(workspaceId);
    return allPages.where((page) => page.isFavorite).toList();
  }

  /// Alternar favorito
  Future<void> toggleFavorite(String pageId) async {
    final page = await getPage(pageId);
    if (page != null) {
      final updatedPage = page.copyWith(isFavorite: !page.isFavorite);
      await savePage(updatedPage);
    }
  }

  /// Obter hierarquia de páginas em árvore
  Future<List<NotionPage>> getPageHierarchy(String workspaceId) async {
    final allPages = await getPagesForWorkspace(workspaceId);

    // Construir árvore hierárquica
    final pageMap = <String, NotionPage>{
      for (final page in allPages) page.id: page
    };

    final result = <NotionPage>[];

    void addPageWithChildren(NotionPage page, List<NotionPage> list) {
      list.add(page);

      // Adicionar filhos ordenados
      final children = page.childrenIds
          .map((childId) => pageMap[childId])
          .where((child) => child != null)
          .cast<NotionPage>()
          .toList();

      children.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      for (final child in children) {
        addPageWithChildren(child, list);
      }
    }

    // Começar com páginas raiz (incluindo Bloquinho)
    final rootPages = allPages.where((page) => page.isRoot).toList();
    rootPages.sort((a, b) {
      if (a.isBloquinhoRoot) return -1;
      if (b.isBloquinhoRoot) return 1;
      return a.createdAt.compareTo(b.createdAt);
    });

    for (final rootPage in rootPages) {
      addPageWithChildren(rootPage, result);
    }

    return result;
  }

  /// Exportar páginas para JSON
  Future<Map<String, dynamic>> exportWorkspace(String workspaceId) async {
    final pages = await getPagesForWorkspace(workspaceId);

    return {
      'workspaceId': workspaceId,
      'exportedAt': DateTime.now().toIso8601String(),
      'pages': pages.map((page) => page.toJson()).toList(),
    };
  }

  /// Importar páginas de JSON
  Future<void> importWorkspace(Map<String, dynamic> data) async {
    final pagesData = data['pages'] as List<dynamic>;

    for (final pageData in pagesData) {
      try {
        final page = NotionPage.fromJson(pageData as Map<String, dynamic>);
        await savePage(page);
      } catch (e) {
        print('Erro ao importar página: $e');
      }
    }
  }

  /// Limpar todos os dados (apenas para desenvolvimento)
  Future<void> clearAllData() async {
    await initialize();
    await _box!.clear();
  }
}
