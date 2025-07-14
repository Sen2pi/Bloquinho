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
          onTap: () => _showLaTeXDialog(context),
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

  void _showLaTeXDialog(BuildContext context) {
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
                    widget.onFormatApplied('latex', color: value);
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
                widget.onFormatApplied('latex', color: latexContent);
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
                    widget.onFormatApplied('matrix', color: templateContent);
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
        widget.onFormatApplied('latex', color: formula);
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
                              color: templateContent);
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
                    widget.onFormatApplied('mermaid', color: value);
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
                widget.onFormatApplied('mermaid', color: customContent);
              }
            },
            child: const Text('Inserir'),
          ),
        ],
      ),
    );
  }
}
