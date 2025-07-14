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
import 'package:table_calendar/table_calendar.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/agenda_provider.dart';
import '../models/agenda_item.dart';
import 'agenda_item_card.dart';
import 'add_agenda_item_dialog.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';

class AgendaCalendarView extends ConsumerWidget {
  final DateTime? focusedDay;
  final DateTime? selectedDay;
  final OnDaySelected? onDaySelected;

  const AgendaCalendarView({
    super.key,
    this.focusedDay,
    this.selectedDay,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final items = ref.watch(filteredAgendaItemsProvider);
    final selectedDate = ref.watch(agendaProvider).selectedDate;
    final strings = ref.watch(appStringsProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Calendário
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: TableCalendar<AgendaItem>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: focusedDay ?? DateTime.now(),
              selectedDayPredicate: (day) =>
                  isSameDay(selectedDay ?? DateTime.now(), day),
              onDaySelected: onDaySelected,
              calendarFormat: CalendarFormat.month,
              eventLoader: (day) => _getEventsForDay(day, items),
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(color: Colors.red[400]),
                holidayTextStyle: TextStyle(color: Colors.red[400]),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle:
                    Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ) ??
                        const TextStyle(),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ) ??
                    const TextStyle(),
                weekendStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.red[400],
                        ) ??
                    const TextStyle(),
              ),
            ),
          ),

          // Lista de eventos do dia selecionado
          Container(
            height: 300, // Altura fixa para a lista de eventos
            child: _buildEventsList(context, selectedDate ?? DateTime.now(),
                items, isDarkMode, strings),
          ),
        ],
      ),
    );
  }

  List<AgendaItem> _getEventsForDay(DateTime day, List<AgendaItem> items) {
    return items.where((item) {
      final itemDate = item.startDate ?? item.deadline;
      if (itemDate == null) return false;

      return isSameDay(itemDate, day);
    }).toList();
  }

  Widget _buildEventsList(BuildContext context, DateTime date,
      List<AgendaItem> items, bool isDarkMode, AppStrings strings) {
    final dayEvents = _getEventsForDay(date, items);

    if (dayEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              strings.noEventsForDate(_formatDate(date)),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.addAnEventToStart,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dayEvents.length,
      itemBuilder: (context, index) {
        final item = dayEvents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AgendaItemCard(
            item: item,
            onTap: () => _showItemDetails(context, item, strings),
            onEdit: () => _showEditItemDialog(context, item),
            onDelete: () => _showDeleteConfirmation(context, item, strings),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showItemDetails(
      BuildContext context, AgendaItem item, AppStrings strings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildItemDetailsSheet(context, item, strings),
    );
  }

  void _showEditItemDialog(BuildContext context, AgendaItem item) {
    showDialog(
      context: context,
      builder: (context) => AddAgendaItemDialog(item: item),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, AgendaItem item, AppStrings strings) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.confirmExclusion),
        content: Text(strings.areYouSureYouWantToDelete(item.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Implementar exclusão
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(strings.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetailsSheet(
      BuildContext context, AgendaItem item, AppStrings strings) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(
                  item.typeIcon,
                  size: 32,
                  color: item.priorityColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (item.location != null)
                        Text(
                          item.location!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.description != null) ...[
                    _buildDetailItem(context, strings.description,
                        item.description!, null, strings),
                    const SizedBox(height: 16),
                  ],
                  _buildDetailItem(
                      context, strings.date, item.displayDate, null, strings),
                  if (item.displayTime.isNotEmpty)
                    _buildDetailItem(
                        context, strings.time, item.displayTime, null, strings),
                  _buildDetailItem(context, strings.type,
                      _getTypeText(item.type, strings), null, strings),
                  if (item.status != null)
                    _buildDetailItem(
                        context, strings.status, item.statusText, null, strings,
                        color: item.statusColor),
                  _buildDetailItem(context, strings.priority, item.priorityText,
                      null, strings,
                      color: item.priorityColor),
                  if (item.attendees.isNotEmpty)
                    _buildDetailItem(context, strings.attendees,
                        item.attendees.join(', '), null, strings),
                  if (item.tags.isNotEmpty)
                    _buildDetailItem(context, strings.tags,
                        item.tags.join(', '), null, strings),
                  _buildDetailItem(context, strings.createdAt,
                      _formatDate(item.createdAt), null, strings),
                  _buildDetailItem(context, strings.updatedAt,
                      _formatDate(item.updatedAt), null, strings),
                ],
              ),
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showEditItemDialog(context, item);
                    },
                    icon: Icon(Icons.edit),
                    label: Text(strings.edit),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Implementar ação específica
                    },
                    icon: Icon(Icons.check),
                    label: Text(strings.complete),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value,
      VoidCallback? onCopy, AppStrings strings,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: color,
                      ),
                ),
              ),
              if (onCopy != null)
                IconButton(
                  onPressed: onCopy,
                  icon: Icon(Icons.copy),
                  tooltip: strings.copy,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTypeText(AgendaItemType type, AppStrings strings) {
    switch (type) {
      case AgendaItemType.event:
        return strings.event;
      case AgendaItemType.task:
        return strings.task;
      case AgendaItemType.reminder:
        return strings.reminder;
      case AgendaItemType.meeting:
        return strings.meeting;
    }
  }
}
