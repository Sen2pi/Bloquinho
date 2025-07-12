import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../models/password_entry.dart';
import '../services/password_service.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../shared/providers/workspace_provider.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/workspace.dart';

// Estado do password manager
class PasswordState extends Equatable {
  final List<PasswordEntry> passwords;
  final List<PasswordFolder> folders;
  final List<PasswordEntry> filteredPasswords;
  final List<PasswordEntry> searchResults;
  final String searchQuery;
  final String? selectedCategory;
  final String? selectedFolderId;
  final bool showFavoritesOnly;
  final bool showWeakOnly;
  final bool showExpiredOnly;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> stats;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  const PasswordState({
    this.passwords = const [],
    this.folders = const [],
    this.filteredPasswords = const [],
    this.searchResults = const [],
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedFolderId,
    this.showFavoritesOnly = false,
    this.showWeakOnly = false,
    this.showExpiredOnly = false,
    this.isLoading = false,
    this.error,
    this.stats = const {},
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  PasswordState copyWith({
    List<PasswordEntry>? passwords,
    List<PasswordFolder>? folders,
    List<PasswordEntry>? filteredPasswords,
    List<PasswordEntry>? searchResults,
    String? searchQuery,
    String? selectedCategory,
    String? selectedFolderId,
    bool? showFavoritesOnly,
    bool? showWeakOnly,
    bool? showExpiredOnly,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? stats,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
  }) {
    return PasswordState(
      passwords: passwords ?? this.passwords,
      folders: folders ?? this.folders,
      filteredPasswords: filteredPasswords ?? this.filteredPasswords,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedFolderId: selectedFolderId ?? this.selectedFolderId,
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
      showWeakOnly: showWeakOnly ?? this.showWeakOnly,
      showExpiredOnly: showExpiredOnly ?? this.showExpiredOnly,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  @override
  List<Object?> get props => [
        passwords,
        folders,
        filteredPasswords,
        searchResults,
        searchQuery,
        selectedCategory,
        selectedFolderId,
        showFavoritesOnly,
        showWeakOnly,
        showExpiredOnly,
        isLoading,
        error,
        stats,
        isCreating,
        isUpdating,
        isDeleting,
      ];
}

// Notifier para gerenciar o estado
class PasswordNotifier extends StateNotifier<PasswordState> {
  final PasswordService _passwordService;
  String? _currentWorkspaceId;
  String? _currentProfileName;
  bool _isInitialized = false;

  PasswordNotifier(this._passwordService) : super(const PasswordState()) {
    _loadInitialData();
  }

  /// Definir contexto do workspace
  Future<void> setContext(String profileName, String workspaceId) async {
    await _passwordService.setContext(profileName, workspaceId);
    _currentProfileName = profileName;
    _currentWorkspaceId = workspaceId;
    await _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Definir contexto completo no serviço
      if (_currentProfileName != null && _currentWorkspaceId != null) {
        await _passwordService.setContext(
            _currentProfileName!, _currentWorkspaceId!);
      } else if (_currentWorkspaceId != null) {
        await _passwordService.setCurrentWorkspace(_currentWorkspaceId!);
      }

      final passwords = await _passwordService.getAllPasswords();
      state = state.copyWith(
        passwords: passwords,
        isLoading: false,
        error: null,
      );
      _isInitialized = true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addPassword(PasswordEntry password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final id = await _passwordService.createPassword(password);
      await _loadInitialData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updatePassword(PasswordEntry password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _passwordService.updatePassword(password);
      await _loadInitialData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deletePassword(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _passwordService.deletePassword(id);
      await _loadInitialData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteMultiplePasswords(List<String> ids) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _passwordService.deleteMultiplePasswords(ids);
      await _loadInitialData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> searchPasswords(String query) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final results = await _passwordService.searchPasswords(query);
      state = state.copyWith(
        searchResults: results,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearSearch() {
    state = state.copyWith(searchResults: []);
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      return await _passwordService.getPasswordStats();
    } catch (e) {
      return {};
    }
  }

  // Métodos de compatibilidade com a interface
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSelectedCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setSelectedFolder(String? folderId) {
    state = state.copyWith(selectedFolderId: folderId);
  }

  void toggleFavoritesOnly() {
    state = state.copyWith(showFavoritesOnly: !state.showFavoritesOnly);
  }

  void toggleWeakOnly() {
    state = state.copyWith(showWeakOnly: !state.showWeakOnly);
  }

  void toggleExpiredOnly() {
    state = state.copyWith(showExpiredOnly: !state.showExpiredOnly);
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedCategory: null,
      selectedFolderId: null,
      showFavoritesOnly: false,
      showWeakOnly: false,
      showExpiredOnly: false,
    );
  }

  Future<void> refresh() async {
    await _loadInitialData();
  }

  Future<void> toggleFavorite(String id) async {
    final password = state.passwords.firstWhere((p) => p.id == id);
    final updatedPassword = password.copyWith(isFavorite: !password.isFavorite);
    await updatePassword(updatedPassword);
  }

  Future<void> toggleArchived(String id) async {
    final password = state.passwords.firstWhere((p) => p.id == id);
    final updatedPassword = password.copyWith(isArchived: !password.isArchived);
    await updatePassword(updatedPassword);
  }

  Future<void> createPassword(PasswordEntry entry) async {
    await addPassword(entry);
  }

  String generatePassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
    bool excludeSimilar = true,
  }) {
    return _passwordService.generatePassword(
      length: length,
      includeUppercase: includeUppercase,
      includeLowercase: includeLowercase,
      includeNumbers: includeNumbers,
      includeSymbols: includeSymbols,
      excludeSimilar: excludeSimilar,
    );
  }

  PasswordStrength validatePasswordStrength(String password) {
    return _passwordService.validatePasswordStrength(password);
  }

  Future<Map<String, dynamic>> exportPasswords() async {
    return await _passwordService.exportPasswords();
  }

  Future<void> importPasswords(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _passwordService.importPasswords(data);
      await _loadInitialData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao importar senhas: $e',
      );
    }
  }

  void replaceAll(List<PasswordEntry> items) {
    state = state.copyWith(passwords: items);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final passwordServiceProvider = Provider<PasswordService>((ref) {
  return PasswordService();
});

final passwordProvider =
    StateNotifierProvider<PasswordNotifier, PasswordState>((ref) {
  final passwordService = ref.watch(passwordServiceProvider);
  final notifier = PasswordNotifier(passwordService);

  // Inicializa contexto na primeira criação do provider
  final profile = ref.read(currentProfileProvider);
  final workspace = ref.read(currentWorkspaceProvider);
  final defaultWorkspaceId = ref.read(passwordsWorkspaceProvider);
  if (profile != null) {
    final workspaceId = workspace?.id ?? defaultWorkspaceId;
    notifier.setContext(profile.name, workspaceId);
  }

  // Observa mudanças de profile/workspace e atualiza contexto
  ref.listen<UserProfile?>(currentProfileProvider, (prevProfile, currProfile) {
    final workspace = ref.read(currentWorkspaceProvider);
    final defaultWorkspaceId = ref.read(passwordsWorkspaceProvider);

    debugPrint(
        '🔍 [PasswordProvider] Profile mudou: ${prevProfile?.name} → ${currProfile?.name}');
    debugPrint(
        '🔍 [PasswordProvider] Workspace atual: ${workspace?.name} (${workspace?.id})');
    debugPrint('🔍 [PasswordProvider] Workspace default: $defaultWorkspaceId');

    if (currProfile != null) {
      final workspaceId = workspace?.id ?? defaultWorkspaceId;
      debugPrint(
          '[PasswordProvider] Mudou workspace/profile: ${currProfile.name}/$workspaceId');
      notifier.setContext(currProfile.name, workspaceId);
    } else {
      debugPrint('[PasswordProvider] Profile é null, não definindo contexto');
    }
  });

  // Observa mudanças de workspace
  ref.listen<Workspace?>(currentWorkspaceProvider,
      (prevWorkspace, currWorkspace) {
    final profile = ref.read(currentProfileProvider);
    final defaultWorkspaceId = ref.read(passwordsWorkspaceProvider);

    debugPrint(
        '🔍 [PasswordProvider] Workspace mudou: ${prevWorkspace?.name} → ${currWorkspace?.name}');
    debugPrint('🔍 [PasswordProvider] Profile atual: ${profile?.name}');
    debugPrint('🔍 [PasswordProvider] Workspace default: $defaultWorkspaceId');

    if (profile != null) {
      final workspaceId = currWorkspace?.id ?? defaultWorkspaceId;
      debugPrint(
          '[PasswordProvider] Mudou workspace/profile: ${profile.name}/$workspaceId');
      notifier.setContext(profile.name, workspaceId);
    } else {
      debugPrint('[PasswordProvider] Profile é null, não definindo contexto');
    }
  });

  return notifier;
});

// Providers derivados
final passwordsProvider = Provider<List<PasswordEntry>>((ref) {
  return ref.watch(passwordProvider).passwords;
});

final filteredPasswordsProvider = Provider<List<PasswordEntry>>((ref) {
  return ref.watch(passwordProvider).filteredPasswords;
});

final foldersProvider = Provider<List<PasswordFolder>>((ref) {
  return ref.watch(passwordProvider).folders;
});

final passwordStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(passwordProvider).stats;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(passwordProvider).isLoading;
});

final errorProvider = Provider<String?>((ref) {
  return ref.watch(passwordProvider).error;
});

final isCreatingProvider = Provider<bool>((ref) {
  return ref.watch(passwordProvider).isCreating;
});

final isUpdatingProvider = Provider<bool>((ref) {
  return ref.watch(passwordProvider).isUpdating;
});

final isDeletingProvider = Provider<bool>((ref) {
  return ref.watch(passwordProvider).isDeleting;
});

// Provider para inicializar contexto do workspace
final passwordContextProvider = Provider<void>((ref) {
  final notifier = ref.read(passwordProvider.notifier);
  final profile = ref.watch(currentProfileProvider);
  final workspace = ref.watch(currentWorkspaceProvider);
  final defaultWorkspaceId = ref.read(passwordsWorkspaceProvider);

  if (profile != null) {
    final workspaceId = workspace?.id ?? defaultWorkspaceId;
    // Definir contexto de forma assíncrona
    Future.microtask(() async {
      await notifier.setContext(profile.name, workspaceId);
    });
  }
});
