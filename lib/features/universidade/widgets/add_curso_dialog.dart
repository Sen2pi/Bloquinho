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
import '../models/curso_model.dart';
import '../models/tipo_curso_enum.dart';
import '../providers/universidade_provider.dart';

class AddCursoDialog extends ConsumerStatefulWidget {
  final CursoModel? curso;
  final Function(CursoModel) onSave;

  const AddCursoDialog({
    super.key,
    this.curso,
    required this.onSave,
  });

  @override
  ConsumerState<AddCursoDialog> createState() => _AddCursoDialogState();
}

class _AddCursoDialogState extends ConsumerState<AddCursoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _codigoController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  String? _selectedUniversidadeId;
  TipoCurso _selectedTipo = TipoCurso.licenciatura;

  @override
  void initState() {
    super.initState();
    if (widget.curso != null) {
      _nomeController.text = widget.curso!.nome;
      _codigoController.text = widget.curso!.codigo ?? '';
      _descricaoController.text = widget.curso!.descricao ?? '';
      _selectedUniversidadeId = widget.curso!.universidadeId;
      _selectedTipo = widget.curso!.tipo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final universidadesAsync = ref.watch(universidadesProvider);

    return AlertDialog(
      title: Text(widget.curso == null ? 'Adicionar Curso' : 'Editar Curso'),
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
                    labelText: 'Nome do Curso *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Nome é obrigatório' : null,
                ),
                const SizedBox(height: 16),
                universidadesAsync.when(
                  data: (universidades) => DropdownButtonFormField<String>(
                    value: _selectedUniversidadeId,
                    decoration: const InputDecoration(
                      labelText: 'Universidade *',
                      border: OutlineInputBorder(),
                    ),
                    items: universidades.map((uni) => DropdownMenuItem(
                      value: uni.id,
                      child: Text(uni.nome),
                    )).toList(),
                    onChanged: (value) => setState(() => _selectedUniversidadeId = value),
                    validator: (value) => value == null ? 'Selecione uma universidade' : null,
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Erro ao carregar universidades'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TipoCurso>(
                  value: _selectedTipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Curso *',
                    border: OutlineInputBorder(),
                  ),
                  items: TipoCurso.values.map((tipo) => DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo.displayName),
                  )).toList(),
                  onChanged: (value) => setState(() => _selectedTipo = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codigoController,
                  decoration: const InputDecoration(
                    labelText: 'Código do Curso',
                    border: OutlineInputBorder(),
                  ),
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
          onPressed: _saveCurso,
          child: Text(widget.curso == null ? 'Adicionar' : 'Salvar'),
        ),
      ],
    );
  }

  void _saveCurso() {
    if (_formKey.currentState!.validate() && _selectedUniversidadeId != null) {
      final curso = widget.curso?.copyWith(
        nome: _nomeController.text,
        codigo: _codigoController.text.isEmpty ? null : _codigoController.text,
        descricao: _descricaoController.text.isEmpty ? null : _descricaoController.text,
        tipo: _selectedTipo,
      ) ?? CursoModel.create(
        nome: _nomeController.text,
        universidadeId: _selectedUniversidadeId!,
        tipo: _selectedTipo,
        codigo: _codigoController.text.isEmpty ? null : _codigoController.text,
        descricao: _descricaoController.text.isEmpty ? null : _descricaoController.text,
      );

      widget.onSave(curso);
    }
  }
}