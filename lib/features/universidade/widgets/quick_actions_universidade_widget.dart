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
import '../providers/universidade_provider.dart';
import '../widgets/add_universidade_dialog.dart';
import '../widgets/add_curso_dialog.dart';
import '../widgets/add_unidade_curricular_dialog.dart';
import '../widgets/add_avaliacao_dialog.dart';

class QuickActionsUniversidadeWidget extends ConsumerWidget {
  const QuickActionsUniversidadeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações Rápidas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _buildActionButton(
                  context,
                  'Nova Universidade',
                  Icons.school,
                  Colors.blue,
                  () => _showAddUniversidadeDialog(context, ref),
                ),
                _buildActionButton(
                  context,
                  'Novo Curso',
                  Icons.book,
                  Colors.green,
                  () => _showAddCursoDialog(context, ref),
                ),
                _buildActionButton(
                  context,
                  'Nova Disciplina',
                  Icons.subject,
                  Colors.orange,
                  () => _showAddUnidadeDialog(context, ref),
                ),
                _buildActionButton(
                  context,
                  'Nova Avaliação',
                  Icons.assignment,
                  Colors.purple,
                  () => _showAddAvaliacaoDialog(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUniversidadeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddUniversidadeDialog(
        onSave: (universidade) async {
          await ref.read(universidadesNotifierProvider.notifier).addUniversidade(universidade);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Universidade adicionada com sucesso!')),
            );
          }
        },
      ),
    );
  }

  void _showAddCursoDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddCursoDialog(
        onSave: (curso) async {
          await ref.read(cursosNotifierProvider.notifier).addCurso(curso);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Curso adicionado com sucesso!')),
            );
          }
        },
      ),
    );
  }

  void _showAddUnidadeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddUnidadeCurricularDialog(
        onSave: (unidade) async {
          await ref.read(unidadesCurricularesNotifierProvider.notifier).addUnidade(unidade);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Disciplina adicionada com sucesso!')),
            );
          }
        },
      ),
    );
  }

  void _showAddAvaliacaoDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddAvaliacaoDialog(
        onSave: (avaliacao) async {
          await ref.read(avaliacoesNotifierProvider.notifier).addAvaliacao(avaliacao);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Avaliação adicionada com sucesso!')),
            );
          }
        },
      ),
    );
  }
}