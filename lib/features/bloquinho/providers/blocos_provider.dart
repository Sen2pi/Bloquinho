/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/bloco_base_model.dart';
import '../models/bloco_tipo_enum.dart';
import '../services/clipboard_parser_service.dart';
import '../services/blocos_converter_service.dart';
import 'package:bloquinho/shared/providers/workspace_provider.dart';
import '../../../core/utils/lru_cache.dart';
import '../../../core/utils/debouncer.dart';

/// Estado dos blocos
class BlocosState {
  final List<BlocoBase> blocos;
  final List<String> selectedBlocoIds;
  final bool isLoading;
  final bool isSaving;
  final bool isExporting;
  final bool isImporting;
  final String? error;
  final String? searchQuery;
  final List<BlocoTipo> activeFilters;
  final Map<String, dynamic> undoStack;
  final Map<String, dynamic> redoStack;
  final int maxHistorySize;
  final DateTime? lastModified;
  final bool hasUnsavedChanges;

  const BlocosState({
    this.blocos = const [],
    this.selectedBlocoIds = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.isExporting = false,
    this.isImporting = false,
    this.error,
    this.searchQuery,
    this.activeFilters = const [],
    this.undoStack = const {},
    this.redoStack = const {},
    this.maxHistorySize = 50,
    this.lastModified,
    this.hasUnsavedChanges = false,
  });

  BlocosState copyWith({
    List<BlocoBase>? blocos,
    List<String>? selectedBlocoIds,
    bool? isLoading,
    bool? isSaving,
    bool? isExporting,
    bool? isImporting,
    String? error,
    String? searchQuery,
    List<BlocoTipo>? activeFilters,
    Map<String, dynamic>? undoStack,
    Map<String, dynamic>? redoStack,
    int? maxHistorySize,
    DateTime? lastModified,
    bool? hasUnsavedChanges,
    bool clearError = false,
    bool clearSearchQuery = false,
  }) {
    return BlocosState(
      blocos: blocos ?? this.blocos,
      selectedBlocoIds: selectedBlocoIds ?? this.selectedBlocoIds,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isExporting: isExporting ?? this.isExporting,
      isImporting: isImporting ?? this.isImporting,
      error: clearError ? null : (error ?? this.error),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      activeFilters: activeFilters ?? this.activeFilters,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      maxHistorySize: maxHistorySize ?? this.maxHistorySize,
      lastModified: lastModified ?? this.lastModified,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }

  /// Blocos filtrados pela busca e filtros ativos (com cache)
  List<BlocoBase> get filteredBlocos {
    // Criar chave de cache baseada nos filtros e query
    final cacheKey = _generateFilterCacheKey();
    
    // Verificar se resultado está em cache
    final cached = _filterCache.get(cacheKey);
    if (cached != null) return cached;

    // Computar filtros
    var filtered = blocos;

    // Aplicar filtro de busca
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      filtered = filtered.where((bloco) {
        return _matchesSearchQuery(bloco, searchQuery!);
      }).toList();
    }

    // Aplicar filtros de tipo
    if (activeFilters.isNotEmpty) {
      filtered = filtered.where((bloco) {
        return activeFilters.contains(bloco.tipo);
      }).toList();
    }

    // Salvar no cache
    _filterCache.put(cacheKey, filtered);
    return filtered;
  }

  /// Gerar chave de cache para filtros
  String _generateFilterCacheKey() {
    final queryHash = searchQuery?.hashCode ?? 0;
    final filtersHash = activeFilters.map((f) => f.name).join(',').hashCode;
    final blocosHash = blocos.length.hashCode; // Invalida cache quando lista muda
    return '$queryHash-$filtersHash-$blocosHash';
  }

  /// Cache estático para filtros
  static final LRUCache<String, List<BlocoBase>> _filterCache = LRUCache(maxSize: 50);

  /// Verificar se um bloco corresponde à query de busca
  bool _matchesSearchQuery(BlocoBase bloco, String query) {
    final queryLower = query.toLowerCase();

    // Buscar no conteúdo específico de cada tipo
    switch (bloco.tipo) {
      case BlocoTipo.texto:
        final blocoTexto = bloco as BlocoTexto;
        return blocoTexto.conteudo.toLowerCase().contains(queryLower);

      case BlocoTipo.titulo:
        final blocoTitulo = bloco as BlocoTitulo;
        return blocoTitulo.conteudo.toLowerCase().contains(queryLower);

      case BlocoTipo.codigo:
        final blocoCodigo = bloco as BlocoCodigo;
        return blocoCodigo.codigo.toLowerCase().contains(queryLower) ||
            blocoCodigo.linguagem.toLowerCase().contains(queryLower);

      case BlocoTipo.tarefa:
        final blocoTarefa = bloco as BlocoTarefa;
        return blocoTarefa.conteudo.toLowerCase().contains(queryLower);

      case BlocoTipo.lista:
        final blocoLista = bloco as BlocoLista;
        return blocoLista.itens
            .any((item) => item.toLowerCase().contains(queryLower));

      case BlocoTipo.listaNumerada:
        final blocoListaNumerada = bloco as BlocoListaNumerada;
        return blocoListaNumerada.itens
            .any((item) => item.toLowerCase().contains(queryLower));

      case BlocoTipo.link:
        final blocoLink = bloco as BlocoLink;
        return blocoLink.url.toLowerCase().contains(queryLower) ||
            (blocoLink.titulo?.toLowerCase().contains(queryLower) ?? false);

      case BlocoTipo.wiki:
        final blocoWiki = bloco as BlocoWiki;
        return blocoWiki.titulo.toLowerCase().contains(queryLower) ||
            blocoWiki.conteudo.toLowerCase().contains(queryLower) ||
            blocoWiki.tags.any((tag) => tag.toLowerCase().contains(queryLower));

      default:
        return false;
    }
  }

  /// Estatísticas dos blocos
  Map<String, int> get stats {
    final stats = <String, int>{};

    // Contar por tipo
    for (final tipo in BlocoTipo.values) {
      stats[tipo.name] = blocos.where((b) => b.tipo == tipo).length;
    }

    // Estatísticas gerais
    stats['total'] = blocos.length;
    stats['selected'] = selectedBlocoIds.length;
    stats['filtered'] = filteredBlocos.length;

    return stats;
  }

  bool get hasSelection => selectedBlocoIds.isNotEmpty;
  bool get hasMultipleSelection => selectedBlocoIds.length > 1;
  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;
  bool get isEmpty => blocos.isEmpty;
  bool get isNotEmpty => blocos.isNotEmpty;
  bool get isBusy => isLoading || isSaving || isExporting || isImporting;
}

/// Notifier para gerenciar blocos com otimizações de performance
class BlocosNotifier extends StateNotifier<BlocosState> with DebounceMixin {
  static const _uuid = Uuid();
  final ClipboardParserService _clipboardService;
  final BlocosConverterService _converterService;
  final Ref _ref;

  // Cache para operações custosas
  static final LRUCache<String, List<BlocoBase>> _searchCache = LRUCache(maxSize: 100);
  static final LRUCache<String, Map<String, int>> _statsCache = LRUCache(maxSize: 10);

  // Debouncer para auto-save
  late final AsyncDebouncer _autoSaveDebouncer;
  
  // Throttler para busca
  late final Throttler _searchThrottler;

  BlocosNotifier(
    this._clipboardService,
    this._converterService,
    this._ref,
  ) : super(const BlocosState()) {
    _autoSaveDebouncer = AsyncDebouncer(delay: const Duration(milliseconds: 1000));
    _searchThrottler = Throttler(interval: const Duration(milliseconds: 200));
    _loadBlocos();
  }

  @override
  void dispose() {
    _autoSaveDebouncer.dispose();
    _searchThrottler.dispose();
    disposeAllDebouncers();
    super.dispose();
  }

  /// Carregar blocos do workspace atual
  Future<void> _loadBlocos() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // TODO: Implementar carregamento do storage local/remoto
      // Por enquanto, lista vazia
      final blocos = <BlocoBase>[];

      state = state.copyWith(
        blocos: blocos,
        isLoading: false,
        lastModified: DateTime.now(),
        hasUnsavedChanges: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar blocos: $e',
      );
    }
  }

  /// Adicionar novo bloco (otimizado)
  void addBloco(BlocoBase bloco) {
    _saveToHistory();
    _invalidateAllCaches(); // Limpar caches quando dados mudam

    final updatedBlocos = [...state.blocos, bloco];
    state = state.copyWith(
      blocos: updatedBlocos,
      lastModified: DateTime.now(),
      hasUnsavedChanges: true,
    );

    _debouncedAutoSave();
  }

  /// Inserir bloco em posição específica (otimizado)
  void insertBloco(int index, BlocoBase bloco) {
    if (index < 0 || index > state.blocos.length) {
      addBloco(bloco);
      return;
    }

    _saveToHistory();
    _invalidateAllCaches();

    final updatedBlocos = [...state.blocos];
    updatedBlocos.insert(index, bloco);

    state = state.copyWith(
      blocos: updatedBlocos,
      lastModified: DateTime.now(),
      hasUnsavedChanges: true,
    );

    _debouncedAutoSave();
  }

  /// Atualizar bloco existente (otimizado)
  void updateBloco(String id, BlocoBase updatedBloco) {
    final index = state.blocos.indexWhere((b) => b.id == id);
    if (index == -1) return;

    _saveToHistory();
    _invalidateAllCaches();

    final updatedBlocos = [...state.blocos];
    updatedBlocos[index] = updatedBloco;

    state = state.copyWith(
      blocos: updatedBlocos,
      lastModified: DateTime.now(),
      hasUnsavedChanges: true,
    );

    _debouncedAutoSave();
  }

  /// Remover bloco
  void removeBloco(String id) {
    _saveToHistory();

    final updatedBlocos = state.blocos.where((b) => b.id != id).toList();
    final updatedSelection =
        state.selectedBlocoIds.where((s) => s != id).toList();

    state = state.copyWith(
      blocos: updatedBlocos,
      selectedBlocoIds: updatedSelection,
      lastModified: DateTime.now(),
      hasUnsavedChanges: true,
    );

    _debouncedAutoSave();
  }

  /// Remover múltiplos blocos
  void removeBlocos(List<String> ids) {
    if (ids.isEmpty) return;

    _saveToHistory();

    final updatedBlocos =
        state.blocos.where((b) => !ids.contains(b.id)).toList();
    final updatedSelection =
        state.selectedBlocoIds.where((s) => !ids.contains(s)).toList();

    state = state.copyWith(
      blocos: updatedBlocos,
      selectedBlocoIds: updatedSelection,
      lastModified: DateTime.now(),
      hasUnsavedChanges: true,
    );

    _debouncedAutoSave();
  }

  /// Reordenar blocos
  void reorderBlocos(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;

    _saveToHistory();

    final updatedBlocos = [...state.blocos];
    final item = updatedBlocos.removeAt(oldIndex);
    updatedBlocos.insert(newIndex, item);

    state = state.copyWith(
      blocos: updatedBlocos,
      lastModified: DateTime.now(),
      hasUnsavedChanges: true,
    );

    _debouncedAutoSave();
  }

  /// Duplicar bloco
  void duplicateBloco(String id) {
    final originalBloco = state.blocos.firstWhere((b) => b.id == id);
    final duplicatedBloco = _duplicateBloco(originalBloco);

    final originalIndex = state.blocos.indexWhere((b) => b.id == id);
    insertBloco(originalIndex + 1, duplicatedBloco);
  }

  /// Criar cópia de um bloco com novo ID
  BlocoBase _duplicateBloco(BlocoBase original) {
    final json = original.toJson();
    json['id'] = _uuid.v4();

    // Adicionar sufixo "(Cópia)" ao conteúdo se aplicável
    if (original is BlocoTexto) {
      json['conteudo'] = '${json['conteudo']} (Cópia)';
    } else if (original is BlocoTitulo) {
      json['conteudo'] = '${json['conteudo']} (Cópia)';
    } else if (original is BlocoWiki) {
      json['titulo'] = '${json['titulo']} (Cópia)';
    }

    return BlocoBase.fromJson(json);
  }

  /// Selecionar bloco
  void selectBloco(String id, {bool multiSelect = false}) {
    List<String> updatedSelection;

    if (multiSelect) {
      if (state.selectedBlocoIds.contains(id)) {
        updatedSelection =
            state.selectedBlocoIds.where((s) => s != id).toList();
      } else {
        updatedSelection = [...state.selectedBlocoIds, id];
      }
    } else {
      updatedSelection = [id];
    }

    state = state.copyWith(selectedBlocoIds: updatedSelection);
  }

  /// Limpar seleção
  void clearSelection() {
    state = state.copyWith(selectedBlocoIds: []);
  }

  /// Selecionar todos os blocos filtrados
  void selectAllFiltered() {
    final filteredIds = state.filteredBlocos.map((b) => b.id).toList();
    state = state.copyWith(selectedBlocoIds: filteredIds);
  }

  /// Definir query de busca (com throttling)
  void setSearchQuery(String? query) {
    _searchThrottler.call(() {
      state = state.copyWith(
        searchQuery: query,
        clearSearchQuery: query == null || query.isEmpty,
      );
    });
  }

  /// Adicionar filtro de tipo
  void addFilter(BlocoTipo tipo) {
    if (state.activeFilters.contains(tipo)) return;

    final updatedFilters = [...state.activeFilters, tipo];
    state = state.copyWith(activeFilters: updatedFilters);
  }

  /// Remover filtro de tipo
  void removeFilter(BlocoTipo tipo) {
    final updatedFilters = state.activeFilters.where((f) => f != tipo).toList();
    state = state.copyWith(activeFilters: updatedFilters);
  }

  /// Limpar todos os filtros
  void clearFilters() {
    state = state.copyWith(activeFilters: []);
  }

  /// Processar colagem do clipboard
  Future<void> pasteFromClipboard() async {
    try {
      final parseResult = await _clipboardService.parseClipboard();

      if (parseResult.success && parseResult.blocos.isNotEmpty) {
        _saveToHistory();

        final updatedBlocos = [...state.blocos, ...parseResult.blocos];
        state = state.copyWith(
          blocos: updatedBlocos,
          lastModified: DateTime.now(),
          hasUnsavedChanges: true,
        );

        _debouncedAutoSave();
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao processar clipboard: $e',
      );
    }
  }

  /// Exportar blocos selecionados
  Future<Map<String, dynamic>> exportSelected() async {
    if (state.selectedBlocoIds.isEmpty) {
      throw Exception('Nenhum bloco selecionado');
    }

    state = state.copyWith(isExporting: true, clearError: true);

    try {
      final selectedBlocos = state.blocos
          .where((b) => state.selectedBlocoIds.contains(b.id))
          .toList();

      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'blocos': selectedBlocos.map((b) => b.toJson()).toList(),
      };

      state = state.copyWith(isExporting: false);
      return exportData;
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        error: 'Erro ao exportar blocos: $e',
      );
      rethrow;
    }
  }

  /// Importar blocos
  Future<void> importBlocos(Map<String, dynamic> importData) async {
    state = state.copyWith(isImporting: true, clearError: true);

    try {
      final blocosData = importData['blocos'] as List;
      final importedBlocos =
          blocosData.map((data) => BlocoBase.fromJson(data)).toList();

      _saveToHistory();

      final updatedBlocos = [...state.blocos, ...importedBlocos];
      state = state.copyWith(
        blocos: updatedBlocos,
        isImporting: false,
        lastModified: DateTime.now(),
        hasUnsavedChanges: true,
      );

      _debouncedAutoSave();
    } catch (e) {
      state = state.copyWith(
        isImporting: false,
        error: 'Erro ao importar blocos: $e',
      );
      rethrow;
    }
  }

  /// Desfazer última ação
  void undo() {
    if (!state.canUndo) return;

    // TODO: Implementar sistema de undo/redo
    // Por enquanto, placeholder
  }

  /// Refazer última ação desfeita
  void redo() {
    if (!state.canRedo) return;

    // TODO: Implementar sistema de undo/redo
    // Por enquanto, placeholder
  }

  /// Salvar estado atual no histórico
  void _saveToHistory() {
    // TODO: Implementar sistema de histórico
    // Por enquanto, placeholder
  }

  /// Auto-save com debounce otimizado
  void _debouncedAutoSave() {
    _autoSaveDebouncer.call(() async {
      await _performAutoSave();
    });
  }

  /// Executar auto-save real
  Future<void> _performAutoSave() async {
    try {
      // TODO: Implementar auto-save real
      debugPrint('🔄 Auto-save executado em ${DateTime.now()}');
      
      // Simular save
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Atualizar estado se ainda estiver ativo
      if (mounted) {
        state = state.copyWith(hasUnsavedChanges: false);
      }
    } catch (e) {
      debugPrint('❌ Erro no auto-save: $e');
    }
  }

  /// Invalidar todos os caches quando dados mudam
  void _invalidateAllCaches() {
    _searchCache.clear();
    _statsCache.clear();
    BlocosState._filterCache.clear();
  }

  /// Salvar manualmente
  Future<void> save() async {
    if (state.isSaving) return;

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      // TODO: Implementar salvamento no storage
      await Future.delayed(const Duration(seconds: 1)); // Simular salvamento

      state = state.copyWith(
        isSaving: false,
        hasUnsavedChanges: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Erro ao salvar: $e',
      );
    }
  }

  /// Limpar erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Limpar todos os blocos
  void clearAllBlocos() {
    _saveToHistory();

    state = state.copyWith(
      blocos: [],
      selectedBlocoIds: [],
      lastModified: DateTime.now(),
      hasUnsavedChanges: true,
    );

    _debouncedAutoSave();
  }

  /// Substituir todos os blocos
  void replaceAllBlocos(List<BlocoBase> newBlocos) {
    _saveToHistory();

    state = state.copyWith(
      blocos: newBlocos,
      selectedBlocoIds: [],
      lastModified: DateTime.now(),
      hasUnsavedChanges: true,
    );

    _debouncedAutoSave();
  }

  /// Obter bloco por ID
  BlocoBase? getBlocoById(String id) {
    try {
      return state.blocos.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obter índice do bloco
  int getBlocoIndex(String id) {
    return state.blocos.indexWhere((b) => b.id == id);
  }

  /// Verificar se bloco existe
  bool hasBlocoWithId(String id) {
    return state.blocos.any((b) => b.id == id);
  }
}

/// Provider dos serviços
final clipboardParserServiceProvider = Provider((ref) {
  return ClipboardParserService();
});

final blocosConverterServiceProvider = Provider((ref) {
  return BlocosConverterService();
});

/// Provider principal dos blocos
final blocosProvider =
    StateNotifierProvider<BlocosNotifier, BlocosState>((ref) {
  final clipboardService = ref.watch(clipboardParserServiceProvider);
  final converterService = ref.watch(blocosConverterServiceProvider);

  return BlocosNotifier(clipboardService, converterService, ref);
});

/// Providers derivados

/// Lista de todos os blocos
final blocosListProvider = Provider<List<BlocoBase>>((ref) {
  return ref.watch(blocosProvider).blocos;
});

/// Lista de blocos filtrados
final filteredBlocosProvider = Provider<List<BlocoBase>>((ref) {
  return ref.watch(blocosProvider).filteredBlocos;
});

/// Blocos selecionados
final selectedBlocosProvider = Provider<List<BlocoBase>>((ref) {
  final state = ref.watch(blocosProvider);
  return state.blocos
      .where((b) => state.selectedBlocoIds.contains(b.id))
      .toList();
});

/// Estatísticas dos blocos
final blocosStatsProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(blocosProvider).stats;
});

/// Verificar se tem blocos
final hasBlocosProvider = Provider<bool>((ref) {
  return ref.watch(blocosProvider).isNotEmpty;
});

/// Verificar se tem seleção
final hasSelectionProvider = Provider<bool>((ref) {
  return ref.watch(blocosProvider).hasSelection;
});

/// Verificar se pode desfazer
final canUndoProvider = Provider<bool>((ref) {
  return ref.watch(blocosProvider).canUndo;
});

/// Verificar se pode refazer
final canRedoProvider = Provider<bool>((ref) {
  return ref.watch(blocosProvider).canRedo;
});

/// Verificar se tem alterações não salvas
final hasUnsavedChangesProvider = Provider<bool>((ref) {
  return ref.watch(blocosProvider).hasUnsavedChanges;
});

/// Verificar se está ocupado
final isBusyProvider = Provider<bool>((ref) {
  return ref.watch(blocosProvider).isBusy;
});

/// Obter bloco específico por ID
final blocoByIdProvider = Provider.family<BlocoBase?, String>((ref, id) {
  return ref.watch(blocosProvider.notifier).getBlocoById(id);
});

/// Contagem de blocos por tipo
final blocosByTypeProvider =
    Provider.family<List<BlocoBase>, BlocoTipo>((ref, tipo) {
  return ref.watch(blocosProvider).blocos.where((b) => b.tipo == tipo).toList();
});

/// Query de busca atual
final searchQueryProvider = Provider<String?>((ref) {
  return ref.watch(blocosProvider).searchQuery;
});

/// Filtros ativos
final activeFiltersProvider = Provider<List<BlocoTipo>>((ref) {
  return ref.watch(blocosProvider).activeFilters;
});

/// Último erro
final blocosErrorProvider = Provider<String?>((ref) {
  return ref.watch(blocosProvider).error;
});

/// Extensões para facilitar uso
extension BlocosNotifierExtension on WidgetRef {
  /// Obter notifier dos blocos
  BlocosNotifier get blocos => read(blocosProvider.notifier);

  /// Adicionar bloco rapidamente
  void addBloco(BlocoBase bloco) => blocos.addBloco(bloco);

  /// Remover bloco rapidamente
  void removeBloco(String id) => blocos.removeBloco(id);

  /// Selecionar bloco rapidamente
  void selectBloco(String id) => blocos.selectBloco(id);

  /// Colar do clipboard
  Future<void> pasteFromClipboard() => blocos.pasteFromClipboard();
}
