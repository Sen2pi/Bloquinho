import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:bloquinho/core/models/database_models.dart';
import 'package:bloquinho/core/services/database_service.dart';
import 'workspace_provider.dart';

/// Provider para integrar DatabaseService com Workspace
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final databaseService = DatabaseService();

  // Observar mudanças no workspace atual
  ref.listen<String?>(
    currentWorkspaceIdProvider,
    (previous, current) async {
      if (current != null && current != previous) {
        debugPrint(
            '🔄 Provider detectou mudança de workspace: $previous → $current');
        await databaseService.setCurrentWorkspace(current);
        debugPrint('✅ Workspace definido no DatabaseService');
      }
    },
  );

  return databaseService;
});

/// Provider derivado: ID do workspace atual
final currentWorkspaceIdProvider = Provider<String?>((ref) {
  return ref.watch(currentWorkspaceProvider)?.id;
});

/// Provider para tabelas do workspace atual
final databaseTablesProvider = FutureProvider<List<DatabaseTable>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.tables;
});

/// Provider para uma tabela específica
final databaseTableProvider =
    FutureProvider.family<DatabaseTable?, String>((ref, tableId) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getTable(tableId);
});

/// Provider para busca de tabelas
final databaseSearchProvider =
    FutureProvider.family<List<DatabaseTable>, String>((ref, query) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.searchTables(query);
});

/// Provider para contar tabelas do workspace atual
final databaseTableCountProvider = Provider<int>((ref) {
  final tables = ref.watch(databaseTablesProvider);

  return tables.when(
    data: (tablesList) => tablesList.length,
    loading: () => 0,
    error: (error, stack) => 0,
  );
});

/// Notifier para operações de database
class DatabaseNotifier extends StateNotifier<AsyncValue<List<DatabaseTable>>> {
  final Ref ref;
  late final DatabaseService _databaseService;
  String? _lastWorkspaceId;
  bool _isInitialized = false;

  DatabaseNotifier(this.ref) : super(const AsyncValue.loading()) {
    _databaseService = ref.read(databaseServiceProvider);

    // Observar mudanças de workspace
    ref.listen<String?>(currentWorkspaceIdProvider, (previous, current) {
      if (current != previous && current != null) {
        debugPrint(
            '🔄 DatabaseNotifier detectou mudança: $previous → $current');
        _lastWorkspaceId = current;
        _databaseService.setCurrentWorkspace(current);

        // Só recarregar se já foi inicializado
        if (_isInitialized) {
          _loadTables();
        }
      }
    });

    _init();
  }

  Future<void> _init() async {
    try {
      await _databaseService.initialize();
      _isInitialized = true;

      // Definir workspace inicial se disponível
      final currentWorkspaceId = ref.read(currentWorkspaceIdProvider);
      if (currentWorkspaceId != null) {
        _lastWorkspaceId = currentWorkspaceId;
        _databaseService.setCurrentWorkspace(currentWorkspaceId);
      }

      await _loadTables();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> _loadTables() async {
    try {
      state = const AsyncValue.loading();

      // Garantir que o workspace está definido
      if (_lastWorkspaceId != null) {
        _databaseService.setCurrentWorkspace(_lastWorkspaceId!);
      }

      final tables = _databaseService.tables;
      debugPrint(
          '🔄 DatabaseNotifier carregou ${tables.length} tabelas para workspace "$_lastWorkspaceId"');
      state = AsyncValue.data(tables);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Forçar recarregamento para novo workspace
  Future<void> reloadForWorkspace(String workspaceId) async {
    if (_lastWorkspaceId == workspaceId && _isInitialized) return;

    _lastWorkspaceId = workspaceId;
    _databaseService.setCurrentWorkspace(workspaceId);
    debugPrint('🔄 DatabaseNotifier: Recarregando para workspace $workspaceId');
    await _loadTables();
  }

  /// Criar nova tabela
  Future<void> createTable({
    required String name,
    String? description,
    dynamic icon,
    dynamic color,
  }) async {
    try {
      await _databaseService.createTable(
        name: name,
        description: description,
        icon: icon,
        color: color,
      );
      await _loadTables();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Atualizar tabela
  Future<void> updateTable(DatabaseTable table) async {
    try {
      await _databaseService.updateTable(table);
      await _loadTables();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Deletar tabela
  Future<void> deleteTable(String tableId) async {
    try {
      await _databaseService.deleteTable(tableId);
      await _loadTables();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Forçar reload das tabelas (útil após mudança de workspace)
  Future<void> refreshTables() async {
    await _loadTables();
  }
}

/// Provider principal do database com notifier
final databaseNotifierProvider =
    StateNotifierProvider<DatabaseNotifier, AsyncValue<List<DatabaseTable>>>(
        (ref) {
  return DatabaseNotifier(ref);
});

/// Provider para obter apenas a lista de tabelas
final tablesProvider = Provider<List<DatabaseTable>>((ref) {
  return ref
          .watch(databaseNotifierProvider)
          .whenOrNull(data: (tables) => tables) ??
      [];
});

/// Provider para contar o número de tabelas
final tablesCountProvider = Provider<int>((ref) {
  return ref.watch(tablesProvider).length;
});

/// Provider para verificar se existem tabelas
final hasTablesProvider = Provider<bool>((ref) {
  return ref.watch(tablesCountProvider) > 0;
});
