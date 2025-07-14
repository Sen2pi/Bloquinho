/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/l10n/app_strings.dart';

/// Comando slash para o editor Bloquinho
/// Representa um comando que pode ser executado digitando "/" + trigger
class BloquinhoSlashCommand {
  final String trigger;
  final String title;
  final String description;
  final IconData icon;
  final String markdownTemplate;
  final bool isPopular;
  final String? category;
  final Color? categoryColor;

  const BloquinhoSlashCommand({
    required this.trigger,
    required this.title,
    required this.description,
    required this.icon,
    required this.markdownTemplate,
    this.isPopular = false,
    this.category,
    this.categoryColor,
  });

  /// Lista de todos os comandos disponíveis
  static List<BloquinhoSlashCommand> allCommands(AppStrings strings) => [
        // ===== TÍTULOS =====
        BloquinhoSlashCommand(
          trigger: 'h1',
          title: strings.title1,
          description: strings.largeHeader,
          icon: PhosphorIcons.textHOne(),
          markdownTemplate: '# ',
          isPopular: true,
          category: 'titulos',
          categoryColor: Colors.purple,
        ),
        BloquinhoSlashCommand(
          trigger: 'h2',
          title: strings.title2,
          description: strings.mediumHeader,
          icon: PhosphorIcons.textHTwo(),
          markdownTemplate: '## ',
          category: 'titulos',
          categoryColor: Colors.purple,
        ),
        BloquinhoSlashCommand(
          trigger: 'h3',
          title: strings.title3,
          description: strings.smallHeader,
          icon: PhosphorIcons.textHThree(),
          markdownTemplate: '### ',
          category: 'titulos',
          categoryColor: Colors.purple,
        ),
        BloquinhoSlashCommand(
          trigger: 'h4',
          title: strings.title4,
          description: strings.verySmallHeader,
          icon: PhosphorIcons.textHFour(),
          markdownTemplate: '#### ',
          category: 'titulos',
          categoryColor: Colors.purple,
        ),

        // ===== LISTAS =====
        BloquinhoSlashCommand(
          trigger: 'lista',
          title: strings.list,
          description: strings.bulletList,
          icon: PhosphorIcons.listBullets(),
          markdownTemplate: '- ',
          isPopular: true,
          category: 'listas',
          categoryColor: Colors.green,
        ),
        BloquinhoSlashCommand(
          trigger: 'numerada',
          title: strings.numberedList,
          description: strings.numberedListDescription,
          icon: PhosphorIcons.listNumbers(),
          markdownTemplate: '1. ',
          category: 'listas',
          categoryColor: Colors.green,
        ),
        BloquinhoSlashCommand(
          trigger: 'todo',
          title: strings.checklist,
          description: strings.todoList,
          icon: PhosphorIcons.checkSquare(),
          markdownTemplate: '- [ ] ',
          isPopular: true,
          category: 'listas',
          categoryColor: Colors.green,
        ),
        BloquinhoSlashCommand(
          trigger: 'feito',
          title: strings.doneItem,
          description: strings.checkedChecklistItem,
          icon: PhosphorIcons.checkSquare(),
          markdownTemplate: '- [x] ',
          category: 'listas',
          categoryColor: Colors.green,
        ),

        // ===== TEXTO =====
        BloquinhoSlashCommand(
          trigger: 'texto',
          title: strings.text,
          description: strings.simpleParagraph,
          icon: PhosphorIcons.textT(),
          markdownTemplate: '',
          isPopular: true,
          category: 'texto',
          categoryColor: Colors.blue,
        ),
        BloquinhoSlashCommand(
          trigger: 'negrito',
          title: strings.bold,
          description: strings.boldText,
          icon: PhosphorIcons.textB(),
          markdownTemplate: '**texto**',
          category: 'texto',
          categoryColor: Colors.blue,
        ),
        BloquinhoSlashCommand(
          trigger: 'italico',
          title: strings.italic,
          description: strings.italicText,
          icon: PhosphorIcons.textItalic(),
          markdownTemplate: '*texto*',
          category: 'texto',
          categoryColor: Colors.blue,
        ),
        BloquinhoSlashCommand(
          trigger: 'riscado',
          title: strings.strikethrough,
          description: strings.strikethroughText,
          icon: PhosphorIcons.textStrikethrough(),
          markdownTemplate: '~~texto~~',
          category: 'texto',
          categoryColor: Colors.blue,
        ),
        BloquinhoSlashCommand(
          trigger: 'codigo',
          title: strings.inlineCode,
          description: strings.inlineCodeDescription,
          icon: PhosphorIcons.code(),
          markdownTemplate: '`código`',
          category: 'texto',
          categoryColor: Colors.blue,
        ),

        // ===== CITAÇÕES =====
        BloquinhoSlashCommand(
          trigger: 'citacao',
          title: strings.quote,
          description: strings.quoteBlock,
          icon: PhosphorIcons.quotes(),
          markdownTemplate: '> ',
          category: 'citacoes',
          categoryColor: Colors.orange,
        ),
        BloquinhoSlashCommand(
          trigger: 'callout',
          title: strings.callout,
          description: strings.calloutBlock,
          icon: PhosphorIcons.lightbulb(),
          markdownTemplate: '> 💡 **Callout**\n> ',
          category: 'citacoes',
          categoryColor: Colors.orange,
        ),

        // ===== CÓDIGO =====
        BloquinhoSlashCommand(
          trigger: 'bloco',
          title: strings.codeBlock,
          description: strings.codeBlockWithSyntaxHighlighting,
          icon: PhosphorIcons.codeBlock(),
          markdownTemplate: '```\n\n```',
          isPopular: true,
          category: 'codigo',
          categoryColor: Colors.indigo,
        ),
        BloquinhoSlashCommand(
          trigger: 'javascript',
          title: 'JavaScript',
          description: strings.javascriptCode,
          icon: PhosphorIcons.fileJs(),
          markdownTemplate: '```javascript\n\n```',
          category: 'codigo',
          categoryColor: Colors.indigo,
        ),
        BloquinhoSlashCommand(
          trigger: 'python',
          title: 'Python',
          description: strings.pythonCode,
          icon: PhosphorIcons.filePy(),
          markdownTemplate: '```python\n\n```',
          category: 'codigo',
          categoryColor: Colors.indigo,
        ),
        BloquinhoSlashCommand(
          trigger: 'dart',
          title: 'Dart',
          description: strings.dartCode,
          icon: PhosphorIcons.fileCode(),
          markdownTemplate: '```dart\n\n```',
          category: 'codigo',
          categoryColor: Colors.indigo,
        ),
        BloquinhoSlashCommand(
          trigger: 'html',
          title: 'HTML',
          description: strings.htmlCode,
          icon: PhosphorIcons.fileHtml(),
          markdownTemplate: '```html\n\n```',
          category: 'codigo',
          categoryColor: Colors.indigo,
        ),
        BloquinhoSlashCommand(
          trigger: 'css',
          title: 'CSS',
          description: strings.cssCode,
          icon: PhosphorIcons.fileCss(),
          markdownTemplate: '```css\n\n```',
          category: 'codigo',
          categoryColor: Colors.indigo,
        ),
        BloquinhoSlashCommand(
          trigger: 'json',
          title: 'JSON',
          description: strings.jsonCode,
          icon: PhosphorIcons.fileCode(),
          markdownTemplate: '```json\n\n```',
          category: 'codigo',
          categoryColor: Colors.indigo,
        ),

        // ===== MATEMÁTICA =====
        BloquinhoSlashCommand(
          trigger: 'latex',
          title: 'LaTeX',
          description: strings.latexEquation,
          icon: PhosphorIcons.mathOperations(),
          markdownTemplate: r'\frac{a}{b}',
          isPopular: true,
          category: 'matematica',
          categoryColor: Colors.red,
        ),
        BloquinhoSlashCommand(
          trigger: 'equacao',
          title: strings.inlineEquation,
          description: strings.inlineEquationDescription,
          icon: PhosphorIcons.mathOperations(),
          markdownTemplate: r'x = y',
          category: 'matematica',
          categoryColor: Colors.red,
        ),
        BloquinhoSlashCommand(
          trigger: 'integral',
          title: strings.integral,
          description: strings.integralSymbol,
          icon: PhosphorIcons.mathOperations(),
          markdownTemplate: r'\int_{a}^{b} f(x) dx',
          category: 'matematica',
          categoryColor: Colors.red,
        ),
        BloquinhoSlashCommand(
          trigger: 'soma',
          title: strings.summation,
          description: strings.summationSymbol,
          icon: PhosphorIcons.mathOperations(),
          markdownTemplate: r'\sum_{i=1}^{n} x_i',
          category: 'matematica',
          categoryColor: Colors.red,
        ),
        BloquinhoSlashCommand(
          trigger: 'produto',
          title: strings.product,
          description: strings.productSymbol,
          icon: PhosphorIcons.mathOperations(),
          markdownTemplate: r'\prod_{i=1}^{n} x_i',
          category: 'matematica',
          categoryColor: Colors.red,
        ),
        BloquinhoSlashCommand(
          trigger: 'limite',
          title: strings.limit,
          description: strings.limitSymbol,
          icon: PhosphorIcons.mathOperations(),
          markdownTemplate: r'\lim_{x \to \infty} f(x)',
          category: 'matematica',
          categoryColor: Colors.red,
        ),
        BloquinhoSlashCommand(
          trigger: 'derivada',
          title: strings.derivative,
          description: strings.derivativeSymbol,
          icon: PhosphorIcons.mathOperations(),
          markdownTemplate: r'\frac{d}{dx} f(x)',
          category: 'matematica',
          categoryColor: Colors.red,
        ),
        BloquinhoSlashCommand(
          trigger: 'matriz',
          title: strings.matrix,
          description: strings.latexMatrix,
          icon: PhosphorIcons.table(),
          markdownTemplate: r'\begin{pmatrix} a & b \\ c & d \end{pmatrix}',
          category: 'matematica',
          categoryColor: Colors.red,
        ),

        // ===== DIAGRAMAS =====
        BloquinhoSlashCommand(
          trigger: 'mermaid',
          title: strings.mermaidDiagram,
          description: strings.mermaidDiagramDescription,
          icon: PhosphorIcons.flowArrow(),
          markdownTemplate:
              '```mermaid\ngraph TD\n    A[Início] --> B[Processo]\n    B --> C[Fim]\n```',
          isPopular: true,
          category: 'diagramas',
          categoryColor: Colors.teal,
        ),
        BloquinhoSlashCommand(
          trigger: 'fluxograma',
          title: strings.flowchart,
          description: strings.flowchartDescription,
          icon: PhosphorIcons.flowArrow(),
          markdownTemplate:
              '```mermaid\nflowchart TD\n    A[Início] --> B{Decisão?}\n    B -->|Sim| C[Ação]\n    B -->|Não| D[Outra ação]\n```',
          category: 'diagramas',
          categoryColor: Colors.teal,
        ),
        BloquinhoSlashCommand(
          trigger: 'sequencia',
          title: strings.sequenceDiagram,
          description: strings.sequenceDiagramDescription,
          icon: PhosphorIcons.arrowsHorizontal(),
          markdownTemplate:
              '```mermaid\nsequenceDiagram\n    participant A as Usuário\n    participant B as Sistema\n    A->>B: Requisição\n    B->>A: Resposta\n```',
          category: 'diagramas',
          categoryColor: Colors.teal,
        ),
        BloquinhoSlashCommand(
          trigger: 'classe',
          title: strings.classDiagram,
          description: strings.umlClassDiagram,
          icon: PhosphorIcons.squaresFour(),
          markdownTemplate:
              '```mermaid\nclassDiagram\n    class Classe {\n        +atributo\n        +metodo()\n    }\n```',
          category: 'diagramas',
          categoryColor: Colors.teal,
        ),
        BloquinhoSlashCommand(
          trigger: 'er',
          title: strings.erDiagram,
          description: strings.erDiagramDescription,
          icon: PhosphorIcons.database(),
          markdownTemplate:
              '```mermaid\nerDiagram\n    USUARIO ||--o{ POST : cria\n    POST ||--o{ COMENTARIO : tem\n```',
          category: 'diagramas',
          categoryColor: Colors.teal,
        ),
        BloquinhoSlashCommand(
          trigger: 'gantt',
          title: strings.ganttChart,
          description: strings.ganttChartDescription,
          icon: PhosphorIcons.calendar(),
          markdownTemplate:
              '```mermaid\ngantt\n    title Cronograma do Projeto\n    section Fase 1\n    Tarefa 1 :done, t1, 2024-01-01, 7d\n    Tarefa 2 :active, t2, after t1, 5d\n```',
          category: 'diagramas',
          categoryColor: Colors.teal,
        ),

        // ===== TABELAS =====
        BloquinhoSlashCommand(
          trigger: 'tabela',
          title: strings.table,
          description: strings.simpleTable,
          icon: PhosphorIcons.table(),
          markdownTemplate:
              '| Coluna 1 | Coluna 2 | Coluna 3 |\n| --- | --- | --- |\n|  |  |  |',
          isPopular: true,
          category: 'tabelas',
          categoryColor: Colors.amber,
        ),
        BloquinhoSlashCommand(
          trigger: 'tabela2',
          title: strings.table2x2,
          description: strings.table2Columns,
          icon: PhosphorIcons.table(),
          markdownTemplate: '| Coluna 1 | Coluna 2 |\n| --- | --- |\n|  |  |',
          category: 'tabelas',
          categoryColor: Colors.amber,
        ),
        BloquinhoSlashCommand(
          trigger: 'tabela3',
          title: strings.table3x3,
          description: strings.table3Columns,
          icon: PhosphorIcons.table(),
          markdownTemplate:
              '| Coluna 1 | Coluna 2 | Coluna 3 |\n| --- | --- | --- |\n|  |  |  |',
          category: 'tabelas',
          categoryColor: Colors.amber,
        ),
        BloquinhoSlashCommand(
          trigger: 'tabela4',
          title: strings.table4x4,
          description: strings.table4Columns,
          icon: PhosphorIcons.table(),
          markdownTemplate:
              '| Coluna 1 | Coluna 2 | Coluna 3 | Coluna 4 |\n| --- | --- | --- | --- |\n|  |  |  |  |',
          category: 'tabelas',
          categoryColor: Colors.amber,
        ),

        // ===== MÍDIA =====
        BloquinhoSlashCommand(
          trigger: 'imagem',
          title: strings.image,
          description: strings.insertImage,
          icon: PhosphorIcons.image(),
          markdownTemplate: '![Descrição](url_da_imagem)',
          isPopular: true,
          category: 'midia',
          categoryColor: Colors.pink,
        ),
        BloquinhoSlashCommand(
          trigger: 'video',
          title: strings.video,
          description: strings.insertVideo,
          icon: PhosphorIcons.video(),
          markdownTemplate: '![Vídeo](url_do_video)',
          category: 'midia',
          categoryColor: Colors.pink,
        ),
        BloquinhoSlashCommand(
          trigger: 'audio',
          title: strings.audio,
          description: strings.insertAudio,
          icon: PhosphorIcons.speakerHigh(),
          markdownTemplate: '![Áudio](url_do_audio)',
          category: 'midia',
          categoryColor: Colors.pink,
        ),
        BloquinhoSlashCommand(
          trigger: 'arquivo',
          title: strings.file,
          description: strings.linkToFile,
          icon: PhosphorIcons.file(),
          markdownTemplate: '[Nome do arquivo](url_do_arquivo)',
          category: 'midia',
          categoryColor: Colors.pink,
        ),

        // ===== LINKS =====
        BloquinhoSlashCommand(
          trigger: 'link',
          title: strings.link,
          description: strings.externalLink,
          icon: PhosphorIcons.link(),
          markdownTemplate: '[Texto do link](url)',
          isPopular: true,
          category: 'links',
          categoryColor: Colors.cyan,
        ),
        BloquinhoSlashCommand(
          trigger: 'pagina',
          title: strings.pageLink,
          description: strings.linkToAnotherPage,
          icon: PhosphorIcons.fileText(),
          markdownTemplate: '[[Nome da página]]',
          category: 'links',
          categoryColor: Colors.cyan,
        ),
        BloquinhoSlashCommand(
          trigger: 'email',
          title: strings.email,
          description: strings.emailLink,
          icon: PhosphorIcons.envelope(),
          markdownTemplate: '[email@exemplo.com](mailto:email@exemplo.com)',
          category: 'links',
          categoryColor: Colors.cyan,
        ),

        // ===== LAYOUT =====
        BloquinhoSlashCommand(
          trigger: 'divisor',
          title: strings.divider,
          description: strings.dividerLine,
          icon: PhosphorIcons.minus(),
          markdownTemplate: '---',
          category: 'layout',
          categoryColor: Colors.grey,
        ),
        BloquinhoSlashCommand(
          trigger: 'espaco',
          title: strings.space,
          description: strings.verticalSpace,
          icon: PhosphorIcons.arrowsVertical(),
          markdownTemplate: '\n\n',
          category: 'layout',
          categoryColor: Colors.grey,
        ),
        BloquinhoSlashCommand(
          trigger: 'coluna',
          title: strings.columns,
          description: strings.columnLayout,
          icon: PhosphorIcons.columns(),
          markdownTemplate:
              '<div style="display: flex;">\n<div style="flex: 1;">\n\n</div>\n<div style="flex: 1;">\n\n</div>\n</div>',
          category: 'layout',
          categoryColor: Colors.grey,
        ),

        // ===== AVANÇADOS =====
        BloquinhoSlashCommand(
          trigger: 'embed',
          title: strings.embed,
          description: strings.embedContent,
          icon: PhosphorIcons.browser(),
          markdownTemplate:
              '<iframe src="url" width="100%" height="400"></iframe>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'bookmark',
          title: strings.bookmark,
          description: strings.saveLink,
          icon: PhosphorIcons.bookmark(),
          markdownTemplate:
              '> 🔖 **Bookmark**\n> [Título](url)\n> Descrição do link',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'indice',
          title: strings.tableOfContents,
          description: strings.createTableOfContents,
          icon: PhosphorIcons.listChecks(),
          markdownTemplate:
              '## Índice\n\n- [Seção 1](#secao-1)\n- [Seção 2](#secao-2)\n- [Seção 3](#secao-3)',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'nota',
          title: strings.note,
          description: strings.noteBlock,
          icon: PhosphorIcons.note(),
          markdownTemplate: '> 📝 **Nota**\n> ',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'aviso',
          title: strings.warning,
          description: strings.warningBlock,
          icon: PhosphorIcons.warning(),
          markdownTemplate: '> ⚠️ **Aviso**\n> ',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'erro',
          title: strings.error,
          description: strings.errorBlock,
          icon: PhosphorIcons.xCircle(),
          markdownTemplate: '> ❌ **Erro**\n> ',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'sucesso',
          title: strings.success,
          description: strings.successBlock,
          icon: PhosphorIcons.checkCircle(),
          markdownTemplate: '> ✅ **Sucesso**\n> ',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'info',
          title: strings.information,
          description: strings.informationBlock,
          icon: PhosphorIcons.info(),
          markdownTemplate: '> ℹ️ **Informação**\n> ',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'dica',
          title: strings.tip,
          description: strings.tipBlock,
          icon: PhosphorIcons.lightbulb(),
          markdownTemplate: '> 💡 **Dica**\n> ',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'spoiler',
          title: strings.spoiler,
          description: strings.hiddenContent,
          icon: PhosphorIcons.eyeSlash(),
          markdownTemplate:
              '<details>\n<summary>Clique para revelar</summary>\n\nConteúdo oculto aqui\n\n</details>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'collapsible',
          title: strings.collapsible,
          description: strings.collapsibleSection,
          icon: PhosphorIcons.caretDown(),
          markdownTemplate:
              '<details>\n<summary>Título da seção</summary>\n\nConteúdo da seção\n\n</details>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'badge',
          title: strings.badge,
          description: strings.insertColoredBadge,
          icon: PhosphorIcons.tag(),
          markdownTemplate:
              '<span style="background: #FFD700; color: #222; border-radius: 6px; padding: 2px 8px; font-size: 0.9em;">Badge</span>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'mark',
          title: strings.highlightedText,
          description: strings.highlightTextWithColor,
          icon: PhosphorIcons.highlighterCircle(),
          markdownTemplate: '<mark>Texto destacado</mark>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'kbd',
          title: strings.keyboardKey,
          description: strings.representShortcutKey,
          icon: PhosphorIcons.keyboard(),
          markdownTemplate: '<kbd>Ctrl+C</kbd>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'sub',
          title: strings.subscript,
          description: strings.subscriptText,
          icon: PhosphorIcons.arrowDownLeft(),
          markdownTemplate: 'Texto<sub>sub</sub>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'sup',
          title: strings.superscript,
          description: strings.superscriptText,
          icon: PhosphorIcons.arrowUpRight(),
          markdownTemplate: 'Texto<sup>sup</sup>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'progresso',
          title: strings.progressBar,
          description: strings.insertProgressBar,
          icon: PhosphorIcons.slidersHorizontal(),
          markdownTemplate: '<progress value="50" max="100">50%</progress>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'detalhes',
          title: strings.details,
          description: strings.expandableDetailsBlock,
          icon: PhosphorIcons.caretDown(),
          markdownTemplate:
              '<details>\n<summary>Resumo</summary>\n\nConteúdo detalhado aqui\n\n</details>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),

        // ===== IA =====
        BloquinhoSlashCommand(
          trigger: 'ia',
          title: strings.noteViaAI,
          description: strings.generateContentWithAI,
          icon: PhosphorIcons.robot(),
          markdownTemplate: '🤖 **Nota Gerada por IA**\n\n',
          isPopular: true,
          category: 'ia',
          categoryColor: Colors.purple,
        ),
      ];

  /// Filtrar comandos por categoria
  static List<BloquinhoSlashCommand> getByCategory(
      String category, AppStrings strings) {
    return allCommands(strings)
        .where((cmd) => cmd.category == category)
        .toList();
  }

  /// Obter comandos populares
  static List<BloquinhoSlashCommand> popularCommands(AppStrings strings) {
    return allCommands(strings).where((cmd) => cmd.isPopular).toList();
  }

  /// Buscar comandos por texto
  static List<BloquinhoSlashCommand> search(String query, AppStrings strings) {
    if (query.isEmpty) return popularCommands(strings);

    final lowerQuery = query.toLowerCase();
    return allCommands(strings).where((cmd) {
      return cmd.trigger.toLowerCase().contains(lowerQuery) ||
          cmd.title.toLowerCase().contains(lowerQuery) ||
          cmd.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Obter comando por trigger
  static BloquinhoSlashCommand? getByTrigger(
      String trigger, AppStrings strings) {
    try {
      return allCommands(strings).firstWhere((cmd) => cmd.trigger == trigger);
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
      case 'titulos':
        return strings.titles;
      case 'listas':
        return strings.lists;
      case 'texto':
        return strings.text;
      case 'citacoes':
        return strings.quotes;
      case 'codigo':
        return strings.code;
      case 'matematica':
        return strings.math;
      case 'diagramas':
        return strings.diagrams;
      case 'tabelas':
        return strings.tables;
      case 'midia':
        return strings.media;
      case 'links':
        return strings.links;
      case 'layout':
        return strings.layout;
      case 'avancado':
        return strings.advanced;
      case 'ia':
        return strings.artificialIntelligence;
      default:
        return strings.others;
    }
  }

  /// Ícone da categoria
  IconData get categoryIcon {
    switch (category) {
      case 'titulos':
        return PhosphorIcons.textH();
      case 'listas':
        return PhosphorIcons.listBullets();
      case 'texto':
        return PhosphorIcons.textT();
      case 'citacoes':
        return PhosphorIcons.quotes();
      case 'codigo':
        return PhosphorIcons.code();
      case 'matematica':
        return PhosphorIcons.mathOperations();
      case 'diagramas':
        return PhosphorIcons.flowArrow();
      case 'tabelas':
        return PhosphorIcons.table();
      case 'midia':
        return PhosphorIcons.image();
      case 'links':
        return PhosphorIcons.link();
      case 'layout':
        return PhosphorIcons.layout();
      case 'avancado':
        return PhosphorIcons.gear();
      case 'ia':
        return PhosphorIcons.robot();
      default:
        return PhosphorIcons.circle();
    }
  }

  /// Cor da categoria
  Color get categoryColorValue {
    return categoryColor ?? Colors.grey;
  }

  /// Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'trigger': trigger,
      'title': title,
      'description': description,
      'icon': icon.codePoint,
      'markdownTemplate': markdownTemplate,
      'isPopular': isPopular,
      'category': category,
      'categoryColor': categoryColor?.value,
    };
  }

  /// Criar a partir de JSON
  factory BloquinhoSlashCommand.fromJson(Map<String, dynamic> json) {
    return BloquinhoSlashCommand(
      trigger: json['trigger'],
      title: json['title'],
      description: json['description'],
      icon: IconData(json['icon'], fontFamily: 'PhosphorIcons'),
      markdownTemplate: json['markdownTemplate'],
      isPopular: json['isPopular'] ?? false,
      category: json['category'],
      categoryColor:
          json['categoryColor'] != null ? Color(json['categoryColor']) : null,
    );
  }

  /// Copiar com modificações
  BloquinhoSlashCommand copyWith({
    String? trigger,
    String? title,
    String? description,
    IconData? icon,
    String? markdownTemplate,
    bool? isPopular,
    String? category,
    Color? categoryColor,
  }) {
    return BloquinhoSlashCommand(
      trigger: trigger ?? this.trigger,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      markdownTemplate: markdownTemplate ?? this.markdownTemplate,
      isPopular: isPopular ?? this.isPopular,
      category: category ?? this.category,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BloquinhoSlashCommand && other.trigger == trigger;
  }

  @override
  int get hashCode => trigger.hashCode;

  @override
  String toString() {
    return 'BloquinhoSlashCommand(trigger: $trigger, title: $title, category: $category)';
  }
}
