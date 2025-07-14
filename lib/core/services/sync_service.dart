import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloquinho/core/models/storage_settings.dart';
import 'package:bloquinho/core/services/cloud_storage_service.dart';
import 'package:bloquinho/core/services/data_directory_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Serviço para sincronização de arquivos com logs de mudanças
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  // Streams para comunicação
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  final _syncProgressController = StreamController<SyncProgress>.broadcast();

  // Configurações
  late Box _changeLogBox;
  late Box _settingsBox;
  late String _localStoragePath;

  // Estados
  bool _isInitialized = false;
  bool _isSyncing = false;
  CloudStorageService? _cloudService;
  Timer? _autoSyncTimer;

  // Streams públicos
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  Stream<SyncProgress> get syncProgressStream => _syncProgressController.stream;

  // Getters públicos
  bool get isSyncing => _isSyncing;
  bool get isInitialized => _isInitialized;

  /// Inicializar serviço de sincronização
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Inicializar Hive
      await Hive.initFlutter();

      final dataDir = await DataDirectoryService().initialize();
      _localStoragePath = await DataDirectoryService().getBasePath();

      // Abrir boxes
      _changeLogBox = await Hive.openBox('change_log', path: _localStoragePath);
      _settingsBox =
          await Hive.openBox('sync_settings', path: _localStoragePath);

      // Criar pasta se não existir
      final localDir = Directory(_localStoragePath);
      if (!await localDir.exists()) {
        await localDir.create(recursive: true);
      }

      // Configurar sincronização automática
      _setupAutoSync();

      _isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  /// Configurar serviço de nuvem
  void configureCloudService(CloudStorageService cloudService) {
    _cloudService = cloudService;

    // Reinicializar timer se necessário
    if (_autoSyncTimer != null) {
      _autoSyncTimer!.cancel();
      _setupAutoSync();
    }
  }

  /// Configurar sincronização automática
  void _setupAutoSync() {
    final autoSyncInterval =
        _settingsBox.get('auto_sync_interval', defaultValue: 30);
    final autoSyncEnabled =
        _settingsBox.get('auto_sync_enabled', defaultValue: true);

    if (autoSyncEnabled && _cloudService != null) {
      _autoSyncTimer = Timer.periodic(
        Duration(minutes: autoSyncInterval),
        (timer) => syncAll(),
      );
    }
  }

  /// Registrar mudança em arquivo
  Future<void> logChange({
    required String filePath,
    required ChangeType changeType,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) await initialize();

    final changeLog = ChangeLog(
      id: const Uuid().v4(),
      filePath: filePath,
      changeType: changeType,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );

    await _changeLogBox.put(changeLog.id, changeLog.toJson());


    // Sincronizar se configurado
    if (_shouldAutoSync()) {
      _scheduleSync();
    }
  }

  /// Sincronizar todos os arquivos
  Future<SyncResult> syncAll() async {
    if (!_isInitialized) await initialize();
    if (_isSyncing)
      return SyncResult(
          success: false, message: 'Sincronização já em andamento');
    if (_cloudService == null)
      return SyncResult(
          success: false, message: 'Serviço de nuvem não configurado');

    _isSyncing = true;
    final stopwatch = Stopwatch()..start();

    try {
      _syncStatusController.add(SyncStatus.syncing);

      // Obter todas as mudanças não sincronizadas
      final pendingChanges = await _getPendingChanges();

      int filesUploaded = 0;
      int filesDownloaded = 0;
      int filesDeleted = 0;

      // Processar cada mudança
      for (int i = 0; i < pendingChanges.length; i++) {
        final change = pendingChanges[i];

        // Emitir progresso
        _syncProgressController.add(SyncProgress(
          currentFile: i + 1,
          totalFiles: pendingChanges.length,
          currentFileName: path.basename(change.filePath),
          operation: _getOperationFromChangeType(change.changeType),
          timestamp: DateTime.now(),
        ));

        switch (change.changeType) {
          case ChangeType.created:
          case ChangeType.modified:
            final result = await _uploadFile(change.filePath);
            if (result.success) {
              filesUploaded++;
              await _markChangeSynced(change.id);
            }
            break;

          case ChangeType.deleted:
            final result = await _deleteFile(change.filePath);
            if (result.success) {
              filesDeleted++;
              await _markChangeSynced(change.id);
            }
            break;
        }
      }

      // Baixar arquivos da nuvem que não existem localmente
      final downloadResult = await _downloadMissingFiles();
      filesDownloaded = downloadResult.filesDownloaded;

      stopwatch.stop();

      _syncStatusController.add(SyncStatus.idle);

      return SyncResult(
        success: true,
        filesUploaded: filesUploaded,
        filesDownloaded: filesDownloaded,
        filesDeleted: filesDeleted,
        duration: stopwatch.elapsed,
        message: 'Sincronização concluída com sucesso',
      );
    } catch (e) {
      stopwatch.stop();
      _syncStatusController.add(SyncStatus.error);
      return SyncResult(
        success: false,
        message: 'Erro na sincronização: $e',
        duration: stopwatch.elapsed,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Upload de arquivo individual
  Future<FileOperationResult> _uploadFile(String filePath) async {
    try {
      final localFile = File(path.join(_localStoragePath, filePath));

      if (!await localFile.exists()) {
        return FileOperationResult(
          success: false,
          message: 'Arquivo local não encontrado: $filePath',
        );
      }

      final remotePath = '/bloquinho/$filePath';

      final result = await _cloudService!.uploadFile(
        localPath: localFile.path,
        remotePath: remotePath,
        overwrite: true,
      );

      return FileOperationResult(
        success: result.success,
        message:
            result.success ? 'Upload realizado com sucesso' : 'Erro no upload',
        remoteUrl: result.remoteUrl,
      );
    } catch (e) {
      return FileOperationResult(
        success: false,
        message: 'Erro no upload: $e',
      );
    }
  }

  /// Download de arquivo individual
  Future<FileOperationResult> _downloadFile(String filePath) async {
    try {
      final localFile = File(path.join(_localStoragePath, filePath));
      final remotePath = '/bloquinho/$filePath';

      final result = await _cloudService!.downloadFile(
        remotePath: remotePath,
        localPath: localFile.path,
        overwrite: true,
      );

      return FileOperationResult(
        success: result.success,
        message: result.success
            ? 'Download realizado com sucesso'
            : 'Erro no download',
        localPath: result.localPath,
      );
    } catch (e) {
      return FileOperationResult(
        success: false,
        message: 'Erro no download: $e',
      );
    }
  }

  /// Deletar arquivo da nuvem
  Future<FileOperationResult> _deleteFile(String filePath) async {
    try {
      final remotePath = '/bloquinho/$filePath';

      final success = await _cloudService!.deleteFile(remotePath);

      return FileOperationResult(
        success: success,
        message: success
            ? 'Arquivo deletado com sucesso'
            : 'Erro ao deletar arquivo',
      );
    } catch (e) {
      return FileOperationResult(
        success: false,
        message: 'Erro ao deletar: $e',
      );
    }
  }

  /// Baixar arquivos que não existem localmente
  Future<DownloadResult> _downloadMissingFiles() async {
    try {
      final remoteFiles =
          await _cloudService!.listFiles(folderPath: '/bloquinho');
      int filesDownloaded = 0;

      for (final remoteFile in remoteFiles) {
        if (remoteFile.isFolder) continue;

        final relativePath = remoteFile.path.replaceFirst('/bloquinho/', '');
        final localFile = File(path.join(_localStoragePath, relativePath));

        // Verificar se arquivo local existe e está atualizado
        if (!await localFile.exists() ||
            (await localFile.lastModified()).isBefore(remoteFile.modifiedAt)) {
          final result = await _downloadFile(relativePath);
          if (result.success) {
            filesDownloaded++;
          }
        }
      }

      return DownloadResult(
        success: true,
        filesDownloaded: filesDownloaded,
        message: 'Download concluído',
      );
    } catch (e) {
      return DownloadResult(
        success: false,
        message: 'Erro no download: $e',
      );
    }
  }

  /// Obter mudanças pendentes
  Future<List<ChangeLog>> _getPendingChanges() async {
    final changes = <ChangeLog>[];

    for (final key in _changeLogBox.keys) {
      final changeData = _changeLogBox.get(key);
      if (changeData != null) {
        final change =
            ChangeLog.fromJson(Map<String, dynamic>.from(changeData));
        if (!change.synced) {
          changes.add(change);
        }
      }
    }

    // Ordenar por timestamp
    changes.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return changes;
  }

  /// Marcar mudança como sincronizada
  Future<void> _markChangeSynced(String changeId) async {
    final changeData = _changeLogBox.get(changeId);
    if (changeData != null) {
      final change = ChangeLog.fromJson(Map<String, dynamic>.from(changeData));
      final syncedChange = change.copyWith(synced: true);
      await _changeLogBox.put(changeId, syncedChange.toJson());
    }
  }

  /// Verificar se deve sincronizar automaticamente
  bool _shouldAutoSync() {
    return _settingsBox.get('auto_sync_enabled', defaultValue: true) &&
        _cloudService != null;
  }

  /// Agendar sincronização
  void _scheduleSync() {
    Timer(const Duration(seconds: 5), () {
      if (!_isSyncing) {
        syncAll();
      }
    });
  }

  /// Converter tipo de mudança para operação
  SyncOperation _getOperationFromChangeType(ChangeType changeType) {
    switch (changeType) {
      case ChangeType.created:
      case ChangeType.modified:
        return SyncOperation.uploading;
      case ChangeType.deleted:
        return SyncOperation.deleting;
    }
  }

  /// Obter estatísticas de sincronização
  Future<SyncStats> getStats() async {
    final pendingChanges = await _getPendingChanges();
    final totalChanges = _changeLogBox.length;

    return SyncStats(
      pendingChanges: pendingChanges.length,
      totalChanges: totalChanges,
      lastSync: _settingsBox.get('last_sync_time'),
      isCloudConnected: _cloudService?.isConnected ?? false,
    );
  }

  /// Limpar logs antigos
  Future<void> clearOldLogs({int daysToKeep = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    final keysToDelete = <String>[];

    for (final key in _changeLogBox.keys) {
      final changeData = _changeLogBox.get(key);
      if (changeData != null) {
        final change =
            ChangeLog.fromJson(Map<String, dynamic>.from(changeData));
        if (change.synced && change.timestamp.isBefore(cutoffDate)) {
          keysToDelete.add(key);
        }
      }
    }

    for (final key in keysToDelete) {
      await _changeLogBox.delete(key);
    }

  }

  /// Limpar recursos
  void dispose() {
    _autoSyncTimer?.cancel();
    _syncStatusController.close();
    _syncProgressController.close();
  }
}

/// Tipos de mudança
enum ChangeType {
  created,
  modified,
  deleted,
}

/// Status da sincronização
enum SyncStatus {
  idle,
  syncing,
  error,
}

/// Log de mudanças
class ChangeLog {
  final String id;
  final String filePath;
  final ChangeType changeType;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final bool synced;

  ChangeLog({
    required this.id,
    required this.filePath,
    required this.changeType,
    required this.timestamp,
    required this.metadata,
    this.synced = false,
  });

  ChangeLog copyWith({
    String? id,
    String? filePath,
    ChangeType? changeType,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    bool? synced,
  }) {
    return ChangeLog(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      changeType: changeType ?? this.changeType,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      synced: synced ?? this.synced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'changeType': changeType.name,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'synced': synced,
    };
  }

  factory ChangeLog.fromJson(Map<String, dynamic> json) {
    return ChangeLog(
      id: json['id'],
      filePath: json['filePath'],
      changeType: ChangeType.values.firstWhere(
        (e) => e.name == json['changeType'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      metadata: Map<String, dynamic>.from(json['metadata']),
      synced: json['synced'] ?? false,
    );
  }
}

/// Resultado de operação de arquivo
class FileOperationResult {
  final bool success;
  final String message;
  final String? localPath;
  final String? remoteUrl;

  FileOperationResult({
    required this.success,
    required this.message,
    this.localPath,
    this.remoteUrl,
  });
}

/// Resultado de download
class DownloadResult {
  final bool success;
  final String message;
  final int filesDownloaded;

  DownloadResult({
    required this.success,
    required this.message,
    this.filesDownloaded = 0,
  });
}

/// Resultado de sincronização
class SyncResult {
  final bool success;
  final String message;
  final int filesUploaded;
  final int filesDownloaded;
  final int filesDeleted;
  final Duration duration;

  SyncResult({
    required this.success,
    required this.message,
    this.filesUploaded = 0,
    this.filesDownloaded = 0,
    this.filesDeleted = 0,
    this.duration = Duration.zero,
  });
}

/// Estatísticas de sincronização
class SyncStats {
  final int pendingChanges;
  final int totalChanges;
  final DateTime? lastSync;
  final bool isCloudConnected;

  SyncStats({
    required this.pendingChanges,
    required this.totalChanges,
    this.lastSync,
    required this.isCloudConnected,
  });
}