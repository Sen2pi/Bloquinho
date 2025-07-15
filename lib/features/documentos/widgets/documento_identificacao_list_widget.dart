/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/documento_identificacao.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_action_button.dart';

class DocumentoIdentificacaoListWidget extends StatelessWidget {
  final List<DocumentoIdentificacao> documentos;
  final bool isLoading;
  final VoidCallback onAdd;
  final Function(DocumentoIdentificacao) onEdit;
  final Function(String) onDelete;

  const DocumentoIdentificacaoListWidget({
    super.key,
    required this.documentos,
    required this.isLoading,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (documentos.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documentos.length,
      itemBuilder: (context, index) {
        final documento = documentos[index];
        return _buildDocumentoCard(context, documento);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.identificationCard(),
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum documento de identificação',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione seus documentos de identificação',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 16),
          AnimatedActionButton(
            text: 'Adicionar Documento',
            onPressed: onAdd,
            isLoading: false,
            isEnabled: true,
            icon: PhosphorIcons.plus(),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentoCard(
      BuildContext context, DocumentoIdentificacao documento) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              documento.corTipo,
              documento.corTipo.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    documento.iconeTipo,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          documento.nomeTipo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          documento.nomeCompleto,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (documento.temPdf || documento.temImagem) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (documento.temPdf)
                            Icon(
                              PhosphorIcons.filePdf(),
                              color: Colors.white,
                              size: 12,
                            ),
                          if (documento.temImagem)
                            Icon(
                              PhosphorIcons.image(),
                              color: Colors.white,
                              size: 12,
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Text(
                documento.numeroFormatado,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              if (documento.orgaoEmissor != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Órgão: ${documento.orgaoEmissor}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
              if (documento.dataEmissao != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Emissão: ${documento.dataEmissao}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
              if (documento.dataVencimento != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Vencimento: ${documento.dataVencimento}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
              if (documento.vencido) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'VENCIDO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ] else if (documento.venceEmBreve) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'VENCE EM BREVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (documento.temPdf || documento.temImagem)
                    IconButton(
                      onPressed: () {
                        // TODO: Implementar visualização de arquivo
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Visualizar arquivo...')),
                        );
                      },
                      icon: Icon(
                        PhosphorIcons.eye(),
                        color: Colors.white,
                        size: 16,
                      ),
                      tooltip: 'Visualizar',
                    ),
                  IconButton(
                    onPressed: () => onEdit(documento),
                    icon: Icon(
                      PhosphorIcons.pencil(),
                      color: Colors.white,
                      size: 16,
                    ),
                    tooltip: 'Editar',
                  ),
                  IconButton(
                    onPressed: () => onDelete(documento.id),
                    icon: Icon(
                      PhosphorIcons.trash(),
                      color: Colors.white,
                      size: 16,
                    ),
                    tooltip: 'Excluir',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
