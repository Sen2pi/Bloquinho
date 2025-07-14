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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bloquinho/core/models/database_models.dart';
import 'package:bloquinho/core/services/local_storage_service.dart';
import 'package:bloquinho/core/services/data_directory_service.dart';
import 'package:bloquinho/core/services/workspace_storage_service.dart';

/// Serviço para gerenciar operações do sistema de database
class DatabaseService {
  static const String _boxName = 'database_tables';
  static const String _tablesKey = 'all_tables';

  bool _initialized = false;
  List<DatabaseTable> _tables = [];
  String? _currentWorkspaceId;
  String? _currentProfileName;
  final WorkspaceStorageService _workspaceStorage = WorkspaceStorageService();

  /// Instância singleton
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Inicializa o serviço
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _workspaceStorage.initialize();
      await _loadTables();
      _initialized = true;
    } catch (e) {
      rethrow;
    }
  }

  /// Definir contexto completo (perfil + workspace)
  Future<void> setContext(String profileName, String workspaceId) async {
    await _ensureInitialized();

    _currentProfileName = profileName;
    _currentWorkspaceId = workspaceId;

    // Definir contexto no workspace storage
    await _workspaceStorage.setContext(profileName, workspaceId);

    // Recarregar tabelas com novo contexto
    await _loadTables();
  }

  /// Carrega todas as tabelas do storage
  Future<void> _loadTables() async {
    try {
      final workspaceData =
          await _workspaceStorage.loadWorkspaceData('database');
      if (workspaceData != null) {
        final List<dynamic> tablesList =
            workspaceData['tables'] as List<dynamic>? ?? [];
        _tables =
            tablesList.map((data) => DatabaseTable.fromJson(data)).toList();
      } else {
        // Se não há dados, inicializar com lista vazia
        _tables = [];
      }
    } catch (e) {
      _tables = [];
    }
  }

  /// Salva todas as tabelas no storage
  Future<void> _saveTables() async {
    try {
      final data = {
        'tables': _tables.map((t) => t.toJson()).toList(),
        'lastModified': DateTime.now().toIso8601String(),
      };
      await _workspaceStorage.saveWorkspaceData('database', data);

      // Também salvar em arquivos locais para backup
      await _saveToLocalFiles();
    } catch (e) {
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

    } catch (e) {
      // Não falhar se o backup local falhar
    }
  }

  /// Define o workspace atual
  Future<void> setCurrentWorkspace(String workspaceId) async {
    await _ensureInitialized();

    final previousWorkspace = _currentWorkspaceId;
    _currentWorkspaceId = workspaceId;


    // Migrar tabelas sem workspaceId para o workspace atual
    _migrateOrphanTables();

    final filteredTables = tables;

  }

  /// Obter workspace atual
  String? get currentWorkspaceId => _currentWorkspaceId;

  /// Migra tabelas sem workspaceId para o workspace atual
  void _migrateOrphanTables() {
    bool hasChanges = false;

    for (int i = 0; i < _tables.length; i++) {
      final table = _tables[i];
      if (table.workspaceId == null) {
        _tables[i] = table.copyWith(workspaceId: _currentWorkspaceId);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      _saveTables(); // Salvar mudanças de migração
    }
  }

  /// Obtém todas as tabelas do workspace atual
  List<DatabaseTable> get tables {
    if (_currentWorkspaceId == null) {
      return List.unmodifiable(_tables);
    }

    final filtered = _tables
        .where((table) => table.workspaceId == _currentWorkspaceId)
        .toList();


    return List.unmodifiable(filtered);
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
    ).copyWith(workspaceId: _currentWorkspaceId); // Definir workspace atual

    _tables.add(table);
    await _saveTables();

    return table;
  }

  /// Atualiza uma tabela existente
  Future<DatabaseTable> updateTable(DatabaseTable table) async {
    await _ensureInitialized();

    final index = _tables.indexWhere((t) => t.id == table.id);
    if (index != -1) {
      final updatedTable = table.copyWith(
        lastModified: DateTime.now(),
        workspaceId: _currentWorkspaceId, // Garantir workspace atual
      );
      _tables[index] = updatedTable;
      await _saveTables();
      return updatedTable;
    }
    return table;
  }

  /// Deleta uma tabela
  Future<void> deleteTable(String tableId) async {
    await _ensureInitialized();

    _tables.removeWhere((table) => table.id == tableId);
    await _saveTables();
  }

  /// Adiciona uma coluna à tabela
  Future<DatabaseTable> addColumn(String tableId, DatabaseColumn column) async {
    await _ensureInitialized();

    final table = getTable(tableId);
    if (table == null) {
      throw Exception('Tabela não encontrada: $tableId');
    }

    final updatedTable = table.addColumn(column);
    await updateTable(updatedTable);
    return updatedTable;
  }

  /// Remove uma coluna da tabela
  Future<DatabaseTable> removeColumn(String tableId, String columnId) async {
    await _ensureInitialized();

    final table = getTable(tableId);
    if (table == null) {
      throw Exception('Tabela não encontrada: $tableId');
    }

    final updatedTable = table.removeColumn(columnId);
    await updateTable(updatedTable);
    return updatedTable;
  }

  /// Atualiza uma coluna da tabela
  Future<DatabaseTable> updateColumn(
      String tableId, DatabaseColumn column) async {
    await _ensureInitialized();

    final table = getTable(tableId);
    if (table == null) {
      throw Exception('Tabela não encontrada: $tableId');
    }

    final updatedTable = table.updateColumn(column);
    await updateTable(updatedTable);
    return updatedTable;
  }

  /// Adiciona uma linha à tabela
  Future<DatabaseTable> addRow(String tableId, DatabaseRow row) async {
    await _ensureInitialized();

    final table = getTable(tableId);
    if (table == null) {
      throw Exception('Tabela não encontrada: $tableId');
    }

    final updatedTable = table.addRow(row);
    await updateTable(updatedTable);
    return updatedTable;
  }

  /// Remove uma linha da tabela
  Future<DatabaseTable> removeRow(String tableId, String rowId) async {
    await _ensureInitialized();

    final table = getTable(tableId);
    if (table == null) {
      throw Exception('Tabela não encontrada: $tableId');
    }

    final updatedTable = table.removeRow(rowId);
    await updateTable(updatedTable);
    return updatedTable;
  }

  /// Atualiza uma célula da tabela
  Future<DatabaseTable> updateCell(
      String tableId, String rowId, String columnId, dynamic value) async {
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
    await updateTable(updatedTable);
    return updatedTable;
  }

  /// Atualiza múltiplas células de uma linha
  Future<DatabaseTable> updateRowCells(
      String tableId, String rowId, Map<String, dynamic> cells) async {
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
    for (final entry in cells.entries) {
      updatedRow = updatedRow.setCell(entry.key, entry.value);
    }

    final updatedTable = table.updateRow(updatedRow);
    await updateTable(updatedTable);
    return updatedTable;
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
  }
}