

/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:bloquinho/features/bloquinho/widgets/enhanced_markdown_preview_widget.dart';

class MarkdownWidgetBuilderService {
  final WidgetRef ref;

  MarkdownWidgetBuilderService(this.ref);

  List<Widget> buildWidgets(String markdown, BuildContext context) {
    final List<Widget> widgets = [];
    final lines = markdown.split('\n');

    for (final line in lines) {
      final List<md.Node> nodes = md.Document().parseInline(line);
      for (final node in nodes) {
        widgets.add(_buildWidgetFromNode(node, context));
      }
    }

    return widgets;
  }

  Widget _buildWidgetFromNode(md.Node node, BuildContext context) {
    if (node is md.Element) {
      switch (node.tag) {
        case 'h1':
          return ModernHeadingBuilder(level: 1).visitElementAfter(node, Theme.of(context).textTheme.headlineLarge);
        case 'h2':
          return ModernHeadingBuilder(level: 2).visitElementAfter(node, Theme.of(context).textTheme.headlineMedium);
        case 'h3':
          return ModernHeadingBuilder(level: 3).visitElementAfter(node, Theme.of(context).textTheme.headlineSmall);
        case 'h4':
          return ModernHeadingBuilder(level: 4).visitElementAfter(node, Theme.of(context).textTheme.titleLarge);
        case 'h5':
          return ModernHeadingBuilder(level: 5).visitElementAfter(node, Theme.of(context).textTheme.titleMedium);
        case 'h6':
          return ModernHeadingBuilder(level: 6).visitElementAfter(node, Theme.of(context).textTheme.titleSmall);
        case 'p':
          return Text(node.textContent);
        case 'code':
          return AdvancedCodeBlockBuilder().visitElementAfter(node, null);
        case 'blockquote':
          return ModernBlockquoteBuilder().visitElementAfter(node, null);
        case 'li':
          return ModernListItemBuilder().visitElementAfter(node, null);
        case 'table':
          return ModernTableBuilder().visitElementAfter(node, null);
        case 'span':
          return SpanBuilder(ref: ref).visitElementAfter(node, null);
        case 'div':
          return DynamicColoredDivBuilder(ref: ref).visitElementAfter(node, null);
        case 'progress':
          return ProgressBuilder().visitElementAfter(node, null);
        case 'mermaid':
          return MermaidBuilder().visitElementAfter(node, null);
        case 'latex-inline':
        case 'latex-block':
          return LatexBuilder().visitElementAfter(node, null);
        default:
          return Text(node.textContent);
      }
    } else if (node is md.Text) {
      return Text(node.text);
    }
    return const SizedBox.shrink();
  }
}

