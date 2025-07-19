/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import '../models/universidade_model.dart';

class AddUniversidadeDialog extends StatefulWidget {
  final UniversidadeModel? universidade;
  final Function(UniversidadeModel) onSave;

  const AddUniversidadeDialog({
    super.key,
    this.universidade,
    required this.onSave,
  });

  @override
  State<AddUniversidadeDialog> createState() => _AddUniversidadeDialogState();
}

class _AddUniversidadeDialogState extends State<AddUniversidadeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _siglaController = TextEditingController();
  final _paisController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _websiteController = TextEditingController();
  final _descricaoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.universidade != null) {
      _nomeController.text = widget.universidade!.nome;
      _siglaController.text = widget.universidade!.sigla ?? '';
      _paisController.text = widget.universidade!.pais ?? '';
      _cidadeController.text = widget.universidade!.cidade ?? '';
      _websiteController.text = widget.universidade!.website ?? '';
      _descricaoController.text = widget.universidade!.descricao ?? '';
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _siglaController.dispose();
    _paisController.dispose();
    _cidadeController.dispose();
    _websiteController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.universidade == null ? 'Adicionar Universidade' : 'Editar Universidade'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Universidade *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _siglaController,
                  decoration: const InputDecoration(
                    labelText: 'Sigla',
                    border: OutlineInputBorder(),
                    hintText: 'Ex: USP, UNICAMP',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _paisController,
                        decoration: const InputDecoration(
                          labelText: 'País',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _cidadeController,
                        decoration: const InputDecoration(
                          labelText: 'Cidade',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(
                    labelText: 'Website',
                    border: OutlineInputBorder(),
                    hintText: 'https://www.universidade.edu',
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !Uri.tryParse(value)!.isAbsolute) {
                      return 'URL inválida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
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
          onPressed: _saveUniversidade,
          child: Text(widget.universidade == null ? 'Adicionar' : 'Salvar'),
        ),
      ],
    );
  }

  void _saveUniversidade() {
    if (_formKey.currentState!.validate()) {
      final universidade = widget.universidade?.copyWith(
        nome: _nomeController.text,
        sigla: _siglaController.text.isEmpty ? null : _siglaController.text,
        pais: _paisController.text.isEmpty ? null : _paisController.text,
        cidade: _cidadeController.text.isEmpty ? null : _cidadeController.text,
        website: _websiteController.text.isEmpty ? null : _websiteController.text,
        descricao: _descricaoController.text.isEmpty ? null : _descricaoController.text,
      ) ?? UniversidadeModel.create(
        nome: _nomeController.text,
        sigla: _siglaController.text.isEmpty ? null : _siglaController.text,
        pais: _paisController.text.isEmpty ? null : _paisController.text,
        cidade: _cidadeController.text.isEmpty ? null : _cidadeController.text,
        website: _websiteController.text.isEmpty ? null : _websiteController.text,
        descricao: _descricaoController.text.isEmpty ? null : _descricaoController.text,
      );

      widget.onSave(universidade);
    }
  }
}