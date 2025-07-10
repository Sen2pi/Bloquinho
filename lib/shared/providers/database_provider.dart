import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bloquinho/core/models/database_models.dart';
import 'package:bloquinho/core/services/database_service.dart';

/// Provider para gerenciar o estado das tabelas do database
class DatabaseNotifier extends StateNotifier<AsyncValue<List<DatabaseTable>>> {
  final DatabaseService _databaseService;

  DatabaseNotifier(this._databaseService) : super(const AsyncValue.loading()) {
    _loadTables();
  }

  Future<void> _loadTables() async {
    try {
      await _databaseService.initialize();
      final tables = _databaseService.tables;
      state = AsyncValue.data(tables);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadTables();
  }

  Future<DatabaseTable> createTable({
    required String name,
    String? description,
    IconData? icon,
    Color? color,
  }) async {
    try {
      final table = await _databaseService.createTable(
        name: name,
        description: description,
        icon: icon,
        color: color,
      );
      await refresh();
      return table;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteTable(String tableId) async {
    try {
      await _databaseService.deleteTable(tableId);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<DatabaseTable> updateTable(DatabaseTable table) async {
    try {
      final updatedTable = await _databaseService.updateTable(table);
      await refresh();
      return updatedTable;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  List<DatabaseTable> searchTables(String query) {
    return state.whenOrNull(
          data: (tables) => _databaseService.searchTables(query),
        ) ??
        [];
  }

  DatabaseTable? getTable(String tableId) {
    return state.whenOrNull(
      data: (tables) => _databaseService.getTable(tableId),
    );
  }

  Map<String, dynamic> getStatistics() {
    return state.whenOrNull(
          data: (tables) => _databaseService.getStatistics(),
        ) ??
        {};
  }
}

/// Provider para o DatabaseService
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// Provider para o estado das tabelas
final databaseProvider =
    StateNotifierProvider<DatabaseNotifier, AsyncValue<List<DatabaseTable>>>(
        (ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return DatabaseNotifier(databaseService);
});

/// Provider para obter apenas a lista de tabelas
final tablesProvider = Provider<List<DatabaseTable>>((ref) {
  return ref.watch(databaseProvider).whenOrNull(data: (tables) => tables) ?? [];
});

/// Provider para contar o número de tabelas
final tablesCountProvider = Provider<int>((ref) {
  return ref.watch(tablesProvider).length;
});

/// Provider para verificar se existem tabelas
final hasTablesProvider = Provider<bool>((ref) {
  return ref.watch(tablesCountProvider) > 0;
});

/// Provider para estatísticas do database
final databaseStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final notifier = ref.watch(databaseProvider.notifier);
  return notifier.getStatistics();
});
