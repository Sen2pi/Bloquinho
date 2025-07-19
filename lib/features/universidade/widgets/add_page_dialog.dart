/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import '../models/universidade_page_model.dart';

class AddPageDialog extends StatefulWidget {
  final UniversidadePageModel? page;
  final String? parentId;
  final TipoContextoPage? tipoContexto;
  final String? contextoId;
  final Function(UniversidadePageModel) onSave;

  const AddPageDialog({
    super.key,
    this.page,
    this.parentId,
    this.tipoContexto,
    this.contextoId,
    required this.onSave,
  });

  @override
  State<AddPageDialog> createState() => _AddPageDialogState();
}

class _AddPageDialogState extends State<AddPageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _conteudoController = TextEditingController();
  
  TipoContextoPage _selectedTipo = TipoContextoPage.geral;
  String? _selectedContextoId;
  String? _selectedIcon;

  final List<Map<String, dynamic>> _availableIcons = [
    {'icon': Icons.description, 'name': 'Documento'},
    {'icon': Icons.note, 'name': 'Nota'},
    {'icon': Icons.book, 'name': 'Livro'},
    {'icon': Icons.folder, 'name': 'Pasta'},
    {'icon': Icons.assignment, 'name': 'Trabalho'},
    {'icon': Icons.quiz, 'name': 'Quiz'},
    {'icon': Icons.science, 'name': 'Laboratório'},
    {'icon': Icons.calculate, 'name': 'Cálculos'},
    {'icon': Icons.code, 'name': 'Código'},
    {'icon': Icons.image, 'name': 'Imagem'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.page != null) {
      _tituloController.text = widget.page!.titulo;
      _conteudoController.text = widget.page!.conteudo;
      _selectedTipo = widget.page!.tipoContexto;
      _selectedContextoId = widget.page!.contextoId;
      _selectedIcon = widget.page!.icon;
    } else {
      if (widget.tipoContexto != null) {
        _selectedTipo = widget.tipoContexto!;
      }
      _selectedContextoId = widget.contextoId;
      _selectedIcon = Icons.description.codePoint.toString();
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.page == null ? 'Nova Página' : 'Editar Página'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título da Página *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Título é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TipoContextoPage>(
                  value: _selectedTipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Contexto *',
                    border: OutlineInputBorder(),
                  ),
                  items: TipoContextoPage.values.map((tipo) => DropdownMenuItem(
                    value: tipo,
                    child: Text(_getTipoDisplayName(tipo)),
                  )).toList(),
                  onChanged: widget.tipoContexto == null ? (value) => setState(() => _selectedTipo = value!) : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: TextEditingController(text: _selectedContextoId ?? ''),
                  decoration: const InputDecoration(
                    labelText: 'ID do Contexto',
                    border: OutlineInputBorder(),
                    hintText: 'Opcional - ID da universidade/curso/disciplina',
                  ),
                  enabled: widget.contextoId == null,
                  onChanged: (value) => _selectedContextoId = value.isEmpty ? null : value,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ícone da Página',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 100,
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: _availableIcons.length,
                        itemBuilder: (context, index) {
                          final iconData = _availableIcons[index];
                          final iconCode = iconData['icon'].codePoint.toString();
                          final isSelected = _selectedIcon == iconCode;
                          
                          return InkWell(
                            onTap: () => setState(() => _selectedIcon = iconCode),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    iconData['icon'],
                                    color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : null,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    iconData['name'],
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 10,
                                      color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : null,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _conteudoController,
                  decoration: const InputDecoration(
                    labelText: 'Conteúdo',
                    border: OutlineInputBorder(),
                    hintText: 'Conteúdo inicial da página...',
                  ),
                  maxLines: 10,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _savePage,
          child: Text(widget.page == null ? 'Criar' : 'Salvar'),
        ),
      ],
    );
  }

  String _getTipoDisplayName(TipoContextoPage tipo) {
    switch (tipo) {
      case TipoContextoPage.universidade:
        return 'Universidade';
      case TipoContextoPage.curso:
        return 'Curso';
      case TipoContextoPage.unidadeCurricular:
        return 'Disciplina';
      case TipoContextoPage.avaliacao:
        return 'Avaliação';
      case TipoContextoPage.geral:
        return 'Geral';
    }
  }

  void _savePage() {
    if (_formKey.currentState!.validate()) {
      final page = widget.page?.copyWith(
        titulo: _tituloController.text,
        conteudo: _conteudoController.text,
        tipoContexto: _selectedTipo,
        contextoId: _selectedContextoId,
        icon: _selectedIcon,
      ) ?? UniversidadePageModel.create(
        titulo: _tituloController.text,
        parentId: widget.parentId,
        conteudo: _conteudoController.text,
        tipoContexto: _selectedTipo,
        contextoId: _selectedContextoId,
        icon: _selectedIcon,
      );

      widget.onSave(page);
    }
  }
}