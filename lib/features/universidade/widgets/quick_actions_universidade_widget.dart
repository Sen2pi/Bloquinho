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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flash_on,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Ações Rápidas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Primeira linha - Universidade e Curso
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildModernActionButton(
                  context,
                  'Nova Universidade',
                  Icons.school,
                  const Color(0xFF4F46E5),
                  () => _showAddUniversidadeDialog(context, ref),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernActionButton(
                  context,
                  'Novo Curso',
                  Icons.book,
                  const Color(0xFF10B981),
                  () => _showAddCursoDialog(context, ref),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Segunda linha - Disciplina e Avaliação
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildModernActionButton(
                  context,
                  'Nova Disciplina',
                  Icons.subject,
                  const Color(0xFFF59E0B),
                  () => _showAddUnidadeDialog(context, ref),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernActionButton(
                  context,
                  'Nova Avaliação',
                  Icons.assignment,
                  const Color(0xFF8B5CF6),
                  () => _showAddAvaliacaoDialog(context, ref),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
          await ref
              .read(universidadesNotifierProvider.notifier)
              .addUniversidade(universidade);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Universidade adicionada com sucesso!')),
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
          await ref
              .read(unidadesCurricularesNotifierProvider.notifier)
              .addUnidade(unidade);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Disciplina adicionada com sucesso!')),
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
          await ref
              .read(avaliacoesNotifierProvider.notifier)
              .addAvaliacao(avaliacao);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Avaliação adicionada com sucesso!')),
            );
          }
        },
      ),
    );
  }
}
