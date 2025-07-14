import '../../../core/l10n/app_strings.dart';

/// Enum para tipos de blocos do Notion
/// Baseado na especificação oficial do Notion com 37 tipos de blocos
enum NotionBlockType {
  // Blocos básicos de texto
  text, // Parágrafo simples
  paragraph, // Alias para text

  // Títulos
  heading1, // Título 1 (H1)
  heading2, // Título 2 (H2)
  heading3, // Título 3 (H3)

  // Listas
  bulletList, // Lista com marcadores
  numberedList, // Lista numerada
  todoList, // Lista de tarefas (checkbox)
  toggle, // Lista expansível

  // Blocos especiais
  quote, // Citação
  callout, // Callout com ícone
  code, // Código inline
  codeBlock, // Bloco de código
  equation, // Equação matemática

  // Mídia
  image, // Imagem
  video, // Vídeo
  audio, // Áudio
  file, // Arquivo
  pdf, // PDF

  // Layout
  divider, // Linha divisória
  spacer, // Espaçador
  columnList, // Lista de colunas
  column, // Coluna individual

  // Bases de dados
  table, // Tabela
  database, // Base de dados
  databaseView, // Visualização de BD

  // Links e referências
  pageLink, // Link para página
  webLink, // Link web
  mention, // Menção
  syncedBlock, // Bloco sincronizado

  // Blocos avançados
  embed, // Embed externo
  bookmark, // Bookmark
  breadcrumb, // Breadcrumb
  tableOfContents, // Índice
  template, // Template

  // Blocos de mídia avançados
  map, // Mapa
  chart, // Gráfico
  calendar, // Calendário
  timeline, // Timeline

  // Blocos de formulário
  form, // Formulário
  poll, // Enquete
  vote, // Votação

  // Blocos de colaboração
  comment, // Comentário
  annotation, // Anotação
  version, // Versão
}

/// Extensões para facilitar uso do NotionBlockType
extension NotionBlockTypeExtension on NotionBlockType {
  /// Nome legível do tipo
  String displayName(AppStrings strings) {
    switch (this) {
      case NotionBlockType.text:
      case NotionBlockType.paragraph:
        return strings.text;
      case NotionBlockType.heading1:
        return strings.title1;
      case NotionBlockType.heading2:
        return strings.title2;
      case NotionBlockType.heading3:
        return strings.title3;
      case NotionBlockType.bulletList:
        return strings.list;
      case NotionBlockType.numberedList:
        return strings.numberedList;
      case NotionBlockType.todoList:
        return strings.todoList;
      case NotionBlockType.toggle:
        return strings.expandableList;
      case NotionBlockType.quote:
        return strings.quote;
      case NotionBlockType.callout:
        return strings.callout;
      case NotionBlockType.code:
        return strings.code;
      case NotionBlockType.codeBlock:
        return strings.codeBlock;
      case NotionBlockType.equation:
        return strings.equation;
      case NotionBlockType.image:
        return strings.image;
      case NotionBlockType.video:
        return strings.video;
      case NotionBlockType.audio:
        return strings.audio;
      case NotionBlockType.file:
        return strings.file;
      case NotionBlockType.pdf:
        return strings.pdf;
      case NotionBlockType.divider:
        return strings.divider;
      case NotionBlockType.spacer:
        return strings.spacer;
      case NotionBlockType.columnList:
        return strings.columns;
      case NotionBlockType.column:
        return strings.column;
      case NotionBlockType.table:
        return strings.table;
      case NotionBlockType.database:
        return strings.database;
      case NotionBlockType.databaseView:
        return strings.databaseView;
      case NotionBlockType.pageLink:
        return strings.pageLink;
      case NotionBlockType.webLink:
        return strings.webLink;
      case NotionBlockType.mention:
        return strings.mention;
      case NotionBlockType.syncedBlock:
        return strings.syncedBlock;
      case NotionBlockType.embed:
        return strings.embed;
      case NotionBlockType.bookmark:
        return strings.bookmark;
      case NotionBlockType.breadcrumb:
        return strings.breadcrumb;
      case NotionBlockType.tableOfContents:
        return strings.tableOfContents;
      case NotionBlockType.template:
        return strings.template;
      case NotionBlockType.map:
        return strings.map;
      case NotionBlockType.chart:
        return strings.chart;
      case NotionBlockType.calendar:
        return strings.calendar;
      case NotionBlockType.timeline:
        return strings.timeline;
      case NotionBlockType.form:
        return strings.form;
      case NotionBlockType.poll:
        return strings.poll;
      case NotionBlockType.vote:
        return strings.vote;
      case NotionBlockType.comment:
        return strings.comment;
      case NotionBlockType.annotation:
        return strings.annotation;
      case NotionBlockType.version:
        return strings.version;
    }
  }

  /// Descrição do tipo
  String description(AppStrings strings) {
    switch (this) {
      case NotionBlockType.text:
      case NotionBlockType.paragraph:
        return strings.simpleParagraph;
      case NotionBlockType.heading1:
        return strings.largeHeader;
      case NotionBlockType.heading2:
        return strings.mediumHeader;
      case NotionBlockType.heading3:
        return strings.smallHeader;
      case NotionBlockType.bulletList:
        return strings.bulletList;
      case NotionBlockType.numberedList:
        return strings.numberedListDescription;
      case NotionBlockType.todoList:
        return strings.todoListWithCheckboxes;
      case NotionBlockType.toggle:
        return strings.expandableList;
      case NotionBlockType.quote:
        return strings.quoteBlock;
      case NotionBlockType.callout:
        return strings.calloutWithIcon;
      case NotionBlockType.code:
        return strings.inlineCode;
      case NotionBlockType.codeBlock:
        return strings.codeBlock;
      case NotionBlockType.equation:
        return strings.mathEquation;
      case NotionBlockType.image:
        return strings.image;
      case NotionBlockType.video:
        return strings.video;
      case NotionBlockType.audio:
        return strings.audio;
      case NotionBlockType.file:
        return strings.file;
      case NotionBlockType.pdf:
        return strings.pdf;
      case NotionBlockType.divider:
        return strings.dividerLine;
      case NotionBlockType.spacer:
        return strings.spacer;
      case NotionBlockType.columnList:
        return strings.columnList;
      case NotionBlockType.column:
        return strings.individualColumn;
      case NotionBlockType.table:
        return strings.table;
      case NotionBlockType.database:
        return strings.database;
      case NotionBlockType.databaseView:
        return strings.databaseViewDescription;
      case NotionBlockType.pageLink:
        return strings.linkToAnotherPage;
      case NotionBlockType.webLink:
        return strings.linkToExternalSite;
      case NotionBlockType.mention:
        return strings.mention;
      case NotionBlockType.syncedBlock:
        return strings.syncedBlock;
      case NotionBlockType.embed:
        return strings.externalEmbed;
      case NotionBlockType.bookmark:
        return strings.bookmark;
      case NotionBlockType.breadcrumb:
        return strings.breadcrumb;
      case NotionBlockType.tableOfContents:
        return strings.tableOfContents;
      case NotionBlockType.template:
        return strings.template;
      case NotionBlockType.map:
        return strings.map;
      case NotionBlockType.chart:
        return strings.chart;
      case NotionBlockType.calendar:
        return strings.calendar;
      case NotionBlockType.timeline:
        return strings.timeline;
      case NotionBlockType.form:
        return strings.form;
      case NotionBlockType.poll:
        return strings.poll;
      case NotionBlockType.vote:
        return strings.vote;
      case NotionBlockType.comment:
        return strings.comment;
      case NotionBlockType.annotation:
        return strings.annotation;
      case NotionBlockType.version:
        return strings.version;
    }
  }

  /// Comando slash correspondente
  String get slashCommand {
    switch (this) {
      case NotionBlockType.text:
      case NotionBlockType.paragraph:
        return 'texto';
      case NotionBlockType.heading1:
        return 'h1';
      case NotionBlockType.heading2:
        return 'h2';
      case NotionBlockType.heading3:
        return 'h3';
      case NotionBlockType.bulletList:
        return 'lista';
      case NotionBlockType.numberedList:
        return 'numerada';
      case NotionBlockType.todoList:
        return 'todo';
      case NotionBlockType.toggle:
        return 'toggle';
      case NotionBlockType.quote:
        return 'citacao';
      case NotionBlockType.callout:
        return 'callout';
      case NotionBlockType.code:
        return 'codigo';
      case NotionBlockType.codeBlock:
        return 'codigo';
      case NotionBlockType.equation:
        return 'equacao';
      case NotionBlockType.image:
        return 'imagem';
      case NotionBlockType.video:
        return 'video';
      case NotionBlockType.audio:
        return 'audio';
      case NotionBlockType.file:
        return 'arquivo';
      case NotionBlockType.pdf:
        return 'pdf';
      case NotionBlockType.divider:
        return 'divisor';
      case NotionBlockType.spacer:
        return 'espacador';
      case NotionBlockType.columnList:
        return 'colunas';
      case NotionBlockType.column:
        return 'coluna';
      case NotionBlockType.table:
        return 'tabela';
      case NotionBlockType.database:
        return 'database';
      case NotionBlockType.databaseView:
        return 'view';
      case NotionBlockType.pageLink:
        return 'pagina';
      case NotionBlockType.webLink:
        return 'weblink';
      case NotionBlockType.mention:
        return 'menção';
      case NotionBlockType.syncedBlock:
        return 'sync';
      case NotionBlockType.embed:
        return 'embed';
      case NotionBlockType.bookmark:
        return 'bookmark';
      case NotionBlockType.breadcrumb:
        return 'breadcrumb';
      case NotionBlockType.tableOfContents:
        return 'indice';
      case NotionBlockType.template:
        return 'template';
      case NotionBlockType.map:
        return 'mapa';
      case NotionBlockType.chart:
        return 'grafico';
      case NotionBlockType.calendar:
        return 'calendario';
      case NotionBlockType.timeline:
        return 'timeline';
      case NotionBlockType.form:
        return 'formulario';
      case NotionBlockType.poll:
        return 'enquete';
      case NotionBlockType.vote:
        return 'votacao';
      case NotionBlockType.comment:
        return 'comentario';
      case NotionBlockType.annotation:
        return 'anotacao';
      case NotionBlockType.version:
        return 'versao';
    }
  }

  /// Verificar se é um bloco de texto
  bool get isTextBlock {
    return this == NotionBlockType.text ||
        this == NotionBlockType.paragraph ||
        this == NotionBlockType.heading1 ||
        this == NotionBlockType.heading2 ||
        this == NotionBlockType.heading3;
  }

  /// Verificar se é uma lista
  bool get isListBlock {
    return this == NotionBlockType.bulletList ||
        this == NotionBlockType.numberedList ||
        this == NotionBlockType.todoList ||
        this == NotionBlockType.toggle;
  }

  /// Verificar se é um bloco de mídia
  bool get isMediaBlock {
    return this == NotionBlockType.image ||
        this == NotionBlockType.video ||
        this == NotionBlockType.audio ||
        this == NotionBlockType.file ||
        this == NotionBlockType.pdf;
  }

  /// Verificar se é um bloco de layout
  bool get isLayoutBlock {
    return this == NotionBlockType.divider ||
        this == NotionBlockType.spacer ||
        this == NotionBlockType.columnList ||
        this == NotionBlockType.column;
  }

  /// Verificar se é um bloco de dados
  bool get isDataBlock {
    return this == NotionBlockType.table ||
        this == NotionBlockType.database ||
        this == NotionBlockType.databaseView;
  }

  /// Verificar se é um bloco de link
  bool get isLinkBlock {
    return this == NotionBlockType.pageLink ||
        this == NotionBlockType.webLink ||
        this == NotionBlockType.mention;
  }
}
