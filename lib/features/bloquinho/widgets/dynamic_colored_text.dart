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
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';

/// Widget para texto com cores dinâmicas usando apenas Flutter
class DynamicColoredText extends ConsumerStatefulWidget {
  final String text;
  final TextStyle? baseStyle;
  final bool showControls;
  final Function(Color textColor, Color backgroundColor)? onColorsChanged;
  final String? textId; // ID único para identificar este texto

  const DynamicColoredText({
    super.key,
    required this.text,
    this.baseStyle,
    this.showControls = true,
    this.onColorsChanged,
    this.textId,
  });

  @override
  ConsumerState<DynamicColoredText> createState() => _DynamicColoredTextState();
}

class _DynamicColoredTextState extends ConsumerState<DynamicColoredText> {
  Color _textColor = Colors.black;
  Color _backgroundColor = Colors.transparent;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _updateThemeColors();
  }

  void _updateThemeColors() {
    final brightness = MediaQuery.of(context).platformBrightness;
    _isDarkMode = brightness == Brightness.dark;

    if (_isDarkMode) {
      _textColor = Colors.white;
    } else {
      _textColor = Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Widget de texto colorido
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _backgroundColor == Colors.transparent
                  ? Colors.grey.withOpacity(0.3)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            widget.text,
            style: (widget.baseStyle ?? const TextStyle()).copyWith(
              color: _textColor,
              fontSize: 16,
            ),
          ),
        ),

        // Controles de cor (se habilitado)
        if (widget.showControls) ...[
          const SizedBox(height: 16),
          _buildColorControls(),
        ],
      ],
    );
  }

  Widget _buildColorControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cores do Texto',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),

        // Controle de cor do texto
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cor do texto:',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isDarkMode ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildColorPicker(
                    currentColor: _textColor,
                    onColorChanged: (color) {
                      setState(() {
                        _textColor = color;
                      });
                      widget.onColorsChanged
                          ?.call(_textColor, _backgroundColor);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cor de fundo:',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isDarkMode ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildColorPicker(
                    currentColor: _backgroundColor == Colors.transparent
                        ? Colors.grey[200]!
                        : _backgroundColor,
                    onColorChanged: (color) {
                      setState(() {
                        _backgroundColor = color;
                      });
                      widget.onColorsChanged
                          ?.call(_textColor, _backgroundColor);
                    },
                    allowTransparent: true,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Botões de ação rápida
        _buildQuickColorButtons(),
      ],
    );
  }

  Widget _buildColorPicker({
    required Color currentColor,
    required Function(Color) onColorChanged,
    bool allowTransparent = false,
  }) {
    return Row(
      children: [
        // Mostrador de cor atual
        GestureDetector(
          onTap: () => _showColorPickerDialog(
              context, currentColor, onColorChanged, allowTransparent),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: currentColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: allowTransparent && currentColor == Colors.grey[200]
                ? Icon(
                    PhosphorIcons.x(),
                    color: Colors.grey[600],
                    size: 16,
                  )
                : null,
          ),
        ),

        const SizedBox(width: 8),

        // Texto da cor
        Expanded(
          child: Text(
            _getColorName(currentColor),
            style: TextStyle(
              fontSize: 12,
              color: _isDarkMode ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickColorButtons() {
    final quickColors = [
      Colors.black,
      Colors.white,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cores rápidas:',
          style: TextStyle(
            fontSize: 12,
            color: _isDarkMode ? Colors.grey[300] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickColors.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _textColor = color;
                });
                widget.onColorsChanged?.call(_textColor, _backgroundColor);
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _textColor == color
                        ? Colors.blue
                        : Colors.grey.withOpacity(0.3),
                    width: _textColor == color ? 2 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showColorPickerDialog(
    BuildContext context,
    Color currentColor,
    Function(Color) onColorChanged,
    bool allowTransparent,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Escolher cor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color picker simples
            Container(
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _getColorPalette().length,
                itemBuilder: (context, index) {
                  final color = _getColorPalette()[index];
                  return GestureDetector(
                    onTap: () {
                      onColorChanged(color);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: currentColor == color
                              ? Colors.blue
                              : Colors.grey.withOpacity(0.3),
                          width: currentColor == color ? 2 : 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (allowTransparent) ...[
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Icon(
                    PhosphorIcons.x(),
                    size: 12,
                    color: Colors.grey[600],
                  ),
                ),
                title: Text('Transparente'),
                onTap: () {
                  onColorChanged(Colors.transparent);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  List<Color> _getColorPalette() {
    return [
      Colors.black,
      Colors.white,
      Colors.red,
      Colors.red[700]!,
      Colors.pink,
      Colors.pink[700]!,
      Colors.purple,
      Colors.purple[700]!,
      Colors.deepPurple,
      Colors.deepPurple[700]!,
      Colors.indigo,
      Colors.indigo[700]!,
      Colors.blue,
      Colors.blue[700]!,
      Colors.lightBlue,
      Colors.lightBlue[700]!,
      Colors.cyan,
      Colors.cyan[700]!,
      Colors.teal,
      Colors.teal[700]!,
      Colors.green,
      Colors.green[700]!,
      Colors.lightGreen,
      Colors.lightGreen[700]!,
      Colors.lime,
      Colors.lime[700]!,
      Colors.yellow,
      Colors.yellow[700]!,
      Colors.amber,
      Colors.amber[700]!,
      Colors.orange,
      Colors.orange[700]!,
      Colors.deepOrange,
      Colors.deepOrange[700]!,
      Colors.brown,
      Colors.brown[700]!,
      Colors.grey,
      Colors.grey[700]!,
      Colors.blueGrey,
      Colors.blueGrey[700]!,
    ];
  }

  String _getColorName(Color color) {
    if (color == Colors.transparent) return 'Transparente';
    if (color == Colors.black) return 'Preto';
    if (color == Colors.white) return 'Branco';
    if (color == Colors.red) return 'Vermelho';
    if (color == Colors.green) return 'Verde';
    if (color == Colors.blue) return 'Azul';
    if (color == Colors.yellow) return 'Amarelo';
    if (color == Colors.orange) return 'Laranja';
    if (color == Colors.purple) return 'Roxo';
    if (color == Colors.pink) return 'Rosa';
    if (color == Colors.teal) return 'Verde-azulado';
    if (color == Colors.cyan) return 'Ciano';
    if (color == Colors.indigo) return 'Índigo';
    if (color == Colors.brown) return 'Marrom';
    if (color == Colors.grey) return 'Cinza';
    if (color == Colors.blueGrey) return 'Azul-cinza';

    return 'RGB(${color.red}, ${color.green}, ${color.blue})';
  }
}

/// Provider para gerenciar cores de texto dinâmicas
class DynamicTextColorsNotifier
    extends StateNotifier<Map<String, Map<String, Color>>> {
  DynamicTextColorsNotifier() : super({});

  void setTextColor(String textId, Color color) {
    final colors = state[textId] ?? {};
    colors['text'] = color;
    state = {...state, textId: colors};
  }

  void setBackgroundColor(String textId, Color color) {
    final colors = state[textId] ?? {};
    colors['background'] = color;
    state = {...state, textId: colors};
  }

  Color getTextColor(String textId) {
    return state[textId]?['text'] ?? Colors.black;
  }

  Color getBackgroundColor(String textId) {
    return state[textId]?['background'] ?? Colors.transparent;
  }

  Map<String, Color> getTextColors(String textId) {
    return state[textId] ?? {};
  }
}

final dynamicTextColorsProvider = StateNotifierProvider<
    DynamicTextColorsNotifier, Map<String, Map<String, Color>>>((ref) {
  return DynamicTextColorsNotifier();
});

/// Widget para texto com cores dinâmicas usando provider
class DynamicColoredTextWithProvider extends ConsumerWidget {
  final String text;
  final String textId;
  final TextStyle? baseStyle;
  final bool showControls;

  const DynamicColoredTextWithProvider({
    super.key,
    required this.text,
    required this.textId,
    this.baseStyle,
    this.showControls = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColors = ref.watch(dynamicTextColorsProvider);
    final colors = textColors[textId] ?? {};
    // Usar cor do provider, senão do estilo base, senão preto/transparente
    final textColor = colors['text'] ?? baseStyle?.color ?? Colors.black;
    final backgroundColor = colors['background'] ??
        baseStyle?.backgroundColor ??
        Colors.transparent;

    // PRESERVAR formatação original do texto (negrito, itálico, etc.)
    // Combinar estilo base com cor, MANTENDO fontWeight/fontStyle/decoration
    final effectiveStyle = (baseStyle ?? const TextStyle()).copyWith(
      color: textColor,
      backgroundColor:
          null, // Não usar backgroundColor do TextStyle, só do Container
      // MANTER formatação original:
      fontWeight: baseStyle?.fontWeight,
      fontStyle: baseStyle?.fontStyle,
      decoration: baseStyle?.decoration,
      decorationColor: baseStyle?.decorationColor,
      decorationStyle: baseStyle?.decorationStyle,
      decorationThickness: baseStyle?.decorationThickness,
      fontFamily: baseStyle?.fontFamily,
      fontSize: baseStyle?.fontSize,
      letterSpacing: baseStyle?.letterSpacing,
      wordSpacing: baseStyle?.wordSpacing,
      height: baseStyle?.height,
      leadingDistribution: baseStyle?.leadingDistribution,
      locale: baseStyle?.locale,
      shadows: baseStyle?.shadows,
      foreground: baseStyle?.foreground,
      background: baseStyle?.background,
    );

    final textWidget = Text(
      text,
      style: effectiveStyle,
    );

    // Só usar Container se houver cor de fundo
    final hasBackground =
        backgroundColor != null && backgroundColor != Colors.transparent;

    return Column(
      children: [
        hasBackground
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.15),
                  ),
                ),
                child: textWidget,
              )
            : textWidget,
        // Controles de cor (se habilitado)
        if (showControls) ...[
          const SizedBox(height: 16),
          _buildColorControls(
            context: context,
            ref: ref,
            textColor: textColor,
            backgroundColor: backgroundColor,
          ),
        ],
      ],
    );
  }

  Widget _buildColorControls({
    required BuildContext context,
    required WidgetRef ref,
    required Color textColor,
    required Color backgroundColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cores do Texto',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // Controle de cor do texto
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cor do texto:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  _buildColorPicker(
                    currentColor: textColor,
                    onColorChanged: (color) {
                      ref
                          .read(dynamicTextColorsProvider.notifier)
                          .setTextColor(textId, color);
                    },
                    context: context,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cor de fundo:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  _buildColorPicker(
                    currentColor: backgroundColor == Colors.transparent
                        ? Colors.grey[200]!
                        : backgroundColor,
                    onColorChanged: (color) {
                      ref
                          .read(dynamicTextColorsProvider.notifier)
                          .setBackgroundColor(textId, color);
                    },
                    allowTransparent: true,
                    context: context,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorPicker({
    required Color currentColor,
    required Function(Color) onColorChanged,
    bool allowTransparent = false,
    BuildContext? context,
  }) {
    return Row(
      children: [
        // Mostrador de cor atual
        GestureDetector(
          onTap: () => _showColorPickerDialog(
              context!, currentColor, onColorChanged, allowTransparent),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: currentColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: allowTransparent && currentColor == Colors.grey[200]
                ? Icon(
                    PhosphorIcons.x(),
                    color: Colors.grey[600],
                    size: 16,
                  )
                : null,
          ),
        ),

        const SizedBox(width: 8),

        // Texto da cor
        Expanded(
          child: Text(
            _getColorName(currentColor),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  void _showColorPickerDialog(
    BuildContext context,
    Color currentColor,
    Function(Color) onColorChanged,
    bool allowTransparent,
  ) {
    final quickColors = [
      Colors.black,
      Colors.white,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher cor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cores rápidas
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: quickColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    onColorChanged(color);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: currentColor == color
                            ? Colors.blue
                            : Colors.grey.withOpacity(0.3),
                        width: currentColor == color ? 2 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            if (allowTransparent) ...[
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Icon(
                    PhosphorIcons.x(),
                    size: 12,
                    color: Colors.grey[600],
                  ),
                ),
                title: const Text('Transparente'),
                onTap: () {
                  onColorChanged(Colors.transparent);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  String _getColorName(Color color) {
    if (color == Colors.transparent) return 'Transparente';
    if (color == Colors.black) return 'Preto';
    if (color == Colors.white) return 'Branco';
    if (color == Colors.red) return 'Vermelho';
    if (color == Colors.green) return 'Verde';
    if (color == Colors.blue) return 'Azul';
    if (color == Colors.yellow) return 'Amarelo';
    if (color == Colors.orange) return 'Laranja';
    if (color == Colors.purple) return 'Roxo';
    if (color == Colors.pink) return 'Rosa';
    if (color == Colors.teal) return 'Verde-azulado';

    return 'RGB(${color.red}, ${color.green}, ${color.blue})';
  }
}
