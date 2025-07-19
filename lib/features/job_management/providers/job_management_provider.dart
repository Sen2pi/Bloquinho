/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/interview_model.dart';
import '../models/cv_model.dart';
import '../models/application_model.dart';
import '../services/job_management_service.dart';
import '../services/cv_photo_service.dart';
import '../services/html_storage_service.dart';
import '../services/eml_parser_service.dart';
import '../services/email_tracking_storage_service.dart';
import '../models/email_tracking_model.dart';
import '../../../shared/providers/workspace_provider.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../core/models/workspace.dart';

// Service Provider
final jobManagementServiceProvider = Provider<JobManagementService>((ref) {
  final service = JobManagementService();
  final cvPhotoService = CVPhotoService();
  final htmlStorageService = HtmlStorageService();
  final emlParserService = EmlParserService();
  final emailTrackingService = EmailTrackingStorageService();
  
  // Configurar contexto automaticamente para todos os serviços
  ref.listen<Workspace?>(workspaceProvider, (previous, next) async {
    if (next != null) {
      final currentProfile = ref.read(currentProfileProvider);
      if (currentProfile != null) {
        await service.setContext(currentProfile.name, next.id);
        await cvPhotoService.setContext(currentProfile.name, next.id);
        await htmlStorageService.setContext(currentProfile.name, next.id);
        await emlParserService.setContext(currentProfile.name, next.id);
        await emailTrackingService.setContext(currentProfile.name, next.id);
      }
    }
  });
  
  // Configurar contexto inicial se já houver workspace e perfil
  final currentWorkspace = ref.read(workspaceProvider);
  final currentProfile = ref.read(currentProfileProvider);
  if (currentWorkspace != null && currentProfile != null) {
    Future.microtask(() async {
      await service.setContext(currentProfile.name, currentWorkspace.id);
      await cvPhotoService.setContext(currentProfile.name, currentWorkspace.id);
      await htmlStorageService.setContext(currentProfile.name, currentWorkspace.id);
      await emlParserService.setContext(currentProfile.name, currentWorkspace.id);
      await emailTrackingService.setContext(currentProfile.name, currentWorkspace.id);
    });
  }
  
  return service;
});

// Interview Providers
final interviewsProvider = FutureProvider<List<InterviewModel>>((ref) async {
  final service = ref.watch(jobManagementServiceProvider);
  await service.initialize();
  return service.getInterviews();
});

final interviewProvider = FutureProvider.family<InterviewModel?, String>((ref, id) async {
  final service = ref.watch(jobManagementServiceProvider);
  await service.initialize();
  return service.getInterview(id);
});

final recentInterviewsProvider = FutureProvider.family<List<InterviewModel>, int>((ref, limit) async {
  final service = ref.watch(jobManagementServiceProvider);
  await service.initialize();
  return service.getRecentInterviews(limit: limit);
});

final interviewsByTypeProvider = FutureProvider.family<List<InterviewModel>, InterviewType>((ref, type) async {
  final service = ref.watch(jobManagementServiceProvider);
  await service.initialize();
  return service.getInterviewsByType(type);
});

final interviewsByStatusProvider = FutureProvider.family<List<InterviewModel>, InterviewStatus>((ref, status) async {
  final service = ref.watch(jobManagementServiceProvider);
  await service.initialize();
  return service.getInterviewsByStatus(status);
});

// CV Providers
final cvsProvider = FutureProvider<List<CVModel>>((ref) async {
  final service = ref.watch(jobManagementServiceProvider);
  await service.initialize();
  return service.getCVs();
});

final cvProvider = FutureProvider.family<CVModel?, String>((ref, id) async {
  final service = ref.watch(jobManagementServiceProvider);
  await service.initialize();
  return service.getCV(id);
});

// Application Providers
final applicationsProvider = FutureProvider<List<ApplicationModel>>((ref) async {
  final service = ref.watch(jobManagementServiceProvider);
  await service.initialize();
  return service.getApplications();
});

final applicationProvider = FutureProvider.family<ApplicationModel?, String>((ref, id) async {
  final service = ref.watch(jobManagementServiceProvider);
  await service.initialize();
  return service.getApplication(id);
});

final applicationsByStatusProvider = FutureProvider.family<List<ApplicationModel>, ApplicationStatus>((ref, status) async {
  final service = ref.watch(jobManagementServiceProvider);
  await service.initialize();
  return service.getApplicationsByStatus(status);
});

final applicationsByCVProvider = FutureProvider.family<List<ApplicationModel>, String>((ref, cvId) async {
  final service = ref.watch(jobManagementServiceProvider);
  await service.initialize();
  return service.getApplicationsByCV(cvId);
});

// Statistics Provider
final jobStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(jobManagementServiceProvider);
  await service.initialize();
  return service.getJobStatistics();
});

// Search Providers
final searchInterviewsProvider = FutureProvider.family<List<InterviewModel>, String>((ref, query) async {
  final service = ref.watch(jobManagementServiceProvider);
  await service.initialize();
  return service.searchInterviews(query);
});

final searchCVsProvider = FutureProvider.family<List<CVModel>, String>((ref, query) async {
  final service = ref.watch(jobManagementServiceProvider);
  await service.initialize();
  return service.searchCVs(query);
});

final searchApplicationsProvider = FutureProvider.family<List<ApplicationModel>, String>((ref, query) async {
  final service = ref.watch(jobManagementServiceProvider);
  await service.initialize();
  return service.searchApplications(query);
});

// Notifier Classes for State Management
class InterviewsNotifier extends StateNotifier<AsyncValue<List<InterviewModel>>> {
  InterviewsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadInterviews();
  }

  final Ref ref;

  Future<void> loadInterviews() async {
    try {
      state = const AsyncValue.loading();
      final service = ref.read(jobManagementServiceProvider);
      await service.initialize();
      final interviews = await service.getInterviews();
      state = AsyncValue.data(interviews);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addInterview(InterviewModel interview) async {
    try {
      final service = ref.read(jobManagementServiceProvider);
      await service.saveInterview(interview);
      await loadInterviews();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateInterview(InterviewModel interview) async {
    try {
      final service = ref.read(jobManagementServiceProvider);
      await service.saveInterview(interview);
      await loadInterviews();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteInterview(String id) async {
    try {
      final service = ref.read(jobManagementServiceProvider);
      await service.deleteInterview(id);
      await loadInterviews();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class CVsNotifier extends StateNotifier<AsyncValue<List<CVModel>>> {
  CVsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadCVs();
  }

  final Ref ref;

  Future<void> loadCVs() async {
    try {
      state = const AsyncValue.loading();
      final service = ref.read(jobManagementServiceProvider);
      await service.initialize();
      final cvs = await service.getCVs();
      state = AsyncValue.data(cvs);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addCV(CVModel cv) async {
    try {
      final service = ref.read(jobManagementServiceProvider);
      await service.saveCV(cv);
      await loadCVs();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateCV(CVModel cv) async {
    try {
      final service = ref.read(jobManagementServiceProvider);
      await service.saveCV(cv);
      await loadCVs();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteCV(String id) async {
    try {
      final service = ref.read(jobManagementServiceProvider);
      await service.deleteCV(id);
      await loadCVs();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class ApplicationsNotifier extends StateNotifier<AsyncValue<List<ApplicationModel>>> {
  ApplicationsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadApplications();
  }

  final Ref ref;

  Future<void> loadApplications() async {
    try {
      state = const AsyncValue.loading();
      final service = ref.read(jobManagementServiceProvider);
      await service.initialize();
      final applications = await service.getApplications();
      state = AsyncValue.data(applications);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addApplication(ApplicationModel application) async {
    try {
      final service = ref.read(jobManagementServiceProvider);
      await service.saveApplication(application);
      await loadApplications();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateApplication(ApplicationModel application) async {
    try {
      final service = ref.read(jobManagementServiceProvider);
      await service.saveApplication(application);
      await loadApplications();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteApplication(String id) async {
    try {
      final service = ref.read(jobManagementServiceProvider);
      await service.deleteApplication(id);
      await loadApplications();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Notifier Providers
final interviewsNotifierProvider = StateNotifierProvider<InterviewsNotifier, AsyncValue<List<InterviewModel>>>((ref) {
  return InterviewsNotifier(ref);
});

final cvsNotifierProvider = StateNotifierProvider<CVsNotifier, AsyncValue<List<CVModel>>>((ref) {
  return CVsNotifier(ref);
});

final applicationsNotifierProvider = StateNotifierProvider<ApplicationsNotifier, AsyncValue<List<ApplicationModel>>>((ref) {
  return ApplicationsNotifier(ref);
});

// UI State Providers
final selectedInterviewProvider = StateProvider<InterviewModel?>((ref) => null);
final selectedCVProvider = StateProvider<CVModel?>((ref) => null);
final selectedApplicationProvider = StateProvider<ApplicationModel?>((ref) => null);

// Filter Providers
final interviewFilterProvider = StateProvider<InterviewType?>((ref) => null);
final applicationFilterProvider = StateProvider<ApplicationStatus?>((ref) => null);

// Search Query Providers
final interviewSearchQueryProvider = StateProvider<String>((ref) => '');
final cvSearchQueryProvider = StateProvider<String>((ref) => '');
final applicationSearchQueryProvider = StateProvider<String>((ref) => '');

// Dashboard State Provider
final dashboardTabProvider = StateProvider<int>((ref) => 0);

// Form State Providers
final interviewFormProvider = StateProvider<InterviewModel?>((ref) => null);
final cvFormProvider = StateProvider<CVModel?>((ref) => null);
final applicationFormProvider = StateProvider<ApplicationModel?>((ref) => null);

// Loading States
final isLoadingInterviewProvider = StateProvider<bool>((ref) => false);
final isLoadingCVProvider = StateProvider<bool>((ref) => false);
final isLoadingApplicationProvider = StateProvider<bool>((ref) => false);

// Error States
final interviewErrorProvider = StateProvider<String?>((ref) => null);
final cvErrorProvider = StateProvider<String?>((ref) => null);
final applicationErrorProvider = StateProvider<String?>((ref) => null);

// Email Tracking Service Providers
final emlParserServiceProvider = Provider<EmlParserService>((ref) {
  return EmlParserService();
});

final emailTrackingStorageServiceProvider = Provider<EmailTrackingStorageService>((ref) {
  return EmailTrackingStorageService();
});

// Email Tracking Providers
final emailTrackingProvider = FutureProvider<List<EmailTrackingModel>>((ref) async {
  final service = ref.watch(emailTrackingStorageServiceProvider);
  return service.getEmails();
});

final emailTrackingByApplicationProvider = FutureProvider.family<List<EmailTrackingModel>, String>((ref, applicationId) async {
  final service = ref.watch(emailTrackingStorageServiceProvider);
  return service.getEmailsByApplicationId(applicationId);
});

// Email Tracking Notifier
class EmailTrackingNotifier extends StateNotifier<AsyncValue<List<EmailTrackingModel>>> {
  EmailTrackingNotifier(this.ref) : super(const AsyncValue.loading());

  final Ref ref;

  Future<void> loadEmailsForApplication(String applicationId) async {
    try {
      state = const AsyncValue.loading();
      final service = ref.read(emailTrackingStorageServiceProvider);
      final emails = await service.getEmailsByApplicationId(applicationId);
      state = AsyncValue.data(emails);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addEmail(EmailTrackingModel email) async {
    try {
      final service = ref.read(emailTrackingStorageServiceProvider);
      await service.saveEmail(email);
      await loadEmailsForApplication(email.applicationId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteEmail(String emailId, String applicationId) async {
    try {
      final service = ref.read(emailTrackingStorageServiceProvider);
      await service.deleteEmail(emailId);
      await loadEmailsForApplication(applicationId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final emailTrackingNotifierProvider = StateNotifierProvider<EmailTrackingNotifier, AsyncValue<List<EmailTrackingModel>>>((ref) {
  return EmailTrackingNotifier(ref);
});