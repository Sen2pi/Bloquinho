import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../models/agenda_item.dart';
import '../services/agenda_service.dart';

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

  AgendaNotifier(this._agendaService) : super(const AgendaState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final items = await _agendaService.getAllItems();
      final stats = await _agendaService.getAgendaStats();

      state = state.copyWith(
        items: items,
        stats: stats,
        isLoading: false,
      );

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
    final item = state.items.firstWhere((item) => item.id == id);
    final updatedItem = item.copyWith(status: status);
    await updateItem(updatedItem);
  }

  // Sincronização com base de dados
  Future<void> syncWithDatabase() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _agendaService.syncWithDatabase();

      // Recarregar dados
      await _loadInitialData();
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
  final service = ref.watch(agendaServiceProvider);
  return AgendaNotifier(service);
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
  return ref.watch(agendaProvider.notifier).todoItems;
});
final inProgressItemsProvider = Provider<List<AgendaItem>>((ref) {
  return ref.watch(agendaProvider.notifier).inProgressItems;
});
final doneItemsProvider = Provider<List<AgendaItem>>((ref) {
  return ref.watch(agendaProvider.notifier).doneItems;
});
final cancelledItemsProvider = Provider<List<AgendaItem>>((ref) {
  return ref.watch(agendaProvider.notifier).cancelledItems;
});
