import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../models/password_entry.dart';
import '../services/password_service.dart';

// Estado do password manager
class PasswordState extends Equatable {
  final List<PasswordEntry> passwords;
  final List<PasswordFolder> folders;
  final List<PasswordEntry> filteredPasswords;
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

  PasswordNotifier(this._passwordService) : super(const PasswordState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final passwords = await _passwordService.getAllPasswords();
      final folders = await _passwordService.getAllFolders();
      final stats = await _passwordService.getPasswordStats();

      state = state.copyWith(
        passwords: passwords,
        folders: folders,
        stats: stats,
        isLoading: false,
      );

      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar dados: $e',
      );
    }
  }

  void _applyFilters() {
    List<PasswordEntry> filtered = state.passwords;

    // Aplicar filtro de busca
    if (state.searchQuery.isNotEmpty) {
      filtered = filtered.where((entry) {
        final query = state.searchQuery.toLowerCase();
        return entry.title.toLowerCase().contains(query) ||
            entry.username.toLowerCase().contains(query) ||
            entry.website?.toLowerCase().contains(query) == true ||
            entry.notes?.toLowerCase().contains(query) == true ||
            entry.category?.toLowerCase().contains(query) == true ||
            entry.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    // Aplicar filtro de categoria
    if (state.selectedCategory != null) {
      filtered = filtered
          .where((entry) => entry.category == state.selectedCategory)
          .toList();
    }

    // Aplicar filtro de pasta
    if (state.selectedFolderId != null) {
      filtered = filtered
          .where((entry) => entry.folderId == state.selectedFolderId)
          .toList();
    }

    // Aplicar filtro de favoritos
    if (state.showFavoritesOnly) {
      filtered = filtered.where((entry) => entry.isFavorite).toList();
    }

    // Aplicar filtro de senhas fracas
    if (state.showWeakOnly) {
      filtered = filtered
          .where((entry) =>
              entry.strength == PasswordStrength.veryWeak ||
              entry.strength == PasswordStrength.weak)
          .toList();
    }

    // Aplicar filtro de senhas expiradas
    if (state.showExpiredOnly) {
      filtered = filtered.where((entry) => entry.isExpired).toList();
    }

    state = state.copyWith(filteredPasswords: filtered);
  }

  // Ações do usuário
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

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedCategory: null,
      selectedFolderId: null,
      showFavoritesOnly: false,
      showWeakOnly: false,
      showExpiredOnly: false,
    );
    _applyFilters();
  }

  // CRUD Operations
  Future<void> createPassword(PasswordEntry entry) async {
    try {
      state = state.copyWith(isCreating: true, error: null);

      final id = await _passwordService.createPassword(entry);
      final newEntry = entry.copyWith(id: id);

      final updatedPasswords = [newEntry, ...state.passwords];
      state = state.copyWith(
        passwords: updatedPasswords,
        isCreating: false,
      );

      _applyFilters();
      await _updateStats();
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Erro ao criar senha: $e',
      );
    }
  }

  Future<void> updatePassword(PasswordEntry entry) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      await _passwordService.updatePassword(entry);

      final updatedPasswords =
          state.passwords.map((p) => p.id == entry.id ? entry : p).toList();

      state = state.copyWith(
        passwords: updatedPasswords,
        isUpdating: false,
      );

      _applyFilters();
      await _updateStats();
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Erro ao atualizar senha: $e',
      );
    }
  }

  Future<void> deletePassword(String id) async {
    try {
      state = state.copyWith(isDeleting: true, error: null);

      await _passwordService.deletePassword(id);

      final updatedPasswords =
          state.passwords.where((p) => p.id != id).toList();
      state = state.copyWith(
        passwords: updatedPasswords,
        isDeleting: false,
      );

      _applyFilters();
      await _updateStats();
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Erro ao deletar senha: $e',
      );
    }
  }

  Future<void> deleteMultiplePasswords(List<String> ids) async {
    try {
      state = state.copyWith(isDeleting: true, error: null);

      await _passwordService.deleteMultiplePasswords(ids);

      final updatedPasswords =
          state.passwords.where((p) => !ids.contains(p.id)).toList();
      state = state.copyWith(
        passwords: updatedPasswords,
        isDeleting: false,
      );

      _applyFilters();
      await _updateStats();
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Erro ao deletar senhas: $e',
      );
    }
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

  // Gestão de pastas
  Future<void> createFolder(PasswordFolder folder) async {
    try {
      state = state.copyWith(isCreating: true, error: null);

      final id = await _passwordService.createFolder(folder);
      final newFolder = folder.copyWith(id: id);

      final updatedFolders = [newFolder, ...state.folders];
      state = state.copyWith(
        folders: updatedFolders,
        isCreating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Erro ao criar pasta: $e',
      );
    }
  }

  Future<void> updateFolder(PasswordFolder folder) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      await _passwordService.updateFolder(folder);

      final updatedFolders =
          state.folders.map((f) => f.id == folder.id ? folder : f).toList();

      state = state.copyWith(
        folders: updatedFolders,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Erro ao atualizar pasta: $e',
      );
    }
  }

  Future<void> deleteFolder(String folderId) async {
    try {
      state = state.copyWith(isDeleting: true, error: null);

      await _passwordService.deleteFolder(folderId);

      final updatedFolders =
          state.folders.where((f) => f.id != folderId).toList();
      state = state.copyWith(
        folders: updatedFolders,
        isDeleting: false,
      );

      // Recarregar senhas para atualizar folderId
      await _loadInitialData();
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Erro ao deletar pasta: $e',
      );
    }
  }

  // Utilitários
  Future<void> _updateStats() async {
    try {
      final stats = await _passwordService.getPasswordStats();
      state = state.copyWith(stats: stats);
    } catch (e) {
      // Ignorar erros de estatísticas
    }
  }

  Future<void> refresh() async {
    await _loadInitialData();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void replaceAll(List<PasswordEntry> items) {
    state = state.copyWith(passwords: items);
    _applyFilters();
  }

  // Geração de senhas
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

  // Exportação e importação
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
}

// Providers
final passwordServiceProvider = Provider<PasswordService>((ref) {
  return PasswordService();
});

final passwordProvider =
    StateNotifierProvider<PasswordNotifier, PasswordState>((ref) {
  final service = ref.watch(passwordServiceProvider);
  return PasswordNotifier(service);
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
