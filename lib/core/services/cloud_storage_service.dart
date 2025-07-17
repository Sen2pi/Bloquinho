/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'dart:io';
import 'package:bloquinho/core/models/storage_settings.dart';
import 'package:bloquinho/core/models/auth_result.dart';

/// Interface abstrata para serviços de armazenamento em nuvem
abstract class CloudStorageService {
  /// Provider associado ao serviço
  CloudStorageProvider get provider;

  /// Verificar se está conectado
  bool get isConnected;

  /// Verificar se está sincronizando
  bool get isSyncing;

  /// Configurações atuais do storage
  StorageSettings get settings;

  /// Autenticar com o provider
  Future<AuthResult> authenticate({
    Map<String, dynamic>? config,
  });

  /// Desconectar da conta
  Future<void> disconnect();

  /// Sincronizar dados bidirecionalmente
  Future<SyncResult> sync({
    bool forceSync = false,
    List<String>? specificFiles,
  });

  /// Fazer upload de arquivo
  Future<UploadResult> uploadFile({
    required String localPath,
    required String remotePath,
    bool overwrite = true,
  });

  /// Fazer download de arquivo
  Future<DownloadResult> downloadFile({
    required String remotePath,
    required String localPath,
    bool overwrite = true,
  });

  /// Listar arquivos remotos
  Future<List<RemoteFile>> listFiles({
    String? folderPath,
    bool recursive = false,
  });

  /// Deletar arquivo remoto
  Future<bool> deleteFile(String remotePath);

  /// Criar pasta remota
  Future<bool> createFolder(String folderPath);

  /// Verificar se arquivo existe remotamente
  Future<bool> fileExists(String remotePath);

  /// Obter informações do arquivo remoto
  Future<RemoteFile?> getFileInfo(String remotePath);

  /// Obter espaço disponível
  Future<StorageSpace> getStorageSpace();

  /// Verificar conectividade
  Future<bool> checkConnectivity();

  /// Validar configurações
  List<String> validateSettings(StorageSettings settings);

  /// Obter configurações padrão
  StorageSettings getDefaultSettings();

  /// Atualizar configurações
  void updateSettings(StorageSettings settings);

  /// Callback para mudanças de status
  Stream<CloudStorageStatus> get statusStream;

  /// Callback para progresso de sincronização
  Stream<SyncProgress> get syncProgressStream;
}

/// Resultado de upload
class UploadResult {
  final bool success;
  final String? errorMessage;
  final String? remoteUrl;
  final int? fileSize;
  final String? fileId;
  final DateTime timestamp;

  const UploadResult({
    required this.success,
    this.errorMessage,
    this.remoteUrl,
    this.fileSize,
    this.fileId,
    required this.timestamp,
  });

  /// Criar resultado de sucesso
  factory UploadResult.success({
    String? remoteUrl,
    int? fileSize,
    String? fileId,
  }) {
    return UploadResult(
      success: true,
      remoteUrl: remoteUrl,
      fileSize: fileSize,
      fileId: fileId,
      timestamp: DateTime.now(),
    );
  }

  /// Criar resultado de erro
  factory UploadResult.error(String errorMessage) {
    return UploadResult(
      success: false,
      errorMessage: errorMessage,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    if (success) {
      return 'UploadResult(success: true, size: ${fileSize}B)';
    } else {
      return 'UploadResult(success: false, error: $errorMessage)';
    }
  }
}

/// Resultado de download
class DownloadResult {
  final bool success;
  final String? errorMessage;
  final String? localPath;
  final int? fileSize;
  final DateTime timestamp;

  const DownloadResult({
    required this.success,
    this.errorMessage,
    this.localPath,
    this.fileSize,
    required this.timestamp,
  });

  /// Criar resultado de sucesso
  factory DownloadResult.success({
    required String localPath,
    int? fileSize,
  }) {
    return DownloadResult(
      success: true,
      localPath: localPath,
      fileSize: fileSize,
      timestamp: DateTime.now(),
    );
  }

  /// Criar resultado de erro
  factory DownloadResult.error(String errorMessage) {
    return DownloadResult(
      success: false,
      errorMessage: errorMessage,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    if (success) {
      return 'DownloadResult(success: true, path: $localPath)';
    } else {
      return 'DownloadResult(success: false, error: $errorMessage)';
    }
  }
}

/// Informações de arquivo remoto
class RemoteFile {
  final String path;
  final String name;
  final int size;
  final DateTime modifiedAt;
  final DateTime? createdAt;
  final String? mimeType;
  final String? fileId;
  final bool isFolder;
  final Map<String, dynamic>? metadata;

  const RemoteFile({
    required this.path,
    required this.name,
    required this.size,
    required this.modifiedAt,
    this.createdAt,
    this.mimeType,
    this.fileId,
    this.isFolder = false,
    this.metadata,
  });

  /// Verificar se é arquivo
  bool get isFile => !isFolder;

  /// Obter extensão do arquivo
  String get extension {
    if (isFolder) return '';
    final index = name.lastIndexOf('.');
    return index != -1 ? name.substring(index + 1).toLowerCase() : '';
  }

  /// Obter nome sem extensão
  String get nameWithoutExtension {
    if (isFolder) return name;
    final index = name.lastIndexOf('.');
    return index != -1 ? name.substring(0, index) : name;
  }

  /// Obter tamanho formatado
  String get formattedSize {
    if (size == 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double bytes = size.toDouble();
    while (bytes >= 1024 && i < suffixes.length - 1) {
      bytes /= 1024;
      i++;
    }
    return '${bytes.toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  String toString() {
    return 'RemoteFile(name: $name, size: $formattedSize, modified: $modifiedAt)';
  }
}

/// Informações de espaço de armazenamento
class StorageSpace {
  final int totalBytes;
  final int usedBytes;
  final int availableBytes;
  final DateTime timestamp;

  const StorageSpace({
    required this.totalBytes,
    required this.usedBytes,
    required this.availableBytes,
    required this.timestamp,
  });

  /// Porcentagem de uso
  double get usagePercentage {
    if (totalBytes == 0) return 0.0;
    final percentage = (usedBytes / totalBytes) * 100;
    if (percentage.isNaN || percentage.isInfinite) return 0.0;
    return percentage.clamp(0.0, 100.0);
  }

  /// Verificar se está quase cheio (>90%)
  bool get isAlmostFull => usagePercentage > 90;

  /// Verificar se está cheio (>95%)
  bool get isFull => usagePercentage > 95;

  /// Obter espaço total formatado
  String get formattedTotal => _formatBytes(totalBytes);

  /// Obter espaço usado formatado
  String get formattedUsed => _formatBytes(usedBytes);

  /// Obter espaço disponível formatado
  String get formattedAvailable => _formatBytes(availableBytes);

  /// Formatar bytes para string legível
  String _formatBytes(int bytes) {
    if (bytes == 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  String toString() {
    return 'StorageSpace(used: $formattedUsed, total: $formattedTotal, ${usagePercentage.toStringAsFixed(1)}%)';
  }
}

/// Progresso de sincronização
class SyncProgress {
  final int currentFile;
  final int totalFiles;
  final String currentFileName;
  final SyncOperation operation;
  final int bytesTransferred;
  final int totalBytes;
  final DateTime timestamp;

  const SyncProgress({
    required this.currentFile,
    required this.totalFiles,
    required this.currentFileName,
    required this.operation,
    this.bytesTransferred = 0,
    this.totalBytes = 0,
    required this.timestamp,
  });

  /// Porcentagem de arquivos processados
  double get fileProgress =>
      totalFiles > 0 ? (currentFile / totalFiles) * 100 : 0;

  /// Porcentagem de bytes transferidos
  double get byteProgress =>
      totalBytes > 0 ? (bytesTransferred / totalBytes) * 100 : 0;

  /// Verificar se está completo
  bool get isComplete => currentFile >= totalFiles;

  /// Obter progresso geral
  double get overallProgress => (fileProgress + byteProgress) / 2;

  @override
  String toString() {
    return 'SyncProgress(${currentFile}/${totalFiles} files, ${operation.name}: $currentFileName)';
  }
}

/// Tipos de operação de sincronização
enum SyncOperation {
  scanning,
  uploading,
  downloading,
  deleting,
  comparing;

  /// Nome legível da operação
  String get displayName {
    switch (this) {
      case SyncOperation.scanning:
        return 'Verificando arquivos';
      case SyncOperation.uploading:
        return 'Enviando';
      case SyncOperation.downloading:
        return 'Baixando';
      case SyncOperation.deleting:
        return 'Deletando';
      case SyncOperation.comparing:
        return 'Comparando';
    }
  }
}

/// Exceção personalizada para erros de cloud storage
class CloudStorageException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final CloudStorageProvider provider;

  const CloudStorageException({
    required this.message,
    this.code,
    this.originalError,
    required this.provider,
  });

  @override
  String toString() {
    return 'CloudStorageException(${provider.name}): $message${code != null ? ' (code: $code)' : ''}';
  }
}

/// Utilitários para cloud storage
class CloudStorageUtils {
  /// Verificar se caminho é válido
  static bool isValidPath(String path) {
    if (path.isEmpty) return false;

    // Verificar caracteres inválidos
    final invalidChars = ['<', '>', ':', '"', '|', '?', '*'];
    for (final char in invalidChars) {
      if (path.contains(char)) return false;
    }

    return true;
  }

  /// Normalizar caminho para cloud storage
  static String normalizePath(String path) {
    return path.replaceAll(r'\', '/').replaceAll('//', '/');
  }

  /// Obter diretório pai
  static String getParentDirectory(String path) {
    final normalized = normalizePath(path);
    final lastSlash = normalized.lastIndexOf('/');
    if (lastSlash == -1) return '';
    return normalized.substring(0, lastSlash);
  }

  /// Obter nome do arquivo
  static String getFileName(String path) {
    final normalized = normalizePath(path);
    final lastSlash = normalized.lastIndexOf('/');
    return lastSlash == -1 ? normalized : normalized.substring(lastSlash + 1);
  }

  /// Verificar se arquivo é imagem
  static bool isImageFile(String path) {
    final extension = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  /// Verificar se arquivo é documento
  static bool isDocumentFile(String path) {
    final extension = path.split('.').last.toLowerCase();
    return ['pdf', 'doc', 'docx', 'txt', 'rtf', 'odt'].contains(extension);
  }

  /// Gerar hash de arquivo
  static Future<String> generateFileHash(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Arquivo não encontrado: $filePath');
    }

    final bytes = await file.readAsBytes();
    // Simulação de hash (em produção usar crypto)
    return bytes.length.toString() +
        file.lastModifiedSync().millisecondsSinceEpoch.toString();
  }

  /// Verificar se arquivos são iguais
  static Future<bool> areFilesEqual(
      String localPath, RemoteFile remoteFile) async {
    final localFile = File(localPath);
    if (!await localFile.exists()) return false;

    final localStat = await localFile.stat();
    final localModified = localStat.modified;
    final localSize = localStat.size;

    // Comparar tamanho e data de modificação
    return localSize == remoteFile.size &&
        localModified.isAtSameMomentAs(remoteFile.modifiedAt);
  }

  /// Criar backup de arquivo antes de sobrescrever
  static Future<bool> createBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final backupPath =
          '$filePath.backup.${DateTime.now().millisecondsSinceEpoch}';
      await file.copy(backupPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Limpar backups antigos
  static Future<void> cleanupBackups(String directory) async {
    try {
      final dir = Directory(directory);
      if (!await dir.exists()) return;

      final backupFiles = await dir
          .list()
          .where((entity) => entity is File && entity.path.contains('.backup.'))
          .cast<File>()
          .toList();

      // Manter apenas os 5 backups mais recentes
      if (backupFiles.length > 5) {
        backupFiles.sort(
            (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
        for (var i = 5; i < backupFiles.length; i++) {
          await backupFiles[i].delete();
        }
      }
    } catch (e) {
      // Ignorar erros de limpeza
    }
  }
}
