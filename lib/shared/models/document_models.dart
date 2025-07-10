import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// Tipos de blocos disponíveis
enum BlockType {
  text,
  heading1,
  heading2,
  heading3,
  bulletList,
  numberedList,
  quote,
  code,
  divider,
  image,
  table,
  database,
  callout,
  toggle,
  bookmark,
}

// Modelo de bloco de conteúdo
class DocumentBlock extends Equatable {
  final String id;
  final BlockType type;
  final String content;
  final Map<String, dynamic> properties;
  final List<DocumentBlock> children;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DocumentBlock({
    required this.id,
    required this.type,
    required this.content,
    this.properties = const {},
    this.children = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory DocumentBlock.create({
    BlockType type = BlockType.text,
    String content = '',
    Map<String, dynamic> properties = const {},
    List<DocumentBlock> children = const [],
  }) {
    final now = DateTime.now();
    return DocumentBlock(
      id: _uuid.v4(),
      type: type,
      content: content,
      properties: properties,
      children: children,
      createdAt: now,
      updatedAt: now,
    );
  }

  DocumentBlock copyWith({
    String? id,
    BlockType? type,
    String? content,
    Map<String, dynamic>? properties,
    List<DocumentBlock>? children,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      properties: properties ?? this.properties,
      children: children ?? this.children,
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DocumentBlock.fromJson(Map<String, dynamic> json) {
    return DocumentBlock(
      id: json['id'] as String,
      type: BlockType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BlockType.text,
      ),
      content: json['content'] as String,
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => DocumentBlock.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
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
        createdAt,
        updatedAt,
      ];
}

// Modelo de documento/página
class Document extends Equatable {
  final String id;
  final String title;
  final String icon;
  final String coverImage;
  final List<DocumentBlock> blocks;
  final String? parentId;
  final List<String> tags;
  final bool isPublic;
  final bool isFavorite;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const Document({
    required this.id,
    required this.title,
    this.icon = '📄',
    this.coverImage = '',
    this.blocks = const [],
    this.parentId,
    this.tags = const [],
    this.isPublic = false,
    this.isFavorite = false,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory Document.create({
    String title = 'Sem título',
    String icon = '📄',
    String? parentId,
    List<String> tags = const [],
    String createdBy = 'user',
  }) {
    final now = DateTime.now();
    return Document(
      id: _uuid.v4(),
      title: title,
      icon: icon,
      parentId: parentId,
      tags: tags,
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
    );
  }

  Document copyWith({
    String? id,
    String? title,
    String? icon,
    String? coverImage,
    List<DocumentBlock>? blocks,
    String? parentId,
    List<String>? tags,
    bool? isPublic,
    bool? isFavorite,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      coverImage: coverImage ?? this.coverImage,
      blocks: blocks ?? this.blocks,
      parentId: parentId ?? this.parentId,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'coverImage': coverImage,
      'blocks': blocks.map((block) => block.toJson()).toList(),
      'parentId': parentId,
      'tags': tags,
      'isPublic': isPublic,
      'isFavorite': isFavorite,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String? ?? '📄',
      coverImage: json['coverImage'] as String? ?? '',
      blocks: (json['blocks'] as List<dynamic>?)
              ?.map((e) => DocumentBlock.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      parentId: json['parentId'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      isPublic: json['isPublic'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        icon,
        coverImage,
        blocks,
        parentId,
        tags,
        isPublic,
        isFavorite,
        isArchived,
        createdAt,
        updatedAt,
        createdBy,
      ];
}

// Modelo de workspace
class Workspace extends Equatable {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<String> documentIds;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String ownerId;

  const Workspace({
    required this.id,
    required this.name,
    this.description = '',
    this.icon = '🏠',
    this.documentIds = const [],
    this.settings = const {},
    required this.createdAt,
    required this.updatedAt,
    required this.ownerId,
  });

  factory Workspace.create({
    String name = 'Meu Workspace',
    String description = '',
    String icon = '🏠',
    String ownerId = 'user',
  }) {
    final now = DateTime.now();
    return Workspace(
      id: _uuid.v4(),
      name: name,
      description: description,
      icon: icon,
      createdAt: now,
      updatedAt: now,
      ownerId: ownerId,
    );
  }

  Workspace copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    List<String>? documentIds,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerId,
  }) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      documentIds: documentIds ?? this.documentIds,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      ownerId: ownerId ?? this.ownerId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'documentIds': documentIds,
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'ownerId': ownerId,
    };
  }

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '🏠',
      documentIds: List<String>.from(json['documentIds'] as List? ?? []),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      ownerId: json['ownerId'] as String,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        icon,
        documentIds,
        settings,
        createdAt,
        updatedAt,
        ownerId,
      ];
}
