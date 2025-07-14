import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/agenda_provider.dart';
import '../models/agenda_item.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';

class AgendaDashboard extends ConsumerWidget {
  const AgendaDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final items = ref.watch(agendaItemsProvider);
    final strings = ref.watch(appStringsProvider);

    // Filtrar eventos por período
    final todayItems = _getTodayItems(items);
    final thisWeekItems = _getThisWeekItems(items);
    final thisMonthItems = _getThisMonthItems(items);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.agendaDashboard,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Eventos de Hoje
              Expanded(
                child: _buildDashboardCard(
                  context,
                  strings.today,
                  todayItems,
                  Icons.today,
                  Colors.blue,
                  isDarkMode,
                  strings,
                ),
              ),
              const SizedBox(width: 12),
              // Eventos desta Semana
              Expanded(
                child: _buildDashboardCard(
                  context,
                  strings.thisWeek,
                  thisWeekItems,
                  Icons.view_week,
                  Colors.green,
                  isDarkMode,
                  strings,
                ),
              ),
              const SizedBox(width: 12),
              // Eventos deste Mês
              Expanded(
                child: _buildDashboardCard(
                  context,
                  strings.thisMonth,
                  thisMonthItems,
                  Icons.calendar_month,
                  Colors.orange,
                  isDarkMode,
                  strings,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    List<AgendaItem> items,
    IconData icon,
    Color color,
    bool isDarkMode,
    AppStrings strings,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(
              strings.noEvents,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            )
          else
            Column(
              children: items
                  .take(3)
                  .map((item) => _buildEventItem(context, item, isDarkMode, strings))
                  .toList(),
            ),
          if (items.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                strings.moreItems(items.length - 3),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventItem(
      BuildContext context, AgendaItem item, bool isDarkMode, AppStrings strings) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: item.priorityColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.displayTime.isNotEmpty ? item.displayTime : strings.noTime,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<AgendaItem> _getTodayItems(List<AgendaItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return items.where((item) {
      final eventDate = item.startDate ?? item.deadline;
      if (eventDate == null) return false;

      final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
      return eventDay.isAtSameMomentAs(today);
    }).toList()
      ..sort((a, b) {
        final aDate = a.startDate ?? a.deadline ?? DateTime.now();
        final bDate = b.startDate ?? b.deadline ?? DateTime.now();
        return aDate.compareTo(bDate);
      });
  }

  List<AgendaItem> _getThisWeekItems(List<AgendaItem> items) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return items.where((item) {
      final eventDate = item.startDate ?? item.deadline;
      if (eventDate == null) return false;

      return eventDate.isAfter(startOfWeek) && eventDate.isBefore(endOfWeek);
    }).toList()
      ..sort((a, b) {
        final aDate = a.startDate ?? a.deadline ?? DateTime.now();
        final bDate = b.startDate ?? b.deadline ?? DateTime.now();
        return aDate.compareTo(bDate);
      });
  }

  List<AgendaItem> _getThisMonthItems(List<AgendaItem> items) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    return items.where((item) {
      final eventDate = item.startDate ?? item.deadline;
      if (eventDate == null) return false;

      return eventDate.isAfter(startOfMonth) && eventDate.isBefore(endOfMonth);
    }).toList()
      ..sort((a, b) {
        final aDate = a.startDate ?? a.deadline ?? DateTime.now();
        final bDate = b.startDate ?? b.deadline ?? DateTime.now();
        return aDate.compareTo(bDate);
      });
  }
}
