import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/bloco_base_model.dart';
import '../models/bloco_tipo_enum.dart';

/// Serviço especializado para parsing avançado de Markdown
class MarkdownParserService {
  static const _uuid = Uuid();

  /// Parser principal de Markdown para blocos
  List<BlocoBase> parseMarkdown(String markdown) {
    if (markdown.trim().isEmpty) return [];

    final document = _parseDocument(markdown);
    return _convertDocumentToBlocos(document);
  }

  /// Parse documento com front matter e metadados
  MarkdownDocument _parseDocument(String markdown) {
    final lines = markdown.split('\n');

    // Detectar front matter
    Map<String, dynamic>? frontMatter;
    int contentStartIndex = 0;

    if (lines.isNotEmpty && lines[0].trim() == '---') {
      final frontMatterEnd =
          lines.skip(1).toList().indexWhere((line) => line.trim() == '---');
      if (frontMatterEnd != -1) {
        final frontMatterLines = lines.skip(1).take(frontMatterEnd).toList();
        frontMatter = _parseFrontMatter(frontMatterLines);
        contentStartIndex = frontMatterEnd + 2;
      }
    }

    final contentLines = lines.skip(contentStartIndex).toList();
    final elements = _parseElements(contentLines);

    return MarkdownDocument(
      frontMatter: frontMatter ?? {},
      elements: elements,
      metadata: _extractMetadata(elements),
    );
  }

  /// Parse front matter YAML
  Map<String, dynamic> _parseFrontMatter(List<String> lines) {
    final frontMatter = <String, dynamic>{};

    for (final line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.skip(1).join(':').trim();

          // Parse diferentes tipos de valores
          if (value.toLowerCase() == 'true') {
            frontMatter[key] = true;
          } else if (value.toLowerCase() == 'false') {
            frontMatter[key] = false;
          } else if (RegExp(r'^\d+$').hasMatch(value)) {
            frontMatter[key] = int.tryParse(value) ?? value;
          } else if (RegExp(r'^\d+\.\d+$').hasMatch(value)) {
            frontMatter[key] = double.tryParse(value) ?? value;
          } else if (value.startsWith('[') && value.endsWith(']')) {
            // Lista simples
            final listContent = value.substring(1, value.length - 1);
            frontMatter[key] =
                listContent.split(',').map((e) => e.trim()).toList();
          } else {
            // String (remover aspas se presentes)
            frontMatter[key] = value.replaceAll('"', '').replaceAll("'", '');
          }
        }
      }
    }

    return frontMatter;
  }

  /// Parse elementos do documento
  List<MarkdownElement> _parseElements(List<String> lines) {
    final elements = <MarkdownElement>[];

    String currentParagraph = '';
    bool inCodeBlock = false;
    String codeBlockLanguage = '';
    String codeBlockContent = '';
    bool inTable = false;
    List<String> tableHeaders = [];
    List<List<String>> tableRows = [];
    bool inFootnote = false;
    String footnoteId = '';
    String footnoteContent = '';

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmedLine = line.trim();

      // Bloco de código
      if (trimmedLine.startsWith('```')) {
        if (inCodeBlock) {
          // Fechar bloco de código
          elements.add(MarkdownElement(
            type: MarkdownElementType.codeBlock,
            content: codeBlockContent.trim(),
            metadata: {'language': codeBlockLanguage},
          ));
          inCodeBlock = false;
          codeBlockContent = '';
          codeBlockLanguage = '';
        } else {
          // Abrir bloco de código
          _addCurrentParagraph(elements, currentParagraph);
          currentParagraph = '';

          inCodeBlock = true;
          codeBlockLanguage = trimmedLine.substring(3).trim();
        }
        continue;
      }

      if (inCodeBlock) {
        codeBlockContent += '$line\n';
        continue;
      }

      // Tabela
      if (line.contains('|') && trimmedLine.isNotEmpty) {
        if (!inTable) {
          _addCurrentParagraph(elements, currentParagraph);
          currentParagraph = '';
          inTable = true;

          tableHeaders = _parseTableRow(line);
        } else {
          if (line.contains('---')) {
            continue; // Linha separadora
          }

          final row = _parseTableRow(line);
          tableRows.add(row);
        }
        continue;
      } else if (inTable) {
        // Fim da tabela
        elements.add(MarkdownElement(
          type: MarkdownElementType.table,
          content: '',
          metadata: {
            'headers': tableHeaders,
            'rows': tableRows,
          },
        ));
        inTable = false;
        tableHeaders.clear();
        tableRows.clear();
      }

      // Footnotes
      final footnoteMatch = RegExp(r'^\^([^:]+):\s*(.*)$').firstMatch(line);
      if (footnoteMatch != null) {
        if (inFootnote) {
          elements.add(MarkdownElement(
            type: MarkdownElementType.footnote,
            content: footnoteContent.trim(),
            metadata: {'id': footnoteId},
          ));
        }

        inFootnote = true;
        footnoteId = footnoteMatch.group(1)!;
        footnoteContent = footnoteMatch.group(2)!;
        continue;
      }

      if (inFootnote && line.startsWith('    ')) {
        footnoteContent += '\n${line.substring(4)}';
        continue;
      } else if (inFootnote) {
        elements.add(MarkdownElement(
          type: MarkdownElementType.footnote,
          content: footnoteContent.trim(),
          metadata: {'id': footnoteId},
        ));
        inFootnote = false;
      }

      // Linha vazia
      if (trimmedLine.isEmpty) {
        _addCurrentParagraph(elements, currentParagraph);
        currentParagraph = '';
        continue;
      }

      // Títulos
      final headerMatch = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(line);
      if (headerMatch != null) {
        _addCurrentParagraph(elements, currentParagraph);
        currentParagraph = '';

        final level = headerMatch.group(1)!.length;
        final title = headerMatch.group(2)!;
        final anchor = _generateAnchor(title);

        elements.add(MarkdownElement(
          type: MarkdownElementType.heading,
          content: title,
          metadata: {
            'level': level,
            'anchor': anchor,
          },
        ));
        continue;
      }

      // Títulos alternativos (setext)
      if (i + 1 < lines.length) {
        final nextLine = lines[i + 1].trim();
        if (nextLine.isNotEmpty &&
            (nextLine.replaceAll('=', '').isEmpty ||
                nextLine.replaceAll('-', '').isEmpty)) {
          _addCurrentParagraph(elements, currentParagraph);
          currentParagraph = '';

          final level = nextLine.contains('=') ? 1 : 2;
          final anchor = _generateAnchor(trimmedLine);

          elements.add(MarkdownElement(
            type: MarkdownElementType.heading,
            content: trimmedLine,
            metadata: {
              'level': level,
              'anchor': anchor,
            },
          ));
          i++; // Pular próxima linha
          continue;
        }
      }

      // Divisor horizontal
      if (RegExp(r'^[-*_]{3,}$').hasMatch(trimmedLine)) {
        _addCurrentParagraph(elements, currentParagraph);
        currentParagraph = '';

        elements.add(MarkdownElement(
          type: MarkdownElementType.horizontalRule,
          content: '',
        ));
        continue;
      }

      // Blockquote
      if (line.startsWith('> ')) {
        _addCurrentParagraph(elements, currentParagraph);
        currentParagraph = '';

        elements.add(MarkdownElement(
          type: MarkdownElementType.blockquote,
          content: line.substring(2),
        ));
        continue;
      }

      // Lista de tarefas
      final taskMatch =
          RegExp(r'^\s*[-*+]\s*\[([x\s])\]\s*(.+)$').firstMatch(line);
      if (taskMatch != null) {
        _addCurrentParagraph(elements, currentParagraph);
        currentParagraph = '';

        final isChecked = taskMatch.group(1)!.toLowerCase() == 'x';
        final taskText = taskMatch.group(2)!;
        final indentation = line.length - line.trimLeft().length;

        elements.add(MarkdownElement(
          type: MarkdownElementType.taskList,
          content: taskText,
          metadata: {
            'checked': isChecked,
            'indentation': indentation,
          },
        ));
        continue;
      }

      // Lista com marcadores
      final bulletMatch = RegExp(r'^\s*[-*+]\s+(.+)$').firstMatch(line);
      if (bulletMatch != null) {
        _addCurrentParagraph(elements, currentParagraph);
        currentParagraph = '';

        final itemText = bulletMatch.group(1)!;
        final indentation = line.length - line.trimLeft().length;

        elements.add(MarkdownElement(
          type: MarkdownElementType.bulletList,
          content: itemText,
          metadata: {
            'indentation': indentation,
          },
        ));
        continue;
      }

      // Lista numerada
      final numberedMatch = RegExp(r'^\s*(\d+)\.\s+(.+)$').firstMatch(line);
      if (numberedMatch != null) {
        _addCurrentParagraph(elements, currentParagraph);
        currentParagraph = '';

        final number = int.parse(numberedMatch.group(1)!);
        final itemText = numberedMatch.group(2)!;
        final indentation = line.length - line.trimLeft().length;

        elements.add(MarkdownElement(
          type: MarkdownElementType.numberedList,
          content: itemText,
          metadata: {
            'number': number,
            'indentation': indentation,
          },
        ));
        continue;
      }

      // Equação matemática (bloco)
      if (trimmedLine.startsWith('$$') &&
          trimmedLine.endsWith('$$') &&
          trimmedLine.length > 4) {
        _addCurrentParagraph(elements, currentParagraph);
        currentParagraph = '';

        final formula = trimmedLine.substring(2, trimmedLine.length - 2);
        elements.add(MarkdownElement(
          type: MarkdownElementType.mathBlock,
          content: formula,
        ));
        continue;
      }

      // Linha normal - adicionar ao parágrafo
      currentParagraph += '${currentParagraph.isEmpty ? '' : '\n'}$line';
    }

    // Finalizar elementos pendentes
    _addCurrentParagraph(elements, currentParagraph);

    if (inTable) {
      elements.add(MarkdownElement(
        type: MarkdownElementType.table,
        content: '',
        metadata: {
          'headers': tableHeaders,
          'rows': tableRows,
        },
      ));
    }

    if (inFootnote) {
      elements.add(MarkdownElement(
        type: MarkdownElementType.footnote,
        content: footnoteContent.trim(),
        metadata: {'id': footnoteId},
      ));
    }

    return elements;
  }

  /// Adicionar parágrafo aos elementos
  void _addCurrentParagraph(List<MarkdownElement> elements, String paragraph) {
    final cleanParagraph = paragraph.trim();
    if (cleanParagraph.isNotEmpty) {
      elements.add(MarkdownElement(
        type: MarkdownElementType.paragraph,
        content: cleanParagraph,
        metadata: _parseInlineElements(cleanParagraph),
      ));
    }
  }

  /// Parse elementos inline (negrito, itálico, links, etc.)
  Map<String, dynamic> _parseInlineElements(String text) {
    final metadata = <String, dynamic>{};
    final inlineElements = <Map<String, dynamic>>[];

    // Links
    final linkMatches = RegExp(r'\[([^\]]+)\]\(([^)]+)\)').allMatches(text);
    for (final match in linkMatches) {
      inlineElements.add({
        'type': 'link',
        'text': match.group(1),
        'url': match.group(2),
        'start': match.start,
        'end': match.end,
      });
    }

    // Imagens
    final imageMatches = RegExp(r'!\u005B([^\]]*)\u005D\(([^)]+)\)').allMatches(text);
    for (final match in imageMatches) {
      inlineElements.add({
        'type': 'image',
        'alt': match.group(1),
        'url': match.group(2),
        'start': match.start,
        'end': match.end,
      });
    }

    // Código inline
    final codeMatches = RegExp(r'`([^`]+)`').allMatches(text);
    for (final match in codeMatches) {
      inlineElements.add({
        'type': 'code',
        'text': match.group(1),
        'start': match.start,
        'end': match.end,
      });
    }

    // Math inline
    final mathMatches = RegExp(r'\$([^$]+)\$').allMatches(text);
    for (final match in mathMatches) {
      inlineElements.add({
        'type': 'math',
        'formula': match.group(1),
        'start': match.start,
        'end': match.end,
      });
    }

    // Negrito
    final boldMatches = RegExp(r'\*\*([^*]+)\*\*').allMatches(text);
    for (final match in boldMatches) {
      inlineElements.add({
        'type': 'bold',
        'text': match.group(1),
        'start': match.start,
        'end': match.end,
      });
    }

    // Itálico
    final italicMatches = RegExp(r'\*([^*]+)\*').allMatches(text);
    for (final match in italicMatches) {
      // Verificar se não está dentro de negrito
      final isBold = boldMatches.any((boldMatch) =>
          match.start >= boldMatch.start && match.end <= boldMatch.end);

      if (!isBold) {
        inlineElements.add({
          'type': 'italic',
          'text': match.group(1),
          'start': match.start,
          'end': match.end,
        });
      }
    }

    // Riscado
    final strikeMatches = RegExp(r'~~([^~]+)~~').allMatches(text);
    for (final match in strikeMatches) {
      inlineElements.add({
        'type': 'strikethrough',
        'text': match.group(1),
        'start': match.start,
        'end': match.end,
      });
    }

    // Footnote references
    final footnoteRefMatches = RegExp(r'\^([^\s]+)').allMatches(text);
    for (final match in footnoteRefMatches) {
      inlineElements.add({
        'type': 'footnoteRef',
        'id': match.group(1),
        'start': match.start,
        'end': match.end,
      });
    }

    if (inlineElements.isNotEmpty) {
      metadata['inlineElements'] = inlineElements;
    }

    return metadata;
  }

  /// Parse linha de tabela
  List<String> _parseTableRow(String line) {
    return line
        .split('|')
        .map((cell) => cell.trim())
        .where((cell) => cell.isNotEmpty)
        .toList();
  }

  /// Gerar âncora para títulos
  String _generateAnchor(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  /// Extrair metadados do documento
  Map<String, dynamic> _extractMetadata(List<MarkdownElement> elements) {
    final metadata = <String, dynamic>{};

    // Contar elementos
    final elementCounts = <MarkdownElementType, int>{};
    for (final element in elements) {
      elementCounts[element.type] = (elementCounts[element.type] ?? 0) + 1;
    }
    metadata['elementCounts'] =
        elementCounts.map((k, v) => MapEntry(k.name, v));

    // Extrair títulos para TOC
    final headings = elements
        .where((e) => e.type == MarkdownElementType.heading)
        .map((e) => {
              'text': e.content,
              'level': e.metadata?['level'] ?? 1,
              'anchor': e.metadata?['anchor'] ?? '',
            })
        .toList();
    metadata['tableOfContents'] = headings;

    // Extrair links
    final links = <String>[];
    for (final element in elements) {
      final inlineElements = element.metadata?['inlineElements'] as List?;
      if (inlineElements != null) {
        for (final inline in inlineElements) {
          if (inline['type'] == 'link') {
            links.add(inline['url']);
          }
        }
      }
    }
    metadata['externalLinks'] = links.toSet().toList();

    // Extrair imagens
    final images = <String>[];
    for (final element in elements) {
      final inlineElements = element.metadata?['inlineElements'] as List?;
      if (inlineElements != null) {
        for (final inline in inlineElements) {
          if (inline['type'] == 'image') {
            images.add(inline['url']);
          }
        }
      }
    }
    metadata['images'] = images;

    // Estatísticas de texto
    final wordCount = elements
        .where((e) => e.type == MarkdownElementType.paragraph)
        .map((e) => e.content.split(RegExp(r'\s+')).length)
        .fold<int>(0, (sum, count) => sum + count);
    metadata['wordCount'] = wordCount;

    final charCount = elements
        .map((e) => e.content.length)
        .fold<int>(0, (sum, count) => sum + count);
    metadata['characterCount'] = charCount;

    // Tempo estimado de leitura (250 palavras por minuto)
    metadata['estimatedReadingTimeMinutes'] = (wordCount / 250).ceil();

    return metadata;
  }

  /// Converter documento para blocos do sistema
  List<BlocoBase> _convertDocumentToBlocos(MarkdownDocument document) {
    final blocos = <BlocoBase>[];

    for (final element in document.elements) {
      final bloco = _convertElementToBloco(element);
      if (bloco != null) {
        blocos.add(bloco);
      }
    }

    return blocos;
  }

  /// Converter elemento individual para bloco
  BlocoBase? _convertElementToBloco(MarkdownElement element) {
    switch (element.type) {
      case MarkdownElementType.heading:
        return BlocoTitulo(
          id: _uuid.v4(),
          conteudo: element.content,
          nivel: element.metadata?['level'] ?? 1,
          formatacao: {
            'anchor': element.metadata?['anchor'],
          },
        );

      case MarkdownElementType.paragraph:
        return BlocoTexto(
          id: _uuid.v4(),
          conteudo: element.content,
          formatacao: _extractInlineFormatting(element.metadata),
        );

      case MarkdownElementType.codeBlock:
        return BlocoCodigo(
          id: _uuid.v4(),
          codigo: element.content,
          linguagem: element.metadata?['language'] ?? 'text',
          destacarSintaxe: true,
        );

      case MarkdownElementType.bulletList:
        return BlocoLista(
          id: _uuid.v4(),
          itens: [element.content],
          indentacao: element.metadata?['indentation'] ?? 0,
        );

      case MarkdownElementType.numberedList:
        return BlocoListaNumerada(
          id: _uuid.v4(),
          itens: [element.content],
          inicioNumero: element.metadata?['number'] ?? 1,
          indentacao: element.metadata?['indentation'] ?? 0,
        );

      case MarkdownElementType.taskList:
        return BlocoTarefa(
          id: _uuid.v4(),
          conteudo: element.content,
          concluida: element.metadata?['checked'] ?? false,
        );

      case MarkdownElementType.table:
        final headers = element.metadata?['headers'] as List<String>? ?? [];
        final rows = element.metadata?['rows'] as List<List<String>>? ?? [];

        return BlocoTabela(
          id: _uuid.v4(),
          cabecalhos: headers,
          linhas: rows,
        );

      case MarkdownElementType.mathBlock:
        return BlocoEquacao(
          id: _uuid.v4(),
          formula: element.content,
          blocoCompleto: true,
        );

      case MarkdownElementType.horizontalRule:
        return BlocoDivisor(
          id: _uuid.v4(),
        );

      case MarkdownElementType.blockquote:
        return BlocoTexto(
          id: _uuid.v4(),
          conteudo: element.content,
          formatacao: {
            'isBlockquote': true,
            'backgroundColor': '#F5F5F5',
            'borderColor': '#E0E0E0',
            'borderLeft': '4px solid #E0E0E0',
            'paddingLeft': '16px',
            'fontStyle': 'italic',
          },
        );

      case MarkdownElementType.footnote:
        return BlocoTexto(
          id: _uuid.v4(),
          conteudo: element.content,
          formatacao: {
            'isFootnote': true,
            'footnoteId': element.metadata?['id'],
            'fontSize': '14px',
            'color': '#666666',
          },
        );

      default:
        return null;
    }
  }

  /// Extrair formatação inline dos metadados
  Map<String, dynamic> _extractInlineFormatting(
      Map<String, dynamic>? metadata) {
    final formatting = <String, dynamic>{};

    final inlineElements = metadata?['inlineElements'] as List?;
    if (inlineElements != null) {
      formatting['inlineElements'] = inlineElements;

      // Verificar se tem elementos especiais
      final hasLinks = inlineElements.any((e) => e['type'] == 'link');
      final hasImages = inlineElements.any((e) => e['type'] == 'image');
      final hasMath = inlineElements.any((e) => e['type'] == 'math');
      final hasCode = inlineElements.any((e) => e['type'] == 'code');

      if (hasLinks) formatting['hasLinks'] = true;
      if (hasImages) formatting['hasImages'] = true;
      if (hasMath) formatting['hasMath'] = true;
      if (hasCode) formatting['hasCode'] = true;
    }

    return formatting;
  }

  /// Validar sintaxe Markdown
  MarkdownValidationResult validateMarkdown(String markdown) {
    final errors = <String>[];
    final warnings = <String>[];
    final suggestions = <String>[];

    final lines = markdown.split('\n');

    // Validar estrutura de títulos
    final headerLevels = <int>[];
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final headerMatch = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(line);

      if (headerMatch != null) {
        final level = headerMatch.group(1)!.length;
        headerLevels.add(level);

        // Verificar se pula níveis
        if (headerLevels.length > 1) {
          final previousLevel = headerLevels[headerLevels.length - 2];
          if (level > previousLevel + 1) {
            warnings.add(
                'Linha ${i + 1}: Nível de título pula de H$previousLevel para H$level');
          }
        }

        // Verificar se título está vazio
        final title = headerMatch.group(2)!.trim();
        if (title.isEmpty) {
          errors.add('Linha ${i + 1}: Título vazio');
        }
      }
    }

    // Validar links
    final linkMatches = RegExp(r'\[([^\]]*)\]\(([^)]*)\)').allMatches(markdown);
    for (final match in linkMatches) {
      final linkText = match.group(1) ?? '';
      final url = match.group(2) ?? '';

      if (linkText.isEmpty) {
        warnings.add('Link sem texto: $url');
      }

      if (url.isEmpty) {
        errors.add('Link sem URL: [$linkText]()');
      }
    }

    // Validar imagens
    final imageMatches =
        RegExp(r'!\u005B([^\]]*)\u005D\(([^)]+)\)').allMatches(markdown);
    for (final match in imageMatches) {
      final alt = match.group(1) ?? '';
      final url = match.group(2) ?? '';

      if (alt.isEmpty) {
        suggestions.add('Imagem sem texto alternativo: $url');
      }

      if (!_isValidUrl(url) &&
          !url.startsWith('./') &&
          !url.startsWith('../')) {
        warnings.add('URL de imagem possivelmente inválida: $url');
      }
    }

    // Validar blocos de código
    final codeBlockStarts = RegExp(r'^```').allMatches(markdown, 0);
    if (codeBlockStarts.length % 2 != 0) {
      errors.add('Bloco de código não fechado (número ímpar de ```)');
    }

    // Validar listas
    _validateLists(lines, warnings);

    // Validar tabelas
    _validateTables(lines, errors, warnings);

    return MarkdownValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      suggestions: suggestions,
    );
  }

  /// Validar listas
  void _validateLists(List<String> lines, List<String> warnings) {
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Lista numerada
      final numberedMatch = RegExp(r'^\s*(\d+)\.\s+(.+)$').firstMatch(line);
      if (numberedMatch != null) {
        final number = int.parse(numberedMatch.group(1)!);

        // Verificar se próxima linha também é lista numerada
        if (i + 1 < lines.length) {
          final nextLine = lines[i + 1];
          final nextNumberedMatch =
              RegExp(r'^\s*(\d+)\.\s+(.+)$').firstMatch(nextLine);

          if (nextNumberedMatch != null) {
            final nextNumber = int.parse(nextNumberedMatch.group(1)!);
            if (nextNumber != number + 1) {
              warnings.add(
                  'Linha ${i + 2}: Numeração de lista inconsistente ($number → $nextNumber)');
            }
          }
        }
      }
    }
  }

  /// Validar tabelas
  void _validateTables(
      List<String> lines, List<String> errors, List<String> warnings) {
    bool inTable = false;
    int headerColumnCount = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.contains('|') && line.trim().isNotEmpty) {
        final columns = _parseTableRow(line);

        if (!inTable) {
          inTable = true;
          headerColumnCount = columns.length;

          // Verificar se próxima linha é separador
          if (i + 1 < lines.length) {
            final nextLine = lines[i + 1];
            if (!nextLine.contains('---')) {
              warnings.add('Linha ${i + 2}: Tabela sem linha separadora');
            }
          }
        } else if (!line.contains('---')) {
          // Linha de dados
          if (columns.length != headerColumnCount) {
            warnings.add(
                'Linha ${i + 1}: Tabela com número diferente de colunas (esperado: $headerColumnCount, encontrado: ${columns.length})');
          }
        }
      } else if (inTable) {
        inTable = false;
        headerColumnCount = 0;
      }
    }
  }

  /// Validar URL
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Obter estatísticas do Markdown
  Map<String, dynamic> getMarkdownStats(String markdown) {
    final document = _parseDocument(markdown);

    return {
      'elementCounts': document.metadata['elementCounts'] ?? {},
      'wordCount': document.metadata['wordCount'] ?? 0,
      'characterCount': document.metadata['characterCount'] ?? 0,
      'estimatedReadingTime':
          document.metadata['estimatedReadingTimeMinutes'] ?? 0,
      'tableOfContents': document.metadata['tableOfContents'] ?? [],
      'externalLinks': document.metadata['externalLinks'] ?? [],
      'images': document.metadata['images'] ?? [],
      'hasFrontMatter': document.frontMatter.isNotEmpty,
      'frontMatterKeys': document.frontMatter.keys.toList(),
    };
  }

  /// Extrair front matter apenas
  Map<String, dynamic> extractFrontMatter(String markdown) {
    return _parseDocument(markdown).frontMatter;
  }

  /// Extrair table of contents
  List<Map<String, dynamic>> extractTableOfContents(String markdown) {
    final document = _parseDocument(markdown);
    return List<Map<String, dynamic>>.from(
        document.metadata['tableOfContents'] ?? []);
  }
}

/// Tipos de elementos Markdown
enum MarkdownElementType {
  heading,
  paragraph,
  codeBlock,
  bulletList,
  numberedList,
  taskList,
  table,
  blockquote,
  horizontalRule,
  mathBlock,
  footnote,
}

/// Elemento individual do Markdown
class MarkdownElement {
  final MarkdownElementType type;
  final String content;
  final Map<String, dynamic>? metadata;

  const MarkdownElement({
    required this.type,
    required this.content,
    this.metadata,
  });
}

/// Documento Markdown parseado
class MarkdownDocument {
  final Map<String, dynamic> frontMatter;
  final List<MarkdownElement> elements;
  final Map<String, dynamic> metadata;

  const MarkdownDocument({
    required this.frontMatter,
    required this.elements,
    required this.metadata,
  });
}

/// Resultado da validação
class MarkdownValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final List<String> suggestions;

  const MarkdownValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.suggestions,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasSuggestions => suggestions.isNotEmpty;
  int get totalIssues => errors.length + warnings.length + suggestions.length;
}

/// Extensões para facilitar uso
extension MarkdownElementTypeExtension on MarkdownElementType {
  String get displayName {
    switch (this) {
      case MarkdownElementType.heading:
        return 'Título';
      case MarkdownElementType.paragraph:
        return 'Parágrafo';
      case MarkdownElementType.codeBlock:
        return 'Bloco de Código';
      case MarkdownElementType.bulletList:
        return 'Lista com Marcadores';
      case MarkdownElementType.numberedList:
        return 'Lista Numerada';
      case MarkdownElementType.taskList:
        return 'Lista de Tarefas';
      case MarkdownElementType.table:
        return 'Tabela';
      case MarkdownElementType.blockquote:
        return 'Citação';
      case MarkdownElementType.horizontalRule:
        return 'Divisor';
      case MarkdownElementType.mathBlock:
        return 'Equação';
      case MarkdownElementType.footnote:
        return 'Nota de Rodapé';
    }
  }

  String get emoji {
    switch (this) {
      case MarkdownElementType.heading:
        return '📋';
      case MarkdownElementType.paragraph:
        return '📝';
      case MarkdownElementType.codeBlock:
        return '💻';
      case MarkdownElementType.bulletList:
        return '-  ';
      case MarkdownElementType.numberedList:
        return '🔢';
      case MarkdownElementType.taskList:
        return '✅';
      case MarkdownElementType.table:
        return '📊';
      case MarkdownElementType.blockquote:
        return '💬';
      case MarkdownElementType.horizontalRule:
        return '➖';
      case MarkdownElementType.mathBlock:
        return '🧮';
      case MarkdownElementType.footnote:
        return '📄';
    }
  }
}