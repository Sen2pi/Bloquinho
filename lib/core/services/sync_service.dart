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
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'cloud_storage_service.dart';
import 'data_directory_service.dart';
import 'platform_service.dart';

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

/// Resultado da sincronização
class SyncResult {
  final bool success;
  final String message;
  final int filesUploaded;
  final int filesDownloaded;
  final int filesDeleted;
  final int conflicts;
  final int skippedFiles;
  final Duration duration;
  final String? error;

  const SyncResult({
    required this.success,
    required this.message,
    this.filesUploaded = 0,
    this.filesDownloaded = 0,
    this.filesDeleted = 0,
    this.conflicts = 0,
    this.skippedFiles = 0,
    this.duration = Duration.zero,
    this.error,
  });

  factory SyncResult.successResult({
    required int filesUploaded,
    required int filesDownloaded,
    required int filesDeleted,
    int conflicts = 0,
    int skippedFiles = 0,
    required Duration duration,
  }) {
    return SyncResult(
      success: true,
      message: 'Sincronização concluída com sucesso',
      filesUploaded: filesUploaded,
      filesDownloaded: filesDownloaded,
      filesDeleted: filesDeleted,
      conflicts: conflicts,
      skippedFiles: skippedFiles,
      duration: duration,
    );
  }

  factory SyncResult.error(String error, Duration duration) {
    return SyncResult(
      success: false,
      message: 'Erro na sincronização: $error',
      duration: duration,
      error: error,
    );
  }
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

/// Serviço de sincronização entre local e cloud
class SyncService {
  static SyncService? _instance;
  
  SyncService._internal();
  
  static SyncService get instance {
    _instance ??= SyncService._internal();
    return _instance!;
  }

  final _platformService = PlatformService.instance;
  
  // Controllers para status
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  final _syncProgressController = StreamController<SyncProgress>.broadcast();
  
  // Estado
  bool _isSyncing = false;
  CloudStorageService? _cloudService;
  String? _localStoragePath;
  Timer? _autoSyncTimer;
  
  // Hive boxes
  Box<Map<String, dynamic>>? _changeLogBox;
  Box<dynamic>? _settingsBox;

  /// Streams
  Stream<SyncStatus> get statusStream => _syncStatusController.stream;
  Stream<SyncProgress> get progressStream => _syncProgressController.stream;
  
  /// Verificar se deve sincronizar (apenas em desktop/mobile)
  bool get shouldSync {
    // Na web, dados estão sempre na cloud
    if (kIsWeb) return false;
    
    // Desktop/mobile podem sincronizar se tiverem cloud storage conectado
    return _platformService.supportsLocalFileSystem;
  }

  /// Verificar se está sincronizando
  bool get isSyncing => _isSyncing;

  /// Inicializar serviço
  Future<void> initialize(CloudStorageService? cloudService) async {
    if (!shouldSync) return;
    
    _cloudService = cloudService;
    
    try {
      // Inicializar armazenamento local
      final dataDir = await DataDirectoryService().getBasePath();
      _localStoragePath = path.join(dataDir, 'data');
      
      // Garantir que diretório existe
      final localDir = Directory(_localStoragePath!);
      if (!await localDir.exists()) {
        await localDir.create(recursive: true);
      }
      
      // Inicializar Hive boxes
      _changeLogBox = await Hive.openBox<Map<String, dynamic>>(
        'sync_changelog',
        path: dataDir,
      );
      _settingsBox = await Hive.openBox('sync_settings', path: dataDir);
      
      // Configurar sincronização automática
      if (_shouldAutoSync()) {
        _startAutoSync();
      }
      
    } catch (e) {
      // Erro na inicialização
    }
  }

  /// Obter diretório de dados local
  Future<Directory> _getLocalDataDirectory() async {
    if (_localStoragePath == null) {
      final dataDir = await DataDirectoryService().getBasePath();
      _localStoragePath = path.join(dataDir, 'data');
    }
    
    final localDataDir = Directory(_localStoragePath!);
    
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
        // Para arquivos remotos, usar fileId como hash ou gerar um hash baseado no path e data de modificação
        final hashValue = remoteFile.fileId ?? '${remoteFile.path}_${remoteFile.modifiedAt.millisecondsSinceEpoch}';
        
        files.add(SyncFileInfo(
          relativePath: remoteFile.name,
          fullPath: remoteFile.path,
          lastModified: remoteFile.modifiedAt,
          hash: hashValue,
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

  /// Registrar mudança em arquivo
  Future<void> recordFileChange(String filePath, ChangeType changeType) async {
    if (!shouldSync || _changeLogBox == null) return;
    
    try {
      final change = ChangeLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filePath: filePath,
        changeType: changeType,
        timestamp: DateTime.now(),
        metadata: {},
      );
      
      await _changeLogBox!.put(change.id, change.toJson());
      
      // Agendar sincronização automática
      if (_shouldAutoSync()) {
        _scheduleSync();
      }
    } catch (e) {
      // Erro ao registrar mudança
    }
  }

  /// Executar sincronização completa
  Future<SyncResult> syncAll({bool resolveConflicts = false}) async {
    if (!shouldSync) {
      return SyncResult.error('Sincronização não disponível nesta plataforma', Duration.zero);
    }
    
    if (_isSyncing) {
      return SyncResult.error('Sincronização já em andamento', Duration.zero);
    }
    
    if (_cloudService == null) {
      return SyncResult.error('Serviço de cloud storage não configurado', Duration.zero);
    }
    
    final startTime = DateTime.now();
    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);
    
    try {
      // Verificar se pasta data existe na cloud
      await _ensureCloudDataFolder(_cloudService!);
      
      // Escanear arquivos
      final localFiles = await _scanLocalFiles();
      final cloudFiles = await _scanCloudFiles(_cloudService!);
      
      // Comparar e determinar ações
      final syncItems = _compareFiles(localFiles, cloudFiles);
      
      // Executar sincronização
      int filesUploaded = 0;
      int filesDownloaded = 0;
      int filesDeleted = 0;
      int conflicts = 0;
      int skippedFiles = 0;
      
      for (int i = 0; i < syncItems.length; i++) {
        final item = syncItems[i];
        
        // Emitir progresso
        _syncProgressController.add(SyncProgress(
          currentFile: i + 1,
          totalFiles: syncItems.length,
          currentFileName: path.basename(item.relativePath),
          operation: _getOperationFromAction(item.action),
          timestamp: DateTime.now(),
        ));
        
        try {
          switch (item.action) {
            case SyncAction.upload:
              if (item.localFile != null) {
                await _uploadFile(item.localFile!);
                filesUploaded++;
              }
              break;
              
            case SyncAction.download:
              if (item.cloudFile != null) {
                await _downloadFile(item.cloudFile!);
                filesDownloaded++;
              }
              break;
              
            case SyncAction.conflict:
              if (resolveConflicts && item.localFile != null) {
                // Resolver conflito favorecendo versão local
                await _uploadFile(item.localFile!);
                filesUploaded++;
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
      
      // Marcar mudanças como sincronizadas
      await _markAllChangesSynced();
      
      // Atualizar última sincronização
      await _settingsBox?.put('last_sync_time', DateTime.now().toIso8601String());
      
      final duration = DateTime.now().difference(startTime);
      _syncStatusController.add(SyncStatus.idle);
      
      return SyncResult.successResult(
        filesUploaded: filesUploaded,
        filesDownloaded: filesDownloaded,
        filesDeleted: filesDeleted,
        conflicts: conflicts,
        skippedFiles: skippedFiles,
        duration: duration,
      );
      
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _syncStatusController.add(SyncStatus.error);
      return SyncResult.error(e.toString(), duration);
    } finally {
      _isSyncing = false;
    }
  }

  /// Garantir que pasta data existe na cloud
  Future<void> _ensureCloudDataFolder(CloudStorageService cloudService) async {
    final dataFolderPath = '/Bloquinho/data';
    
    if (!await cloudService.fileExists(dataFolderPath)) {
      await cloudService.createFolder(dataFolderPath);
    }
  }

  /// Fazer upload de arquivo
  Future<void> _uploadFile(SyncFileInfo fileInfo) async {
    final remotePath = '/Bloquinho/data/${fileInfo.relativePath}';
    
    await _cloudService!.uploadFile(
      localPath: fileInfo.fullPath,
      remotePath: remotePath,
      overwrite: true,
    );
  }

  /// Fazer download de arquivo
  Future<void> _downloadFile(SyncFileInfo fileInfo) async {
    final localDir = await _getLocalDataDirectory();
    final localPath = path.join(localDir.path, fileInfo.relativePath);
    
    // Criar diretório pai se necessário
    final parentDir = Directory(path.dirname(localPath));
    if (!await parentDir.exists()) {
      await parentDir.create(recursive: true);
    }
    
    await _cloudService!.downloadFile(
      remotePath: fileInfo.fullPath,
      localPath: localPath,
      overwrite: true,
    );
  }

  /// Marcar todas as mudanças como sincronizadas
  Future<void> _markAllChangesSynced() async {
    if (_changeLogBox == null) return;
    
    try {
      for (final key in _changeLogBox!.keys) {
        final changeData = _changeLogBox!.get(key);
        if (changeData != null) {
          final change = ChangeLog.fromJson(Map<String, dynamic>.from(changeData));
          if (!change.synced) {
            final syncedChange = change.copyWith(synced: true);
            await _changeLogBox!.put(key, syncedChange.toJson());
          }
        }
      }
    } catch (e) {
      // Erro ao marcar mudanças como sincronizadas
    }
  }

  /// Verificar se deve sincronizar automaticamente
  bool _shouldAutoSync() {
    return _settingsBox?.get('auto_sync_enabled', defaultValue: true) ?? true;
  }

  /// Iniciar sincronização automática
  void _startAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (!_isSyncing && _cloudService != null) {
        syncAll();
      }
    });
  }

  /// Agendar sincronização
  void _scheduleSync() {
    Timer(const Duration(seconds: 10), () {
      if (!_isSyncing) {
        syncAll();
      }
    });
  }

  /// Converter ação para operação
  SyncOperation _getOperationFromAction(SyncAction action) {
    switch (action) {
      case SyncAction.upload:
        return SyncOperation.uploading;
      case SyncAction.download:
        return SyncOperation.downloading;
      case SyncAction.conflict:
        return SyncOperation.uploading; // Assumindo resolução por upload
      case SyncAction.skip:
        return SyncOperation.uploading; // Placeholder
    }
  }

  /// Verificar se há arquivos para sincronizar
  Future<bool> hasChangesToSync() async {
    if (!shouldSync) return false;
    
    try {
      if (_cloudService == null) return false;
      
      final localFiles = await _scanLocalFiles();
      final cloudFiles = await _scanCloudFiles(_cloudService!);
      final syncItems = _compareFiles(localFiles, cloudFiles);
      
      return syncItems.any((item) => item.action != SyncAction.skip);
    } catch (e) {
      return false;
    }
  }

  /// Obter estatísticas de sincronização
  Future<SyncStats> getStats() async {
    if (!shouldSync) {
      return SyncStats(
        pendingChanges: 0,
        totalChanges: 0,
        isCloudConnected: false,
      );
    }
    
    try {
      final pendingChanges = await _getPendingChanges();
      final totalChanges = _changeLogBox?.length ?? 0;
      final lastSyncString = _settingsBox?.get('last_sync_time') as String?;
      final lastSync = lastSyncString != null ? DateTime.parse(lastSyncString) : null;
      
      return SyncStats(
        pendingChanges: pendingChanges.length,
        totalChanges: totalChanges,
        lastSync: lastSync,
        isCloudConnected: _cloudService?.isConnected ?? false,
      );
    } catch (e) {
      return SyncStats(
        pendingChanges: 0,
        totalChanges: 0,
        isCloudConnected: false,
      );
    }
  }

  /// Obter mudanças pendentes
  Future<List<ChangeLog>> _getPendingChanges() async {
    if (_changeLogBox == null) return [];
    
    final changes = <ChangeLog>[];
    
    try {
      for (final key in _changeLogBox!.keys) {
        final changeData = _changeLogBox!.get(key);
        if (changeData != null) {
          final change = ChangeLog.fromJson(Map<String, dynamic>.from(changeData));
          if (!change.synced) {
            changes.add(change);
          }
        }
      }
      
      // Ordenar por timestamp
      changes.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      // Erro ao obter mudanças pendentes
    }
    
    return changes;
  }

  /// Limpar logs antigos
  Future<void> clearOldLogs({int daysToKeep = 30}) async {
    if (_changeLogBox == null) return;
    
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final keysToDelete = <String>[];

      for (final key in _changeLogBox!.keys) {
        final changeData = _changeLogBox!.get(key);
        if (changeData != null) {
          final change = ChangeLog.fromJson(Map<String, dynamic>.from(changeData));
          if (change.synced && change.timestamp.isBefore(cutoffDate)) {
            keysToDelete.add(key);
          }
        }
      }

      for (final key in keysToDelete) {
        await _changeLogBox!.delete(key);
      }
    } catch (e) {
      // Erro ao limpar logs antigos
    }
  }

  /// Limpar recursos
  void dispose() {
    _autoSyncTimer?.cancel();
    _syncStatusController.close();
    _syncProgressController.close();
  }
}