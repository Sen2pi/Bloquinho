// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkExperience _$WorkExperienceFromJson(Map<String, dynamic> json) =>
    WorkExperience(
      id: json['id'] as String,
      company: json['company'] as String,
      position: json['position'] as String,
      location: json['location'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      description: json['description'] as String?,
      achievements: (json['achievements'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$WorkExperienceToJson(WorkExperience instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company': instance.company,
      'position': instance.position,
      'location': instance.location,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'description': instance.description,
      'achievements': instance.achievements,
    };

Education _$EducationFromJson(Map<String, dynamic> json) => Education(
      id: json['id'] as String,
      institution: json['institution'] as String,
      degree: json['degree'] as String,
      field: json['field'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      grade: json['grade'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$EducationToJson(Education instance) => <String, dynamic>{
      'id': instance.id,
      'institution': instance.institution,
      'degree': instance.degree,
      'field': instance.field,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'grade': instance.grade,
      'description': instance.description,
    };

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      technologies: (json['technologies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      url: json['url'] as String?,
      repository: json['repository'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'technologies': instance.technologies,
      'url': instance.url,
      'repository': instance.repository,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
    };

CVModel _$CVModelFromJson(Map<String, dynamic> json) => CVModel(
      id: json['id'] as String,
      name: json['name'] as String,
      targetPosition: json['targetPosition'] as String?,
      aiIntroduction: json['aiIntroduction'] as String?,
      personalSummary: json['personalSummary'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      linkedin: json['linkedin'] as String?,
      github: json['github'] as String?,
      website: json['website'] as String?,
      experiences: (json['experiences'] as List<dynamic>)
          .map((e) => WorkExperience.fromJson(e as Map<String, dynamic>))
          .toList(),
      education: (json['education'] as List<dynamic>)
          .map((e) => Education.fromJson(e as Map<String, dynamic>))
          .toList(),
      projects: (json['projects'] as List<dynamic>)
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
      skills:
          (json['skills'] as List<dynamic>).map((e) => e as String).toList(),
      languages:
          (json['languages'] as List<dynamic>).map((e) => e as String).toList(),
      certifications: (json['certifications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      interviewIds: (json['interviewIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      pdfPath: json['pdfPath'] as String?,
      htmlContent: json['htmlContent'] as String?,
      htmlFilePath: json['htmlFilePath'] as String?,
      isHtmlCV: json['isHtmlCV'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CVModelToJson(CVModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'targetPosition': instance.targetPosition,
      'aiIntroduction': instance.aiIntroduction,
      'personalSummary': instance.personalSummary,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'linkedin': instance.linkedin,
      'github': instance.github,
      'website': instance.website,
      'experiences': instance.experiences,
      'education': instance.education,
      'projects': instance.projects,
      'skills': instance.skills,
      'languages': instance.languages,
      'certifications': instance.certifications,
      'interviewIds': instance.interviewIds,
      'pdfPath': instance.pdfPath,
      'htmlContent': instance.htmlContent,
      'htmlFilePath': instance.htmlFilePath,
      'isHtmlCV': instance.isHtmlCV,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
