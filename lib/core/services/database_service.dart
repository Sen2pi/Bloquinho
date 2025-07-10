import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bloquinho/core/models/database_models.dart';
import 'package:bloquinho/core/services/local_storage_service.dart';

/// Serviço para gerenciar operações do sistema de database
class DatabaseService {
  static const String _boxName = 'database_tables';
  static const String _tablesKey = 'all_tables';

  Box<String>? _box;
  bool _initialized = false;
  List<DatabaseTable> _tables = [];

  /// Instância singleton
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Inicializa o serviço
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _box = await Hive.openBox<String>(_boxName);
      await _loadTables();
      _initialized = true;
      debugPrint(
          '✅ DatabaseService inicializado com ${_tables.length} tabelas');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar DatabaseService: $e');
      rethrow;
    }
  }

  /// Carrega todas as tabelas do storage
  Future<void> _loadTables() async {
    try {
      final tablesJson = _box?.get(_tablesKey);
      if (tablesJson != null) {
        final List<dynamic> tablesList = json.decode(tablesJson);
        _tables =
            tablesList.map((data) => DatabaseTable.fromJson(data)).toList();
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar tabelas: $e');
      _tables = [];
    }
  }

  /// Salva todas as tabelas no storage
  Future<void> _saveTables() async {
    try {
      final tablesJson = json.encode(_tables.map((t) => t.toJson()).toList());
      await _box?.put(_tablesKey, tablesJson);

      // Também salvar em arquivos locais para backup
      await _saveToLocalFiles();
    } catch (e) {
      debugPrint('❌ Erro ao salvar tabelas: $e');
      rethrow;
    }
  }

  /// Salva backup em arquivos locais
  Future<void> _saveToLocalFiles() async {
    try {
      final localStorage = LocalStorageService();
      final dataPath = await localStorage.getBasePath();

      if (dataPath == null) return; // Web não suporta arquivos locais

      final databaseDir = Directory('$dataPath/database');
      if (!await databaseDir.exists()) {
        await databaseDir.create(recursive: true);
      }

      // Salvar cada tabela em arquivo separado
      for (final table in _tables) {
        final tableFile = File('${databaseDir.path}/${table.id}.json');
        await tableFile.writeAsString(json.encode(table.toJson()));
      }

      // Salvar índice de tabelas
      final indexFile = File('${databaseDir.path}/index.json');
      await indexFile.writeAsString(json.encode({
        'tables': _tables
            .map((t) => {
                  'id': t.id,
                  'name': t.name,
                  'lastModified': t.lastModified.toIso8601String(),
                })
            .toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      }));

      debugPrint('💾 Backup das tabelas salvo em: ${databaseDir.path}');
    } catch (e) {
      debugPrint('⚠️ Erro ao salvar backup local: $e');
      // Não falhar se o backup local falhar
    }
  }

  /// Obtém todas as tabelas
  List<DatabaseTable> get tables {
    return List.unmodifiable(_tables);
  }

  /// Obtém uma tabela por ID
  DatabaseTable? getTable(String tableId) {
    try {
      return _tables.firstWhere((t) => t.id == tableId);
    } catch (e) {
      return null;
    }
  }

  /// Obtém tabelas por nome (busca)
  List<DatabaseTable> searchTables(String query) {
    if (query.isEmpty) return tables;

    final lowercaseQuery = query.toLowerCase();
    return _tables
        .where((table) =>
            table.name.toLowerCase().contains(lowercaseQuery) ||
            table.description.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  /// Cria uma nova tabela
  Future<DatabaseTable> createTable({
    required String name,
    String? description,
    IconData? icon,
    Color? color,
  }) async {
    await _ensureInitialized();

    final table = DatabaseTable.empty(
      name: name,
      description: description,
      icon: icon,
      color: color,
    );

    _tables.add(table);
    await _saveTables();

    debugPrint('✅ Tabela criada: ${table.name} (${table.id})');
    return table;
  }

  /// Atualiza uma tabela
  Future<DatabaseTable> updateTable(DatabaseTable table) async {
    await _ensureInitialized();

    final index = _tables.indexWhere((t) => t.id == table.id);
    if (index == -1) {
      throw Exception('Tabela não encontrada: ${table.id}');
    }

    final updatedTable = table.copyWith(lastModified: DateTime.now());
    _tables[index] = updatedTable;
    await _saveTables();

    debugPrint('✅ Tabela atualizada: ${updatedTable.name}');
    return updatedTable;
  }

  /// Remove uma tabela
  Future<void> deleteTable(String tableId) async {
    await _ensureInitialized();

    final table = getTable(tableId);
    if (table == null) {
      throw Exception('Tabela não encontrada: $tableId');
    }

    _tables.removeWhere((t) => t.id == tableId);
    await _saveTables();

    // Remover arquivo local também
    try {
      final localStorage = LocalStorageService();
      final dataPath = await localStorage.getBasePath();
      if (dataPath != null) {
        final tableFile = File('$dataPath/database/$tableId.json');
        if (await tableFile.exists()) {
          await tableFile.delete();
        }
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao remover arquivo local: $e');
    }

    debugPrint('🗑️ Tabela removida: ${table.name}');
  }

  /// Adiciona uma coluna a uma tabela
  Future<DatabaseTable> addColumn(String tableId, DatabaseColumn column) async {
    await _ensureInitialized();

    final table = getTable(tableId);
    if (table == null) {
      throw Exception('Tabela não encontrada: $tableId');
    }

    final updatedTable = table.addColumn(column);
    return await updateTable(updatedTable);
  }

  /// Remove uma coluna de uma tabela
  Future<DatabaseTable> removeColumn(String tableId, String columnId) async {
    await _ensureInitialized();

    final table = getTable(tableId);
    if (table == null) {
      throw Exception('Tabela não encontrada: $tableId');
    }

    final updatedTable = table.removeColumn(columnId);
    return await updateTable(updatedTable);
  }

  /// Atualiza uma coluna de uma tabela
  Future<DatabaseTable> updateColumn(
      String tableId, DatabaseColumn column) async {
    await _ensureInitialized();

    final table = getTable(tableId);
    if (table == null) {
      throw Exception('Tabela não encontrada: $tableId');
    }

    final updatedTable = table.updateColumn(column);
    return await updateTable(updatedTable);
  }

  /// Adiciona uma linha a uma tabela
  Future<DatabaseTable> addRow(String tableId,
      {Map<String, dynamic>? initialData}) async {
    await _ensureInitialized();

    final table = getTable(tableId);
    if (table == null) {
      throw Exception('Tabela não encontrada: $tableId');
    }

    final now = DateTime.now();
    final rowId = 'row_${now.millisecondsSinceEpoch}';

    // Criar células iniciais baseadas nas colunas existentes
    final cells = <String, DatabaseCellValue>{};
    for (final column in table.columns) {
      final initialValue = initialData?[column.id];
      cells[column.id] = DatabaseCellValue(
        columnId: column.id,
        value: initialValue,
        lastModified: now,
      );
    }

    final row = DatabaseRow(
      id: rowId,
      tableId: tableId,
      cells: cells,
      createdAt: now,
      lastModified: now,
    );

    final updatedTable = table.addRow(row);
    return await updateTable(updatedTable);
  }

  /// Remove uma linha de uma tabela
  Future<DatabaseTable> removeRow(String tableId, String rowId) async {
    await _ensureInitialized();

    final table = getTable(tableId);
    if (table == null) {
      throw Exception('Tabela não encontrada: $tableId');
    }

    final updatedTable = table.removeRow(rowId);
    return await updateTable(updatedTable);
  }

  /// Atualiza uma célula específica
  Future<DatabaseTable> updateCell(
    String tableId,
    String rowId,
    String columnId,
    dynamic value,
  ) async {
    await _ensureInitialized();

    final table = getTable(tableId);
    if (table == null) {
      throw Exception('Tabela não encontrada: $tableId');
    }

    final row = table.getRow(rowId);
    if (row == null) {
      throw Exception('Linha não encontrada: $rowId');
    }

    final updatedRow = row.setCell(columnId, value);
    final updatedTable = table.updateRow(updatedRow);
    return await updateTable(updatedTable);
  }

  /// Atualiza múltiplas células de uma linha
  Future<DatabaseTable> updateRowCells(
    String tableId,
    String rowId,
    Map<String, dynamic> updates,
  ) async {
    await _ensureInitialized();

    final table = getTable(tableId);
    if (table == null) {
      throw Exception('Tabela não encontrada: $tableId');
    }

    final row = table.getRow(rowId);
    if (row == null) {
      throw Exception('Linha não encontrada: $rowId');
    }

    DatabaseRow updatedRow = row;
    for (final entry in updates.entries) {
      updatedRow = updatedRow.setCell(entry.key, entry.value);
    }

    final updatedTable = table.updateRow(updatedRow);
    return await updateTable(updatedTable);
  }

  /// Duplica uma tabela
  Future<DatabaseTable> duplicateTable(String tableId,
      {String? newName}) async {
    await _ensureInitialized();

    final originalTable = getTable(tableId);
    if (originalTable == null) {
      throw Exception('Tabela não encontrada: $tableId');
    }

    final now = DateTime.now();
    final newId = 'table_${now.millisecondsSinceEpoch}';
    final duplicatedName = newName ?? '${originalTable.name} (Cópia)';

    // Duplicar colunas com novos IDs
    final newColumns = <DatabaseColumn>[];
    final columnIdMap = <String, String>{};

    for (final column in originalTable.columns) {
      final newColumnId =
          'col_${now.millisecondsSinceEpoch}_${newColumns.length}';
      columnIdMap[column.id] = newColumnId;

      newColumns.add(column.copyWith(id: newColumnId));
    }

    // Duplicar linhas com novos IDs e referências de coluna atualizadas
    final newRows = <DatabaseRow>[];
    for (int i = 0; i < originalTable.rows.length; i++) {
      final originalRow = originalTable.rows[i];
      final newRowId = 'row_${now.millisecondsSinceEpoch}_$i';

      final newCells = <String, DatabaseCellValue>{};
      for (final entry in originalRow.cells.entries) {
        final newColumnId = columnIdMap[entry.key];
        if (newColumnId != null) {
          newCells[newColumnId] = entry.value.copyWith(
            columnId: newColumnId,
            lastModified: now,
          );
        }
      }

      newRows.add(DatabaseRow(
        id: newRowId,
        tableId: newId,
        cells: newCells,
        createdAt: now,
        lastModified: now,
      ));
    }

    final duplicatedTable = originalTable.copyWith(
      id: newId,
      name: duplicatedName,
      columns: newColumns,
      rows: newRows,
      createdAt: now,
      lastModified: now,
    );

    _tables.add(duplicatedTable);
    await _saveTables();

    debugPrint('✅ Tabela duplicada: ${duplicatedTable.name}');
    return duplicatedTable;
  }

  /// Importa tabela de JSON
  Future<DatabaseTable> importFromJson(Map<String, dynamic> json) async {
    await _ensureInitialized();

    final table = DatabaseTable.fromJson(json);

    // Gerar novo ID para evitar conflitos
    final now = DateTime.now();
    final newId = 'table_${now.millisecondsSinceEpoch}';
    final importedTable = table.copyWith(
      id: newId,
      lastModified: now,
    );

    _tables.add(importedTable);
    await _saveTables();

    debugPrint('✅ Tabela importada: ${importedTable.name}');
    return importedTable;
  }

  /// Exporta tabela para JSON
  Map<String, dynamic> exportToJson(String tableId) {
    final table = getTable(tableId);
    if (table == null) {
      throw Exception('Tabela não encontrada: $tableId');
    }

    return table.toJson();
  }

  /// Obtém estatísticas gerais
  Map<String, dynamic> getStatistics() {
    final totalRows =
        _tables.fold<int>(0, (sum, table) => sum + table.rows.length);
    final totalColumns =
        _tables.fold<int>(0, (sum, table) => sum + table.columns.length);
    final tablesWithMath = _tables
        .where((table) => table.columns.any((col) => col.mathOperation != null))
        .length;

    return {
      'totalTables': _tables.length,
      'totalRows': totalRows,
      'totalColumns': totalColumns,
      'tablesWithMath': tablesWithMath,
      'averageRowsPerTable':
          _tables.isNotEmpty ? totalRows / _tables.length : 0,
      'averageColumnsPerTable':
          _tables.isNotEmpty ? totalColumns / _tables.length : 0,
    };
  }

  /// Executa busca avançada nas tabelas
  List<Map<String, dynamic>> searchData({
    String? query,
    String? tableId,
    String? columnId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final results = <Map<String, dynamic>>[];

    final tablesToSearch = tableId != null
        ? [getTable(tableId)].where((t) => t != null).cast<DatabaseTable>()
        : _tables;

    for (final table in tablesToSearch) {
      for (final row in table.rows) {
        // Filtrar por data se especificado
        if (startDate != null && row.lastModified.isBefore(startDate)) continue;
        if (endDate != null && row.lastModified.isAfter(endDate)) continue;

        // Buscar nas células
        for (final cell in row.cells.values) {
          if (columnId != null && cell.columnId != columnId) continue;

          final cellText = cell.displayValue.toLowerCase();
          if (query == null || cellText.contains(query.toLowerCase())) {
            final column = table.getColumn(cell.columnId);
            results.add({
              'tableId': table.id,
              'tableName': table.name,
              'rowId': row.id,
              'columnId': cell.columnId,
              'columnName': column?.name ?? 'Unknown',
              'value': cell.value,
              'displayValue': cell.displayValue,
              'lastModified': cell.lastModified,
            });
          }
        }
      }
    }

    return results;
  }

  /// Garantir que o serviço está inicializado
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  /// Limpa o cache e recarrega dados
  Future<void> refresh() async {
    _tables.clear();
    await _loadTables();
    debugPrint('🔄 DatabaseService recarregado');
  }

  /// Fecha o serviço
  Future<void> dispose() async {
    await _box?.close();
    _initialized = false;
    debugPrint('🔒 DatabaseService finalizado');
  }
}
