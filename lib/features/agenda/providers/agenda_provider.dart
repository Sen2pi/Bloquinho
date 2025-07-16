/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../models/agenda_item.dart';
import '../services/agenda_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/models/database_models.dart';
import 'package:flutter/foundation.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/workspace.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../shared/providers/workspace_provider.dart';

// Estado da agenda
class AgendaState extends Equatable {
  final List<AgendaItem> items;
  final List<AgendaItem> filteredItems;
  final String searchQuery;
  final AgendaItemType? selectedType;
  final TaskStatus? selectedStatus;
  final DateTime? selectedDate;
  final bool showOverdueOnly;
  final bool showDueTodayOnly;
  final bool showDueSoonOnly;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> stats;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String currentView; // 'calendar', 'kanban', 'list'

  const AgendaState({
    this.items = const [],
    this.filteredItems = const [],
    this.searchQuery = '',
    this.selectedType,
    this.selectedStatus,
    this.selectedDate,
    this.showOverdueOnly = false,
    this.showDueTodayOnly = false,
    this.showDueSoonOnly = false,
    this.isLoading = false,
    this.error,
    this.stats = const {},
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.currentView = 'calendar',
  });

  AgendaState copyWith({
    List<AgendaItem>? items,
    List<AgendaItem>? filteredItems,
    String? searchQuery,
    AgendaItemType? selectedType,
    TaskStatus? selectedStatus,
    DateTime? selectedDate,
    bool? showOverdueOnly,
    bool? showDueTodayOnly,
    bool? showDueSoonOnly,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? stats,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? currentView,
  }) {
    return AgendaState(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedDate: selectedDate ?? this.selectedDate,
      showOverdueOnly: showOverdueOnly ?? this.showOverdueOnly,
      showDueTodayOnly: showDueTodayOnly ?? this.showDueTodayOnly,
      showDueSoonOnly: showDueSoonOnly ?? this.showDueSoonOnly,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      currentView: currentView ?? this.currentView,
    );
  }

  @override
  List<Object?> get props => [
        items,
        filteredItems,
        searchQuery,
        selectedType,
        selectedStatus,
        selectedDate,
        showOverdueOnly,
        showDueTodayOnly,
        showDueSoonOnly,
        isLoading,
        error,
        stats,
        isCreating,
        isUpdating,
        isDeleting,
        currentView,
      ];
}

// Notifier para gerenciar o estado
class AgendaNotifier extends StateNotifier<AgendaState> {
  final AgendaService _agendaService;
  String? _currentWorkspaceId;
  String? _currentProfileName;
  bool _isInitialized = false;

  AgendaNotifier(this._agendaService) : super(const AgendaState()) {
    _loadInitialData();
  }

  /// Definir contexto do workspace
  Future<void> setContext(String profileName, String workspaceId) async {
    await _agendaService.setContext(profileName, workspaceId);
    _currentProfileName = profileName;
    _currentWorkspaceId = workspaceId;
    await _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Verificar se temos contexto definido
      if (_currentProfileName != null && _currentWorkspaceId != null) {
        await _agendaService.setContext(
            _currentProfileName!, _currentWorkspaceId!);
      }

      // Carregar itens da agenda
      final agendaItems = await _agendaService.getAllItems();

      // Carregar deadlines da base de dados
      final databaseDeadlines = await _agendaService.getDatabaseDeadlines();

      // Unificar itens (agenda + base de dados)
      final allItems = [...agendaItems, ...databaseDeadlines];

      // --- NOVO: Cancelar automaticamente eventos vencidos e não concluídos ---
      final now = DateTime.now();
      final List<AgendaItem> atualizados = [];
      for (final item in allItems) {
        if (item.deadline != null &&
            item.deadline!.isBefore(now) &&
            item.status != TaskStatus.done &&
            item.status != TaskStatus.cancelled) {
          final cancelado = item.copyWith(status: TaskStatus.cancelled);
          await _agendaService.updateItem(cancelado);
          atualizados.add(cancelado);
        } else {
          atualizados.add(item);
        }
      }

      final stats = await _agendaService.getAgendaStats();

      state = state.copyWith(
        items: atualizados,
        stats: stats,
        isLoading: false,
      );

      _isInitialized = true;
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar dados: $e',
      );
    }
  }

  void _applyFilters() {
    List<AgendaItem> filtered = state.items;

    // Aplicar filtro de busca
    if (state.searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final query = state.searchQuery.toLowerCase();
        return item.title.toLowerCase().contains(query) ||
            item.description?.toLowerCase().contains(query) == true ||
            item.location?.toLowerCase().contains(query) == true ||
            item.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    // Aplicar filtro de tipo
    if (state.selectedType != null) {
      filtered =
          filtered.where((item) => item.type == state.selectedType).toList();
    }

    // Aplicar filtro de status
    if (state.selectedStatus != null) {
      filtered = filtered
          .where((item) => item.status == state.selectedStatus)
          .toList();
    }

    // Aplicar filtro de data
    if (state.selectedDate != null) {
      filtered = filtered.where((item) {
        final itemDate = item.startDate ?? item.deadline;
        if (itemDate == null) return false;

        final selectedDate = state.selectedDate!;
        final startOfDay =
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        return itemDate.isAfter(startOfDay) && itemDate.isBefore(endOfDay);
      }).toList();
    }

    // Aplicar filtro de atrasados
    if (state.showOverdueOnly) {
      filtered = filtered.where((item) => item.isOverdue).toList();
    }

    // Aplicar filtro de vencimento hoje
    if (state.showDueTodayOnly) {
      filtered = filtered.where((item) => item.isDueToday).toList();
    }

    // Aplicar filtro de vencimento em breve
    if (state.showDueSoonOnly) {
      filtered = filtered.where((item) => item.isDueSoon).toList();
    }

    state = state.copyWith(filteredItems: filtered);
  }

  // Ações do usuário
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void setSelectedType(AgendaItemType? type) {
    state = state.copyWith(selectedType: type);
    _applyFilters();
  }

  void setSelectedStatus(TaskStatus? status) {
    state = state.copyWith(selectedStatus: status);
    _applyFilters();
  }

  void setSelectedDate(DateTime? date) {
    state = state.copyWith(selectedDate: date);
    _applyFilters();
  }

  void toggleOverdueOnly() {
    state = state.copyWith(showOverdueOnly: !state.showOverdueOnly);
    _applyFilters();
  }

  void toggleDueTodayOnly() {
    state = state.copyWith(showDueTodayOnly: !state.showDueTodayOnly);
    _applyFilters();
  }

  void toggleDueSoonOnly() {
    state = state.copyWith(showDueSoonOnly: !state.showDueSoonOnly);
    _applyFilters();
  }

  void setCurrentView(String view) {
    state = state.copyWith(currentView: view);
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedType: null,
      selectedStatus: null,
      selectedDate: null,
      showOverdueOnly: false,
      showDueTodayOnly: false,
      showDueSoonOnly: false,
    );
    _applyFilters();
  }

  // CRUD Operations
  Future<void> createItem(AgendaItem item) async {
    try {
      state = state.copyWith(isCreating: true, error: null);

      final id = await _agendaService.createItem(item);
      final newItem = item.copyWith(id: id);

      final updatedItems = [newItem, ...state.items];
      state = state.copyWith(
        items: updatedItems,
        isCreating: false,
      );

      _applyFilters();
      await _updateStats();
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Erro ao criar item: $e',
      );
    }
  }

  Future<void> updateItem(AgendaItem item) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      await _agendaService.updateItem(item);

      final updatedItems =
          state.items.map((i) => i.id == item.id ? item : i).toList();

      state = state.copyWith(
        items: updatedItems,
        isUpdating: false,
      );

      _applyFilters();
      await _updateStats();
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Erro ao atualizar item: $e',
      );
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      state = state.copyWith(isDeleting: true, error: null);

      await _agendaService.deleteItem(id);

      final updatedItems = state.items.where((item) => item.id != id).toList();
      state = state.copyWith(
        items: updatedItems,
        isDeleting: false,
      );

      _applyFilters();
      await _updateStats();
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Erro ao deletar item: $e',
      );
    }
  }

  Future<void> toggleItemCompletion(String id) async {
    final item = state.items.firstWhere((item) => item.id == id);
    final updatedItem = item.copyWith(
      isCompleted: !item.isCompleted,
      completedAt: !item.isCompleted ? DateTime.now() : null,
    );
    await updateItem(updatedItem);
  }

  Future<void> updateItemStatus(String id, TaskStatus status) async {
    final itemIndex = state.items.indexWhere((item) => item.id == id);
    if (itemIndex == -1) return;
    
    final item = state.items[itemIndex];
    final updatedItem = item.copyWith(status: status);

    // Atualizar imediatamente no state para UI responsiva
    final updatedItems = List<AgendaItem>.from(state.items);
    updatedItems[itemIndex] = updatedItem;
    state = state.copyWith(items: updatedItems);
    _applyFilters();

    // Se o item é da base de dados, atualizar lá também
    if (item.databaseItemId != null && item.databaseName != null) {
      await _updateDatabaseItemStatus(
          item.databaseItemId!, item.databaseName!, status);
    }

    // Persistir mudanças no serviço
    await _agendaService.updateItem(updatedItem);
    await _updateStats();
  }

  /// Atualiza o status de um item na base de dados
  Future<void> _updateDatabaseItemStatus(
      String databaseItemId, String databaseName, TaskStatus status) async {
    try {
      final databaseService = DatabaseService();
      await databaseService.initialize();

      // Encontrar a tabela
      DatabaseTable? table;
      for (final t in databaseService.tables) {
        if (t.name == databaseName) {
          table = t;
          break;
        }
      }

      if (table == null) return;

      // Encontrar a coluna de status
      DatabaseColumn? statusColumn;
      for (final col in table.columns) {
        if (col.type == ColumnType.status) {
          statusColumn = col;
          break;
        }
      }

      if (statusColumn == null) return;

      // Encontrar a linha
      final row = table.getRow(databaseItemId);
      if (row == null) return;

      // Mapear TaskStatus para valor da base de dados
      final statusValue = _mapTaskStatusToDatabaseStatus(status);

      // Atualizar a célula
      final updatedRow = row.setCell(statusColumn.id, statusValue);
      final updatedTable = table.updateRow(updatedRow);

      // Salvar na base de dados
      await databaseService.updateTable(updatedTable);
    } catch (e) {
      // Erro ao atualizar status na base de dados
    }
  }

  /// Mapeia TaskStatus para valor da base de dados
  String _mapTaskStatusToDatabaseStatus(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'Por fazer';
      case TaskStatus.inProgress:
        return 'Em progresso';
      case TaskStatus.done:
        return 'Concluído';
      case TaskStatus.cancelled:
        return 'Cancelado';
    }
  }

  // Sincronização com base de dados
  Future<void> syncWithDatabase() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Buscar deadlines da base de dados
      final databaseDeadlines = await _agendaService.getDatabaseDeadlines();

      // Filtrar itens que não são da base de dados (manter apenas itens nativos da agenda)
      final nativeItems =
          state.items.where((item) => item.databaseItemId == null).toList();

      // Unificar itens nativos + deadlines da base de dados
      final allItems = [...nativeItems, ...databaseDeadlines];

      state = state.copyWith(
        items: allItems,
        isLoading: false,
      );

      _applyFilters();
      await _updateStats();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao sincronizar: $e',
      );
    }
  }

  // Utilitários
  Future<void> _updateStats() async {
    try {
      final stats = await _agendaService.getAgendaStats();
      state = state.copyWith(stats: stats);
    } catch (e) {
      // Ignorar erros de estatísticas
    }
  }

  Future<void> refresh() async {
    await _loadInitialData();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void replaceAll(List<AgendaItem> items) {
    state = state.copyWith(items: items);
    _applyFilters();
  }

  // Getters para diferentes listas Kanban
  List<AgendaItem> get todoItems =>
      state.items.where((item) => item.status == TaskStatus.todo).toList();
  List<AgendaItem> get inProgressItems => state.items
      .where((item) => item.status == TaskStatus.inProgress)
      .toList();
  List<AgendaItem> get doneItems =>
      state.items.where((item) => item.status == TaskStatus.done).toList();
  List<AgendaItem> get cancelledItems =>
      state.items.where((item) => item.status == TaskStatus.cancelled).toList();
}

// Providers
final agendaServiceProvider = Provider<AgendaService>((ref) {
  return AgendaService();
});

final agendaProvider =
    StateNotifierProvider<AgendaNotifier, AgendaState>((ref) {
  final agendaService = ref.watch(agendaServiceProvider);
  final notifier = AgendaNotifier(agendaService);

  // Inicializa contexto na primeira criação do provider
  final profile = ref.read(currentProfileProvider);
  final workspace = ref.read(currentWorkspaceProvider);
  final defaultWorkspaceId = ref.read(agendaWorkspaceProvider);
  if (profile != null) {
    final workspaceId = workspace?.id ?? defaultWorkspaceId;
    notifier.setContext(profile.name, workspaceId);
  }

  // Observa mudanças de profile/workspace e atualiza contexto
  ref.listen<UserProfile?>(currentProfileProvider, (prevProfile, currProfile) {
    final workspace = ref.read(currentWorkspaceProvider);
    final defaultWorkspaceId = ref.read(agendaWorkspaceProvider);
    if (currProfile != null) {
      final workspaceId = workspace?.id ?? defaultWorkspaceId;
      notifier.setContext(currProfile.name, workspaceId);
    }
  });

  // Observa mudanças de workspace
  ref.listen<Workspace?>(currentWorkspaceProvider,
      (prevWorkspace, currWorkspace) {
    final profile = ref.read(currentProfileProvider);
    final defaultWorkspaceId = ref.read(agendaWorkspaceProvider);
    if (profile != null) {
      final workspaceId = currWorkspace?.id ?? defaultWorkspaceId;
      notifier.setContext(profile.name, workspaceId);
    }
  });

  return notifier;
});

// Providers derivados
final agendaItemsProvider = Provider<List<AgendaItem>>((ref) {
  return ref.watch(agendaProvider).items;
});

final filteredAgendaItemsProvider = Provider<List<AgendaItem>>((ref) {
  return ref.watch(agendaProvider).filteredItems;
});

final agendaStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(agendaProvider).stats;
});

final agendaIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(agendaProvider).isLoading;
});

final agendaErrorProvider = Provider<String?>((ref) {
  return ref.watch(agendaProvider).error;
});

final agendaIsCreatingProvider = Provider<bool>((ref) {
  return ref.watch(agendaProvider).isCreating;
});

final agendaIsUpdatingProvider = Provider<bool>((ref) {
  return ref.watch(agendaProvider).isUpdating;
});

final agendaIsDeletingProvider = Provider<bool>((ref) {
  return ref.watch(agendaProvider).isDeleting;
});

final agendaCurrentViewProvider = Provider<String>((ref) {
  return ref.watch(agendaProvider).currentView;
});

// Providers para Kanban
final todoItemsProvider = Provider<List<AgendaItem>>((ref) {
  final state = ref.watch(agendaProvider);
  return state.items.where((item) => item.status == TaskStatus.todo).toList();
});
final inProgressItemsProvider = Provider<List<AgendaItem>>((ref) {
  final state = ref.watch(agendaProvider);
  return state.items.where((item) => item.status == TaskStatus.inProgress).toList();
});
final doneItemsProvider = Provider<List<AgendaItem>>((ref) {
  final state = ref.watch(agendaProvider);
  return state.items.where((item) => item.status == TaskStatus.done).toList();
});
final cancelledItemsProvider = Provider<List<AgendaItem>>((ref) {
  final state = ref.watch(agendaProvider);
  return state.items.where((item) => item.status == TaskStatus.cancelled).toList();
});

// Provider para inicializar contexto do workspace
final agendaContextProvider = Provider<void>((ref) {
  final notifier = ref.read(agendaProvider.notifier);
  final profile = ref.watch(currentProfileProvider);
  final workspace = ref.watch(currentWorkspaceProvider);
  final defaultWorkspaceId = ref.read(agendaWorkspaceProvider);

  if (profile != null) {
    final workspaceId = workspace?.id ?? defaultWorkspaceId;
    // Definir contexto de forma assíncrona
    Future.microtask(() async {
      await notifier.setContext(profile.name, workspaceId);
    });
  }
});

// Provider para chronologia de eventos passados
final pastEventsProvider = Provider<List<AgendaItem>>((ref) {
  final state = ref.watch(agendaProvider);
  final now = DateTime.now();
  return state.items.where((item) {
    if (item.deadline == null) return false;
    final isPast = item.deadline!.isBefore(now);
    final isDoneOrCancelled = item.status == TaskStatus.done || item.status == TaskStatus.cancelled;
    return isPast && isDoneOrCancelled;
  }).toList();
});
