/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import '../models/avaliacao_model.dart';

class AvaliacaoCard extends StatelessWidget {
  final AvaliacaoModel avaliacao;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AvaliacaoCard({
    super.key,
    required this.avaliacao,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTipoIcon(),
                      color: _getStatusColor(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          avaliacao.nome,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          avaliacao.tipo.displayName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _getStatusColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      avaliacao.status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (avaliacao.dataAvaliacao != null || avaliacao.dataEntrega != null) ...[
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _getDataText(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (avaliacao.nota != null) ...[
                    Icon(Icons.grade, size: 16, color: _getNotaColor()),
                    const SizedBox(width: 4),
                    Text(
                      '${avaliacao.nota!.toStringAsFixed(1)}/${avaliacao.notaMaxima}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getNotaColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getNotaColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${avaliacao.percentualNota.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getNotaColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else
                    const Spacer(),
                  if (!avaliacao.realizada && !avaliacao.entregue && avaliacao.diasParaEntrega >= 0)
                    Text(
                      avaliacao.diasParaEntrega == 0 
                        ? 'Hoje'
                        : avaliacao.diasParaEntrega == 1
                          ? 'Amanhã'
                          : '${avaliacao.diasParaEntrega} dias',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: avaliacao.emAtraso ? Colors.red : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDataText() {
    final data = avaliacao.dataAvaliacao ?? avaliacao.dataEntrega;
    if (data == null) return '';
    return '${data.day}/${data.month}/${data.year}';
  }

  Color _getStatusColor() {
    if (avaliacao.emAtraso) return Colors.red;
    
    switch (avaliacao.status.toLowerCase()) {
      case 'aprovado':
        return Colors.green;
      case 'reprovado':
        return Colors.red;
      case 'pendente':
        return Colors.orange;
      case 'aguardando correção':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getNotaColor() {
    if (avaliacao.nota == null) return Colors.grey;
    return avaliacao.aprovado ? Colors.green : Colors.red;
  }

  IconData _getTipoIcon() {
    switch (avaliacao.tipo) {
      case TipoAvaliacao.teste:
        return Icons.quiz;
      case TipoAvaliacao.exame:
        return Icons.school;
      case TipoAvaliacao.trabalho:
        return Icons.assignment;
      case TipoAvaliacao.projeto:
        return Icons.engineering;
      case TipoAvaliacao.apresentacao:
        return Icons.presentation_chart;
      case TipoAvaliacao.laboratorio:
        return Icons.science;
      case TipoAvaliacao.participacao:
        return Icons.forum;
      case TipoAvaliacao.outro:
        return Icons.assignment_outlined;
    }
  }
}