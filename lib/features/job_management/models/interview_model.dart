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

part 'interview_model.g.dart';

enum InterviewType {
  @JsonValue('rh')
  rh,
  @JsonValue('technical')
  technical,
  @JsonValue('team_lead')
  teamLead,
}

enum InterviewStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('pending')
  pending,
}

@JsonSerializable()
class InterviewModel {
  final String id;
  final String title;
  final String? description;
  final InterviewType type;
  final InterviewStatus status;
  final DateTime dateTime;
  final String company;
  final String? companyLink;
  final String country;
  final String language;
  final double? salaryProposal;
  final double? annualSalary;
  final String? cvId;
  final String? applicationId;
  final String? notes;
  final int? rating; // 1-5
  final String? pageId; // Link para página do bloquinho
  final DateTime createdAt;
  final DateTime updatedAt;

  const InterviewModel({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    required this.dateTime,
    required this.company,
    this.companyLink,
    required this.country,
    required this.language,
    this.salaryProposal,
    this.annualSalary,
    this.cvId,
    this.applicationId,
    this.notes,
    this.rating,
    this.pageId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InterviewModel.create({
    required String title,
    String? description,
    required InterviewType type,
    required DateTime dateTime,
    required String company,
    String? companyLink,
    required String country,
    required String language,
    double? salaryProposal,
    double? annualSalary,
    String? cvId,
    String? applicationId,
    String? notes,
    int? rating,
    String? pageId,
  }) {
    final now = DateTime.now();
    return InterviewModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      type: type,
      status: InterviewStatus.scheduled,
      dateTime: dateTime,
      company: company,
      companyLink: companyLink,
      country: country,
      language: language,
      salaryProposal: salaryProposal,
      annualSalary: annualSalary,
      cvId: cvId,
      applicationId: applicationId,
      notes: notes,
      rating: rating,
      pageId: pageId,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory InterviewModel.fromJson(Map<String, dynamic> json) =>
      _$InterviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$InterviewModelToJson(this);

  InterviewModel copyWith({
    String? id,
    String? title,
    String? description,
    InterviewType? type,
    InterviewStatus? status,
    DateTime? dateTime,
    String? company,
    String? companyLink,
    String? country,
    String? language,
    double? salaryProposal,
    double? annualSalary,
    String? cvId,
    String? applicationId,
    String? notes,
    int? rating,
    String? pageId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InterviewModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      dateTime: dateTime ?? this.dateTime,
      company: company ?? this.company,
      companyLink: companyLink ?? this.companyLink,
      country: country ?? this.country,
      language: language ?? this.language,
      salaryProposal: salaryProposal ?? this.salaryProposal,
      annualSalary: annualSalary ?? this.annualSalary,
      cvId: cvId ?? this.cvId,
      applicationId: applicationId ?? this.applicationId,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      pageId: pageId ?? this.pageId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InterviewModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}