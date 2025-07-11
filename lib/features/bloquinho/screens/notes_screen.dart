import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../widgets/notes_editor.dart';
import '../../../core/theme/app_colors.dart';

/// Tela do editor de notas
class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _currentNote = '';
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        title: const Text('Editor de Notas'),
        backgroundColor: _isDarkMode ? AppColors.darkSurface : Colors.white,
        foregroundColor: _isDarkMode ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon:
                Icon(_isDarkMode ? PhosphorIcons.sun() : PhosphorIcons.moon()),
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
            tooltip: 'Alternar tema',
          ),
          IconButton(
            icon: Icon(PhosphorIcons.floppyDisk()),
            onPressed: _saveNote,
            tooltip: 'Salvar nota',
          ),
          IconButton(
            icon: Icon(PhosphorIcons.folderOpen()),
            onPressed: _loadNote,
            tooltip: 'Carregar nota',
          ),
        ],
      ),
      body: NotesEditor(
        initialContent: _currentNote,
        onChanged: (content) {
          setState(() {
            _currentNote = content;
          });
        },
        isDarkMode: _isDarkMode,
        placeholder: '''
# Bem-vindo ao Editor de Notas!

## Funcionalidades Disponíveis

### Formatação de Texto
- **Negrito**: Use o botão B ou digite **texto**
- *Itálico*: Use o botão I ou digite *texto*
- ~~Riscado~~: Use o botão ~~ ou digite ~~texto~~

### Estrutura
- # Título 1
- ## Título 2  
- ### Título 3

### Listas
- Lista simples: - item
- Lista numerada: 1. item
- Tarefas: - [ ] tarefa

### Código
- `Código inline`: Use o botão código
- Blocos de código: Use o botão bloco de código

### Outros
- > Citações
- Links: [texto](url)
- Imagens: ![alt](url)
- Tabelas: Use o botão tabela
- Divisores: ---

Comece a escrever suas notas!
        ''',
      ),
    );
  }

  void _saveNote() {
    if (_currentNote.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nada para salvar')),
      );
      return;
    }

    // Implementar salvamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nota salva!')),
    );
  }

  void _loadNote() {
    // Implementar carregamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Carregamento em desenvolvimento...')),
    );
  }
}
