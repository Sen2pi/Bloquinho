import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';

class BloquinhoFormatMenu extends StatefulWidget {
  final Function(String formatType,
      {String? color,
      String? backgroundColor,
      String? alignment}) onFormatApplied;
  final VoidCallback onDismiss;

  const BloquinhoFormatMenu({
    super.key,
    required this.onFormatApplied,
    required this.onDismiss,
  });

  @override
  State<BloquinhoFormatMenu> createState() => _BloquinhoFormatMenuState();
}

class _BloquinhoFormatMenuState extends State<BloquinhoFormatMenu> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: _buildFormatSection(isDarkMode),
      ),
    );
  }

  Widget _buildFormatSection(bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Negrito
        _buildFormatButton(
          icon: Icons.format_bold,
          tooltip: 'Negrito',
          onTap: () => widget.onFormatApplied('bold'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Itálico
        _buildFormatButton(
          icon: Icons.format_italic,
          tooltip: 'Itálico',
          onTap: () => widget.onFormatApplied('italic'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Riscado
        _buildFormatButton(
          icon: Icons.format_strikethrough,
          tooltip: 'Riscado',
          onTap: () => widget.onFormatApplied('strikethrough'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Código
        _buildFormatButton(
          icon: Icons.code,
          tooltip: 'Código',
          onTap: () => widget.onFormatApplied('code'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Sublinhado
        _buildFormatButton(
          icon: Icons.format_underlined,
          tooltip: 'Sublinhado',
          onTap: () => widget.onFormatApplied('underline'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Highlight
        _buildFormatButton(
          icon: Icons.highlight,
          tooltip: 'Destacar',
          onTap: () => widget.onFormatApplied('highlight'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Subscrito
        _buildFormatButton(
          icon: Icons.subscript,
          tooltip: 'Subscrito',
          onTap: () => widget.onFormatApplied('subscript'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Sobrescrito
        _buildFormatButton(
          icon: Icons.superscript,
          tooltip: 'Sobrescrito',
          onTap: () => widget.onFormatApplied('superscript'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Detalhes (expansível)
        _buildFormatButton(
          icon: Icons.unfold_more,
          tooltip: 'Detalhes (expansível)',
          onTap: () => widget.onFormatApplied('details'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Spoiler
        _buildFormatButton(
          icon: Icons.visibility_off,
          tooltip: 'Spoiler',
          onTap: () => widget.onFormatApplied('spoiler'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Badge
        _buildFormatButton(
          icon: Icons.label,
          tooltip: 'Badge',
          onTap: () => widget.onFormatApplied('badge'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Callout
        _buildFormatButton(
          icon: Icons.info_outline,
          tooltip: 'Callout',
          onTap: () => widget.onFormatApplied('callout'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // LaTeX
        _buildFormatButton(
          icon: Icons.functions,
          tooltip: 'Fórmula LaTeX',
          onTap: () => widget.onFormatApplied('latex'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Mermaid
        _buildFormatButton(
          icon: Icons.device_hub,
          tooltip: 'Diagrama Mermaid',
          onTap: () => widget.onFormatApplied('mermaid'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Progresso
        _buildFormatButton(
          icon: Icons.linear_scale,
          tooltip: 'Barra de Progresso',
          onTap: () => widget.onFormatApplied('progress'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Divider
        _buildFormatButton(
          icon: Icons.horizontal_rule,
          tooltip: 'Divisor',
          onTap: () => widget.onFormatApplied('divider'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Cor do texto
        _buildFormatButton(
          icon: Icons.format_color_text,
          tooltip: 'Cor do texto',
          onTap: () => _showColorPicker(context, 'text'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Cor de fundo
        _buildFormatButton(
          icon: Icons.format_color_fill,
          tooltip: 'Cor de fundo',
          onTap: () => _showColorPicker(context, 'background'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Alinhamento
        _buildFormatButton(
          icon: Icons.format_align_left,
          tooltip: 'Alinhamento',
          onTap: () => _showAlignmentPicker(context),
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _buildFormatButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isDarkMode
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, String type) {
    final colors = type == 'text'
        ? [
            'red',
            'blue',
            'green',
            'yellow',
            'purple',
            'orange',
            'pink',
            'brown',
            'grey',
            'black',
            'white'
          ]
        : [
            'bg-red',
            'bg-blue',
            'bg-green',
            'bg-yellow',
            'bg-purple',
            'bg-orange',
            'bg-pink',
            'bg-brown',
            'bg-grey',
            'bg-black',
            'bg-white'
          ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == 'text' ? 'Cor do texto' : 'Cor de fundo'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onFormatApplied(
                      type == 'text' ? 'textColor' : 'backgroundColor',
                      color: color);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _getColorFromName(color),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Center(
                    child: Text(
                      color.replaceAll('bg-', ''),
                      style: TextStyle(
                        color: _getTextColorForBackground(
                            _getColorFromName(color)),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
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

  void _showAlignmentPicker(BuildContext context) {
    final alignments = [
      {'name': 'Esquerda', 'value': 'left', 'icon': Icons.format_align_left},
      {'name': 'Centro', 'value': 'center', 'icon': Icons.format_align_center},
      {'name': 'Direita', 'value': 'right', 'icon': Icons.format_align_right},
      {
        'name': 'Justificado',
        'value': 'justify',
        'icon': Icons.format_align_justify
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alinhamento'),
        content: SizedBox(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: alignments.map((alignment) {
              return ListTile(
                leading: Icon(alignment['icon'] as IconData),
                title: Text(alignment['name'] as String),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onFormatApplied('alignment',
                      alignment: alignment['value'] as String);
                },
              );
            }).toList(),
          ),
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

  Color _getColorFromName(String colorName) {
    final colorMap = {
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
    };
    return colorMap[colorName] ?? Colors.grey;
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    // Retorna branco para fundos escuros, preto para fundos claros
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
