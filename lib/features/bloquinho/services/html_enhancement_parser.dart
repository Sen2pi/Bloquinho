/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';

/// Parser especializado para enhancements HTML em markdown
class HtmlEnhancementParser {
  // Cores de texto disponíveis
  static final Map<String, Color> textColors = {
    'red': Colors.red,
    'blue': Colors.blue,
    'green': Colors.green,
    'yellow': Colors.yellow,
    'purple': Colors.purple,
    'orange': Colors.orange,
    'pink': Colors.pink,
    'brown': Colors.brown,
    'grey': Colors.grey,
    'black': Colors.black,
    'white': Colors.white,
    'cyan': Colors.cyan,
    'teal': Colors.teal,
    'indigo': Colors.indigo,
    'lime': Colors.lime,
    'amber': Colors.amber,
    'deeporange': Colors.deepOrange,
    'lightblue': Colors.lightBlue,
    'lightgreen': Colors.lightGreen,
    'lightpink': Colors.pink.shade200,
  };

  // Cores de fundo disponíveis
  static final Map<String, Color> backgroundColorColors = {
    'bg-red': Colors.red,
    'bg-blue': Colors.blue,
    'bg-green': Colors.green,
    'bg-yellow': Colors.yellow,
    'bg-purple': Colors.purple,
    'bg-orange': Colors.orange,
    'bg-pink': Colors.pink,
    'bg-brown': Colors.brown,
    'bg-grey': Colors.grey,
    'bg-black': Colors.black,
    'bg-white': Colors.white,
    'bg-cyan': Colors.cyan,
    'bg-teal': Colors.teal,
    'bg-indigo': Colors.indigo,
    'bg-lime': Colors.lime,
    'bg-amber': Colors.amber,
    'bg-deeporange': Colors.deepOrange,
    'bg-lightblue': Colors.lightBlue,
    'bg-lightgreen': Colors.lightGreen,
    'bg-lightpink': Colors.pink.shade200,
    'bg-lightyellow': Colors.yellow.shade100,
    'bg-lightgrey': Colors.grey.shade200,
  };

  // Alinhamentos disponíveis
  static const Map<String, TextAlign> alignments = {
    'left': TextAlign.left,
    'right': TextAlign.right,
    'center': TextAlign.center,
    'justify': TextAlign.justify,
  };

  /// Processa o conteúdo markdown com enhancements HTML
  static String processWithEnhancements(String content) {
    // Proteger blocos LaTeX ($$ ... $$) e Mermaid (```mermaid ... ```) para não serem processados
    final protectedBlocks = <String>[];
    content = content.replaceAllMapped(
      RegExp(r'\$\$([\s\S]+?)\$\$|```mermaid([\s\S]+?)```', multiLine: true),
      (match) {
        protectedBlocks.add(match.group(0)!);
        return '<<PROTECTED_BLOCK_${protectedBlocks.length - 1}>>';
      },
    );

    // Processar spans com estilos complexos
    content = _processComplexSpans(content);
    // Processar cores de texto
    content = _processTextColors(content);
    // Processar cores de fundo
    content = _processBackgroundColors(content);
    // Processar alinhamentos
    content = _processAlignments(content);
    // Processar combinações aninhadas
    content = _processNestedTags(content);

    // Restaurar blocos protegidos
    for (var i = 0; i < protectedBlocks.length; i++) {
      content = content.replaceAll('<<PROTECTED_BLOCK_$i>>', protectedBlocks[i]);
    }
    return content;
  }

  /// Processa spans com estilos complexos (como badges, progress bars, etc.)
  static String _processComplexSpans(String content) {
    // Processar spans com estilos inline complexos
    return content.replaceAllMapped(
      RegExp(r'<span\s+style="([^"]+)">((?:(?!</span>).)*)</span>', multiLine: true),
      (match) {
        final style = match.group(1)!;
        final text = match.group(2)!;

        // Extrair propriedades CSS
        final properties = _parseCssProperties(style);

        // Gerar HTML otimizado para Flutter
        return _generateStyledSpan(text, properties);
      },
    );
  }

  /// Parse propriedades CSS
  static Map<String, String> _parseCssProperties(String css) {
    final properties = <String, String>{};
    final pairs = css.split(';');

    for (final pair in pairs) {
      final colonIndex = pair.indexOf(':');
      if (colonIndex > 0) {
        final property = pair.substring(0, colonIndex).trim();
        final value = pair.substring(colonIndex + 1).trim();
        properties[property] = value;
      }
    }

    return properties;
  }

  /// Gera span estilizado para Flutter
  static String _generateStyledSpan(
      String text, Map<String, String> properties) {
    final styleAttributes = <String>[];

    // Cor do texto
    if (properties.containsKey('color')) {
      final color = properties['color']!;
      if (color.startsWith('#')) {
        styleAttributes.add('color: $color');
      }
    }

    // Cor de fundo
    if (properties.containsKey('background-color')) {
      final bgColor = properties['background-color']!;
      if (bgColor.startsWith('#')) {
        styleAttributes.add('background-color: $bgColor');
      }
    }

    // Padding
    if (properties.containsKey('padding')) {
      styleAttributes.add('padding: ${properties['padding']}');
    }

    // Border radius
    if (properties.containsKey('border-radius')) {
      styleAttributes.add('border-radius: ${properties['border-radius']}');
    }

    // Font weight
    if (properties.containsKey('font-weight')) {
      styleAttributes.add('font-weight: ${properties['font-weight']}');
    }

    // Font family
    if (properties.containsKey('font-family')) {
      styleAttributes.add('font-family: ${properties['font-family']}');
    }

    // Text decoration
    if (properties.containsKey('text-decoration')) {
      styleAttributes.add('text-decoration: ${properties['text-decoration']}');
    }

    // Border
    if (properties.containsKey('border')) {
      styleAttributes.add('border: ${properties['border']}');
    }

    // Display
    if (properties.containsKey('display')) {
      styleAttributes.add('display: ${properties['display']}');
    }

    // Margin
    if (properties.containsKey('margin')) {
      styleAttributes.add('margin: ${properties['margin']}');
    }

    // Width
    if (properties.containsKey('width')) {
      styleAttributes.add('width: ${properties['width']}');
    }

    // Height
    if (properties.containsKey('height')) {
      styleAttributes.add('height: ${properties['height']}');
    }

    // Align items
    if (properties.containsKey('align-items')) {
      styleAttributes.add('align-items: ${properties['align-items']}');
    }

    // Justify content
    if (properties.containsKey('justify-content')) {
      styleAttributes.add('justify-content: ${properties['justify-content']}');
    }

    // Flex
    if (properties.containsKey('flex')) {
      styleAttributes.add('flex: ${properties['flex']}');
    }

    // Blur radius
    if (properties.containsKey('blur-radius')) {
      styleAttributes.add('blur-radius: ${properties['blur-radius']}');
    }

    // Offset
    if (properties.containsKey('offset')) {
      styleAttributes.add('offset: ${properties['offset']}');
    }

    // Box shadow
    if (properties.containsKey('box-shadow')) {
      styleAttributes.add('box-shadow: ${properties['box-shadow']}');
    }

    final styleString = styleAttributes.join('; ');
    return '<span style="$styleString">$text</span>';
  }

  /// Converte nome de cor para hex
  static String? _colorNameToHex(String colorName) {
    final colorMap = {
      'red': '#FF0000',
      'blue': '#0000FF',
      'green': '#00FF00',
      'yellow': '#FFFF00',
      'purple': '#800080',
      'orange': '#FFA500',
      'pink': '#FFC0CB',
      'brown': '#A52A2A',
      'grey': '#808080',
      'gray': '#808080',
      'black': '#000000',
      'white': '#FFFFFF',
      'cyan': '#00FFFF',
      'teal': '#008080',
      'indigo': '#4B0082',
      'lime': '#00FF00',
      'amber': '#FFBF00',
      'deeporange': '#FF5722',
      'lightblue': '#ADD8E6',
      'lightgreen': '#90EE90',
      'lightpink': '#FFB6C1',
      'lightyellow': '#FFFFE0',
      'lightgrey': '#D3D3D3',
      'lightgray': '#D3D3D3',
    };

    return colorMap[colorName.toLowerCase()];
  }

  /// Processa cores de texto
  static String _processTextColors(String content) {
    return content.replaceAllMapped(
      HtmlInlineParser.colorRegex,
      (match) {
        final colorName = match.group(1)!.toLowerCase();
        final text = match.group(2)!;
        final color = textColors[colorName];

        if (color != null) {
          return '<bloquinho-color value="$colorName">$text</bloquinho-color>';
        }
        return match.group(0)!;
      },
    );
  }

  /// Processa cores de fundo
  static String _processBackgroundColors(String content) {
    return content.replaceAllMapped(
      HtmlInlineParser.bgColorRegex,
      (match) {
        final colorName = match.group(1)!.toLowerCase();
        final text = match.group(2)!;
        final color = backgroundColorColors[colorName];

        if (color != null) {
          return '<bloquinho-bg color="$colorName">$text</bloquinho-bg>';
        }
        return match.group(0)!;
      },
    );
  }

  /// Processa alinhamentos
  static String _processAlignments(String content) {
    return content.replaceAllMapped(
      HtmlInlineParser.alignRegex,
      (match) {
        final alignValue = match.group(1)!.toLowerCase();
        final text = match.group(2)!;
        final alignment = alignments[alignValue];

        if (alignment != null) {
          return '<div style="text-align: $alignValue">$text</div>';
        }
        return match.group(0)!;
      },
    );
  }

  /// Processa tags aninhadas (combinações)
  static String _processNestedTags(String content) {
    // Processar múltiplas vezes para garantir que todas as combinações sejam processadas
    String processedContent = content;
    int iterations = 0;
    const maxIterations = 10; // Evitar loop infinito

    while (iterations < maxIterations) {
      final beforeProcessing = processedContent;

      // Processar cores aninhadas
      processedContent = _processNestedColors(processedContent);

      // Processar backgrounds aninhados
      processedContent = _processNestedBackgrounds(processedContent);

      // Se não houve mudanças, parar
      if (processedContent == beforeProcessing) {
        break;
      }

      iterations++;
    }

    return processedContent;
  }

  /// Processa cores aninhadas
  static String _processNestedColors(String content) {
    return content.replaceAllMapped(
      RegExp(
          r'<color\s+value="([^"]+)">([^<]*(?:<[^>]*>[^<]*</[^>]*>[^<]*)*)</color>',
          multiLine: true),
      (match) {
        final colorName = match.group(1)!.toLowerCase();
        final text = match.group(2)!;
        final color = textColors[colorName];

        if (color != null) {
          return '<span style="color: #${_colorToHex(color)}">$text</span>';
        }
        return match.group(0)!;
      },
    );
  }

  /// Processa backgrounds aninhados
  static String _processNestedBackgrounds(String content) {
    return content.replaceAllMapped(
      RegExp(
          r'<bg\s+color="([^"]+)">([^<]*(?:<[^>]*>[^<]*</[^>]*>[^<]*)*)</bg>',
          multiLine: true),
      (match) {
        final colorName = match.group(1)!.toLowerCase();
        final text = match.group(2)!;
        final color = backgroundColorColors[colorName];

        if (color != null) {
          return '<span style="background-color: #${_colorToHex(color)}">$text</span>';
        }
        return match.group(0)!;
      },
    );
  }

  /// Valida se uma cor existe
  static bool isValidTextColor(String colorName) {
    return textColors.containsKey(colorName.toLowerCase());
  }

  /// Valida se uma cor de fundo existe
  static bool isValidBackgroundColor(String colorName) {
    return backgroundColorColors.containsKey(colorName.toLowerCase());
  }

  /// Valida se um alinhamento existe
  static bool isValidAlignment(String alignment) {
    return alignments.containsKey(alignment.toLowerCase());
  }

  /// Obtém lista de cores de texto disponíveis
  static List<String> getAvailableTextColors() {
    return textColors.keys.toList();
  }

  /// Obtém lista de cores de fundo disponíveis
  static List<String> getAvailableBackgroundColors() {
    return backgroundColorColors.keys.toList();
  }

  /// Obtém lista de alinhamentos disponíveis
  static List<String> getAvailableAlignments() {
    return alignments.keys.toList();
  }

  static String _colorToHex(Color color) {
    // Retorna apenas os 6 dígitos RGB, ignorando alpha
    return color.value.toRadixString(16).padLeft(8, '0').substring(2);
  }
}

/// Parser para tags HTML inline
class HtmlInlineParser {
  // Regex para detectar tags HTML inline
  static final RegExp htmlTagRegex = RegExp(
    r'<([^>]+)>([^<]*)</\1>',
    multiLine: true,
  );

  // Regex para cores de texto
  static final RegExp colorRegex = RegExp(
    r'<color\s+value="([^"]+)">((?:(?!</color>).)*)</color>',
    multiLine: true,
  );

  // Regex para cores de fundo
  static final RegExp bgColorRegex = RegExp(
    r'<bg\s+color="([^"]+)">((?:(?!</bg>).)*)</bg>',
    multiLine: true,
  );

  // Regex para alinhamento
  static final RegExp alignRegex = RegExp(
    r'<align\s+value="([^"]+)">((?:(?!</align>).)*)</align>',
    multiLine: true,
  );
}
