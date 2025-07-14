/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bloquinho/core/services/file_storage_service.dart';
import 'package:bloquinho/core/services/bloquinho_file_service.dart';
import 'package:bloquinho/core/models/user_profile.dart';

/// Provider para o FileStorageService
final fileStorageServiceProvider = Provider<FileStorageService>((ref) {
  return FileStorageService();
});

/// Provider para o BloquinhoFileService
final bloquinhoFileServiceProvider = Provider<BloquinhoFileService>((ref) {
  return BloquinhoFileService();
});

/// Estado do armazenamento de arquivos
class FileStorageState {
  final bool isInitialized;
  final bool isLoading;
  final String? error;
  final List<UserProfile> profiles;
  final String? currentProfileName;
  final String? currentWorkspaceName;
  final Map<String, dynamic> storageStats;

  const FileStorageState({
    this.isInitialized = false,
    this.isLoading = false,
    this.error,
    this.profiles = const [],
    this.currentProfileName,
    this.currentWorkspaceName,
    this.storageStats = const {},
  });

  FileStorageState copyWith({
    bool? isInitialized,
    bool? isLoading,
    String? error,
    List<UserProfile>? profiles,
    String? currentProfileName,
    String? currentWorkspaceName,
    Map<String, dynamic>? storageStats,
  }) {
    return FileStorageState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      profiles: profiles ?? this.profiles,
      currentProfileName: currentProfileName ?? this.currentProfileName,
      currentWorkspaceName: currentWorkspaceName ?? this.currentWorkspaceName,
      storageStats: storageStats ?? this.storageStats,
    );
  }
}

/// Notifier para gerenciar o estado do armazenamento de arquivos
class FileStorageNotifier extends StateNotifier<FileStorageState> {
  final FileStorageService _fileStorageService;
  final BloquinhoFileService _bloquinhoFileService;

  FileStorageNotifier(this._fileStorageService, this._bloquinhoFileService)
      : super(const FileStorageState());

  /// Inicializar o serviço
  Future<void> initialize() async {
    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _fileStorageService.initialize();
      await _loadProfiles();
      await _loadStorageStats();

      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao inicializar: $e',
      );
    }
  }

  /// Carregar perfis existentes
  Future<void> _loadProfiles() async {
    try {
      final profiles = await _fileStorageService.getExistingProfiles();
      state = state.copyWith(profiles: profiles);
    } catch (e) {
      state = state.copyWith(error: 'Erro ao carregar perfis: $e');
    }
  }

  /// Carregar estatísticas de armazenamento
  Future<void> _loadStorageStats() async {
    try {
      final stats = await _fileStorageService.getStorageStats();
      state = state.copyWith(storageStats: stats);
    } catch (e) {
      state = state.copyWith(error: 'Erro ao carregar estatísticas: $e');
    }
  }

  /// Criar novo perfil
  Future<void> createProfile(UserProfile profile) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _fileStorageService.saveProfile(profile);
      await _loadProfiles();
      await _loadStorageStats();

      state = state.copyWith(
        isLoading: false,
        currentProfileName: profile.name,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao criar perfil: $e',
      );
    }
  }

  /// Selecionar perfil atual
  void selectProfile(String profileName) {
    state = state.copyWith(currentProfileName: profileName);
  }

  /// Selecionar workspace atual
  void selectWorkspace(String workspaceName) {
    state = state.copyWith(currentWorkspaceName: workspaceName);
  }

  /// Criar workspace
  Future<void> createWorkspace(String profileName, String workspaceName) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _fileStorageService.createWorkspace(profileName, workspaceName);
      await _loadStorageStats();

      state = state.copyWith(
        isLoading: false,
        currentWorkspaceName: workspaceName,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao criar workspace: $e',
      );
    }
  }

  /// Deletar perfil
  Future<void> deleteProfile(String profileName) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _fileStorageService.deleteProfile(profileName);
      await _loadProfiles();
      await _loadStorageStats();

      // Se o perfil deletado era o atual, limpar seleção
      if (state.currentProfileName == profileName) {
        state = state.copyWith(
          currentProfileName: null,
          currentWorkspaceName: null,
        );
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao deletar perfil: $e',
      );
    }
  }

  /// Salvar página do Bloquinho
  Future<void> saveBloquinhoPage({
    required String pageTitle,
    required String content,
    String? parentPageTitle,
    String? pageId,
    Map<String, dynamic>? metadata,
  }) async {
    if (state.currentProfileName == null ||
        state.currentWorkspaceName == null) {
      state = state.copyWith(error: 'Nenhum perfil ou workspace selecionado');
      return;
    }

    try {
      await _bloquinhoFileService.savePage(
        profileName: state.currentProfileName!,
        workspaceName: state.currentWorkspaceName!,
        pageTitle: pageTitle,
        content: content,
        parentPageTitle: parentPageTitle,
        pageId: pageId,
        metadata: metadata,
      );
    } catch (e) {
      state = state.copyWith(error: 'Erro ao salvar página: $e');
    }
  }

  /// Carregar página do Bloquinho
  Future<Map<String, dynamic>?> loadBloquinhoPage({
    required String pageTitle,
    String? parentPageTitle,
  }) async {
    if (state.currentProfileName == null ||
        state.currentWorkspaceName == null) {
      state = state.copyWith(error: 'Nenhum perfil ou workspace selecionado');
      return null;
    }

    try {
      return await _bloquinhoFileService.loadPage(
        profileName: state.currentProfileName!,
        workspaceName: state.currentWorkspaceName!,
        pageTitle: pageTitle,
        parentPageTitle: parentPageTitle,
      );
    } catch (e) {
      state = state.copyWith(error: 'Erro ao carregar página: $e');
      return null;
    }
  }

  /// Listar todas as páginas do Bloquinho
  Future<List<Map<String, dynamic>>> listBloquinhoPages() async {
    if (state.currentProfileName == null ||
        state.currentWorkspaceName == null) {
      return [];
    }

    try {
      return await _bloquinhoFileService.listAllPages(
        profileName: state.currentProfileName!,
        workspaceName: state.currentWorkspaceName!,
      );
    } catch (e) {
      state = state.copyWith(error: 'Erro ao listar páginas: $e');
      return [];
    }
  }

  /// Auto-save de página do Bloquinho
  Future<void> autoSaveBloquinhoPage({
    required String pageTitle,
    required String content,
    String? parentPageTitle,
    Map<String, dynamic>? metadata,
  }) async {
    if (state.currentProfileName == null ||
        state.currentWorkspaceName == null) {
      return;
    }

    try {
      await _bloquinhoFileService.autoSave(
        profileName: state.currentProfileName!,
        workspaceName: state.currentWorkspaceName!,
        pageTitle: pageTitle,
        content: content,
        parentPageTitle: parentPageTitle,
        metadata: metadata,
      );
    } catch (e) {
      state = state.copyWith(error: 'Erro no auto-save: $e');
    }
  }

  /// Renomear página do Bloquinho
  Future<void> renameBloquinhoPage({
    required String oldTitle,
    required String newTitle,
    String? parentPageTitle,
  }) async {
    if (state.currentProfileName == null ||
        state.currentWorkspaceName == null) {
      state = state.copyWith(error: 'Nenhum perfil ou workspace selecionado');
      return;
    }

    try {
      await _bloquinhoFileService.renamePage(
        profileName: state.currentProfileName!,
        workspaceName: state.currentWorkspaceName!,
        oldTitle: oldTitle,
        newTitle: newTitle,
        parentPageTitle: parentPageTitle,
      );
    } catch (e) {
      state = state.copyWith(error: 'Erro ao renomear página: $e');
    }
  }

  /// Deletar página do Bloquinho
  Future<void> deleteBloquinhoPage({
    required String pageTitle,
    String? parentPageTitle,
  }) async {
    if (state.currentProfileName == null ||
        state.currentWorkspaceName == null) {
      state = state.copyWith(error: 'Nenhum perfil ou workspace selecionado');
      return;
    }

    try {
      await _bloquinhoFileService.deletePage(
        profileName: state.currentProfileName!,
        workspaceName: state.currentWorkspaceName!,
        pageTitle: pageTitle,
        parentPageTitle: parentPageTitle,
      );
    } catch (e) {
      state = state.copyWith(error: 'Erro ao deletar página: $e');
    }
  }

  /// Limpar erro
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Limpar recursos
  void dispose() {
    _bloquinhoFileService.dispose();
  }
}

/// Provider principal para o estado do armazenamento de arquivos
final fileStorageProvider =
    StateNotifierProvider<FileStorageNotifier, FileStorageState>((ref) {
  final fileStorageService = ref.watch(fileStorageServiceProvider);
  final bloquinhoFileService = ref.watch(bloquinhoFileServiceProvider);
  return FileStorageNotifier(fileStorageService, bloquinhoFileService);
});

/// Providers derivados
final isFileStorageInitializedProvider = Provider<bool>((ref) {
  return ref.watch(fileStorageProvider).isInitialized;
});

final isFileStorageLoadingProvider = Provider<bool>((ref) {
  return ref.watch(fileStorageProvider).isLoading;
});

final fileStorageErrorProvider = Provider<String?>((ref) {
  return ref.watch(fileStorageProvider).error;
});

final fileStorageProfilesProvider = Provider<List<UserProfile>>((ref) {
  return ref.watch(fileStorageProvider).profiles;
});

final currentProfileNameProvider = Provider<String?>((ref) {
  return ref.watch(fileStorageProvider).currentProfileName;
});

final currentWorkspaceNameProvider = Provider<String?>((ref) {
  return ref.watch(fileStorageProvider).currentWorkspaceName;
});

final fileStorageStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(fileStorageProvider).storageStats;
});
