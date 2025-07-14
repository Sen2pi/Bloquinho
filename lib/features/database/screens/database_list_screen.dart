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
import 'package:bloquinho/features/database/screens/table_editor_screen.dart';
import 'package:bloquinho/features/database/widgets/create_table_dialog.dart';
import 'package:bloquinho/core/theme/app_colors.dart';

/// Tela principal que lista todas as tabelas do database
class DatabaseListScreen extends StatefulWidget {
  const DatabaseListScreen({super.key});

  @override
  State<DatabaseListScreen> createState() => _DatabaseListScreenState();
}

class _DatabaseListScreenState extends State<DatabaseListScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<DatabaseTable> _tables = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    setState(() => _isLoading = true);

    try {
      await _databaseService.initialize();
      _tables = _databaseService.tables;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar tabelas: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
        await _databaseService.createTable(
          name: resultMap['name'] as String,
          description: resultMap['description'] as String,
          icon: resultMap['icon'] as IconData,
          color: resultMap['color'] as Color,
        );
        await _loadTables();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao criar tabela: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteTable(DatabaseTable table) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
            'Tem certeza que deseja excluir a tabela "${table.name}"? Esta ação não pode ser desfeita.'),
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
        await _databaseService.deleteTable(table.id);
        await _loadTables();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Tabela "${table.name}" excluída com sucesso')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir tabela: $e')),
          );
        }
      }
    }
  }

  Future<void> _duplicateTable(DatabaseTable table) async {
    try {
      await _databaseService.duplicateTable(table.id);
      await _loadTables();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Tabela "${table.name}" duplicada com sucesso')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao duplicar tabela: $e')),
        );
      }
    }
  }

  void _openTable(DatabaseTable table) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => TableEditorScreen(table: table),
          ),
        )
        .then((_) => _loadTables()); // Recarregar ao voltar
  }

  List<DatabaseTable> get _filteredTables {
    if (_searchQuery.isEmpty) return _tables;

    return _databaseService.searchTables(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Voltar',
        ),
        title: Row(
          children: [
            Icon(
              Icons.table_chart,
              size: 24,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            const Text('Base de Dados'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTables,
            tooltip: 'Atualizar',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createTable,
            tooltip: 'Nova Tabela',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Pesquisar tabelas...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Lista de tabelas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTables.isEmpty
                    ? _buildEmptyState()
                    : _buildTablesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_chart_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Nenhuma tabela criada ainda'
                : 'Nenhuma tabela encontrada',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Crie sua primeira tabela para começar'
                : 'Tente uma pesquisa diferente',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _createTable,
              icon: const Icon(Icons.add),
              label: const Text('Criar Tabela'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTablesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredTables.length,
      itemBuilder: (context, index) {
        final table = _filteredTables[index];
        return _buildTableCard(table);
      },
    );
  }

  Widget _buildTableCard(DatabaseTable table) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openTable(table),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Ícone da tabela
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: table.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      table.icon,
                      color: table.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nome e descrição
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          table.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (table.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            table.description,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Menu de ações
                  PopupMenuButton<String>(
                    onSelected: (action) {
                      switch (action) {
                        case 'duplicate':
                          _duplicateTable(table);
                          break;
                        case 'delete':
                          _deleteTable(table);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy),
                            SizedBox(width: 8),
                            Text('Duplicar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Estatísticas da tabela
              Row(
                children: [
                  _buildStatChip(
                    icon: Icons.view_column,
                    label: '${table.columns.length} colunas',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    icon: Icons.table_rows,
                    label: '${table.rows.length} linhas',
                    color: Colors.green,
                  ),
                  if (table.columns.any((c) => c.mathOperation != null)) ...[
                    const SizedBox(width: 8),
                    _buildStatChip(
                      icon: Icons.functions,
                      label: 'Com fórmulas',
                      color: Colors.orange,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 8),

              // Data de modificação
              Text(
                'Modificado em ${_formatDate(table.lastModified)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'hoje às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
