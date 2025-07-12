import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'agenda_item.g.dart';

enum AgendaItemType {
  event,
  task,
  reminder,
  meeting,
}

enum TaskStatus {
  todo,
  inProgress,
  done,
  cancelled,
}

enum Priority {
  low,
  medium,
  high,
  urgent,
}

@JsonSerializable()
class AgendaItem extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? deadline;
  final AgendaItemType type;
  final TaskStatus? status;
  final Priority priority;
  final String? location;
  final List<String> attendees;
  final List<String> tags;
  final bool isAllDay;
  final bool isRecurring;
  final String? recurrenceRule;
  final String? color;
  final String? databaseItemId; // ID do item na base de dados
  final String? databaseName; // Nome da base de dados
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? notes;
  final List<String> attachments;
  final String? workspaceId;

  const AgendaItem({
    required this.id,
    required this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.deadline,
    required this.type,
    this.status,
    this.priority = Priority.medium,
    this.location,
    this.attendees = const [],
    this.tags = const [],
    this.isAllDay = false,
    this.isRecurring = false,
    this.recurrenceRule,
    this.color,
    this.databaseItemId,
    this.databaseName,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
    this.completedAt,
    this.notes,
    this.attachments = const [],
    this.workspaceId,
  });

  factory AgendaItem.fromJson(Map<String, dynamic> json) =>
      _$AgendaItemFromJson(json);

  Map<String, dynamic> toJson() => _$AgendaItemToJson(this);

  AgendaItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? deadline,
    AgendaItemType? type,
    TaskStatus? status,
    Priority? priority,
    String? location,
    List<String>? attendees,
    List<String>? tags,
    bool? isAllDay,
    bool? isRecurring,
    String? recurrenceRule,
    String? color,
    String? databaseItemId,
    String? databaseName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    DateTime? completedAt,
    String? notes,
    List<String>? attachments,
    String? workspaceId,
  }) {
    return AgendaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      deadline: deadline ?? this.deadline,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
      tags: tags ?? this.tags,
      isAllDay: isAllDay ?? this.isAllDay,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      color: color ?? this.color,
      databaseItemId: databaseItemId ?? this.databaseItemId,
      databaseName: databaseName ?? this.databaseName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startDate,
        endDate,
        deadline,
        type,
        status,
        priority,
        location,
        attendees,
        tags,
        isAllDay,
        isRecurring,
        recurrenceRule,
        color,
        databaseItemId,
        databaseName,
        createdAt,
        updatedAt,
        isCompleted,
        completedAt,
        notes,
        attachments,
        workspaceId,
      ];

  // Métodos de utilidade
  bool get isOverdue {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!);
  }

  bool get isDueToday {
    if (deadline == null) return false;
    final now = DateTime.now();
    final deadlineDate =
        DateTime(deadline!.year, deadline!.month, deadline!.day);
    final today = DateTime(now.year, now.month, now.day);
    return deadlineDate.isAtSameMomentAs(today);
  }

  bool get isDueSoon {
    if (deadline == null) return false;
    final now = DateTime.now();
    final daysUntilDeadline = deadline!.difference(now).inDays;
    return daysUntilDeadline <= 3 && daysUntilDeadline > 0;
  }

  Duration? get duration {
    if (startDate == null || endDate == null) return null;
    return endDate!.difference(startDate!);
  }

  String get displayDate {
    if (startDate != null) {
      return '${startDate!.day.toString().padLeft(2, '0')}/${startDate!.month.toString().padLeft(2, '0')}/${startDate!.year}';
    }
    if (deadline != null) {
      return '${deadline!.day.toString().padLeft(2, '0')}/${deadline!.month.toString().padLeft(2, '0')}/${deadline!.year}';
    }
    return 'Sem data';
  }

  String get displayTime {
    if (startDate != null) {
      return '${startDate!.hour.toString().padLeft(2, '0')}:${startDate!.minute.toString().padLeft(2, '0')}';
    }
    if (deadline != null) {
      return '${deadline!.hour.toString().padLeft(2, '0')}:${deadline!.minute.toString().padLeft(2, '0')}';
    }
    return '';
  }

  IconData get typeIcon {
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

  Color get priorityColor {
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

  String get priorityText {
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

  String get statusText {
    switch (status) {
      case TaskStatus.todo:
        return 'A fazer';
      case TaskStatus.inProgress:
        return 'Em progresso';
      case TaskStatus.done:
        return 'Concluída';
      case TaskStatus.cancelled:
        return 'Cancelada';
      default:
        return '';
    }
  }

  Color get statusColor {
    switch (status) {
      case TaskStatus.todo:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.done:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool get isFromDatabase => databaseItemId != null && databaseName != null;
}
