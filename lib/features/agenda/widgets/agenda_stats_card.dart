import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';

class AgendaStatsCard extends ConsumerWidget {
  final Map<String, dynamic> stats;

  const AgendaStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estatísticas da Agenda',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Grid de estatísticas
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                context,
                'Total',
                '${stats['total'] ?? 0}',
                Icons.calendar_month,
                Colors.blue,
                isDarkMode,
              ),
              _buildStatCard(
                context,
                'Eventos',
                '${stats['events'] ?? 0}',
                Icons.event,
                Colors.green,
                isDarkMode,
              ),
              _buildStatCard(
                context,
                'Tarefas',
                '${stats['tasks'] ?? 0}',
                Icons.task,
                Colors.orange,
                isDarkMode,
              ),
              _buildStatCard(
                context,
                'Reuniões',
                '${stats['meetings'] ?? 0}',
                Icons.meeting_room,
                Colors.purple,
                isDarkMode,
              ),
              _buildStatCard(
                context,
                'Lembretes',
                '${stats['reminders'] ?? 0}',
                Icons.alarm,
                Colors.red,
                isDarkMode,
              ),
              _buildStatCard(
                context,
                'Concluídas',
                '${stats['completed'] ?? 0}',
                Icons.check_circle,
                Colors.green,
                isDarkMode,
              ),
              _buildStatCard(
                context,
                'Atrasadas',
                '${stats['overdue'] ?? 0}',
                Icons.warning,
                Colors.red,
                isDarkMode,
              ),
              _buildStatCard(
                context,
                'Hoje',
                '${stats['dueToday'] ?? 0}',
                Icons.today,
                Colors.blue,
                isDarkMode,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Informações adicionais
          if (stats['fromDatabase'] != null && stats['fromDatabase'] > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.storage,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${stats['fromDatabase']} itens sincronizados com a base de dados',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
