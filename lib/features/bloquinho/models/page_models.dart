import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Tipos de blocos de conteúdo disponíveis no Bloquinho
enum PageBlockType {
  // Texto básico
  text,
  heading1,
  heading2,
  heading3,
  paragraph,

  // Listas
  bulletList,
  numberedList,
  todoList,
  toggleList,

  // Formatação
  quote,
  callout,
  divider,

  // Mídia
  image,
  video,
  audio,
  file,

  // Dados
  table,
  database,
  databaseView,

  // Código
  code,

  // Links e Referências
  pageLink, // Link para outra página interna
  webLink, // Link para URL externa
  mention, // Menção a pessoa ou página

  // Outros
  bookmark,
  embed,
  diagram, // Para diagramas Mermaid
  breadcrumb,

  // Layouts
  columns,
  column,
}

/// Modelo de bloco de conteúdo de uma página
class PageBlock extends Equatable {
  final String id;
  final PageBlockType type;
  final String content;
  final Map<String, dynamic> properties;
  final List<PageBlock> children;
  final String? parentBlockId;
  final int orderIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PageBlock({
    required this.id,
    required this.type,
    required this.content,
    this.properties = const {},
    this.children = const [],
    this.parentBlockId,
    this.orderIndex = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PageBlock.create({
    PageBlockType type = PageBlockType.text,
    String content = '',
    Map<String, dynamic> properties = const {},
    List<PageBlock> children = const [],
    String? parentBlockId,
    int orderIndex = 0,
  }) {
    final now = DateTime.now();
    return PageBlock(
      id: _uuid.v4(),
      type: type,
      content: content,
      properties: properties,
      children: children,
      parentBlockId: parentBlockId,
      orderIndex: orderIndex,
      createdAt: now,
      updatedAt: now,
    );
  }

  PageBlock copyWith({
    String? id,
    PageBlockType? type,
    String? content,
    Map<String, dynamic>? properties,
    List<PageBlock>? children,
    String? parentBlockId,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PageBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      properties: properties ?? this.properties,
      children: children ?? this.children,
      parentBlockId: parentBlockId ?? this.parentBlockId,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'content': content,
      'properties': properties,
      'children': children.map((child) => child.toJson()).toList(),
      'parentBlockId': parentBlockId,
      'orderIndex': orderIndex,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PageBlock.fromJson(Map<String, dynamic> json) {
    return PageBlock(
      id: json['id'] as String,
      type: PageBlockType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PageBlockType.text,
      ),
      content: json['content'] as String? ?? '',
      properties: Map<String, dynamic>.from(json['properties'] as Map? ?? {}),
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => PageBlock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      parentBlockId: json['parentBlockId'] as String?,
      orderIndex: json['orderIndex'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        content,
        properties,
        children,
        parentBlockId,
        orderIndex,
        createdAt,
        updatedAt,
      ];
}

/// Modelo de página do Bloquinho
class BloqPage extends Equatable {
  final String id;
  final String title;
  final String emoji;
  final String? coverImage;
  final List<PageBlock> blocks;
  final String? parentId;
  final List<String> childrenIds;
  final List<String> tags;
  final bool isPublic;
  final bool isFavorite;
  final bool isArchived;
  final bool isTemplate;
  final Map<String, dynamic> properties;
  final String workspaceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final List<String> collaborators;

  const BloqPage({
    required this.id,
    required this.title,
    this.emoji = '📄',
    this.coverImage,
    this.blocks = const [],
    this.parentId,
    this.childrenIds = const [],
    this.tags = const [],
    this.isPublic = false,
    this.isFavorite = false,
    this.isArchived = false,
    this.isTemplate = false,
    this.properties = const {},
    required this.workspaceId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.collaborators = const [],
  });

  factory BloqPage.create({
    String title = 'Sem título',
    String emoji = '📄',
    String? parentId,
    List<String> tags = const [],
    required String workspaceId,
    String createdBy = 'user',
  }) {
    final now = DateTime.now();
    return BloqPage(
      id: _uuid.v4(),
      title: title,
      emoji: emoji,
      parentId: parentId,
      tags: tags,
      workspaceId: workspaceId,
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
    );
  }

  BloqPage copyWith({
    String? id,
    String? title,
    String? emoji,
    String? coverImage,
    List<PageBlock>? blocks,
    String? parentId,
    List<String>? childrenIds,
    List<String>? tags,
    bool? isPublic,
    bool? isFavorite,
    bool? isArchived,
    bool? isTemplate,
    Map<String, dynamic>? properties,
    String? workspaceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    List<String>? collaborators,
  }) {
    return BloqPage(
      id: id ?? this.id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      coverImage: coverImage ?? this.coverImage,
      blocks: blocks ?? this.blocks,
      parentId: parentId ?? this.parentId,
      childrenIds: childrenIds ?? this.childrenIds,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      isTemplate: isTemplate ?? this.isTemplate,
      properties: properties ?? this.properties,
      workspaceId: workspaceId ?? this.workspaceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      createdBy: createdBy ?? this.createdBy,
      collaborators: collaborators ?? this.collaborators,
    );
  }

  /// Retorna true se esta página tem filhos
  bool get hasChildren => childrenIds.isNotEmpty;

  /// Retorna true se esta página é uma raiz (sem pai)
  bool get isRoot => parentId == null;

  /// Retorna o nível de profundidade na hierarquia
  int getDepthLevel(List<BloqPage> allPages) {
    if (isRoot) return 0;

    final parent = allPages.firstWhere(
      (page) => page.id == parentId,
      orElse: () => throw Exception('Página pai não encontrada'),
    );

    return 1 + parent.getDepthLevel(allPages);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'emoji': emoji,
      'coverImage': coverImage,
      'blocks': blocks.map((block) => block.toJson()).toList(),
      'parentId': parentId,
      'childrenIds': childrenIds,
      'tags': tags,
      'isPublic': isPublic,
      'isFavorite': isFavorite,
      'isArchived': isArchived,
      'isTemplate': isTemplate,
      'properties': properties,
      'workspaceId': workspaceId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'collaborators': collaborators,
    };
  }

  factory BloqPage.fromJson(Map<String, dynamic> json) {
    return BloqPage(
      id: json['id'] as String,
      title: json['title'] as String,
      emoji: json['emoji'] as String? ?? '📄',
      coverImage: json['coverImage'] as String?,
      blocks: (json['blocks'] as List<dynamic>?)
              ?.map((e) => PageBlock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      parentId: json['parentId'] as String?,
      childrenIds: List<String>.from(json['childrenIds'] as List? ?? []),
      tags: List<String>.from(json['tags'] as List? ?? []),
      isPublic: json['isPublic'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      isTemplate: json['isTemplate'] as bool? ?? false,
      properties: Map<String, dynamic>.from(json['properties'] as Map? ?? {}),
      workspaceId: json['workspaceId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      collaborators: List<String>.from(json['collaborators'] as List? ?? []),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        emoji,
        coverImage,
        blocks,
        parentId,
        childrenIds,
        tags,
        isPublic,
        isFavorite,
        isArchived,
        isTemplate,
        properties,
        workspaceId,
        createdAt,
        updatedAt,
        createdBy,
        collaborators,
      ];
}

/// Estrutura hierárquica de páginas para exibição na árvore
class PageTreeNode {
  final BloqPage page;
  final List<PageTreeNode> children;
  final bool isExpanded;
  final int level;

  const PageTreeNode({
    required this.page,
    this.children = const [],
    this.isExpanded = false,
    this.level = 0,
  });

  PageTreeNode copyWith({
    BloqPage? page,
    List<PageTreeNode>? children,
    bool? isExpanded,
    int? level,
  }) {
    return PageTreeNode(
      page: page ?? this.page,
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
      level: level ?? this.level,
    );
  }
}

/// Utilitários para trabalhar com páginas
class PageUtils {
  /// Constrói uma árvore hierárquica de páginas
  static List<PageTreeNode> buildPageTree(List<BloqPage> pages) {
    // Filtrar páginas raiz (sem pai)
    final rootPages = pages.where((page) => page.isRoot).toList();

    return rootPages.map((page) => _buildNode(page, pages, 0)).toList();
  }

  static PageTreeNode _buildNode(
      BloqPage page, List<BloqPage> allPages, int level) {
    // Encontrar filhos desta página
    final children = allPages
        .where((p) => p.parentId == page.id)
        .map((child) => _buildNode(child, allPages, level + 1))
        .toList();

    return PageTreeNode(
      page: page,
      children: children,
      level: level,
    );
  }

  /// Atualiza uma página na árvore
  static List<PageTreeNode> updatePageInTree(
    List<PageTreeNode> tree,
    BloqPage updatedPage,
  ) {
    return tree.map((node) {
      if (node.page.id == updatedPage.id) {
        return node.copyWith(page: updatedPage);
      }

      if (node.children.isNotEmpty) {
        return node.copyWith(
          children: updatePageInTree(node.children, updatedPage),
        );
      }

      return node;
    }).toList();
  }

  /// Expande/colapsa um nó na árvore
  static List<PageTreeNode> toggleNodeExpansion(
    List<PageTreeNode> tree,
    String pageId,
  ) {
    return tree.map((node) {
      if (node.page.id == pageId) {
        return node.copyWith(isExpanded: !node.isExpanded);
      }

      if (node.children.isNotEmpty) {
        return node.copyWith(
          children: toggleNodeExpansion(node.children, pageId),
        );
      }

      return node;
    }).toList();
  }
}
