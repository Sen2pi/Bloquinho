/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'email_tracking_model.g.dart';

enum EmailDirection {
  @JsonValue('sent')
  sent,
  @JsonValue('received')
  received,
}

@JsonSerializable()
class EmailTrackingModel {
  final String id;
  final String applicationId;
  final String subject;
  final String fromEmail;
  final String toEmail;
  final String? ccEmail;
  final String? bccEmail;
  final DateTime sentDate;
  final String? body;
  final EmailDirection direction;
  final String? emlFilePath;
  final List<String> attachments;
  final DateTime createdAt;

  const EmailTrackingModel({
    required this.id,
    required this.applicationId,
    required this.subject,
    required this.fromEmail,
    required this.toEmail,
    this.ccEmail,
    this.bccEmail,
    required this.sentDate,
    this.body,
    required this.direction,
    this.emlFilePath,
    required this.attachments,
    required this.createdAt,
  });

  factory EmailTrackingModel.create({
    required String applicationId,
    required String subject,
    required String fromEmail,
    required String toEmail,
    String? ccEmail,
    String? bccEmail,
    required DateTime sentDate,
    String? body,
    required EmailDirection direction,
    String? emlFilePath,
    List<String>? attachments,
  }) {
    final now = DateTime.now();
    return EmailTrackingModel(
      id: const Uuid().v4(),
      applicationId: applicationId,
      subject: subject,
      fromEmail: fromEmail,
      toEmail: toEmail,
      ccEmail: ccEmail,
      bccEmail: bccEmail,
      sentDate: sentDate,
      body: body,
      direction: direction,
      emlFilePath: emlFilePath,
      attachments: attachments ?? [],
      createdAt: now,
    );
  }

  factory EmailTrackingModel.fromJson(Map<String, dynamic> json) =>
      _$EmailTrackingModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmailTrackingModelToJson(this);

  EmailTrackingModel copyWith({
    String? id,
    String? applicationId,
    String? subject,
    String? fromEmail,
    String? toEmail,
    String? ccEmail,
    String? bccEmail,
    DateTime? sentDate,
    String? body,
    EmailDirection? direction,
    String? emlFilePath,
    List<String>? attachments,
    DateTime? createdAt,
  }) {
    return EmailTrackingModel(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      subject: subject ?? this.subject,
      fromEmail: fromEmail ?? this.fromEmail,
      toEmail: toEmail ?? this.toEmail,
      ccEmail: ccEmail ?? this.ccEmail,
      bccEmail: bccEmail ?? this.bccEmail,
      sentDate: sentDate ?? this.sentDate,
      body: body ?? this.body,
      direction: direction ?? this.direction,
      emlFilePath: emlFilePath ?? this.emlFilePath,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmailTrackingModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}