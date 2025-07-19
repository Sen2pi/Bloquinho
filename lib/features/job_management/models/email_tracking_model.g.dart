// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_tracking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmailTrackingModel _$EmailTrackingModelFromJson(Map<String, dynamic> json) =>
    EmailTrackingModel(
      id: json['id'] as String,
      applicationId: json['applicationId'] as String,
      subject: json['subject'] as String,
      fromEmail: json['fromEmail'] as String,
      toEmail: json['toEmail'] as String,
      ccEmail: json['ccEmail'] as String?,
      bccEmail: json['bccEmail'] as String?,
      sentDate: DateTime.parse(json['sentDate'] as String),
      body: json['body'] as String?,
      direction: $enumDecode(_$EmailDirectionEnumMap, json['direction']),
      emlFilePath: json['emlFilePath'] as String?,
      attachments: (json['attachments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$EmailTrackingModelToJson(EmailTrackingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'applicationId': instance.applicationId,
      'subject': instance.subject,
      'fromEmail': instance.fromEmail,
      'toEmail': instance.toEmail,
      'ccEmail': instance.ccEmail,
      'bccEmail': instance.bccEmail,
      'sentDate': instance.sentDate.toIso8601String(),
      'body': instance.body,
      'direction': _$EmailDirectionEnumMap[instance.direction]!,
      'emlFilePath': instance.emlFilePath,
      'attachments': instance.attachments,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$EmailDirectionEnumMap = {
  EmailDirection.sent: 'sent',
  EmailDirection.received: 'received',
};
