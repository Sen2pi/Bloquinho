import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';

/// Widget para texto com cores dinâmicas
class ColoredTextWidget extends ConsumerStatefulWidget {
  final String text;
  final TextStyle? baseStyle;
  final bool showColorPicker;
  final Function(Color textColor, Color backgroundColor)? onColorsChanged;

  const ColoredTextWidget({
    super.key,
    required this.text,
    this.baseStyle,
    this.showColorPicker = true,
    this.onColorsChanged,
  });

  @override
  ConsumerState<ColoredTextWidget> createState() => _ColoredTextWidgetState();
}

class _ColoredTextWidgetState extends ConsumerState<ColoredTextWidget> {
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
        if (widget.showColorPicker) ...[
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
              currentColor, onColorChanged, allowTransparent),
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

/// Provider para gerenciar cores de texto
class TextColorsNotifier extends StateNotifier<Map<String, Color>> {
  TextColorsNotifier() : super({});

  void setTextColor(String textId, Color color) {
    state = {...state, 'text_$textId': color};
  }

  void setBackgroundColor(String textId, Color color) {
    state = {...state, 'bg_$textId': color};
  }

  Color getTextColor(String textId) {
    return state['text_$textId'] ?? Colors.black;
  }

  Color getBackgroundColor(String textId) {
    return state['bg_$textId'] ?? Colors.transparent;
  }
}

final textColorsProvider =
    StateNotifierProvider<TextColorsNotifier, Map<String, Color>>((ref) {
  return TextColorsNotifier();
});
