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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Estatísticas Gerais',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
              ),
            ],
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
              _buildModernStatItem(
                context,
                'Universidades',
                estatisticas['totalUniversidades']?.toString() ?? '0',
                Icons.school,
                const Color(0xFF4F46E5),
              ),
              _buildModernStatItem(
                context,
                'Cursos',
                estatisticas['totalCursos']?.toString() ?? '0',
                Icons.book,
                const Color(0xFF10B981),
              ),
              _buildModernStatItem(
                context,
                'Disciplinas',
                estatisticas['totalUnidades']?.toString() ?? '0',
                Icons.subject,
                const Color(0xFFF59E0B),
              ),
              _buildModernStatItem(
                context,
                'Avaliações',
                estatisticas['totalAvaliacoes']?.toString() ?? '0',
                Icons.assignment,
                const Color(0xFF8B5CF6),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildModernProgressSection(context),
        ],
      ),
    );
  }

  Widget _buildModernStatItem(BuildContext context, String label, String value,
      IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

  Widget _buildModernProgressSection(BuildContext context) {
    final totalAvaliacoes = estatisticas['totalAvaliacoes'] ?? 0;
    final avaliacoesRealizadas = estatisticas['avaliacoesRealizadas'] ?? 0;
    final avaliacoesPendentes = estatisticas['avaliacoesPendentes'] ?? 0;
    final avaliacoesEmAtraso = estatisticas['avaliacoesEmAtraso'] ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.trending_up,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Progresso das Avaliações',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildModernProgressBar(
          context,
          'Realizadas',
          avaliacoesRealizadas,
          totalAvaliacoes,
          const Color(0xFF10B981),
          Icons.check_circle,
        ),
        const SizedBox(height: 12),
        _buildModernProgressBar(
          context,
          'Pendentes',
          avaliacoesPendentes,
          totalAvaliacoes,
          const Color(0xFFF59E0B),
          Icons.schedule,
        ),
        const SizedBox(height: 12),
        _buildModernProgressBar(
          context,
          'Em Atraso',
          avaliacoesEmAtraso,
          totalAvaliacoes,
          const Color(0xFFEF4444),
          Icons.warning,
        ),
      ],
    );
  }

  Widget _buildModernProgressBar(BuildContext context, String label, int value,
      int total, Color color, IconData icon) {
    final percentage = total > 0 ? value / total : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
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
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 8,
                width: MediaQuery.of(context).size.width * 0.6 * percentage,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
