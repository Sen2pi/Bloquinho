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
import '../models/curso_model.dart';

class CursosOverviewWidget extends ConsumerWidget {
  const CursosOverviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cursosAsync = ref.watch(cursosProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cursos Ativos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(universidadeDashboardTabProvider.notifier).state = 2;
                  },
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            cursosAsync.when(
              data: (cursos) {
                final cursosAtivos = cursos.where((c) => c.ativo).toList();
                
                if (cursosAtivos.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.book, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Nenhum curso ativo'),
                        ],
                      ),
                    ),
                  );
                }
                
                return Column(
                  children: cursosAtivos.take(3).map((curso) => 
                    _buildCursoItem(context, ref, curso)
                  ).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Erro ao carregar cursos: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCursoItem(BuildContext context, WidgetRef ref, CursoModel curso) {
    final unidadesAsync = ref.watch(unidadesByCursoProvider(curso.id));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getTipoColor(curso.tipo).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTipoIcon(curso.tipo),
              color: _getTipoColor(curso.tipo),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  curso.nome,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  curso.tipo.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getTipoColor(curso.tipo),
                  ),
                ),
                unidadesAsync.when(
                  data: (unidades) => Text(
                    '${unidades.length} disciplinas',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(curso.statusCurso).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  curso.statusCurso,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(curso.statusCurso),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (curso.mediaAtual != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Média: ${curso.mediaAtual!.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: curso.aprovado ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTipoColor(TipoCurso tipo) {
    switch (tipo) {
      case TipoCurso.licenciatura:
        return Colors.blue;
      case TipoCurso.mestrado:
        return Colors.green;
      case TipoCurso.posGraduacao:
        return Colors.orange;
      case TipoCurso.doutoramento:
        return Colors.purple;
    }
  }

  IconData _getTipoIcon(TipoCurso tipo) {
    switch (tipo) {
      case TipoCurso.licenciatura:
        return Icons.school;
      case TipoCurso.mestrado:
        return Icons.academic_cap;
      case TipoCurso.posGraduacao:
        return Icons.workspace_premium;
      case TipoCurso.doutoramento:
        return Icons.psychology;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'em curso':
        return Colors.blue;
      case 'concluído':
        return Colors.green;
      case 'não iniciado':
        return Colors.orange;
      case 'inativo':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}