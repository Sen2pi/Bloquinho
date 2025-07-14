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
import '../widgets/markdown_editor_widget.dart';
import '../widgets/enhanced_markdown_preview_widget.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';

class MarkdownEditorScreen extends ConsumerStatefulWidget {
  const MarkdownEditorScreen({super.key});

  @override
  ConsumerState<MarkdownEditorScreen> createState() =>
      _MarkdownEditorScreenState();
}

class _MarkdownEditorScreenState extends ConsumerState<MarkdownEditorScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _showPreview = true;
  double _splitRatio = 0.5;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    // Conteúdo inicial de exemplo
// No initState(), adicionar o exemplo que replica a imagem:
    _controller.text = '''
# 📊 Editor de Markdown com Blocos de Código

## 💻 Exemplo de Código JavaScript

\`\`\`javascript
const soma = (n1,n2) => {
  return n1 + n2;
}
\`\`\`

## 🐍 Exemplo Python

\`\`\`python
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

print(fibonacci(10))
\`\`\`

## 🔢 Fórmula Matemática

A equação de Einstein: \$E = mc^2\$

## 📈 Diagrama Simples

\`\`\`mermaid
graph TD
    A[Início] --> B{Decisão}
    B -->|Sim| C[Sucesso]
    B -->|Não| D[Falha]
\`\`\`
''';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: _buildAppBar(isDarkMode),
      body: _buildBody(isDarkMode),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      title: const Text('Editor Markdown'),
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      actions: [
        IconButton(
          icon: Icon(
              _showPreview ? PhosphorIcons.eyeSlash() : PhosphorIcons.eye()),
          tooltip: _showPreview ? 'Ocultar Preview' : 'Mostrar Preview',
          onPressed: () => setState(() => _showPreview = !_showPreview),
        ),
        IconButton(
          icon: Icon(_isFullscreen
              ? PhosphorIcons.arrowsIn()
              : PhosphorIcons.arrowsOut()),
          tooltip: _isFullscreen ? 'Sair Fullscreen' : 'Fullscreen',
          onPressed: () => setState(() => _isFullscreen = !_isFullscreen),
        ),
        IconButton(
          icon: Icon(PhosphorIcons.downloadSimple()),
          tooltip: 'Exportar',
          onPressed: _showExportDialog,
        ),
      ],
    );
  }

  Widget _buildBody(bool isDarkMode) {
    if (_isFullscreen) {
      return _showPreview
          ? EnhancedMarkdownPreviewWidget(markdown: _controller.text)
          : MarkdownEditorWidget(controller: _controller);
    }

    if (!_showPreview) {
      return MarkdownEditorWidget(controller: _controller);
    }

    return Row(
      children: [
        // Editor
        Expanded(
          flex: (_splitRatio * 100).round(),
          child: MarkdownEditorWidget(
            controller: _controller,
            onChanged: (value) => setState(() {}),
          ),
        ),

        // Divisor redimensionável
        GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _splitRatio = (details.globalPosition.dx /
                      MediaQuery.of(context).size.width)
                  .clamp(0.2, 0.8);
            });
          },
          child: Container(
            width: 4,
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            child: Center(
              child: Container(
                width: 2,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),

        // Preview
        Expanded(
          flex: ((1 - _splitRatio) * 100).round(),
          child: EnhancedMarkdownPreviewWidget(
            markdown: _controller.text,
          ),
        ),
      ],
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Documento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(PhosphorIcons.fileText()),
              title: const Text('Markdown (.md)'),
              onTap: () => _exportAsMarkdown(),
            ),
            ListTile(
              leading: Icon(PhosphorIcons.fileHtml()),
              title: const Text('HTML (.html)'),
              onTap: () => _exportAsHtml(),
            ),
            ListTile(
              leading: Icon(PhosphorIcons.filePdf()),
              title: const Text('PDF (.pdf)'),
              onTap: () => _exportAsPdf(),
            ),
          ],
        ),
      ),
    );
  }

  void _exportAsMarkdown() {
    // Implementar exportação MD
    Navigator.pop(context);
  }

  void _exportAsHtml() {
    // Implementar exportação HTML
    Navigator.pop(context);
  }

  void _exportAsPdf() {
    // Implementar exportação PDF
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
