import 'package:flutter/material.dart';

/// Tipos de dados suportados nas colunas
enum ColumnType {
  text('Texto', Icons.text_fields),
  number('Número', Icons.tag),
  checkbox('Checkbox', Icons.check_box),
  select('Seleção', Icons.arrow_drop_down),
  multiSelect('Multi-seleção', Icons.checklist),
  date('Data', Icons.calendar_today),
  datetime('Data/Hora', Icons.access_time),
  url('URL', Icons.link),
  email('Email', Icons.email),
  phone('Telefone', Icons.phone),
  file('Arquivo', Icons.attach_file),
  image('Imagem', Icons.image),
  note('Nota', Icons.note),
  relation('Relação', Icons.account_tree),
  formula('Fórmula', Icons.functions),
  rating('Avaliação', Icons.star),
  progress('Progresso', Icons.linear_scale),
  status('Status', Icons.assignment_turned_in),
  deadline('Deadline', Icons.schedule);

  const ColumnType(this.displayName, this.icon);

  final String displayName;
  final IconData icon;
}

/// Operações matemáticas para colunas numéricas
enum MathOperation {
  sum('Soma', Icons.add, 'SUM'),
  average('Média', Icons.trending_up, 'AVG'),
  count('Contar', Icons.tag, 'COUNT'),
  countEmpty('Contar Vazios', Icons.remove, 'COUNT_EMPTY'),
  countNotEmpty('Contar Não Vazios', Icons.add, 'COUNT_NOT_EMPTY'),
  min('Mínimo', Icons.south, 'MIN'),
  max('Máximo', Icons.north, 'MAX'),
  median('Mediana', Icons.timeline, 'MEDIAN'),
  range('Amplitude', Icons.linear_scale, 'RANGE');

  const MathOperation(this.displayName, this.icon, this.formula);

  final String displayName;
  final IconData icon;
  final String formula;
}

/// Representa uma opção de seleção
class SelectOption {
  final String id;
  final String name;
  final Color color;

  const SelectOption({
    required this.id,
    required this.name,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
    };
  }

  factory SelectOption.fromJson(Map<String, dynamic> json) {
    return SelectOption(
      id: json['id'],
      name: json['name'],
      color: Color(json['color']),
    );
  }
}

/// Representa uma coluna da tabela
class DatabaseColumn {
  final String id;
  final String name;
  final ColumnType type;
  final bool isRequired;
  final bool isPrimary;
  final Map<String, dynamic> config;
  final MathOperation? mathOperation;
  final int sortOrder;

  const DatabaseColumn({
    required this.id,
    required this.name,
    required this.type,
    this.isRequired = false,
    this.isPrimary = false,
    this.config = const {},
    this.mathOperation,
    this.sortOrder = 0,
  });

  DatabaseColumn copyWith({
    String? id,
    String? name,
    ColumnType? type,
    bool? isRequired,
    bool? isPrimary,
    Map<String, dynamic>? config,
    MathOperation? mathOperation,
    int? sortOrder,
  }) {
    return DatabaseColumn(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      isPrimary: isPrimary ?? this.isPrimary,
      config: config ?? this.config,
      mathOperation: mathOperation ?? this.mathOperation,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'isRequired': isRequired,
      'isPrimary': isPrimary,
      'config': config,
      'mathOperation': mathOperation?.name,
      'sortOrder': sortOrder,
    };
  }

  factory DatabaseColumn.fromJson(Map<String, dynamic> json) {
    return DatabaseColumn(
      id: json['id'],
      name: json['name'],
      type: ColumnType.values.firstWhere((e) => e.name == json['type']),
      isRequired: json['isRequired'] ?? false,
      isPrimary: json['isPrimary'] ?? false,
      config: Map<String, dynamic>.from(json['config'] ?? {}),
      mathOperation: json['mathOperation'] != null
          ? MathOperation.values
              .firstWhere((e) => e.name == json['mathOperation'])
          : null,
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  /// Obtém opções de seleção (para tipos select/multiSelect)
  List<SelectOption> get selectOptions {
    if (type != ColumnType.select && type != ColumnType.multiSelect) {
      return [];
    }

    final optionsData = config['options'] as List<dynamic>? ?? [];
    return optionsData.map((data) => SelectOption.fromJson(data)).toList();
  }

  /// Define opções de seleção
  DatabaseColumn withSelectOptions(List<SelectOption> options) {
    return copyWith(
      config: {
        ...config,
        'options': options.map((o) => o.toJson()).toList(),
      },
    );
  }

  /// Verifica se o tipo de coluna suporta operações matemáticas
  bool get supportsMathOperations {
    return type == ColumnType.number ||
        type == ColumnType.formula ||
        type == ColumnType.progress ||
        type == ColumnType.rating;
  }

  /// Verifica se é uma coluna computed (calculada)
  bool get isComputed {
    return type == ColumnType.formula || mathOperation != null;
  }

  /// Obtém opções padrão para o tipo Status
  static List<SelectOption> getDefaultStatusOptions() {
    return [
      const SelectOption(
        id: 'todo',
        name: 'Por fazer',
        color: Color(0xFFEF4444), // Red
      ),
      const SelectOption(
        id: 'in_progress',
        name: 'Em progresso',
        color: Color(0xFFF59E0B), // Amber
      ),
      const SelectOption(
        id: 'done',
        name: 'Concluído',
        color: Color(0xFF10B981), // Emerald
      ),
    ];
  }

  /// Cria uma coluna de status com opções predefinidas
  static DatabaseColumn createStatusColumn(String id, String name) {
    return DatabaseColumn(
      id: id,
      name: name,
      type: ColumnType.status,
      config: {
        'options': getDefaultStatusOptions().map((o) => o.toJson()).toList(),
      },
    );
  }
}

/// Representa o valor de uma célula
class DatabaseCellValue {
  final String columnId;
  final dynamic value;
  final DateTime lastModified;

  const DatabaseCellValue({
    required this.columnId,
    required this.value,
    required this.lastModified,
  });

  DatabaseCellValue copyWith({
    String? columnId,
    dynamic value,
    DateTime? lastModified,
  }) {
    return DatabaseCellValue(
      columnId: columnId ?? this.columnId,
      value: value ?? this.value,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'columnId': columnId,
      'value': _serializeValue(value),
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory DatabaseCellValue.fromJson(Map<String, dynamic> json) {
    return DatabaseCellValue(
      columnId: json['columnId'],
      value: _deserializeValue(json['value']),
      lastModified: DateTime.parse(json['lastModified']),
    );
  }

  static dynamic _serializeValue(dynamic value) {
    if (value is DateTime) {
      return value.toIso8601String();
    } else if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return value;
  }

  static dynamic _deserializeValue(dynamic value) {
    if (value is String && DateTime.tryParse(value) != null) {
      return DateTime.parse(value);
    }
    return value;
  }

  /// Obtém o valor como string para exibição
  String get displayValue {
    if (value == null) return '';

    if (value is List) {
      return (value as List).join(', ');
    } else if (value is DateTime) {
      return value.toString().split('.')[0]; // Remove microseconds
    } else if (value is double) {
      return value.toStringAsFixed(2);
    } else if (value is bool) {
      return value ? '✅' : '❌';
    }

    return value.toString();
  }

  /// Obtém o valor numérico (para operações matemáticas)
  double? get numericValue {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value);
    } else if (value is bool) {
      return value ? 1.0 : 0.0;
    }
    return null;
  }
}

/// Representa uma linha da tabela
class DatabaseRow {
  final String id;
  final String tableId;
  final Map<String, DatabaseCellValue> cells;
  final DateTime createdAt;
  final DateTime lastModified;
  final int sortOrder;

  const DatabaseRow({
    required this.id,
    required this.tableId,
    required this.cells,
    required this.createdAt,
    required this.lastModified,
    this.sortOrder = 0,
  });

  DatabaseRow copyWith({
    String? id,
    String? tableId,
    Map<String, DatabaseCellValue>? cells,
    DateTime? createdAt,
    DateTime? lastModified,
    int? sortOrder,
  }) {
    return DatabaseRow(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      cells: cells ?? this.cells,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableId': tableId,
      'cells': cells.map((key, value) => MapEntry(key, value.toJson())),
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'sortOrder': sortOrder,
    };
  }

  factory DatabaseRow.fromJson(Map<String, dynamic> json) {
    final cellsData = json['cells'] as Map<String, dynamic>? ?? {};
    final cells = cellsData.map(
      (key, value) => MapEntry(key, DatabaseCellValue.fromJson(value)),
    );

    return DatabaseRow(
      id: json['id'],
      tableId: json['tableId'],
      cells: cells,
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: DateTime.parse(json['lastModified']),
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  /// Obtém o valor de uma coluna específica
  DatabaseCellValue? getCell(String columnId) {
    return cells[columnId];
  }

  /// Define o valor de uma coluna
  DatabaseRow setCell(String columnId, dynamic value) {
    final newCells = Map<String, DatabaseCellValue>.from(cells);
    newCells[columnId] = DatabaseCellValue(
      columnId: columnId,
      value: value,
      lastModified: DateTime.now(),
    );

    return copyWith(
      cells: newCells,
      lastModified: DateTime.now(),
    );
  }

  /// Remove uma célula
  DatabaseRow removeCell(String columnId) {
    final newCells = Map<String, DatabaseCellValue>.from(cells);
    newCells.remove(columnId);

    return copyWith(
      cells: newCells,
      lastModified: DateTime.now(),
    );
  }
}

/// Representa uma tabela completa
class DatabaseTable {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<DatabaseColumn> columns;
  final List<DatabaseRow> rows;
  final DateTime createdAt;
  final DateTime lastModified;
  final Map<String, dynamic> config;

  const DatabaseTable({
    required this.id,
    required this.name,
    this.description = '',
    this.icon = Icons.table_chart,
    this.color = Colors.blue,
    required this.columns,
    required this.rows,
    required this.createdAt,
    required this.lastModified,
    this.config = const {},
  });

  DatabaseTable copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    List<DatabaseColumn>? columns,
    List<DatabaseRow>? rows,
    DateTime? createdAt,
    DateTime? lastModified,
    Map<String, dynamic>? config,
  }) {
    return DatabaseTable(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      config: config ?? this.config,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon.codePoint,
      'color': color.value,
      'columns': columns.map((c) => c.toJson()).toList(),
      'rows': rows.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'config': config,
    };
  }

  factory DatabaseTable.fromJson(Map<String, dynamic> json) {
    final columnsData = json['columns'] as List<dynamic>? ?? [];
    final rowsData = json['rows'] as List<dynamic>? ?? [];

    return DatabaseTable(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      icon: IconData(json['icon'] ?? Icons.table_chart.codePoint,
          fontFamily: 'MaterialIcons'),
      color: Color(json['color'] ?? Colors.blue.value),
      columns:
          columnsData.map((data) => DatabaseColumn.fromJson(data)).toList(),
      rows: rowsData.map((data) => DatabaseRow.fromJson(data)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: DateTime.parse(json['lastModified']),
      config: Map<String, dynamic>.from(json['config'] ?? {}),
    );
  }

  /// Cria uma nova tabela vazia
  factory DatabaseTable.empty({
    required String name,
    String? description,
    IconData? icon,
    Color? color,
  }) {
    final now = DateTime.now();
    final id = 'table_${now.millisecondsSinceEpoch}';

    return DatabaseTable(
      id: id,
      name: name,
      description: description ?? '',
      icon: icon ?? Icons.table_chart,
      color: color ?? Colors.blue,
      columns: [],
      rows: [],
      createdAt: now,
      lastModified: now,
    );
  }

  /// Adiciona uma nova coluna
  DatabaseTable addColumn(DatabaseColumn column) {
    final newColumns = List<DatabaseColumn>.from(columns)..add(column);
    return copyWith(
      columns: newColumns,
      lastModified: DateTime.now(),
    );
  }

  /// Remove uma coluna
  DatabaseTable removeColumn(String columnId) {
    final newColumns = columns.where((c) => c.id != columnId).toList();
    final newRows = rows.map((row) => row.removeCell(columnId)).toList();

    return copyWith(
      columns: newColumns,
      rows: newRows,
      lastModified: DateTime.now(),
    );
  }

  /// Atualiza uma coluna
  DatabaseTable updateColumn(DatabaseColumn column) {
    final newColumns =
        columns.map((c) => c.id == column.id ? column : c).toList();
    return copyWith(
      columns: newColumns,
      lastModified: DateTime.now(),
    );
  }

  /// Adiciona uma nova linha
  DatabaseTable addRow(DatabaseRow row) {
    final newRows = List<DatabaseRow>.from(rows)..add(row);
    return copyWith(
      rows: newRows,
      lastModified: DateTime.now(),
    );
  }

  /// Remove uma linha
  DatabaseTable removeRow(String rowId) {
    final newRows = rows.where((r) => r.id != rowId).toList();
    return copyWith(
      rows: newRows,
      lastModified: DateTime.now(),
    );
  }

  /// Atualiza uma linha
  DatabaseTable updateRow(DatabaseRow row) {
    final newRows = rows.map((r) => r.id == row.id ? row : r).toList();
    return copyWith(
      rows: newRows,
      lastModified: DateTime.now(),
    );
  }

  /// Obtém uma coluna pelo ID
  DatabaseColumn? getColumn(String columnId) {
    try {
      return columns.firstWhere((c) => c.id == columnId);
    } catch (e) {
      return null;
    }
  }

  /// Obtém uma linha pelo ID
  DatabaseRow? getRow(String rowId) {
    try {
      return rows.firstWhere((r) => r.id == rowId);
    } catch (e) {
      return null;
    }
  }

  /// Calcula operação matemática para uma coluna
  double? calculateMathOperation(String columnId, MathOperation operation) {
    final column = getColumn(columnId);
    if (column == null || !column.supportsMathOperations) return null;

    final values = rows
        .map((row) => row.getCell(columnId)?.numericValue)
        .where((value) => value != null)
        .cast<double>()
        .toList();

    if (values.isEmpty) return null;

    switch (operation) {
      case MathOperation.sum:
        return values.reduce((a, b) => a + b);
      case MathOperation.average:
        return values.reduce((a, b) => a + b) / values.length;
      case MathOperation.count:
        return values.length.toDouble();
      case MathOperation.countEmpty:
        return (rows.length - values.length).toDouble();
      case MathOperation.countNotEmpty:
        return values.length.toDouble();
      case MathOperation.min:
        return values.reduce((a, b) => a < b ? a : b);
      case MathOperation.max:
        return values.reduce((a, b) => a > b ? a : b);
      case MathOperation.median:
        values.sort();
        final middle = values.length ~/ 2;
        if (values.length % 2 == 0) {
          return (values[middle - 1] + values[middle]) / 2;
        } else {
          return values[middle];
        }
      case MathOperation.range:
        final min = values.reduce((a, b) => a < b ? a : b);
        final max = values.reduce((a, b) => a > b ? a : b);
        return max - min;
    }
  }

  /// Obtém resumo estatístico da tabela
  Map<String, dynamic> get summary {
    return {
      'totalRows': rows.length,
      'totalColumns': columns.length,
      'columnsWithMath': columns.where((c) => c.mathOperation != null).length,
      'computedColumns': columns.where((c) => c.isComputed).length,
      'lastModified': lastModified,
      'createdAt': createdAt,
    };
  }
}
