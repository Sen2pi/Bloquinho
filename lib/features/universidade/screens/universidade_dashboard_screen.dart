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
import 'universidades_screen.dart';
import 'cursos_screen.dart';
import 'unidades_curriculares_screen.dart';
import 'avaliacoes_screen.dart';

class UniversidadeDashboardScreen extends ConsumerWidget {
  const UniversidadeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(universidadeDashboardTabProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão Universitária'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
          _buildTabBar(context, ref),
          Expanded(
            child: IndexedStack(
              index: tabIndex,
              children: const [
                _DashboardTab(),
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

  Widget _buildTabBar(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(universidadeDashboardTabProvider);
    
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTabButton(context, ref, 0, 'Dashboard', Icons.dashboard, tabIndex),
            _buildTabButton(context, ref, 1, 'Universidades', Icons.school, tabIndex),
            _buildTabButton(context, ref, 2, 'Cursos', Icons.book, tabIndex),
            _buildTabButton(context, ref, 3, 'Disciplinas', Icons.subject, tabIndex),
            _buildTabButton(context, ref, 4, 'Avaliações', Icons.assignment, tabIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, WidgetRef ref, int index, String label, IconData icon, int currentIndex) {
    final isSelected = currentIndex == index;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton.icon(
        onPressed: () => ref.read(universidadeDashboardTabProvider.notifier).state = index,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
          foregroundColor: isSelected 
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estatisticasAsync = ref.watch(estatisticasUniversidadeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo Geral',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          estatisticasAsync.when(
            data: (stats) => UniversidadeStatsCard(estatisticas: stats),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Erro ao carregar estatísticas: $error'),
            ),
          ),
          
          const SizedBox(height: 24),
          
          const QuickActionsUniversidadeWidget(),
          
          const SizedBox(height: 24),
          
          Text(
            'Visão Geral dos Cursos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          const CursosOverviewWidget(),
          
          const SizedBox(height: 24),
          
          Text(
            'Avaliações Recentes',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          const RecentAvaliacoesWidget(),
        ],
      ),
    );
  }
}