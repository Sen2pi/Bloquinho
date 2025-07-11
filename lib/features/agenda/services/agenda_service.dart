import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/agenda_item.dart';
import '../../../shared/providers/database_provider.dart';

class AgendaService {
  static const String _boxName = 'agenda_items';

  static final AgendaService _instance = AgendaService._internal();
  factory AgendaService() => _instance;
  AgendaService._internal();

  late Box<dynamic> _agendaBox;
  final Uuid _uuid = const Uuid();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _agendaBox = await Hive.openBox(_boxName);
      _isInitialized = true;
    } catch (e) {
      throw Exception('Erro ao inicializar AgendaService: $e');
    }
  }

  // CRUD Operations
  Future<List<AgendaItem>> getAllItems() async {
    await _ensureInitialized();
    final List<AgendaItem> items = [];

    for (final key in _agendaBox.keys) {
      final data = _agendaBox.get(key);
      if (data != null) {
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
    final data = _agendaBox.get(id);
    if (data != null) {
      return AgendaItem.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  Future<String> createItem(AgendaItem item) async {
    await _ensureInitialized();

    final now = DateTime.now();
    final newItem = item.copyWith(
      id: _uuid.v4(),
      createdAt: now,
      updatedAt: now,
    );

    await _agendaBox.put(newItem.id, newItem.toJson());
    return newItem.id;
  }

  Future<void> updateItem(AgendaItem item) async {
    await _ensureInitialized();

    final updatedItem = item.copyWith(updatedAt: DateTime.now());
    await _agendaBox.put(updatedItem.id, updatedItem.toJson());
  }

  Future<void> deleteItem(String id) async {
    await _ensureInitialized();
    await _agendaBox.delete(id);
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
      print('Sincronizando agenda com base de dados...');
    } catch (e) {
      print('Erro ao sincronizar com base de dados: $e');
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

  TaskStatus _mapDatabaseStatusToTaskStatus(String? dbStatus) {
    switch (dbStatus?.toLowerCase()) {
      case 'todo':
      case 'a fazer':
        return TaskStatus.todo;
      case 'inprogress':
      case 'em progresso':
        return TaskStatus.inProgress;
      case 'done':
      case 'concluída':
        return TaskStatus.done;
      case 'cancelled':
      case 'cancelada':
        return TaskStatus.cancelled;
      default:
        return TaskStatus.todo;
    }
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

  Future<void> clearAllData() async {
    await _ensureInitialized();
    await _agendaBox.clear();
  }

  Future<void> close() async {
    if (_isInitialized) {
      await _agendaBox.close();
      _isInitialized = false;
    }
  }
}
