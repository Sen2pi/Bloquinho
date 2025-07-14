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
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';

class AddAgendaItemDialog extends ConsumerStatefulWidget {
  final AgendaItem? item;

  const AddAgendaItemDialog({
    super.key,
    this.item,
  });

  @override
  ConsumerState<AddAgendaItemDialog> createState() =>
      _AddAgendaItemDialogState();
}

class _AddAgendaItemDialogState extends ConsumerState<AddAgendaItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();
  final _attendeesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _deadline;
  AgendaItemType _selectedType = AgendaItemType.task;
  TaskStatus? _selectedStatus;
  Priority _selectedPriority = Priority.medium;
  bool _isAllDay = false;
  bool _isRecurring = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _loadItemData();
    }
  }

  void _loadItemData() {
    final item = widget.item!;
    _titleController.text = item.title;
    _descriptionController.text = item.description ?? '';
    _locationController.text = item.location ?? '';
    _tagsController.text = item.tags.join(', ');
    _attendeesController.text = item.attendees.join(', ');
    _startDate = item.startDate;
    _endDate = item.endDate;
    _deadline = item.deadline;
    _selectedType = item.type;
    _selectedStatus = item.status;
    _selectedPriority = item.priority;
    _isAllDay = item.isAllDay;
    _isRecurring = item.isRecurring;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    _attendeesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final isCreating = ref.watch(agendaIsCreatingProvider);
    final isUpdating = ref.watch(agendaIsUpdatingProvider);
    final strings = ref.watch(appStringsProvider);

    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:
                    isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.item != null ? Icons.edit : Icons.add,
                    size: 24,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.item != null ? strings.editItem : strings.newItem,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: '${strings.title} *',
                          hintText: strings.typeItemTitle,
                        ),
                        textInputAction: TextInputAction.next,
                        enableInteractiveSelection: true,
                        autocorrect: false,
                        enableSuggestions: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return strings.titleIsRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tipo
                      DropdownButtonFormField<AgendaItemType>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: '${strings.type} *',
                        ),
                        items: AgendaItemType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Icon(_getTypeIcon(type)),
                                const SizedBox(width: 8),
                                Text(_getTypeText(type, strings)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                            if (value == AgendaItemType.task &&
                                _selectedStatus == null) {
                              _selectedStatus = TaskStatus.todo;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Status (apenas para tarefas)
                      if (_selectedType == AgendaItemType.task)
                        DropdownButtonFormField<TaskStatus>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: strings.status,
                          ),
                          items: TaskStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_getStatusText(status, strings)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          },
                        ),
                      if (_selectedType == AgendaItemType.task)
                        const SizedBox(height: 16),

                      // Prioridade
                      DropdownButtonFormField<Priority>(
                        value: _selectedPriority,
                        decoration: InputDecoration(
                          labelText: strings.priority,
                        ),
                        items: Priority.values.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(priority),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(_getPriorityText(priority, strings)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Descrição
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: strings.description,
                          hintText: strings.typeDescriptionOptional,
                        ),
                        maxLines: 3,
                        textInputAction: TextInputAction.next,
                        enableInteractiveSelection: true,
                        autocorrect: false,
                        enableSuggestions: true,
                      ),
                      const SizedBox(height: 16),

                      // Localização
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: strings.location,
                          hintText: strings.typeLocationOptional,
                        ),
                        textInputAction: TextInputAction.next,
                        enableInteractiveSelection: true,
                        autocorrect: false,
                        enableSuggestions: true,
                      ),
                      const SizedBox(height: 16),

                      // Datas
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateTimeField(
                              strings.startDateTime,
                              _startDate,
                              (date) => setState(() => _startDate = date),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDateTimeField(
                              strings.endDateTime,
                              _endDate,
                              (date) => setState(() => _endDate = date),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Deadline
                      _buildDateTimeField(
                        strings.deadlineDateTime,
                        _deadline,
                        (date) => setState(() => _deadline = date),
                      ),
                      const SizedBox(height: 16),

                      // Opções
                      Row(
                        children: [
                          Checkbox(
                            value: _isAllDay,
                            onChanged: (value) {
                              setState(() {
                                _isAllDay = value ?? false;
                              });
                            },
                          ),
                          Text(strings.allDay),
                          const SizedBox(width: 24),
                          Checkbox(
                            value: _isRecurring,
                            onChanged: (value) {
                              setState(() {
                                _isRecurring = value ?? false;
                              });
                            },
                          ),
                          Text(strings.recurring),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Participantes
                      TextFormField(
                        controller: _attendeesController,
                        decoration: InputDecoration(
                          labelText: strings.attendees,
                          hintText:
                              strings.typeAttendeesCommaSeparated,
                        ),
                        textInputAction: TextInputAction.next,
                        enableInteractiveSelection: true,
                        autocorrect: false,
                        enableSuggestions: true,
                      ),
                      const SizedBox(height: 16),

                      // Tags
                      TextFormField(
                        controller: _tagsController,
                        decoration: InputDecoration(
                          labelText: strings.tags,
                          hintText: strings.typeTagsCommaSeparated,
                        ),
                        textInputAction: TextInputAction.done,
                        enableInteractiveSelection: true,
                        autocorrect: false,
                        enableSuggestions: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:
                    isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
                border: Border(
                  top: BorderSide(
                    color: isDarkMode
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(strings.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (isCreating || isUpdating) ? null : _saveItem,
                      child: (isCreating || isUpdating)
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.item != null ? strings.update : strings.create),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeField(
      String label, DateTime? value, Function(DateTime?) onChanged) {
    final strings = ref.watch(appStringsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            // Primeiro selecionar data
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              // Depois selecionar hora
              final time = await showTimePicker(
                context: context,
                initialTime: value != null
                    ? TimeOfDay.fromDateTime(value)
                    : TimeOfDay.now(),
              );
              if (time != null) {
                // Combinar data e hora
                final dateTime = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );
                onChanged(dateTime);
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(
                  value != null
                      ? '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}'
                      : strings.selectDateTime,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate()) return;

    // Garantir que sempre tenha data e hora
    DateTime? startDate = _startDate;
    DateTime? endDate = _endDate;
    DateTime? deadline = _deadline;

    // Se não tem data de início, usar agora
    if (startDate == null) {
      startDate = DateTime.now();
    }

    // Se tem data de início mas não de fim, usar início + 1 hora
    if (startDate != null && endDate == null) {
      endDate = startDate.add(const Duration(hours: 1));
    }

    // Se não tem deadline mas é uma tarefa, usar data de início
    if (deadline == null && _selectedType == AgendaItemType.task) {
      deadline = startDate;
    }

    final item = AgendaItem(
      id: widget.item?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      startDate: startDate,
      endDate: endDate,
      deadline: deadline,
      type: _selectedType,
      status: _selectedStatus,
      priority: _selectedPriority,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      attendees: _attendeesController.text.trim().isEmpty
          ? []
          : _attendeesController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
      tags: _tagsController.text.trim().isEmpty
          ? []
          : _tagsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
      isAllDay: _isAllDay,
      isRecurring: _isRecurring,
      createdAt: widget.item?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.item != null) {
      ref.read(agendaProvider.notifier).updateItem(item);
    } else {
      ref.read(agendaProvider.notifier).createItem(item);
    }

    Navigator.of(context).pop();
  }

  IconData _getTypeIcon(AgendaItemType type) {
    switch (type) {
      case AgendaItemType.event:
        return Icons.event;
      case AgendaItemType.task:
        return Icons.task;
      case AgendaItemType.reminder:
        return Icons.alarm;
      case AgendaItemType.meeting:
        return Icons.meeting_room;
    }
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

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.done:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(TaskStatus status, AppStrings strings) {
    switch (status) {
      case TaskStatus.todo:
        return strings.statusTodo;
      case TaskStatus.inProgress:
        return strings.statusInProgress;
      case TaskStatus.done:
        return strings.statusCompleted;
      case TaskStatus.cancelled:
        return strings.statusCancelled;
    }
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
      case Priority.urgent:
        return Colors.purple;
    }
  }

  String _getPriorityText(Priority priority, AppStrings strings) {
    switch (priority) {
      case Priority.low:
        return strings.priorityLow;
      case Priority.medium:
        return strings.priorityMedium;
      case Priority.high:
        return strings.priorityHigh;
      case Priority.urgent:
        return strings.priorityUrgent;
    }
  }
}
