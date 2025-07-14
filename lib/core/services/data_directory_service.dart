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
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:hive/hive.dart';

/// Serviço centralizado para gerenciar todos os diretórios de dados do aplicativo
/// Todos os arquivos são salvos dentro da pasta 'data' para organização
class DataDirectoryService {
  static const String _dataFolder = 'data';
  static const String _backupsFolder = 'backups';
  static const String _cacheFolder = 'cache';
  static const String _avatarsCacheFolder = 'avatars_cache';
  static const String _tempFolder = 'temp';
  static const String _logsFolder = 'logs';

  /// Instância singleton
  static final DataDirectoryService _instance =
      DataDirectoryService._internal();
  factory DataDirectoryService() => _instance;
  DataDirectoryService._internal();

  String? _basePath;
  bool _isInitialized = false;

  /// Inicializar o serviço
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (kIsWeb) {
        // No web, usar armazenamento limitado
        _basePath = null;
        _isInitialized = true;
        return;
      }

      // Em plataformas nativas, usar diretório de documentos
      final appDir = await getApplicationDocumentsDirectory();
      _basePath = path.join(appDir.path, _dataFolder);

      // Criar pasta base se não existir
      final baseDir = Directory(_basePath!);
      if (!await baseDir.exists()) {
        await baseDir.create(recursive: true);
      }

      // Criar subpastas padrão
      _createDefaultSubdirectories();

      _isInitialized = true;
    } catch (e) {
      throw Exception('Erro ao inicializar diretório de dados: $e');
    }
  }

  /// Criar subpastas padrão
  void _createDefaultSubdirectories() {
    if (kIsWeb || _basePath == null) return;

    final subdirs = [
      _backupsFolder,
      _cacheFolder,
      _avatarsCacheFolder,
      _tempFolder,
      _logsFolder,
    ];

    for (final subdir in subdirs) {
      final dir = Directory(path.join(_basePath!, subdir));
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
    }
  }

  /// Obter caminho base dos dados
  Future<String> getBasePath() async {
    await _ensureInitialized();
    return _basePath!;
  }

  /// Obter diretório de backups
  Future<Directory> getBackupsDirectory() async {
    await _ensureInitialized();
    if (kIsWeb) throw Exception('Backups não suportados no web');

    final backupDir = Directory(path.join(_basePath!, _backupsFolder));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// Obter diretório de cache
  Future<Directory> getCacheDirectory() async {
    await _ensureInitialized();
    if (kIsWeb) throw Exception('Cache não suportado no web');

    final cacheDir = Directory(path.join(_basePath!, _cacheFolder));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// Obter diretório de cache de avatares
  Future<Directory> getAvatarsCacheDirectory() async {
    await _ensureInitialized();
    if (kIsWeb) throw Exception('Cache de avatares não suportado no web');

    final avatarsDir = Directory(path.join(_basePath!, _avatarsCacheFolder));
    if (!await avatarsDir.exists()) {
      await avatarsDir.create(recursive: true);
    }
    return avatarsDir;
  }

  /// Obter diretório temporário
  Future<Directory> getTempDirectory() async {
    await _ensureInitialized();
    if (kIsWeb) throw Exception('Diretório temporário não suportado no web');

    final tempDir = Directory(path.join(_basePath!, _tempFolder));
    if (!await tempDir.exists()) {
      await tempDir.create(recursive: true);
    }
    return tempDir;
  }

  /// Obter diretório de logs
  Future<Directory> getLogsDirectory() async {
    await _ensureInitialized();
    if (kIsWeb) throw Exception('Logs não suportados no web');

    final logsDir = Directory(path.join(_basePath!, _logsFolder));
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }
    return logsDir;
  }

  /// Obter caminho para arquivo de backup
  Future<String> getBackupFilePath(String fileName) async {
    final backupDir = await getBackupsDirectory();
    return path.join(backupDir.path, fileName);
  }

  /// Obter caminho para arquivo de cache
  Future<String> getCacheFilePath(String fileName) async {
    final cacheDir = await getCacheDirectory();
    return path.join(cacheDir.path, fileName);
  }

  /// Obter caminho para arquivo de avatar
  Future<String> getAvatarFilePath(String fileName) async {
    final avatarsDir = await getAvatarsCacheDirectory();
    return path.join(avatarsDir.path, fileName);
  }

  /// Obter caminho para arquivo temporário
  Future<String> getTempFilePath(String fileName) async {
    final tempDir = await getTempDirectory();
    return path.join(tempDir.path, fileName);
  }

  /// Obter caminho para arquivo de log
  Future<String> getLogFilePath(String fileName) async {
    final logsDir = await getLogsDirectory();
    return path.join(logsDir.path, fileName);
  }

  /// Limpar diretório temporário
  Future<void> clearTempDirectory() async {
    if (kIsWeb) return;

    try {
      final tempDir = await getTempDirectory();
      final files = await tempDir.list().toList();

      for (final file in files) {
        if (file is File) {
          await file.delete();
        }
      }
    } catch (e) {
    }
  }

  /// Limpar cache antigo
  Future<void> clearOldCache({int maxDays = 7}) async {
    if (kIsWeb) return;

    try {
      final cacheDir = await getCacheDirectory();
      final avatarsDir = await getAvatarsCacheDirectory();
      final now = DateTime.now();

      // Limpar cache geral
      await _clearOldFiles(cacheDir, maxDays);

      // Limpar cache de avatares
      await _clearOldFiles(avatarsDir, maxDays);
    } catch (e) {
    }
  }

  /// Limpar arquivos antigos de um diretório
  Future<void> _clearOldFiles(Directory dir, int maxDays) async {
    if (!await dir.exists()) return;

    final files = await dir.list().toList();
    final cutoffDate = DateTime.now().subtract(Duration(days: maxDays));

    for (final file in files) {
      if (file is File) {
        try {
          final stat = await file.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await file.delete();
          }
        } catch (e) {
          // Ignorar erros ao deletar arquivos
        }
      }
    }
  }

  /// Obter estatísticas de uso do disco
  Future<Map<String, dynamic>> getDiskUsage() async {
    if (kIsWeb) return {};

    try {
      final baseDir = Directory(_basePath!);
      if (!await baseDir.exists()) return {};

      final stats = <String, dynamic>{};
      final subdirs = [
        _backupsFolder,
        _cacheFolder,
        _avatarsCacheFolder,
        _tempFolder,
        _logsFolder,
      ];

      for (final subdir in subdirs) {
        final dir = Directory(path.join(_basePath!, subdir));
        if (await dir.exists()) {
          final size = await _calculateDirectorySize(dir);
          stats[subdir] = size;
        }
      }

      return stats;
    } catch (e) {
      return {};
    }
  }

  /// Calcular tamanho de um diretório
  Future<int> _calculateDirectorySize(Directory dir) async {
    int totalSize = 0;

    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    } catch (e) {
      // Ignorar erros ao calcular tamanho
    }

    return totalSize;
  }

  /// Verificar se o serviço está inicializado
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      throw Exception('DataDirectoryService não foi inicializado');
    }
  }

  /// Obter informações do diretório de dados
  Future<Map<String, dynamic>> getDirectoryInfo() async {
    await _ensureInitialized();

    return {
      'basePath': _basePath,
      'isWeb': kIsWeb,
      'isInitialized': _isInitialized,
      'diskUsage': await getDiskUsage(),
    };
  }
}

Future<String> getComponentPath(
    String profile, String workspace, String component) async {
  final base = await DataDirectoryService().getBasePath();
  return path.join(
    base,
    'profile',
    profile,
    'workspaces',
    workspace,
    component,
  );
}