// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplicationModel _$ApplicationModelFromJson(Map<String, dynamic> json) =>
    ApplicationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      company: json['company'] as String,
      companyLink: json['companyLink'] as String?,
      description: json['description'] as String?,
      status: $enumDecode(_$ApplicationStatusEnumMap, json['status']),
      appliedDate: DateTime.parse(json['appliedDate'] as String),
      location: json['location'] as String?,
      platform: json['platform'] as String?,
      cvId: json['cvId'] as String,
      motivationLetter: json['motivationLetter'] as String?,
      aiMatchPercentage: json['aiMatchPercentage'] as String?,
      notes: json['notes'] as String?,
      interviewIds: (json['interviewIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ApplicationModelToJson(ApplicationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'company': instance.company,
      'companyLink': instance.companyLink,
      'description': instance.description,
      'status': _$ApplicationStatusEnumMap[instance.status]!,
      'appliedDate': instance.appliedDate.toIso8601String(),
      'location': instance.location,
      'platform': instance.platform,
      'cvId': instance.cvId,
      'motivationLetter': instance.motivationLetter,
      'aiMatchPercentage': instance.aiMatchPercentage,
      'notes': instance.notes,
      'interviewIds': instance.interviewIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ApplicationStatusEnumMap = {
  ApplicationStatus.applied: 'applied',
  ApplicationStatus.inReview: 'in_review',
  ApplicationStatus.interviewScheduled: 'interview_scheduled',
  ApplicationStatus.rejected: 'rejected',
  ApplicationStatus.accepted: 'accepted',
  ApplicationStatus.withdrawn: 'withdrawn',
};
