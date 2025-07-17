/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import '../../features/bloquinho/services/html_enhancement_parser.dart';

/// Parser centralizado de markdown com enhancements
/// Usado tanto pelo preview quanto pelo exportador PDF
class EnhancedMarkdownParser {
  /// Parse markdown para blocos estruturados
  static List<MarkdownBlock> parseMarkdown(String markdown,
      {bool enableHtmlEnhancements = true}) {
    print('🔍 [PARSER] Iniciando parsing de markdown...');
    print('🔍 [PARSER] Tamanho do markdown: ${markdown.length} caracteres');
    print('🔍 [PARSER] HTML enhancements: $enableHtmlEnhancements');
    final blocks = <MarkdownBlock>[];

    try {
      // Sanitizar markdown para evitar problemas UTF-16
      print('🔍 [PARSER] Sanitizando markdown...');
      String sanitizedMarkdown = _sanitizeText(markdown);
      print(
          '🔍 [PARSER] Markdown sanitizado: ${sanitizedMarkdown.length} caracteres');

      final lines = sanitizedMarkdown.split('\n');
      print('🔍 [PARSER] Total de linhas: ${lines.length}');
      bool inCodeBlock = false;
      String codeBlockContent = '';
      String codeLanguage = '';
      bool inList = false;
      bool inBlockquote = false;
      String blockquoteContent = '';
      bool inTable = false;
      List<String> tableRows = [];

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];

        try {
          // Detectar início/fim de bloco de código
          if (line.startsWith('```')) {
            if (inCodeBlock) {
              // Fim do bloco de código
              blocks.add(MarkdownBlock(
                type: BlockType.code,
                content: codeBlockContent.trim(),
                language: codeLanguage,
              ));
              inCodeBlock = false;
              codeBlockContent = '';
              codeLanguage = '';
            } else {
              // Início do bloco de código
              inCodeBlock = true;
              codeLanguage = line.substring(3).trim();
            }
            continue;
          }

          if (inCodeBlock) {
            codeBlockContent += line + '\n';
            continue;
          }

          // Detectar tabelas
          if (line.contains('|') &&
              line.trim().startsWith('|') &&
              line.trim().endsWith('|')) {
            if (!inTable) {
              inTable = true;
              tableRows = [];
            }
            tableRows.add(line);
            continue;
          } else if (inTable) {
            // Fim da tabela
            blocks.add(MarkdownBlock(
              type: BlockType.table,
              content: tableRows.join('\n'),
            ));
            inTable = false;
            tableRows = [];
          }

          // Detectar blockquotes
          if (line.startsWith('> ')) {
            if (!inBlockquote) {
              inBlockquote = true;
              blockquoteContent = '';
            }
            blockquoteContent += line.substring(2) + '\n';
            continue;
          } else if (inBlockquote) {
            // Fim do blockquote
            blocks.add(MarkdownBlock(
              type: BlockType.blockquote,
              content: blockquoteContent.trim(),
            ));
            inBlockquote = false;
            blockquoteContent = '';
          }

          // Títulos
          if (line.startsWith('# ')) {
            blocks.add(MarkdownBlock(
              type: BlockType.heading,
              content: line.substring(2),
              level: 1,
            ));
          } else if (line.startsWith('## ')) {
            blocks.add(MarkdownBlock(
              type: BlockType.heading,
              content: line.substring(3),
              level: 2,
            ));
          } else if (line.startsWith('### ')) {
            blocks.add(MarkdownBlock(
              type: BlockType.heading,
              content: line.substring(4),
              level: 3,
            ));
          } else if (line.startsWith('#### ')) {
            blocks.add(MarkdownBlock(
              type: BlockType.heading,
              content: line.substring(5),
              level: 4,
            ));
          } else if (line.startsWith('##### ')) {
            blocks.add(MarkdownBlock(
              type: BlockType.heading,
              content: line.substring(6),
              level: 5,
            ));
          } else if (line.startsWith('###### ')) {
            blocks.add(MarkdownBlock(
              type: BlockType.heading,
              content: line.substring(7),
              level: 6,
            ));
          }
          // Listas
          else if (line.startsWith('- ') ||
              line.startsWith('* ') ||
              line.startsWith('+ ')) {
            blocks.add(MarkdownBlock(
              type: BlockType.listItem,
              content: line.substring(2),
              listType: ListType.unordered,
            ));
            inList = true;
          }
          // Listas numeradas
          else if (RegExp(r'^\d+\. ').hasMatch(line)) {
            final match = RegExp(r'^\d+\. (.*)').firstMatch(line);
            if (match != null) {
              blocks.add(MarkdownBlock(
                type: BlockType.listItem,
                content: match.group(1)!,
                listType: ListType.ordered,
              ));
            }
          }
          // Texto normal ou com formatação inline
          else if (line.trim().isNotEmpty) {
            if (inList) {
              inList = false;
            }

            // Processar enhancements HTML se habilitado
            String processedContent = line;
            if (enableHtmlEnhancements) {
              try {
                processedContent =
                    HtmlEnhancementParser.processWithEnhancements(line);
              } catch (e) {
                print(
                    '⚠️ [PARSER] Erro ao processar HTML enhancements na linha $i: $e');
                processedContent = line; // Usar linha original como fallback
              }
            }

            blocks.add(MarkdownBlock(
              type: BlockType.paragraph,
              content: processedContent,
            ));
          }
          // Linha em branco
          else {
            if (inList) {
              inList = false;
            }
          }
        } catch (e) {
          print('❌ [PARSER] Erro ao processar linha $i: $e');
          print('❌ [PARSER] Conteúdo da linha: "${line}"');
          // Adicionar bloco de erro como fallback
          blocks.add(MarkdownBlock(
            type: BlockType.paragraph,
            content: 'Erro ao processar conteúdo',
          ));
        }
      }

      // Finalizar blockquote se ainda estiver ativo
      if (inBlockquote) {
        blocks.add(MarkdownBlock(
          type: BlockType.blockquote,
          content: blockquoteContent.trim(),
        ));
      }

      // Finalizar tabela se ainda estiver ativa
      if (inTable && tableRows.isNotEmpty) {
        blocks.add(MarkdownBlock(
          type: BlockType.table,
          content: tableRows.join('\n'),
        ));
      }

      // Finalizar bloco de código se ainda estiver ativo
      if (inCodeBlock) {
        blocks.add(MarkdownBlock(
          type: BlockType.code,
          content: codeBlockContent.trim(),
          language: codeLanguage,
        ));
      }

      print('✅ [PARSER] Parsing concluído: ${blocks.length} blocos criados');
      return blocks;
    } catch (e, stackTrace) {
      print('❌ [PARSER] Erro crítico no parsing: $e');
      print('❌ [PARSER] Stack trace: $stackTrace');
      // Retornar bloco de erro como fallback
      return [
        MarkdownBlock(
          type: BlockType.paragraph,
          content: 'Erro ao processar markdown: $e',
        )
      ];
    }
  }

  /// Processar texto inline (negrito, itálico, código, links, etc.)
  static List<InlineElement> parseInlineText(String text) {
    final elements = <InlineElement>[];

    // Sanitizar texto para evitar problemas UTF-16
    String sanitizedText = _sanitizeText(text);
    String remaining = sanitizedText;

    while (remaining.isNotEmpty) {
      // Processar LaTeX inline \$...\$
      final latexMatch = RegExp(r'\$([^\$]+)\$').firstMatch(remaining);
      if (latexMatch != null && latexMatch.start == 0) {
        elements.add(InlineElement(
          type: InlineType.latex,
          content: latexMatch.group(1)!,
        ));
        remaining = remaining.substring(latexMatch.end);
        continue;
      }

      // Processar **texto**
      final boldMatch = RegExp(r'\*\*([^*]+)\*\*').firstMatch(remaining);
      if (boldMatch != null && boldMatch.start == 0) {
        elements.add(InlineElement(
          type: InlineType.bold,
          content: boldMatch.group(1)!,
        ));
        remaining = remaining.substring(boldMatch.end);
        continue;
      }

      // Processar *texto*
      final italicMatch = RegExp(r'\*([^*]+)\*').firstMatch(remaining);
      if (italicMatch != null && italicMatch.start == 0) {
        elements.add(InlineElement(
          type: InlineType.italic,
          content: italicMatch.group(1)!,
        ));
        remaining = remaining.substring(italicMatch.end);
        continue;
      }

      // Processar `código`
      final codeMatch = RegExp(r'`([^`]+)`').firstMatch(remaining);
      if (codeMatch != null && codeMatch.start == 0) {
        elements.add(InlineElement(
          type: InlineType.code,
          content: codeMatch.group(1)!,
        ));
        remaining = remaining.substring(codeMatch.end);
        continue;
      }

      // Processar <span style="...">...</span>
      final spanMatch =
          RegExp(r'<span style="([^"]*)">(.*?)<\/span>').firstMatch(remaining);
      if (spanMatch != null && spanMatch.start == 0) {
        elements.add(InlineElement(
          type: InlineType.span,
          content: spanMatch.group(2)!,
          style: spanMatch.group(1)!,
        ));
        remaining = remaining.substring(spanMatch.end);
        continue;
      }

      // Processar <kbd>...</kbd>
      final kbdMatch = RegExp(r'<kbd>(.*?)<\/kbd>').firstMatch(remaining);
      if (kbdMatch != null && kbdMatch.start == 0) {
        elements.add(InlineElement(
          type: InlineType.kbd,
          content: kbdMatch.group(1)!,
        ));
        remaining = remaining.substring(kbdMatch.end);
        continue;
      }

      // Processar <mark>...</mark>
      final markMatch = RegExp(r'<mark>(.*?)<\/mark>').firstMatch(remaining);
      if (markMatch != null && markMatch.start == 0) {
        elements.add(InlineElement(
          type: InlineType.mark,
          content: markMatch.group(1)!,
        ));
        remaining = remaining.substring(markMatch.end);
        continue;
      }

      // Processar <sub>...</sub>
      final subMatch = RegExp(r'<sub>(.*?)<\/sub>').firstMatch(remaining);
      if (subMatch != null && subMatch.start == 0) {
        elements.add(InlineElement(
          type: InlineType.subscript,
          content: subMatch.group(1)!,
        ));
        remaining = remaining.substring(subMatch.end);
        continue;
      }

      // Processar <sup>...</sup>
      final supMatch = RegExp(r'<sup>(.*?)<\/sup>').firstMatch(remaining);
      if (supMatch != null && supMatch.start == 0) {
        elements.add(InlineElement(
          type: InlineType.superscript,
          content: supMatch.group(1)!,
        ));
        remaining = remaining.substring(supMatch.end);
        continue;
      }

      // Encontrar próxima formatação ou fim do texto
      var nextFormatPos = remaining.length;
      final patterns = [
        r'\$[^\$]+\$',
        r'\*\*[^*]+\*\*',
        r'\*[^*]+\*',
        r'`[^`]+`',
        r'<span style="[^"]*">.*?<\/span>',
        r'<kbd>.*?<\/kbd>',
        r'<mark>.*?<\/mark>',
        r'<sub>.*?<\/sub>',
        r'<sup>.*?<\/sup>'
      ];

      for (final pattern in patterns) {
        final match = RegExp(pattern).firstMatch(remaining);
        if (match != null && match.start < nextFormatPos) {
          nextFormatPos = match.start;
        }
      }

      if (nextFormatPos > 0) {
        elements.add(InlineElement(
          type: InlineType.text,
          content: remaining.substring(0, nextFormatPos),
        ));
        remaining = remaining.substring(nextFormatPos);
      } else {
        break;
      }
    }

    if (remaining.isNotEmpty) {
      elements.add(InlineElement(
        type: InlineType.text,
        content: remaining,
      ));
    }

    return elements;
  }

  /// Parse estilos CSS
  static Map<String, dynamic> parseStyle(String style) {
    final map = <String, dynamic>{};
    final props = style.split(';');

    for (final prop in props) {
      final parts = prop.split(':');
      if (parts.length != 2) continue;

      final key = parts[0].trim();
      final value = parts[1].trim();

      switch (key) {
        case 'color':
          map['color'] = _parseColor(value);
          break;
        case 'background-color':
          map['backgroundColor'] = _parseColor(value);
          break;
        case 'font-weight':
          map['fontWeight'] =
              value == 'bold' ? FontWeight.bold : FontWeight.normal;
          break;
        case 'font-style':
          map['fontStyle'] =
              value == 'italic' ? FontStyle.italic : FontStyle.normal;
          break;
        case 'text-decoration':
          if (value.contains('underline')) {
            map['decoration'] = TextDecoration.underline;
          }
          if (value.contains('line-through')) {
            map['decoration'] = TextDecoration.lineThrough;
          }
          break;
        case 'font-family':
          map['fontFamily'] = value;
          break;
        case 'font-size':
          map['fontSize'] = double.tryParse(value.replaceAll('px', ''));
          break;
        case 'padding':
          map['padding'] = _parseEdgeInsets(value);
          break;
        case 'margin':
          map['margin'] = _parseEdgeInsets(value);
          break;
        case 'border-radius':
          map['borderRadius'] = BorderRadius.circular(
              double.tryParse(value.replaceAll('px', '')) ?? 0);
          break;
        case 'border':
          map['border'] = _parseBorder(value);
          break;
        case 'text-align':
          map['textAlign'] = _parseTextAlign(value);
          break;
      }
    }

    return map;
  }

  static Color? _parseColor(String value) {
    if (value.startsWith('#')) {
      try {
        return Color(int.parse(value.substring(1), radix: 16) + 0xFF000000);
      } catch (e) {
        return null;
      }
    }

    switch (value.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'grey':
      case 'gray':
        return Colors.grey;
      default:
        return null;
    }
  }

  static EdgeInsets _parseEdgeInsets(String value) {
    final parts = value.replaceAll('px', '').split(' ');
    if (parts.length == 1) {
      final v = double.tryParse(parts[0]) ?? 0;
      return EdgeInsets.all(v);
    } else if (parts.length == 2) {
      final v1 = double.tryParse(parts[0]) ?? 0;
      final v2 = double.tryParse(parts[1]) ?? 0;
      return EdgeInsets.symmetric(vertical: v1, horizontal: v2);
    } else if (parts.length == 4) {
      final top = double.tryParse(parts[0]) ?? 0;
      final right = double.tryParse(parts[1]) ?? 0;
      final bottom = double.tryParse(parts[2]) ?? 0;
      final left = double.tryParse(parts[3]) ?? 0;
      return EdgeInsets.fromLTRB(left, top, right, bottom);
    }
    return EdgeInsets.zero;
  }

  static Border? _parseBorder(String value) {
    final parts = value.split(' ');
    if (parts.length == 3) {
      final width = double.tryParse(parts[0].replaceAll('px', '')) ?? 1;
      final color = _parseColor(parts[2]);
      return Border.all(color: color ?? Colors.black, width: width);
    }
    return null;
  }

  static TextAlign? _parseTextAlign(String value) {
    switch (value) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'left':
        return TextAlign.left;
      case 'justify':
        return TextAlign.justify;
      default:
        return null;
    }
  }

  /// Sanitizar texto para evitar problemas UTF-16
  static String _sanitizeText(String text) {
    if (text.isEmpty) return text;

    try {
      // Verificar se a string é válida UTF-16
      text.codeUnits;

      // Remover caracteres de controle problemáticos
      String sanitized =
          text.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

      // Garantir que não há caracteres nulos
      sanitized = sanitized.replaceAll('\x00', '');

      // Verificar novamente se é válida
      sanitized.codeUnits;

      return sanitized;
    } catch (e) {
      // Se houver erro, retornar string vazia
      return '';
    }
  }
}

/// Tipos de blocos markdown
enum BlockType {
  paragraph,
  heading,
  listItem,
  code,
  blockquote,
  table,
  horizontalRule,
}

/// Tipos de listas
enum ListType {
  ordered,
  unordered,
}

/// Tipos de elementos inline
enum InlineType {
  text,
  bold,
  italic,
  code,
  latex,
  span,
  kbd,
  mark,
  subscript,
  superscript,
}

/// Bloco de markdown estruturado
class MarkdownBlock {
  final BlockType type;
  final String content;
  final int? level;
  final ListType? listType;
  final String? language;
  final Map<String, dynamic>? metadata;

  MarkdownBlock({
    required this.type,
    required this.content,
    this.level,
    this.listType,
    this.language,
    this.metadata,
  });
}

/// Elemento inline estruturado
class InlineElement {
  final InlineType type;
  final String content;
  final String? style;
  final Map<String, dynamic>? attributes;

  InlineElement({
    required this.type,
    required this.content,
    this.style,
    this.attributes,
  });
}
