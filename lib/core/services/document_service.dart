import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../shared/models/document_models.dart';

class DocumentService {
  static Database? _database;
  static const String _databaseName = 'bloquinho.db';
  static const int _databaseVersion = 1;

  // Nomes das tabelas
  static const String _documentsTable = 'documents';
  static const String _blocksTable = 'blocks';
  static const String _workspacesTable = 'workspaces';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Tabela de workspaces
    await db.execute('''
      CREATE TABLE $_workspacesTable(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        document_ids TEXT,
        settings TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        owner_id TEXT NOT NULL
      )
    ''');

    // Tabela de documentos
    await db.execute('''
      CREATE TABLE $_documentsTable(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        icon TEXT,
        cover_image TEXT,
        parent_id TEXT,
        tags TEXT,
        is_public INTEGER DEFAULT 0,
        is_favorite INTEGER DEFAULT 0,
        is_archived INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        created_by TEXT NOT NULL,
        FOREIGN KEY (parent_id) REFERENCES $_documentsTable (id)
      )
    ''');

    // Tabela de blocos
    await db.execute('''
      CREATE TABLE $_blocksTable(
        id TEXT PRIMARY KEY,
        document_id TEXT NOT NULL,
        parent_block_id TEXT,
        type TEXT NOT NULL,
        content TEXT,
        properties TEXT,
        order_index INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (document_id) REFERENCES $_documentsTable (id) ON DELETE CASCADE,
        FOREIGN KEY (parent_block_id) REFERENCES $_blocksTable (id) ON DELETE CASCADE
      )
    ''');

    // Criar workspace padrão
    final defaultWorkspace = Workspace.create(
      name: 'Meu Workspace',
      description: 'Workspace pessoal',
    );

    await _insertWorkspace(db, defaultWorkspace);
  }

  // WORKSPACE OPERATIONS
  Future<Workspace> createWorkspace(Workspace workspace) async {
    final db = await database;
    await _insertWorkspace(db, workspace);
    return workspace;
  }

  Future<void> _insertWorkspace(Database db, Workspace workspace) async {
    await db.insert(
      _workspacesTable,
      {
        'id': workspace.id,
        'name': workspace.name,
        'description': workspace.description,
        'icon': workspace.icon,
        'document_ids': jsonEncode(workspace.documentIds),
        'settings': jsonEncode(workspace.settings),
        'created_at': workspace.createdAt.toIso8601String(),
        'updated_at': workspace.updatedAt.toIso8601String(),
        'owner_id': workspace.ownerId,
      },
    );
  }

  Future<List<Workspace>> getAllWorkspaces() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_workspacesTable);

    return List.generate(maps.length, (i) {
      return Workspace(
        id: maps[i]['id'],
        name: maps[i]['name'],
        description: maps[i]['description'] ?? '',
        icon: maps[i]['icon'] ?? '🏠',
        documentIds:
            List<String>.from(jsonDecode(maps[i]['document_ids'] ?? '[]')),
        settings:
            Map<String, dynamic>.from(jsonDecode(maps[i]['settings'] ?? '{}')),
        createdAt: DateTime.parse(maps[i]['created_at']),
        updatedAt: DateTime.parse(maps[i]['updated_at']),
        ownerId: maps[i]['owner_id'],
      );
    });
  }

  // DOCUMENT OPERATIONS
  Future<Document> createDocument(Document document) async {
    final db = await database;

    // Inserir documento
    await db.insert(
      _documentsTable,
      {
        'id': document.id,
        'title': document.title,
        'icon': document.icon,
        'cover_image': document.coverImage,
        'parent_id': document.parentId,
        'tags': jsonEncode(document.tags),
        'is_public': document.isPublic ? 1 : 0,
        'is_favorite': document.isFavorite ? 1 : 0,
        'is_archived': document.isArchived ? 1 : 0,
        'created_at': document.createdAt.toIso8601String(),
        'updated_at': document.updatedAt.toIso8601String(),
        'created_by': document.createdBy,
      },
    );

    // Inserir blocos
    for (int i = 0; i < document.blocks.length; i++) {
      await _insertBlock(db, document.id, document.blocks[i], i);
    }

    return document;
  }

  Future<void> _insertBlock(
    Database db,
    String documentId,
    DocumentBlock block,
    int orderIndex, [
    String? parentBlockId,
  ]) async {
    await db.insert(
      _blocksTable,
      {
        'id': block.id,
        'document_id': documentId,
        'parent_block_id': parentBlockId,
        'type': block.type.name,
        'content': block.content,
        'properties': jsonEncode(block.properties),
        'order_index': orderIndex,
        'created_at': block.createdAt.toIso8601String(),
        'updated_at': block.updatedAt.toIso8601String(),
      },
    );

    // Inserir blocos filhos
    for (int i = 0; i < block.children.length; i++) {
      await _insertBlock(db, documentId, block.children[i], i, block.id);
    }
  }

  Future<Document?> getDocument(String id) async {
    final db = await database;

    final List<Map<String, dynamic>> docMaps = await db.query(
      _documentsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (docMaps.isEmpty) return null;

    final docMap = docMaps.first;
    final blocks = await _getDocumentBlocks(db, id);

    return Document(
      id: docMap['id'],
      title: docMap['title'],
      icon: docMap['icon'] ?? '📄',
      coverImage: docMap['cover_image'] ?? '',
      blocks: blocks,
      parentId: docMap['parent_id'],
      tags: List<String>.from(jsonDecode(docMap['tags'] ?? '[]')),
      isPublic: docMap['is_public'] == 1,
      isFavorite: docMap['is_favorite'] == 1,
      isArchived: docMap['is_archived'] == 1,
      createdAt: DateTime.parse(docMap['created_at']),
      updatedAt: DateTime.parse(docMap['updated_at']),
      createdBy: docMap['created_by'],
    );
  }

  Future<List<DocumentBlock>> _getDocumentBlocks(
      Database db, String documentId) async {
    final List<Map<String, dynamic>> blockMaps = await db.query(
      _blocksTable,
      where: 'document_id = ? AND parent_block_id IS NULL',
      whereArgs: [documentId],
      orderBy: 'order_index ASC',
    );

    List<DocumentBlock> blocks = [];
    for (var blockMap in blockMaps) {
      final block = await _buildBlockFromMap(db, blockMap);
      blocks.add(block);
    }

    return blocks;
  }

  Future<DocumentBlock> _buildBlockFromMap(
      Database db, Map<String, dynamic> blockMap) async {
    // Buscar blocos filhos
    final childMaps = await db.query(
      _blocksTable,
      where: 'parent_block_id = ?',
      whereArgs: [blockMap['id']],
      orderBy: 'order_index ASC',
    );

    List<DocumentBlock> children = [];
    for (var childMap in childMaps) {
      final child = await _buildBlockFromMap(db, childMap);
      children.add(child);
    }

    return DocumentBlock(
      id: blockMap['id'],
      type: BlockType.values.firstWhere(
        (e) => e.name == blockMap['type'],
        orElse: () => BlockType.text,
      ),
      content: blockMap['content'] ?? '',
      properties:
          Map<String, dynamic>.from(jsonDecode(blockMap['properties'] ?? '{}')),
      children: children,
      createdAt: DateTime.parse(blockMap['created_at']),
      updatedAt: DateTime.parse(blockMap['updated_at']),
    );
  }

  Future<List<Document>> getAllDocuments({
    bool includeArchived = false,
    String? parentId,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (!includeArchived) {
      whereClause = 'is_archived = ?';
      whereArgs.add(0);
    }

    if (parentId != null) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += 'parent_id = ?';
      whereArgs.add(parentId);
    } else {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += 'parent_id IS NULL';
    }

    final List<Map<String, dynamic>> maps = await db.query(
      _documentsTable,
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'updated_at DESC',
    );

    List<Document> documents = [];
    for (var map in maps) {
      final blocks = await _getDocumentBlocks(db, map['id']);
      documents.add(Document(
        id: map['id'],
        title: map['title'],
        icon: map['icon'] ?? '📄',
        coverImage: map['cover_image'] ?? '',
        blocks: blocks,
        parentId: map['parent_id'],
        tags: List<String>.from(jsonDecode(map['tags'] ?? '[]')),
        isPublic: map['is_public'] == 1,
        isFavorite: map['is_favorite'] == 1,
        isArchived: map['is_archived'] == 1,
        createdAt: DateTime.parse(map['created_at']),
        updatedAt: DateTime.parse(map['updated_at']),
        createdBy: map['created_by'],
      ));
    }

    return documents;
  }

  Future<Document> updateDocument(Document document) async {
    final db = await database;

    // Atualizar documento
    await db.update(
      _documentsTable,
      {
        'title': document.title,
        'icon': document.icon,
        'cover_image': document.coverImage,
        'parent_id': document.parentId,
        'tags': jsonEncode(document.tags),
        'is_public': document.isPublic ? 1 : 0,
        'is_favorite': document.isFavorite ? 1 : 0,
        'is_archived': document.isArchived ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [document.id],
    );

    // Remover blocos existentes
    await db.delete(
      _blocksTable,
      where: 'document_id = ?',
      whereArgs: [document.id],
    );

    // Inserir blocos atualizados
    for (int i = 0; i < document.blocks.length; i++) {
      await _insertBlock(db, document.id, document.blocks[i], i);
    }

    return document;
  }

  Future<void> deleteDocument(String id) async {
    final db = await database;

    // Os blocos serão deletados automaticamente devido ao ON DELETE CASCADE
    await db.delete(
      _documentsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Document>> searchDocuments(String query) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      _documentsTable,
      where: 'title LIKE ? AND is_archived = ?',
      whereArgs: ['%$query%', 0],
      orderBy: 'updated_at DESC',
    );

    List<Document> documents = [];
    for (var map in maps) {
      final blocks = await _getDocumentBlocks(db, map['id']);
      documents.add(Document(
        id: map['id'],
        title: map['title'],
        icon: map['icon'] ?? '📄',
        coverImage: map['cover_image'] ?? '',
        blocks: blocks,
        parentId: map['parent_id'],
        tags: List<String>.from(jsonDecode(map['tags'] ?? '[]')),
        isPublic: map['is_public'] == 1,
        isFavorite: map['is_favorite'] == 1,
        isArchived: map['is_archived'] == 1,
        createdAt: DateTime.parse(map['created_at']),
        updatedAt: DateTime.parse(map['updated_at']),
        createdBy: map['created_by'],
      ));
    }

    return documents;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
