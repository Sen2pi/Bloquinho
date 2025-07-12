// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agenda_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgendaItem _$AgendaItemFromJson(Map<String, dynamic> json) => AgendaItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      type: $enumDecode(_$AgendaItemTypeEnumMap, json['type']),
      status: $enumDecodeNullable(_$TaskStatusEnumMap, json['status']),
      priority: $enumDecodeNullable(_$PriorityEnumMap, json['priority']) ??
          Priority.medium,
      location: json['location'] as String?,
      attendees: (json['attendees'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      isAllDay: json['isAllDay'] as bool? ?? false,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurrenceRule: json['recurrenceRule'] as String?,
      color: json['color'] as String?,
      databaseItemId: json['databaseItemId'] as String?,
      databaseName: json['databaseName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      notes: json['notes'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      workspaceId: json['workspaceId'] as String?,
    );

Map<String, dynamic> _$AgendaItemToJson(AgendaItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'deadline': instance.deadline?.toIso8601String(),
      'type': _$AgendaItemTypeEnumMap[instance.type]!,
      'status': _$TaskStatusEnumMap[instance.status],
      'priority': _$PriorityEnumMap[instance.priority]!,
      'location': instance.location,
      'attendees': instance.attendees,
      'tags': instance.tags,
      'isAllDay': instance.isAllDay,
      'isRecurring': instance.isRecurring,
      'recurrenceRule': instance.recurrenceRule,
      'color': instance.color,
      'databaseItemId': instance.databaseItemId,
      'databaseName': instance.databaseName,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
      'notes': instance.notes,
      'attachments': instance.attachments,
      'workspaceId': instance.workspaceId,
    };

const _$AgendaItemTypeEnumMap = {
  AgendaItemType.event: 'event',
  AgendaItemType.task: 'task',
  AgendaItemType.reminder: 'reminder',
  AgendaItemType.meeting: 'meeting',
};

const _$TaskStatusEnumMap = {
  TaskStatus.todo: 'todo',
  TaskStatus.inProgress: 'inProgress',
  TaskStatus.done: 'done',
  TaskStatus.cancelled: 'cancelled',
};

const _$PriorityEnumMap = {
  Priority.low: 'low',
  Priority.medium: 'medium',
  Priority.high: 'high',
  Priority.urgent: 'urgent',
};
