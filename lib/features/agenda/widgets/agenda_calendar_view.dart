import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/agenda_provider.dart';
import '../models/agenda_item.dart';
import 'agenda_item_card.dart';
import 'add_agenda_item_dialog.dart';

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

    return Column(
      children: [
        // Calendário
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
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
              titleTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
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
        Expanded(
          child: _buildEventsList(
              context, selectedDate ?? DateTime.now(), items, isDarkMode),
        ),
      ],
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
      List<AgendaItem> items, bool isDarkMode) {
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
              'Nenhum evento para ${_formatDate(date)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione um novo evento para começar',
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
            onTap: () => _showItemDetails(context, item),
            onEdit: () => _showEditItemDialog(context, item),
            onDelete: () => _showDeleteConfirmation(context, item),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showItemDetails(BuildContext context, AgendaItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildItemDetailsSheet(context, item),
    );
  }

  void _showEditItemDialog(BuildContext context, AgendaItem item) {
    showDialog(
      context: context,
      builder: (context) => AddAgendaItemDialog(item: item),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AgendaItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Implementar exclusão
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetailsSheet(BuildContext context, AgendaItem item) {
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
                    _buildDetailItem(
                        context, 'Descrição', item.description!, null),
                    const SizedBox(height: 16),
                  ],
                  _buildDetailItem(context, 'Data', item.displayDate, null),
                  if (item.displayTime.isNotEmpty)
                    _buildDetailItem(context, 'Hora', item.displayTime, null),
                  _buildDetailItem(
                      context, 'Tipo', _getTypeText(item.type), null),
                  if (item.status != null)
                    _buildDetailItem(context, 'Status', item.statusText, null,
                        color: item.statusColor),
                  _buildDetailItem(
                      context, 'Prioridade', item.priorityText, null,
                      color: item.priorityColor),
                  if (item.attendees.isNotEmpty)
                    _buildDetailItem(context, 'Participantes',
                        item.attendees.join(', '), null),
                  if (item.tags.isNotEmpty)
                    _buildDetailItem(
                        context, 'Tags', item.tags.join(', '), null),
                  _buildDetailItem(
                      context, 'Criado', _formatDate(item.createdAt), null),
                  _buildDetailItem(
                      context, 'Atualizado', _formatDate(item.updatedAt), null),
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
                    label: const Text('Editar'),
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
                    label: const Text('Concluir'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context, String label, String value, VoidCallback? onCopy,
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
                  tooltip: 'Copiar',
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTypeText(AgendaItemType type) {
    switch (type) {
      case AgendaItemType.event:
        return 'Evento';
      case AgendaItemType.task:
        return 'Tarefa';
      case AgendaItemType.reminder:
        return 'Lembrete';
      case AgendaItemType.meeting:
        return 'Reunião';
    }
  }
}
