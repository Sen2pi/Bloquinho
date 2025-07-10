import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Tipos de blocos disponíveis no sistema similar ao Notion
enum NotionBlockType {
  // Texto básico
  text,
  paragraph,

  // Cabeçalhos
  heading1,
  heading2,
  heading3,

  // Listas
  bulletList,
  numberedList,
  todoList,
  toggleList,

  // Citações e códigos
  quote,
  code,
  codeBlock,

  // Mídia
  image,
  video,
  audio,
  file,
  embed,

  // Estruturais
  divider,
  pageBreak,
  spacer,

  // Interativos
  table,
  database,
  button,
  bookmark,

  // Avançados
  callout,
  equation,
  template,
  breadcrumb,

  // Layout
  columns,
  column,

  // Links e referências
  pageLink,
  webLink,
  mention,
}

/// Propriedades específicas para diferentes tipos de blocos
class NotionBlockProperties extends Equatable {
  final Map<String, dynamic> data;

  const NotionBlockProperties([this.data = const {}]);

  // Getters para propriedades comuns
  String? get color => data['color'];
  String? get backgroundColor => data['backgroundColor'];
  bool get bold => data['bold'] ?? false;
  bool get italic => data['italic'] ?? false;
  bool get underline => data['underline'] ?? false;
  bool get strikethrough => data['strikethrough'] ?? false;
  bool get code => data['code'] ?? false;
  String? get link => data['link'];

  // Propriedades específicas por tipo
  bool get checked => data['checked'] ?? false; // Para TODO
  String? get language => data['language']; // Para code blocks
  String? get url => data['url']; // Para links, imagens, etc.
  String? get caption => data['caption']; // Para mídia
  int get level => data['level'] ?? 1; // Para headings
  bool get collapsed => data['collapsed'] ?? false; // Para toggle

  // Para tabelas
  int get rows => data['rows'] ?? 1;
  int get columns => data['columns'] ?? 1;
  bool get hasHeader => data['hasHeader'] ?? false;

  // Para callouts
  String? get icon => data['icon'];

  NotionBlockProperties copyWith(Map<String, dynamic> updates) {
    final newData = Map<String, dynamic>.from(data);
    newData.addAll(updates);
    return NotionBlockProperties(newData);
  }

  @override
  List<Object?> get props => [data];
}

/// Modelo principal de bloco do Notion
class NotionBlock extends Equatable {
  final String id;
  final NotionBlockType type;
  final String content;
  final NotionBlockProperties properties;
  final List<NotionBlock> children;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? parentId;

  const NotionBlock({
    required this.id,
    required this.type,
    required this.content,
    this.properties = const NotionBlockProperties(),
    this.children = const [],
    required this.createdAt,
    required this.updatedAt,
    this.parentId,
  });

  factory NotionBlock.create({
    NotionBlockType type = NotionBlockType.text,
    String content = '',
    NotionBlockProperties properties = const NotionBlockProperties(),
    List<NotionBlock> children = const [],
    String? parentId,
  }) {
    final now = DateTime.now();
    return NotionBlock(
      id: _uuid.v4(),
      type: type,
      content: content,
      properties: properties,
      children: children,
      createdAt: now,
      updatedAt: now,
      parentId: parentId,
    );
  }

  NotionBlock copyWith({
    String? id,
    NotionBlockType? type,
    String? content,
    NotionBlockProperties? properties,
    List<NotionBlock>? children,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? parentId,
  }) {
    return NotionBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      properties: properties ?? this.properties,
      children: children ?? this.children,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      parentId: parentId ?? this.parentId,
    );
  }

  // Métodos de verificação de tipo
  bool get isTextBlock => [
        NotionBlockType.text,
        NotionBlockType.paragraph,
        NotionBlockType.heading1,
        NotionBlockType.heading2,
        NotionBlockType.heading3,
      ].contains(type);

  bool get isListBlock => [
        NotionBlockType.bulletList,
        NotionBlockType.numberedList,
        NotionBlockType.todoList,
        NotionBlockType.toggleList,
      ].contains(type);

  bool get isMediaBlock => [
        NotionBlockType.image,
        NotionBlockType.video,
        NotionBlockType.audio,
        NotionBlockType.file,
        NotionBlockType.embed,
      ].contains(type);

  bool get isHeading => [
        NotionBlockType.heading1,
        NotionBlockType.heading2,
        NotionBlockType.heading3,
      ].contains(type);

  bool get canHaveChildren => [
        NotionBlockType.toggleList,
        NotionBlockType.columns,
        NotionBlockType.column,
        NotionBlockType.callout,
      ].contains(type);

  // Serialização
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'content': content,
      'properties': properties.data,
      'children': children.map((child) => child.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'parentId': parentId,
    };
  }

  factory NotionBlock.fromJson(Map<String, dynamic> json) {
    return NotionBlock(
      id: json['id'] as String,
      type: NotionBlockType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotionBlockType.text,
      ),
      content: json['content'] as String? ?? '',
      properties: NotionBlockProperties(
        Map<String, dynamic>.from(json['properties'] as Map? ?? {}),
      ),
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => NotionBlock.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      parentId: json['parentId'] as String?,
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
        parentId,
      ];
}

/// Comandos slash disponíveis
class SlashCommand {
  final String trigger;
  final String displayName;
  final String description;
  final String icon;
  final NotionBlockType blockType;
  final NotionBlockProperties? defaultProperties;

  const SlashCommand({
    required this.trigger,
    required this.displayName,
    required this.description,
    required this.icon,
    required this.blockType,
    this.defaultProperties,
  });
}

/// Lista de comandos slash disponíveis
class SlashCommands {
  static const List<SlashCommand> all = [
    // Texto básico
    SlashCommand(
      trigger: 'text',
      displayName: 'Texto',
      description: 'Comece a escrever texto simples',
      icon: '📝',
      blockType: NotionBlockType.text,
    ),
    SlashCommand(
      trigger: 'paragraph',
      displayName: 'Parágrafo',
      description: 'Crie um parágrafo de texto',
      icon: '📄',
      blockType: NotionBlockType.paragraph,
    ),

    // Cabeçalhos
    SlashCommand(
      trigger: 'h1',
      displayName: 'Título 1',
      description: 'Cabeçalho grande',
      icon: '📰',
      blockType: NotionBlockType.heading1,
      defaultProperties: NotionBlockProperties({'level': 1}),
    ),
    SlashCommand(
      trigger: 'h2',
      displayName: 'Título 2',
      description: 'Cabeçalho médio',
      icon: '📑',
      blockType: NotionBlockType.heading2,
      defaultProperties: NotionBlockProperties({'level': 2}),
    ),
    SlashCommand(
      trigger: 'h3',
      displayName: 'Título 3',
      description: 'Cabeçalho pequeno',
      icon: '📋',
      blockType: NotionBlockType.heading3,
      defaultProperties: NotionBlockProperties({'level': 3}),
    ),

    // Listas
    SlashCommand(
      trigger: 'bullet',
      displayName: 'Lista com marcadores',
      description: 'Crie uma lista simples',
      icon: '•',
      blockType: NotionBlockType.bulletList,
    ),
    SlashCommand(
      trigger: 'numbered',
      displayName: 'Lista numerada',
      description: 'Crie uma lista com números',
      icon: '1.',
      blockType: NotionBlockType.numberedList,
    ),
    SlashCommand(
      trigger: 'todo',
      displayName: 'Lista de tarefas',
      description: 'Acompanhe tarefas com checkboxes',
      icon: '☑️',
      blockType: NotionBlockType.todoList,
    ),
    SlashCommand(
      trigger: 'toggle',
      displayName: 'Lista recolhível',
      description: 'Crie uma lista que pode ser expandida',
      icon: '🔽',
      blockType: NotionBlockType.toggleList,
    ),

    // Formatação
    SlashCommand(
      trigger: 'quote',
      displayName: 'Citação',
      description: 'Capture uma citação',
      icon: '💬',
      blockType: NotionBlockType.quote,
    ),
    SlashCommand(
      trigger: 'code',
      displayName: 'Código',
      description: 'Capture um trecho de código',
      icon: '💻',
      blockType: NotionBlockType.codeBlock,
    ),
    SlashCommand(
      trigger: 'divider',
      displayName: 'Divisor',
      description: 'Separe seções com uma linha',
      icon: '➖',
      blockType: NotionBlockType.divider,
    ),

    // Mídia
    SlashCommand(
      trigger: 'image',
      displayName: 'Imagem',
      description: 'Adicione uma imagem',
      icon: '🖼️',
      blockType: NotionBlockType.image,
    ),
    SlashCommand(
      trigger: 'file',
      displayName: 'Arquivo',
      description: 'Anexe um arquivo',
      icon: '📎',
      blockType: NotionBlockType.file,
    ),

    // Avançados
    SlashCommand(
      trigger: 'table',
      displayName: 'Tabela',
      description: 'Crie uma tabela',
      icon: '📊',
      blockType: NotionBlockType.table,
      defaultProperties: NotionBlockProperties({
        'rows': 3,
        'columns': 3,
        'hasHeader': true,
      }),
    ),
    SlashCommand(
      trigger: 'database',
      displayName: 'Base de dados',
      description: 'Crie uma base de dados',
      icon: '🗄️',
      blockType: NotionBlockType.database,
    ),
    SlashCommand(
      trigger: 'callout',
      displayName: 'Destaque',
      description: 'Destaque informações importantes',
      icon: '💡',
      blockType: NotionBlockType.callout,
      defaultProperties: NotionBlockProperties({'icon': '💡'}),
    ),
    SlashCommand(
      trigger: 'equation',
      displayName: 'Equação',
      description: 'Adicione uma equação matemática',
      icon: '∑',
      blockType: NotionBlockType.equation,
    ),
  ];

  static List<SlashCommand> search(String query) {
    if (query.isEmpty) return all;

    final lowercaseQuery = query.toLowerCase();
    return all
        .where((cmd) =>
            cmd.trigger.toLowerCase().contains(lowercaseQuery) ||
            cmd.displayName.toLowerCase().contains(lowercaseQuery) ||
            cmd.description.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  static SlashCommand? findByTrigger(String trigger) {
    try {
      return all.firstWhere(
          (cmd) => cmd.trigger.toLowerCase() == trigger.toLowerCase());
    } catch (e) {
      return null;
    }
  }
}

/// Ações de formatação contextual
enum FormatAction {
  bold,
  italic,
  underline,
  strikethrough,
  code,
  link,
  color,
  backgroundColor,
  turnIntoHeading1,
  turnIntoHeading2,
  turnIntoHeading3,
  turnIntoBulletList,
  turnIntoNumberedList,
  turnIntoTodo,
  turnIntoQuote,
  turnIntoCode,
  duplicate,
  delete,
}

class ContextualFormatAction {
  final FormatAction action;
  final String displayName;
  final String icon;
  final String? shortcut;

  const ContextualFormatAction({
    required this.action,
    required this.displayName,
    required this.icon,
    this.shortcut,
  });
}

/// Ações de formatação contextual disponíveis
class ContextualActions {
  static const List<ContextualFormatAction> textFormatting = [
    ContextualFormatAction(
      action: FormatAction.bold,
      displayName: 'Negrito',
      icon: 'B',
      shortcut: 'Ctrl+B',
    ),
    ContextualFormatAction(
      action: FormatAction.italic,
      displayName: 'Itálico',
      icon: 'I',
      shortcut: 'Ctrl+I',
    ),
    ContextualFormatAction(
      action: FormatAction.underline,
      displayName: 'Sublinhado',
      icon: 'U',
      shortcut: 'Ctrl+U',
    ),
    ContextualFormatAction(
      action: FormatAction.strikethrough,
      displayName: 'Tachado',
      icon: 'S',
      shortcut: 'Ctrl+Shift+S',
    ),
    ContextualFormatAction(
      action: FormatAction.code,
      displayName: 'Código',
      icon: '</>',
      shortcut: 'Ctrl+E',
    ),
    ContextualFormatAction(
      action: FormatAction.link,
      displayName: 'Link',
      icon: '🔗',
      shortcut: 'Ctrl+K',
    ),
  ];

  static const List<ContextualFormatAction> blockTransforms = [
    ContextualFormatAction(
      action: FormatAction.turnIntoHeading1,
      displayName: 'Transformar em Título 1',
      icon: 'H1',
    ),
    ContextualFormatAction(
      action: FormatAction.turnIntoHeading2,
      displayName: 'Transformar em Título 2',
      icon: 'H2',
    ),
    ContextualFormatAction(
      action: FormatAction.turnIntoHeading3,
      displayName: 'Transformar em Título 3',
      icon: 'H3',
    ),
    ContextualFormatAction(
      action: FormatAction.turnIntoBulletList,
      displayName: 'Transformar em Lista',
      icon: '•',
    ),
    ContextualFormatAction(
      action: FormatAction.turnIntoNumberedList,
      displayName: 'Transformar em Lista Numerada',
      icon: '1.',
    ),
    ContextualFormatAction(
      action: FormatAction.turnIntoTodo,
      displayName: 'Transformar em Lista de Tarefas',
      icon: '☑️',
    ),
    ContextualFormatAction(
      action: FormatAction.turnIntoQuote,
      displayName: 'Transformar em Citação',
      icon: '💬',
    ),
    ContextualFormatAction(
      action: FormatAction.turnIntoCode,
      displayName: 'Transformar em Código',
      icon: '💻',
    ),
  ];

  static const List<ContextualFormatAction> blockActions = [
    ContextualFormatAction(
      action: FormatAction.duplicate,
      displayName: 'Duplicar',
      icon: '📋',
    ),
    ContextualFormatAction(
      action: FormatAction.delete,
      displayName: 'Deletar',
      icon: '��️',
    ),
  ];
}
