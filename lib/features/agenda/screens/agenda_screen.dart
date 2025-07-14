/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/agenda_provider.dart';
import '../models/agenda_item.dart';
import '../widgets/agenda_calendar_view.dart';
import '../widgets/agenda_kanban_view.dart';
import '../widgets/agenda_list_view.dart';
import '../widgets/add_agenda_item_dialog.dart';
import '../widgets/agenda_stats_card.dart';
import '../widgets/agenda_dashboard.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(agendaProvider.notifier).setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final currentView = ref.watch(agendaCurrentViewProvider);
    final stats = ref.watch(agendaStatsProvider);
    final isLoading = ref.watch(agendaIsLoadingProvider);
    final error = ref.watch(agendaErrorProvider);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        foregroundColor:
            isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: strings.back,
        ),
        title: Row(
          children: [
            Icon(
              Icons.calendar_month,
              size: 24,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(strings.agenda),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showSyncDialog(context, strings),
            icon: Icon(Icons.sync),
            tooltip: strings.syncWithDatabase,
          ),
          IconButton(
            onPressed: () => _showStatsDialog(context, strings),
            icon: Icon(Icons.analytics),
            tooltip: strings.statistics,
          ),
        ],
      ),
      body: Column(
        children: [
          // Dashboard
          const AgendaDashboard(),

          // Filtros
          _buildFilters(isDarkMode, strings),

          // Conteúdo principal
          Expanded(
            child: _buildContent(
                isDarkMode, currentView, isLoading, error, strings),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(isDarkMode, strings),
    );
  }

  Widget _buildHeader(
      bool isDarkMode, Map<String, dynamic> stats, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                size: 32,
                color: AppColors.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.agenda,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                    ),
                    Text(
                      '${stats['total'] ?? 0} ${strings.itemsOnAgenda}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showSyncDialog(context, strings),
                icon: Icon(Icons.sync),
                tooltip: strings.syncWithDatabase,
              ),
              IconButton(
                onPressed: () => _showStatsDialog(context, strings),
                icon: Icon(Icons.analytics),
                tooltip: strings.statistics,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Barra de pesquisa
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: strings.searchInAgenda,
              prefixIcon: Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                      },
                      icon: Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color:
                      isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              filled: true,
              fillColor:
                  isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
            ),
            textInputAction: TextInputAction.search,
            enableInteractiveSelection: true,
            autocorrect: false,
            enableSuggestions: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isDarkMode, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Botões de vista
            _buildViewButton(
                'calendar', strings.calendar, Icons.calendar_month, isDarkMode),
            const SizedBox(width: 8),
            _buildViewButton(
                'kanban', strings.kanban, Icons.view_column, isDarkMode),
            const SizedBox(width: 8),
            _buildViewButton('list', strings.list, Icons.list, isDarkMode),

            const SizedBox(width: 16),

            // Filtros
            _buildFilterChip(
                strings.overdue, Icons.warning, Colors.red, isDarkMode, () {
              ref.read(agendaProvider.notifier).toggleOverdueOnly();
            }),
            const SizedBox(width: 8),
            _buildFilterChip(
                strings.today, Icons.today, Colors.blue, isDarkMode, () {
              ref.read(agendaProvider.notifier).toggleDueTodayOnly();
            }),
            const SizedBox(width: 8),
            _buildFilterChip(
                strings.dueSoon, Icons.schedule, Colors.orange, isDarkMode, () {
              ref.read(agendaProvider.notifier).toggleDueSoonOnly();
            }),
            const SizedBox(width: 8),
            _buildFilterChip(
                strings.clear, Icons.clear, Colors.grey, isDarkMode, () {
              ref.read(agendaProvider.notifier).clearFilters();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildViewButton(
      String view, String label, IconData icon, bool isDarkMode) {
    final currentView = ref.watch(agendaCurrentViewProvider);
    final isSelected = currentView == view;

    return InkWell(
      onTap: () => ref.read(agendaProvider.notifier).setCurrentView(view),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDarkMode ? AppColors.darkBorder : AppColors.lightBorder),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected ? AppColors.primary : Colors.grey[600],
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, Color color,
      bool isDarkMode, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDarkMode, String currentView, bool isLoading,
      String? error, AppStrings strings) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              strings.errorLoadingAgenda,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(agendaProvider.notifier).refresh(),
              child: Text(strings.tryAgain),
            ),
          ],
        ),
      );
    }

    switch (currentView) {
      case 'calendar':
        return AgendaCalendarView(
          focusedDay: _focusedDay,
          selectedDay: _selectedDay,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            ref.read(agendaProvider.notifier).setSelectedDate(selectedDay);
          },
        );
      case 'kanban':
        return const AgendaKanbanView();
      case 'list':
        return const AgendaListView();
      default:
        return const AgendaCalendarView(
          focusedDay: null,
          selectedDay: null,
          onDaySelected: null,
        );
    }
  }

  Widget _buildFloatingActionButton(bool isDarkMode, AppStrings strings) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddItemDialog(context),
      icon: Icon(Icons.add),
      label: Text(strings.newItem),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    );
  }

  // Diálogos e ações
  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddAgendaItemDialog(),
    );
  }

  void _showSyncDialog(BuildContext context, AppStrings strings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.syncWithDatabase),
        content: Text(
          strings.syncWithDatabaseDescription,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(agendaProvider.notifier).syncWithDatabase();
            },
            child: Text(strings.syncButton),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog(BuildContext context, AppStrings strings) {
    final stats = ref.watch(agendaStatsProvider);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                strings.agendaStats,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              AgendaStatsCard(stats: stats),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(strings.closeButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
