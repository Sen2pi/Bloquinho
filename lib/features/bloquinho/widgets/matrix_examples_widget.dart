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
import 'latex_widget.dart';
import 'enhanced_markdown_preview_widget.dart';

/// Widget para demonstrar exemplos de matrizes LaTeX
class MatrixExamplesWidget extends ConsumerWidget {
  const MatrixExamplesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemplos de Matrizes LaTeX'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exemplos de Matrizes e Fórmulas Matemáticas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Seção de Matrizes
            _buildSection('Matrizes', [
              _buildExample('Matriz 2x2', 'matrix-2x2'),
              _buildExample('Matriz 3x3', 'matrix-3x3'),
              _buildExample('Matriz 4x4', 'matrix-4x4'),
              _buildExample('Matriz com colchetes', 'matrix-brackets'),
              _buildExample('Matriz com chaves', 'matrix-braces'),
            ]),

            const SizedBox(height: 20),

            // Seção de Determinantes
            _buildSection('Determinantes', [
              _buildExample('Determinante 2x2', 'determinant-2x2'),
              _buildExample('Determinante 3x3', 'determinant-3x3'),
            ]),

            const SizedBox(height: 20),

            // Seção de Sistemas
            _buildSection('Sistemas de Equações', [
              _buildExample('Sistema 2x2', 'system-2x2'),
              _buildExample('Sistema 3x3', 'system-3x3'),
            ]),

            const SizedBox(height: 20),

            // Seção de Vetores
            _buildSection('Vetores', [
              _buildExample('Vetor 3D', 'vector'),
            ]),

            const SizedBox(height: 20),

            // Seção de Fórmulas Matemáticas
            _buildSection('Fórmulas Matemáticas', [
              _buildExample('Integral', 'integral'),
              _buildExample('Derivada', 'derivative'),
              _buildExample('Derivada Parcial', 'partial'),
              _buildExample('Limite', 'limit'),
              _buildExample('Soma', 'sum'),
              _buildExample('Produtório', 'product'),
              _buildExample('Fração', 'fraction'),
              _buildExample('Raiz Quadrada', 'sqrt'),
              _buildExample('Raiz n-ésima', 'root'),
              _buildExample('Potência', 'power'),
              _buildExample('Subscrito', 'subscript'),
            ]),

            const SizedBox(height: 20),

            // Seção de Preview Markdown
            _buildMarkdownPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildExample(String name, String template) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          LaTeXWidget.fromTemplate(template),
        ],
      ),
    );
  }

  Widget _buildMarkdownPreview() {
    const markdownExample = r'''
# Exemplos de Matrizes em Markdown

## Matriz 2x2
$$
\begin{pmatrix} 
a & b \\ 
c & d 
\end{pmatrix}
$$

## Sistema de Equações
$$
\begin{cases}
ax + by = c \\
dx + ey = f
\end{cases}
$$

## Determinante
$$
\begin{vmatrix}
a & b \\
c & d
\end{vmatrix} = ad - bc
$$

## Vetor
$$
\vec{v} = \begin{pmatrix} x \\ y \\ z \end{pmatrix}
$$

## Fórmulas Matemáticas

### Integral
$$
\int_{a}^{b} f(x) \, dx
$$

### Derivada
$$
\frac{d}{dx} f(x)
$$

### Soma
$$
\sum_{i=1}^{n} x_i
$$

### Limite
$$
\lim_{x \to \infty} f(x)
$$
''';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview Markdown com LaTeX',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 400,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: EnhancedMarkdownPreviewWidget(
            markdown: markdownExample,
            enableHtmlEnhancements: true,
          ),
        ),
      ],
    );
  }
}
