/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/interview_model.dart';
import '../models/cv_model.dart';
import '../models/application_model.dart';
import '../../../core/services/data_directory_service.dart';

class JobManagementService {
  static const String _interviewsBox = 'job_interviews';
  static const String _cvsBox = 'job_cvs';
  static const String _applicationsBox = 'job_applications';

  Box<Map>? _interviewsBox;
  Box<Map>? _cvsBox;
  Box<Map>? _applicationsBox;

  Future<void> initialize() async {
    try {
      final dataDir = await DataDirectoryService().initialize();
      final dbPath = await DataDirectoryService().getBasePath();
      
      _interviewsBox = await Hive.openBox<Map>(_interviewsBox, path: dbPath);
      _cvsBox = await Hive.openBox<Map>(_cvsBox, path: dbPath);
      _applicationsBox = await Hive.openBox<Map>(_applicationsBox, path: dbPath);
    } catch (e) {
      throw Exception('Erro ao inicializar JobManagementService: $e');
    }
  }

  // Interview Management

  Future<List<InterviewModel>> getInterviews() async {
    await _ensureInitialized();
    try {
      final interviews = <InterviewModel>[];
      for (var key in _interviewsBox!.keys) {
        final data = _interviewsBox!.get(key);
        if (data != null) {
          interviews.add(InterviewModel.fromJson(Map<String, dynamic>.from(data)));
        }
      }
      return interviews;
    } catch (e) {
      return [];
    }
  }

  Future<InterviewModel?> getInterview(String id) async {
    await _ensureInitialized();
    try {
      final data = _interviewsBox!.get(id);
      if (data != null) {
        return InterviewModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveInterview(InterviewModel interview) async {
    await _ensureInitialized();
    try {
      await _interviewsBox!.put(interview.id, interview.toJson());
    } catch (e) {
      throw Exception('Erro ao salvar entrevista: $e');
    }
  }

  Future<void> deleteInterview(String id) async {
    await _ensureInitialized();
    try {
      await _interviewsBox!.delete(id);
    } catch (e) {
      throw Exception('Erro ao deletar entrevista: $e');
    }
  }

  Future<List<InterviewModel>> getRecentInterviews({int limit = 10}) async {
    final interviews = await getInterviews();
    interviews.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return interviews.take(limit).toList();
  }

  Future<List<InterviewModel>> getInterviewsByType(InterviewType type) async {
    final interviews = await getInterviews();
    return interviews.where((interview) => interview.type == type).toList();
  }

  Future<List<InterviewModel>> getInterviewsByStatus(InterviewStatus status) async {
    final interviews = await getInterviews();
    return interviews.where((interview) => interview.status == status).toList();
  }

  // CV Management

  Future<List<CVModel>> getCVs() async {
    await _ensureInitialized();
    try {
      final cvs = <CVModel>[];
      for (var key in _cvsBox!.keys) {
        final data = _cvsBox!.get(key);
        if (data != null) {
          cvs.add(CVModel.fromJson(Map<String, dynamic>.from(data)));
        }
      }
      return cvs;
    } catch (e) {
      return [];
    }
  }

  Future<CVModel?> getCV(String id) async {
    await _ensureInitialized();
    try {
      final data = _cvsBox!.get(id);
      if (data != null) {
        return CVModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveCV(CVModel cv) async {
    await _ensureInitialized();
    try {
      await _cvsBox!.put(cv.id, cv.toJson());
    } catch (e) {
      throw Exception('Erro ao salvar CV: $e');
    }
  }

  Future<void> deleteCV(String id) async {
    await _ensureInitialized();
    try {
      await _cvsBox!.delete(id);
    } catch (e) {
      throw Exception('Erro ao deletar CV: $e');
    }
  }

  // Application Management

  Future<List<ApplicationModel>> getApplications() async {
    await _ensureInitialized();
    try {
      final applications = <ApplicationModel>[];
      for (var key in _applicationsBox!.keys) {
        final data = _applicationsBox!.get(key);
        if (data != null) {
          applications.add(ApplicationModel.fromJson(Map<String, dynamic>.from(data)));
        }
      }
      return applications;
    } catch (e) {
      return [];
    }
  }

  Future<ApplicationModel?> getApplication(String id) async {
    await _ensureInitialized();
    try {
      final data = _applicationsBox!.get(id);
      if (data != null) {
        return ApplicationModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveApplication(ApplicationModel application) async {
    await _ensureInitialized();
    try {
      await _applicationsBox!.put(application.id, application.toJson());
    } catch (e) {
      throw Exception('Erro ao salvar candidatura: $e');
    }
  }

  Future<void> deleteApplication(String id) async {
    await _ensureInitialized();
    try {
      await _applicationsBox!.delete(id);
    } catch (e) {
      throw Exception('Erro ao deletar candidatura: $e');
    }
  }

  Future<List<ApplicationModel>> getApplicationsByStatus(ApplicationStatus status) async {
    final applications = await getApplications();
    return applications.where((app) => app.status == status).toList();
  }

  Future<List<ApplicationModel>> getApplicationsByCV(String cvId) async {
    final applications = await getApplications();
    return applications.where((app) => app.cvId == cvId).toList();
  }

  // Statistics and Analytics

  Future<Map<String, dynamic>> getJobStatistics() async {
    final interviews = await getInterviews();
    final cvs = await getCVs();
    final applications = await getApplications();

    // Interview statistics
    final interviewsByType = <InterviewType, int>{};
    final interviewsByStatus = <InterviewStatus, int>{};
    
    for (final interview in interviews) {
      interviewsByType[interview.type] = (interviewsByType[interview.type] ?? 0) + 1;
      interviewsByStatus[interview.status] = (interviewsByStatus[interview.status] ?? 0) + 1;
    }

    // Application statistics
    final applicationsByStatus = <ApplicationStatus, int>{};
    
    for (final application in applications) {
      applicationsByStatus[application.status] = (applicationsByStatus[application.status] ?? 0) + 1;
    }

    // Monthly statistics
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    
    final interviewsThisMonth = interviews.where((interview) {
      return interview.dateTime.isAfter(thisMonth);
    }).length;
    
    final applicationsThisMonth = applications.where((app) {
      return app.appliedDate.isAfter(thisMonth);
    }).length;

    return {
      'totalInterviews': interviews.length,
      'totalCVs': cvs.length,
      'totalApplications': applications.length,
      'interviewsByType': interviewsByType,
      'interviewsByStatus': interviewsByStatus,
      'applicationsByStatus': applicationsByStatus,
      'interviewsThisMonth': interviewsThisMonth,
      'applicationsThisMonth': applicationsThisMonth,
      'recentInterviews': await getRecentInterviews(limit: 5),
    };
  }

  // Link Management

  Future<void> linkInterviewToApplication(String interviewId, String applicationId) async {
    final interview = await getInterview(interviewId);
    if (interview != null) {
      final updatedInterview = interview.copyWith(applicationId: applicationId);
      await saveInterview(updatedInterview);
    }

    final application = await getApplication(applicationId);
    if (application != null) {
      final updatedIds = List<String>.from(application.interviewIds);
      if (!updatedIds.contains(interviewId)) {
        updatedIds.add(interviewId);
        final updatedApplication = application.copyWith(interviewIds: updatedIds);
        await saveApplication(updatedApplication);
      }
    }
  }

  Future<void> linkCVToInterview(String cvId, String interviewId) async {
    final cv = await getCV(cvId);
    if (cv != null) {
      final updatedIds = List<String>.from(cv.interviewIds);
      if (!updatedIds.contains(interviewId)) {
        updatedIds.add(interviewId);
        final updatedCV = cv.copyWith(interviewIds: updatedIds);
        await saveCV(updatedCV);
      }
    }

    final interview = await getInterview(interviewId);
    if (interview != null) {
      final updatedInterview = interview.copyWith(cvId: cvId);
      await saveInterview(updatedInterview);
    }
  }

  // Search and Filter

  Future<List<InterviewModel>> searchInterviews(String query) async {
    final interviews = await getInterviews();
    final lowercaseQuery = query.toLowerCase();
    
    return interviews.where((interview) {
      return interview.title.toLowerCase().contains(lowercaseQuery) ||
             interview.company.toLowerCase().contains(lowercaseQuery) ||
             interview.description?.toLowerCase().contains(lowercaseQuery) == true;
    }).toList();
  }

  Future<List<CVModel>> searchCVs(String query) async {
    final cvs = await getCVs();
    final lowercaseQuery = query.toLowerCase();
    
    return cvs.where((cv) {
      return cv.name.toLowerCase().contains(lowercaseQuery) ||
             cv.targetPosition?.toLowerCase().contains(lowercaseQuery) == true ||
             cv.skills.any((skill) => skill.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  Future<List<ApplicationModel>> searchApplications(String query) async {
    final applications = await getApplications();
    final lowercaseQuery = query.toLowerCase();
    
    return applications.where((app) {
      return app.title.toLowerCase().contains(lowercaseQuery) ||
             app.company.toLowerCase().contains(lowercaseQuery) ||
             app.description?.toLowerCase().contains(lowercaseQuery) == true;
    }).toList();
  }

  // Private methods

  Future<void> _ensureInitialized() async {
    if (_interviewsBox == null || _cvsBox == null || _applicationsBox == null) {
      await initialize();
    }
  }

  // Export/Import functionality

  Future<String> exportData() async {
    final interviews = await getInterviews();
    final cvs = await getCVs();
    final applications = await getApplications();

    final data = {
      'interviews': interviews.map((e) => e.toJson()).toList(),
      'cvs': cvs.map((e) => e.toJson()).toList(),
      'applications': applications.map((e) => e.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };

    return jsonEncode(data);
  }

  Future<void> importData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData);
      
      // Import interviews
      if (data['interviews'] != null) {
        for (final interviewData in data['interviews']) {
          final interview = InterviewModel.fromJson(interviewData);
          await saveInterview(interview);
        }
      }
      
      // Import CVs
      if (data['cvs'] != null) {
        for (final cvData in data['cvs']) {
          final cv = CVModel.fromJson(cvData);
          await saveCV(cv);
        }
      }
      
      // Import applications
      if (data['applications'] != null) {
        for (final applicationData in data['applications']) {
          final application = ApplicationModel.fromJson(applicationData);
          await saveApplication(application);
        }
      }
    } catch (e) {
      throw Exception('Erro ao importar dados: $e');
    }
  }
}