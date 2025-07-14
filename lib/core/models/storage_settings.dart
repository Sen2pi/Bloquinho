/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'dart:convert';

/// Enum para tipos de armazenamento disponíveis
enum CloudStorageProvider {
  local,
  googleDrive,
  oneDrive;

  /// Nome legível do provider
  String get displayName {
    switch (this) {
      case CloudStorageProvider.local:
        return 'Armazenamento Local';
      case CloudStorageProvider.googleDrive:
        return 'Google Drive';
      case CloudStorageProvider.oneDrive:
        return 'OneDrive';
    }
  }

  /// Ícone do provider
  String get iconName {
    switch (this) {
      case CloudStorageProvider.local:
        return 'storage';
      case CloudStorageProvider.googleDrive:
        return 'cloud';
      case CloudStorageProvider.oneDrive:
        return 'cloud_outlined';
    }
  }

  /// Cor associada ao provider
  String get colorHex {
    switch (this) {
      case CloudStorageProvider.local:
        return '#6B7280'; // Gray
      case CloudStorageProvider.googleDrive:
        return '#4285F4'; // Google Blue
      case CloudStorageProvider.oneDrive:
        return '#0078D4'; // Microsoft Blue
    }
  }

  /// Verificar se é armazenamento em nuvem
  bool get isCloudStorage {
    return this != CloudStorageProvider.local;
  }

  /// Verificar se requer autenticação
  bool get requiresAuth {
    return isCloudStorage;
  }
}

/// Status da conexão com cloud storage
enum CloudStorageStatus {
  disconnected,
  connecting,
  connected,
  error,
  syncing;

  /// Nome legível do status
  String get displayName {
    switch (this) {
      case CloudStorageStatus.disconnected:
        return 'Desconectado';
      case CloudStorageStatus.connecting:
        return 'Conectando...';
      case CloudStorageStatus.connected:
        return 'Conectado';
      case CloudStorageStatus.error:
        return 'Erro de Conexão';
      case CloudStorageStatus.syncing:
        return 'Sincronizando...';
    }
  }

  /// Verificar se está em estado operacional
  bool get isOperational {
    return this == CloudStorageStatus.connected ||
        this == CloudStorageStatus.syncing;
  }
}

/// Configurações de armazenamento
class StorageSettings {
  final CloudStorageProvider provider;
  final CloudStorageStatus status;
  final String? accountEmail;
  final String? accountName;
  final DateTime? lastSyncAt;
  final bool autoSyncEnabled;
  final bool syncOnStartup;
  final bool syncOnClose;
  final String? syncFolderPath;
  final Map<String, dynamic> providerConfig;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StorageSettings({
    required this.provider,
    this.status = CloudStorageStatus.disconnected,
    this.accountEmail,
    this.accountName,
    this.lastSyncAt,
    this.autoSyncEnabled = true,
    this.syncOnStartup = true,
    this.syncOnClose = true,
    this.syncFolderPath,
    this.providerConfig = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// Criar configurações padrão para armazenamento local
  factory StorageSettings.local() {
    final now = DateTime.now();
    return StorageSettings(
      provider: CloudStorageProvider.local,
      status: CloudStorageStatus.connected,
      autoSyncEnabled: false,
      syncOnStartup: false,
      syncOnClose: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Criar configurações para Google Drive
  factory StorageSettings.googleDrive({
    String? email,
    String? name,
    Map<String, dynamic>? config,
  }) {
    final now = DateTime.now();
    return StorageSettings(
      provider: CloudStorageProvider.googleDrive,
      accountEmail: email,
      accountName: name,
      providerConfig: config ?? {},
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Criar configurações para OneDrive
  factory StorageSettings.oneDrive({
    String? email,
    String? name,
    Map<String, dynamic>? config,
  }) {
    final now = DateTime.now();
    return StorageSettings(
      provider: CloudStorageProvider.oneDrive,
      accountEmail: email,
      accountName: name,
      providerConfig: config ?? {},
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Criar uma cópia com campos modificados
  StorageSettings copyWith({
    CloudStorageProvider? provider,
    CloudStorageStatus? status,
    String? accountEmail,
    String? accountName,
    DateTime? lastSyncAt,
    bool? autoSyncEnabled,
    bool? syncOnStartup,
    bool? syncOnClose,
    String? syncFolderPath,
    Map<String, dynamic>? providerConfig,
    DateTime? updatedAt,
  }) {
    return StorageSettings(
      provider: provider ?? this.provider,
      status: status ?? this.status,
      accountEmail: accountEmail ?? this.accountEmail,
      accountName: accountName ?? this.accountName,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncOnStartup: syncOnStartup ?? this.syncOnStartup,
      syncOnClose: syncOnClose ?? this.syncOnClose,
      syncFolderPath: syncFolderPath ?? this.syncFolderPath,
      providerConfig: providerConfig ?? this.providerConfig,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Converter para Map para serialização JSON
  Map<String, dynamic> toJson() {
    return {
      'provider': provider.name,
      'status': status.name,
      'accountEmail': accountEmail,
      'accountName': accountName,
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      'autoSyncEnabled': autoSyncEnabled,
      'syncOnStartup': syncOnStartup,
      'syncOnClose': syncOnClose,
      'syncFolderPath': syncFolderPath,
      'providerConfig': providerConfig,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Criar instância a partir de Map JSON
  factory StorageSettings.fromJson(Map<String, dynamic> json) {
    return StorageSettings(
      provider: CloudStorageProvider.values.firstWhere(
        (p) => p.name == json['provider'],
        orElse: () => CloudStorageProvider.local,
      ),
      status: CloudStorageStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => CloudStorageStatus.disconnected,
      ),
      accountEmail: json['accountEmail'] as String?,
      accountName: json['accountName'] as String?,
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.parse(json['lastSyncAt'] as String)
          : null,
      autoSyncEnabled: json['autoSyncEnabled'] as bool? ?? true,
      syncOnStartup: json['syncOnStartup'] as bool? ?? true,
      syncOnClose: json['syncOnClose'] as bool? ?? true,
      syncFolderPath: json['syncFolderPath'] as String?,
      providerConfig: Map<String, dynamic>.from(json['providerConfig'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converter para string JSON
  String toJsonString() => json.encode(toJson());

  /// Criar instância a partir de string JSON
  factory StorageSettings.fromJsonString(String jsonString) {
    return StorageSettings.fromJson(
        Map<String, dynamic>.from(json.decode(jsonString)));
  }

  /// Verificar se está conectado e operacional
  bool get isConnected => status.isOperational;

  /// Verificar se é armazenamento em nuvem
  bool get isCloudStorage => provider.isCloudStorage;

  /// Verificar se tem conta configurada
  bool get hasAccount => accountEmail != null || accountName != null;

  /// Obter nome de exibição da conta
  String get accountDisplayName {
    if (accountName != null && accountName!.isNotEmpty) {
      return accountName!;
    }
    if (accountEmail != null && accountEmail!.isNotEmpty) {
      return accountEmail!;
    }
    return 'Conta não configurada';
  }

  /// Verificar se está sincronizando
  bool get isSyncing => status == CloudStorageStatus.syncing;

  /// Verificar se tem erro
  bool get hasError => status == CloudStorageStatus.error;

  /// Verificar se pode sincronizar
  bool get canSync => isConnected && !isSyncing;

  /// Obter tempo desde última sincronização
  Duration? get timeSinceLastSync {
    if (lastSyncAt == null) return null;
    return DateTime.now().difference(lastSyncAt!);
  }

  /// Verificar se precisa sincronizar (mais de 1 hora)
  bool get needsSync {
    if (!isCloudStorage) return false;
    final timeSince = timeSinceLastSync;
    return timeSince == null || timeSince.inHours >= 1;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StorageSettings &&
        other.provider == provider &&
        other.accountEmail == accountEmail;
  }

  @override
  int get hashCode => Object.hash(provider, accountEmail);

  @override
  String toString() {
    return 'StorageSettings(provider: $provider, status: $status, account: $accountDisplayName)';
  }
}

/// Resultado de operação de sincronização
class SyncResult {
  final bool success;
  final String? errorMessage;
  final int filesUploaded;
  final int filesDownloaded;
  final int filesDeleted;
  final Duration duration;
  final DateTime timestamp;

  const SyncResult({
    required this.success,
    this.errorMessage,
    this.filesUploaded = 0,
    this.filesDownloaded = 0,
    this.filesDeleted = 0,
    required this.duration,
    required this.timestamp,
  });

  /// Criar resultado de sucesso
  factory SyncResult.success({
    int filesUploaded = 0,
    int filesDownloaded = 0,
    int filesDeleted = 0,
    required Duration duration,
  }) {
    return SyncResult(
      success: true,
      filesUploaded: filesUploaded,
      filesDownloaded: filesDownloaded,
      filesDeleted: filesDeleted,
      duration: duration,
      timestamp: DateTime.now(),
    );
  }

  /// Criar resultado de erro
  factory SyncResult.error(String errorMessage, Duration duration) {
    return SyncResult(
      success: false,
      errorMessage: errorMessage,
      duration: duration,
      timestamp: DateTime.now(),
    );
  }

  /// Total de arquivos processados
  int get totalFiles => filesUploaded + filesDownloaded + filesDeleted;

  /// Verificar se houve mudanças
  bool get hasChanges => totalFiles > 0;

  @override
  String toString() {
    if (success) {
      return 'SyncResult(success: $success, files: $totalFiles, duration: ${duration.inSeconds}s)';
    } else {
      return 'SyncResult(success: $success, error: $errorMessage)';
    }
  }
}

/// Configurações de validação para storage
class StorageValidator {
  /// Validar configurações de armazenamento
  static List<String> validate(StorageSettings settings) {
    final errors = <String>[];

    // Validar configurações de cloud storage
    if (settings.isCloudStorage) {
      if (settings.accountEmail == null || settings.accountEmail!.isEmpty) {
        errors.add('Email da conta é obrigatório para armazenamento em nuvem');
      }

      if (settings.accountEmail != null &&
          !_isValidEmail(settings.accountEmail!)) {
        errors.add('Email da conta inválido');
      }

      if (settings.syncFolderPath != null && settings.syncFolderPath!.isEmpty) {
        errors.add('Caminho da pasta de sincronização não pode estar vazio');
      }
    }

    return errors;
  }

  /// Validar formato de email
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

/// Extensões para facilitar uso das configurações
extension StorageSettingsExtension on StorageSettings {
  /// Verificar se pode fazer backup automático
  bool get canAutoBackup => isConnected && autoSyncEnabled;

  /// Verificar se deve sincronizar na inicialização
  bool get shouldSyncOnStartup =>
      isCloudStorage && syncOnStartup && canAutoBackup;

  /// Verificar se deve sincronizar ao fechar
  bool get shouldSyncOnClose => isCloudStorage && syncOnClose && canAutoBackup;

  /// Obter texto de status com emoji
  String get statusWithEmoji {
    switch (status) {
      case CloudStorageStatus.disconnected:
        return '🔴 ${status.displayName}';
      case CloudStorageStatus.connecting:
        return '🟡 ${status.displayName}';
      case CloudStorageStatus.connected:
        return '🟢 ${status.displayName}';
      case CloudStorageStatus.error:
        return '❌ ${status.displayName}';
      case CloudStorageStatus.syncing:
        return '🔄 ${status.displayName}';
    }
  }
}
