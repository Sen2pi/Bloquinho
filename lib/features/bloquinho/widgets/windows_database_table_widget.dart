/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../core/models/database_models.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../core/services/enhanced_pdf_export_service.dart';

class WindowsDatabaseTableWidget extends ConsumerStatefulWidget {
  final String tableId;
  final bool showMacOSHeader;

  const WindowsDatabaseTableWidget({
    super.key,
    required this.tableId,
    this.showMacOSHeader = true,
  });

  @override
  ConsumerState<WindowsDatabaseTableWidget> createState() =>
      _WindowsDatabaseTableWidgetState();
}

class _WindowsDatabaseTableWidgetState
    extends ConsumerState<WindowsDatabaseTableWidget> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  bool _copied = false;

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final tableAsync = ref.watch(databaseTableProvider(widget.tableId));

    return RepaintBoundary(
      key: _repaintBoundaryKey,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: tableAsync.when(
            data: (table) => table != null ? _buildTableContent(table, isDarkMode) : _buildErrorState('Tabela não encontrada', isDarkMode),
            loading: () => _buildLoadingState(isDarkMode),
            error: (error, stack) => _buildErrorState(error.toString(), isDarkMode),
          ),
        ),
      ),
    );
  }

  Widget _buildTableContent(DatabaseTable table, bool isDarkMode) {
    final headerColor = isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF5F5F5);
    final borderColor = isDarkMode ? const Color(0xFF404040) : const Color(0xFFE0E0E0);
    final backgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showMacOSHeader)
          _buildMacOSHeader(table, isDarkMode, headerColor, borderColor, textColor),
        _buildTable(table, isDarkMode, backgroundColor, borderColor, textColor, secondaryTextColor),
      ],
    );
  }

  Widget _buildMacOSHeader(DatabaseTable table, bool isDarkMode, Color headerColor, Color borderColor, Color textColor) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: headerColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Traffic lights
          _buildTrafficLight(const Color(0xFFFF5F57)), // Red
          const SizedBox(width: 8),
          _buildTrafficLight(const Color(0xFFFFBD2E)), // Yellow
          const SizedBox(width: 8),
          _buildTrafficLight(const Color(0xFF28CA42)), // Green

          const SizedBox(width: 16),

          // Table icon and name
          Icon(
            PhosphorIcons.table(),
            color: AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            table.name,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Row count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${table.rows.length} ${table.rows.length == 1 ? 'linha' : 'linhas'}',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const Spacer(),

          // Action buttons
          _buildHeaderButton(
            PhosphorIcons.copy(),
            'Copiar tabela',
            () => _copyTable(table),
            textColor,
          ),
          const SizedBox(width: 8),
          _buildHeaderButton(
            PhosphorIcons.downloadSimple(),
            'Exportar como CSV',
            () => _exportAsCSV(table),
            textColor,
          ),
          const SizedBox(width: 8),
          _buildHeaderButton(
            PhosphorIcons.image(),
            'Exportar como imagem',
            () => _exportAsImage(table),
            textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficLight(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, String tooltip, VoidCallback onPressed, Color textColor) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 16,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildTable(DatabaseTable table, bool isDarkMode, Color backgroundColor, Color borderColor, Color textColor, Color? secondaryTextColor) {
    if (table.columns.isEmpty) {
      return Container(
        height: 120,
        color: backgroundColor,
        child: Center(
          child: Text(
            'Tabela vazia',
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Container(
      color: backgroundColor,
      child: Scrollbar(
        controller: _horizontalController,
        thumbVisibility: true,
        child: Scrollbar(
          controller: _verticalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              controller: _verticalController,
              child: DataTable(
                border: TableBorder.all(
                  color: borderColor,
                  width: 1,
                ),
                headingRowColor: MaterialStateProperty.all(
                  isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF8F9FA),
                ),
                dataRowColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.hovered)) {
                    return isDarkMode ? const Color(0xFF333333) : const Color(0xFFF5F5F5);
                  }
                  return backgroundColor;
                }),
                headingTextStyle: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                dataTextStyle: TextStyle(
                  color: textColor,
                  fontSize: 12,
                ),
                columnSpacing: 24,
                horizontalMargin: 16,
                headingRowHeight: 48,
                dataRowHeight: 40,
                columns: table.columns.map((column) {
                  return DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getColumnTypeIcon(column.type.name),
                          size: 14,
                          color: _getColumnTypeColor(column.type.name),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            column.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                rows: table.rows.map((row) {
                  return DataRow(
                    cells: table.columns.map((column) {
                      final cellValue = row.cells[column.id]?.value ?? '';
                      return DataCell(
                        Container(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            cellValue.toString(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getColumnTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'text':
      case 'string':
        return PhosphorIcons.textT();
      case 'number':
      case 'int':
      case 'double':
        return PhosphorIcons.hash();
      case 'date':
      case 'datetime':
        return PhosphorIcons.calendar();
      case 'boolean':
      case 'bool':
        return PhosphorIcons.toggleLeft();
      case 'url':
      case 'link':
        return PhosphorIcons.link();
      case 'email':
        return PhosphorIcons.envelope();
      case 'file':
        return PhosphorIcons.file();
      default:
        return PhosphorIcons.textT();
    }
  }

  Color _getColumnTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'text':
      case 'string':
        return Colors.blue;
      case 'number':
      case 'int':
      case 'double':
        return Colors.green;
      case 'date':
      case 'datetime':
        return Colors.orange;
      case 'boolean':
      case 'bool':
        return Colors.purple;
      case 'url':
      case 'link':
        return Colors.indigo;
      case 'email':
        return Colors.red;
      case 'file':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLoadingState(bool isDarkMode) {
    final backgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Container(
      height: 160,
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Carregando tabela...',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, bool isDarkMode) {
    final backgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.red[300] : Colors.red[700];

    return Container(
      height: 160,
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.warning(),
              size: 32,
              color: textColor,
            ),
            const SizedBox(height: 12),
            Text(
              'Erro ao carregar tabela',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _copyTable(DatabaseTable table) async {
    // Convert table to CSV format
    final csv = _tableToCSV(table);
    await Clipboard.setData(ClipboardData(text: csv));
    
    setState(() => _copied = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tabela copiada para a área de transferência'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  String _tableToCSV(DatabaseTable table) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln(table.columns.map((col) => '"${col.name}"').join(','));
    
    // Rows
    for (final row in table.rows) {
      final values = table.columns.map((col) {
        final value = row.cells[col.id]?.value ?? '';
        return '"${value.toString().replaceAll('"', '""')}"';
      });
      buffer.writeln(values.join(','));
    }
    
    return buffer.toString();
  }

  void _exportAsCSV(DatabaseTable table) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exportando tabela como CSV...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      final csv = _tableToCSV(table);
      final pdfService = EnhancedPdfExportService();
      final filePath = await pdfService.exportTextAsFile(
        content: csv,
        fileName: 'tabela_${table.name}_${DateTime.now().millisecondsSinceEpoch}',
        extension: 'csv',
      );

      if (filePath != null) {
        await pdfService.openExportedFile(filePath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('CSV exportado com sucesso!\nSalvo em: $filePath'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao exportar CSV'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar CSV: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _exportAsImage(DatabaseTable table) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exportando tabela como imagem...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      final pdfService = EnhancedPdfExportService();
      final filePath = await pdfService.exportWidgetAsImage(
        widgetKey: _repaintBoundaryKey,
        fileName: 'tabela_${table.name}_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (filePath != null) {
        await pdfService.openExportedFile(filePath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Imagem exportada com sucesso!\nSalva em: $filePath'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao exportar imagem'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar imagem: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}