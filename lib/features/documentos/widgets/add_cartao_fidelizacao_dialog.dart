import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/cartao_fidelizacao.dart';
import '../../../core/theme/app_colors.dart';

class AddCartaoFidelizacaoDialog extends StatefulWidget {
  final void Function(CartaoFidelizacao) onAdd;
  final CartaoFidelizacao? cartao; // Para edição

  const AddCartaoFidelizacaoDialog({
    super.key,
    required this.onAdd,
    this.cartao,
  });

  @override
  State<AddCartaoFidelizacaoDialog> createState() =>
      _AddCartaoFidelizacaoDialogState();
}

class _AddCartaoFidelizacaoDialogState
    extends State<AddCartaoFidelizacaoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _empresaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _nomeImpressoController = TextEditingController();
  final _validadeController = TextEditingController();
  final _pontosAtuaisController = TextEditingController();
  final _pontosExpiracaoController = TextEditingController();
  final _beneficiosController = TextEditingController();
  final _websiteController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _observacoesController = TextEditingController();

  TipoFidelizacao _tipo = TipoFidelizacao.pontos;
  bool _ativo = true;

  @override
  void initState() {
    super.initState();
    if (widget.cartao != null) {
      // Modo edição
      final cartao = widget.cartao!;
      _tipo = cartao.tipo;
      _nomeController.text = cartao.nome;
      _empresaController.text = cartao.empresa;
      _numeroController.text = cartao.numero;
      _nomeImpressoController.text = cartao.nomeImpresso ?? '';
      _validadeController.text = cartao.validade ?? '';
      _pontosAtuaisController.text = cartao.pontosAtuais ?? '';
      _pontosExpiracaoController.text = cartao.pontosExpiracao ?? '';
      _beneficiosController.text = cartao.beneficios ?? '';
      _websiteController.text = cartao.website ?? '';
      _telefoneController.text = cartao.telefone ?? '';
      _emailController.text = cartao.email ?? '';
      _observacoesController.text = cartao.observacoes ?? '';
      _ativo = cartao.ativo;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _empresaController.dispose();
    _numeroController.dispose();
    _nomeImpressoController.dispose();
    _validadeController.dispose();
    _pontosAtuaisController.dispose();
    _pontosExpiracaoController.dispose();
    _beneficiosController.dispose();
    _websiteController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.cartao != null;

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
                    PhosphorIcons.star(),
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? 'Editar Cartão' : 'Novo Cartão de Fidelização',
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
                      DropdownButtonFormField<TipoFidelizacao>(
                        value: _tipo,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Fidelização',
                          border: OutlineInputBorder(),
                        ),
                        items: TipoFidelizacao.values.map((tipo) {
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

                      // Nome e Empresa
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nomeController,
                              decoration: const InputDecoration(
                                labelText: 'Nome do Cartão',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.card_giftcard),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nome é obrigatório';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _empresaController,
                              decoration: const InputDecoration(
                                labelText: 'Empresa',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.business),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Empresa é obrigatória';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Número e Nome Impresso
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _numeroController,
                              decoration: const InputDecoration(
                                labelText: 'Número do Cartão',
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
                              controller: _nomeImpressoController,
                              decoration: const InputDecoration(
                                labelText: 'Nome Impresso',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Validade
                      TextFormField(
                        controller: _validadeController,
                        decoration: const InputDecoration(
                          labelText: 'Validade (MM/AA)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Pontos
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _pontosAtuaisController,
                              decoration: const InputDecoration(
                                labelText: 'Pontos Atuais',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.stars),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _pontosExpiracaoController,
                              decoration: const InputDecoration(
                                labelText: 'Data Expiração Pontos',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.schedule),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Benefícios
                      TextFormField(
                        controller: _beneficiosController,
                        decoration: const InputDecoration(
                          labelText: 'Benefícios',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.card_giftcard),
                        ),
                        maxLines: 2,
                      ),

                      const SizedBox(height: 16),

                      // Contato
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _websiteController,
                              decoration: const InputDecoration(
                                labelText: 'Website',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.language),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _telefoneController,
                              decoration: const InputDecoration(
                                labelText: 'Telefone',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
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
                        title: const Text('Cartão Ativo'),
                        subtitle:
                            const Text('Desative para cartões cancelados'),
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
      final cartao = CartaoFidelizacao(
        id: widget.cartao?.id,
        nome: _nomeController.text,
        empresa: _empresaController.text,
        numero: _numeroController.text,
        nomeImpresso: _nomeImpressoController.text.isNotEmpty
            ? _nomeImpressoController.text
            : null,
        validade: _validadeController.text.isNotEmpty
            ? _validadeController.text
            : null,
        tipo: _tipo,
        pontosAtuais: _pontosAtuaisController.text.isNotEmpty
            ? _pontosAtuaisController.text
            : null,
        pontosExpiracao: _pontosExpiracaoController.text.isNotEmpty
            ? _pontosExpiracaoController.text
            : null,
        beneficios: _beneficiosController.text.isNotEmpty
            ? _beneficiosController.text
            : null,
        website:
            _websiteController.text.isNotEmpty ? _websiteController.text : null,
        telefone: _telefoneController.text.isNotEmpty
            ? _telefoneController.text
            : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        ativo: _ativo,
        observacoes: _observacoesController.text.isNotEmpty
            ? _observacoesController.text
            : null,
      );

      widget.onAdd(cartao);
      Navigator.of(context).pop();
    }
  }

  String _getTipoName(TipoFidelizacao tipo) {
    switch (tipo) {
      case TipoFidelizacao.pontos:
        return 'Pontos';
      case TipoFidelizacao.milhas:
        return 'Milhas';
      case TipoFidelizacao.desconto:
        return 'Desconto';
      case TipoFidelizacao.cashback:
        return 'Cashback';
      case TipoFidelizacao.outros:
        return 'Outros';
    }
  }

  IconData _getTipoIcon(TipoFidelizacao tipo) {
    switch (tipo) {
      case TipoFidelizacao.pontos:
        return Icons.stars;
      case TipoFidelizacao.milhas:
        return Icons.flight;
      case TipoFidelizacao.desconto:
        return Icons.discount;
      case TipoFidelizacao.cashback:
        return Icons.account_balance_wallet;
      case TipoFidelizacao.outros:
        return Icons.card_giftcard;
    }
  }
}
