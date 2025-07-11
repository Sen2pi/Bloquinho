import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../core/services/backup_service.dart';
import '../../features/agenda/providers/agenda_provider.dart';
import '../../features/passwords/providers/password_provider.dart';
import '../../features/documentos/providers/documentos_provider.dart';
import '../../features/agenda/models/agenda_item.dart';
import '../../features/passwords/models/password_entry.dart';
import '../../features/documentos/models/documento.dart';

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

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});

class BackupNotifier extends StateNotifier<BackupState> {
  final BackupService _backupService;
  final Ref _ref;

  BackupNotifier(this._backupService, this._ref) : super(const BackupState()) {
    loadLocalBackups();
  }

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

  Future<BackupData?> createBackup({
    Map<String, dynamic>? settings,
    String? customName,
    bool saveToFile = true,
  }) async {
    if (state.isCreatingBackup) return null;
    try {
      state = state.copyWith(isCreatingBackup: true, clearError: true);
      // Coletar dados dos providers
      final agendaItems = _ref.read(agendaProvider).items;
      final passwords = _ref.read(passwordProvider).passwords;
      final documentosState = _ref.read(documentosProvider);

      // Converter DocumentosState para lista de Documento (para compatibilidade)
      final documentos = <Documento>[];
      // TODO: Implementar conversão quando necessário

      final backup = await _backupService.createBackup(
        agendaItems: agendaItems,
        passwords: passwords,
        documentos: documentos,
        additionalSettings: settings,
      );
      if (saveToFile) {
        await _backupService.saveBackupToFile(backup, customName: customName);
        await loadLocalBackups();
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

  Future<BackupData?> importBackupFromFile(String filePath) async {
    if (state.isImportingBackup) return null;
    try {
      state = state.copyWith(isImportingBackup: true, clearError: true);
      final backup = await _backupService.importBackupFromFile(filePath);
      final isValid = await _backupService.validateBackup(backup);
      if (!isValid) {
        throw Exception('Arquivo de backup inválido ou corrompido');
      }
      // Restaurar dados nos providers
      _ref.read(agendaProvider.notifier).replaceAll(backup.agendaItems);
      _ref.read(passwordProvider.notifier).replaceAll(backup.passwords);
      // TODO: Implementar restauração de documentos quando necessário
      // _ref.read(documentosProvider.notifier).replaceAll(backup.documentos);
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
}

final backupProvider =
    StateNotifierProvider<BackupNotifier, BackupState>((ref) {
  final backupService = ref.watch(backupServiceProvider);
  return BackupNotifier(backupService, ref);
});
