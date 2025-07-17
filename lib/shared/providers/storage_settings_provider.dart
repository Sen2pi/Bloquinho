/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bloquinho/core/models/storage_settings.dart';
import 'package:bloquinho/core/services/cloud_storage_service.dart';
import 'package:bloquinho/core/services/google_drive_service.dart';
import 'package:bloquinho/core/services/onedrive_service.dart';
import 'package:bloquinho/core/services/oauth2_service.dart' as oauth2;
import 'package:bloquinho/core/services/platform_service.dart';
import 'package:bloquinho/core/services/web_auth_service.dart';
import 'package:bloquinho/core/models/auth_result.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bloquinho/core/services/data_directory_service.dart';
import 'package:flutter/foundation.dart';

/// Provider singleton para as configurações de armazenamento
final storageSettingsProvider =
    StateNotifierProvider<StorageSettingsNotifier, StorageSettings>((ref) {
  return StorageSettingsNotifier();
});

/// Notifier para gerenciar o estado das configurações de armazenamento
class StorageSettingsNotifier extends StateNotifier<StorageSettings> {
  static const String _boxName = 'storage_settings';
  static const String _settingsKey = 'current_settings';

  Box<String>? _box;
  CloudStorageService? _currentService;
  bool _initialized = false;

  StorageSettingsNotifier() : super(_getInitialSettings()) {
    // Não inicializar automaticamente para evitar loops infinitos
  }
  
  /// Obter configurações iniciais baseadas na plataforma
  static StorageSettings _getInitialSettings() {
    final platformService = PlatformService.instance;
    
    if (kIsWeb && platformService.requiresCloudAuth) {
      // Na web, sempre usar cloud storage
      return StorageSettings.googleDrive(); // Padrão para Google Drive
    } else {
      // Outras plataformas usam local por padrão
      return StorageSettings.local();
    }
  }

  /// Garantir que o storage está inicializado
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _initializeSettings();
    _initialized = true;
  }

  /// Inicializar configurações carregando do Hive
  Future<void> _initializeSettings() async {
    try {
      final platformService = PlatformService.instance;
      
      // Na web, verificar se existe autenticação salva
      if (kIsWeb && platformService.requiresCloudAuth) {
        await _initializeWebStorage();
      } else {
        // Outras plataformas usam Hive
        final dataDir = await DataDirectoryService().initialize();
        final dbPath = await DataDirectoryService().getBasePath();
        _box = await Hive.openBox<String>(_boxName, path: dbPath);
        await _loadSettings();
      }
    } catch (e) {
      // Erro ao inicializar configurações de storage: $e
      // Se falhar a inicialização, manter configurações padrão
    }
  }
  
  /// Inicializar storage na web
  Future<void> _initializeWebStorage() async {
    final webAuthService = WebAuthService.instance;
    await webAuthService.initialize();
    
    if (webAuthService.isAuthenticated && webAuthService.storageSettings != null) {
      state = webAuthService.storageSettings!;
      _initializeService(state.provider);
    }
  }

  /// Carregar configurações do Hive
  Future<void> _loadSettings() async {
    try {
      final settingsJson = _box?.get(_settingsKey);
      if (settingsJson != null) {
        final settings = StorageSettings.fromJsonString(settingsJson);
        state = settings;
        _initializeService(settings.provider);
      }
    } catch (e) {
      // Erro ao carregar configurações: $e
    }
  }

  /// Salvar configurações no Hive
  Future<void> _saveSettings() async {
    try {
      await _box?.put(_settingsKey, state.toJsonString());
    } catch (e) {
      // Erro ao salvar configurações: $e
    }
  }

  /// Inicializar serviço baseado no provider
  void _initializeService(CloudStorageProvider provider) {
    switch (provider) {
      case CloudStorageProvider.googleDrive:
        _currentService = GoogleDriveService();
        break;
      case CloudStorageProvider.oneDrive:
        _currentService = OneDriveService();
        break;
      case CloudStorageProvider.local:
        _currentService = null;
        break;
    }

    if (_currentService != null) {
      _currentService!.updateSettings(state);
    }
  }

  /// Obter serviço atual
  CloudStorageService? get currentService => _currentService;

  /// Verificar se está conectado
  bool get isConnected => state.isConnected;

  /// Verificar se está sincronizando
  bool get isSyncing => state.isSyncing;

  /// Verificar se é armazenamento local
  bool get isLocalStorage => state.provider == CloudStorageProvider.local;

  /// Verificar se é armazenamento em nuvem
  bool get isCloudStorage => state.isCloudStorage;

  /// Alterar provider de armazenamento
  Future<void> changeProvider(CloudStorageProvider newProvider) async {
    final platformService = PlatformService.instance;
    
    // Na web, não permitir armazenamento local
    if (kIsWeb && platformService.requiresCloudAuth && newProvider == CloudStorageProvider.local) {
      throw Exception('Armazenamento local não é permitido na plataforma web');
    }
    
    // Desconectar do serviço anterior
    if (_currentService != null) {
      await _currentService!.disconnect();
    }

    // Atualizar configurações
    state = state.copyWith(
      provider: newProvider,
      status: newProvider == CloudStorageProvider.local
          ? CloudStorageStatus.connected
          : CloudStorageStatus.disconnected,
    );

    // Inicializar novo serviço
    _initializeService(newProvider);

    // Salvar configurações
    await _saveSettings();
  }

  /// Conectar ao serviço de cloud storage
  Future<AuthResult> connect({Map<String, dynamic>? config}) async {
    if (_currentService == null) {
      return AuthResult.error('Nenhum serviço de cloud storage configurado');
    }

    final result = await _currentService!.authenticate(config: config);

    if (result.success) {
      state = _currentService!.settings;
      await _saveSettings();
    }

    return result;
  }

  /// Desconectar do serviço
  Future<void> disconnect() async {
    if (_currentService != null) {
      await _currentService!.disconnect();
      state = _currentService!.settings;
      await _saveSettings();
    }
  }

  /// Sincronizar dados
  Future<SyncResult> sync({bool forceSync = false}) async {
    if (_currentService == null) {
      return SyncResult.error(
          'Nenhum serviço de cloud storage configurado', Duration.zero);
    }

    final result = await _currentService!.sync(forceSync: forceSync);

    if (result.success) {
      state = _currentService!.settings;
      await _saveSettings();
    }

    return result;
  }

  /// Atualizar configurações de sincronização
  Future<void> updateSyncSettings({
    bool? autoSyncEnabled,
    bool? syncOnStartup,
    bool? syncOnClose,
  }) async {
    state = state.copyWith(
      autoSyncEnabled: autoSyncEnabled,
      syncOnStartup: syncOnStartup,
      syncOnClose: syncOnClose,
    );

    if (_currentService != null) {
      _currentService!.updateSettings(state);
    }

    await _saveSettings();
  }

  /// Verificar conectividade
  Future<bool> checkConnectivity() async {
    if (_currentService == null) return false;
    return await _currentService!.checkConnectivity();
  }

  /// Obter espaço de armazenamento
  Future<StorageSpace> getStorageSpace() async {
    if (_currentService == null) {
      return StorageSpace(
        totalBytes: 0,
        usedBytes: 0,
        availableBytes: 0,
        timestamp: DateTime.now(),
      );
    }

    return await _currentService!.getStorageSpace();
  }

  /// Fazer upload de arquivo
  Future<UploadResult> uploadFile({
    required String localPath,
    required String remotePath,
    bool overwrite = true,
  }) async {
    if (_currentService == null) {
      return UploadResult.error('Nenhum serviço de cloud storage configurado');
    }

    return await _currentService!.uploadFile(
      localPath: localPath,
      remotePath: remotePath,
      overwrite: overwrite,
    );
  }

  /// Fazer download de arquivo
  Future<DownloadResult> downloadFile({
    required String remotePath,
    required String localPath,
    bool overwrite = true,
  }) async {
    if (_currentService == null) {
      return DownloadResult.error(
          'Nenhum serviço de cloud storage configurado');
    }

    return await _currentService!.downloadFile(
      remotePath: remotePath,
      localPath: localPath,
      overwrite: overwrite,
    );
  }

  /// Listar arquivos remotos
  Future<List<RemoteFile>> listFiles({String? folderPath}) async {
    if (_currentService == null) return [];

    return await _currentService!.listFiles(folderPath: folderPath);
  }

  /// Obter stream de status
  Stream<CloudStorageStatus>? get statusStream => _currentService?.statusStream;

  /// Obter stream de progresso de sincronização
  Stream<SyncProgress>? get syncProgressStream =>
      _currentService?.syncProgressStream;

  /// Validar configurações
  List<String> validateSettings() {
    if (_currentService == null) return [];
    return _currentService!.validateSettings(state);
  }
}

/// Provider para status de conexão
final storageConnectionStatusProvider = Provider<CloudStorageStatus>((ref) {
  final settings = ref.watch(storageSettingsProvider);
  return settings.status;
});

/// Provider para verificar se está conectado
final isStorageConnectedProvider = Provider<bool>((ref) {
  final settings = ref.watch(storageSettingsProvider);
  return settings.isConnected;
});

/// Provider para verificar se está conectado via OAuth2 (para telas de configuração)
final isOAuth2ConnectedProvider = FutureProvider<bool>((ref) async {
  try {
    return await oauth2.OAuth2Service.hasActiveConnection();
  } catch (e) {
    return false;
  }
});

/// Provider para verificar se está sincronizando
final isStorageSyncingProvider = Provider<bool>((ref) {
  final settings = ref.watch(storageSettingsProvider);
  return settings.isSyncing;
});

/// Provider para verificar se é armazenamento local
final isLocalStorageProvider = Provider<bool>((ref) {
  final settings = ref.watch(storageSettingsProvider);
  return settings.provider == CloudStorageProvider.local;
});

/// Provider para verificar se é armazenamento em nuvem
final isCloudStorageProvider = Provider<bool>((ref) {
  final settings = ref.watch(storageSettingsProvider);
  return settings.isCloudStorage;
});

/// Provider para nome do provider atual
final currentProviderNameProvider = Provider<String>((ref) {
  final settings = ref.watch(storageSettingsProvider);
  return settings.provider.displayName;
});

/// Provider para informações da conta
final storageAccountInfoProvider = Provider<Map<String, String?>>((ref) {
  final settings = ref.watch(storageSettingsProvider);
  return {
    'email': settings.accountEmail,
    'name': settings.accountName,
    'displayName': settings.accountDisplayName,
  };
});

/// Provider para última sincronização
final lastSyncProvider = Provider<DateTime?>((ref) {
  final settings = ref.watch(storageSettingsProvider);
  return settings.lastSyncAt;
});

/// Provider para tempo desde última sincronização
final timeSinceLastSyncProvider = Provider<Duration?>((ref) {
  final settings = ref.watch(storageSettingsProvider);
  return settings.timeSinceLastSync;
});

/// Provider para verificar se precisa sincronizar
final needsSyncProvider = Provider<bool>((ref) {
  final settings = ref.watch(storageSettingsProvider);
  return settings.needsSync;
});

/// Provider para configurações de sincronização automática
final autoSyncSettingsProvider = Provider<Map<String, bool>>((ref) {
  final settings = ref.watch(storageSettingsProvider);
  return {
    'autoSyncEnabled': settings.autoSyncEnabled,
    'syncOnStartup': settings.syncOnStartup,
    'syncOnClose': settings.syncOnClose,
  };
});

/// Provider para validação de configurações
final storageSettingsValidationProvider = Provider<List<String>>((ref) {
  final notifier = ref.watch(storageSettingsProvider.notifier);
  return notifier.validateSettings();
});

/// Provider para espaço de armazenamento (future)
final storageSpaceProvider = FutureProvider<StorageSpace>((ref) async {
  final notifier = ref.watch(storageSettingsProvider.notifier);
  return await notifier.getStorageSpace();
});

/// Provider para verificar conectividade (future)
final storageConnectivityProvider = FutureProvider<bool>((ref) async {
  final notifier = ref.watch(storageSettingsProvider.notifier);
  return await notifier.checkConnectivity();
});

/// Provider para arquivos remotos (future)
final remoteFilesProvider = FutureProvider<List<RemoteFile>>((ref) async {
  final notifier = ref.watch(storageSettingsProvider.notifier);
  return await notifier.listFiles();
});

/// Provider para status com emoji
final storageStatusWithEmojiProvider = Provider<String>((ref) {
  final settings = ref.watch(storageSettingsProvider);
  return settings.statusWithEmoji;
});

/// Provider para aviso de armazenamento local
final localStorageWarningProvider = Provider<String?>((ref) {
  final isLocal = ref.watch(isLocalStorageProvider);

  if (isLocal) {
    return '⚠️ Armazenamento Local: Os dados ficam apenas neste dispositivo. '
        'Para sincronizar entre dispositivos, configure um armazenamento em nuvem '
        'ou use as opções de backup/import.';
  }

  return null;
});

/// Provider para texto de sincronização
final syncStatusTextProvider = Provider<String>((ref) {
  final settings = ref.watch(storageSettingsProvider);
  final timeSinceSync = settings.timeSinceLastSync;

  if (settings.provider == CloudStorageProvider.local) {
    return 'Armazenamento local - Sincronização não aplicável';
  }

  if (!settings.isConnected) {
    return 'Desconectado - Conecte-se para sincronizar';
  }

  if (settings.isSyncing) {
    return 'Sincronizando...';
  }

  if (timeSinceSync == null) {
    return 'Nunca sincronizado';
  }

  if (timeSinceSync.inMinutes < 1) {
    return 'Sincronizado agora';
  } else if (timeSinceSync.inMinutes < 60) {
    return 'Sincronizado há ${timeSinceSync.inMinutes} minutos';
  } else if (timeSinceSync.inHours < 24) {
    return 'Sincronizado há ${timeSinceSync.inHours} horas';
  } else {
    return 'Sincronizado há ${timeSinceSync.inDays} dias';
  }
});

/// Provider para providers disponíveis
final availableProvidersProvider = Provider<List<CloudStorageProvider>>((ref) {
  final platformService = PlatformService.instance;
  
  // Na web, não mostrar opção de armazenamento local
  if (kIsWeb && platformService.requiresCloudAuth) {
    return CloudStorageProvider.values
        .where((provider) => provider != CloudStorageProvider.local)
        .toList();
  }
  
  return CloudStorageProvider.values;
});

/// Provider para informações dos providers
final providerInfoProvider =
    Provider<Map<CloudStorageProvider, Map<String, String>>>((ref) {
  return {
    for (final provider in CloudStorageProvider.values)
      provider: {
        'name': provider.displayName,
        'icon': provider.iconName,
        'color': provider.colorHex,
      }
  };
});

/// Provider para verificar se pode fazer sync automático
final canAutoSyncProvider = Provider<bool>((ref) {
  final settings = ref.watch(storageSettingsProvider);
  return settings.canAutoBackup;
});

/// Provider para verificar se deve sincronizar na inicialização
final shouldSyncOnStartupProvider = Provider<bool>((ref) {
  final settings = ref.watch(storageSettingsProvider);
  return settings.shouldSyncOnStartup;
});

/// Provider para verificar se deve sincronizar ao fechar
final shouldSyncOnCloseProvider = Provider<bool>((ref) {
  final settings = ref.watch(storageSettingsProvider);
  return settings.shouldSyncOnClose;
});

/// Provider para obter cor do status
final statusColorProvider = Provider<String>((ref) {
  final status = ref.watch(storageConnectionStatusProvider);

  switch (status) {
    case CloudStorageStatus.connected:
      return '#4CAF50'; // Verde
    case CloudStorageStatus.syncing:
      return '#2196F3'; // Azul
    case CloudStorageStatus.connecting:
      return '#FF9800'; // Laranja
    case CloudStorageStatus.error:
      return '#F44336'; // Vermelho
    case CloudStorageStatus.disconnected:
      return '#9E9E9E'; // Cinza
  }
});

/// Provider para obter recomendações de provider
final providerRecommendationProvider = Provider<Map<String, dynamic>>((ref) {
  return {
    'recommended': CloudStorageProvider.googleDrive,
    'reason': 'Maior espaço gratuito (15GB) e melhor integração',
    'alternatives': [
      {
        'provider': CloudStorageProvider.oneDrive,
        'reason': 'Boa integração com Microsoft Office',
      },
      {
        'provider': CloudStorageProvider.local,
        'reason': 'Maior privacidade, mas sem sincronização',
      }
    ]
  };
});

/// Extensão para facilitar uso do provider
extension StorageSettingsProviderExtension on WidgetRef {
  /// Obter notifier de storage settings
  StorageSettingsNotifier get storageSettings =>
      read(storageSettingsProvider.notifier);

  /// Verificar se está conectado
  bool get isStorageConnected => read(isStorageConnectedProvider);

  /// Verificar se é storage local
  bool get isLocalStorage => read(isLocalStorageProvider);

  /// Obter status de conexão
  CloudStorageStatus get storageConnectionStatus =>
      read(storageConnectionStatusProvider);

  /// Conectar ao storage
  Future<AuthResult> connectToStorage({Map<String, dynamic>? config}) {
    return storageSettings.connect(config: config);
  }

  /// Desconectar do storage
  Future<void> disconnectFromStorage() {
    return storageSettings.disconnect();
  }

  /// Sincronizar dados
  Future<SyncResult> syncStorage({bool forceSync = false}) {
    return storageSettings.sync(forceSync: forceSync);
  }

  /// Alterar provider
  Future<void> changeStorageProvider(CloudStorageProvider provider) {
    return storageSettings.changeProvider(provider);
  }
}
