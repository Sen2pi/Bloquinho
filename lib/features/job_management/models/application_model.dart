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

part 'application_model.g.dart';

enum ApplicationStatus {
  @JsonValue('applied')
  applied,
  @JsonValue('in_review')
  inReview,
  @JsonValue('interview_scheduled')
  interviewScheduled,
  @JsonValue('rejected')
  rejected,
  @JsonValue('accepted')
  accepted,
  @JsonValue('withdrawn')
  withdrawn,
}

@JsonSerializable()
class ApplicationModel {
  final String id;
  final String title;
  final String company;
  final String? companyLink;
  final String? description;
  final ApplicationStatus status;
  final DateTime appliedDate;
  final String? location;
  final String? platform; // LinkedIn, Indeed, etc.
  final String cvId;
  final String? motivationLetter;
  final String? aiMatchPercentage;
  final String? notes;
  final List<String> interviewIds;
  final List<String> emailTrackingIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ApplicationModel({
    required this.id,
    required this.title,
    required this.company,
    this.companyLink,
    this.description,
    required this.status,
    required this.appliedDate,
    this.location,
    this.platform,
    required this.cvId,
    this.motivationLetter,
    this.aiMatchPercentage,
    this.notes,
    required this.interviewIds,
    required this.emailTrackingIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApplicationModel.create({
    required String title,
    required String company,
    String? companyLink,
    String? description,
    DateTime? appliedDate,
    String? location,
    String? platform,
    required String cvId,
    String? motivationLetter,
    String? aiMatchPercentage,
    String? notes,
    List<String>? interviewIds,
    List<String>? emailTrackingIds,
  }) {
    final now = DateTime.now();
    return ApplicationModel(
      id: const Uuid().v4(),
      title: title,
      company: company,
      companyLink: companyLink,
      description: description,
      status: ApplicationStatus.applied,
      appliedDate: appliedDate ?? now,
      location: location,
      platform: platform,
      cvId: cvId,
      motivationLetter: motivationLetter,
      aiMatchPercentage: aiMatchPercentage,
      notes: notes,
      interviewIds: interviewIds ?? [],
      emailTrackingIds: emailTrackingIds ?? [],
      createdAt: now,
      updatedAt: now,
    );
  }

  factory ApplicationModel.fromJson(Map<String, dynamic> json) =>
      _$ApplicationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationModelToJson(this);

  ApplicationModel copyWith({
    String? id,
    String? title,
    String? company,
    String? companyLink,
    String? description,
    ApplicationStatus? status,
    DateTime? appliedDate,
    String? location,
    String? platform,
    String? cvId,
    String? motivationLetter,
    String? aiMatchPercentage,
    String? notes,
    List<String>? interviewIds,
    List<String>? emailTrackingIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      companyLink: companyLink ?? this.companyLink,
      description: description ?? this.description,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      location: location ?? this.location,
      platform: platform ?? this.platform,
      cvId: cvId ?? this.cvId,
      motivationLetter: motivationLetter ?? this.motivationLetter,
      aiMatchPercentage: aiMatchPercentage ?? this.aiMatchPercentage,
      notes: notes ?? this.notes,
      interviewIds: interviewIds ?? this.interviewIds,
      emailTrackingIds: emailTrackingIds ?? this.emailTrackingIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApplicationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}