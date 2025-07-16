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

import '../../../core/models/database_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/database_provider.dart';
import '../screens/table_editor_screen.dart';
import '../screens/database_list_screen.dart';
import 'create_table_dialog.dart';

/// Widget especializado para a seção de database no workspace
class DatabaseSectionWidget extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;

  const DatabaseSectionWidget({
    super.key,
    required this.isDarkMode,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  ConsumerState<DatabaseSectionWidget> createState() =>
      _DatabaseSectionWidgetState();
}

class _DatabaseSectionWidgetState extends ConsumerState<DatabaseSectionWidget> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  Future<void> _createTable() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const CreateTableDialog(),
    );

    if (result != null) {
      // Fazendo cast explícito para garantir tipos corretos
      final resultMap = Map<String, dynamic>.from(result);

      try {
        await ref.read(databaseNotifierProvider.notifier).createTable(
              name: resultMap['name'] as String,
              description: resultMap['description'] as String,
              icon: resultMap['icon'] as IconData,
              color: resultMap['color'] as Color,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Tabela "${resultMap['name']}" criada com sucesso')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao criar tabela: $e')),
          );
        }
      }
    }
  }

  void _openTable(DatabaseTable table) {
    context.go('/database/table/${table.id}');
  }

  void _openDatabaseList() {
    context.go('/workspace/database');
  }

  @override
  Widget build(BuildContext context) {
    final tablesAsync = ref.watch(databaseNotifierProvider);
    final tables = ref.watch(tablesProvider);
    final hasTable = tables.isNotEmpty;

    return Column(
      children: [
        // Item principal da seção
        Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: hasTable
                  ? () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    }
                  : _openDatabaseList,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: widget.isSelected
                      ? (widget.isDarkMode
                          ? AppColors.sidebarItemHoverDark
                          : AppColors.sidebarItemHover)
                      : null,
                ),
                child: Row(
                  children: [
                    // Ícone customizado para manter cores originais
                    Image.asset(
                      'assets/images/dossier.png',
                      width: 18,
                      height: 18,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.storage_outlined,
                          size: 18,
                          color: widget.isSelected
                              ? AppColors.primary
                              : (widget.isDarkMode
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Base de Dados',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  widget.isSelected ? AppColors.primary : null,
                              fontWeight: widget.isSelected
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                      ),
                    ),
                    if (hasTable) ...[
                      // Contador de tabelas
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${tables.length}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Ícone de expansão
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        size: 16,
                        color: widget.isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ] else ...[
                      // Botão de adicionar quando não há tabelas
                      IconButton(
                        onPressed: _createTable,
                        icon: const Icon(Icons.add, size: 16),
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Criar primeira tabela',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // Lista expandível de tabelas
        if (hasTable && _isExpanded) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Column(
              children: [
                // Lista de tabelas
                ...tables.take(5).map((table) => Container(
                      margin: const EdgeInsets.only(left: 24, bottom: 2),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () => _openTable(table),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            child: Row(
                              children: [
                                Icon(
                                  table.icon,
                                  size: 14,
                                  color: table.color,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    table.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: widget.isDarkMode
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Indicador de linhas/colunas
                                Text(
                                  '${table.rows.length}×${table.columns.length}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Colors.grey[500],
                                        fontSize: 10,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),

                // Mostrar mais se há mais de 5 tabelas
                if (tables.length > 5)
                  Container(
                    margin: const EdgeInsets.only(left: 24, bottom: 2),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: _openDatabaseList,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                Icons.more_horiz,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '+ ${tables.length - 5} mais tabelas',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Botão para criar nova tabela
                Container(
                  margin: const EdgeInsets.only(left: 24, top: 4, bottom: 2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: _createTable,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Nova tabela',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Botão para ver todas as tabelas
                Container(
                  margin: const EdgeInsets.only(left: 24, bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: _openDatabaseList,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.view_list,
                              size: 14,
                              color: widget.isDarkMode
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ver todas as tabelas',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: widget.isDarkMode
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
