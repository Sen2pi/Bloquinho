import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/documento_identificacao.dart';
import '../../../core/theme/app_colors.dart';

class AddDocumentoIdentificacaoDialog extends StatefulWidget {
  final void Function(DocumentoIdentificacao) onAdd;
  final DocumentoIdentificacao? documento; // Para edição

  const AddDocumentoIdentificacaoDialog({
    super.key,
    required this.onAdd,
    this.documento,
  });

  @override
  State<AddDocumentoIdentificacaoDialog> createState() =>
      _AddDocumentoIdentificacaoDialogState();
}

class _AddDocumentoIdentificacaoDialogState
    extends State<AddDocumentoIdentificacaoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _nomeCompletoController = TextEditingController();
  final _orgaoEmissorController = TextEditingController();
  final _dataEmissaoController = TextEditingController();
  final _dataVencimentoController = TextEditingController();
  final _naturalidadeController = TextEditingController();
  final _nacionalidadeController = TextEditingController();
  final _nomePaiController = TextEditingController();
  final _nomeMaeController = TextEditingController();
  final _observacoesController = TextEditingController();

  TipoIdentificacao _tipo = TipoIdentificacao.rg;
  bool _ativo = true;

  @override
  void initState() {
    super.initState();
    if (widget.documento != null) {
      // Modo edição
      final documento = widget.documento!;
      _tipo = documento.tipo;
      _numeroController.text = documento.numero;
      _nomeCompletoController.text = documento.nomeCompleto;
      _orgaoEmissorController.text = documento.orgaoEmissor ?? '';
      _dataEmissaoController.text = documento.dataEmissao ?? '';
      _dataVencimentoController.text = documento.dataVencimento ?? '';
      _naturalidadeController.text = documento.naturalidade ?? '';
      _nacionalidadeController.text = documento.nacionalidade ?? '';
      _nomePaiController.text = documento.nomePai ?? '';
      _nomeMaeController.text = documento.nomeMae ?? '';
      _observacoesController.text = documento.observacoes ?? '';
      _ativo = documento.ativo;
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _nomeCompletoController.dispose();
    _orgaoEmissorController.dispose();
    _dataEmissaoController.dispose();
    _dataVencimentoController.dispose();
    _naturalidadeController.dispose();
    _nacionalidadeController.dispose();
    _nomePaiController.dispose();
    _nomeMaeController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.documento != null;

    return Dialog(
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.identificationCard(),
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditing
                        ? 'Editar Documento'
                        : 'Novo Documento de Identificação',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tipo
                      DropdownButtonFormField<TipoIdentificacao>(
                        value: _tipo,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Documento',
                          border: OutlineInputBorder(),
                        ),
                        items: TipoIdentificacao.values.map((tipo) {
                          return DropdownMenuItem(
                            value: tipo,
                            child: Row(
                              children: [
                                Icon(_getTipoIcon(tipo), size: 16),
                                const SizedBox(width: 8),
                                Text(_getTipoName(tipo)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (tipo) {
                          if (tipo != null) setState(() => _tipo = tipo);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Número e Nome Completo
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _numeroController,
                              decoration: const InputDecoration(
                                labelText: 'Número do Documento',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.credit_card),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Número é obrigatório';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _nomeCompletoController,
                              decoration: const InputDecoration(
                                labelText: 'Nome Completo',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nome é obrigatório';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Órgão Emissor
                      TextFormField(
                        controller: _orgaoEmissorController,
                        decoration: const InputDecoration(
                          labelText: 'Órgão Emissor',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_balance),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Datas
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dataEmissaoController,
                              decoration: const InputDecoration(
                                labelText: 'Data de Emissão',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _dataVencimentoController,
                              decoration: const InputDecoration(
                                labelText: 'Data de Vencimento',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.schedule),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Naturalidade e Nacionalidade
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _naturalidadeController,
                              decoration: const InputDecoration(
                                labelText: 'Naturalidade',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_city),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _nacionalidadeController,
                              decoration: const InputDecoration(
                                labelText: 'Nacionalidade',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.flag),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Nome dos Pais
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nomePaiController,
                              decoration: const InputDecoration(
                                labelText: 'Nome do Pai',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _nomeMaeController,
                              decoration: const InputDecoration(
                                labelText: 'Nome da Mãe',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Observações
                      TextFormField(
                        controller: _observacoesController,
                        decoration: const InputDecoration(
                          labelText: 'Observações',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 16),

                      // Ativo
                      SwitchListTile(
                        title: const Text('Documento Ativo'),
                        subtitle:
                            const Text('Desative para documentos cancelados'),
                        value: _ativo,
                        onChanged: (value) {
                          setState(() => _ativo = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDarkMode
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _salvar,
                    icon: Icon(isEditing
                        ? PhosphorIcons.check()
                        : PhosphorIcons.plus()),
                    label: Text(isEditing ? 'Salvar' : 'Adicionar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final documento = DocumentoIdentificacao(
        id: widget.documento?.id,
        tipo: _tipo,
        numero: _numeroController.text,
        nomeCompleto: _nomeCompletoController.text,
        orgaoEmissor: _orgaoEmissorController.text.isNotEmpty
            ? _orgaoEmissorController.text
            : null,
        dataEmissao: _dataEmissaoController.text.isNotEmpty
            ? _dataEmissaoController.text
            : null,
        dataVencimento: _dataVencimentoController.text.isNotEmpty
            ? _dataVencimentoController.text
            : null,
        naturalidade: _naturalidadeController.text.isNotEmpty
            ? _naturalidadeController.text
            : null,
        nacionalidade: _nacionalidadeController.text.isNotEmpty
            ? _nacionalidadeController.text
            : null,
        nomePai:
            _nomePaiController.text.isNotEmpty ? _nomePaiController.text : null,
        nomeMae:
            _nomeMaeController.text.isNotEmpty ? _nomeMaeController.text : null,
        observacoes: _observacoesController.text.isNotEmpty
            ? _observacoesController.text
            : null,
        ativo: _ativo,
      );

      widget.onAdd(documento);
      Navigator.of(context).pop();
    }
  }

  String _getTipoName(TipoIdentificacao tipo) {
    switch (tipo) {
      case TipoIdentificacao.rg:
        return 'RG';
      case TipoIdentificacao.cpf:
        return 'CPF';
      case TipoIdentificacao.cnh:
        return 'CNH';
      case TipoIdentificacao.passaporte:
        return 'Passaporte';
      case TipoIdentificacao.tituloEleitor:
        return 'Título de Eleitor';
      case TipoIdentificacao.carteiraTrabalho:
        return 'Carteira de Trabalho';
      case TipoIdentificacao.outros:
        return 'Outros';
    }
  }

  IconData _getTipoIcon(TipoIdentificacao tipo) {
    switch (tipo) {
      case TipoIdentificacao.rg:
        return Icons.badge;
      case TipoIdentificacao.cpf:
        return Icons.credit_card;
      case TipoIdentificacao.cnh:
        return Icons.drive_eta;
      case TipoIdentificacao.passaporte:
        return Icons.flight;
      case TipoIdentificacao.tituloEleitor:
        return Icons.how_to_vote;
      case TipoIdentificacao.carteiraTrabalho:
        return Icons.work;
      case TipoIdentificacao.outros:
        return Icons.description;
    }
  }
}
