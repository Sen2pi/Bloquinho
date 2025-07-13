import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/html_enhancement_parser.dart';
import 'advanced_code_block.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Widget de visualização markdown com enhancements HTML moderno
class EnhancedMarkdownPreviewWidget extends StatelessWidget {
  final String markdown;
  final bool showLineNumbers;
  final bool enableHtmlEnhancements;
  final TextStyle? baseTextStyle;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final bool showScrollbar;
  final ScrollPhysics? scrollPhysics;

  const EnhancedMarkdownPreviewWidget({
    super.key,
    required this.markdown,
    this.showLineNumbers = false,
    this.enableHtmlEnhancements = true,
    this.baseTextStyle,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
    this.showScrollbar = true,
    this.scrollPhysics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = baseTextStyle ?? theme.textTheme.bodyMedium!;
    final isDark = theme.brightness == Brightness.dark;
    final containerColor =
        backgroundColor ?? (isDark ? Colors.black : Colors.white);

    return Container(
      color: containerColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: padding,
          child: _buildEnhancedMarkdown(context, textStyle),
        ),
      ),
    );
  }

  Widget _buildEnhancedMarkdown(BuildContext context, TextStyle baseStyle) {
    if (!enableHtmlEnhancements) {
      return MarkdownBody(
        data: markdown,
        styleSheet: _createBasicStyleSheet(context, baseStyle),
        builders: {
          'code': AdvancedCodeBlockBuilder(),
          'mark': MarkBuilder(),
          'kbd': KbdBuilder(),
          'sub': SubBuilder(),
          'sup': SupBuilder(),
          'details': DetailsBuilder(),
          'summary': SummaryBuilder(),
          // ... outros builders customizados ...
        },
        inlineSyntaxes: [
          LatexInlineSyntax(),
        ],
        blockSyntaxes: [
          LatexBlockSyntax(),
        ],
      );
    }

    // Processar enhancements HTML
    final processedContent =
        HtmlEnhancementParser.processWithEnhancements(markdown);

    return MarkdownBody(
      data: processedContent,
      styleSheet: _createEnhancedStyleSheet(context, baseStyle),
      builders: {
        'code': AdvancedCodeBlockBuilder(),
        'mark': MarkBuilder(),
        'kbd': KbdBuilder(),
        'sub': SubBuilder(),
        'sup': SupBuilder(),
        'details': DetailsBuilder(),
        'summary': SummaryBuilder(),
        'latex-inline': LatexBuilder(),
        'latex-block': LatexBuilder(),
        'span': StyledSpanBuilder(),
        'div': StyledSpanBuilder(),
        'progress': ProgressBuilder(),
        'mermaid': MermaidBuilder(),
        // ... outros builders customizados ...
      },
      inlineSyntaxes: [
        LatexInlineSyntax(),
      ],
      blockSyntaxes: [
        LatexBlockSyntax(),
      ],
    );
  }

  /// Cria styleSheet básico para markdown
  MarkdownStyleSheet _createBasicStyleSheet(
      BuildContext context, TextStyle baseStyle) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      h1: baseStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.2,
      ),
      h2: baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.3,
      ),
      h3: baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      h4: baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      h5: baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      h6: baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      p: baseStyle.copyWith(
        fontSize: 16,
        height: 1.6,
        color: textColor,
      ),
      strong: baseStyle.copyWith(
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      em: baseStyle.copyWith(
        fontStyle: FontStyle.italic,
        color: textColor,
      ),
      code: baseStyle.copyWith(
        fontFamily: 'monospace',
        backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        color: textColor,
        fontSize: 14,
      ),
      codeblockDecoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  /// Cria styleSheet avançado com enhancements
  MarkdownStyleSheet _createEnhancedStyleSheet(
      BuildContext context, TextStyle baseStyle) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      h1: baseStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.2,
      ),
      h2: baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.3,
      ),
      h3: baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      h4: baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      h5: baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      h6: baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      p: baseStyle.copyWith(
        fontSize: 16,
        height: 1.6,
        color: textColor,
      ),
      strong: baseStyle.copyWith(
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      em: baseStyle.copyWith(
        fontStyle: FontStyle.italic,
        color: textColor,
      ),
      code: baseStyle.copyWith(
        fontFamily: 'monospace',
        backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        color: textColor,
        fontSize: 14,
      ),
      codeblockDecoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      blockquote: baseStyle.copyWith(
        fontSize: 16,
        fontStyle: FontStyle.italic,
        color: textColor.withOpacity(0.8),
        height: 1.6,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary,
            width: 4,
          ),
        ),
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
      ),
      listBullet: baseStyle.copyWith(
        color: textColor,
        fontSize: 16,
      ),
      tableHead: baseStyle.copyWith(
        fontWeight: FontWeight.bold,
        color: textColor,
        fontSize: 14,
      ),
      tableBody: baseStyle.copyWith(
        color: textColor,
        fontSize: 14,
      ),
    );
  }
}

/// Builder moderno para tabelas
class ModernTableBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Table(
              border: TableBorder.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                width: 1,
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: _buildTableRows(element, theme),
            ),
          ),
        );
      },
    );
  }

  List<TableRow> _buildTableRows(md.Element element, ThemeData theme) {
    final rows = <TableRow>[];
    final isDark = theme.brightness == Brightness.dark;

    for (final child in element.children ?? []) {
      if (child is md.Element && child.tag == 'tr') {
        final cells = <Widget>[];
        bool isHeader = rows.isEmpty;

        for (final cell in child.children ?? []) {
          if (cell is md.Element && (cell.tag == 'td' || cell.tag == 'th')) {
            cells.add(
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isHeader
                      ? (isDark ? Colors.grey[800] : Colors.grey[100])
                      : null,
                ),
                child: Text(
                  cell.textContent,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }
        }
        rows.add(TableRow(children: cells));
      }
    }

    return rows;
  }
}

/// Builder moderno para listas
class ModernListBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (element.children ?? []).map((child) {
          if (child is md.Element && child.tag == 'li') {
            return ModernListItemBuilder()
                .visitElementAfter(child, preferredStyle);
          }
          return const SizedBox.shrink();
        }).toList(),
      ),
    );
  }
}

/// Builder moderno para itens de lista
class ModernListItemBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 8, right: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  element.textContent,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Builder moderno para blockquotes
class ModernBlockquoteBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: theme.colorScheme.primary,
                width: 4,
              ),
            ),
            borderRadius: BorderRadius.circular(8),
            color:
                isDark ? Colors.grey[900]!.withOpacity(0.5) : Colors.grey[50]!,
          ),
          child: Text(
            element.textContent,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
        );
      },
    );
  }
}

/// Builder moderno para títulos
class ModernHeadingBuilder extends MarkdownElementBuilder {
  final int level;

  ModernHeadingBuilder({required this.level});

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        double fontSize;
        FontWeight fontWeight;

        switch (level) {
          case 1:
            fontSize = 28;
            fontWeight = FontWeight.bold;
            break;
          case 2:
            fontSize = 24;
            fontWeight = FontWeight.bold;
            break;
          case 3:
            fontSize = 20;
            fontWeight = FontWeight.w600;
            break;
          case 4:
            fontSize = 18;
            fontWeight = FontWeight.w600;
            break;
          case 5:
            fontSize = 16;
            fontWeight = FontWeight.w600;
            break;
          case 6:
            fontSize = 14;
            fontWeight = FontWeight.w600;
            break;
          default:
            fontSize = 16;
            fontWeight = FontWeight.normal;
        }

        return Container(
          margin: EdgeInsets.only(
            top: level == 1 ? 24 : 20,
            bottom: 12,
          ),
          child: Text(
            element.textContent,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: fontSize,
              fontWeight: fontWeight,
              height: 1.2,
            ),
          ),
        );
      },
    );
  }
}

/// Widget para mostrar preview com toggle entre edit/preview
class MarkdownPreviewToggleWidget extends StatefulWidget {
  final String markdown;
  final bool enableHtmlEnhancements;
  final TextStyle? baseTextStyle;
  final EdgeInsets padding;
  final Color? backgroundColor;

  const MarkdownPreviewToggleWidget({
    super.key,
    required this.markdown,
    this.enableHtmlEnhancements = true,
    this.baseTextStyle,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
  });

  @override
  State<MarkdownPreviewToggleWidget> createState() =>
      _MarkdownPreviewToggleWidgetState();
}

class _MarkdownPreviewToggleWidgetState
    extends State<MarkdownPreviewToggleWidget> {
  bool _isPreviewMode = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _isPreviewMode ? 'Visualização' : 'Edição',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Switch(
                value: _isPreviewMode,
                onChanged: (value) {
                  setState(() {
                    _isPreviewMode = value;
                  });
                },
              ),
            ],
          ),
        ),

        // Content area
        Expanded(
          child: _isPreviewMode
              ? EnhancedMarkdownPreviewWidget(
                  markdown: widget.markdown,
                  enableHtmlEnhancements: widget.enableHtmlEnhancements,
                  baseTextStyle: widget.baseTextStyle,
                  backgroundColor: widget.backgroundColor,
                )
              : _buildEditMode(),
        ),
      ],
    );
  }

  Widget _buildEditMode() {
    return Container(
      padding: widget.padding,
      color: widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        child: Text(
          widget.markdown,
          style: widget.baseTextStyle ?? Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

/// Widget para mostrar exemplos de formatação
class MarkdownFormattingExamplesWidget extends StatelessWidget {
  const MarkdownFormattingExamplesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const examples = '''
# Exemplos de Formatação

## Cores de Texto
<color value="red">Texto vermelho</color>
<color value="blue">Texto azul</color>
<color value="green">Texto verde</color>
<color value="purple">Texto roxo</color>

## Cores de Fundo
<bg color="yellow">Texto com fundo amarelo</bg>
<bg color="lightblue">Texto com fundo azul claro</bg>
<bg color="lightgreen">Texto com fundo verde claro</bg>

## Alinhamento
<align value="left">Texto alinhado à esquerda</align>

<align value="center">Texto centralizado</align>

<align value="right">Texto alinhado à direita</align>

## Combinações
<color value="white"><bg color="red">Texto branco com fundo vermelho</bg></color>

<align value="center"><color value="blue">Texto azul centralizado</color></align>

<bg color="yellow"><align value="right"><color value="black">Texto preto com fundo amarelo alinhado à direita</color></align></bg>

## Markdown Padrão
**Texto em negrito**
*Texto em itálico*
`código inline`

### Lista
- Item 1
- Item 2
- Item 3

### Código
```dart
void main() {
  print('Hello World!');
}
```

### Citação
> Esta é uma citação de exemplo
> com múltiplas linhas
''';

    return EnhancedMarkdownPreviewWidget(
      markdown: examples,
      enableHtmlEnhancements: true,
      padding: const EdgeInsets.all(16.0),
    );
  }
}

class AdvancedCodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final code = element.textContent;
    final language =
        element.attributes['class']?.replaceFirst('language-', '') ?? 'dart';
    return AdvancedCodeBlock(
      code: code,
      language: language,
      showLineNumbers: true,
    );
  }
}

// Builders customizados para <mark>, <kbd>, <sub>, <sup>, <details>, <summary>
class MarkBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.yellow[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        element.textContent,
        style: preferredStyle?.copyWith(backgroundColor: Colors.transparent),
      ),
    );
  }
}

class KbdBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Text(
        element.textContent,
        style: preferredStyle?.copyWith(
          fontFamily: 'monospace',
          fontSize: 13,
          color: Colors.black,
        ),
      ),
    );
  }
}

class SubBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Transform.translate(
      offset: const Offset(0, 4),
      child: Text(
        element.textContent,
        style: preferredStyle?.copyWith(fontSize: 12),
      ),
    );
  }
}

class SupBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Transform.translate(
      offset: const Offset(0, -6),
      child: Text(
        element.textContent,
        style: preferredStyle?.copyWith(fontSize: 12),
      ),
    );
  }
}

class DetailsBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final summary = element.children?.firstWhere(
        (e) => e is md.Element && e.tag == 'summary',
        orElse: () => md.Element.text('summary', ''));
    final content = element.children
            ?.where((e) => e is! md.Element || e.tag != 'summary')
            .toList() ??
        [];
    return ExpansionTile(
      title: Text(summary?.textContent ?? 'Detalhes'),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content.map((e) => Text(e.textContent)).toList(),
          ),
        ),
      ],
    );
  }
}

class SummaryBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Text(
      element.textContent,
      style: preferredStyle?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

// Suporte a LaTeX inline e bloco
class LatexInlineSyntax extends md.InlineSyntax {
  LatexInlineSyntax() : super(r'\$(.+?)\$');
  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('latex-inline', match.group(1)!));
    return true;
  }
}

class LatexBlockSyntax extends md.BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^\${2}([\s\S]+?)\${2}', multiLine: true);
  @override
  md.Node parse(md.BlockParser parser) {
    final currentLine = parser.current.toString();
    final match = pattern.firstMatch(currentLine);
    if (match != null) {
      parser.advance();
      final content = match.group(1)?.toString() ?? '';
      return md.Element.text('latex-block', content);
    }
    // Se não houver match, retornar um elemento vazio
    return md.Element.text('latex-block', '');
  }
}

class LatexBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Math.tex(
      element.textContent,
      textStyle: preferredStyle,
      mathStyle:
          element.tag == 'latex-block' ? MathStyle.display : MathStyle.text,
    );
  }
}

class StyledSpanBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final style = element.attributes['style'] ?? '';
    final text = element.textContent;
    final styleMap = _parseStyle(style);
    final isBlock = element.tag == 'div' || (styleMap['display'] == 'block');
    return Container(
      padding: styleMap['padding'] ??
          const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      margin: styleMap['margin'] ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: styleMap['backgroundColor'],
        borderRadius: styleMap['borderRadius'],
        border: styleMap['borderLeft'] ?? styleMap['border'],
      ),
      alignment: styleMap['alignment'],
      width: styleMap['width'],
      height: styleMap['height'],
      child: Text(
        text,
        style: (preferredStyle ?? const TextStyle()).copyWith(
          color: styleMap['color'],
          fontWeight: styleMap['fontWeight'],
          fontStyle: styleMap['fontStyle'],
          decoration: styleMap['decoration'],
          fontFamily: styleMap['fontFamily'],
          fontSize: styleMap['fontSize'],
        ),
        textAlign: styleMap['textAlign'],
        maxLines: isBlock ? null : 1,
        overflow: isBlock ? TextOverflow.visible : TextOverflow.ellipsis,
        softWrap: true,
      ),
    );
  }

  Map<String, dynamic> _parseStyle(String style) {
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
          if (value.contains('underline'))
            map['decoration'] = TextDecoration.underline;
          if (value.contains('line-through'))
            map['decoration'] = TextDecoration.lineThrough;
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
        case 'border-left':
          map['borderLeft'] = _parseBorderSide(value, left: true);
          break;
        case 'display':
          map['display'] = value;
          break;
        case 'width':
          map['width'] = double.tryParse(value.replaceAll('px', ''));
          break;
        case 'height':
          map['height'] = double.tryParse(value.replaceAll('px', ''));
          break;
        case 'text-align':
          map['textAlign'] = _parseTextAlign(value);
          break;
        case 'align-items':
          map['alignment'] = _parseAlignment(value);
          break;
      }
    }
    return map;
  }

  Color? _parseColor(String value) {
    if (value.startsWith('#')) {
      return Color(int.parse(value.substring(1), radix: 16) + 0xFF000000);
    }
    switch (value) {
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
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'gray':
      case 'grey':
        return Colors.grey;
      default:
        return null;
    }
  }

  EdgeInsets _parseEdgeInsets(String value) {
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

  Border? _parseBorder(String value) {
    // Exemplo: 1px solid #FF0000
    final parts = value.split(' ');
    if (parts.length == 3) {
      final width = double.tryParse(parts[0].replaceAll('px', '')) ?? 1;
      final color = _parseColor(parts[2]);
      return Border.all(color: color ?? Colors.black, width: width);
    }
    return null;
  }

  Border? _parseBorderSide(String value, {bool left = false}) {
    // Exemplo: 4px solid #0277bd
    final parts = value.split(' ');
    if (parts.length == 3) {
      final width = double.tryParse(parts[0].replaceAll('px', '')) ?? 1;
      final color = _parseColor(parts[2]);
      if (left) {
        return Border(
            left: BorderSide(color: color ?? Colors.black, width: width));
      }
    }
    return null;
  }

  TextAlign? _parseTextAlign(String value) {
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

  Alignment? _parseAlignment(String value) {
    switch (value) {
      case 'center':
        return Alignment.center;
      case 'right':
        return Alignment.centerRight;
      case 'left':
        return Alignment.centerLeft;
      case 'top':
        return Alignment.topCenter;
      case 'bottom':
        return Alignment.bottomCenter;
      default:
        return null;
    }
  }
}

class ProgressBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final value = int.tryParse(element.attributes['value'] ?? '0') ?? 0;
    final max = int.tryParse(element.attributes['max'] ?? '100') ?? 100;
    final percent = (value / max).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent,
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: percent < 1.0 ? Colors.blue : Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '${(percent * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MermaidBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final code = element.textContent;
    // Placeholder visual amigável
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.device_hub, color: Colors.cyanAccent, size: 20),
              const SizedBox(width: 8),
              Text('Diagrama Mermaid',
                  style: TextStyle(
                      color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            code,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Visualização real de Mermaid não suportada no Flutter puro. Copie o código acima e visualize em https://mermaid.live ou GitHub.',
            style: TextStyle(
                color: Colors.cyanAccent.withOpacity(0.7), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
