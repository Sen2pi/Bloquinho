import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bloquinho/core/models/storage_settings.dart';
import 'package:bloquinho/core/services/cloud_storage_service.dart';
import 'package:bloquinho/shared/providers/storage_settings_provider.dart';

/// Serviço para gerenciar sincronização automática
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  Timer? _autoSyncTimer;
  StreamSubscription? _statusSubscription;
  ProviderSubscription? _settingsSubscription;
  ProviderContainer? _container;

  bool _isInitialized = false;
  bool _isSyncing = false;

  /// Inicializar serviço de sincronização
  void initialize(ProviderContainer container) {
    if (_isInitialized) return;

    _container = container;
    _isInitialized = true;

    // Observar mudanças nas configurações
    _settingsSubscription = _container!.listen<StorageSettings>(
      storageSettingsProvider,
      (previous, next) {
        _onSettingsChanged(next);
      },
    );

    // Inicializar com configurações atuais
    final currentSettings = _container!.read(storageSettingsProvider);
    _onSettingsChanged(currentSettings);
  }

  /// Observar mudanças nas configurações
  void _onSettingsChanged(StorageSettings settings) {
    if (!settings.isCloudStorage) {
      _stopAutoSync();
      return;
    }

    // Configurar sincronização automática
    if (settings.autoSyncEnabled && settings.isConnected) {
      _startAutoSync();
    } else {
      _stopAutoSync();
    }

    // Observar mudanças de status
    _statusSubscription?.cancel();
    final notifier = _container!.read(storageSettingsProvider.notifier);
    final service = notifier.currentService;

    if (service != null) {
      _statusSubscription = service.statusStream.listen((status) {
        if (status == CloudStorageStatus.connected &&
            settings.autoSyncEnabled &&
            settings.needsSync) {
          _scheduleSync();
        }
      });
    }
  }

  /// Iniciar sincronização automática
  void _startAutoSync() {
    _stopAutoSync();

    // Sincronizar a cada 30 minutos
    _autoSyncTimer = Timer.periodic(
      const Duration(minutes: 30),
      (timer) => _performAutoSync(),
    );
  }

  /// Parar sincronização automática
  void _stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  /// Executar sincronização automática
  Future<void> _performAutoSync() async {
    if (!_isInitialized || _isSyncing) return;

    final notifier = _container!.read(storageSettingsProvider.notifier);
    final settings = _container!.read(storageSettingsProvider);

    if (!settings.canAutoBackup || !settings.needsSync) {
      return;
    }

    _isSyncing = true;

    try {
      await notifier.sync();
      print('Sincronização automática concluída com sucesso');
    } catch (e) {
      print('Erro na sincronização automática: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Agendar sincronização para breve
  void _scheduleSync() {
    Timer(const Duration(seconds: 5), () {
      _performAutoSync();
    });
  }

  /// Sincronizar na inicialização do app
  Future<void> syncOnStartup() async {
    if (!_isInitialized) return;

    final settings = _container!.read(storageSettingsProvider);

    if (settings.shouldSyncOnStartup) {
      await _performAutoSync();
    }
  }

  /// Sincronizar ao fechar app
  Future<void> syncOnClose() async {
    if (!_isInitialized) return;

    final settings = _container!.read(storageSettingsProvider);

    if (settings.shouldSyncOnClose) {
      await _performAutoSync();
    }
  }

  /// Forçar sincronização manual
  Future<SyncResult> forceSyncNow() async {
    if (!_isInitialized) {
      return SyncResult.error('Serviço não inicializado', Duration.zero);
    }

    final notifier = _container!.read(storageSettingsProvider.notifier);
    return await notifier.sync(forceSync: true);
  }

  /// Verificar se está sincronizando
  bool get isSyncing => _isSyncing;

  /// Verificar se tem sincronização pendente
  bool get hasPendingSync {
    if (!_isInitialized) return false;

    final settings = _container!.read(storageSettingsProvider);
    return settings.needsSync;
  }

  /// Obter próxima sincronização programada
  Duration? get nextSyncIn {
    if (_autoSyncTimer == null) return null;

    final settings = _container!.read(storageSettingsProvider);
    final timeSinceLastSync = settings.timeSinceLastSync;

    if (timeSinceLastSync == null) return null;

    const syncInterval = Duration(minutes: 30);
    final nextSync = syncInterval - timeSinceLastSync;

    return nextSync.isNegative ? Duration.zero : nextSync;
  }

  /// Limpar recursos
  void dispose() {
    _stopAutoSync();
    _statusSubscription?.cancel();
    _settingsSubscription?.close();
    _container = null;
    _isInitialized = false;
  }
}

/// Provider para o serviço de sincronização
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});

/// Provider para verificar se está sincronizando automaticamente
final isAutoSyncingProvider = Provider<bool>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.isSyncing;
});

/// Provider para verificar se tem sincronização pendente
final hasPendingSyncProvider = Provider<bool>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.hasPendingSync;
});

/// Provider para próxima sincronização
final nextSyncProvider = Provider<Duration?>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.nextSyncIn;
});

/// Provider para status de sincronização automática
final autoSyncStatusProvider = Provider<Map<String, dynamic>>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  final settings = ref.watch(storageSettingsProvider);

  return {
    'enabled': settings.autoSyncEnabled,
    'active': syncService.isSyncing,
    'pendingSync': syncService.hasPendingSync,
    'nextSync': syncService.nextSyncIn,
    'canAutoSync': settings.canAutoBackup,
  };
});

/// Extensão para facilitar uso do sync service
extension SyncServiceExtension on WidgetRef {
  /// Obter serviço de sincronização
  SyncService get syncService => read(syncServiceProvider);

  /// Verificar se está sincronizando
  bool get isAutoSyncing => read(isAutoSyncingProvider);

  /// Verificar se tem sincronização pendente
  bool get hasPendingSync => read(hasPendingSyncProvider);

  /// Forçar sincronização
  Future<SyncResult> forceSyncNow() => syncService.forceSyncNow();

  /// Sincronizar na inicialização
  Future<void> syncOnStartup() => syncService.syncOnStartup();

  /// Sincronizar ao fechar
  Future<void> syncOnClose() => syncService.syncOnClose();
}

/// Mixin para widgets que precisam de sincronização
mixin SyncMixin {
  /// Inicializar sincronização no widget
  void initializeSync(WidgetRef ref) {
    final container = ProviderScope.containerOf(ref.context);
    ref.read(syncServiceProvider).initialize(container);
  }

  /// Sincronizar quando widget aparecer
  Future<void> syncOnAppear(WidgetRef ref) async {
    await ref.syncOnStartup();
  }

  /// Sincronizar quando widget desaparecer
  Future<void> syncOnDisappear(WidgetRef ref) async {
    await ref.syncOnClose();
  }
}

/// Helper para gerenciar ciclo de vida da sincronização
class SyncLifecycleManager {
  static bool _isInitialized = false;

  /// Inicializar gerenciador de ciclo de vida
  static void initialize(ProviderContainer container) {
    if (_isInitialized) return;

    final syncService = container.read(syncServiceProvider);
    syncService.initialize(container);

    _isInitialized = true;
  }

  /// Sincronizar na inicialização do app
  static Future<void> onAppStart(ProviderContainer container) async {
    final syncService = container.read(syncServiceProvider);
    await syncService.syncOnStartup();
  }

  /// Sincronizar ao fechar app
  static Future<void> onAppClose(ProviderContainer container) async {
    final syncService = container.read(syncServiceProvider);
    await syncService.syncOnClose();
  }

  /// Limpar recursos
  static void dispose(ProviderContainer container) {
    final syncService = container.read(syncServiceProvider);
    syncService.dispose();
    _isInitialized = false;
  }
}

/// Widget para monitorar status de sincronização
class SyncStatusWidget extends ConsumerWidget {
  final Widget child;

  const SyncStatusWidget({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoSyncStatus = ref.watch(autoSyncStatusProvider);
    final isAutoSyncing = autoSyncStatus['active'] as bool;

    return Stack(
      children: [
        child,
        if (isAutoSyncing)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              child: const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ),
      ],
    );
  }
}

/// Indicador de sincronização para usar em app bars
class SyncIndicator extends ConsumerWidget {
  final double size;

  const SyncIndicator({
    this.size = 20,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAutoSyncing = ref.watch(isAutoSyncingProvider);
    final hasPendingSync = ref.watch(hasPendingSyncProvider);

    if (isAutoSyncing) {
      return SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    if (hasPendingSync) {
      return Icon(
        Icons.sync_problem,
        size: size,
        color: Colors.orange,
      );
    }

    return const SizedBox.shrink();
  }
}
