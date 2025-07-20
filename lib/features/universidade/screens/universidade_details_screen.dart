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

import '../models/universidade_model.dart';
import '../models/curso_model.dart';
import '../providers/universidade_provider.dart';
import '../widgets/curso_summary_card.dart';
import '../../../core/theme/app_colors.dart';

class UniversidadeDetailsScreen extends ConsumerWidget {
  final UniversidadeModel universidade;

  const UniversidadeDetailsScreen({
    super.key,
    required this.universidade,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cursosAsync = ref.watch(cursosByUniversidadeProvider(universidade.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                universidade.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Icon(
                        PhosphorIcons.graduationCap(),
                        size: 200,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUniversityInfo(context, universidade),
                  const SizedBox(height: 24),
                  cursosAsync.when(
                    data: (cursos) => _buildCoursesSection(context, ref, cursos),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stack) => _buildErrorWidget(context, error),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUniversityInfo(BuildContext context, UniversidadeModel universidade) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  PhosphorIcons.info(),
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Informações Gerais',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (universidade.sigla != null)
              _buildInfoRow(
                context,
                'Sigla',
                universidade.sigla!,
                PhosphorIcons.tag(),
              ),
            if (universidade.descricao != null)
              _buildInfoRow(
                context,
                'Descrição',
                universidade.descricao!,
                PhosphorIcons.textAa(),
              ),
            if (universidade.cidade != null || universidade.pais != null)
              _buildInfoRow(
                context,
                'Localização',
                [universidade.cidade, universidade.pais]
                    .where((e) => e != null)
                    .join(', '),
                PhosphorIcons.mapPin(),
              ),
            if (universidade.website != null)
              _buildInfoRow(
                context,
                'Website',
                universidade.website!,
                PhosphorIcons.globe(),
              ),
            _buildInfoRow(
              context,
              'Criada em',
              '${universidade.createdAt.day}/${universidade.createdAt.month}/${universidade.createdAt.year}',
              PhosphorIcons.calendar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesSection(BuildContext context, WidgetRef ref, List<CursoModel> cursos) {
    if (cursos.isEmpty) {
      return _buildEmptyCoursesState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              PhosphorIcons.books(),
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Cursos (${cursos.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cursos.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final curso = cursos[index];
            return CursoSummaryCard(
              curso: curso,
              onTap: () => _navigateToCursoDetails(context, curso),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyCoursesState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                PhosphorIcons.books(),
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum curso encontrado',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Adicione cursos para esta universidade',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, Object error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                PhosphorIcons.warning(),
                size: 48,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar cursos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCursoDetails(BuildContext context, CursoModel curso) {
    // TODO: Implementar navegação para detalhes do curso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegar para detalhes do curso: ${curso.nome}'),
      ),
    );
  }
}