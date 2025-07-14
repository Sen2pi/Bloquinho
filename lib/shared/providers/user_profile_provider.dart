/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/user_profile.dart';
import '../../core/services/user_profile_service.dart';

/// Estado do perfil de usuário
class UserProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final bool isUpdating;
  final bool isUploadingAvatar;
  final String? error;
  final Map<String, dynamic> stats;

  const UserProfileState({
    this.profile,
    this.isLoading = false,
    this.isUpdating = false,
    this.isUploadingAvatar = false,
    this.error,
    this.stats = const {},
  });

  UserProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? isUpdating,
    bool? isUploadingAvatar,
    String? error,
    Map<String, dynamic>? stats,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      error: error,
      stats: stats ?? this.stats,
    );
  }

  bool get hasProfile => profile != null;
  bool get isProfileComplete => profile?.isComplete ?? false;
  bool get hasAvatar => profile?.hasCustomAvatar ?? false;
  bool get isBusy => isLoading || isUpdating || isUploadingAvatar;
}

/// Notifier para gerenciar estado do perfil
class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final UserProfileService _profileService;

  UserProfileNotifier(this._profileService) : super(const UserProfileState()) {
    _loadProfile();
  }

  /// Carregar perfil atual
  Future<void> _loadProfile() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _profileService.initialize();

      final profile = await _profileService.getCurrentProfile();

      // Carregar stats apenas se temos perfil, e de forma assíncrona
      Map<String, dynamic> stats = {};
      if (profile != null) {
        try {
          stats = await _profileService.getProfileStats();
        } catch (e) {
          // Não falhamos o loading por causa das stats
        }
      }

      state = state.copyWith(
        profile: profile,
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Recarregar perfil
  Future<void> refresh() async {
    _profileService.clearCache();
    await _loadProfile();
  }

  /// Carregar perfil existente (para inicialização)
  Future<void> loadProfile() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _loadProfile();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Criar novo perfil
  Future<void> createProfile({
    required String name,
    required String email,
  }) async {
    if (state.isUpdating) return;

    state = state.copyWith(isUpdating: true, error: null);

    try {
      final profile = await _profileService.createProfile(
        name: name,
        email: email,
      );
      final stats = await _profileService.getProfileStats();

      state = state.copyWith(
        profile: profile,
        stats: stats,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Criar perfil a partir do OAuth2
  Future<void> createProfileFromOAuth({
    required String name,
    required String email,
    String? avatarPath,
    String? avatarUrl,
  }) async {
    if (state.isUpdating) return;

    state = state.copyWith(isUpdating: true, error: null);

    try {
      final profile = await _profileService.createProfileFromOAuth(
        name: name,
        email: email,
        avatarPath: avatarPath,
        avatarUrl: avatarUrl,
      );
      final stats = await _profileService.getProfileStats();

      state = state.copyWith(
        profile: profile,
        stats: stats,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Atualizar perfil
  Future<void> updateProfile({
    String? name,
    String? email,
    String? bio,
    String? phone,
    String? location,
    DateTime? birthDate,
    String? website,
    String? profession,
    List<String>? interests,
    bool? isPublic,
  }) async {
    if (state.isUpdating) return;

    state = state.copyWith(isUpdating: true, error: null);

    try {
      final updatedProfile = await _profileService.updateProfile(
        name: name,
        email: email,
        bio: bio,
        phone: phone,
        location: location,
        birthDate: birthDate,
        website: website,
        profession: profession,
        interests: interests,
        isPublic: isPublic,
      );
      final stats = await _profileService.getProfileStats();

      state = state.copyWith(
        profile: updatedProfile,
        stats: stats,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Upload de avatar da galeria
  Future<void> uploadAvatarFromGallery() async {
    if (state.isUploadingAvatar) return;

    state = state.copyWith(isUploadingAvatar: true, error: null);

    try {
      final updatedProfile = await _profileService.uploadAvatarFromGallery();
      final stats = await _profileService.getProfileStats();

      state = state.copyWith(
        profile: updatedProfile,
        stats: stats,
        isUploadingAvatar: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUploadingAvatar: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Upload de avatar da câmera
  Future<void> uploadAvatarFromCamera() async {
    if (state.isUploadingAvatar) return;

    state = state.copyWith(isUploadingAvatar: true, error: null);

    try {
      final updatedProfile = await _profileService.uploadAvatarFromCamera();
      final stats = await _profileService.getProfileStats();

      state = state.copyWith(
        profile: updatedProfile,
        stats: stats,
        isUploadingAvatar: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUploadingAvatar: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Remover avatar
  Future<void> removeAvatar() async {
    if (state.isUpdating) return;

    state = state.copyWith(isUpdating: true, error: null);

    try {
      final updatedProfile = await _profileService.removeAvatar();
      final stats = await _profileService.getProfileStats();

      state = state.copyWith(
        profile: updatedProfile,
        stats: stats,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Deletar perfil
  Future<void> deleteProfile() async {
    if (state.isUpdating) return;

    state = state.copyWith(isUpdating: true, error: null);

    try {
      await _profileService.deleteProfile();

      state = const UserProfileState();
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Deletar todos os dados do aplicativo (reset completo para onboarding)
  Future<void> deleteAllData() async {
    if (state.isUpdating) return;

    state = state.copyWith(isUpdating: true, error: null);

    try {
      await _profileService.deleteAllData();

      // Reset completo do estado
      state = const UserProfileState();
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Obter arquivo de avatar
  Future<File?> getAvatarFile() async {
    return await _profileService.getAvatarFile();
  }

  /// Exportar dados do perfil
  Future<Map<String, dynamic>> exportProfile() async {
    return await _profileService.exportProfile();
  }

  /// Limpar erro
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider do serviço de perfil (singleton)
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});

/// Provider principal do perfil de usuário (singleton)
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  final service = ref.watch(userProfileServiceProvider);
  return UserProfileNotifier(service);
});

/// Provider derivado: perfil atual
final currentProfileProvider = Provider<UserProfile?>((ref) {
  return ref.watch(userProfileProvider).profile;
});

/// Provider derivado: verificar se tem perfil
final hasProfileProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).hasProfile;
});

/// Provider derivado: verificar se perfil está completo
final isProfileCompleteProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).isProfileComplete;
});

/// Provider derivado: verificar se tem avatar
final hasAvatarProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).hasAvatar;
});

/// Provider derivado: estado de loading
final isProfileLoadingProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).isLoading;
});

/// Provider derivado: estado de atualização
final isProfileUpdatingProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).isUpdating;
});

/// Provider derivado: estado de upload de avatar
final isUploadingAvatarProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).isUploadingAvatar;
});

/// Provider derivado: verificar se está ocupado
final isProfileBusyProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).isBusy;
});

/// Provider derivado: erro atual
final profileErrorProvider = Provider<String?>((ref) {
  return ref.watch(userProfileProvider).error;
});

/// Provider derivado: estatísticas do perfil
final profileStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(userProfileProvider).stats;
});

/// Provider derivado: iniciais do nome para avatar
final profileInitialsProvider = Provider<String>((ref) {
  final profile = ref.watch(currentProfileProvider);
  return profile?.initials ?? '';
});

/// Provider derivado: idade do usuário
final userAgeProvider = Provider<int?>((ref) {
  final profile = ref.watch(currentProfileProvider);
  return profile?.age;
});

/// Provider derivado: arquivo de avatar
final avatarFileProvider = FutureProvider<File?>((ref) async {
  final notifier = ref.watch(userProfileProvider.notifier);
  return await notifier.getAvatarFile();
});

/// Provider para avatar URL (para OAuth2)
final avatarUrlProvider = Provider<String?>((ref) {
  final profile = ref.watch(currentProfileProvider);
  return profile?.avatarUrl;
});

/// Provider para verificar se tem avatar customizado
final hasCustomAvatarProvider = Provider<bool>((ref) {
  final profile = ref.watch(currentProfileProvider);
  return profile?.hasCustomAvatar ?? false;
});

/// Provider para avatar path local
final avatarPathProvider = Provider<String?>((ref) {
  final profile = ref.watch(currentProfileProvider);
  return profile?.avatarPath;
});

/// Provider para verificar se deve mostrar onboarding
final shouldShowOnboardingProvider = Provider<bool>((ref) {
  final hasProfile = ref.watch(hasProfileProvider);
  return !hasProfile;
});

/// Provider para verificar se deve solicitar completar perfil
final shouldCompleteProfileProvider = Provider<bool>((ref) {
  final hasProfile = ref.watch(hasProfileProvider);
  final isComplete = ref.watch(isProfileCompleteProvider);
  return hasProfile && !isComplete;
});
