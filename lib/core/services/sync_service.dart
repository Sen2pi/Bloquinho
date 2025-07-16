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
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'cloud_storage_service.dart';
import 'data_directory_service.dart';
import 'platform_service.dart';
import 'oauth2_service.dart';

/// Informações sobre um arquivo para sincronização
class SyncFileInfo {
  final String relativePath;
  final String fullPath;
  final DateTime lastModified;
  final String hash;
  final int size;
  final bool isLocal;

  const SyncFileInfo({
    required this.relativePath,
    required this.fullPath,
    required this.lastModified,
    required this.hash,
    required this.size,
    required this.isLocal,
  });

  Map<String, dynamic> toJson() {
    return {
      'relativePath': relativePath,
      'fullPath': fullPath,
      'lastModified': lastModified.toIso8601String(),
      'hash': hash,
      'size': size,
      'isLocal': isLocal,
    };
  }

  factory SyncFileInfo.fromJson(Map<String, dynamic> json) {
    return SyncFileInfo(
      relativePath: json['relativePath'],
      fullPath: json['fullPath'],
      lastModified: DateTime.parse(json['lastModified']),
      hash: json['hash'],
      size: json['size'],
      isLocal: json['isLocal'],
    );
  }
}

/// Ação de sincronização
enum SyncAction {
  upload,    // Local -> Cloud
  download,  // Cloud -> Local
  conflict,  // Conflito - necessita resolução
  skip,      // Não necessita sincronização
}

/// Item de sincronização
class SyncItem {
  final SyncFileInfo? localFile;
  final SyncFileInfo? cloudFile;
  final SyncAction action;
  final String reason;

  const SyncItem({
    this.localFile,
    this.cloudFile,
    required this.action,
    required this.reason,
  });

  String get relativePath => localFile?.relativePath ?? cloudFile?.relativePath ?? '';
}

/// Resultado da sincronização
class SyncResult {
  final bool success;
  final int uploadedFiles;
  final int downloadedFiles;
  final int conflicts;
  final int skippedFiles;
  final Duration duration;
  final String? error;

  const SyncResult({
    required this.success,
    required this.uploadedFiles,
    required this.downloadedFiles,
    required this.conflicts,
    required this.skippedFiles,
    required this.duration,
    this.error,
  });

  factory SyncResult.success({
    required int uploadedFiles,
    required int downloadedFiles,
    required int conflicts,
    required int skippedFiles,
    required Duration duration,
  }) {
    return SyncResult(
      success: true,
      uploadedFiles: uploadedFiles,
      downloadedFiles: downloadedFiles,
      conflicts: conflicts,
      skippedFiles: skippedFiles,
      duration: duration,
    );
  }

  factory SyncResult.error(String error, Duration duration) {
    return SyncResult(
      success: false,
      uploadedFiles: 0,
      downloadedFiles: 0,
      conflicts: 0,
      skippedFiles: 0,
      duration: duration,
      error: error,
    );
  }
}

/// Serviço de sincronização entre local e cloud
class SyncService {
  static SyncService? _instance;
  
  SyncService._internal();
  
  static SyncService get instance {
    _instance ??= SyncService._internal();
    return _instance!;
  }

  final _platformService = PlatformService.instance;
  bool _isSyncing = false;
  
  /// Verificar se deve sincronizar (apenas em desktop/mobile)
  bool get shouldSync {
    // Na web, dados estão sempre na cloud
    if (kIsWeb) return false;
    
    // Desktop/mobile podem sincronizar se tiverem cloud storage conectado
    return _platformService.supportsLocalFileSystem;
  }

  /// Verificar se está sincronizando
  bool get isSyncing => _isSyncing;

  /// Obter diretório de dados local
  Future<Directory> _getLocalDataDirectory() async {
    final dataDir = await DataDirectoryService().getBasePath();
    final localDataDir = Directory(path.join(dataDir, 'data'));
    
    if (!await localDataDir.exists()) {
      await localDataDir.create(recursive: true);
    }
    
    return localDataDir;
  }

  /// Escanear arquivos locais
  Future<List<SyncFileInfo>> _scanLocalFiles() async {
    final localDir = await _getLocalDataDirectory();
    final files = <SyncFileInfo>[];
    
    if (!await localDir.exists()) {
      return files;
    }
    
    await for (final entity in localDir.list(recursive: true)) {
      if (entity is File) {
        final stat = await entity.stat();
        final relativePath = path.relative(entity.path, from: localDir.path);
        
        // Calcular hash do arquivo
        final bytes = await entity.readAsBytes();
        final hash = sha256.convert(bytes).toString();
        
        files.add(SyncFileInfo(
          relativePath: relativePath,
          fullPath: entity.path,
          lastModified: stat.modified,
          hash: hash,
          size: stat.size,
          isLocal: true,
        ));
      }
    }
    
    return files;
  }

  /// Escanear arquivos na cloud
  Future<List<SyncFileInfo>> _scanCloudFiles(CloudStorageService cloudService) async {
    final files = <SyncFileInfo>[];
    
    try {
      // Listar arquivos na pasta /Bloquinho/data/
      final remoteFiles = await cloudService.listFiles(
        folderPath: '/Bloquinho/data',
        recursive: true,
      );
      
      for (final remoteFile in remoteFiles) {
        files.add(SyncFileInfo(
          relativePath: remoteFile.name,
          fullPath: remoteFile.path,
          lastModified: remoteFile.lastModified,
          hash: remoteFile.hash ?? '',
          size: remoteFile.size,
          isLocal: false,
        ));
      }
    } catch (e) {
      // Erro ao listar arquivos da cloud
    }
    
    return files;
  }

  /// Comparar arquivos e determinar ações de sincronização
  List<SyncItem> _compareFiles(List<SyncFileInfo> localFiles, List<SyncFileInfo> cloudFiles) {
    final items = <SyncItem>[];
    final localMap = <String, SyncFileInfo>{};
    final cloudMap = <String, SyncFileInfo>{};
    
    // Criar mapas por caminho relativo
    for (final file in localFiles) {
      localMap[file.relativePath] = file;
    }
    
    for (final file in cloudFiles) {
      cloudMap[file.relativePath] = file;
    }
    
    // Obter todos os caminhos únicos
    final allPaths = <String>{...localMap.keys, ...cloudMap.keys};
    
    for (final relativePath in allPaths) {
      final localFile = localMap[relativePath];
      final cloudFile = cloudMap[relativePath];
      
      if (localFile != null && cloudFile != null) {
        // Arquivo existe em ambos os locais
        if (localFile.hash == cloudFile.hash) {
          // Arquivos idênticos
          items.add(SyncItem(
            localFile: localFile,
            cloudFile: cloudFile,
            action: SyncAction.skip,
            reason: 'Arquivos idênticos',
          ));
        } else if (localFile.lastModified.isAfter(cloudFile.lastModified)) {
          // Local mais recente
          items.add(SyncItem(
            localFile: localFile,
            cloudFile: cloudFile,
            action: SyncAction.upload,
            reason: 'Local mais recente',
          ));
        } else if (cloudFile.lastModified.isAfter(localFile.lastModified)) {
          // Cloud mais recente
          items.add(SyncItem(
            localFile: localFile,
            cloudFile: cloudFile,
            action: SyncAction.download,
            reason: 'Cloud mais recente',
          ));
        } else {
          // Conflito - mesma data mas hashes diferentes
          items.add(SyncItem(
            localFile: localFile,
            cloudFile: cloudFile,
            action: SyncAction.conflict,
            reason: 'Conflito - arquivos diferentes com mesma data',
          ));
        }
      } else if (localFile != null) {
        // Arquivo existe apenas localmente
        items.add(SyncItem(
          localFile: localFile,
          action: SyncAction.upload,
          reason: 'Arquivo novo local',
        ));
      } else if (cloudFile != null) {
        // Arquivo existe apenas na cloud
        items.add(SyncItem(
          cloudFile: cloudFile,
          action: SyncAction.download,
          reason: 'Arquivo novo na cloud',
        ));
      }
    }
    
    return items;
  }

  /// Executar sincronização
  Future<SyncResult> performSync({
    CloudStorageService? cloudService,
    bool resolveConflicts = false,
  }) async {
    if (!shouldSync) {
      return SyncResult.error('Sincronização não disponível nesta plataforma', Duration.zero);
    }
    
    if (_isSyncing) {
      return SyncResult.error('Sincronização já em andamento', Duration.zero);
    }
    
    final startTime = DateTime.now();
    _isSyncing = true;
    
    try {
      // Obter serviço de cloud storage
      cloudService ??= await _getCloudStorageService();
      if (cloudService == null) {
        return SyncResult.error('Serviço de cloud storage não disponível', Duration.zero);
      }
      
      // Verificar se pasta data existe na cloud
      await _ensureCloudDataFolder(cloudService);
      
      // Escanear arquivos
      final localFiles = await _scanLocalFiles();
      final cloudFiles = await _scanCloudFiles(cloudService);
      
      // Comparar e determinar ações
      final syncItems = _compareFiles(localFiles, cloudFiles);
      
      // Executar sincronização
      int uploadedFiles = 0;
      int downloadedFiles = 0;
      int conflicts = 0;
      int skippedFiles = 0;
      
      for (final item in syncItems) {
        try {
          switch (item.action) {
            case SyncAction.upload:
              if (item.localFile != null) {
                await _uploadFile(cloudService, item.localFile!);
                uploadedFiles++;
              }
              break;
              
            case SyncAction.download:
              if (item.cloudFile != null) {
                await _downloadFile(cloudService, item.cloudFile!);
                downloadedFiles++;
              }
              break;
              
            case SyncAction.conflict:
              if (resolveConflicts && item.localFile != null) {
                // Resolver conflito favorecendo versão local
                await _uploadFile(cloudService, item.localFile!);
                uploadedFiles++;
              } else {
                conflicts++;
              }
              break;
              
            case SyncAction.skip:
              skippedFiles++;
              break;
          }
        } catch (e) {
          // Erro ao sincronizar arquivo individual
        }
      }
      
      final duration = DateTime.now().difference(startTime);
      
      return SyncResult.success(
        uploadedFiles: uploadedFiles,
        downloadedFiles: downloadedFiles,
        conflicts: conflicts,
        skippedFiles: skippedFiles,
        duration: duration,
      );
      
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      return SyncResult.error(e.toString(), duration);
    } finally {
      _isSyncing = false;
    }
  }

  /// Obter serviço de cloud storage ativo
  Future<CloudStorageService?> _getCloudStorageService() async {
    // Implementar lógica para obter serviço ativo
    // Por enquanto, retornar null
    return null;
  }

  /// Garantir que pasta data existe na cloud
  Future<void> _ensureCloudDataFolder(CloudStorageService cloudService) async {
    final dataFolderPath = '/Bloquinho/data';
    
    if (!await cloudService.fileExists(dataFolderPath)) {
      await cloudService.createFolder(dataFolderPath);
    }
  }

  /// Fazer upload de arquivo
  Future<void> _uploadFile(CloudStorageService cloudService, SyncFileInfo fileInfo) async {
    final remotePath = '/Bloquinho/data/${fileInfo.relativePath}';
    
    await cloudService.uploadFile(
      localPath: fileInfo.fullPath,
      remotePath: remotePath,
      overwrite: true,
    );
  }

  /// Fazer download de arquivo
  Future<void> _downloadFile(CloudStorageService cloudService, SyncFileInfo fileInfo) async {
    final localDir = await _getLocalDataDirectory();
    final localPath = path.join(localDir.path, fileInfo.relativePath);
    
    // Criar diretório pai se necessário
    final parentDir = Directory(path.dirname(localPath));
    if (!await parentDir.exists()) {
      await parentDir.create(recursive: true);
    }
    
    await cloudService.downloadFile(
      remotePath: fileInfo.fullPath,
      localPath: localPath,
      overwrite: true,
    );
  }

  /// Verificar se há arquivos para sincronizar
  Future<bool> hasChangesToSync() async {
    if (!shouldSync) return false;
    
    try {
      final cloudService = await _getCloudStorageService();
      if (cloudService == null) return false;
      
      final localFiles = await _scanLocalFiles();
      final cloudFiles = await _scanCloudFiles(cloudService);
      final syncItems = _compareFiles(localFiles, cloudFiles);
      
      return syncItems.any((item) => item.action != SyncAction.skip);
    } catch (e) {
      return false;
    }
  }

  /// Obter estatísticas de sincronização
  Future<Map<String, int>> getSyncStats() async {
    if (!shouldSync) {
      return {
        'localFiles': 0,
        'cloudFiles': 0,
        'toUpload': 0,
        'toDownload': 0,
        'conflicts': 0,
      };
    }
    
    try {
      final cloudService = await _getCloudStorageService();
      if (cloudService == null) {
        return {
          'localFiles': 0,
          'cloudFiles': 0,
          'toUpload': 0,
          'toDownload': 0,
          'conflicts': 0,
        };
      }
      
      final localFiles = await _scanLocalFiles();
      final cloudFiles = await _scanCloudFiles(cloudService);
      final syncItems = _compareFiles(localFiles, cloudFiles);
      
      return {
        'localFiles': localFiles.length,
        'cloudFiles': cloudFiles.length,
        'toUpload': syncItems.where((item) => item.action == SyncAction.upload).length,
        'toDownload': syncItems.where((item) => item.action == SyncAction.download).length,
        'conflicts': syncItems.where((item) => item.action == SyncAction.conflict).length,
      };
    } catch (e) {
      return {
        'localFiles': 0,
        'cloudFiles': 0,
        'toUpload': 0,
        'toDownload': 0,
        'conflicts': 0,
      };
    }
  }
}

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