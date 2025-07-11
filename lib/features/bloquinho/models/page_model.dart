import 'package:uuid/uuid.dart';
import 'dart:math' as math;

/// Modelo para representar uma página no sistema
class PageModel {
  final String id;
  final String title;
  final String? content;
  final String? parentId;
  final List<String> childrenIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;
  final int order;
  final bool isArchived;

  const PageModel({
    required this.id,
    required this.title,
    this.content,
    this.parentId,
    this.childrenIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
    this.order = 0,
    this.isArchived = false,
  });

  /// Criar uma nova página
  factory PageModel.create({
    required String title,
    String? content,
    String? parentId,
    int order = 0,
  }) {
    final now = DateTime.now();
    return PageModel(
      id: const Uuid().v4(),
      title: title,
      content: content,
      parentId: parentId,
      createdAt: now,
      updatedAt: now,
      order: order,
    );
  }

  /// Copiar com modificações
  PageModel copyWith({
    String? id,
    String? title,
    String? content,
    String? parentId,
    List<String>? childrenIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    int? order,
    bool? isArchived,
  }) {
    return PageModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      childrenIds: childrenIds ?? this.childrenIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      order: order ?? this.order,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  /// Converter para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'parentId': parentId,
      'childrenIds': childrenIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
      'order': order,
      'isArchived': isArchived,
    };
  }

  /// Criar a partir de Map
  factory PageModel.fromMap(Map<String, dynamic> map) {
    return PageModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'],
      parentId: map['parentId'],
      childrenIds: List<String>.from(map['childrenIds'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      order: map['order'] ?? 0,
      isArchived: map['isArchived'] ?? false,
    );
  }

  /// Verificar se é página raiz
  bool get isRoot => parentId == null;

  /// Verificar se tem filhos
  bool get hasChildren => childrenIds.isNotEmpty;

  /// Verificar se é uma subpágina
  bool get isSubPage => parentId != null;

  /// Obter nível de profundidade (0 = raiz)
  int getDepth(List<PageModel> allPages) {
    if (isRoot) return 0;

    int depth = 0;
    String? currentParentId = parentId;

    while (currentParentId != null) {
      depth++;
      final parent = allPages.firstWhere(
        (page) => page.id == currentParentId,
        orElse: () => PageModel.create(title: 'Página não encontrada'),
      );
      currentParentId = parent.parentId;
    }

    return depth;
  }

  /// Obter caminho completo da página
  List<String> getPath(List<PageModel> allPages) {
    final path = <String>[title];
    String? currentParentId = parentId;

    while (currentParentId != null) {
      final parent = allPages.firstWhere(
        (page) => page.id == currentParentId,
        orElse: () => PageModel.create(title: 'Página não encontrada'),
      );
      path.insert(0, parent.title);
      currentParentId = parent.parentId;
    }

    return path;
  }

  /// Obter string do caminho
  String getPathString(List<PageModel> allPages) {
    return getPath(allPages).join(' > ');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PageModel(id: $id, title: $title, parentId: $parentId)';
  }
}

/// Modelo para representar a estrutura de páginas
class PageTree {
  final List<PageModel> pages;
  final String rootPageId;

  const PageTree({
    required this.pages,
    required this.rootPageId,
  });

  /// Obter página raiz
  PageModel? get rootPage {
    try {
      return pages.firstWhere((page) => page.id == rootPageId);
    } catch (e) {
      return null;
    }
  }

  /// Obter páginas raiz (sem pai)
  List<PageModel> get rootPages {
    return pages.where((page) => page.isRoot).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Obter filhos de uma página
  List<PageModel> getChildren(String parentId) {
    return pages.where((page) => page.parentId == parentId).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Obter ancestrais de uma página
  List<PageModel> getAncestors(String pageId) {
    final ancestors = <PageModel>[];
    String? currentId = pageId;

    while (currentId != null) {
      final page = pages.firstWhere(
        (p) => p.id == currentId,
        orElse: () => PageModel.create(title: 'Página não encontrada'),
      );

      if (page.parentId != null) {
        ancestors.insert(0, page);
        currentId = page.parentId;
      } else {
        break;
      }
    }

    return ancestors;
  }

  /// Obter descendentes de uma página
  List<PageModel> getDescendants(String pageId) {
    final descendants = <PageModel>[];
    final toProcess = <String>[pageId];

    while (toProcess.isNotEmpty) {
      final currentId = toProcess.removeAt(0);
      final children = getChildren(currentId);

      for (final child in children) {
        descendants.add(child);
        toProcess.add(child.id);
      }
    }

    return descendants;
  }

  /// Verificar se uma página é descendente de outra
  bool isDescendant(String pageId, String ancestorId) {
    final descendants = getDescendants(ancestorId);
    return descendants.any((page) => page.id == pageId);
  }

  /// Obter árvore hierárquica
  List<PageTreeNode> getTree() {
    final rootPages = this.rootPages;
    return rootPages.map((page) => _buildTreeNode(page)).toList();
  }

  /// Construir nó da árvore
  PageTreeNode _buildTreeNode(PageModel page) {
    final children = getChildren(page.id);
    final childNodes = children.map((child) => _buildTreeNode(child)).toList();

    return PageTreeNode(
      page: page,
      children: childNodes,
    );
  }

  /// Buscar páginas por texto
  List<PageModel> search(String query) {
    final lowercaseQuery = query.toLowerCase();
    return pages.where((page) {
      return page.title.toLowerCase().contains(lowercaseQuery) ||
          (page.content?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  /// Obter estatísticas
  Map<String, dynamic> getStats() {
    final totalPages = pages.length;
    final rootPages = this.rootPages.length;
    final subPages = pages.where((p) => p.isSubPage).length;
    final archivedPages = pages.where((p) => p.isArchived).length;

    return {
      'totalPages': totalPages,
      'rootPages': rootPages,
      'subPages': subPages,
      'archivedPages': archivedPages,
      'activePages': totalPages - archivedPages,
    };
  }
}

/// Nó da árvore de páginas
class PageTreeNode {
  final PageModel page;
  final List<PageTreeNode> children;

  const PageTreeNode({
    required this.page,
    this.children = const [],
  });

  /// Obter profundidade do nó
  int get depth {
    int maxDepth = 0;
    for (final child in children) {
      maxDepth = math.max(maxDepth, child.depth + 1);
    }
    return maxDepth;
  }

  /// Obter número total de descendentes
  int get totalDescendants {
    int count = children.length;
    for (final child in children) {
      count += child.totalDescendants;
    }
    return count;
  }

  /// Verificar se tem filhos
  bool get hasChildren => children.isNotEmpty;

  /// Obter todos os descendentes como lista plana
  List<PageModel> getAllDescendants() {
    final descendants = <PageModel>[page];
    for (final child in children) {
      descendants.addAll(child.getAllDescendants());
    }
    return descendants;
  }
}

/// Extensões úteis
extension PageModelExtension on PageModel {
  /// Verificar se é a página raiz do Bloquinho
  bool get isBloquinhoRoot => title.toLowerCase() == 'bloquinho' && isRoot;

  /// Obter ícone baseado no tipo
  String get icon {
    if (isBloquinhoRoot) return '📝';
    if (isRoot) return '📄';
    return '📄';
  }

  /// Obter cor baseada no tipo
  String get color {
    if (isBloquinhoRoot) return '#3B82F6'; // Azul
    if (isRoot) return '#10B981'; // Verde
    return '#6B7280'; // Cinza
  }
}
