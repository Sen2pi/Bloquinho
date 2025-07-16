/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import 'mermaid_diagram_widget.dart'; // Adicionar import para MermaidTemplates
import 'latex_widget.dart'; // Adicionar import para LaTeXWidget

class BloquinhoFormatMenu extends StatefulWidget {
  final Function(String formatType,
      {String? color,
      String? backgroundColor,
      String? alignment,
      String? content}) onFormatApplied;
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

        // Badge
        _buildFormatButton(
          icon: Icons.label,
          tooltip: 'Badge',
          onTap: () => widget.onFormatApplied('badge'),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // LaTeX
        _buildFormatButton(
          icon: Icons.functions,
          tooltip: 'Fórmula LaTeX',
          onTap: () => _showLatexDialog(context),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Matrizes
        _buildFormatButton(
          icon: Icons.grid_on,
          tooltip: 'Matrizes',
          onTap: () => _showMatrixDialog(context),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Mermaid
        _buildFormatButton(
          icon: Icons.device_hub,
          tooltip: 'Diagrama Mermaid',
          onTap: () => _showMermaidDialog(context),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(width: 4),

        // Barra de Progresso
        _buildFormatButton(
          icon: Icons.linear_scale,
          tooltip: 'Barra de Progresso',
          onTap: () => widget.onFormatApplied('progress'),
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

        // Cor combinada (texto + fundo)
        _buildFormatButton(
          icon: Icons.palette,
          tooltip: 'Cor combinada (texto + fundo)',
          onTap: () => _showCombinedColorPicker(context),
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
            '#FF0000', // red
            '#0000FF', // blue
            '#00FF00', // green
            '#FFFF00', // yellow
            '#800080', // purple
            '#FFA500', // orange
            '#FFC0CB', // pink
            '#A52A2A', // brown
            '#808080', // grey
            '#000000', // black
            '#FFFFFF', // white
            '#FF69B4', // hotpink
            '#4B0082', // indigo
            '#008080', // teal
            '#FFD700', // gold
            '#DC143C', // crimson
          ]
        : [
            '#FF0000', // red
            '#0000FF', // blue
            '#00FF00', // green
            '#FFFF00', // yellow
            '#800080', // purple
            '#FFA500', // orange
            '#FFC0CB', // pink
            '#A52A2A', // brown
            '#808080', // grey
            '#000000', // black
            '#FFFFFF', // white
            '#FF69B4', // hotpink
            '#4B0082', // indigo
            '#008080', // teal
            '#FFD700', // gold
            '#DC143C', // crimson
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
              final colorValue = _getColorFromName(color);
              return InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onFormatApplied(
                      type == 'text' ? 'textColor' : 'backgroundColor',
                      color: type == 'text' ? color : null,
                      backgroundColor: type == 'background' ? color : null);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: type == 'text' ? null : colorValue,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: type == 'text'
                            ? colorValue
                            : _getTextColorForBackground(colorValue),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        backgroundColor: type == 'text' ? null : colorValue,
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

  void _showCombinedColorPicker(BuildContext context) {
    // Combinações otimizadas: cores escuras com fundos claros e vice-versa
    final colorCombinations = [
      // Escuro sobre claro
      {'text': '#000000', 'bg': '#FFFFFF', 'name': 'Preto / Branco', 'example': 'Aa'},
      {'text': '#1a1a1a', 'bg': '#f8f9fa', 'name': 'Carvão / Cinza Claro', 'example': 'Aa'},
      {'text': '#2c3e50', 'bg': '#ecf0f1', 'name': 'Azul Escuro / Cinza Pérola', 'example': 'Aa'},
      {'text': '#8b0000', 'bg': '#ffe6e6', 'name': 'Vermelho Escuro / Rosa Claro', 'example': 'Aa'},
      {'text': '#4a5568', 'bg': '#f7fafc', 'name': 'Ardósia / Azul Muito Claro', 'example': 'Aa'},
      {'text': '#2d3748', 'bg': '#edf2f7', 'name': 'Cinza Escuro / Cinza Gelo', 'example': 'Aa'},
      {'text': '#744210', 'bg': '#fffaf0', 'name': 'Marrom Escuro / Bege Claro', 'example': 'Aa'},
      {'text': '#0d5415', 'bg': '#f0fff4', 'name': 'Verde Escuro / Verde Muito Claro', 'example': 'Aa'},
      
      // Claro sobre escuro
      {'text': '#FFFFFF', 'bg': '#000000', 'name': 'Branco / Preto', 'example': 'Aa'},
      {'text': '#f8f9fa', 'bg': '#2c3e50', 'name': 'Cinza Claro / Azul Escuro', 'example': 'Aa'},
      {'text': '#ffffff', 'bg': '#1a365d', 'name': 'Branco / Azul Marinho', 'example': 'Aa'},
      {'text': '#f7fafc', 'bg': '#2d3748', 'name': 'Azul Muito Claro / Cinza Escuro', 'example': 'Aa'},
      {'text': '#fff5f5', 'bg': '#742a2a', 'name': 'Rosa Claro / Vermelho Escuro', 'example': 'Aa'},
      {'text': '#f0fff4', 'bg': '#22543d', 'name': 'Verde Muito Claro / Verde Escuro', 'example': 'Aa'},
      {'text': '#fffaf0', 'bg': '#744210', 'name': 'Bege Claro / Marrom Escuro', 'example': 'Aa'},
      {'text': '#faf5ff', 'bg': '#553c9a', 'name': 'Roxo Claro / Roxo Escuro', 'example': 'Aa'},
      
      // Combinações vibrantes
      {'text': '#ffffff', 'bg': '#e53e3e', 'name': 'Branco / Vermelho', 'example': '⚠️'},
      {'text': '#ffffff', 'bg': '#38a169', 'name': 'Branco / Verde', 'example': '✅'},
      {'text': '#ffffff', 'bg': '#3182ce', 'name': 'Branco / Azul', 'example': 'ℹ️'},
      {'text': '#ffffff', 'bg': '#d69e2e', 'name': 'Branco / Amarelo Escuro', 'example': '⚡'},
      {'text': '#ffffff', 'bg': '#805ad5', 'name': 'Branco / Roxo', 'example': '🔮'},
      {'text': '#ffffff', 'bg': '#dd6b20', 'name': 'Branco / Laranja', 'example': '🔥'},
      
      // Pastéis profissionais
      {'text': '#2d3748', 'bg': '#bee3f8', 'name': 'Escuro / Azul Pastel', 'example': 'Info'},
      {'text': '#2d3748', 'bg': '#c6f6d5', 'name': 'Escuro / Verde Pastel', 'example': 'OK'},
      {'text': '#2d3748', 'bg': '#fed7d7', 'name': 'Escuro / Rosa Pastel', 'example': 'Alert'},
      {'text': '#2d3748', 'bg': '#fef5e7', 'name': 'Escuro / Amarelo Pastel', 'example': 'Note'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎨 Combinações de Cores'),
        content: SizedBox(
          width: 400,
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Escolha uma combinação otimizada de texto + fundo:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: colorCombinations.length,
                  itemBuilder: (context, index) {
                    final combo = colorCombinations[index];
                    final textColor = _getColorFromName(combo['text']!);
                    final bgColor = _getColorFromName(combo['bg']!);
                    
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onFormatApplied(
                          'span',
                          content: '<span style="background-color:${combo['bg']}; color:${combo['text']}">TEXTO_SELECIONADO</span>',
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Exemplo visual grande
                              Text(
                                combo['example']!,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Nome da combinação
                              Text(
                                combo['name']!,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Informação adicional
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Combinações otimizadas para máximo contraste e legibilidade',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    // Se for um código hexadecimal, processar diretamente
    if (colorName.startsWith('#')) {
      try {
        return Color(int.parse(colorName.substring(1), radix: 16) + 0xFF000000);
      } catch (e) {
        return Colors.grey;
      }
    }
    
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

  /// Converte uma cor em formato hexadecimal
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  void _showLatexDialog(BuildContext context) {
    final TextEditingController latexController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fórmula LaTeX'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: Column(
            children: [
              TextField(
                controller: latexController,
                decoration: const InputDecoration(
                  labelText: 'Digite sua fórmula LaTeX',
                  hintText: 'Ex: \\frac{a}{b} ou E = mc^2',
                ),
                maxLines: 3,
                onSubmitted: (value) {
                  Navigator.of(context).pop();
                  if (value.isNotEmpty) {
                    widget.onFormatApplied('latex', content: value);
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text('Exemplos rápidos:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickLaTeXButton('Fração', '\\frac{a}{b}'),
                  _buildQuickLaTeXButton('Raiz', '\\sqrt{x}'),
                  _buildQuickLaTeXButton('Potência', 'x^n'),
                  _buildQuickLaTeXButton('Integral', '\\int_{a}^{b} f(x) dx'),
                  _buildQuickLaTeXButton('Soma', '\\sum_{i=1}^{n} x_i'),
                  _buildQuickLaTeXButton('Limite', '\\lim_{x \\to \\infty}'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final latexContent = latexController.text.trim();
              if (latexContent.isNotEmpty) {
                Navigator.of(context).pop();
                // Usar formato $ simples (funciona melhor)
                final finalContent = '\$$latexContent\$';
                widget.onFormatApplied('latex', content: finalContent);
              }
            },
            child: const Text('Inserir'),
          ),
        ],
      ),
    );
  }

  void _showMatrixDialog(BuildContext context) {
    final matrixTypes = [
      {'name': 'Matriz 2x2', 'template': 'matrix-2x2', 'icon': Icons.grid_on},
      {'name': 'Matriz 3x3', 'template': 'matrix-3x3', 'icon': Icons.grid_on},
      {'name': 'Matriz 4x4', 'template': 'matrix-4x4', 'icon': Icons.grid_on},
      {
        'name': 'Determinante 2x2',
        'template': 'determinant-2x2',
        'icon': Icons.calculate
      },
      {
        'name': 'Determinante 3x3',
        'template': 'determinant-3x3',
        'icon': Icons.calculate
      },
      {
        'name': 'Sistema 2x2',
        'template': 'system-2x2',
        'icon': Icons.system_update
      },
      {
        'name': 'Sistema 3x3',
        'template': 'system-3x3',
        'icon': Icons.system_update
      },
      {'name': 'Vetor', 'template': 'vector', 'icon': Icons.arrow_upward},
      {
        'name': 'Matriz com colchetes',
        'template': 'matrix-brackets',
        'icon': Icons.grid_on
      },
      {
        'name': 'Matriz com chaves',
        'template': 'matrix-braces',
        'icon': Icons.grid_on
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Matriz'),
        content: SizedBox(
          width: 350,
          height: 400,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.5,
            ),
            itemCount: matrixTypes.length,
            itemBuilder: (context, index) {
              final matrix = matrixTypes[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  final templateName = matrix['template'] as String;
                  final templateContent =
                      LaTeXWidget.matrixTemplates[templateName];
                  if (templateContent != null) {
                    // Usar formato $ simples para melhor compatibilidade
                    final wrappedContent = '\$$templateContent\$';
                    widget.onFormatApplied('matrix', content: wrappedContent);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(matrix['icon'] as IconData, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        matrix['name'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
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

  Widget _buildQuickLaTeXButton(String label, String formula) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
        widget.onFormatApplied('latex', content: formula);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  void _showMermaidDialog(BuildContext context) {
    final diagramTypes = [
      {
        'name': 'Fluxograma',
        'template': 'flowchart',
        'icon': Icons.account_tree
      },
      {
        'name': 'Diagrama de Sequência',
        'template': 'sequence',
        'icon': Icons.timeline
      },
      {'name': 'Diagrama de Classe', 'template': 'class', 'icon': Icons.class_},
      {'name': 'Diagrama ER', 'template': 'er', 'icon': Icons.storage},
      {'name': 'Gantt Chart', 'template': 'gantt', 'icon': Icons.schedule},
      {'name': 'Gráfico de Pizza', 'template': 'pie', 'icon': Icons.pie_chart},
      {'name': 'Mapa Mental', 'template': 'mindmap', 'icon': Icons.psychology},
      {'name': 'Git Graph', 'template': 'gitgraph', 'icon': Icons.account_tree},
      {'name': 'C4 Context', 'template': 'c4', 'icon': Icons.architecture},
      {
        'name': 'Mermaid Básico',
        'template': 'mermaid',
        'icon': Icons.device_hub
      },
    ];

    final TextEditingController customMermaidController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Diagrama Mermaid'),
        content: SizedBox(
          width: 400,
          height: 500,
          child: Column(
            children: [
              const Text(
                'Escolha um tipo de diagrama:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: diagramTypes.length,
                  itemBuilder: (context, index) {
                    final diagram = diagramTypes[index];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        final templateName = diagram['template'] as String;
                        final templateContent =
                            MermaidTemplates.templates[templateName];
                        if (templateContent != null) {
                          widget.onFormatApplied('mermaid',
                              content: templateContent);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(diagram['icon'] as IconData, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              diagram['name'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ou digite seu próprio código Mermaid:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: customMermaidController,
                decoration: const InputDecoration(
                  labelText: 'Código Mermaid',
                  hintText: 'graph TD\nA[Início] --> B[Fim]',
                ),
                maxLines: 4,
                onSubmitted: (value) {
                  Navigator.of(context).pop();
                  if (value.isNotEmpty) {
                    widget.onFormatApplied('mermaid', content: value);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final customContent = customMermaidController.text.trim();
              if (customContent.isNotEmpty) {
                Navigator.of(context).pop();
                widget.onFormatApplied('mermaid', content: customContent);
              }
            },
            child: const Text('Inserir'),
          ),
        ],
      ),
    );
  }
}
