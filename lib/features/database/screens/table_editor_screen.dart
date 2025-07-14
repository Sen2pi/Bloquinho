/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:bloquinho/core/models/database_models.dart';
import 'package:bloquinho/core/services/database_service.dart';
import 'package:bloquinho/features/database/widgets/database_cell_widgets.dart';

/// Tela principal para editar uma tabela do database
class TableEditorScreen extends StatefulWidget {
  final DatabaseTable table;

  const TableEditorScreen({
    super.key,
    required this.table,
  });

  @override
  State<TableEditorScreen> createState() => _TableEditorScreenState();
}

class _TableEditorScreenState extends State<TableEditorScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late DatabaseTable _table;
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  String? _editingCellId; // rowId_columnId
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _table = widget.table;
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  Future<void> _saveTable() async {
    setState(() => _isLoading = true);

    try {
      final updatedTable = await _databaseService.updateTable(_table);
      setState(() => _table = updatedTable);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tabela salva com sucesso')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar tabela: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addColumn() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddColumnDialog(),
    );

    if (result != null) {
      final now = DateTime.now();
      final columnId = 'col_${now.millisecondsSinceEpoch}';

      // Fazendo cast explícito para garantir tipos corretos
      final resultMap = Map<String, dynamic>.from(result);

      final newColumn = DatabaseColumn(
        id: columnId,
        name: resultMap['name'] as String,
        type: resultMap['type'] as ColumnType,
        isRequired: resultMap['isRequired'] as bool? ?? false,
        config: Map<String, dynamic>.from(resultMap['config'] as Map? ?? {}),
        mathOperation: resultMap['mathOperation'] as MathOperation?,
        sortOrder: _table.columns.length,
      );

      try {
        final updatedTable =
            await _databaseService.addColumn(_table.id, newColumn);
        setState(() => _table = updatedTable);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao adicionar coluna: $e')),
          );
        }
      }
    }
  }

  Future<void> _addRow() async {
    try {
      final now = DateTime.now();
      final rowId = 'row_${now.millisecondsSinceEpoch}';

      // Criar células vazias para cada coluna
      final cells = <String, DatabaseCellValue>{};
      for (final column in _table.columns) {
        cells[column.id] = DatabaseCellValue(
          columnId: column.id,
          value: null,
          lastModified: now,
        );
      }

      final newRow = DatabaseRow(
        id: rowId,
        tableId: _table.id,
        cells: cells,
        createdAt: now,
        lastModified: now,
      );

      final updatedTable = await _databaseService.addRow(_table.id, newRow);
      setState(() => _table = updatedTable);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar linha: $e')),
        );
      }
    }
  }

  Future<void> _updateCell(String rowId, String columnId, dynamic value) async {
    try {
      final updatedTable =
          await _databaseService.updateCell(_table.id, rowId, columnId, value);
      setState(() => _table = updatedTable);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar célula: $e')),
        );
      }
    }
  }

  Future<void> _deleteColumn(DatabaseColumn column) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
            'Tem certeza que deseja excluir a coluna "${column.name}"? Todos os dados desta coluna serão perdidos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final updatedTable =
            await _databaseService.removeColumn(_table.id, column.id);
        setState(() => _table = updatedTable);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir coluna: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteRow(DatabaseRow row) async {
    try {
      final updatedTable = await _databaseService.removeRow(_table.id, row.id);
      setState(() => _table = updatedTable);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir linha: $e')),
        );
      }
    }
  }

  void _startEditing(String rowId, String columnId) {
    setState(() {
      _editingCellId = '${rowId}_$columnId';
    });
  }

  void _stopEditing() {
    setState(() {
      _editingCellId = null;
    });
  }

  Widget _buildMathResultRow(DatabaseColumn column) {
    if (column.mathOperation == null) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      final borderColor = isDark
          ? theme.colorScheme.outline.withOpacity(0.3)
          : theme.colorScheme.outline.withOpacity(0.2);
      final mathRowColor = isDark
          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
          : theme.colorScheme.primaryContainer.withOpacity(0.1);

      return Container(
        width: 180,
        height: 44,
        decoration: BoxDecoration(
          color: mathRowColor,
          border: Border(
            right: BorderSide(color: borderColor),
            top: BorderSide(color: borderColor, width: 2),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? theme.colorScheme.outline.withOpacity(0.3)
        : theme.colorScheme.outline.withOpacity(0.2);
    final mathRowColor = isDark
        ? theme.colorScheme.primaryContainer.withOpacity(0.3)
        : theme.colorScheme.primaryContainer.withOpacity(0.1);

    final result =
        _table.calculateMathOperation(column.id, column.mathOperation!);

    return Container(
      width: 180,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: mathRowColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 2),
          right: BorderSide(color: borderColor),
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.7),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            result != null
                ? (result % 1 == 0
                    ? result.toInt().toString()
                    : result.toStringAsFixed(2))
                : '-',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(_table.icon, color: _table.color),
            const SizedBox(width: 8),
            Text(_table.name),
          ],
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                  child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveTable,
            ),
          PopupMenuButton<String>(
            onSelected: (action) {
              switch (action) {
                case 'add_column':
                  _addColumn();
                  break;
                case 'add_row':
                  _addRow();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_column',
                child: Row(
                  children: [
                    Icon(Icons.view_column),
                    SizedBox(width: 8),
                    Text('Adicionar Coluna'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'add_row',
                child: Row(
                  children: [
                    Icon(Icons.table_rows),
                    SizedBox(width: 8),
                    Text('Adicionar Linha'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Cabeçalho com informações da tabela
          if (_table.description.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _table.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ),

          // Tabela de dados
          Expanded(
            child:
                _table.columns.isEmpty ? _buildEmptyState() : _buildDataTable(),
          ),
        ],
      ),
      floatingActionButton: _table.columns.isEmpty
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.small(
                  heroTag: 'add_column',
                  onPressed: _addColumn,
                  tooltip: 'Adicionar Coluna',
                  child: const Icon(Icons.view_column, size: 20),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'add_row',
                  onPressed: _addRow,
                  tooltip: 'Adicionar Linha',
                  child: const Icon(Icons.add),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.table_chart_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tabela vazia',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Adicione colunas para começar a estruturar seus dados.\nCrie diferentes tipos de campos para organizar suas informações.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _addColumn,
              icon: const Icon(Icons.view_column),
              label: const Text('Adicionar Primeira Coluna'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Cores adaptadas ao tema
    final headerColor = isDark
        ? theme.colorScheme.surface
        : theme.colorScheme.surfaceContainerHighest;
    final cellColor = theme.colorScheme.surface;
    final borderColor = isDark
        ? theme.colorScheme.outline.withOpacity(0.3)
        : theme.colorScheme.outline.withOpacity(0.2);
    final mathRowColor = isDark
        ? theme.colorScheme.primaryContainer.withOpacity(0.3)
        : theme.colorScheme.primaryContainer.withOpacity(0.1);
    final addButtonColor = isDark
        ? theme.colorScheme.surfaceContainerHigh
        : theme.colorScheme.surfaceContainer;

    return Container(
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Scrollbar(
          controller: _horizontalController,
          child: Scrollbar(
            controller: _verticalController,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                controller: _verticalController,
                child: Column(
                  children: [
                    // Cabeçalho da tabela
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          // Coluna de ações das linhas
                          Container(
                            width: 50,
                            decoration: BoxDecoration(
                              color: headerColor,
                              border: Border(
                                right: BorderSide(color: borderColor),
                                bottom: BorderSide(color: borderColor),
                              ),
                            ),
                            child: Icon(
                              Icons.drag_indicator,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ),

                          // Cabeçalhos das colunas
                          ..._table.columns
                              .map((column) => _buildColumnHeader(column)),

                          // Botão para adicionar coluna
                          Container(
                            width: 180,
                            height: 56,
                            decoration: BoxDecoration(
                              color: addButtonColor,
                              border: Border(
                                right: BorderSide(color: borderColor),
                                bottom: BorderSide(color: borderColor),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _addColumn,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: theme.colorScheme.primary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Coluna',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w500,
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

                    // Linhas de dados
                    ..._table.rows.map((row) => _buildDataRow(row)),

                    // Linha de resultados matemáticos
                    if (_table.columns.any((c) => c.mathOperation != null))
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            // Célula vazia para ações
                            Container(
                              width: 50,
                              height: 44,
                              decoration: BoxDecoration(
                                color: mathRowColor,
                                border: Border(
                                  right: BorderSide(color: borderColor),
                                  top: BorderSide(color: borderColor, width: 2),
                                ),
                              ),
                              child: Icon(
                                Icons.functions,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                            ),

                            // Resultados das operações matemáticas
                            ..._table.columns
                                .map((column) => _buildMathResultRow(column)),

                            // Célula vazia final
                            Container(
                              width: 180,
                              height: 44,
                              decoration: BoxDecoration(
                                color: mathRowColor,
                                border: Border(
                                  right: BorderSide(color: borderColor),
                                  top: BorderSide(color: borderColor, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Botão para adicionar linha
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 44,
                            decoration: BoxDecoration(
                              color: addButtonColor,
                              border: Border(
                                right: BorderSide(color: borderColor),
                                top: BorderSide(color: borderColor),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _addRow,
                                child: Icon(
                                  Icons.add,
                                  color: theme.colorScheme.primary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          ..._table.columns.map((column) => Container(
                                width: 180,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: addButtonColor,
                                  border: Border(
                                    right: BorderSide(color: borderColor),
                                    top: BorderSide(color: borderColor),
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _addRow,
                                    child: Center(
                                      child: Text(
                                        'Nova linha',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                          Container(
                            width: 180,
                            height: 44,
                            decoration: BoxDecoration(
                              color: addButtonColor,
                              border: Border(
                                right: BorderSide(color: borderColor),
                                top: BorderSide(color: borderColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColumnHeader(DatabaseColumn column) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headerColor = isDark
        ? theme.colorScheme.surface
        : theme.colorScheme.surfaceContainerHighest;
    final borderColor = isDark
        ? theme.colorScheme.outline.withOpacity(0.3)
        : theme.colorScheme.outline.withOpacity(0.2);

    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: headerColor,
        border: Border(
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: column.type.icon == Icons.text_fields
                        ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                        : theme.colorScheme.secondaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    column.type.icon,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    column.name,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: PopupMenuButton<String>(
                    onSelected: (action) {
                      switch (action) {
                        case 'delete':
                          _deleteColumn(column);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete,
                                color: theme.colorScheme.error, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Excluir',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    icon: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (column.mathOperation != null)
            Container(
              height: 24,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                border: Border(
                  top: BorderSide(color: borderColor, width: 0.5),
                ),
              ),
              child: Center(
                child: Text(
                  column.mathOperation!.displayName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataRow(DatabaseRow row) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? theme.colorScheme.outline.withOpacity(0.3)
        : theme.colorScheme.outline.withOpacity(0.2);

    return IntrinsicHeight(
      child: Row(
        children: [
          // Ações da linha
          Container(
            width: 50,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: borderColor),
                bottom: BorderSide(color: borderColor),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: PopupMenuButton<String>(
                onSelected: (action) {
                  switch (action) {
                    case 'delete':
                      _deleteRow(row);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete,
                            color: theme.colorScheme.error, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Excluir',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                icon: Icon(
                  Icons.more_horiz,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          // Células de dados
          ..._table.columns.map((column) => _buildDataCell(row, column)),

          // Célula vazia final
          Container(
            width: 180,
            height: 48,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: borderColor),
                bottom: BorderSide(color: borderColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell(DatabaseRow row, DatabaseColumn column) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? theme.colorScheme.outline.withOpacity(0.3)
        : theme.colorScheme.outline.withOpacity(0.2);
    final cellId = '${row.id}_${column.id}';
    final isEditing = _editingCellId == cellId;
    final cellValue = row.getCell(column.id);

    return Container(
      width: 180,
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        color: isEditing
            ? theme.colorScheme.primaryContainer.withOpacity(0.1)
            : theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: DatabaseCellWidgetFactory.create(
          value: cellValue,
          column: column,
          isEditing: isEditing,
          onChanged: (value) => _updateCell(row.id, column.id, value),
          onStartEdit: () => _startEditing(row.id, column.id),
          onStopEdit: _stopEditing,
        ),
      ),
    );
  }
}

/// Dialog para adicionar nova coluna
class AddColumnDialog extends StatefulWidget {
  const AddColumnDialog({super.key});

  @override
  State<AddColumnDialog> createState() => _AddColumnDialogState();
}

class _AddColumnDialogState extends State<AddColumnDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  ColumnType _selectedType = ColumnType.text;
  bool _isRequired = false;
  MathOperation? _selectedMathOperation;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final config = <String, dynamic>{};

      // Para tipo Status, adicionar automaticamente as opções predefinidas
      if (_selectedType == ColumnType.status) {
        config['options'] = DatabaseColumn.getDefaultStatusOptions()
            .map((o) => o.toJson())
            .toList();
      }

      final result = <String, dynamic>{
        'name': _nameController.text.trim(),
        'type': _selectedType,
        'isRequired': _isRequired,
        'mathOperation': _selectedMathOperation,
        'config': config,
      };
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canHaveMathOperation = _selectedType == ColumnType.number ||
        _selectedType == ColumnType.rating ||
        _selectedType == ColumnType.progress;

    return AlertDialog(
      title: const Text('Adicionar Coluna'),
      content: SizedBox(
        width: 300,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da coluna',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
                autofocus: true,
                textInputAction: TextInputAction.next,
                enableInteractiveSelection: true,
                autocorrect: false,
                enableSuggestions: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ColumnType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de dados',
                  border: OutlineInputBorder(),
                ),
                items: ColumnType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(type.icon, size: 16),
                              const SizedBox(width: 8),
                              Text(type.displayName),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                    if (!canHaveMathOperation) {
                      _selectedMathOperation = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _isRequired,
                onChanged: (value) =>
                    setState(() => _isRequired = value ?? false),
                title: const Text('Campo obrigatório'),
                contentPadding: EdgeInsets.zero,
              ),
              if (canHaveMathOperation) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<MathOperation?>(
                  value: _selectedMathOperation,
                  decoration: const InputDecoration(
                    labelText: 'Operação matemática (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<MathOperation?>(
                      value: null,
                      child: Text('Nenhuma'),
                    ),
                    ...MathOperation.values.map((op) => DropdownMenuItem(
                          value: op,
                          child: Row(
                            children: [
                              Icon(op.icon, size: 16),
                              const SizedBox(width: 8),
                              Text(op.displayName),
                            ],
                          ),
                        )),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedMathOperation = value),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
