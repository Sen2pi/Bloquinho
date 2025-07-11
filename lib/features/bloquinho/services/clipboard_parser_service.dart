import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/bloco_base_model.dart';
import '../models/bloco_tipo_enum.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/painting.dart';

/// Serviço para análise e conversão inteligente de conteúdo do clipboard
class ClipboardParserService {
  static const _uuid = Uuid();

  /// Obter e analisar conteúdo do clipboard
  Future<ClipboardParseResult> parseClipboard() async {
    try {
      final data = await Clipboard.getData('text/plain');
      if (data == null || data.text == null || data.text!.trim().isEmpty) {
        return ClipboardParseResult.empty();
      }

      final content = data.text!.trim();
      return _analyzeAndConvert(content);
    } catch (e) {
      debugPrint('❌ Erro ao acessar clipboard: $e');
      return ClipboardParseResult.error('Erro ao acessar clipboard: $e');
    }
  }

  /// Analisar tipo de conteúdo e converter para blocos
  ClipboardParseResult _analyzeAndConvert(String content) {
    try {
      // Detectar tipo de conteúdo
      final contentType = _detectContentType(content);

      List<BlocoBase> blocos;

      switch (contentType) {
        case ContentType.markdown:
          blocos = _parseMarkdown(content);
          break;
        case ContentType.url:
          blocos = _parseUrl(content);
          break;
        case ContentType.codeBlock:
          blocos = _parseCodeBlock(content);
          break;
        case ContentType.mathEquation:
          blocos = _parseMathEquation(content);
          break;
        case ContentType.table:
          blocos = _parseTable(content);
          break;
        case ContentType.list:
          blocos = _parseList(content);
          break;
        case ContentType.taskList:
          blocos = _parseTaskList(content);
          break;
        case ContentType.numberedList:
          blocos = _parseNumberedList(content);
          break;
        case ContentType.jsonData:
          blocos = _parseJsonData(content);
          break;
        case ContentType.csvData:
          blocos = _parseCsvData(content);
          break;
        case ContentType.aiPrompt:
          blocos = _parseAiPrompt(content);
          break;
        case ContentType.plainText:
        default:
          blocos = _parsePlainText(content);
          break;
      }

      return ClipboardParseResult.success(
        blocos: blocos,
        originalContent: content,
        detectedType: contentType,
      );
    } catch (e) {
      debugPrint('❌ Erro ao analisar conteúdo: $e');
      return ClipboardParseResult.error('Erro ao processar conteúdo: $e');
    }
  }

  /// Detectar tipo de conteúdo
  ContentType _detectContentType(String content) {
    // URL
    if (_isUrl(content)) {
      return ContentType.url;
    }

    // Prompt de IA (detectar padrões comuns)
    if (_isAiPrompt(content)) {
      return ContentType.aiPrompt;
    }

    // Equação matemática (LaTeX)
    if (_isMathEquation(content)) {
      return ContentType.mathEquation;
    }

    // Bloco de código (com linguagem especificada)
    if (_isCodeBlock(content)) {
      return ContentType.codeBlock;
    }

    // JSON
    if (_isJsonData(content)) {
      return ContentType.jsonData;
    }

    // CSV
    if (_isCsvData(content)) {
      return ContentType.csvData;
    }

    // Tabela markdown
    if (_isTable(content)) {
      return ContentType.table;
    }

    // Lista de tarefas
    if (_isTaskList(content)) {
      return ContentType.taskList;
    }

    // Lista numerada
    if (_isNumberedList(content)) {
      return ContentType.numberedList;
    }

    // Lista com marcadores
    if (_isList(content)) {
      return ContentType.list;
    }

    // Markdown (títulos, formatação, etc.)
    if (_isMarkdown(content)) {
      return ContentType.markdown;
    }

    // Texto simples
    return ContentType.plainText;
  }

  /// Verificar se é URL
  bool _isUrl(String content) {
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
      caseSensitive: false,
    );
    return urlRegex.hasMatch(content.trim());
  }

  /// Verificar se é prompt de IA
  bool _isAiPrompt(String content) {
    final aiPatterns = [
      RegExp(r'^(você|tu|gere|crie|escreva|analise|explique|traduza)',
          caseSensitive: false),
      RegExp(r'^(generate|create|write|analyze|explain|translate)',
          caseSensitive: false),
      RegExp(r'^(act as|roleplay|pretend)', caseSensitive: false),
      RegExp(r'^(ajude|help me)', caseSensitive: false),
      RegExp(r'(prompt|chatgpt|gpt|ai assistant)', caseSensitive: false),
    ];

    return aiPatterns.any((pattern) => pattern.hasMatch(content)) &&
        content.length > 20 && // Prompts tendem a ser mais longos
        content.contains(' '); // Deve ter pelo menos uma palavra
  }

  /// Verificar se é equação matemática
  bool _isMathEquation(String content) {
    // LaTeX equations
    final latexRegex =
        RegExp(r'(\$\$.*\$\$|\$.*\$|\\begin\{.*\}.*\\end\{.*\})');
    return latexRegex.hasMatch(content);
  }

  /// Verificar se é bloco de código
  bool _isCodeBlock(String content) {
    // Código com três backticks
    final codeBlockRegex = RegExp(r'^```(.*)\n[\s\S]*\n```$', multiLine: true);
    return codeBlockRegex.hasMatch(content.trim());
  }

  /// Verificar se é JSON
  bool _isJsonData(String content) {
    try {
      final trimmed = content.trim();
      if (!((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']')))) {
        return false;
      }

      // Tentativa básica de validação JSON
      final lines = trimmed.split('\n');
      return lines.length > 2 &&
          (trimmed.contains('"') || trimmed.contains("'")) &&
          (trimmed.contains(':') || trimmed.contains(','));
    } catch (e) {
      return false;
    }
  }

  /// Verificar se é CSV
  bool _isCsvData(String content) {
    final lines =
        content.split('\n').where((line) => line.trim().isNotEmpty).toList();
    if (lines.length < 2) return false;

    final firstLineCommas = lines[0].split(',').length;
    if (firstLineCommas < 2) return false;

    // Verificar se outras linhas têm número similar de vírgulas
    return lines
        .skip(1)
        .take(3)
        .every((line) => (line.split(',').length - firstLineCommas).abs() <= 1);
  }

  /// Verificar se é tabela markdown
  bool _isTable(String content) {
    final lines = content.split('\n');
    return lines.any((line) => line.contains('|')) &&
        lines.any((line) => line.contains('---'));
  }

  /// Verificar se é lista de tarefas
  bool _isTaskList(String content) {
    final taskRegex = RegExp(r'^\s*[-\*\+]\s*\[[\sx]\]');
    return taskRegex.hasMatch(content);
  }

  /// Verificar se é lista numerada
  bool _isNumberedList(String content) {
    final numberedRegex = RegExp(r'^\s*\d+\.\s+');
    return numberedRegex.hasMatch(content);
  }

  /// Verificar se é lista com marcadores
  bool _isList(String content) {
    final listRegex = RegExp(r'^\s*[-\*\+]\s+');
    return listRegex.hasMatch(content);
  }

  /// Verificar se é markdown
  bool _isMarkdown(String content) {
    final markdownPatterns = [
      RegExp(r'^#{1,6}\s+'), // Títulos
      RegExp(r'\*\*.*\*\*'), // Negrito
      RegExp(r'\*.*\*'), // Itálico
      RegExp(r'`.*`'), // Código inline
      RegExp(r'^\s*[-\*\+]\s+', multiLine: true), // Listas
      RegExp(r'^\s*\d+\.\s+', multiLine: true), // Listas numeradas
      RegExp(r'\[.*\]\(.*\)'), // Links
    ];

    return markdownPatterns.any((pattern) => pattern.hasMatch(content));
  }

  /// Converter markdown
  List<BlocoBase> _parseMarkdown(String content) {
    // Por enquanto, tratar como texto simples
    // TODO: Implementar parser de markdown completo
    return [_createTextBlock(content)];
  }

  /// Converter URL
  List<BlocoBase> _parseUrl(String content) {
    return [
      BlocoLink(
        id: _uuid.v4(),
        url: content.trim(),
        titulo: 'Link',
      )
    ];
  }

  /// Converter bloco de código
  List<BlocoBase> _parseCodeBlock(String content) {
    final codeBlockRegex =
        RegExp(r'^```(.*)\n([\s\S]*)\n```$', multiLine: true);
    final match = codeBlockRegex.firstMatch(content.trim());

    if (match != null) {
      final language = match.group(1) ?? 'text';
      final code = match.group(2) ?? '';

      return [
        BlocoCodigo(
          id: _uuid.v4(),
          codigo: code,
          linguagem: language,
          destacarSintaxe: true,
        )
      ];
    }

    return [_createTextBlock(content)];
  }

  /// Converter equação matemática
  List<BlocoBase> _parseMathEquation(String content) {
    // Remover delimitadores LaTeX se presentes
    String formula = content.trim();
    if (formula.startsWith('\$\$') && formula.endsWith('\$\$')) {
      formula = formula.substring(2, formula.length - 2);
    } else if (formula.startsWith('\$') && formula.endsWith('\$')) {
      formula = formula.substring(1, formula.length - 1);
    }

    return [
      BlocoEquacao(
        id: _uuid.v4(),
        formula: formula,
        blocoCompleto: content.contains('\$\$'),
      )
    ];
  }

  /// Converter tabela
  List<BlocoBase> _parseTable(String content) {
    final lines =
        content.split('\n').where((line) => line.trim().isNotEmpty).toList();

    if (lines.length < 2) {
      return [_createTextBlock(content)];
    }

    // Primeira linha são os cabeçalhos
    final headers = lines[0]
        .split('|')
        .map((cell) => cell.trim())
        .where((cell) => cell.isNotEmpty)
        .toList();

    // Pular linha de separação (segunda linha)
    // Demais linhas são dados
    final rows = <List<String>>[];
    for (int i = 2; i < lines.length; i++) {
      final row = lines[i]
          .split('|')
          .map((cell) => cell.trim())
          .where((cell) => cell.isNotEmpty)
          .toList();

      if (row.isNotEmpty) {
        rows.add(row);
      }
    }

    return [
      BlocoTabela(
        id: _uuid.v4(),
        cabecalhos: headers,
        linhas: rows,
      )
    ];
  }

  /// Converter lista simples
  List<BlocoBase> _parseList(String content) {
    final items = content
        .split('\n')
        .map(
            (line) => RegExp(r'^\s*[-\*\+]\s+(.+)$').firstMatch(line)?.group(1))
        .where((item) => item != null)
        .cast<String>()
        .toList();

    return [
      BlocoLista(
        id: _uuid.v4(),
        itens: items,
      )
    ];
  }

  /// Converter lista de tarefas
  List<BlocoBase> _parseTaskList(String content) {
    final blocos = <BlocoBase>[];
    final lines = content.split('\n');

    for (final line in lines) {
      final match =
          RegExp(r'^\s*[-\*\+]\s*\[([x\s])\]\s*(.+)$').firstMatch(line);
      if (match != null) {
        final isChecked = match.group(1)!.toLowerCase() == 'x';
        final taskText = match.group(2)!;

        blocos.add(BlocoTarefa(
          id: _uuid.v4(),
          conteudo: taskText,
          concluida: isChecked,
        ));
      }
    }

    return blocos.isEmpty ? [_createTextBlock(content)] : blocos;
  }

  /// Converter lista numerada
  List<BlocoBase> _parseNumberedList(String content) {
    final items = content
        .split('\n')
        .map((line) => RegExp(r'^\s*\d+\.\s+(.+)$').firstMatch(line)?.group(1))
        .where((item) => item != null)
        .cast<String>()
        .toList();

    return [
      BlocoListaNumerada(
        id: _uuid.v4(),
        itens: items,
      )
    ];
  }

  /// Converter dados JSON
  List<BlocoBase> _parseJsonData(String content) {
    return [
      BlocoCodigo(
        id: _uuid.v4(),
        codigo: content,
        linguagem: 'json',
        destacarSintaxe: true,
      )
    ];
  }

  /// Converter dados CSV
  List<BlocoBase> _parseCsvData(String content) {
    final lines =
        content.split('\n').where((line) => line.trim().isNotEmpty).toList();

    if (lines.isEmpty) {
      return [_createTextBlock(content)];
    }

    // Primeira linha como cabeçalhos
    final headers = lines[0].split(',').map((cell) => cell.trim()).toList();

    // Demais linhas como dados
    final rows = <List<String>>[];
    for (int i = 1; i < lines.length; i++) {
      final row = lines[i].split(',').map((cell) => cell.trim()).toList();
      rows.add(row);
    }

    return [
      BlocoTabela(
        id: _uuid.v4(),
        cabecalhos: headers,
        linhas: rows,
      )
    ];
  }

  /// Converter prompt de IA
  List<BlocoBase> _parseAiPrompt(String content) {
    return [
      BlocoTexto(
        id: _uuid.v4(),
        conteudo: content,
        // TODO: Adicionar formatação especial para prompts de IA
      )
    ];
  }

  /// Converter texto simples
  List<BlocoBase> _parsePlainText(String content) {
    // Dividir em parágrafos se houver quebras de linha duplas
    final paragraphs =
        content.split('\n\n').where((p) => p.trim().isNotEmpty).toList();

    if (paragraphs.length > 1) {
      return paragraphs
          .map((paragraph) => _createTextBlock(paragraph.trim()))
          .toList();
    }

    return [_createTextBlock(content)];
  }

  /// Criar bloco de texto simples
  BlocoTexto _createTextBlock(String content) {
    return BlocoTexto(
      id: _uuid.v4(),
      conteudo: content,
    );
  }

  /// Extrair metadados de URL (para preview)
  Future<Map<String, String>?> extractUrlMetadata(String url) async {
    // TODO: Implementar extração de metadados de URL
    // Por agora, retorna dados básicos
    try {
      final uri = Uri.parse(url);
      return {
        'title': uri.host,
        'description': 'Link para ${uri.host}',
        'url': url,
      };
    } catch (e) {
      return null;
    }
  }

  /// Detectar e converter múltiplos URLs em uma string
  List<BlocoBase> _parseMultipleUrls(String content) {
    final urlRegex = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      caseSensitive: false,
    );

    final matches = urlRegex.allMatches(content);
    final blocos = <BlocoBase>[];

    for (final match in matches) {
      final url = match.group(0)!;
      blocos.add(BlocoLink(
        id: _uuid.v4(),
        url: url,
        titulo: 'Link extraído',
      ));
    }

    return blocos;
  }

  /// Análise de sentimento para prompts de IA (opcional)
  Map<String, dynamic> _analyzePromptSentiment(String content) {
    final positiveWords = ['ajude', 'obrigado', 'por favor', 'grato'];
    final questionWords = ['como', 'o que', 'por que', 'quando', 'onde'];

    final lowerContent = content.toLowerCase();
    final hasPositive =
        positiveWords.any((word) => lowerContent.contains(word));
    final hasQuestion =
        questionWords.any((word) => lowerContent.contains(word));

    return {
      'isPolite': hasPositive,
      'isQuestion': hasQuestion,
      'wordCount': content.split(' ').length,
      'estimatedComplexity': content.length > 100 ? 'alta' : 'baixa',
    };
  }
}

/// Tipos de conteúdo detectados
enum ContentType {
  plainText,
  markdown,
  url,
  codeBlock,
  mathEquation,
  table,
  list,
  taskList,
  numberedList,
  jsonData,
  csvData,
  aiPrompt, // Novo tipo para prompts de IA
}

/// Resultado da análise do clipboard
class ClipboardParseResult {
  final bool success;
  final List<BlocoBase> blocos;
  final String originalContent;
  final ContentType? detectedType;
  final String? error;
  final Map<String, dynamic>? metadata;

  const ClipboardParseResult({
    required this.success,
    this.blocos = const [],
    this.originalContent = '',
    this.detectedType,
    this.error,
    this.metadata,
  });

  factory ClipboardParseResult.success({
    required List<BlocoBase> blocos,
    required String originalContent,
    required ContentType detectedType,
    Map<String, dynamic>? metadata,
  }) {
    return ClipboardParseResult(
      success: true,
      blocos: blocos,
      originalContent: originalContent,
      detectedType: detectedType,
      metadata: metadata,
    );
  }

  factory ClipboardParseResult.error(String error) {
    return ClipboardParseResult(
      success: false,
      error: error,
    );
  }

  factory ClipboardParseResult.empty() {
    return const ClipboardParseResult(
      success: true,
      blocos: [],
      originalContent: '',
      detectedType: ContentType.plainText,
    );
  }

  bool get isEmpty => blocos.isEmpty;
  bool get isNotEmpty => blocos.isNotEmpty;
  bool get hasMetadata => metadata != null && metadata!.isNotEmpty;
}

/// Extensões para facilitar o uso
extension ContentTypeExtension on ContentType {
  String get displayName {
    switch (this) {
      case ContentType.plainText:
        return 'Texto Simples';
      case ContentType.markdown:
        return 'Markdown';
      case ContentType.url:
        return 'Link/URL';
      case ContentType.codeBlock:
        return 'Código';
      case ContentType.mathEquation:
        return 'Equação Matemática';
      case ContentType.table:
        return 'Tabela';
      case ContentType.list:
        return 'Lista';
      case ContentType.taskList:
        return 'Lista de Tarefas';
      case ContentType.numberedList:
        return 'Lista Numerada';
      case ContentType.jsonData:
        return 'Dados JSON';
      case ContentType.csvData:
        return 'Dados CSV';
      case ContentType.aiPrompt:
        return 'Prompt de IA';
    }
  }

  String get emoji {
    switch (this) {
      case ContentType.plainText:
        return '📝';
      case ContentType.markdown:
        return '📄';
      case ContentType.url:
        return '🔗';
      case ContentType.codeBlock:
        return '💻';
      case ContentType.mathEquation:
        return '🧮';
      case ContentType.table:
        return '📊';
      case ContentType.list:
        return '📋';
      case ContentType.taskList:
        return '✅';
      case ContentType.numberedList:
        return '🔢';
      case ContentType.jsonData:
        return '📦';
      case ContentType.csvData:
        return '📈';
      case ContentType.aiPrompt:
        return '🤖';
    }
  }

  Color get color {
    switch (this) {
      case ContentType.plainText:
        return const Color(0xFF757575);
      case ContentType.markdown:
        return const Color(0xFF2196F3);
      case ContentType.url:
        return const Color(0xFF1976D2);
      case ContentType.codeBlock:
        return const Color(0xFF4CAF50);
      case ContentType.mathEquation:
        return const Color(0xFF9C27B0);
      case ContentType.table:
        return const Color(0xFF607D8B);
      case ContentType.list:
        return const Color(0xFF795548);
      case ContentType.taskList:
        return const Color(0xFF4CAF50);
      case ContentType.numberedList:
        return const Color(0xFF3F51B5);
      case ContentType.jsonData:
        return const Color(0xFFFF5722);
      case ContentType.csvData:
        return const Color(0xFF009688);
      case ContentType.aiPrompt:
        return const Color(0xFFFF9800);
    }
  }
}
