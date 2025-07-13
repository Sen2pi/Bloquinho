import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
  static List<BloquinhoSlashCommand> get allCommands => [
        // ===== TÍTULOS =====
        BloquinhoSlashCommand(
          trigger: 'h1',
          title: 'Título 1',
          description: 'Cabeçalho grande',
          icon: PhosphorIcons.textHOne(),
          markdownTemplate: '# ',
          isPopular: true,
          category: 'titulos',
          categoryColor: Colors.purple,
        ),
        BloquinhoSlashCommand(
          trigger: 'h2',
          title: 'Título 2',
          description: 'Cabeçalho médio',
          icon: PhosphorIcons.textHTwo(),
          markdownTemplate: '## ',
          category: 'titulos',
          categoryColor: Colors.purple,
        ),
        BloquinhoSlashCommand(
          trigger: 'h3',
          title: 'Título 3',
          description: 'Cabeçalho pequeno',
          icon: PhosphorIcons.textHThree(),
          markdownTemplate: '### ',
          category: 'titulos',
          categoryColor: Colors.purple,
        ),
        BloquinhoSlashCommand(
          trigger: 'h4',
          title: 'Título 4',
          description: 'Cabeçalho muito pequeno',
          icon: PhosphorIcons.textHFour(),
          markdownTemplate: '#### ',
          category: 'titulos',
          categoryColor: Colors.purple,
        ),

        // ===== LISTAS =====
        BloquinhoSlashCommand(
          trigger: 'lista',
          title: 'Lista',
          description: 'Lista com marcadores',
          icon: PhosphorIcons.listBullets(),
          markdownTemplate: '- ',
          isPopular: true,
          category: 'listas',
          categoryColor: Colors.green,
        ),
        BloquinhoSlashCommand(
          trigger: 'numerada',
          title: 'Lista numerada',
          description: 'Lista com números',
          icon: PhosphorIcons.listNumbers(),
          markdownTemplate: '1. ',
          category: 'listas',
          categoryColor: Colors.green,
        ),
        BloquinhoSlashCommand(
          trigger: 'todo',
          title: 'Checklist',
          description: 'Lista de tarefas',
          icon: PhosphorIcons.checkSquare(),
          markdownTemplate: '- [ ] ',
          isPopular: true,
          category: 'listas',
          categoryColor: Colors.green,
        ),
        BloquinhoSlashCommand(
          trigger: 'feito',
          title: 'Item feito',
          description: 'Item de checklist marcado',
          icon: PhosphorIcons.checkSquare(),
          markdownTemplate: '- [x] ',
          category: 'listas',
          categoryColor: Colors.green,
        ),

        // ===== TEXTO =====
        BloquinhoSlashCommand(
          trigger: 'texto',
          title: 'Texto',
          description: 'Parágrafo simples',
          icon: PhosphorIcons.textT(),
          markdownTemplate: '',
          isPopular: true,
          category: 'texto',
          categoryColor: Colors.blue,
        ),
        BloquinhoSlashCommand(
          trigger: 'negrito',
          title: 'Negrito',
          description: 'Texto em negrito',
          icon: PhosphorIcons.textB(),
          markdownTemplate: '**texto**',
          category: 'texto',
          categoryColor: Colors.blue,
        ),
        BloquinhoSlashCommand(
          trigger: 'italico',
          title: 'Itálico',
          description: 'Texto em itálico',
          icon: PhosphorIcons.textItalic(),
          markdownTemplate: '*texto*',
          category: 'texto',
          categoryColor: Colors.blue,
        ),
        BloquinhoSlashCommand(
          trigger: 'riscado',
          title: 'Riscado',
          description: 'Texto riscado',
          icon: PhosphorIcons.textStrikethrough(),
          markdownTemplate: '~~texto~~',
          category: 'texto',
          categoryColor: Colors.blue,
        ),
        BloquinhoSlashCommand(
          trigger: 'codigo',
          title: 'Código inline',
          description: 'Código na linha',
          icon: PhosphorIcons.code(),
          markdownTemplate: '`código`',
          category: 'texto',
          categoryColor: Colors.blue,
        ),

        // ===== CITAÇÕES =====
        BloquinhoSlashCommand(
          trigger: 'citacao',
          title: 'Citação',
          description: 'Bloco de citação',
          icon: PhosphorIcons.quotes(),
          markdownTemplate: '> ',
          category: 'citacoes',
          categoryColor: Colors.orange,
        ),
        BloquinhoSlashCommand(
          trigger: 'callout',
          title: 'Callout',
          description: 'Bloco destacado',
          icon: PhosphorIcons.lightbulb(),
          markdownTemplate: '> 💡 **Callout**\n> ',
          category: 'citacoes',
          categoryColor: Colors.orange,
        ),

        // ===== CÓDIGO =====
        BloquinhoSlashCommand(
          trigger: 'bloco',
          title: 'Bloco de código',
          description: 'Código com syntax highlighting',
          icon: PhosphorIcons.codeBlock(),
          markdownTemplate: '```\n\n```',
          isPopular: true,
          category: 'codigo',
          categoryColor: Colors.indigo,
        ),
        BloquinhoSlashCommand(
          trigger: 'javascript',
          title: 'JavaScript',
          description: 'Código JavaScript',
          icon: PhosphorIcons.fileJs(),
          markdownTemplate: '```javascript\n\n```',
          category: 'codigo',
          categoryColor: Colors.indigo,
        ),
        BloquinhoSlashCommand(
          trigger: 'python',
          title: 'Python',
          description: 'Código Python',
          icon: PhosphorIcons.filePy(),
          markdownTemplate: '```python\n\n```',
          category: 'codigo',
          categoryColor: Colors.indigo,
        ),
        BloquinhoSlashCommand(
          trigger: 'dart',
          title: 'Dart',
          description: 'Código Dart',
          icon: PhosphorIcons.fileCode(),
          markdownTemplate: '```dart\n\n```',
          category: 'codigo',
          categoryColor: Colors.indigo,
        ),
        BloquinhoSlashCommand(
          trigger: 'html',
          title: 'HTML',
          description: 'Código HTML',
          icon: PhosphorIcons.fileHtml(),
          markdownTemplate: '```html\n\n```',
          category: 'codigo',
          categoryColor: Colors.indigo,
        ),
        BloquinhoSlashCommand(
          trigger: 'css',
          title: 'CSS',
          description: 'Código CSS',
          icon: PhosphorIcons.fileCss(),
          markdownTemplate: '```css\n\n```',
          category: 'codigo',
          categoryColor: Colors.indigo,
        ),
        BloquinhoSlashCommand(
          trigger: 'json',
          title: 'JSON',
          description: 'Código JSON',
          icon: PhosphorIcons.fileCode(),
          markdownTemplate: '```json\n\n```',
          category: 'codigo',
          categoryColor: Colors.indigo,
        ),

        // ===== MATEMÁTICA =====
        BloquinhoSlashCommand(
          trigger: 'latex',
          title: 'LaTeX',
          description: 'Equação LaTeX',
          icon: PhosphorIcons.mathOperations(),
          markdownTemplate: r'$$\frac{a}{b}$$',
          isPopular: true,
          category: 'matematica',
          categoryColor: Colors.red,
        ),
        BloquinhoSlashCommand(
          trigger: 'equacao',
          title: 'Equação inline',
          description: 'Equação na linha',
          icon: PhosphorIcons.mathOperations(),
          markdownTemplate: r'$x = y$',
          category: 'matematica',
          categoryColor: Colors.red,
        ),
        BloquinhoSlashCommand(
          trigger: 'integral',
          title: 'Integral',
          description: 'Símbolo de integral',
          icon: PhosphorIcons.mathOperations(),
          markdownTemplate: r'$$\int_{a}^{b} f(x) dx$$',
          category: 'matematica',
          categoryColor: Colors.red,
        ),
        BloquinhoSlashCommand(
          trigger: 'soma',
          title: 'Somatório',
          description: 'Símbolo de somatório',
          icon: PhosphorIcons.mathOperations(),
          markdownTemplate: r'$$\sum_{i=1}^{n} x_i$$',
          category: 'matematica',
          categoryColor: Colors.red,
        ),
        BloquinhoSlashCommand(
          trigger: 'produto',
          title: 'Produtório',
          description: 'Símbolo de produtório',
          icon: PhosphorIcons.mathOperations(),
          markdownTemplate: r'$$\prod_{i=1}^{n} x_i$$',
          category: 'matematica',
          categoryColor: Colors.red,
        ),
        BloquinhoSlashCommand(
          trigger: 'limite',
          title: 'Limite',
          description: 'Símbolo de limite',
          icon: PhosphorIcons.mathOperations(),
          markdownTemplate: r'$$\lim_{x \to \infty} f(x)$$',
          category: 'matematica',
          categoryColor: Colors.red,
        ),
        BloquinhoSlashCommand(
          trigger: 'derivada',
          title: 'Derivada',
          description: 'Símbolo de derivada',
          icon: PhosphorIcons.mathOperations(),
          markdownTemplate: r'$$\frac{d}{dx} f(x)$$',
          category: 'matematica',
          categoryColor: Colors.red,
        ),
        BloquinhoSlashCommand(
          trigger: 'matriz',
          title: 'Matriz',
          description: 'Matriz LaTeX',
          icon: PhosphorIcons.table(),
          markdownTemplate: r'$$\begin{pmatrix} a & b \\ c & d \end{pmatrix}$$',
          category: 'matematica',
          categoryColor: Colors.red,
        ),

        // ===== DIAGRAMAS =====
        BloquinhoSlashCommand(
          trigger: 'mermaid',
          title: 'Diagrama Mermaid',
          description: 'Diagrama com Mermaid',
          icon: PhosphorIcons.flowArrow(),
          markdownTemplate:
              '```mermaid\ngraph TD\n    A[Início] --> B[Processo]\n    B --> C[Fim]\n```',
          isPopular: true,
          category: 'diagramas',
          categoryColor: Colors.teal,
        ),
        BloquinhoSlashCommand(
          trigger: 'fluxograma',
          title: 'Fluxograma',
          description: 'Diagrama de fluxo',
          icon: PhosphorIcons.flowArrow(),
          markdownTemplate:
              '```mermaid\nflowchart TD\n    A[Início] --> B{Decisão?}\n    B -->|Sim| C[Ação]\n    B -->|Não| D[Outra ação]\n```',
          category: 'diagramas',
          categoryColor: Colors.teal,
        ),
        BloquinhoSlashCommand(
          trigger: 'sequencia',
          title: 'Diagrama de Sequência',
          description: 'Diagrama de sequência',
          icon: PhosphorIcons.arrowsHorizontal(),
          markdownTemplate:
              '```mermaid\nsequenceDiagram\n    participant A as Usuário\n    participant B as Sistema\n    A->>B: Requisição\n    B->>A: Resposta\n```',
          category: 'diagramas',
          categoryColor: Colors.teal,
        ),
        BloquinhoSlashCommand(
          trigger: 'classe',
          title: 'Diagrama de Classe',
          description: 'Diagrama de classe UML',
          icon: PhosphorIcons.squaresFour(),
          markdownTemplate:
              '```mermaid\nclassDiagram\n    class Classe {\n        +atributo\n        +metodo()\n    }\n```',
          category: 'diagramas',
          categoryColor: Colors.teal,
        ),
        BloquinhoSlashCommand(
          trigger: 'er',
          title: 'Diagrama ER',
          description: 'Diagrama entidade-relacionamento',
          icon: PhosphorIcons.database(),
          markdownTemplate:
              '```mermaid\nerDiagram\n    USUARIO ||--o{ POST : cria\n    POST ||--o{ COMENTARIO : tem\n```',
          category: 'diagramas',
          categoryColor: Colors.teal,
        ),
        BloquinhoSlashCommand(
          trigger: 'gantt',
          title: 'Gráfico de Gantt',
          description: 'Gráfico de Gantt',
          icon: PhosphorIcons.calendar(),
          markdownTemplate:
              '```mermaid\ngantt\n    title Cronograma do Projeto\n    section Fase 1\n    Tarefa 1 :done, t1, 2024-01-01, 7d\n    Tarefa 2 :active, t2, after t1, 5d\n```',
          category: 'diagramas',
          categoryColor: Colors.teal,
        ),

        // ===== TABELAS =====
        BloquinhoSlashCommand(
          trigger: 'tabela',
          title: 'Tabela',
          description: 'Tabela simples',
          icon: PhosphorIcons.table(),
          markdownTemplate:
              '| Coluna 1 | Coluna 2 | Coluna 3 |\n| --- | --- | --- |\n|  |  |  |',
          isPopular: true,
          category: 'tabelas',
          categoryColor: Colors.amber,
        ),
        BloquinhoSlashCommand(
          trigger: 'tabela2',
          title: 'Tabela 2x2',
          description: 'Tabela 2 colunas',
          icon: PhosphorIcons.table(),
          markdownTemplate: '| Coluna 1 | Coluna 2 |\n| --- | --- |\n|  |  |',
          category: 'tabelas',
          categoryColor: Colors.amber,
        ),
        BloquinhoSlashCommand(
          trigger: 'tabela3',
          title: 'Tabela 3x3',
          description: 'Tabela 3 colunas',
          icon: PhosphorIcons.table(),
          markdownTemplate:
              '| Coluna 1 | Coluna 2 | Coluna 3 |\n| --- | --- | --- |\n|  |  |  |',
          category: 'tabelas',
          categoryColor: Colors.amber,
        ),
        BloquinhoSlashCommand(
          trigger: 'tabela4',
          title: 'Tabela 4x4',
          description: 'Tabela 4 colunas',
          icon: PhosphorIcons.table(),
          markdownTemplate:
              '| Coluna 1 | Coluna 2 | Coluna 3 | Coluna 4 |\n| --- | --- | --- | --- |\n|  |  |  |  |',
          category: 'tabelas',
          categoryColor: Colors.amber,
        ),

        // ===== MÍDIA =====
        BloquinhoSlashCommand(
          trigger: 'imagem',
          title: 'Imagem',
          description: 'Inserir imagem',
          icon: PhosphorIcons.image(),
          markdownTemplate: '![Descrição](url_da_imagem)',
          isPopular: true,
          category: 'midia',
          categoryColor: Colors.pink,
        ),
        BloquinhoSlashCommand(
          trigger: 'video',
          title: 'Vídeo',
          description: 'Inserir vídeo',
          icon: PhosphorIcons.video(),
          markdownTemplate: '![Vídeo](url_do_video)',
          category: 'midia',
          categoryColor: Colors.pink,
        ),
        BloquinhoSlashCommand(
          trigger: 'audio',
          title: 'Áudio',
          description: 'Inserir áudio',
          icon: PhosphorIcons.speakerHigh(),
          markdownTemplate: '![Áudio](url_do_audio)',
          category: 'midia',
          categoryColor: Colors.pink,
        ),
        BloquinhoSlashCommand(
          trigger: 'arquivo',
          title: 'Arquivo',
          description: 'Link para arquivo',
          icon: PhosphorIcons.file(),
          markdownTemplate: '[Nome do arquivo](url_do_arquivo)',
          category: 'midia',
          categoryColor: Colors.pink,
        ),

        // ===== LINKS =====
        BloquinhoSlashCommand(
          trigger: 'link',
          title: 'Link',
          description: 'Link externo',
          icon: PhosphorIcons.link(),
          markdownTemplate: '[Texto do link](url)',
          isPopular: true,
          category: 'links',
          categoryColor: Colors.cyan,
        ),
        BloquinhoSlashCommand(
          trigger: 'pagina',
          title: 'Link de página',
          description: 'Link para outra página',
          icon: PhosphorIcons.fileText(),
          markdownTemplate: '[[Nome da página]]',
          category: 'links',
          categoryColor: Colors.cyan,
        ),
        BloquinhoSlashCommand(
          trigger: 'email',
          title: 'Email',
          description: 'Link de email',
          icon: PhosphorIcons.envelope(),
          markdownTemplate: '[email@exemplo.com](mailto:email@exemplo.com)',
          category: 'links',
          categoryColor: Colors.cyan,
        ),

        // ===== LAYOUT =====
        BloquinhoSlashCommand(
          trigger: 'divisor',
          title: 'Divisor',
          description: 'Linha divisória',
          icon: PhosphorIcons.minus(),
          markdownTemplate: '---',
          category: 'layout',
          categoryColor: Colors.grey,
        ),
        BloquinhoSlashCommand(
          trigger: 'espaco',
          title: 'Espaço',
          description: 'Espaço vertical',
          icon: PhosphorIcons.arrowsVertical(),
          markdownTemplate: '\n\n',
          category: 'layout',
          categoryColor: Colors.grey,
        ),
        BloquinhoSlashCommand(
          trigger: 'coluna',
          title: 'Colunas',
          description: 'Layout em colunas',
          icon: PhosphorIcons.columns(),
          markdownTemplate:
              '<div style="display: flex;">\n<div style="flex: 1;">\n\n</div>\n<div style="flex: 1;">\n\n</div>\n</div>',
          category: 'layout',
          categoryColor: Colors.grey,
        ),

        // ===== AVANÇADOS =====
        BloquinhoSlashCommand(
          trigger: 'embed',
          title: 'Embed',
          description: 'Incorporar conteúdo',
          icon: PhosphorIcons.browser(),
          markdownTemplate:
              '<iframe src="url" width="100%" height="400"></iframe>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'bookmark',
          title: 'Bookmark',
          description: 'Salvar link',
          icon: PhosphorIcons.bookmark(),
          markdownTemplate:
              '> 🔖 **Bookmark**\n> [Título](url)\n> Descrição do link',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'indice',
          title: 'Índice',
          description: 'Criar índice',
          icon: PhosphorIcons.listChecks(),
          markdownTemplate:
              '## Índice\n\n- [Seção 1](#secao-1)\n- [Seção 2](#secao-2)\n- [Seção 3](#secao-3)',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'nota',
          title: 'Nota',
          description: 'Bloco de nota',
          icon: PhosphorIcons.note(),
          markdownTemplate: '> 📝 **Nota**\n> ',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'aviso',
          title: 'Aviso',
          description: 'Bloco de aviso',
          icon: PhosphorIcons.warning(),
          markdownTemplate: '> ⚠️ **Aviso**\n> ',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'erro',
          title: 'Erro',
          description: 'Bloco de erro',
          icon: PhosphorIcons.xCircle(),
          markdownTemplate: '> ❌ **Erro**\n> ',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'sucesso',
          title: 'Sucesso',
          description: 'Bloco de sucesso',
          icon: PhosphorIcons.checkCircle(),
          markdownTemplate: '> ✅ **Sucesso**\n> ',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'info',
          title: 'Informação',
          description: 'Bloco de informação',
          icon: PhosphorIcons.info(),
          markdownTemplate: '> ℹ️ **Informação**\n> ',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'dica',
          title: 'Dica',
          description: 'Bloco de dica',
          icon: PhosphorIcons.lightbulb(),
          markdownTemplate: '> 💡 **Dica**\n> ',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'spoiler',
          title: 'Spoiler',
          description: 'Conteúdo oculto',
          icon: PhosphorIcons.eyeSlash(),
          markdownTemplate:
              '<details>\n<summary>Clique para revelar</summary>\n\nConteúdo oculto aqui\n\n</details>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'collapsible',
          title: 'Colapsível',
          description: 'Seção colapsível',
          icon: PhosphorIcons.caretDown(),
          markdownTemplate:
              '<details>\n<summary>Título da seção</summary>\n\nConteúdo da seção\n\n</details>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'badge',
          title: 'Badge',
          description: 'Insere um badge colorido',
          icon: PhosphorIcons.tag(),
          markdownTemplate:
              '<span style="background: #FFD700; color: #222; border-radius: 6px; padding: 2px 8px; font-size: 0.9em;">Badge</span>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'mark',
          title: 'Texto destacado',
          description: 'Destaca texto com cor',
          icon: PhosphorIcons.highlighterCircle(),
          markdownTemplate: '<mark>Texto destacado</mark>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'kbd',
          title: 'Tecla (kbd)',
          description: 'Representa uma tecla de atalho',
          icon: PhosphorIcons.keyboard(),
          markdownTemplate: '<kbd>Ctrl+C</kbd>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'sub',
          title: 'Subscrito',
          description: 'Texto subscrito',
          icon: PhosphorIcons.arrowDownLeft(),
          markdownTemplate: 'Texto<sub>sub</sub>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'sup',
          title: 'Sobrescrito',
          description: 'Texto sobrescrito',
          icon: PhosphorIcons.arrowUpRight(),
          markdownTemplate: 'Texto<sup>sup</sup>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'progresso',
          title: 'Barra de progresso',
          description: 'Insere uma barra de progresso',
          icon: PhosphorIcons.slidersHorizontal(),
          markdownTemplate: '<progress value="50" max="100">50%</progress>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),
        BloquinhoSlashCommand(
          trigger: 'detalhes',
          title: 'Detalhes',
          description: 'Bloco de detalhes expansível',
          icon: PhosphorIcons.caretDown(),
          markdownTemplate:
              '<details>\n<summary>Resumo</summary>\n\nConteúdo detalhado aqui\n\n</details>',
          category: 'avancado',
          categoryColor: Colors.deepPurple,
        ),

        // ===== IA =====
        BloquinhoSlashCommand(
          trigger: 'ia',
          title: 'Nota via IA',
          description: 'Gerar conteúdo com inteligência artificial',
          icon: PhosphorIcons.robot(),
          markdownTemplate: '🤖 **Nota Gerada por IA**\n\n',
          isPopular: true,
          category: 'ia',
          categoryColor: Colors.purple,
        ),
      ];

  /// Filtrar comandos por categoria
  static List<BloquinhoSlashCommand> getByCategory(String category) {
    return allCommands.where((cmd) => cmd.category == category).toList();
  }

  /// Obter comandos populares
  static List<BloquinhoSlashCommand> get popularCommands {
    return allCommands.where((cmd) => cmd.isPopular).toList();
  }

  /// Buscar comandos por texto
  static List<BloquinhoSlashCommand> search(String query) {
    if (query.isEmpty) return popularCommands;

    final lowerQuery = query.toLowerCase();
    return allCommands.where((cmd) {
      return cmd.trigger.toLowerCase().contains(lowerQuery) ||
          cmd.title.toLowerCase().contains(lowerQuery) ||
          cmd.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Obter comando por trigger
  static BloquinhoSlashCommand? getByTrigger(String trigger) {
    try {
      return allCommands.firstWhere((cmd) => cmd.trigger == trigger);
    } catch (e) {
      return null;
    }
  }

  /// Categorias disponíveis
  static List<String> get categories {
    return allCommands
        .map((cmd) => cmd.category)
        .where((cat) => cat != null)
        .cast<String>()
        .toSet()
        .toList();
  }

  /// Nome da categoria
  String get categoryName {
    switch (category) {
      case 'titulos':
        return 'Títulos';
      case 'listas':
        return 'Listas';
      case 'texto':
        return 'Texto';
      case 'citacoes':
        return 'Citações';
      case 'codigo':
        return 'Código';
      case 'matematica':
        return 'Matemática';
      case 'diagramas':
        return 'Diagramas';
      case 'tabelas':
        return 'Tabelas';
      case 'midia':
        return 'Mídia';
      case 'links':
        return 'Links';
      case 'layout':
        return 'Layout';
      case 'avancado':
        return 'Avançado';
      case 'ia':
        return 'Inteligência Artificial';
      default:
        return 'Outros';
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
