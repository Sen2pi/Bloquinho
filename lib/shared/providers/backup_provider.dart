import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../core/services/backup_service.dart';
import '../../core/services/document_service.dart';
import 'document_provider.dart';

// Estado dos backups
class BackupState {
  final List<BackupMetadata> localBackups;
  final bool isLoading;
  final String? error;
  final BackupData? lastCreatedBackup;
  final bool isCreatingBackup;
  final bool isImportingBackup;
  final bool isExportingBackup;

  const BackupState({
    this.localBackups = const [],
    this.isLoading = false,
    this.error,
    this.lastCreatedBackup,
    this.isCreatingBackup = false,
    this.isImportingBackup = false,
    this.isExportingBackup = false,
  });

  BackupState copyWith({
    List<BackupMetadata>? localBackups,
    bool? isLoading,
    String? error,
    BackupData? lastCreatedBackup,
    bool? isCreatingBackup,
    bool? isImportingBackup,
    bool? isExportingBackup,
    bool clearError = false,
    bool clearLastCreatedBackup = false,
  }) {
    return BackupState(
      localBackups: localBackups ?? this.localBackups,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastCreatedBackup: clearLastCreatedBackup
          ? null
          : (lastCreatedBackup ?? this.lastCreatedBackup),
      isCreatingBackup: isCreatingBackup ?? this.isCreatingBackup,
      isImportingBackup: isImportingBackup ?? this.isImportingBackup,
      isExportingBackup: isExportingBackup ?? this.isExportingBackup,
    );
  }
}

// Provider do serviço de backup
final backupServiceProvider = Provider<BackupService>((ref) {
  final documentService = ref.watch(documentServiceProvider);
  return BackupService(documentService);
});

// Provider do estado dos backups
class BackupNotifier extends StateNotifier<BackupState> {
  final BackupService _backupService;
  final Ref _ref;

  BackupNotifier(this._backupService, this._ref) : super(const BackupState()) {
    loadLocalBackups();
  }

  /// Carregar lista de backups locais
  Future<void> loadLocalBackups() async {
    if (state.isLoading) return;

    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final backups = await _backupService.getLocalBackups();
      state = state.copyWith(
        localBackups: backups,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar backups: $e',
      );
    }
  }

  /// Criar novo backup
  Future<BackupData?> createBackup({
    Map<String, dynamic>? settings,
    String? customName,
    bool saveToFile = true,
  }) async {
    if (state.isCreatingBackup) return null;

    try {
      state = state.copyWith(isCreatingBackup: true, clearError: true);

      final backup = await _backupService.createBackup(
        additionalSettings: settings,
      );

      if (saveToFile) {
        await _backupService.saveBackupToFile(backup, customName: customName);
        await loadLocalBackups(); // Recarregar lista
      }

      state = state.copyWith(
        isCreatingBackup: false,
        lastCreatedBackup: backup,
      );

      return backup;
    } catch (e) {
      state = state.copyWith(
        isCreatingBackup: false,
        error: 'Erro ao criar backup: $e',
      );
      return null;
    }
  }

  /// Exportar backup para compartilhamento
  Future<String?> exportBackup({String? customName}) async {
    if (state.isExportingBackup) return null;

    try {
      state = state.copyWith(isExportingBackup: true, clearError: true);

      final filePath =
          await _backupService.exportBackup(customName: customName);

      state = state.copyWith(isExportingBackup: false);
      return filePath;
    } catch (e) {
      state = state.copyWith(
        isExportingBackup: false,
        error: 'Erro ao exportar backup: $e',
      );
      return null;
    }
  }

  /// Importar backup de arquivo
  Future<BackupData?> importBackupFromFile(String filePath) async {
    if (state.isImportingBackup) return null;

    try {
      state = state.copyWith(isImportingBackup: true, clearError: true);

      final backup = await _backupService.importBackupFromFile(filePath);
      final isValid = await _backupService.validateBackup(backup);

      if (!isValid) {
        throw Exception('Arquivo de backup inválido ou corrompido');
      }

      state = state.copyWith(
        isImportingBackup: false,
        lastCreatedBackup: backup,
      );

      return backup;
    } catch (e) {
      state = state.copyWith(
        isImportingBackup: false,
        error: 'Erro ao importar backup: $e',
      );
      return null;
    }
  }

  /// Importar backup usando file picker
  Future<BackupData?> importBackupWithPicker() async {
    if (state.isImportingBackup) return null;

    try {
      state = state.copyWith(isImportingBackup: true, clearError: true);

      final backup = await _backupService.importBackupWithPicker();

      if (backup == null) {
        state = state.copyWith(isImportingBackup: false);
        return null;
      }

      final isValid = await _backupService.validateBackup(backup);

      if (!isValid) {
        throw Exception('Arquivo de backup inválido ou corrompido');
      }

      state = state.copyWith(
        isImportingBackup: false,
        lastCreatedBackup: backup,
      );

      return backup;
    } catch (e) {
      state = state.copyWith(
        isImportingBackup: false,
        error: 'Erro ao importar backup: $e',
      );
      return null;
    }
  }

  /// Restaurar dados do backup
  Future<bool> restoreFromBackup(
    BackupData backup, {
    bool clearExistingData = false,
    bool restoreSettings = true,
  }) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      await _backupService.restoreFromBackup(
        backup,
        clearExistingData: clearExistingData,
        restoreSettings: restoreSettings,
      );

      // Recarregar dados nos providers relacionados
      _ref.invalidate(documentProvider);
      _ref.invalidate(workspaceProvider);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao restaurar backup: $e',
      );
      return false;
    }
  }

  /// Deletar backup local
  Future<void> deleteLocalBackup(String fileName) async {
    try {
      await _backupService.deleteLocalBackup(fileName);
      await loadLocalBackups(); // Recarregar lista
    } catch (e) {
      state = state.copyWith(error: 'Erro ao deletar backup: $e');
    }
  }

  /// Obter estatísticas do backup
  Future<Map<String, dynamic>?> getBackupStats(BackupData backup) async {
    try {
      return await _backupService.getBackupStats(backup);
    } catch (e) {
      state = state.copyWith(error: 'Erro ao obter estatísticas: $e');
      return null;
    }
  }

  /// Validar backup
  Future<bool> validateBackup(BackupData backup) async {
    try {
      return await _backupService.validateBackup(backup);
    } catch (e) {
      return false;
    }
  }

  /// Criar backup automático
  Future<void> createScheduledBackup() async {
    try {
      await _backupService.createScheduledBackup();
      await loadLocalBackups(); // Recarregar lista
    } catch (e) {
      debugPrint('Erro no backup automático: $e');
    }
  }

  /// Limpar erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Limpar último backup criado
  void clearLastCreatedBackup() {
    state = state.copyWith(clearLastCreatedBackup: true);
  }
}

final backupProvider =
    StateNotifierProvider<BackupNotifier, BackupState>((ref) {
  final backupService = ref.watch(backupServiceProvider);
  return BackupNotifier(backupService, ref);
});

// Providers derivados para casos específicos
final localBackupsProvider = Provider<List<BackupMetadata>>((ref) {
  return ref.watch(backupProvider).localBackups;
});

final isCreatingBackupProvider = Provider<bool>((ref) {
  return ref.watch(backupProvider).isCreatingBackup;
});

final isImportingBackupProvider = Provider<bool>((ref) {
  return ref.watch(backupProvider).isImportingBackup;
});

final isExportingBackupProvider = Provider<bool>((ref) {
  return ref.watch(backupProvider).isExportingBackup;
});

final backupErrorProvider = Provider<String?>((ref) {
  return ref.watch(backupProvider).error;
});

final lastCreatedBackupProvider = Provider<BackupData?>((ref) {
  return ref.watch(backupProvider).lastCreatedBackup;
});

// Provider para verificar se há backups disponíveis
final hasLocalBackupsProvider = Provider<bool>((ref) {
  return ref.watch(backupProvider).localBackups.isNotEmpty;
});

// Provider para contagem de backups
final backupCountProvider = Provider<int>((ref) {
  return ref.watch(backupProvider).localBackups.length;
});

// Provider para último backup
final latestBackupProvider = Provider<BackupMetadata?>((ref) {
  final backups = ref.watch(backupProvider).localBackups;
  return backups.isNotEmpty ? backups.first : null;
});

// Provider para verificar se alguma operação está em andamento
final isBackupBusyProvider = Provider<bool>((ref) {
  final state = ref.watch(backupProvider);
  return state.isLoading ||
      state.isCreatingBackup ||
      state.isImportingBackup ||
      state.isExportingBackup;
});
