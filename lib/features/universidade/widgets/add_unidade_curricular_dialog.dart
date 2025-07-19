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
import '../models/unidade_curricular_model.dart';
import '../providers/universidade_provider.dart';

class AddUnidadeCurricularDialog extends ConsumerStatefulWidget {
  final UnidadeCurricularModel? unidade;
  final Function(UnidadeCurricularModel) onSave;

  const AddUnidadeCurricularDialog({
    super.key,
    this.unidade,
    required this.onSave,
  });

  @override
  ConsumerState<AddUnidadeCurricularDialog> createState() => _AddUnidadeCurricularDialogState();
}

class _AddUnidadeCurricularDialogState extends ConsumerState<AddUnidadeCurricularDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _codigoController = TextEditingController();
  final _professorController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  String? _selectedCursoId;
  int? _semestre;
  int? _creditos;

  @override
  void initState() {
    super.initState();
    if (widget.unidade != null) {
      _nomeController.text = widget.unidade!.nome;
      _codigoController.text = widget.unidade!.codigo ?? '';
      _professorController.text = widget.unidade!.professor ?? '';
      _descricaoController.text = widget.unidade!.descricao ?? '';
      _selectedCursoId = widget.unidade!.cursoId;
      _semestre = widget.unidade!.semestre;
      _creditos = widget.unidade!.creditos;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cursosAsync = ref.watch(cursosProvider);

    return AlertDialog(
      title: Text(widget.unidade == null ? 'Adicionar Disciplina' : 'Editar Disciplina'),
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
                    labelText: 'Nome da Disciplina *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Nome é obrigatório' : null,
                ),
                const SizedBox(height: 16),
                cursosAsync.when(
                  data: (cursos) => DropdownButtonFormField<String>(
                    value: _selectedCursoId,
                    decoration: const InputDecoration(
                      labelText: 'Curso *',
                      border: OutlineInputBorder(),
                    ),
                    items: cursos.map((curso) => DropdownMenuItem(
                      value: curso.id,
                      child: Text(curso.nome),
                    )).toList(),
                    onChanged: (value) => setState(() => _selectedCursoId = value),
                    validator: (value) => value == null ? 'Selecione um curso' : null,
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Erro ao carregar cursos'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _codigoController,
                        decoration: const InputDecoration(
                          labelText: 'Código',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _semestre,
                        decoration: const InputDecoration(
                          labelText: 'Semestre',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(10, (i) => i + 1).map((sem) => DropdownMenuItem(
                          value: sem,
                          child: Text('$sem'),
                        )).toList(),
                        onChanged: (value) => setState(() => _semestre = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _professorController,
                  decoration: const InputDecoration(
                    labelText: 'Professor',
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
          onPressed: _saveUnidade,
          child: Text(widget.unidade == null ? 'Adicionar' : 'Salvar'),
        ),
      ],
    );
  }

  void _saveUnidade() {
    if (_formKey.currentState!.validate() && _selectedCursoId != null) {
      final unidade = widget.unidade?.copyWith(
        nome: _nomeController.text,
        codigo: _codigoController.text.isEmpty ? null : _codigoController.text,
        professor: _professorController.text.isEmpty ? null : _professorController.text,
        descricao: _descricaoController.text.isEmpty ? null : _descricaoController.text,
        semestre: _semestre,
        creditos: _creditos,
      ) ?? UnidadeCurricularModel.create(
        nome: _nomeController.text,
        cursoId: _selectedCursoId!,
        codigo: _codigoController.text.isEmpty ? null : _codigoController.text,
        professor: _professorController.text.isEmpty ? null : _professorController.text,
        descricao: _descricaoController.text.isEmpty ? null : _descricaoController.text,
        semestre: _semestre,
        creditos: _creditos,
      );

      widget.onSave(unidade);
    }
  }
}