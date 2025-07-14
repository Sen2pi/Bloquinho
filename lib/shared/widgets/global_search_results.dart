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
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../providers/global_search_provider.dart';
import '../../core/theme/app_colors.dart';

class GlobalSearchResults extends ConsumerWidget {
  final VoidCallback? onResultSelected;

  const GlobalSearchResults({
    super.key,
    this.onResultSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(globalSearchProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // DEBUG: Log do estado da pesquisa
    debugPrint('🔍 GlobalSearchResults: query="${searchState.query}"');
    debugPrint('🔍 GlobalSearchResults: results=${searchState.results.length}');
    debugPrint(
        '🔍 GlobalSearchResults: isSearching=${searchState.isSearching}');
    debugPrint(
        '🔍 GlobalSearchResults: showLoadingIndicator=${searchState.showLoadingIndicator}');

    // Mostrar indicador de carregamento se estiver pesquisando ou se o indicador estiver ativo
    if (searchState.isSearching || searchState.showLoadingIndicator) {
      debugPrint('🔍 GlobalSearchResults: showing loading state');
      return _buildLoadingState(isDarkMode);
    }

    // Mostrar mensagem de mínimo de caracteres se query tem menos de 3 caracteres
    if (searchState.query.isNotEmpty && searchState.query.length < 3) {
      debugPrint('🔍 GlobalSearchResults: showing min chars message');
      return _buildMinCharsMessage(isDarkMode);
    }

    if (searchState.results.isEmpty && searchState.query.isNotEmpty) {
      debugPrint('🔍 GlobalSearchResults: showing empty state');
      return _buildEmptyState(isDarkMode, searchState.query);
    }

    if (searchState.results.isEmpty) {
      debugPrint('🔍 GlobalSearchResults: no results, showing nothing');
      return const SizedBox.shrink();
    }

    debugPrint(
        '🔍 GlobalSearchResults: showing results list with ${searchState.results.length} results');
    return _buildResultsList(context, ref, searchState, isDarkMode);
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDarkMode ? Colors.white70 : Colors.grey[600]!,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Pesquisando...',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinCharsMessage(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.info(),
            size: 16,
            color: isDarkMode ? Colors.white54 : Colors.grey[400],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Digite pelo menos 3 caracteres para pesquisar',
              style: TextStyle(
                color: isDarkMode ? Colors.white54 : Colors.grey[600],
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, String query) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            PhosphorIcons.magnifyingGlass(),
            size: 32,
            color: isDarkMode ? Colors.white54 : Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Nenhum resultado encontrado para "$query"',
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(
    BuildContext context,
    WidgetRef ref,
    GlobalSearchState searchState,
    bool isDarkMode,
  ) {
    final stats = ref.read(searchStatsProvider);
    final groupedResults = _groupResultsByType(searchState.results);

    return Container(
      constraints: const BoxConstraints(
          maxHeight: 280), // Reduzir altura para dar margem
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true, // Importante para altura limitada
        children: [
          // Estatísticas da pesquisa
          _buildSearchStats(stats, isDarkMode),

          // Resultados agrupados por tipo
          ...groupedResults.entries.map((entry) {
            return _buildResultGroup(
              context,
              entry.key,
              entry.value,
              isDarkMode,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchStats(Map<SearchResultType, int> stats, bool isDarkMode) {
    final totalResults = stats.values.fold(0, (sum, count) => sum + count);

    if (totalResults == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkSurface.withOpacity(0.5)
            : AppColors.lightSurface.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(
              '$totalResults resultado${totalResults == 1 ? '' : 's'} encontrado${totalResults == 1 ? '' : 's'}',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white54 : Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children:
                  stats.entries.where((entry) => entry.value > 0).map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getTypeIcon(entry.key),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.value}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white54 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultGroup(
    BuildContext context,
    SearchResultType type,
    List<SearchResult> results,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho do grupo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                _getTypeIcon(type),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getTypeName(type),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white24 : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${results.length}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode ? Colors.white70 : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista de resultados
        ...results.map((result) => _buildResultItem(
              context,
              result,
              isDarkMode,
            )),
      ],
    );
  }

  Widget _buildResultItem(
    BuildContext context,
    SearchResult result,
    bool isDarkMode,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleResultTap(context, result),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Ícone do resultado
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    result.icon ?? '📄',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Conteúdo do resultado
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (result.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        result.subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white54 : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (result.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        result.description!,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDarkMode ? Colors.white38 : Colors.grey[500],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Ícone de navegação
              Icon(
                PhosphorIcons.arrowRight(),
                size: 16,
                color: isDarkMode ? Colors.white38 : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleResultTap(BuildContext context, SearchResult result) {
    // Fechar resultados de pesquisa
    onResultSelected?.call();

    // Navegar para o resultado
    if (result.navigationPath != null) {
      context.go(result.navigationPath!);
    }
  }

  Map<SearchResultType, List<SearchResult>> _groupResultsByType(
    List<SearchResult> results,
  ) {
    final grouped = <SearchResultType, List<SearchResult>>{};

    for (final result in results) {
      grouped.putIfAbsent(result.type, () => []).add(result);
    }

    return grouped;
  }

  String _getTypeIcon(SearchResultType type) {
    switch (type) {
      case SearchResultType.password:
        return '🔐';
      case SearchResultType.database:
        return '📊';
      case SearchResultType.agenda:
        return '📅';
      case SearchResultType.page:
        return '📄';
    }
  }

  String _getTypeName(SearchResultType type) {
    switch (type) {
      case SearchResultType.password:
        return 'Senhas';
      case SearchResultType.database:
        return 'Base de Dados';
      case SearchResultType.agenda:
        return 'Agenda';
      case SearchResultType.page:
        return 'Páginas';
    }
  }
}
