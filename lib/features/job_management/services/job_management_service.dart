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
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:bloquinho/core/services/workspace_storage_service.dart';
import 'package:bloquinho/core/services/data_directory_service.dart';

import '../models/interview_model.dart';
import '../models/cv_model.dart';
import '../models/application_model.dart';

class JobManagementService {
  static const String _componentName = 'job_management';

  static final JobManagementService _instance = JobManagementService._internal();
  factory JobManagementService() => _instance;
  JobManagementService._internal();

  final Uuid _uuid = const Uuid();
  final WorkspaceStorageService _workspaceStorage = WorkspaceStorageService();

  bool _isInitialized = false;
  String? _currentWorkspaceId;
  String? _currentProfileName;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _workspaceStorage.initialize();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Erro ao inicializar JobManagementService: $e');
    }
  }

  /// Definir contexto completo (perfil + workspace)
  Future<void> setContext(String profileName, String workspaceId) async {
    await _ensureInitialized();

    _currentProfileName = profileName;
    _currentWorkspaceId = workspaceId;

    // Configurar contexto no WorkspaceStorageService
    _workspaceStorage.setContext(profileName, workspaceId);
  }

  // Interview Management

  Future<List<InterviewModel>> getInterviews() async {
    await _ensureInitialized();
    try {
      final data = await _workspaceStorage.loadWorkspaceData(_componentName);
      if (data == null) return [];
      
      final interviews = <InterviewModel>[];
      final interviewsData = data['interviews'] as List? ?? [];
      
      for (final interviewData in interviewsData) {
        if (interviewData is Map<String, dynamic>) {
          interviews.add(InterviewModel.fromJson(interviewData));
        }
      }
      
      return interviews;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar entrevistas: $e');
      }
      return [];
    }
  }

  Future<InterviewModel?> getInterview(String id) async {
    final interviews = await getInterviews();
    try {
      return interviews.firstWhere((interview) => interview.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveInterview(InterviewModel interview) async {
    await _ensureInitialized();
    try {
      final data = await _workspaceStorage.loadWorkspaceData(_componentName) ?? {};
      
      final interviews = <Map<String, dynamic>>[];
      final interviewsData = data['interviews'] as List? ?? [];
      
      // Carregar entrevistas existentes
      for (final interviewData in interviewsData) {
        if (interviewData is Map<String, dynamic>) {
          interviews.add(interviewData);
        }
      }
      
      // Atualizar ou adicionar entrevista
      final existingIndex = interviews.indexWhere((i) => i['id'] == interview.id);
      if (existingIndex != -1) {
        interviews[existingIndex] = interview.toJson();
      } else {
        interviews.add(interview.toJson());
      }
      
      // Salvar de volta
      data['interviews'] = interviews;
      await _workspaceStorage.saveWorkspaceData(_componentName, data);
    } catch (e) {
      throw Exception('Erro ao salvar entrevista: $e');
    }
  }

  Future<void> deleteInterview(String id) async {
    await _ensureInitialized();
    try {
      final data = await _workspaceStorage.loadWorkspaceData(_componentName) ?? {};
      
      final interviews = <Map<String, dynamic>>[];
      final interviewsData = data['interviews'] as List? ?? [];
      
      // Carregar entrevistas existentes, excluindo a que deve ser deletada
      for (final interviewData in interviewsData) {
        if (interviewData is Map<String, dynamic> && interviewData['id'] != id) {
          interviews.add(interviewData);
        }
      }
      
      // Salvar de volta
      data['interviews'] = interviews;
      await _workspaceStorage.saveWorkspaceData(_componentName, data);
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
      final data = await _workspaceStorage.loadWorkspaceData(_componentName);
      if (data == null) return [];
      
      final cvs = <CVModel>[];
      final cvsData = data['cvs'] as List? ?? [];
      
      for (final cvData in cvsData) {
        if (cvData is Map<String, dynamic>) {
          cvs.add(CVModel.fromJson(cvData));
        }
      }
      
      return cvs;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar CVs: $e');
      }
      return [];
    }
  }

  Future<CVModel?> getCV(String id) async {
    final cvs = await getCVs();
    try {
      return cvs.firstWhere((cv) => cv.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveCV(CVModel cv) async {
    await _ensureInitialized();
    try {
      final data = await _workspaceStorage.loadWorkspaceData(_componentName) ?? {};
      
      final cvs = <Map<String, dynamic>>[];
      final cvsData = data['cvs'] as List? ?? [];
      
      // Carregar CVs existentes
      for (final cvData in cvsData) {
        if (cvData is Map<String, dynamic>) {
          cvs.add(cvData);
        }
      }
      
      // Atualizar ou adicionar CV
      final existingIndex = cvs.indexWhere((c) => c['id'] == cv.id);
      if (existingIndex != -1) {
        cvs[existingIndex] = cv.toJson();
      } else {
        cvs.add(cv.toJson());
      }
      
      // Salvar de volta
      data['cvs'] = cvs;
      await _workspaceStorage.saveWorkspaceData(_componentName, data);
    } catch (e) {
      throw Exception('Erro ao salvar CV: $e');
    }
  }

  Future<void> deleteCV(String id) async {
    await _ensureInitialized();
    try {
      final data = await _workspaceStorage.loadWorkspaceData(_componentName) ?? {};
      
      final cvs = <Map<String, dynamic>>[];
      final cvsData = data['cvs'] as List? ?? [];
      
      // Carregar CVs existentes, excluindo o que deve ser deletado
      for (final cvData in cvsData) {
        if (cvData is Map<String, dynamic> && cvData['id'] != id) {
          cvs.add(cvData);
        }
      }
      
      // Salvar de volta
      data['cvs'] = cvs;
      await _workspaceStorage.saveWorkspaceData(_componentName, data);
    } catch (e) {
      throw Exception('Erro ao deletar CV: $e');
    }
  }

  // Application Management

  Future<List<ApplicationModel>> getApplications() async {
    await _ensureInitialized();
    try {
      final data = await _workspaceStorage.loadWorkspaceData(_componentName);
      if (data == null) return [];
      
      final applications = <ApplicationModel>[];
      final applicationsData = data['applications'] as List? ?? [];
      
      for (final appData in applicationsData) {
        if (appData is Map<String, dynamic>) {
          applications.add(ApplicationModel.fromJson(appData));
        }
      }
      
      return applications;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar candidaturas: $e');
      }
      return [];
    }
  }

  Future<ApplicationModel?> getApplication(String id) async {
    final applications = await getApplications();
    try {
      return applications.firstWhere((app) => app.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveApplication(ApplicationModel application) async {
    await _ensureInitialized();
    try {
      final data = await _workspaceStorage.loadWorkspaceData(_componentName) ?? {};
      
      final applications = <Map<String, dynamic>>[];
      final applicationsData = data['applications'] as List? ?? [];
      
      // Carregar candidaturas existentes
      for (final appData in applicationsData) {
        if (appData is Map<String, dynamic>) {
          applications.add(appData);
        }
      }
      
      // Atualizar ou adicionar candidatura
      final existingIndex = applications.indexWhere((a) => a['id'] == application.id);
      if (existingIndex != -1) {
        applications[existingIndex] = application.toJson();
      } else {
        applications.add(application.toJson());
      }
      
      // Salvar de volta
      data['applications'] = applications;
      await _workspaceStorage.saveWorkspaceData(_componentName, data);
    } catch (e) {
      throw Exception('Erro ao salvar candidatura: $e');
    }
  }

  Future<void> deleteApplication(String id) async {
    await _ensureInitialized();
    try {
      final data = await _workspaceStorage.loadWorkspaceData(_componentName) ?? {};
      
      final applications = <Map<String, dynamic>>[];
      final applicationsData = data['applications'] as List? ?? [];
      
      // Carregar candidaturas existentes, excluindo a que deve ser deletada
      for (final appData in applicationsData) {
        if (appData is Map<String, dynamic> && appData['id'] != id) {
          applications.add(appData);
        }
      }
      
      // Salvar de volta
      data['applications'] = applications;
      await _workspaceStorage.saveWorkspaceData(_componentName, data);
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
    if (!_isInitialized) {
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