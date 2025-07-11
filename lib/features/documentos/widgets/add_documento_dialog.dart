import 'package:flutter/material.dart';
import '../models/documento.dart';

class AddDocumentoDialog extends StatefulWidget {
  final void Function(Documento) onAdd;
  const AddDocumentoDialog({super.key, required this.onAdd});

  @override
  State<AddDocumentoDialog> createState() => _AddDocumentoDialogState();
}

class _AddDocumentoDialogState extends State<AddDocumentoDialog> {
  TipoDocumento _tipo = TipoDocumento.identificacao;
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _numeroController = TextEditingController();
  final _validadeController = TextEditingController();
  final _nomeImpressoController = TextEditingController();
  final _emissorController = TextEditingController();
  final _codigoSegurancaController = TextEditingController();
  final _programaFidelidadeController = TextEditingController();

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _numeroController.dispose();
    _validadeController.dispose();
    _nomeImpressoController.dispose();
    _emissorController.dispose();
    _codigoSegurancaController.dispose();
    _programaFidelidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Documento'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<TipoDocumento>(
              value: _tipo,
              items: TipoDocumento.values.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Text(_descricaoTipo(tipo)),
                );
              }).toList(),
              onChanged: (tipo) {
                if (tipo != null) setState(() => _tipo = tipo);
              },
              decoration: const InputDecoration(labelText: 'Tipo'),
            ),
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            if (_tipo == TipoDocumento.identificacao) ...[
              TextField(
                controller: _numeroController,
                decoration:
                    const InputDecoration(labelText: 'Número do Documento'),
              ),
              TextField(
                controller: _validadeController,
                decoration: const InputDecoration(labelText: 'Validade'),
              ),
              TextField(
                controller: _emissorController,
                decoration: const InputDecoration(labelText: 'Emissor'),
              ),
            ],
            if (_tipo == TipoDocumento.cartaoCredito) ...[
              TextField(
                controller: _numeroController,
                decoration:
                    const InputDecoration(labelText: 'Número do Cartão'),
              ),
              TextField(
                controller: _validadeController,
                decoration: const InputDecoration(labelText: 'Validade'),
              ),
              TextField(
                controller: _nomeImpressoController,
                decoration: const InputDecoration(labelText: 'Nome Impresso'),
              ),
              TextField(
                controller: _codigoSegurancaController,
                decoration:
                    const InputDecoration(labelText: 'Código de Segurança'),
              ),
            ],
            if (_tipo == TipoDocumento.cartaoFidelizacao) ...[
              TextField(
                controller: _numeroController,
                decoration:
                    const InputDecoration(labelText: 'Número do Cartão'),
              ),
              TextField(
                controller: _programaFidelidadeController,
                decoration:
                    const InputDecoration(labelText: 'Programa de Fidelidade'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _adicionar,
          child: const Text('Adicionar'),
        ),
      ],
    );
  }

  void _adicionar() {
    final doc = Documento(
      tipo: _tipo,
      titulo: _tituloController.text,
      descricao: _descricaoController.text,
      numero: _numeroController.text.isNotEmpty ? _numeroController.text : null,
      validade:
          _validadeController.text.isNotEmpty ? _validadeController.text : null,
      nomeImpresso: _nomeImpressoController.text.isNotEmpty
          ? _nomeImpressoController.text
          : null,
      emissor:
          _emissorController.text.isNotEmpty ? _emissorController.text : null,
      codigoSeguranca: _codigoSegurancaController.text.isNotEmpty
          ? _codigoSegurancaController.text
          : null,
      programaFidelidade: _programaFidelidadeController.text.isNotEmpty
          ? _programaFidelidadeController.text
          : null,
    );
    widget.onAdd(doc);
    Navigator.of(context).pop();
  }

  String _descricaoTipo(TipoDocumento tipo) {
    switch (tipo) {
      case TipoDocumento.identificacao:
        return 'Identificação';
      case TipoDocumento.cartaoCredito:
        return 'Cartão de Crédito';
      case TipoDocumento.cartaoFidelizacao:
        return 'Cartão de Fidelização';
    }
  }
}
