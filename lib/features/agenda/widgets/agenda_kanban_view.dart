import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/agenda_provider.dart';
import '../models/agenda_item.dart';
import 'agenda_item_card.dart';
import 'add_agenda_item_dialog.dart';

class AgendaKanbanView extends ConsumerWidget {
  const AgendaKanbanView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final todoItems = ref.watch(todoItemsProvider);
    final inProgressItems = ref.watch(inProgressItemsProvider);
    final doneItems = ref.watch(doneItemsProvider);
    final cancelledItems = ref.watch(cancelledItemsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Coluna: A Fazer
          Expanded(
            child: _buildKanbanColumn(
              context,
              'A Fazer',
              todoItems,
              TaskStatus.todo,
              Colors.grey,
              isDarkMode,
              ref,
            ),
          ),
          const SizedBox(width: 16),

          // Coluna: Em Progresso
          Expanded(
            child: _buildKanbanColumn(
              context,
              'Em Progresso',
              inProgressItems,
              TaskStatus.inProgress,
              Colors.blue,
              isDarkMode,
              ref,
            ),
          ),
          const SizedBox(width: 16),

          // Coluna: Concluída
          Expanded(
            child: _buildKanbanColumn(
              context,
              'Concluída',
              doneItems,
              TaskStatus.done,
              Colors.green,
              isDarkMode,
              ref,
            ),
          ),
          const SizedBox(width: 16),

          // Coluna: Cancelada
          Expanded(
            child: _buildKanbanColumn(
              context,
              'Cancelada',
              cancelledItems,
              TaskStatus.cancelled,
              Colors.red,
              isDarkMode,
              ref,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(
    BuildContext context,
    String title,
    List<AgendaItem> items,
    TaskStatus status,
    Color color,
    bool isDarkMode,
    WidgetRef ref,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          // Header da coluna
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          ),

          // Lista de itens
          Expanded(
            child: items.isEmpty
                ? _buildEmptyColumn(context, title, isDarkMode)
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Draggable<AgendaItem>(
                          data: item,
                          feedback: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 280,
                              child: AgendaItemCard(
                                item: item,
                                onTap: () => _showItemDetails(context, item),
                                onEdit: () =>
                                    _showEditItemDialog(context, item),
                                onDelete: () =>
                                    _showDeleteConfirmation(context, item),
                              ),
                            ),
                          ),
                          childWhenDragging: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                          child: DragTarget<AgendaItem>(
                            onWillAccept: (data) =>
                                data != null && data.status != status,
                            onAccept: (data) =>
                                _moveItemToStatus(data, status, ref),
                            builder: (context, candidateData, rejectedData) {
                              return AgendaItemCard(
                                item: item,
                                onTap: () => _showItemDetails(context, item),
                                onEdit: () =>
                                    _showEditItemDialog(context, item),
                                onDelete: () =>
                                    _showDeleteConfirmation(context, item),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyColumn(
      BuildContext context, String title, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum item',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Arraste itens para cá',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _moveItemToStatus(AgendaItem item, TaskStatus newStatus, WidgetRef ref) {
    // Usar o provider para atualizar o status (que também atualiza na base de dados se necessário)
    ref.read(agendaProvider.notifier).updateItemStatus(item.id, newStatus);
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
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
