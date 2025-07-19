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
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';

/// Widget para renderizar tabelas bem formatadas e editáveis
class EditableTableWidget extends ConsumerStatefulWidget {
  final String tableName;
  final List<List<String>> data;
  final Function(List<List<String>>)? onDataChanged;
  final bool isEditable;

  const EditableTableWidget({
    super.key,
    required this.tableName,
    required this.data,
    this.onDataChanged,
    this.isEditable = true,
  });

  @override
  ConsumerState<EditableTableWidget> createState() =>
      _EditableTableWidgetState();
}

class _EditableTableWidgetState extends ConsumerState<EditableTableWidget> {
  late List<List<String>> _tableData;
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tableData = List.from(widget.data.map((row) => List.from(row)));
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da tabela
          _buildTableHeader(isDarkMode),

          // Conteúdo da tabela
          _buildTableContent(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildTableHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.table(),
            size: 16,
            color: isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            widget.tableName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const Spacer(),
          if (widget.isEditable) ...[
            IconButton(
              onPressed: _addRow,
              icon: Icon(
                PhosphorIcons.plus(),
                size: 16,
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              tooltip: 'Adicionar linha',
            ),
            IconButton(
              onPressed: _addColumn,
              icon: Icon(
                PhosphorIcons.plus(),
                size: 16,
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              tooltip: 'Adicionar coluna',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTableContent(bool isDarkMode) {
    if (_tableData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Tabela vazia',
            style: TextStyle(
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      controller: _verticalController,
      child: SingleChildScrollView(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          dataTextStyle: TextStyle(
            color: isDarkMode
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          columns: _buildColumns(isDarkMode),
          rows: _buildRows(isDarkMode),
          border: TableBorder(
            horizontalInside: BorderSide(
              color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
            verticalInside: BorderSide(
              color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns(bool isDarkMode) {
    final maxColumns = _tableData.fold<int>(
        0, (max, row) => row.length > max ? row.length : max);

    return List.generate(maxColumns, (index) {
      return DataColumn(
        label: widget.isEditable
            ? _buildEditableHeader(index, isDarkMode)
            : Text('Coluna ${index + 1}'),
      );
    });
  }

  Widget _buildEditableHeader(int index, bool isDarkMode) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          hintText: 'Coluna ${index + 1}',
          hintStyle: TextStyle(
            color: isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDarkMode
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
        onChanged: (value) {
          // Atualizar cabeçalho da coluna
          // Por enquanto, apenas placeholder
        },
      ),
    );
  }

  List<DataRow> _buildRows(bool isDarkMode) {
    return List.generate(_tableData.length, (rowIndex) {
      return DataRow(
        cells: List.generate(_tableData[rowIndex].length, (colIndex) {
          return DataCell(
            widget.isEditable
                ? _buildEditableCell(rowIndex, colIndex, isDarkMode)
                : Text(_tableData[rowIndex][colIndex]),
          );
        }),
      );
    });
  }

  Widget _buildEditableCell(int rowIndex, int colIndex, bool isDarkMode) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        style: TextStyle(
          fontSize: 14,
          color: isDarkMode
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
        controller: TextEditingController(text: _tableData[rowIndex][colIndex]),
        onChanged: (value) {
          _tableData[rowIndex][colIndex] = value;
          widget.onDataChanged?.call(_tableData);
        },
      ),
    );
  }

  void _addRow() {
    setState(() {
      final maxColumns = _tableData.fold<int>(
          0, (max, row) => row.length > max ? row.length : max);
      _tableData.add(List.generate(maxColumns, (index) => ''));
      widget.onDataChanged?.call(_tableData);
    });
  }

  void _addColumn() {
    setState(() {
      for (int i = 0; i < _tableData.length; i++) {
        _tableData[i].add('');
      }
      widget.onDataChanged?.call(_tableData);
    });
  }

  void _removeRow(int rowIndex) {
    setState(() {
      _tableData.removeAt(rowIndex);
      widget.onDataChanged?.call(_tableData);
    });
  }

  void _removeColumn(int colIndex) {
    setState(() {
      for (int i = 0; i < _tableData.length; i++) {
        if (colIndex < _tableData[i].length) {
          _tableData[i].removeAt(colIndex);
        }
      }
      widget.onDataChanged?.call(_tableData);
    });
  }
}
