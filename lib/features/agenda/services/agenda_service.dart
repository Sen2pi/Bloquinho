/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:uuid/uuid.dart';
import 'package:bloquinho/core/services/workspace_storage_service.dart';
import 'package:bloquinho/core/services/data_directory_service.dart';

import '../models/agenda_item.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../core/services/database_service.dart';
import '../../../core/models/database_models.dart';

class AgendaService {
  static const String _boxName = 'agenda_items';

  static final AgendaService _instance = AgendaService._internal();
  factory AgendaService() => _instance;
  AgendaService._internal();

  final Uuid _uuid = const Uuid();
  final WorkspaceStorageService _workspaceStorage = WorkspaceStorageService();

  bool _isInitialized = false;
  String? _currentWorkspaceId;
  String? _currentProfileName;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _workspaceStorage.initialize();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Erro ao inicializar AgendaService: $e');
    }
  }

  /// Definir contexto completo (perfil + workspace)
  Future<void> setContext(String profileName, String workspaceId) async {
    await _ensureInitialized();

    _currentProfileName = profileName;
    _currentWorkspaceId = workspaceId;

    // Definir contexto no workspace storage
    await _workspaceStorage.setContext(profileName, workspaceId);
  }

  /// Definir workspace atual
  Future<void> setCurrentWorkspace(String workspaceId) async {
    await _ensureInitialized();

    if (_currentWorkspaceId != workspaceId) {
      _currentWorkspaceId = workspaceId;
    }
  }

  /// Obter workspace atual
  String? get currentWorkspaceId => _currentWorkspaceId;

  // CRUD Operations
  Future<List<AgendaItem>> getAllItems() async {
    await _ensureInitialized();

    if (_currentWorkspaceId == null) {
      return [];
    }

    final List<AgendaItem> items = [];

    // Carregar do workspace storage primeiro
    final workspaceData = await _workspaceStorage.loadWorkspaceData('agenda');
    if (workspaceData != null) {
      final itemsData = workspaceData['items'] as List<dynamic>? ?? [];
      for (final data in itemsData) {
        try {
          final item = AgendaItem.fromJson(Map<String, dynamic>.from(data));
          items.add(item);
        } catch (e) {
          continue;
        }
      }
    }

    return items
      ..sort((a, b) => (a.startDate ?? a.deadline ?? DateTime.now())
          .compareTo(b.startDate ?? b.deadline ?? DateTime.now()));
  }

  Future<AgendaItem?> getItemById(String id) async {
    await _ensureInitialized();

    final allItems = await getAllItems();
    try {
      return allItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<String> createItem(AgendaItem item) async {
    await _ensureInitialized();

    if (_currentWorkspaceId == null) {
      throw Exception('Workspace não definido');
    }

    final now = DateTime.now();
    final newItem = item.copyWith(
      id: _uuid.v4(),
      createdAt: now,
      updatedAt: now,
      workspaceId: _currentWorkspaceId, // Definir workspace
    );

    // Salvar no workspace storage
    final allItems = await getAllItems();
    allItems.add(newItem);
    await _saveItemsToWorkspace(allItems);

    return newItem.id;
  }

  Future<void> updateItem(AgendaItem item) async {
    await _ensureInitialized();

    if (_currentWorkspaceId == null) {
      throw Exception('Workspace não definido');
    }

    // Se o item é da base de dados, não precisa salvar na agenda
    if (item.databaseItemId != null) {
      return;
    }

    final updatedItem = item.copyWith(
      updatedAt: DateTime.now(),
      workspaceId: _currentWorkspaceId, // Garantir workspace
    );

    // Atualizar no workspace storage
    final allItems = await getAllItems();
    final index = allItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      allItems[index] = updatedItem;
      await _saveItemsToWorkspace(allItems);
    }
  }

  Future<void> deleteItem(String id) async {
    await _ensureInitialized();

    // Remover do workspace storage
    final allItems = await getAllItems();
    allItems.removeWhere((i) => i.id == id);
    await _saveItemsToWorkspace(allItems);
  }

  /// Salvar itens no workspace storage
  Future<void> _saveItemsToWorkspace(List<AgendaItem> items) async {
    if (_currentWorkspaceId == null) return;

    final data = {
      'items': items.map((i) => i.toJson()).toList(),
      'lastModified': DateTime.now().toIso8601String(),
    };

    await _workspaceStorage.saveWorkspaceData('agenda', data);
  }

  // Busca e filtros
  Future<List<AgendaItem>> getItemsByDate(DateTime date) async {
    final allItems = await getAllItems();
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return allItems.where((item) {
      final itemDate = item.startDate ?? item.deadline;
      if (itemDate == null) return false;

      return itemDate.isAfter(startOfDay) && itemDate.isBefore(endOfDay);
    }).toList();
  }

  Future<List<AgendaItem>> getItemsByStatus(TaskStatus status) async {
    final allItems = await getAllItems();
    return allItems.where((item) => item.status == status).toList();
  }

  Future<List<AgendaItem>> getItemsByType(AgendaItemType type) async {
    final allItems = await getAllItems();
    return allItems.where((item) => item.type == type).toList();
  }

  Future<List<AgendaItem>> getOverdueItems() async {
    final allItems = await getAllItems();
    return allItems.where((item) => item.isOverdue).toList();
  }

  Future<List<AgendaItem>> getDueTodayItems() async {
    final allItems = await getAllItems();
    return allItems.where((item) => item.isDueToday).toList();
  }

  Future<List<AgendaItem>> getDueSoonItems() async {
    final allItems = await getAllItems();
    return allItems.where((item) => item.isDueSoon).toList();
  }

  Future<List<AgendaItem>> searchItems(String query) async {
    final allItems = await getAllItems();
    final lowercaseQuery = query.toLowerCase();

    return allItems.where((item) {
      return item.title.toLowerCase().contains(lowercaseQuery) ||
          item.description?.toLowerCase().contains(lowercaseQuery) == true ||
          item.location?.toLowerCase().contains(lowercaseQuery) == true ||
          item.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Integração com base de dados
  Future<void> syncWithDatabase() async {
    await _ensureInitialized();

    // Buscar itens da base de dados que têm deadline
    // Esta é uma implementação placeholder - será expandida quando tivermos acesso ao DatabaseProvider
    try {
      // Aqui você pode integrar com o DatabaseProvider para buscar itens com deadline
      // Por enquanto, vamos apenas simular
    } catch (e) {
    }
  }

  Future<AgendaItem?> createFromDatabaseItem(
      Map<String, dynamic> dbItem, String databaseName) async {
    try {
      // Verificar se o item já existe na agenda
      final existingItems = await getAllItems();
      final existingItem = existingItems.firstWhere(
        (item) =>
            item.databaseItemId == dbItem['id'] &&
            item.databaseName == databaseName,
        orElse: () => throw Exception('Item não encontrado'),
      );

      return existingItem;
    } catch (e) {
      // Criar novo item na agenda baseado no item da base de dados
      final deadline = dbItem['deadline'] != null
          ? DateTime.parse(dbItem['deadline'])
          : null;

      if (deadline == null) return null; // Só criar se tiver deadline

      final status = _mapDatabaseStatusToTaskStatus(dbItem['status']);

      final agendaItem = AgendaItem(
        id: '', // Será gerado pelo createItem
        title: dbItem['title'] ?? 'Item sem título',
        description: dbItem['description'],
        deadline: deadline,
        type: AgendaItemType.task,
        status: status,
        priority: _mapDatabasePriorityToPriority(dbItem['priority']),
        databaseItemId: dbItem['id'],
        databaseName: databaseName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await createItem(agendaItem);
      return agendaItem.copyWith(id: id);
    }
  }

  /// Busca todos os deadlines da base de dados e converte em AgendaItem
  Future<List<AgendaItem>> getDatabaseDeadlines() async {
    final List<AgendaItem> items = [];
    final databaseService = DatabaseService();
    await databaseService.initialize();
    for (final table in databaseService.tables) {
      // Buscar deadlineColumn
      DatabaseColumn? deadlineColumn;
      for (final col in table.columns) {
        if (col.type == ColumnType.deadline) {
          deadlineColumn = col;
          break;
        }
      }
      // Buscar statusColumn
      DatabaseColumn? statusColumn;
      for (final col in table.columns) {
        if (col.type == ColumnType.status) {
          statusColumn = col;
          break;
        }
      }
      // Buscar titleColumn
      DatabaseColumn? titleColumn;
      for (final col in table.columns) {
        if (col.isPrimary) {
          titleColumn = col;
          break;
        }
      }
      if (titleColumn == null) {
        for (final col in table.columns) {
          if (col.type == ColumnType.text) {
            titleColumn = col;
            break;
          }
        }
      }
      if (titleColumn == null && table.columns.isNotEmpty) {
        titleColumn = table.columns.first;
      }
      if (deadlineColumn == null || titleColumn == null) continue;
      for (final row in table.rows) {
        final deadlineCell = row.getCell(deadlineColumn.id);
        if (deadlineCell == null || deadlineCell.value == null) continue;
        final statusCell =
            statusColumn != null ? row.getCell(statusColumn.id) : null;
        final statusValue = statusCell?.value;
        // Mapear status da base para TaskStatus
        final TaskStatus? status = _mapDatabaseStatusToTaskStatus(statusValue);
        items.add(
          AgendaItem(
            id: 'db_${table.name}_${row.id}', // ID único para itens da base de dados
            title:
                row.getCell(titleColumn.id)?.value?.toString() ?? 'Sem título',
            description: row.getCell(titleColumn.id)?.value?.toString(),
            deadline: deadlineCell.value is DateTime
                ? deadlineCell.value
                : DateTime.tryParse(deadlineCell.value.toString()),
            type: AgendaItemType.task,
            status: status,
            priority:
                Priority.medium, // pode mapear se houver coluna de prioridade
            databaseItemId: row.id,
            databaseName: table.name,
            createdAt: row.createdAt,
            updatedAt: row.lastModified,
          ),
        );
      }
    }
    return items;
  }

  TaskStatus? _mapDatabaseStatusToTaskStatus(dynamic dbStatus) {
    if (dbStatus == null) return null;
    final value = dbStatus.toString().toLowerCase();
    if (value == 'todo' || value == 'a fazer') return TaskStatus.todo;
    if (value == 'in_progress' || value == 'em progresso')
      return TaskStatus.inProgress;
    if (value == 'done' || value == 'concluído' || value == 'concluido')
      return TaskStatus.done;
    if (value == 'cancelled' || value == 'cancelada' || value == 'cancelado')
      return TaskStatus.cancelled;
    return null;
  }

  Priority _mapDatabasePriorityToPriority(String? dbPriority) {
    switch (dbPriority?.toLowerCase()) {
      case 'low':
      case 'baixa':
        return Priority.low;
      case 'high':
      case 'alta':
        return Priority.high;
      case 'urgent':
      case 'urgente':
        return Priority.urgent;
      default:
        return Priority.medium;
    }
  }

  // Estatísticas
  Future<Map<String, dynamic>> getAgendaStats() async {
    final allItems = await getAllItems();

    final total = allItems.length;
    final events =
        allItems.where((item) => item.type == AgendaItemType.event).length;
    final tasks =
        allItems.where((item) => item.type == AgendaItemType.task).length;
    final meetings =
        allItems.where((item) => item.type == AgendaItemType.meeting).length;
    final reminders =
        allItems.where((item) => item.type == AgendaItemType.reminder).length;

    final overdue = allItems.where((item) => item.isOverdue).length;
    final dueToday = allItems.where((item) => item.isDueToday).length;
    final dueSoon = allItems.where((item) => item.isDueSoon).length;

    final completed = allItems.where((item) => item.isCompleted).length;
    final fromDatabase = allItems.where((item) => item.isFromDatabase).length;

    return {
      'total': total,
      'events': events,
      'tasks': tasks,
      'meetings': meetings,
      'reminders': reminders,
      'overdue': overdue,
      'dueToday': dueToday,
      'dueSoon': dueSoon,
      'completed': completed,
      'fromDatabase': fromDatabase,
    };
  }

  // Utilitários
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
}
