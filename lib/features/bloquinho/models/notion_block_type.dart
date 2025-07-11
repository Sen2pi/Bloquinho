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
  String get displayName {
    switch (this) {
      case NotionBlockType.text:
      case NotionBlockType.paragraph:
        return 'Texto';
      case NotionBlockType.heading1:
        return 'Título 1';
      case NotionBlockType.heading2:
        return 'Título 2';
      case NotionBlockType.heading3:
        return 'Título 3';
      case NotionBlockType.bulletList:
        return 'Lista';
      case NotionBlockType.numberedList:
        return 'Lista numerada';
      case NotionBlockType.todoList:
        return 'Lista de tarefas';
      case NotionBlockType.toggle:
        return 'Lista expansível';
      case NotionBlockType.quote:
        return 'Citação';
      case NotionBlockType.callout:
        return 'Callout';
      case NotionBlockType.code:
        return 'Código';
      case NotionBlockType.codeBlock:
        return 'Bloco de código';
      case NotionBlockType.equation:
        return 'Equação';
      case NotionBlockType.image:
        return 'Imagem';
      case NotionBlockType.video:
        return 'Vídeo';
      case NotionBlockType.audio:
        return 'Áudio';
      case NotionBlockType.file:
        return 'Arquivo';
      case NotionBlockType.pdf:
        return 'PDF';
      case NotionBlockType.divider:
        return 'Divisor';
      case NotionBlockType.spacer:
        return 'Espaçador';
      case NotionBlockType.columnList:
        return 'Colunas';
      case NotionBlockType.column:
        return 'Coluna';
      case NotionBlockType.table:
        return 'Tabela';
      case NotionBlockType.database:
        return 'Base de dados';
      case NotionBlockType.databaseView:
        return 'Visualização';
      case NotionBlockType.pageLink:
        return 'Link de página';
      case NotionBlockType.webLink:
        return 'Link web';
      case NotionBlockType.mention:
        return 'Menção';
      case NotionBlockType.syncedBlock:
        return 'Bloco sincronizado';
      case NotionBlockType.embed:
        return 'Embed';
      case NotionBlockType.bookmark:
        return 'Bookmark';
      case NotionBlockType.breadcrumb:
        return 'Breadcrumb';
      case NotionBlockType.tableOfContents:
        return 'Índice';
      case NotionBlockType.template:
        return 'Template';
      case NotionBlockType.map:
        return 'Mapa';
      case NotionBlockType.chart:
        return 'Gráfico';
      case NotionBlockType.calendar:
        return 'Calendário';
      case NotionBlockType.timeline:
        return 'Timeline';
      case NotionBlockType.form:
        return 'Formulário';
      case NotionBlockType.poll:
        return 'Enquete';
      case NotionBlockType.vote:
        return 'Votação';
      case NotionBlockType.comment:
        return 'Comentário';
      case NotionBlockType.annotation:
        return 'Anotação';
      case NotionBlockType.version:
        return 'Versão';
    }
  }

  /// Descrição do tipo
  String get description {
    switch (this) {
      case NotionBlockType.text:
      case NotionBlockType.paragraph:
        return 'Parágrafo simples';
      case NotionBlockType.heading1:
        return 'Cabeçalho grande';
      case NotionBlockType.heading2:
        return 'Cabeçalho médio';
      case NotionBlockType.heading3:
        return 'Cabeçalho pequeno';
      case NotionBlockType.bulletList:
        return 'Lista com marcadores';
      case NotionBlockType.numberedList:
        return 'Lista com números';
      case NotionBlockType.todoList:
        return 'Lista com checkboxes';
      case NotionBlockType.toggle:
        return 'Lista expansível';
      case NotionBlockType.quote:
        return 'Bloco de citação';
      case NotionBlockType.callout:
        return 'Callout com ícone';
      case NotionBlockType.code:
        return 'Código inline';
      case NotionBlockType.codeBlock:
        return 'Bloco de código';
      case NotionBlockType.equation:
        return 'Equação matemática';
      case NotionBlockType.image:
        return 'Imagem';
      case NotionBlockType.video:
        return 'Vídeo';
      case NotionBlockType.audio:
        return 'Áudio';
      case NotionBlockType.file:
        return 'Arquivo';
      case NotionBlockType.pdf:
        return 'PDF';
      case NotionBlockType.divider:
        return 'Linha divisória';
      case NotionBlockType.spacer:
        return 'Espaçador';
      case NotionBlockType.columnList:
        return 'Lista de colunas';
      case NotionBlockType.column:
        return 'Coluna individual';
      case NotionBlockType.table:
        return 'Tabela';
      case NotionBlockType.database:
        return 'Base de dados';
      case NotionBlockType.databaseView:
        return 'Visualização de BD';
      case NotionBlockType.pageLink:
        return 'Link para outra página';
      case NotionBlockType.webLink:
        return 'Link para site externo';
      case NotionBlockType.mention:
        return 'Menção';
      case NotionBlockType.syncedBlock:
        return 'Bloco sincronizado';
      case NotionBlockType.embed:
        return 'Embed externo';
      case NotionBlockType.bookmark:
        return 'Bookmark';
      case NotionBlockType.breadcrumb:
        return 'Breadcrumb';
      case NotionBlockType.tableOfContents:
        return 'Índice';
      case NotionBlockType.template:
        return 'Template';
      case NotionBlockType.map:
        return 'Mapa';
      case NotionBlockType.chart:
        return 'Gráfico';
      case NotionBlockType.calendar:
        return 'Calendário';
      case NotionBlockType.timeline:
        return 'Timeline';
      case NotionBlockType.form:
        return 'Formulário';
      case NotionBlockType.poll:
        return 'Enquete';
      case NotionBlockType.vote:
        return 'Votação';
      case NotionBlockType.comment:
        return 'Comentário';
      case NotionBlockType.annotation:
        return 'Anotação';
      case NotionBlockType.version:
        return 'Versão';
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
