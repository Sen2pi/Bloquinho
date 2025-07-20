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

import '../models/universidade_page_model.dart';
import '../providers/universidade_provider.dart';

class UniversidadePageEditorWidget extends ConsumerStatefulWidget {
  final UniversidadePageModel page;

  const UniversidadePageEditorWidget({
    super.key,
    required this.page,
  });

  @override
  ConsumerState<UniversidadePageEditorWidget> createState() => _UniversidadePageEditorWidgetState();
}

class _UniversidadePageEditorWidgetState extends ConsumerState<UniversidadePageEditorWidget> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.page.titulo);
    _contentController = TextEditingController(text: widget.page.conteudo);
    
    _titleController.addListener(_onContentChanged);
    _contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.page.icon ?? '📄'),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.page.titulo,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_hasUnsavedChanges)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Não salvo',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _hasUnsavedChanges ? _saveChanges : null,
            icon: Icon(
              PhosphorIcons.floppyDisk(),
              color: _hasUnsavedChanges ? Colors.blue : Colors.grey,
            ),
            tooltip: 'Salvar',
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(PhosphorIcons.x()),
            tooltip: 'Fechar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Informações da página
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(
                      label: Text(widget.page.contextoNome),
                      backgroundColor: _getContextoColor(widget.page.tipoContexto).withOpacity(0.2),
                    ),
                    if (widget.page.tipoModulo != null) ...[
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(widget.page.tipoModulo!.displayName),
                        backgroundColor: Colors.teal.withOpacity(0.2),
                      ),
                    ],
                    const Spacer(),
                    if (widget.page.arquivos.isNotEmpty)
                      Chip(
                        avatar: Icon(
                          PhosphorIcons.paperclip(),
                          size: 16,
                        ),
                        label: Text('${widget.page.arquivos.length} arquivo(s)'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  style: Theme.of(context).textTheme.headlineSmall,
                  decoration: const InputDecoration(
                    hintText: 'Título da página',
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          
          // Editor de conteúdo
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
                decoration: const InputDecoration(
                  hintText: 'Comece a escrever o conteúdo da página...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              PhosphorIcons.info(),
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              'Criado em ${_formatDate(widget.page.createdAt)} • '
              'Atualizado em ${_formatDate(widget.page.updatedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const Spacer(),
            if (_hasUnsavedChanges)
              TextButton(
                onPressed: _saveChanges,
                child: const Text('Salvar alterações'),
              ),
          ],
        ),
      ),
    );
  }

  Color _getContextoColor(TipoContextoPage tipo) {
    switch (tipo) {
      case TipoContextoPage.universidade:
        return Colors.blue;
      case TipoContextoPage.curso:
        return Colors.green;
      case TipoContextoPage.unidadeCurricular:
        return Colors.orange;
      case TipoContextoPage.modulo:
        return Colors.teal;
      case TipoContextoPage.avaliacao:
        return Colors.purple;
      case TipoContextoPage.geral:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year} às '
           '${date.hour.toString().padLeft(2, '0')}:'
           '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveChanges() async {
    try {
      final updatedPage = widget.page.copyWith(
        titulo: _titleController.text.trim(),
        conteudo: _contentController.text,
        updatedAt: DateTime.now(),
      );

      final service = ref.read(universidadeServiceProvider);
      await service.savePage(updatedPage);
      ref.invalidate(universidadePagesProvider);

      setState(() {
        _hasUnsavedChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Página salva com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}