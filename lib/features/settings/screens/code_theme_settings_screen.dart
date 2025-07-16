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
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../features/bloquinho/models/code_theme.dart';
import '../../../features/bloquinho/widgets/windows_code_block_widget.dart';

class CodeThemeSettingsScreen extends ConsumerStatefulWidget {
  const CodeThemeSettingsScreen({super.key});

  @override
  ConsumerState<CodeThemeSettingsScreen> createState() =>
      _CodeThemeSettingsScreenState();
}

class _CodeThemeSettingsScreenState
    extends ConsumerState<CodeThemeSettingsScreen> {
  CodeTheme? _selectedTheme;
  final String _sampleCode = '''
// Exemplo de código JavaScript
function calculateSum(a, b) {
  // Função para calcular a soma
  const result = a + b;
  
  if (result > 100) {
    console.log("Resultado é maior que 100");
    return result * 2;
  }
  
  return result;
}

// Classe de exemplo
class Calculator {
  constructor() {
    this.history = [];
  }
  
  add(a, b) {
    const result = a + b;
    this.history.push(result);
    return result;
  }
}

// Uso da função
const calc = new Calculator();
const sum = calculateSum(50, 30);
console.log("Soma:", sum);
''';

  @override
  void initState() {
    super.initState();
    // Inicializar com o tema atual
    _selectedTheme = ref.read(selectedCodeThemeProvider);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsProvider.of(ref.watch(languageProvider));
    final currentTheme = ref.watch(selectedCodeThemeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.codeTheme),
        actions: [
          // Botão para restaurar padrão
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () => _resetToDefault(strings),
            tooltip: strings.resetToDefault,
          ),
        ],
      ),
      body: Column(
        children: [
          // Seção de temas escuros
          _buildThemeSection(
            strings.darkThemes,
            CodeTheme.themes
                .where((theme) =>
                    theme.name.contains('dracula') ||
                    theme.name.contains('monokai') ||
                    theme.name.contains('oneDark') ||
                    theme.name.contains('nightOwl') ||
                    theme.name.contains('materialOcean') ||
                    theme.name.contains('palenight') ||
                    theme.name.contains('synthwave') ||
                    theme.name.contains('tokyoNight'))
                .toList(),
            strings,
          ),

          // Seção de temas claros
          _buildThemeSection(
            strings.lightThemes,
            CodeTheme.themes
                .where((theme) =>
                    theme.name.contains('github') ||
                    theme.name.contains('solarizedLight') ||
                    theme.name.contains('xcode') ||
                    theme.name.contains('vsCode') ||
                    theme.name.contains('atom') ||
                    theme.name.contains('sublime'))
                .toList(),
            strings,
          ),

          // Preview do código
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.preview, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          strings.preview,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: WindowsCodeBlockWidget(
                      code: _sampleCode,
                      language: 'javascript',
                      showLineNumbers: true,
                      showMacOSHeader: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(strings),
    );
  }

  Widget _buildThemeSection(
      String title, List<CodeTheme> themes, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: themes.length,
            itemBuilder: (context, index) {
              final theme = themes[index];
              final isSelected = _selectedTheme?.name == theme.name;

              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  elevation: isSelected ? 4 : 2,
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                  child: InkWell(
                    onTap: () => _selectTheme(theme, strings),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  theme.displayName,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : null,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Preview das cores do tema
                          Row(
                            children: [
                              _buildColorPreview(theme.backgroundColor, 'BG'),
                              const SizedBox(width: 4),
                              _buildColorPreview(theme.textColor, 'T'),
                              const SizedBox(width: 4),
                              _buildColorPreview(theme.keywordColor, 'K'),
                              const SizedBox(width: 4),
                              _buildColorPreview(theme.stringColor, 'S'),
                              const SizedBox(width: 4),
                              _buildColorPreview(theme.numberColor, 'N'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorPreview(Color color, String label) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 8,
            color: _getContrastColor(color),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Widget _buildBottomBar(AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(strings.cancel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed:
                  _selectedTheme != null ? () => _applyTheme(strings) : null,
              child: Text(strings.applyTheme),
            ),
          ),
        ],
      ),
    );
  }

  void _selectTheme(CodeTheme theme, AppStrings strings) {
    setState(() {
      _selectedTheme = theme;
    });

    // Atualizar o provider para preview em tempo real
    ref.read(selectedCodeThemeProvider.notifier).state = theme;
  }

  void _applyTheme(AppStrings strings) {
    if (_selectedTheme != null) {
      // O tema já foi aplicado via provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.codeThemeChanged),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _resetToDefault(AppStrings strings) {
    final defaultTheme = CodeTheme.defaultTheme;
    setState(() {
      _selectedTheme = defaultTheme;
    });

    ref.read(selectedCodeThemeProvider.notifier).state = defaultTheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.resetToDefault),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
