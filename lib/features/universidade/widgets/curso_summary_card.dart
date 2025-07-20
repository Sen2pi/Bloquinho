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
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/curso_model.dart';
import '../models/unidade_curricular_model.dart';
import '../providers/universidade_provider.dart';
import '../../../core/theme/app_colors.dart';

class CursoSummaryCard extends ConsumerWidget {
  final CursoModel curso;
  final VoidCallback? onTap;

  const CursoSummaryCard({
    super.key,
    required this.curso,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unidadesAsync = ref.watch(unidadesByCursoProvider(curso.id));
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              unidadesAsync.when(
                data: (unidades) => _buildStatistics(context, ref, unidades),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => _buildErrorState(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            PhosphorIcons.books(),
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                curso.nome,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (curso.codigo != null)
                Text(
                  curso.codigo!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        Icon(
          PhosphorIcons.caretRight(),
          color: Colors.grey[400],
          size: 16,
        ),
      ],
    );
  }

  Widget _buildStatistics(BuildContext context, WidgetRef ref, List<UnidadeCurricularModel> unidades) {
    if (unidades.isEmpty) {
      return _buildEmptyState(context);
    }

    final stats = _calculateStatistics(unidades);
    
    return Column(
      children: [
        _buildMainStatistics(context, stats),
        const SizedBox(height: 12),
        _buildProgressSection(context, stats),
      ],
    );
  }

  Widget _buildMainStatistics(BuildContext context, Map<String, dynamic> stats) {
    final mediaPonderada = stats['mediaPonderada'] as double?;
    final totalCreditos = stats['totalCreditos'] as int;
    final creditosCompletados = stats['creditosCompletados'] as int;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            'Média Geral',
            mediaPonderada != null ? mediaPonderada.toStringAsFixed(1) : 'N/A',
            PhosphorIcons.chartLine(),
            _getGradeColor(mediaPonderada),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            context,
            'Créditos',
            '$creditosCompletados/$totalCreditos',
            PhosphorIcons.graduationCap(),
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            context,
            'Disciplinas',
            '${stats['unidadesAtivas']}/${stats['totalUnidades']}',
            PhosphorIcons.books(),
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, Map<String, dynamic> stats) {
    final progressoCreditos = stats['progressoCreditos'] as double;
    final avaliacoesPendentes = stats['avaliacoesPendentes'] as int;
    final proximasAvaliacoes = stats['proximasAvaliacoes'] as int;
    
    return Column(
      children: [
        Row(
          children: [
            Icon(
              PhosphorIcons.chartPie(),
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              'Progresso do curso',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const Spacer(),
            Text(
              '${(progressoCreditos * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progressoCreditos,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (avaliacoesPendentes > 0) ...[
              _buildInfoChip(
                'Avaliações pendentes: $avaliacoesPendentes',
                Colors.orange,
                PhosphorIcons.clockCountdown(),
              ),
              const SizedBox(width: 8),
            ],
            if (proximasAvaliacoes > 0)
              _buildInfoChip(
                'Próximas avaliações: $proximasAvaliacoes',
                Colors.blue,
                PhosphorIcons.calendar(),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          children: [
            Icon(
              PhosphorIcons.books(),
              size: 32,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Nenhuma disciplina cadastrada',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          children: [
            Icon(
              PhosphorIcons.warning(),
              size: 32,
              color: Colors.red[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Erro ao carregar disciplinas',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateStatistics(List<UnidadeCurricularModel> unidades) {
    int totalCreditos = 0;
    int creditosCompletados = 0;
    double somaMediasPonderadas = 0;
    int totalCreditosComMedia = 0;
    int unidadesAtivas = 0;
    int avaliacoesPendentes = 0;
    int proximasAvaliacoes = 0;


    for (final unidade in unidades) {
      if (unidade.ativo) {
        unidadesAtivas++;
      }

      final creditos = unidade.creditos ?? 0;
      totalCreditos += creditos;

      if (unidade.mediaAtual != null && unidade.mediaAtual! > 0) {
        somaMediasPonderadas += unidade.mediaAtual! * creditos;
        totalCreditosComMedia += creditos;
        
        // Consideramos completada se a média for >= 10
        if (unidade.mediaAtual! >= 10) {
          creditosCompletados += creditos;
        }
      }

      // Contar avaliações pendentes e próximas (esta lógica pode ser expandida)
      // Por agora, assumimos que se não há média, há avaliações pendentes
      if (unidade.mediaAtual == null || unidade.mediaAtual! == 0) {
        avaliacoesPendentes++;
      }
    }

    final mediaPonderada = totalCreditosComMedia > 0 
        ? somaMediasPonderadas / totalCreditosComMedia 
        : null;

    final progressoCreditos = totalCreditos > 0 
        ? creditosCompletados / totalCreditos 
        : 0.0;

    return {
      'mediaPonderada': mediaPonderada,
      'totalCreditos': totalCreditos,
      'creditosCompletados': creditosCompletados,
      'progressoCreditos': progressoCreditos,
      'unidadesAtivas': unidadesAtivas,
      'totalUnidades': unidades.length,
      'avaliacoesPendentes': avaliacoesPendentes,
      'proximasAvaliacoes': proximasAvaliacoes,
    };
  }

  Color _getGradeColor(double? media) {
    if (media == null) return Colors.grey;
    if (media >= 16) return Colors.green;
    if (media >= 14) return Colors.lightGreen;
    if (media >= 12) return Colors.orange;
    if (media >= 10) return Colors.deepOrange;
    return Colors.red;
  }
}