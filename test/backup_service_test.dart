import 'package:flutter_test/flutter_test.dart';
import 'package:bloquinho/core/services/backup_service.dart';
import 'package:bloquinho/shared/models/document_models.dart';

void main() {
  group('BackupService JSON Serialization Tests', () {
    test('BackupData deve serializar e deserializar corretamente', () {
      // Arrange
      final workspace = Workspace(
        id: 'workspace1',
        name: 'Test Workspace',
        description: 'Test Description',
        ownerId: 'user1',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      final document = Document(
        id: 'doc1',
        title: 'Test Document',
        blocks: [
          DocumentBlock(
            id: 'block1',
            type: BlockType.text,
            content: 'Hello World',
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          DocumentBlock(
            id: 'block2',
            type: BlockType.heading1,
            content: 'Título Principal',
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
        createdBy: 'user1',
      );

      final originalBackup = BackupData(
        workspaces: [workspace],
        documents: [document],
        settings: {'theme': 'dark', 'autoSave': true, 'language': 'pt-BR'},
        createdAt: DateTime(2024, 1, 1),
        version: '1.0.0',
        appVersion: '1.0.0',
      );

      // Act
      final json = originalBackup.toJson();
      final restoredBackup = BackupData.fromJson(json);

      // Assert
      expect(restoredBackup.workspaces.length, equals(1));
      expect(restoredBackup.documents.length, equals(1));
      expect(restoredBackup.workspaces.first.name, equals('Test Workspace'));
      expect(restoredBackup.workspaces.first.description,
          equals('Test Description'));
      expect(restoredBackup.documents.first.title, equals('Test Document'));
      expect(restoredBackup.documents.first.blocks.length, equals(2));
      expect(restoredBackup.documents.first.blocks.first.content,
          equals('Hello World'));
      expect(restoredBackup.documents.first.blocks.first.type,
          equals(BlockType.text));
      expect(restoredBackup.documents.first.blocks.last.type,
          equals(BlockType.heading1));
      expect(restoredBackup.settings['theme'], equals('dark'));
      expect(restoredBackup.settings['autoSave'], equals(true));
      expect(restoredBackup.settings['language'], equals('pt-BR'));
      expect(restoredBackup.version, equals('1.0.0'));
      expect(restoredBackup.appVersion, equals('1.0.0'));
      expect(restoredBackup.createdAt, equals(DateTime(2024, 1, 1)));
    });

    test('BackupMetadata deve serializar e deserializar corretamente', () {
      // Arrange
      final originalMetadata = BackupMetadata(
        fileName: 'backup_test.json',
        createdAt: DateTime(2024, 1, 1),
        fileSize: 1024,
        documentsCount: 5,
        workspacesCount: 2,
        version: '1.0.0',
      );

      // Act
      final json = originalMetadata.toJson();
      final restoredMetadata = BackupMetadata.fromJson(json);

      // Assert
      expect(restoredMetadata.fileName, equals('backup_test.json'));
      expect(restoredMetadata.createdAt, equals(DateTime(2024, 1, 1)));
      expect(restoredMetadata.fileSize, equals(1024));
      expect(restoredMetadata.documentsCount, equals(5));
      expect(restoredMetadata.workspacesCount, equals(2));
      expect(restoredMetadata.version, equals('1.0.0'));
    });

    test('BackupData com dados vazios deve funcionar', () {
      // Arrange
      final emptyBackup = BackupData(
        workspaces: [],
        documents: [],
        settings: {},
        createdAt: DateTime(2024, 1, 1),
        version: '1.0.0',
        appVersion: '1.0.0',
      );

      // Act
      final json = emptyBackup.toJson();
      final restoredBackup = BackupData.fromJson(json);

      // Assert
      expect(restoredBackup.workspaces, isEmpty);
      expect(restoredBackup.documents, isEmpty);
      expect(restoredBackup.settings, isEmpty);
      expect(restoredBackup.version, equals('1.0.0'));
      expect(restoredBackup.appVersion, equals('1.0.0'));
    });

    test('DocumentBlock deve serializar corretamente todos os tipos', () {
      final blockTypes = [
        BlockType.text,
        BlockType.heading1,
        BlockType.heading2,
        BlockType.heading3,
        BlockType.bulletList,
        BlockType.numberedList,
        BlockType.quote,
        BlockType.code,
        BlockType.divider,
        BlockType.image,
        BlockType.table,
        BlockType.database,
        BlockType.callout,
        BlockType.toggle,
        BlockType.bookmark,
      ];

      for (final blockType in blockTypes) {
        // Arrange
        final block = DocumentBlock(
          id: 'block_${blockType.name}',
          type: blockType,
          content: 'Content for ${blockType.name}',
          properties: {'key': 'value'},
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        // Act
        final json = block.toJson();
        final restoredBlock = DocumentBlock.fromJson(json);

        // Assert
        expect(restoredBlock.id, equals('block_${blockType.name}'));
        expect(restoredBlock.type, equals(blockType));
        expect(restoredBlock.content, equals('Content for ${blockType.name}'));
        expect(restoredBlock.properties['key'], equals('value'));
      }
    });

    test('Workspace com configurações complexas deve funcionar', () {
      // Arrange
      final workspace = Workspace(
        id: 'workspace1',
        name: 'Workspace Complexo',
        description: 'Um workspace com muitas configurações',
        icon: '🚀',
        documentIds: ['doc1', 'doc2', 'doc3'],
        settings: {
          'theme': 'dark',
          'notifications': true,
          'autoSave': false,
          'collaborators': ['user1', 'user2'],
          'permissions': {
            'read': true,
            'write': true,
            'admin': false,
          },
        },
        ownerId: 'admin',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      // Act
      final json = workspace.toJson();
      final restoredWorkspace = Workspace.fromJson(json);

      // Assert
      expect(restoredWorkspace.id, equals('workspace1'));
      expect(restoredWorkspace.name, equals('Workspace Complexo'));
      expect(restoredWorkspace.description,
          equals('Um workspace com muitas configurações'));
      expect(restoredWorkspace.icon, equals('🚀'));
      expect(restoredWorkspace.documentIds, hasLength(3));
      expect(restoredWorkspace.documentIds, contains('doc1'));
      expect(restoredWorkspace.documentIds, contains('doc2'));
      expect(restoredWorkspace.documentIds, contains('doc3'));
      expect(restoredWorkspace.settings['theme'], equals('dark'));
      expect(restoredWorkspace.settings['notifications'], equals(true));
      expect(restoredWorkspace.settings['autoSave'], equals(false));
      expect(restoredWorkspace.settings['collaborators'], hasLength(2));
      expect(restoredWorkspace.settings['permissions']['read'], equals(true));
      expect(restoredWorkspace.settings['permissions']['write'], equals(true));
      expect(restoredWorkspace.settings['permissions']['admin'], equals(false));
      expect(restoredWorkspace.ownerId, equals('admin'));
    });

    test('Document com blocos aninhados deve funcionar', () {
      // Arrange
      final childBlock = DocumentBlock(
        id: 'child1',
        type: BlockType.text,
        content: 'Conteúdo filho',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final parentBlock = DocumentBlock(
        id: 'parent1',
        type: BlockType.toggle,
        content: 'Bloco expansível',
        children: [childBlock],
        properties: {'expanded': true},
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final document = Document(
        id: 'doc1',
        title: 'Documento com Blocos Aninhados',
        icon: '📝',
        coverImage: 'https://example.com/cover.jpg',
        blocks: [parentBlock],
        tags: ['importante', 'trabalho'],
        isPublic: true,
        isFavorite: true,
        isArchived: false,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
        createdBy: 'user1',
      );

      // Act
      final json = document.toJson();
      final restoredDocument = Document.fromJson(json);

      // Assert
      expect(restoredDocument.id, equals('doc1'));
      expect(restoredDocument.title, equals('Documento com Blocos Aninhados'));
      expect(restoredDocument.icon, equals('📝'));
      expect(
          restoredDocument.coverImage, equals('https://example.com/cover.jpg'));
      expect(restoredDocument.blocks, hasLength(1));
      expect(restoredDocument.blocks.first.type, equals(BlockType.toggle));
      expect(restoredDocument.blocks.first.children, hasLength(1));
      expect(restoredDocument.blocks.first.children.first.content,
          equals('Conteúdo filho'));
      expect(
          restoredDocument.blocks.first.properties['expanded'], equals(true));
      expect(restoredDocument.tags, hasLength(2));
      expect(restoredDocument.tags, contains('importante'));
      expect(restoredDocument.tags, contains('trabalho'));
      expect(restoredDocument.isPublic, equals(true));
      expect(restoredDocument.isFavorite, equals(true));
      expect(restoredDocument.isArchived, equals(false));
      expect(restoredDocument.createdBy, equals('user1'));
    });

    test('BackupData com estrutura completa deve preservar integridade', () {
      // Arrange - Criar estrutura complexa
      final workspace1 = Workspace(
        id: 'ws1',
        name: 'Workspace Principal',
        documentIds: ['doc1', 'doc2'],
        ownerId: 'user1',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final workspace2 = Workspace(
        id: 'ws2',
        name: 'Workspace Secundário',
        documentIds: ['doc3'],
        ownerId: 'user2',
        createdAt: DateTime(2024, 1, 2),
        updatedAt: DateTime(2024, 1, 2),
      );

      final doc1 = Document(
        id: 'doc1',
        title: 'Documento 1',
        blocks: [
          DocumentBlock(
            id: 'b1',
            type: BlockType.heading1,
            content: 'Título',
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          DocumentBlock(
            id: 'b2',
            type: BlockType.text,
            content: 'Parágrafo de texto',
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ],
        isFavorite: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        createdBy: 'user1',
      );

      final doc2 = Document(
        id: 'doc2',
        title: 'Documento 2',
        blocks: [],
        isArchived: true,
        createdAt: DateTime(2024, 1, 2),
        updatedAt: DateTime(2024, 1, 2),
        createdBy: 'user1',
      );

      final doc3 = Document(
        id: 'doc3',
        title: 'Documento 3',
        blocks: [
          DocumentBlock(
            id: 'b3',
            type: BlockType.quote,
            content: 'Uma citação importante',
            createdAt: DateTime(2024, 1, 2),
            updatedAt: DateTime(2024, 1, 2),
          ),
        ],
        isPublic: true,
        createdAt: DateTime(2024, 1, 2),
        updatedAt: DateTime(2024, 1, 2),
        createdBy: 'user2',
      );

      final backup = BackupData(
        workspaces: [workspace1, workspace2],
        documents: [doc1, doc2, doc3],
        settings: {
          'theme': 'system',
          'language': 'pt-BR',
          'autoSave': true,
          'syncEnabled': true,
          'version': '1.0.0',
        },
        createdAt: DateTime(2024, 1, 3),
        version: '1.0.0',
        appVersion: '1.0.0',
      );

      // Act
      final json = backup.toJson();
      final restored = BackupData.fromJson(json);

      // Assert - Verificar integridade completa
      expect(restored.workspaces, hasLength(2));
      expect(restored.documents, hasLength(3));

      // Workspace 1
      final restoredWs1 =
          restored.workspaces.firstWhere((ws) => ws.id == 'ws1');
      expect(restoredWs1.name, equals('Workspace Principal'));
      expect(restoredWs1.documentIds, hasLength(2));
      expect(restoredWs1.documentIds, containsAll(['doc1', 'doc2']));

      // Workspace 2
      final restoredWs2 =
          restored.workspaces.firstWhere((ws) => ws.id == 'ws2');
      expect(restoredWs2.name, equals('Workspace Secundário'));
      expect(restoredWs2.documentIds, contains('doc3'));

      // Document 1
      final restoredDoc1 = restored.documents.firstWhere((d) => d.id == 'doc1');
      expect(restoredDoc1.title, equals('Documento 1'));
      expect(restoredDoc1.blocks, hasLength(2));
      expect(restoredDoc1.isFavorite, equals(true));
      expect(restoredDoc1.isArchived, equals(false));

      // Document 2
      final restoredDoc2 = restored.documents.firstWhere((d) => d.id == 'doc2');
      expect(restoredDoc2.title, equals('Documento 2'));
      expect(restoredDoc2.blocks, isEmpty);
      expect(restoredDoc2.isArchived, equals(true));

      // Document 3
      final restoredDoc3 = restored.documents.firstWhere((d) => d.id == 'doc3');
      expect(restoredDoc3.title, equals('Documento 3'));
      expect(restoredDoc3.blocks, hasLength(1));
      expect(restoredDoc3.isPublic, equals(true));
      expect(restoredDoc3.blocks.first.type, equals(BlockType.quote));

      // Settings
      expect(restored.settings['theme'], equals('system'));
      expect(restored.settings['language'], equals('pt-BR'));
      expect(restored.settings['autoSave'], equals(true));
      expect(restored.settings['syncEnabled'], equals(true));

      // Metadata
      expect(restored.version, equals('1.0.0'));
      expect(restored.appVersion, equals('1.0.0'));
      expect(restored.createdAt, equals(DateTime(2024, 1, 3)));
    });
  });
}
