import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

/// Status da sincronização na nuvem
enum CloudSyncStatus {
  disconnected,
  connecting,
  connected,
  syncing,
  error,
  paused,
}

/// Estado da sincronização na nuvem
class CloudSyncState {
  final CloudSyncStatus status;
  final String? provider; // 'google', 'microsoft', 'local'
  final String? message;
  final DateTime? lastSync;
  final bool isConnected;
  final int? filesCount;
  final String? error;

  const CloudSyncState({
    required this.status,
    this.provider,
    this.message,
    this.lastSync,
    this.isConnected = false,
    this.filesCount,
    this.error,
  });

  CloudSyncState copyWith({
    CloudSyncStatus? status,
    String? provider,
    String? message,
    DateTime? lastSync,
    bool? isConnected,
    int? filesCount,
    String? error,
  }) {
    return CloudSyncState(
      status: status ?? this.status,
      provider: provider ?? this.provider,
      message: message ?? this.message,
      lastSync: lastSync ?? this.lastSync,
      isConnected: isConnected ?? this.isConnected,
      filesCount: filesCount ?? this.filesCount,
      error: error ?? this.error,
    );
  }

  /// Estado inicial desconectado
  static const CloudSyncState initial = CloudSyncState(
    status: CloudSyncStatus.disconnected,
    message: 'Desconectado',
  );
}

/// Notifier para gerenciar o estado de sincronização
class CloudSyncNotifier extends StateNotifier<CloudSyncState> {
  CloudSyncNotifier() : super(CloudSyncState.initial);

  /// Conectar com um provedor
  void connect(String provider) {
    state = state.copyWith(
      status: CloudSyncStatus.connecting,
      provider: provider,
      message: 'Conectando...',
      error: null,
    );
  }

  /// Marcar como conectado
  void setConnected({
    required String provider,
    DateTime? lastSync,
    int? filesCount,
  }) {
    state = state.copyWith(
      status: CloudSyncStatus.connected,
      provider: provider,
      message: 'Conectado',
      isConnected: true,
      lastSync: lastSync ?? DateTime.now(),
      filesCount: filesCount,
      error: null,
    );
  }

  /// Iniciar sincronização
  void startSync() {
    state = state.copyWith(
      status: CloudSyncStatus.syncing,
      message: 'Sincronizando...',
    );
  }

  /// Finalizar sincronização
  void finishSync({
    int? filesCount,
    DateTime? lastSync,
  }) {
    state = state.copyWith(
      status: CloudSyncStatus.connected,
      message: 'Sincronizado',
      lastSync: lastSync ?? DateTime.now(),
      filesCount: filesCount,
    );
  }

  /// Marcar erro
  void setError(String error) {
    state = state.copyWith(
      status: CloudSyncStatus.error,
      message: 'Erro de sincronização',
      error: error,
    );
  }

  /// Desconectar
  void disconnect() {
    state = CloudSyncState.initial;
  }

  /// Pausar sincronização
  void pause() {
    state = state.copyWith(
      status: CloudSyncStatus.paused,
      message: 'Pausado',
    );
  }

  /// Resumir sincronização
  void resume() {
    if (state.isConnected) {
      state = state.copyWith(
        status: CloudSyncStatus.connected,
        message: 'Conectado',
      );
    }
  }
}

/// Provider principal do status de sincronização
final cloudSyncStatusProvider =
    StateNotifierProvider<CloudSyncNotifier, CloudSyncState>((ref) {
  return CloudSyncNotifier();
});

/// Provider derivado: ícone do status
final cloudSyncIconProvider = Provider<IconData>((ref) {
  final status = ref.watch(cloudSyncStatusProvider).status;

  switch (status) {
    case CloudSyncStatus.disconnected:
      return Icons.cloud_off;
    case CloudSyncStatus.connecting:
      return Icons.cloud_queue;
    case CloudSyncStatus.connected:
      return Icons.cloud_done;
    case CloudSyncStatus.syncing:
      return Icons.cloud_sync;
    case CloudSyncStatus.error:
      return Icons.cloud_off;
    case CloudSyncStatus.paused:
      return Icons.pause_circle;
  }
});

/// Provider derivado: cor do status
final cloudSyncColorProvider = Provider<Color>((ref) {
  final status = ref.watch(cloudSyncStatusProvider).status;

  switch (status) {
    case CloudSyncStatus.disconnected:
      return Colors.grey;
    case CloudSyncStatus.connecting:
      return Colors.orange;
    case CloudSyncStatus.connected:
      return Colors.green;
    case CloudSyncStatus.syncing:
      return Colors.blue;
    case CloudSyncStatus.error:
      return Colors.red;
    case CloudSyncStatus.paused:
      return Colors.amber;
  }
});

/// Provider derivado: texto do status
final cloudSyncMessageProvider = Provider<String>((ref) {
  final state = ref.watch(cloudSyncStatusProvider);

  if (state.error != null) {
    return 'Erro: ${state.error}';
  }

  return state.message ?? 'Desconhecido';
});

/// Provider derivado: último sincronização formatada
final cloudSyncLastSyncProvider = Provider<String?>((ref) {
  final lastSync = ref.watch(cloudSyncStatusProvider).lastSync;

  if (lastSync == null) return null;

  final now = DateTime.now();
  final difference = now.difference(lastSync);

  if (difference.inMinutes < 1) {
    return 'Agora mesmo';
  } else if (difference.inHours < 1) {
    return '${difference.inMinutes}m atrás';
  } else if (difference.inDays < 1) {
    return '${difference.inHours}h atrás';
  } else {
    return '${difference.inDays}d atrás';
  }
});
