/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

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

  // NOVOS CAMPOS PARA FUNCIONALIDADES AVANÇADAS
  final Map<String, dynamic> securityAnalysis;
  final List<String> securitySuggestions;
  final bool showCompromisedOnly;
  final bool showReusedOnly;
  final bool showOldOnly;
  final bool showWith2FAOnly;
  final bool showInVaultOnly;
  final bool showPinnedOnly;

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
    this.securityAnalysis = const {},
    this.securitySuggestions = const [],
    this.showCompromisedOnly = false,
    this.showReusedOnly = false,
    this.showOldOnly = false,
    this.showWith2FAOnly = false,
    this.showInVaultOnly = false,
    this.showPinnedOnly = false,
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
    Map<String, dynamic>? securityAnalysis,
    List<String>? securitySuggestions,
    bool? showCompromisedOnly,
    bool? showReusedOnly,
    bool? showOldOnly,
    bool? showWith2FAOnly,
    bool? showInVaultOnly,
    bool? showPinnedOnly,
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
      securityAnalysis: securityAnalysis ?? this.securityAnalysis,
      securitySuggestions: securitySuggestions ?? this.securitySuggestions,
      showCompromisedOnly: showCompromisedOnly ?? this.showCompromisedOnly,
      showReusedOnly: showReusedOnly ?? this.showReusedOnly,
      showOldOnly: showOldOnly ?? this.showOldOnly,
      showWith2FAOnly: showWith2FAOnly ?? this.showWith2FAOnly,
      showInVaultOnly: showInVaultOnly ?? this.showInVaultOnly,
      showPinnedOnly: showPinnedOnly ?? this.showPinnedOnly,
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
        securityAnalysis,
        securitySuggestions,
        showCompromisedOnly,
        showReusedOnly,
        showOldOnly,
        showWith2FAOnly,
        showInVaultOnly,
        showPinnedOnly,
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

  void _applyFilters() {
    final all = state.passwords;
    List<PasswordEntry> filtered = List.from(all);

    // Filtros principais
    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      filtered = filtered
          .where((e) =>
              e.title.toLowerCase().contains(q) ||
              e.username.toLowerCase().contains(q) ||
              (e.website?.toLowerCase().contains(q) ?? false) ||
              (e.notes?.toLowerCase().contains(q) ?? false) ||
              (e.category?.toLowerCase().contains(q) ?? false) ||
              e.tags.any((tag) => tag.toLowerCase().contains(q)))
          .toList();
    }
    if (state.selectedCategory != null) {
      filtered =
          filtered.where((e) => e.category == state.selectedCategory).toList();
    }
    if (state.selectedFolderId != null) {
      filtered =
          filtered.where((e) => e.folderId == state.selectedFolderId).toList();
    }
    if (state.showFavoritesOnly) {
      filtered = filtered.where((e) => e.isFavorite).toList();
    }
    if (state.showWeakOnly) {
      filtered = filtered
          .where((e) =>
              e.strength == PasswordStrength.veryWeak ||
              e.strength == PasswordStrength.weak)
          .toList();
    }
    if (state.showExpiredOnly) {
      filtered = filtered.where((e) => e.isExpired).toList();
    }
    if (state.showCompromisedOnly) {
      filtered = filtered.where((e) => e.isCompromised).toList();
    }
    if (state.showReusedOnly) {
      filtered = filtered.where((e) => e.isReused).toList();
    }
    if (state.showOldOnly) {
      filtered = filtered.where((e) => e.isOldPassword).toList();
    }
    if (state.showWith2FAOnly) {
      filtered = filtered.where((e) => e.hasTwoFactor).toList();
    }
    if (state.showInVaultOnly) {
      filtered = filtered.where((e) => e.isInSecureVault).toList();
    }
    if (state.showPinnedOnly) {
      filtered = filtered.where((e) => e.isPinned).toList();
    }
    state = state.copyWith(filteredPasswords: filtered);
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
      final stats = await _passwordService.getPasswordStats();
      final analysis = await _passwordService.analyzeSecurity();

      state = state.copyWith(
        passwords: passwords,
        stats: stats,
        securityAnalysis: analysis,
        isLoading: false,
        error: null,
      );
      _applyFilters();
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
      state = state.copyWith(isCreating: true, error: null);
      final id = await _passwordService.createPassword(password);
      await _loadInitialData();
      state = state.copyWith(isCreating: false);
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updatePassword(PasswordEntry password) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);
      await _passwordService.updatePassword(password);
      await _loadInitialData();
      state = state.copyWith(isUpdating: false);
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deletePassword(String id) async {
    try {
      state = state.copyWith(isDeleting: true, error: null);
      await _passwordService.deletePassword(id);
      await _loadInitialData();
      state = state.copyWith(isDeleting: false);
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteMultiplePasswords(List<String> ids) async {
    try {
      state = state.copyWith(isDeleting: true, error: null);
      await _passwordService.deleteMultiplePasswords(ids);
      await _loadInitialData();
      state = state.copyWith(isDeleting: false);
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
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

  // NOVOS MÉTODOS PARA FUNCIONALIDADES AVANÇADAS

  /// Analisar segurança geral
  Future<Map<String, dynamic>> analyzeSecurity() async {
    try {
      return await _passwordService.analyzeSecurity();
    } catch (e) {
      return {};
    }
  }

  /// Obter sugestões de segurança para uma senha específica
  Future<List<String>> getSecuritySuggestions(PasswordEntry password) async {
    try {
      return await _passwordService.suggestSecurityImprovements(password);
    } catch (e) {
      return [];
    }
  }

  /// Verificar se uma senha foi comprometida
  Future<bool> checkPasswordBreach(String password) async {
    try {
      return await _passwordService.checkPasswordBreach(password);
    } catch (e) {
      return false;
    }
  }

  /// Verificar se uma senha é reutilizada
  Future<bool> checkPasswordReuse(String password, String excludeId) async {
    try {
      return await _passwordService.checkPasswordReuse(password, excludeId);
    } catch (e) {
      return false;
    }
  }

  /// Adicionar senha ao histórico
  Future<void> addToPasswordHistory(
      PasswordEntry password, String oldPassword) async {
    try {
      await _passwordService.addToPasswordHistory(password, oldPassword);
      await _loadInitialData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Gerar código 2FA
  String generateTwoFactorSecret() {
    return _passwordService.generateTwoFactorSecret();
  }

  /// Verificar código 2FA
  bool verifyTwoFactorCode(String secret, String code) {
    return _passwordService.verifyTwoFactorCode(secret, code);
  }

  /// Criar vault seguro
  Future<String> createVault(String name, String description) async {
    try {
      return await _passwordService.createVault(name, description);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return '';
    }
  }

  /// Mover entrada para vault
  Future<void> moveToVault(PasswordEntry password, String vaultId) async {
    try {
      await _passwordService.moveToVault(password, vaultId);
      await _loadInitialData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Configurar acesso de emergência
  Future<void> setupEmergencyAccess(
      PasswordEntry password, String contactEmail, int days) async {
    try {
      await _passwordService.setupEmergencyAccess(password, contactEmail, days);
      await _loadInitialData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Verificar acesso de emergência
  Future<bool> checkEmergencyAccess(PasswordEntry password) async {
    try {
      return await _passwordService.checkEmergencyAccess(password);
    } catch (e) {
      return false;
    }
  }

  // NOVOS FILTROS AVANÇADOS
  Future<List<PasswordEntry>> getCompromisedPasswords() async {
    try {
      return await _passwordService.getCompromisedPasswords();
    } catch (e) {
      return [];
    }
  }

  Future<List<PasswordEntry>> getReusedPasswords() async {
    try {
      return await _passwordService.getReusedPasswords();
    } catch (e) {
      return [];
    }
  }

  Future<List<PasswordEntry>> getOldPasswords() async {
    try {
      return await _passwordService.getOldPasswords();
    } catch (e) {
      return [];
    }
  }

  Future<List<PasswordEntry>> getPasswordsWith2FA() async {
    try {
      return await _passwordService.getPasswordsWith2FA();
    } catch (e) {
      return [];
    }
  }

  Future<List<PasswordEntry>> getPasswordsInVault() async {
    try {
      return await _passwordService.getPasswordsInVault();
    } catch (e) {
      return [];
    }
  }

  Future<List<PasswordEntry>> getPinnedPasswords() async {
    try {
      return await _passwordService.getPinnedPasswords();
    } catch (e) {
      return [];
    }
  }

  // Métodos de compatibilidade com a interface
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void setSelectedCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
    _applyFilters();
  }

  void setSelectedFolder(String? folderId) {
    state = state.copyWith(selectedFolderId: folderId);
    _applyFilters();
  }

  void toggleFavoritesOnly() {
    state = state.copyWith(showFavoritesOnly: !state.showFavoritesOnly);
    _applyFilters();
  }

  void toggleWeakOnly() {
    state = state.copyWith(showWeakOnly: !state.showWeakOnly);
    _applyFilters();
  }

  void toggleExpiredOnly() {
    state = state.copyWith(showExpiredOnly: !state.showExpiredOnly);
    _applyFilters();
  }

  // NOVOS TOGGLES PARA FILTROS AVANÇADOS
  void toggleCompromisedOnly() {
    state = state.copyWith(showCompromisedOnly: !state.showCompromisedOnly);
    _applyFilters();
  }

  void toggleReusedOnly() {
    state = state.copyWith(showReusedOnly: !state.showReusedOnly);
    _applyFilters();
  }

  void toggleOldOnly() {
    state = state.copyWith(showOldOnly: !state.showOldOnly);
    _applyFilters();
  }

  void toggleWith2FAOnly() {
    state = state.copyWith(showWith2FAOnly: !state.showWith2FAOnly);
    _applyFilters();
  }

  void toggleInVaultOnly() {
    state = state.copyWith(showInVaultOnly: !state.showInVaultOnly);
    _applyFilters();
  }

  void togglePinnedOnly() {
    state = state.copyWith(showPinnedOnly: !state.showPinnedOnly);
    _applyFilters();
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedCategory: null,
      selectedFolderId: null,
      showFavoritesOnly: false,
      showWeakOnly: false,
      showExpiredOnly: false,
      showCompromisedOnly: false,
      showReusedOnly: false,
      showOldOnly: false,
      showWith2FAOnly: false,
      showInVaultOnly: false,
      showPinnedOnly: false,
    );
    _applyFilters();
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

  Future<void> togglePinned(String id) async {
    final password = state.passwords.firstWhere((p) => p.id == id);
    final updatedPassword = password.copyWith(isPinned: !password.isPinned);
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
    if (currProfile != null) {
      final workspaceId = workspace?.id ?? defaultWorkspaceId;
      notifier.setContext(currProfile.name, workspaceId);
    }
  });

  // Observa mudanças de workspace
  ref.listen<Workspace?>(currentWorkspaceProvider,
      (prevWorkspace, currWorkspace) {
    final profile = ref.read(currentProfileProvider);
    final defaultWorkspaceId = ref.read(passwordsWorkspaceProvider);
    if (profile != null) {
      final workspaceId = currWorkspace?.id ?? defaultWorkspaceId;
      notifier.setContext(profile.name, workspaceId);
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

// NOVOS PROVIDERS PARA FUNCIONALIDADES AVANÇADAS
final securityAnalysisProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(passwordProvider).securityAnalysis;
});

final securitySuggestionsProvider = Provider<List<String>>((ref) {
  return ref.watch(passwordProvider).securitySuggestions;
});

final compromisedPasswordsProvider = Provider<List<PasswordEntry>>((ref) {
  final passwords = ref.watch(passwordsProvider);
  return passwords.where((p) => p.isCompromised).toList();
});

final reusedPasswordsProvider = Provider<List<PasswordEntry>>((ref) {
  final passwords = ref.watch(passwordsProvider);
  return passwords.where((p) => p.isReused).toList();
});

final oldPasswordsProvider = Provider<List<PasswordEntry>>((ref) {
  final passwords = ref.watch(passwordsProvider);
  return passwords.where((p) => p.isOldPassword).toList();
});

final passwordsWith2FAProvider = Provider<List<PasswordEntry>>((ref) {
  final passwords = ref.watch(passwordsProvider);
  return passwords.where((p) => p.hasTwoFactor).toList();
});

final passwordsInVaultProvider = Provider<List<PasswordEntry>>((ref) {
  final passwords = ref.watch(passwordsProvider);
  return passwords.where((p) => p.isInSecureVault).toList();
});

final pinnedPasswordsProvider = Provider<List<PasswordEntry>>((ref) {
  final passwords = ref.watch(passwordsProvider);
  return passwords.where((p) => p.isPinned).toList();
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
