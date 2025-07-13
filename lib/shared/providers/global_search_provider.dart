import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import '../../features/passwords/models/password_entry.dart';
import '../../features/passwords/providers/password_provider.dart';
import '../../features/agenda/models/agenda_item.dart';
import '../../features/agenda/providers/agenda_provider.dart';
import '../../features/bloquinho/models/page_model.dart';
import '../../features/bloquinho/providers/pages_provider.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/providers/user_profile_provider.dart';
import '../../shared/providers/workspace_provider.dart';
import '../../core/models/database_models.dart';
import 'package:flutter/foundation.dart';

/// Resultado de pesquisa global
class SearchResult extends Equatable {
  final String id;
  final String title;
  final String? subtitle;
  final String? description;
  final SearchResultType type;
  final String? icon;
  final Map<String, dynamic>? metadata;
  final String? navigationPath;

  const SearchResult({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    required this.type,
    this.icon,
    this.metadata,
    this.navigationPath,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        description,
        type,
        icon,
        metadata,
        navigationPath,
      ];
}

/// Tipos de resultados de pesquisa
enum SearchResultType {
  password,
  database,
  agenda,
  page,
}

/// Estado da pesquisa global
class GlobalSearchState extends Equatable {
  final List<SearchResult> results;
  final String query;
  final bool isLoading;
  final String? error;
  final bool isSearching;
  final bool showLoadingIndicator;

  const GlobalSearchState({
    this.results = const [],
    this.query = '',
    this.isLoading = false,
    this.error,
    this.isSearching = false,
    this.showLoadingIndicator = false,
  });

  GlobalSearchState copyWith({
    List<SearchResult>? results,
    String? query,
    bool? isLoading,
    String? error,
    bool? isSearching,
    bool? showLoadingIndicator,
    bool clearError = false,
  }) {
    return GlobalSearchState(
      results: results ?? this.results,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSearching: isSearching ?? this.isSearching,
      showLoadingIndicator: showLoadingIndicator ?? this.showLoadingIndicator,
    );
  }

  @override
  List<Object?> get props =>
      [results, query, isLoading, error, isSearching, showLoadingIndicator];
}

/// Notifier para pesquisa global
class GlobalSearchNotifier extends StateNotifier<GlobalSearchState> {
  final Ref _ref;
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 300);
  static const int _minQueryLength = 3;

  GlobalSearchNotifier(this._ref) : super(const GlobalSearchState());

  /// Realizar pesquisa global com debounce
  void search(String query) {
    // Cancelar timer anterior se existir
    _debounceTimer?.cancel();

    // Limpar pesquisa se query estiver vazia
    if (query.trim().isEmpty) {
      state = state.copyWith(
        results: [],
        query: '',
        isSearching: false,
        showLoadingIndicator: false,
      );
      return;
    }

    // Atualizar query imediatamente
    state = state.copyWith(
      query: query,
      error: null,
    );

    // Verificar se tem pelo menos 3 caracteres
    if (query.trim().length < _minQueryLength) {
      state = state.copyWith(
        results: [],
        isSearching: false,
        showLoadingIndicator: false,
      );
      return;
    }

    // Mostrar indicador de carregamento imediatamente
    state = state.copyWith(
      showLoadingIndicator: true,
      isSearching: true,
    );

    // Configurar debounce
    _debounceTimer = Timer(_debounceDelay, () {
      _performSearch(query.trim());
    });
  }

  /// Realizar a pesquisa efetiva
  Future<void> _performSearch(String query) async {
    if (query.length < _minQueryLength) {
      state = state.copyWith(
        results: [],
        isSearching: false,
        showLoadingIndicator: false,
      );
      return;
    }

    try {
      final results = <SearchResult>[];

      // Verificar se temos contexto válido antes de pesquisar
      final currentProfile = _ref.read(currentProfileProvider);
      final currentWorkspace = _ref.read(currentWorkspaceProvider);

      if (currentProfile == null || currentWorkspace == null) {
        debugPrint('🔍 GlobalSearch: Profile ou Workspace não disponível');
        state = state.copyWith(
          results: [],
          isSearching: false,
          showLoadingIndicator: false,
        );
        return;
      }

      debugPrint('🔍 GlobalSearch: Pesquisando em $query');
      debugPrint(
          '🔍 GlobalSearch: Contexto - ${currentProfile.name} / ${currentWorkspace.name}');

      // Pesquisar em passwords
      final passwordResults = await _searchInPasswords(query);
      results.addAll(passwordResults);

      // Pesquisar na base de dados
      final databaseResults = await _searchInDatabase(query);
      results.addAll(databaseResults);

      // Pesquisar na agenda
      final agendaResults = await _searchInAgenda(query);
      results.addAll(agendaResults);

      // Pesquisar em páginas
      final pageResults = await _searchInPages(query);
      results.addAll(pageResults);

      debugPrint('🔍 GlobalSearch: ${results.length} resultados encontrados');

      state = state.copyWith(
        results: results,
        isSearching: false,
        showLoadingIndicator: false,
      );
    } catch (e) {
      debugPrint('🔍 GlobalSearch: Erro na pesquisa: $e');
      state = state.copyWith(
        error: 'Erro na pesquisa: $e',
        isSearching: false,
        showLoadingIndicator: false,
      );
    }
  }

  /// Pesquisar em passwords
  Future<List<SearchResult>> _searchInPasswords(String query) async {
    try {
      final currentProfile = _ref.read(currentProfileProvider);
      final currentWorkspace = _ref.read(currentWorkspaceProvider);

      if (currentProfile == null || currentWorkspace == null) {
        debugPrint('🔍 GlobalSearch: Contexto não disponível para passwords');
        return [];
      }

      final passwordState = _ref.read(passwordProvider);
      final passwords = passwordState.filteredPasswords;

      debugPrint(
          '🔍 GlobalSearch: Pesquisando em ${passwords.length} passwords');

      final results = <SearchResult>[];
      final lowerQuery = query.toLowerCase();

      for (final password in passwords) {
        if (_matchesPassword(password, lowerQuery)) {
          results.add(SearchResult(
            id: password.id,
            title: password.title,
            subtitle: password.username,
            description: password.website,
            type: SearchResultType.password,
            icon: '🔐',
            metadata: {
              'category': password.category,
              'strength': password.strength.toString(),
            },
            navigationPath: '/workspace/passwords',
          ));
        }
      }

      debugPrint('🔍 GlobalSearch: ${results.length} passwords encontradas');
      return results;
    } catch (e) {
      debugPrint('🔍 GlobalSearch: Erro ao pesquisar passwords: $e');
      return [];
    }
  }

  /// Verificar se password corresponde à pesquisa
  bool _matchesPassword(PasswordEntry password, String query) {
    return password.title.toLowerCase().contains(query) ||
        password.username.toLowerCase().contains(query) ||
        (password.website?.toLowerCase().contains(query) ?? false) ||
        (password.category?.toLowerCase().contains(query) ?? false) ||
        (password.notes?.toLowerCase().contains(query) ?? false);
  }

  /// Pesquisar na base de dados
  Future<List<SearchResult>> _searchInDatabase(String query) async {
    try {
      final currentProfile = _ref.read(currentProfileProvider);
      final currentWorkspace = _ref.read(currentWorkspaceProvider);

      if (currentProfile == null || currentWorkspace == null) {
        debugPrint('🔍 GlobalSearch: Contexto não disponível para database');
        return [];
      }

      final databaseState = _ref.read(databaseNotifierProvider);
      final tables = databaseState.value ?? [];

      debugPrint('🔍 GlobalSearch: Pesquisando em ${tables.length} tabelas');

      final results = <SearchResult>[];
      final lowerQuery = query.toLowerCase();

      for (final table in tables) {
        if (_matchesDatabaseTable(table, lowerQuery)) {
          results.add(SearchResult(
            id: table.id,
            title: table.name,
            subtitle: 'Tabela',
            description: table.description,
            type: SearchResultType.database,
            icon: '📊',
            metadata: {
              'rowCount': table.rows.length,
              'columnCount': table.columns.length,
            },
            navigationPath: '/workspace/database',
          ));
        }

        // Pesquisar nas linhas da tabela
        for (final row in table.rows) {
          if (_matchesDatabaseRow(row, lowerQuery)) {
            final cellValues =
                row.cells.values.map((cell) => cell.value.toString()).toList();
            results.add(SearchResult(
              id: '${table.id}_${row.id}',
              title: cellValues.isNotEmpty ? cellValues.first : 'Linha vazia',
              subtitle: 'Linha em ${table.name}',
              description: cellValues.join(', '),
              type: SearchResultType.database,
              icon: '📋',
              metadata: {
                'tableName': table.name,
                'tableId': table.id,
                'rowId': row.id,
              },
              navigationPath: '/workspace/database',
            ));
          }
        }
      }

      debugPrint(
          '🔍 GlobalSearch: ${results.length} resultados de database encontrados');
      return results;
    } catch (e) {
      debugPrint('🔍 GlobalSearch: Erro ao pesquisar database: $e');
      return [];
    }
  }

  /// Verificar se tabela corresponde à pesquisa
  bool _matchesDatabaseTable(DatabaseTable table, String query) {
    return table.name.toLowerCase().contains(query) ||
        table.description?.toLowerCase().contains(query) == true;
  }

  /// Verificar se linha corresponde à pesquisa
  bool _matchesDatabaseRow(DatabaseRow row, String query) {
    return row.cells.values
        .any((cell) => cell.value.toString().toLowerCase().contains(query));
  }

  /// Pesquisar na agenda
  Future<List<SearchResult>> _searchInAgenda(String query) async {
    try {
      final currentProfile = _ref.read(currentProfileProvider);
      final currentWorkspace = _ref.read(currentWorkspaceProvider);

      if (currentProfile == null || currentWorkspace == null) {
        debugPrint('🔍 GlobalSearch: Contexto não disponível para agenda');
        return [];
      }

      final agendaState = _ref.read(agendaProvider);
      final items = agendaState.items;

      debugPrint(
          '🔍 GlobalSearch: Pesquisando em ${items.length} itens da agenda');

      final results = <SearchResult>[];
      final lowerQuery = query.toLowerCase();

      for (final item in items) {
        if (_matchesAgendaItem(item, lowerQuery)) {
          results.add(SearchResult(
            id: item.id,
            title: item.title,
            subtitle: _getAgendaItemSubtitle(item),
            description: item.description,
            type: SearchResultType.agenda,
            icon: _getAgendaItemIcon(item),
            metadata: {
              'type': item.type.toString(),
              'status': item.status.toString(),
              'startDate': item.startDate?.toIso8601String(),
              'endDate': item.endDate?.toIso8601String(),
            },
            navigationPath: '/workspace/agenda',
          ));
        }
      }

      debugPrint(
          '🔍 GlobalSearch: ${results.length} itens da agenda encontrados');
      return results;
    } catch (e) {
      debugPrint('🔍 GlobalSearch: Erro ao pesquisar agenda: $e');
      return [];
    }
  }

  /// Verificar se item da agenda corresponde à pesquisa
  bool _matchesAgendaItem(AgendaItem item, String query) {
    return item.title.toLowerCase().contains(query) ||
        item.description?.toLowerCase().contains(query) == true ||
        item.location?.toLowerCase().contains(query) == true ||
        item.tags.any((tag) => tag.toLowerCase().contains(query));
  }

  /// Obter subtítulo do item da agenda
  String _getAgendaItemSubtitle(AgendaItem item) {
    if (item.startDate != null) {
      return '${_getAgendaItemTypeName(item.type)} • ${_formatDate(item.startDate!)}';
    }
    return _getAgendaItemTypeName(item.type);
  }

  /// Obter nome do tipo de item da agenda
  String _getAgendaItemTypeName(AgendaItemType type) {
    switch (type) {
      case AgendaItemType.event:
        return 'Evento';
      case AgendaItemType.task:
        return 'Tarefa';
      case AgendaItemType.reminder:
        return 'Lembrete';
      case AgendaItemType.meeting:
        return 'Reunião';
    }
  }

  /// Obter ícone do item da agenda
  String _getAgendaItemIcon(AgendaItem item) {
    switch (item.type) {
      case AgendaItemType.event:
        return '📅';
      case AgendaItemType.task:
        return '✅';
      case AgendaItemType.reminder:
        return '⏰';
      case AgendaItemType.meeting:
        return '👥';
    }
  }

  /// Formatar data
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Pesquisar em páginas
  Future<List<SearchResult>> _searchInPages(String query) async {
    try {
      final currentProfile = _ref.read(currentProfileProvider);
      final currentWorkspace = _ref.read(currentWorkspaceProvider);

      if (currentProfile == null || currentWorkspace == null) {
        debugPrint('🔍 GlobalSearch: Contexto não disponível para páginas');
        return [];
      }

      final pages = _ref.read(pagesProvider((
        profileName: currentProfile.name,
        workspaceName: currentWorkspace.name
      )));

      debugPrint('🔍 GlobalSearch: Pesquisando em ${pages.length} páginas');

      final results = <SearchResult>[];
      final lowerQuery = query.toLowerCase();

      for (final page in pages) {
        if (_matchesPage(page, lowerQuery)) {
          results.add(SearchResult(
            id: page.id,
            title: page.title,
            subtitle: 'Página',
            description: _extractPageContent(page.content),
            type: SearchResultType.page,
            icon: page.icon ?? '📄',
            metadata: {
              'parentId': page.parentId,
              'createdAt': page.createdAt.toIso8601String(),
              'updatedAt': page.updatedAt.toIso8601String(),
            },
            navigationPath: '/workspace/bloquinho/editor/${page.id}',
          ));
        }
      }

      debugPrint('🔍 GlobalSearch: ${results.length} páginas encontradas');
      return results;
    } catch (e) {
      debugPrint('🔍 GlobalSearch: Erro ao pesquisar páginas: $e');
      return [];
    }
  }

  /// Verificar se página corresponde à pesquisa
  bool _matchesPage(PageModel page, String query) {
    return page.title.toLowerCase().contains(query) ||
        page.content.toLowerCase().contains(query);
  }

  /// Extrair conteúdo da página para descrição
  String _extractPageContent(String content) {
    if (content.isEmpty) return 'Página vazia';

    // Remover markdown e pegar primeiras 100 caracteres
    final cleanContent = content
        .replaceAll(RegExp(r'[#*`\[\]]'), '')
        .replaceAll(RegExp(r'\n+'), ' ')
        .trim();

    return cleanContent.length > 100
        ? '${cleanContent.substring(0, 100)}...'
        : cleanContent;
  }

  /// Limpar pesquisa
  void clearSearch() {
    _debounceTimer?.cancel();
    state = state.copyWith(
      results: [],
      query: '',
      isSearching: false,
      showLoadingIndicator: false,
    );
  }

  /// Obter resultados filtrados por tipo
  List<SearchResult> getResultsByType(SearchResultType type) {
    return state.results.where((result) => result.type == type).toList();
  }

  /// Obter estatísticas da pesquisa
  Map<SearchResultType, int> getSearchStats() {
    final stats = <SearchResultType, int>{};
    for (final type in SearchResultType.values) {
      stats[type] = state.results.where((r) => r.type == type).length;
    }
    return stats;
  }
}

/// Provider para pesquisa global
final globalSearchProvider =
    StateNotifierProvider<GlobalSearchNotifier, GlobalSearchState>((ref) {
  return GlobalSearchNotifier(ref);
});

/// Provider para resultados de pesquisa
final searchResultsProvider = Provider<List<SearchResult>>((ref) {
  return ref.watch(globalSearchProvider).results;
});

/// Provider para estatísticas da pesquisa
final searchStatsProvider = Provider<Map<SearchResultType, int>>((ref) {
  final notifier = ref.read(globalSearchProvider.notifier);
  return notifier.getSearchStats();
});

/// Provider para verificar se está pesquisando
final isSearchingProvider = Provider<bool>((ref) {
  return ref.watch(globalSearchProvider).isSearching;
});

/// Provider para verificar se deve mostrar indicador de carregamento
final showLoadingIndicatorProvider = Provider<bool>((ref) {
  return ref.watch(globalSearchProvider).showLoadingIndicator;
});
