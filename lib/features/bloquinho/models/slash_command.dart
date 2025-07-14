import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'notion_block_type.dart';
import '../../../core/l10n/app_strings.dart';

/// Comando slash para o editor Notion-like
/// Representa um comando que pode ser executado digitando "/" + trigger
class SlashCommand {
  final String trigger;
  final String title;
  final String description;
  final IconData icon;
  final NotionBlockType blockType;
  final Map<String, dynamic>? properties;
  final bool isPopular;
  final String? category;

  const SlashCommand({
    required this.trigger,
    required this.title,
    required this.description,
    required this.icon,
    required this.blockType,
    this.properties,
    this.isPopular = false,
    this.category,
  });

  /// Lista de todos os comandos disponíveis
  static List<SlashCommand> allCommands(AppStrings strings) => [
        // Comandos básicos de texto
        SlashCommand(
          trigger: 'texto',
          title: strings.text,
          description: strings.simpleParagraph,
          icon: PhosphorIcons.textT(),
          blockType: NotionBlockType.text,
          isPopular: true,
          category: 'texto',
        ),

        // Títulos
        SlashCommand(
          trigger: 'h1',
          title: strings.title1,
          description: strings.largeHeader,
          icon: PhosphorIcons.textHOne(),
          blockType: NotionBlockType.heading1,
          isPopular: true,
          category: 'titulos',
        ),
        SlashCommand(
          trigger: 'h2',
          title: strings.title2,
          description: strings.mediumHeader,
          icon: PhosphorIcons.textHTwo(),
          blockType: NotionBlockType.heading2,
          category: 'titulos',
        ),
        SlashCommand(
          trigger: 'h3',
          title: strings.title3,
          description: strings.smallHeader,
          icon: PhosphorIcons.textHThree(),
          blockType: NotionBlockType.heading3,
          category: 'titulos',
        ),

        // Listas
        SlashCommand(
          trigger: 'lista',
          title: strings.list,
          description: strings.bulletList,
          icon: PhosphorIcons.listBullets(),
          blockType: NotionBlockType.bulletList,
          isPopular: true,
          category: 'listas',
        ),
        SlashCommand(
          trigger: 'numerada',
          title: strings.numberedList,
          description: strings.numberedListDescription,
          icon: PhosphorIcons.listNumbers(),
          blockType: NotionBlockType.numberedList,
          category: 'listas',
        ),
        SlashCommand(
          trigger: 'todo',
          title: strings.todoList,
          description: strings.todoListWithCheckboxes,
          icon: PhosphorIcons.checkSquare(),
          blockType: NotionBlockType.todoList,
          isPopular: true,
          category: 'listas',
        ),
        SlashCommand(
          trigger: 'toggle',
          title: strings.expandableList,
          description: strings.expandableListDescription,
          icon: PhosphorIcons.caretRight(),
          blockType: NotionBlockType.toggle,
          category: 'listas',
        ),

        // Blocos especiais
        SlashCommand(
          trigger: 'citacao',
          title: strings.quote,
          description: strings.quoteBlock,
          icon: PhosphorIcons.quotes(),
          blockType: NotionBlockType.quote,
          category: 'especiais',
        ),
        SlashCommand(
          trigger: 'callout',
          title: strings.callout,
          description: strings.calloutWithIcon,
          icon: PhosphorIcons.lightbulb(),
          blockType: NotionBlockType.callout,
          category: 'especiais',
        ),

        // Código
        SlashCommand(
          trigger: 'codigo',
          title: strings.code,
          description: strings.codeBlock,
          icon: PhosphorIcons.code(),
          blockType: NotionBlockType.codeBlock,
          isPopular: true,
          category: 'codigo',
        ),
        SlashCommand(
          trigger: 'equacao',
          title: strings.equation,
          description: strings.mathEquation,
          icon: PhosphorIcons.mathOperations(),
          blockType: NotionBlockType.equation,
          category: 'codigo',
        ),

        // Layout
        SlashCommand(
          trigger: 'divisor',
          title: strings.divider,
          description: strings.dividerLine,
          icon: PhosphorIcons.minus(),
          blockType: NotionBlockType.divider,
          category: 'layout',
        ),
        SlashCommand(
          trigger: 'espacador',
          title: strings.spacer,
          description: strings.verticalSpace,
          icon: PhosphorIcons.arrowsVertical(),
          blockType: NotionBlockType.spacer,
          category: 'layout',
        ),

        // Mídia
        SlashCommand(
          trigger: 'imagem',
          title: strings.image,
          description: strings.insertImage,
          icon: PhosphorIcons.image(),
          blockType: NotionBlockType.image,
          isPopular: true,
          category: 'midia',
        ),
        SlashCommand(
          trigger: 'video',
          title: strings.video,
          description: strings.insertVideo,
          icon: PhosphorIcons.video(),
          blockType: NotionBlockType.video,
          category: 'midia',
        ),
        SlashCommand(
          trigger: 'arquivo',
          title: strings.file,
          description: strings.insertFile,
          icon: PhosphorIcons.file(),
          blockType: NotionBlockType.file,
          category: 'midia',
        ),

        // Links
        SlashCommand(
          trigger: 'pagina',
          title: strings.pageLink,
          description: strings.linkToAnotherPage,
          icon: PhosphorIcons.link(),
          blockType: NotionBlockType.pageLink,
          category: 'links',
        ),
        SlashCommand(
          trigger: 'weblink',
          title: strings.webLink,
          description: strings.linkToExternalSite,
          icon: PhosphorIcons.globe(),
          blockType: NotionBlockType.webLink,
          category: 'links',
        ),

        // Dados
        SlashCommand(
          trigger: 'tabela',
          title: strings.table,
          description: strings.createTable,
          icon: PhosphorIcons.table(),
          blockType: NotionBlockType.table,
          category: 'dados',
        ),
        SlashCommand(
          trigger: 'database',
          title: strings.database,
          description: strings.createDatabase,
          icon: PhosphorIcons.database(),
          blockType: NotionBlockType.database,
          category: 'dados',
        ),

        // Avançados
        SlashCommand(
          trigger: 'embed',
          title: strings.embed,
          description: strings.embedExternalContent,
          icon: PhosphorIcons.browser(),
          blockType: NotionBlockType.embed,
          category: 'avancado',
        ),
        SlashCommand(
          trigger: 'bookmark',
          title: strings.bookmark,
          description: strings.saveLinkAsBookmark,
          icon: PhosphorIcons.bookmark(),
          blockType: NotionBlockType.bookmark,
          category: 'avancado',
        ),
        SlashCommand(
          trigger: 'indice',
          title: strings.tableOfContents,
          description: strings.createTableOfContents,
          icon: PhosphorIcons.listChecks(),
          blockType: NotionBlockType.tableOfContents,
          category: 'avancado',
        ),
      ];

  /// Filtrar comandos por categoria
  static List<SlashCommand> getByCategory(String category, AppStrings strings) {
    return allCommands(strings).where((cmd) => cmd.category == category).toList();
  }

  /// Obter comandos populares
  static List<SlashCommand> popularCommands(AppStrings strings) {
    return allCommands(strings).where((cmd) => cmd.isPopular).toList();
  }

  /// Buscar comandos por texto
  static List<SlashCommand> search(String query, AppStrings strings) {
    if (query.isEmpty) return popularCommands(strings);

    final lowerQuery = query.toLowerCase();
    return allCommands(strings).where((cmd) {
      return cmd.trigger.toLowerCase().contains(lowerQuery) ||
          cmd.title.toLowerCase().contains(lowerQuery) ||
          cmd.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Obter comando por trigger
  static SlashCommand? getByTrigger(String trigger, AppStrings strings) {
    try {
      return allCommands(strings).firstWhere((cmd) => cmd.trigger == trigger);
    } catch (e) {
      return null;
    }
  }

  /// Obter comando por tipo de bloco
  static SlashCommand? getByBlockType(NotionBlockType blockType, AppStrings strings) {
    try {
      return allCommands(strings).firstWhere((cmd) => cmd.blockType == blockType);
    } catch (e) {
      return null;
    }
  }

  /// Categorias disponíveis
  static List<String> categories(AppStrings strings) {
    return allCommands(strings)
        .map((cmd) => cmd.category)
        .where((cat) => cat != null)
        .cast<String>()
        .toSet()
        .toList();
  }

  /// Nome da categoria
  String getCategoryName(AppStrings strings) {
    switch (category) {
      case 'texto':
        return strings.text;
      case 'titulos':
        return strings.titles;
      case 'listas':
        return strings.lists;
      case 'especiais':
        return strings.specials;
      case 'codigo':
        return strings.code;
      case 'layout':
        return strings.layout;
      case 'midia':
        return strings.media;
      case 'links':
        return strings.links;
      case 'dados':
        return strings.data;
      case 'avancado':
        return strings.advanced;
      default:
        return strings.others;
    }
  }

  /// Ícone da categoria
  IconData get categoryIcon {
    switch (category) {
      case 'texto':
        return PhosphorIcons.textT();
      case 'titulos':
        return PhosphorIcons.textH();
      case 'listas':
        return PhosphorIcons.listBullets();
      case 'especiais':
        return PhosphorIcons.star();
      case 'codigo':
        return PhosphorIcons.code();
      case 'layout':
        return PhosphorIcons.layout();
      case 'midia':
        return PhosphorIcons.image();
      case 'links':
        return PhosphorIcons.link();
      case 'dados':
        return PhosphorIcons.database();
      case 'avancado':
        return PhosphorIcons.gear();
      default:
        return PhosphorIcons.circle();
    }
  }

  /// Cor da categoria
  Color get categoryColor {
    switch (category) {
      case 'texto':
        return Colors.blue;
      case 'titulos':
        return Colors.purple;
      case 'listas':
        return Colors.green;
      case 'especiais':
        return Colors.orange;
      case 'codigo':
        return Colors.indigo;
      case 'layout':
        return Colors.teal;
      case 'midia':
        return Colors.pink;
      case 'links':
        return Colors.cyan;
      case 'dados':
        return Colors.amber;
      case 'avancado':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'trigger': trigger,
      'title': title,
      'description': description,
      'icon': icon.codePoint,
      'blockType': blockType.name,
      'properties': properties,
      'isPopular': isPopular,
      'category': category,
    };
  }

  /// Criar a partir de JSON
  factory SlashCommand.fromJson(Map<String, dynamic> json) {
    return SlashCommand(
      trigger: json['trigger'],
      title: json['title'],
      description: json['description'],
      icon: IconData(json['icon'], fontFamily: 'PhosphorIcons'),
      blockType: NotionBlockType.values.firstWhere(
        (type) => type.name == json['blockType'],
      ),
      properties: json['properties'],
      isPopular: json['isPopular'] ?? false,
      category: json['category'],
    );
  }

  /// Copiar com modificações
  SlashCommand copyWith({
    String? trigger,
    String? title,
    String? description,
    IconData? icon,
    NotionBlockType? blockType,
    Map<String, dynamic>? properties,
    bool? isPopular,
    String? category,
  }) {
    return SlashCommand(
      trigger: trigger ?? this.trigger,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      blockType: blockType ?? this.blockType,
      properties: properties ?? this.properties,
      isPopular: isPopular ?? this.isPopular,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SlashCommand && other.trigger == trigger;
  }

  @override
  int get hashCode => trigger.hashCode;

  @override
  String toString() {
    return 'SlashCommand(trigger: $trigger, title: $title, blockType: $blockType)';
  }
}
