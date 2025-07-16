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

import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/agenda_provider.dart';
import '../models/agenda_item.dart';
import 'agenda_item_card.dart';
import 'add_agenda_item_dialog.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';

class AgendaListView extends ConsumerWidget {
  const AgendaListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final items = ref.watch(filteredAgendaItemsProvider);
    final strings = ref.watch(appStringsProvider);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              strings.noItemsOnAgenda,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.addAnItemToStart,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.2, // Ajuste para o formato desejado
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return AgendaItemCard(
          item: item,
          onTap: () => _showItemDetails(context, item, strings),
          onEdit: () => _showEditItemDialog(context, item),
          onDelete: () => _showDeleteConfirmation(context, item, strings),
        );
      },
    );
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
      builder: (context) => AlertDialog(
        title: Text(strings.confirmExclusion),
        content: Text(strings.areYouSureYouWantToDelete(item.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
