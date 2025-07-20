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
import '../widgets/universidade_stats_card.dart';
import '../widgets/recent_avaliacoes_widget.dart';
import '../widgets/cursos_overview_widget.dart';
import '../widgets/quick_actions_universidade_widget.dart';
import '../widgets/universidade_charts_widget.dart';
import '../widgets/add_universidade_dialog.dart';
import '../widgets/add_curso_dialog.dart';
import '../widgets/add_unidade_curricular_dialog.dart';
import '../widgets/add_avaliacao_dialog.dart';
import 'universidades_screen.dart';
import 'cursos_screen.dart';
import 'unidades_curriculares_screen.dart';
import 'avaliacoes_screen.dart';

class UniversidadeDashboardScreen extends ConsumerWidget {
  const UniversidadeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(universidadeDashboardTabProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Gestão Universitária'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(ref),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildModernTabBar(context, ref),
          Expanded(
            child: IndexedStack(
              index: tabIndex,
              children: const [
                _ModernDashboardTab(),
                UniversidadesScreen(),
                CursosScreen(),
                UnidadesCurricularesScreen(),
                AvaliacoesScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTabBar(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(universidadeDashboardTabProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(4.0),
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
          _buildModernTabButton(
              context, ref, 0, 'Dashboard', Icons.dashboard, tabIndex),
          _buildModernTabButton(
              context, ref, 1, 'Universidades', Icons.school, tabIndex),
          _buildModernTabButton(
              context, ref, 2, 'Cursos', Icons.book, tabIndex),
          _buildModernTabButton(
              context, ref, 3, 'Disciplinas', Icons.subject, tabIndex),
          _buildModernTabButton(
              context, ref, 4, 'Avaliações', Icons.assignment, tabIndex),
        ],
      ),
    );
  }

  Widget _buildModernTabButton(BuildContext context, WidgetRef ref, int index,
      String label, IconData icon, int currentIndex) {
    final isSelected = currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () =>
            ref.read(universidadeDashboardTabProvider.notifier).state = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
            ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : isDark
                        ? Colors.grey[400]
                        : Colors.grey[600],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
            ? Theme.of(context).colorScheme.onPrimary
                          : isDark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Digite para buscar...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  void _refreshData(WidgetRef ref) {
    ref.invalidate(universidadesProvider);
    ref.invalidate(cursosProvider);
    ref.invalidate(unidadesCurricularesProvider);
    ref.invalidate(avaliacoesProvider);
    ref.invalidate(estatisticasUniversidadeProvider);
  }
}

class _ModernDashboardTab extends ConsumerWidget {
  const _ModernDashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estatisticasAsync = ref.watch(estatisticasUniversidadeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(context),
          const SizedBox(height: 24),
          estatisticasAsync.when(
            data: (stats) => _buildModernStatsSection(context, stats),
            loading: () => _buildLoadingStats(context),
            error: (error, stack) => _buildErrorStats(context, error),
          ),
          const SizedBox(height: 24),
          _buildModernQuickActions(context, ref),
          const SizedBox(height: 24),
          const UniversidadeChartsWidget(),
          const SizedBox(height: 24),
          _buildOverviewSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF2A2A2A),
                  const Color(0xFF3A3A3A),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF0F0F0),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.school,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo ao seu',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                ),
          Text(
                  'Dashboard Universitário',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatsSection(
      BuildContext context, Map<String, dynamic> stats) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estatísticas Gerais',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCompactStatCard(
                context,
                'Universidades',
                stats['totalUniversidades']?.toString() ?? '0',
                Icons.school,
                const Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactStatCard(
                context,
                'Cursos',
                stats['totalCursos']?.toString() ?? '0',
                Icons.book,
                const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactStatCard(
                context,
                'Disciplinas',
                stats['totalUnidades']?.toString() ?? '0',
                Icons.subject,
                const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactStatCard(
                context,
                'Avaliações',
                stats['totalAvaliacoes']?.toString() ?? '0',
                Icons.assignment,
                const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildProgressCharts(context, stats),
      ],
    );
  }

  Widget _buildCompactStatCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCharts(
      BuildContext context, Map<String, dynamic> stats) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalAvaliacoes = stats['totalAvaliacoes'] ?? 0;
    final avaliacoesRealizadas = stats['avaliacoesRealizadas'] ?? 0;
    final avaliacoesPendentes = stats['avaliacoesPendentes'] ?? 0;
    final avaliacoesEmAtraso = stats['avaliacoesEmAtraso'] ?? 0;

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
          Text(
            'Progresso das Avaliações',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            context,
            'Realizadas',
            avaliacoesRealizadas,
            totalAvaliacoes,
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          _buildProgressBar(
            context,
            'Pendentes',
            avaliacoesPendentes,
            totalAvaliacoes,
            const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 12),
          _buildProgressBar(
            context,
            'Em Atraso',
            avaliacoesEmAtraso,
            totalAvaliacoes,
            const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
      BuildContext context, String label, int value, int total, Color color) {
    final percentage = total > 0 ? value / total : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
            ),
            Text(
              '$value/$total',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildLoadingStats(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorStats(BuildContext context, Object error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'Erro ao carregar estatísticas: $error',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red,
              ),
        ),
      ),
    );
  }

  Widget _buildModernQuickActions(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
        ),
        const SizedBox(height: 16),
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
                child: _buildQuickActionButton(
                  context,
                  'Nova Universidade',
                  Icons.school,
                  const Color(0xFF4F46E5),
                  () => _showAddUniversidadeDialog(context, ref),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
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
                child: _buildQuickActionButton(
                  context,
                  'Nova Disciplina',
                  Icons.subject,
                  const Color(0xFFF59E0B),
                  () => _showAddUnidadeDialog(context, ref),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
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

  Widget _buildQuickActionButton(
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
            Icon(icon, color: color, size: 28),
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



  Widget _buildOverviewSection(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visão Geral',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
        ),
        const SizedBox(height: 16),
        const CursosOverviewWidget(),
        const SizedBox(height: 16),
        const RecentAvaliacoesWidget(),
      ],
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
