import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dynamic_colored_text.dart';

/// Widget de demonstração para cores dinâmicas
class ColorDemoWidget extends ConsumerStatefulWidget {
  const ColorDemoWidget({super.key});

  @override
  ConsumerState<ColorDemoWidget> createState() => _ColorDemoWidgetState();
}

class _ColorDemoWidgetState extends ConsumerState<ColorDemoWidget> {
  Color _textColor = Colors.black;
  Color _backgroundColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'Demonstração de Cores Dinâmicas',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Texto com cores dinâmicas
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
              'Este texto tem cores que podem ser alteradas dinamicamente!',
              style: TextStyle(
                color: _textColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Controles de cor
          _buildColorControls(),

          const SizedBox(height: 24),

          // Exemplo com o widget DynamicColoredText
          Text(
            'Usando o widget DynamicColoredText:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          DynamicColoredText(
            text:
                'Este é um exemplo usando o widget DynamicColoredText com controles integrados!',
            showControls: true,
            onColorsChanged: (textColor, backgroundColor) {
              print(
                  'Cores alteradas via DynamicColoredText: texto=$textColor, fundo=$backgroundColor');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Controles de Cor',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        // Controle de cor do texto
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cor do texto:'),
                  const SizedBox(height: 4),
                  _buildColorPicker(
                    currentColor: _textColor,
                    onColorChanged: (color) {
                      setState(() {
                        _textColor = color;
                      });
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
                  const Text('Cor de fundo:'),
                  const SizedBox(height: 4),
                  _buildColorPicker(
                    currentColor: _backgroundColor == Colors.transparent
                        ? Colors.grey[200]!
                        : _backgroundColor,
                    onColorChanged: (color) {
                      setState(() {
                        _backgroundColor = color;
                      });
                    },
                    allowTransparent: true,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Cores rápidas
        const Text('Cores rápidas:'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
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
          ].map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _textColor = color;
                });
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
                ? const Icon(
                    Icons.clear,
                    size: 16,
                    color: Colors.grey,
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
                  child: const Icon(
                    Icons.clear,
                    size: 12,
                    color: Colors.grey,
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
