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
import 'documento_grid_card.dart';

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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Botão de adicionar
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            child: AnimatedActionButton(
              text: 'Adicionar Documento',
              onPressed: onAdd,
              isLoading: false,
              isEnabled: true,
              icon: PhosphorIcons.plus(),
            ),
          ),
          // Grid de documentos
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: documentos.length,
              itemBuilder: (context, index) {
                final documento = documentos[index];
                return _buildDocumentoGridCard(context, documento);
              },
            ),
          ),
        ],
      ),
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

  Widget _buildDocumentoGridCard(BuildContext context, DocumentoIdentificacao documento) {
    String informacaoSecundaria = documento.numeroFormatado;
    if (documento.orgaoEmissor != null) {
      informacaoSecundaria += ' • ${documento.orgaoEmissor}';
    }
    
    // Botões de ação customizados para incluir visualização se houver arquivos
    List<Widget> actionButtons = [];
    
    if (documento.temPdf || documento.temImagem) {
      actionButtons.add(
        _buildActionButton(
          PhosphorIcons.eye(),
          () {
            // TODO: Implementar visualização de arquivo
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Visualizar arquivo...')),
            );
          },
          'Visualizar',
        ),
      );
    }
    
    actionButtons.addAll([
      _buildActionButton(
        PhosphorIcons.pencil(),
        () => onEdit(documento),
        'Editar',
      ),
      _buildActionButton(
        PhosphorIcons.trash(),
        () => onDelete(documento.id),
        'Excluir',
      ),
    ]);
    
    return DocumentoGridCard(
      imagemPath: documento.arquivoImagemPath,
      titulo: documento.nomeTipo,
      subtitulo: documento.nomeCompleto,
      informacaoSecundaria: informacaoSecundaria,
      corPrimaria: documento.corTipo,
      iconePadrao: documento.iconeTipo,
      isVencido: documento.vencido || documento.venceEmBreve,
      actionButtons: actionButtons,
    );
  }
  
  Widget _buildActionButton(IconData icon, VoidCallback onPressed, String tooltip) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 12,
          color: Colors.white,
        ),
      ),
    );
  }
}
