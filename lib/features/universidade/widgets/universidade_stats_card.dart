/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';

class UniversidadeStatsCard extends StatelessWidget {
  final Map<String, dynamic> estatisticas;

  const UniversidadeStatsCard({
    super.key,
    required this.estatisticas,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas Gerais',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _buildStatItem(
                  context,
                  'Universidades',
                  estatisticas['totalUniversidades']?.toString() ?? '0',
                  Icons.school,
                  Colors.blue,
                ),
                _buildStatItem(
                  context,
                  'Cursos',
                  estatisticas['totalCursos']?.toString() ?? '0',
                  Icons.book,
                  Colors.green,
                ),
                _buildStatItem(
                  context,
                  'Disciplinas',
                  estatisticas['totalUnidades']?.toString() ?? '0',
                  Icons.subject,
                  Colors.orange,
                ),
                _buildStatItem(
                  context,
                  'Avaliações',
                  estatisticas['totalAvaliacoes']?.toString() ?? '0',
                  Icons.assignment,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final totalAvaliacoes = estatisticas['totalAvaliacoes'] ?? 0;
    final avaliacoesRealizadas = estatisticas['avaliacoesRealizadas'] ?? 0;
    final avaliacoesPendentes = estatisticas['avaliacoesPendentes'] ?? 0;
    final avaliacoesEmAtraso = estatisticas['avaliacoesEmAtraso'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progresso das Avaliações',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildProgressBar(
          context,
          'Realizadas',
          avaliacoesRealizadas,
          totalAvaliacoes,
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildProgressBar(
          context,
          'Pendentes',
          avaliacoesPendentes,
          totalAvaliacoes,
          Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildProgressBar(
          context,
          'Em Atraso',
          avaliacoesEmAtraso,
          totalAvaliacoes,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, String label, int value, int total, Color color) {
    final percentage = total > 0 ? value / total : 0.0;
    
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '$value',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}