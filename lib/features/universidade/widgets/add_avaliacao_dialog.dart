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
import '../models/avaliacao_model.dart';
import '../providers/universidade_provider.dart';

class AddAvaliacaoDialog extends ConsumerStatefulWidget {
  final AvaliacaoModel? avaliacao;
  final Function(AvaliacaoModel) onSave;

  const AddAvaliacaoDialog({
    super.key,
    this.avaliacao,
    required this.onSave,
  });

  @override
  ConsumerState<AddAvaliacaoDialog> createState() => _AddAvaliacaoDialogState();
}

class _AddAvaliacaoDialogState extends ConsumerState<AddAvaliacaoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _notaController = TextEditingController();
  final _notaMaximaController = TextEditingController();
  
  String? _selectedUnidadeId;
  TipoAvaliacao _selectedTipo = TipoAvaliacao.teste;
  DateTime? _dataAvaliacao;
  DateTime? _dataEntrega;

  @override
  void initState() {
    super.initState();
    if (widget.avaliacao != null) {
      _nomeController.text = widget.avaliacao!.nome;
      _descricaoController.text = widget.avaliacao!.descricao ?? '';
      _notaController.text = widget.avaliacao!.nota?.toString() ?? '';
      _notaMaximaController.text = widget.avaliacao!.notaMaxima.toString();
      _selectedUnidadeId = widget.avaliacao!.unidadeCurricularId;
      _selectedTipo = widget.avaliacao!.tipo;
      _dataAvaliacao = widget.avaliacao!.dataAvaliacao;
      _dataEntrega = widget.avaliacao!.dataEntrega;
    } else {
      _notaMaximaController.text = '20.0';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unidadesAsync = ref.watch(unidadesCurricularesProvider);

    return AlertDialog(
      title: Text(widget.avaliacao == null ? 'Adicionar Avaliação' : 'Editar Avaliação'),
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
                    labelText: 'Nome da Avaliação *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Nome é obrigatório' : null,
                ),
                const SizedBox(height: 16),
                unidadesAsync.when(
                  data: (unidades) => DropdownButtonFormField<String>(
                    value: _selectedUnidadeId,
                    decoration: const InputDecoration(
                      labelText: 'Disciplina *',
                      border: OutlineInputBorder(),
                    ),
                    items: unidades.map((unidade) => DropdownMenuItem(
                      value: unidade.id,
                      child: Text(unidade.nome),
                    )).toList(),
                    onChanged: (value) => setState(() => _selectedUnidadeId = value),
                    validator: (value) => value == null ? 'Selecione uma disciplina' : null,
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Erro ao carregar disciplinas'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TipoAvaliacao>(
                  value: _selectedTipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Avaliação *',
                    border: OutlineInputBorder(),
                  ),
                  items: TipoAvaliacao.values.map((tipo) => DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo.displayName),
                  )).toList(),
                  onChanged: (value) => setState(() => _selectedTipo = value!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Data da Avaliação'),
                        subtitle: Text(_dataAvaliacao?.toString().split(' ')[0] ?? 'Não definida'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _dataAvaliacao ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => _dataAvaliacao = date);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _notaController,
                        decoration: const InputDecoration(
                          labelText: 'Nota Obtida',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _notaMaximaController,
                        decoration: const InputDecoration(
                          labelText: 'Nota Máxima *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty == true) return 'Nota máxima é obrigatória';
                          if (double.tryParse(value!) == null) return 'Valor inválido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição/Observações',
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
          onPressed: _saveAvaliacao,
          child: Text(widget.avaliacao == null ? 'Adicionar' : 'Salvar'),
        ),
      ],
    );
  }

  void _saveAvaliacao() {
    if (_formKey.currentState!.validate() && _selectedUnidadeId != null) {
      final nota = _notaController.text.isEmpty ? null : double.tryParse(_notaController.text);
      final notaMaxima = double.parse(_notaMaximaController.text);
      
      final avaliacao = widget.avaliacao?.copyWith(
        nome: _nomeController.text,
        tipo: _selectedTipo,
        nota: nota,
        notaMaxima: notaMaxima,
        dataAvaliacao: _dataAvaliacao,
        descricao: _descricaoController.text.isEmpty ? null : _descricaoController.text,
        realizada: nota != null,
      ) ?? AvaliacaoModel.create(
        nome: _nomeController.text,
        unidadeCurricularId: _selectedUnidadeId!,
        tipo: _selectedTipo,
        nota: nota,
        notaMaxima: notaMaxima,
        dataAvaliacao: _dataAvaliacao,
        descricao: _descricaoController.text.isEmpty ? null : _descricaoController.text,
        realizada: nota != null,
      );

      widget.onSave(avaliacao);
    }
  }
}