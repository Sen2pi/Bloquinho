import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/html_enhancement_parser.dart';
import 'advanced_code_block.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
        backgroundColor ?? (isDark ? Colors.transparent : Colors.white);

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
        MermaidBlockSyntax(),
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
    const examples = r'''
# 🎨 Exemplos de Formatação Avançada

## 🌈 Cores de Texto e Fundo
<span style="color:red; background-color:#ffeeee; padding:2px 5px; border-radius:3px">**Texto vermelho com fundo claro**</span>
<span style="color:white; background-color:green; padding:3px 8px; border-radius:5px">✅ Sucesso</span>
<span style="color:white; background-color:red; padding:3px 8px; border-radius:5px">❌ Erro</span>
<span style="color:orange; background-color:#fff3cd; padding:3px 8px; border-radius:5px">⚠️ Aviso</span>

## 🔢 Fórmulas Matemáticas (LaTeX)

**Inline:** A famosa equação de Einstein: $E = mc^2$

**Bloco:**
$$
\int_a^b f(x) \, dx = F(b) - F(a)
$$

## 📈 Diagramas (Mermaid)

```mermaid
graph TD
    A[Início] --> B{Login válido?}
    B -->|Sim| C[Dashboard]
    B -->|Não| D[Tela de erro]
```

## 🛠️ Elementos HTML Avançados

### Detalhes Expansíveis
<details>
<summary><strong>Clique para ver os requisitos</strong></summary>

- **Sistema Operacional:** Windows 10+
- **RAM:** 8GB+

</details>

### Teclas e Atalhos
Para salvar, pressione <kbd>Ctrl</kbd> + <kbd>S</kbd>

### Texto Especial
H<sub>2</sub>O e E=mc<sup>2</sup>
<mark>Texto destacado</mark>

### Barra de Progresso
<div style="background-color:#f0f0f0; border-radius:10px; padding:3px; margin:10px 0;">
<div style="background-color:#28a745; width:75%; height:20px; border-radius:8px; display:flex; align-items:center; justify-content:center; color:white; font-weight:bold; font-size:12px;">
75% Completo
</div>
</div>

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
    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Transform.translate(
              offset: const Offset(0.0, 4.0),
              child: Text(
                element.textContent,
                style: (preferredStyle ?? const TextStyle()).copyWith(
                  fontSize: (preferredStyle?.fontSize ?? 16) * 0.75,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SupBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Transform.translate(
              offset: const Offset(0.0, -6.0),
              child: Text(
                element.textContent,
                style: (preferredStyle ?? const TextStyle()).copyWith(
                  fontSize: (preferredStyle?.fontSize ?? 16) * 0.75,
                ),
              ),
            ),
          ),
        ],
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
    return md.Element.text('p', parser.current.content);
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

    // Determine if it's an inline span or a block-level div
    if (isBlock) {
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
          softWrap: true,
        ),
      );
    } else {
      // Inline span
      return RichText(
        text: TextSpan(
          text: text,
          style: (preferredStyle ?? const TextStyle()).copyWith(
            color: styleMap['color'],
            fontWeight: styleMap['fontWeight'],
            fontStyle: styleMap['fontStyle'],
            decoration: styleMap['decoration'],
            fontFamily: styleMap['fontFamily'],
            fontSize: styleMap['fontSize'],
            backgroundColor: styleMap['backgroundColor'],
          ),
        ),
      );
    }
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
    final html = """
      <!DOCTYPE html>
      <html>
        <head>
          <style>
            body {
              background-color: #1E1E1E;
              color: white;
              display: flex;
              justify-content: center;
              align-items: center;
              height: 100vh;
              margin: 0;
            }
          </style>
        </head>
        <body>
          <pre class="mermaid">
            $code
          </pre>
          <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
          <script>mermaid.initialize({startOnLoad:true, theme: 'dark'});</script>
        </body>
      </html>
    """;

    return SizedBox(
      height: 300,
      child:
          WebViewWidget(controller: WebViewController()..loadHtmlString(html)),
    );
  }
}

class MermaidBlockSyntax extends md.BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^```mermaid\n([\s\S]+?)\n```');

  @override
  md.Node parse(md.BlockParser parser) {
    final match = pattern.firstMatch(parser.current.content);
    if (match != null) {
      parser.advance();
      final code = match.group(1)!;
      return md.Element.text('mermaid', code);
    }
    return md.Element.text('p', parser.current.content);
  }
}
