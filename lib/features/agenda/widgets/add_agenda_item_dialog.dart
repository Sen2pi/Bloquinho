import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/agenda_provider.dart';
import '../models/agenda_item.dart';

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
                    widget.item != null ? 'Editar Item' : 'Novo Item',
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
                        decoration: const InputDecoration(
                          labelText: 'Título *',
                          hintText: 'Digite o título do item',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Título é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tipo
                      DropdownButtonFormField<AgendaItemType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo *',
                        ),
                        items: AgendaItemType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Icon(_getTypeIcon(type)),
                                const SizedBox(width: 8),
                                Text(_getTypeText(type)),
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
                          decoration: const InputDecoration(
                            labelText: 'Status',
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
                                  Text(_getStatusText(status)),
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
                        decoration: const InputDecoration(
                          labelText: 'Prioridade',
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
                                Text(_getPriorityText(priority)),
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
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          hintText: 'Digite uma descrição (opcional)',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Localização
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Localização',
                          hintText: 'Digite o local (opcional)',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Datas
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              'Data de Início',
                              _startDate,
                              (date) => setState(() => _startDate = date),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDateField(
                              'Data de Fim',
                              _endDate,
                              (date) => setState(() => _endDate = date),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Deadline
                      _buildDateField(
                        'Deadline',
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
                          const Text('Dia inteiro'),
                          const SizedBox(width: 24),
                          Checkbox(
                            value: _isRecurring,
                            onChanged: (value) {
                              setState(() {
                                _isRecurring = value ?? false;
                              });
                            },
                          ),
                          const Text('Recorrente'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Participantes
                      TextFormField(
                        controller: _attendeesController,
                        decoration: const InputDecoration(
                          labelText: 'Participantes',
                          hintText:
                              'Digite os participantes separados por vírgula',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tags
                      TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Tags',
                          hintText: 'Digite as tags separadas por vírgula',
                        ),
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
                      child: const Text('Cancelar'),
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
                          : Text(widget.item != null ? 'Atualizar' : 'Criar'),
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

  Widget _buildDateField(
      String label, DateTime? value, Function(DateTime?) onChanged) {
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
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              onChanged(date);
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
                      ? '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}'
                      : 'Selecionar data',
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

    final item = AgendaItem(
      id: widget.item?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      deadline: _deadline,
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

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'A fazer';
      case TaskStatus.inProgress:
        return 'Em progresso';
      case TaskStatus.done:
        return 'Concluída';
      case TaskStatus.cancelled:
        return 'Cancelada';
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

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'Baixa';
      case Priority.medium:
        return 'Média';
      case Priority.high:
        return 'Alta';
      case Priority.urgent:
        return 'Urgente';
    }
  }
}
