// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interview_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InterviewModel _$InterviewModelFromJson(Map<String, dynamic> json) =>
    InterviewModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: $enumDecode(_$InterviewTypeEnumMap, json['type']),
      status: $enumDecode(_$InterviewStatusEnumMap, json['status']),
      dateTime: DateTime.parse(json['dateTime'] as String),
      company: json['company'] as String,
      companyLink: json['companyLink'] as String?,
      country: json['country'] as String,
      language: json['language'] as String,
      salaryProposal: (json['salaryProposal'] as num?)?.toDouble(),
      annualSalary: (json['annualSalary'] as num?)?.toDouble(),
      cvId: json['cvId'] as String?,
      applicationId: json['applicationId'] as String?,
      notes: json['notes'] as String?,
      rating: (json['rating'] as num?)?.toInt(),
      pageId: json['pageId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$InterviewModelToJson(InterviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$InterviewTypeEnumMap[instance.type]!,
      'status': _$InterviewStatusEnumMap[instance.status]!,
      'dateTime': instance.dateTime.toIso8601String(),
      'company': instance.company,
      'companyLink': instance.companyLink,
      'country': instance.country,
      'language': instance.language,
      'salaryProposal': instance.salaryProposal,
      'annualSalary': instance.annualSalary,
      'cvId': instance.cvId,
      'applicationId': instance.applicationId,
      'notes': instance.notes,
      'rating': instance.rating,
      'pageId': instance.pageId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$InterviewTypeEnumMap = {
  InterviewType.rh: 'rh',
  InterviewType.technical: 'technical',
  InterviewType.teamLead: 'team_lead',
};

const _$InterviewStatusEnumMap = {
  InterviewStatus.scheduled: 'scheduled',
  InterviewStatus.completed: 'completed',
  InterviewStatus.cancelled: 'cancelled',
  InterviewStatus.pending: 'pending',
};
