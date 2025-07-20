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
import '../models/tipo_curso_enum.dart';

class CursosOverviewWidget extends ConsumerWidget {
  const CursosOverviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cursosAsync = ref.watch(cursosProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.book,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cursos Ativos',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  ref.read(universidadeDashboardTabProvider.notifier).state = 2;
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Ver todos'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          cursosAsync.when(
            data: (cursos) {
              final cursosAtivos = cursos.where((c) => c.ativo).toList();

              if (cursosAtivos.isEmpty) {
                return _buildEmptyState(context);
              }

              return Column(
                children: cursosAtivos
                    .take(3)
                    .map((curso) => _buildModernCursoItem(context, ref, curso))
                    .toList(),
              );
            },
            loading: () => _buildLoadingState(context),
            error: (error, stack) => _buildErrorState(context, error),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.book,
              size: 48,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum curso ativo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Erro ao carregar cursos: $error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red[400],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernCursoItem(
      BuildContext context, WidgetRef ref, CursoModel curso) {
    final unidadesAsync = ref.watch(unidadesByCursoProvider(curso.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getTipoColor(curso.tipo).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getTipoColor(curso.tipo).withOpacity(0.3),
              ),
            ),
            child: Icon(
              _getTipoIcon(curso.tipo),
              color: _getTipoColor(curso.tipo),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  curso.nome,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  curso.tipo.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getTipoColor(curso.tipo),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                unidadesAsync.when(
                  data: (unidades) {
                    final totalEcts = unidades
                        .where((u) => u.creditos != null)
                        .fold<int>(0, (sum, u) => sum + (u.creditos ?? 0));

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${unidades.length} disciplinas',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                        ),
                        if (totalEcts > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            '$totalEcts ECTS',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[500],
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                      ],
                    );
                  },
                  loading: () => Text(
                    'Carregando...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                  ),
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
                  color: _getStatusColor(curso.statusCurso).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(curso.statusCurso).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  curso.statusCurso,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(curso.statusCurso),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (curso.mediaAtual != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: curso.aprovado
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: curso.aprovado
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Média: ${curso.mediaAtual!.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: curso.aprovado ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getTipoColor(TipoCurso tipo) {
    switch (tipo) {
      case TipoCurso.licenciatura:
        return const Color(0xFF4F46E5);
      case TipoCurso.mestrado:
        return const Color(0xFF10B981);
      case TipoCurso.posGraduacao:
        return const Color(0xFFF59E0B);
      case TipoCurso.doutoramento:
        return const Color(0xFF8B5CF6);
    }
  }

  IconData _getTipoIcon(TipoCurso tipo) {
    switch (tipo) {
      case TipoCurso.licenciatura:
        return Icons.school;
      case TipoCurso.mestrado:
        return Icons.military_tech;
      case TipoCurso.posGraduacao:
        return Icons.workspace_premium;
      case TipoCurso.doutoramento:
        return Icons.psychology;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'em curso':
        return const Color(0xFF4F46E5);
      case 'concluído':
        return const Color(0xFF10B981);
      case 'não iniciado':
        return const Color(0xFFF59E0B);
      case 'inativo':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
