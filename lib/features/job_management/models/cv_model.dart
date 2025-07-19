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

part 'cv_model.g.dart';

@JsonSerializable()
class WorkExperience {
  final String id;
  final String company;
  final String position;
  final String? location;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final List<String> achievements;

  const WorkExperience({
    required this.id,
    required this.company,
    required this.position,
    this.location,
    required this.startDate,
    this.endDate,
    this.description,
    required this.achievements,
  });

  factory WorkExperience.create({
    required String company,
    required String position,
    String? location,
    required DateTime startDate,
    DateTime? endDate,
    String? description,
    List<String>? achievements,
  }) {
    return WorkExperience(
      id: const Uuid().v4(),
      company: company,
      position: position,
      location: location,
      startDate: startDate,
      endDate: endDate,
      description: description,
      achievements: achievements ?? [],
    );
  }

  factory WorkExperience.fromJson(Map<String, dynamic> json) =>
      _$WorkExperienceFromJson(json);

  Map<String, dynamic> toJson() => _$WorkExperienceToJson(this);

  WorkExperience copyWith({
    String? id,
    String? company,
    String? position,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    List<String>? achievements,
  }) {
    return WorkExperience(
      id: id ?? this.id,
      company: company ?? this.company,
      position: position ?? this.position,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      achievements: achievements ?? this.achievements,
    );
  }
}

@JsonSerializable()
class Education {
  final String id;
  final String institution;
  final String degree;
  final String? field;
  final DateTime startDate;
  final DateTime? endDate;
  final String? grade;
  final String? description;

  const Education({
    required this.id,
    required this.institution,
    required this.degree,
    this.field,
    required this.startDate,
    this.endDate,
    this.grade,
    this.description,
  });

  factory Education.create({
    required String institution,
    required String degree,
    String? field,
    required DateTime startDate,
    DateTime? endDate,
    String? grade,
    String? description,
  }) {
    return Education(
      id: const Uuid().v4(),
      institution: institution,
      degree: degree,
      field: field,
      startDate: startDate,
      endDate: endDate,
      grade: grade,
      description: description,
    );
  }

  factory Education.fromJson(Map<String, dynamic> json) =>
      _$EducationFromJson(json);

  Map<String, dynamic> toJson() => _$EducationToJson(this);

  Education copyWith({
    String? id,
    String? institution,
    String? degree,
    String? field,
    DateTime? startDate,
    DateTime? endDate,
    String? grade,
    String? description,
  }) {
    return Education(
      id: id ?? this.id,
      institution: institution ?? this.institution,
      degree: degree ?? this.degree,
      field: field ?? this.field,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      grade: grade ?? this.grade,
      description: description ?? this.description,
    );
  }
}

@JsonSerializable()
class Project {
  final String id;
  final String name;
  final String? description;
  final List<String> technologies;
  final String? url;
  final String? repository;
  final DateTime? startDate;
  final DateTime? endDate;

  const Project({
    required this.id,
    required this.name,
    this.description,
    required this.technologies,
    this.url,
    this.repository,
    this.startDate,
    this.endDate,
  });

  factory Project.create({
    required String name,
    String? description,
    List<String>? technologies,
    String? url,
    String? repository,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Project(
      id: const Uuid().v4(),
      name: name,
      description: description,
      technologies: technologies ?? [],
      url: url,
      repository: repository,
      startDate: startDate,
      endDate: endDate,
    );
  }

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  Project copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? technologies,
    String? url,
    String? repository,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      technologies: technologies ?? this.technologies,
      url: url ?? this.url,
      repository: repository ?? this.repository,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

@JsonSerializable()
class CVModel {
  final String id;
  final String name;
  final String? targetPosition;
  final String? aiIntroduction;
  final String? personalSummary;
  final String? email;
  final String? phone;
  final String? address;
  final String? linkedin;
  final String? github;
  final String? website;
  final List<WorkExperience> experiences;
  final List<Education> education;
  final List<Project> projects;
  final List<String> skills;
  final List<String> languages;
  final List<String> certifications;
  final List<String> interviewIds;
  final String? pdfPath;
  final String? htmlContent;
  final String? htmlFilePath;
  final String? photoPath;
  final bool isHtmlCV;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CVModel({
    required this.id,
    required this.name,
    this.targetPosition,
    this.aiIntroduction,
    this.personalSummary,
    this.email,
    this.phone,
    this.address,
    this.linkedin,
    this.github,
    this.website,
    required this.experiences,
    required this.education,
    required this.projects,
    required this.skills,
    required this.languages,
    required this.certifications,
    required this.interviewIds,
    this.pdfPath,
    this.htmlContent,
    this.htmlFilePath,
    this.photoPath,
    required this.isHtmlCV,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CVModel.create({
    required String name,
    String? targetPosition,
    String? aiIntroduction,
    String? personalSummary,
    String? email,
    String? phone,
    String? address,
    String? linkedin,
    String? github,
    String? website,
    List<WorkExperience>? experiences,
    List<Education>? education,
    List<Project>? projects,
    List<String>? skills,
    List<String>? languages,
    List<String>? certifications,
    List<String>? interviewIds,
    String? pdfPath,
    String? htmlContent,
    String? htmlFilePath,
    String? photoPath,
    bool? isHtmlCV,
  }) {
    final now = DateTime.now();
    return CVModel(
      id: const Uuid().v4(),
      name: name,
      targetPosition: targetPosition,
      aiIntroduction: aiIntroduction,
      personalSummary: personalSummary,
      email: email,
      phone: phone,
      address: address,
      linkedin: linkedin,
      github: github,
      website: website,
      experiences: experiences ?? [],
      education: education ?? [],
      projects: projects ?? [],
      skills: skills ?? [],
      languages: languages ?? [],
      certifications: certifications ?? [],
      interviewIds: interviewIds ?? [],
      pdfPath: pdfPath,
      htmlContent: htmlContent,
      htmlFilePath: htmlFilePath,
      photoPath: photoPath,
      isHtmlCV: isHtmlCV ?? false,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory CVModel.createHtml({
    required String name,
    required String htmlContent,
    String? htmlFilePath,
    String? photoPath,
  }) {
    final now = DateTime.now();
    return CVModel(
      id: const Uuid().v4(),
      name: name,
      targetPosition: null,
      aiIntroduction: null,
      personalSummary: null,
      email: null,
      phone: null,
      address: null,
      linkedin: null,
      github: null,
      website: null,
      experiences: [],
      education: [],
      projects: [],
      skills: [],
      languages: [],
      certifications: [],
      interviewIds: [],
      pdfPath: null,
      htmlContent: htmlContent,
      htmlFilePath: htmlFilePath,
      photoPath: photoPath,
      isHtmlCV: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory CVModel.fromJson(Map<String, dynamic> json) =>
      _$CVModelFromJson(json);

  Map<String, dynamic> toJson() => _$CVModelToJson(this);

  CVModel copyWith({
    String? id,
    String? name,
    String? targetPosition,
    String? aiIntroduction,
    String? personalSummary,
    String? email,
    String? phone,
    String? address,
    String? linkedin,
    String? github,
    String? website,
    List<WorkExperience>? experiences,
    List<Education>? education,
    List<Project>? projects,
    List<String>? skills,
    List<String>? languages,
    List<String>? certifications,
    List<String>? interviewIds,
    String? pdfPath,
    String? htmlContent,
    String? htmlFilePath,
    String? photoPath,
    bool? isHtmlCV,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CVModel(
      id: id ?? this.id,
      name: name ?? this.name,
      targetPosition: targetPosition ?? this.targetPosition,
      aiIntroduction: aiIntroduction ?? this.aiIntroduction,
      personalSummary: personalSummary ?? this.personalSummary,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      linkedin: linkedin ?? this.linkedin,
      github: github ?? this.github,
      website: website ?? this.website,
      experiences: experiences ?? this.experiences,
      education: education ?? this.education,
      projects: projects ?? this.projects,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
      certifications: certifications ?? this.certifications,
      interviewIds: interviewIds ?? this.interviewIds,
      pdfPath: pdfPath ?? this.pdfPath,
      htmlContent: htmlContent ?? this.htmlContent,
      htmlFilePath: htmlFilePath ?? this.htmlFilePath,
      photoPath: photoPath ?? this.photoPath,
      isHtmlCV: isHtmlCV ?? this.isHtmlCV,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CVModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
