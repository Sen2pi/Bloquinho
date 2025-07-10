import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:bloquinho/features/bloquinho/models/notion_block.dart';
import 'package:bloquinho/features/bloquinho/services/notion_page_service.dart';

/// Mock para path_provider
class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return '/tmp';
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp/docs';
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return '/tmp/support';
  }
}

void main() {
  group('Sistema Notion-like Tests', () {
    late NotionPageService pageService;

    setUpAll(() async {
      // Mock do path provider
      PathProviderPlatform.instance = MockPathProviderPlatform();

      // Inicializar Hive em modo de teste
      await Hive.initFlutter();

      pageService = NotionPageService();
    });

    tearDownAll(() async {
      await Hive.deleteFromDisk();
    });

    group('NotionBlock Tests', () {
      test('Deve criar bloco com valores padrão', () {
        final block = NotionBlock.create();

        expect(block.id, isNotEmpty);
        expect(block.type, NotionBlockType.text);
        expect(block.content, isEmpty);
        expect(block.properties, isA<NotionBlockProperties>());
        expect(block.children, isEmpty);
        expect(block.createdAt, isA<DateTime>());
        expect(block.updatedAt, isA<DateTime>());
      });

      test('Deve criar bloco com parâmetros customizados', () {
        final properties =
            NotionBlockProperties({'bold': true, 'italic': true});
        final block = NotionBlock.create(
          type: NotionBlockType.heading1,
          content: 'Título de teste',
          properties: properties,
        );

        expect(block.type, NotionBlockType.heading1);
        expect(block.content, 'Título de teste');
        expect(block.properties.bold, isTrue);
        expect(block.properties.italic, isTrue);
      });

      test('Deve verificar tipos de blocos corretamente', () {
        final textBlock = NotionBlock.create(type: NotionBlockType.text);
        final headingBlock = NotionBlock.create(type: NotionBlockType.heading1);
        final listBlock = NotionBlock.create(type: NotionBlockType.bulletList);
        final imageBlock = NotionBlock.create(type: NotionBlockType.image);

        expect(textBlock.isTextBlock, isTrue);
        expect(headingBlock.isTextBlock, isTrue);
        expect(headingBlock.isHeading, isTrue);
        expect(listBlock.isListBlock, isTrue);
        expect(imageBlock.isMediaBlock, isTrue);
      });

      test('Deve serializar e deserializar JSON corretamente', () {
        final originalBlock = NotionBlock.create(
          type: NotionBlockType.heading2,
          content: 'Conteúdo de teste',
          properties: NotionBlockProperties({
            'bold': true,
            'color': 'red',
            'level': 2,
          }),
        );

        final json = originalBlock.toJson();
        final deserializedBlock = NotionBlock.fromJson(json);

        expect(deserializedBlock.id, originalBlock.id);
        expect(deserializedBlock.type, originalBlock.type);
        expect(deserializedBlock.content, originalBlock.content);
        expect(deserializedBlock.properties.bold, isTrue);
        expect(deserializedBlock.properties.data['color'], 'red');
        expect(deserializedBlock.properties.level, 2);
      });

      test('Deve criar blocos com hierarquia de filhos', () {
        final childBlock1 = NotionBlock.create(
          type: NotionBlockType.text,
          content: 'Filho 1',
        );

        final childBlock2 = NotionBlock.create(
          type: NotionBlockType.text,
          content: 'Filho 2',
        );

        final parentBlock = NotionBlock.create(
          type: NotionBlockType.toggleList,
          content: 'Lista expansível',
          children: [childBlock1, childBlock2],
        );

        expect(parentBlock.children.length, 2);
        expect(parentBlock.children[0].content, 'Filho 1');
        expect(parentBlock.children[1].content, 'Filho 2');
        expect(parentBlock.canHaveChildren, isTrue);
      });
    });

    group('NotionBlockProperties Tests', () {
      test('Deve criar propriedades vazias por padrão', () {
        const properties = NotionBlockProperties();

        expect(properties.data, isEmpty);
        expect(properties.bold, isFalse);
        expect(properties.italic, isFalse);
        expect(properties.checked, isFalse);
        expect(properties.level, 1);
      });

      test('Deve acessar propriedades específicas', () {
        final properties = NotionBlockProperties({
          'bold': true,
          'italic': false,
          'checked': true,
          'level': 3,
          'language': 'dart',
          'url': 'https://example.com',
          'icon': '💡',
        });

        expect(properties.bold, isTrue);
        expect(properties.italic, isFalse);
        expect(properties.checked, isTrue);
        expect(properties.level, 3);
        expect(properties.language, 'dart');
        expect(properties.url, 'https://example.com');
        expect(properties.icon, '💡');
      });

      test('Deve fazer copyWith corretamente', () {
        final original = NotionBlockProperties({'bold': true, 'color': 'blue'});
        final updated = original.copyWith({'italic': true, 'color': 'red'});

        expect(updated.bold, isTrue); // Mantido
        expect(updated.italic, isTrue); // Adicionado
        expect(updated.data['color'], 'red'); // Atualizado
      });
    });

    group('SlashCommands Tests', () {
      test('Deve encontrar comandos por trigger', () {
        final command = SlashCommands.findByTrigger('h1');

        expect(command, isNotNull);
        expect(command!.blockType, NotionBlockType.heading1);
        expect(command.displayName, 'Título 1');
      });

      test('Deve buscar comandos por texto', () {
        final results = SlashCommands.search('título');

        expect(results, isNotEmpty);
        expect(results.any((cmd) => cmd.trigger == 'h1'), isTrue);
        expect(results.any((cmd) => cmd.trigger == 'h2'), isTrue);
        expect(results.any((cmd) => cmd.trigger == 'h3'), isTrue);
      });

      test('Deve retornar todos comandos para busca vazia', () {
        final results = SlashCommands.search('');

        expect(results.length, SlashCommands.all.length);
      });

      test('Deve buscar por descrição', () {
        final results = SlashCommands.search('lista');

        expect(results, isNotEmpty);
        expect(results.any((cmd) => cmd.trigger == 'bullet'), isTrue);
        expect(results.any((cmd) => cmd.trigger == 'numbered'), isTrue);
        expect(results.any((cmd) => cmd.trigger == 'todo'), isTrue);
      });
    });

    group('NotionPage Tests', () {
      test('Deve criar página com valores padrão', () {
        final page = NotionPage.create(
          title: 'Página de Teste',
          workspaceId: 'workspace-1',
        );

        expect(page.id, isNotEmpty);
        expect(page.title, 'Página de Teste');
        expect(page.emoji, '📄');
        expect(page.workspaceId, 'workspace-1');
        expect(page.blocks.length, 1); // Bloco inicial
        expect(page.blocks.first.type, NotionBlockType.text);
        expect(page.isRoot, isTrue);
        expect(page.hasChildren, isFalse);
      });

      test('Deve criar página filha', () {
        final parentPage = NotionPage.create(
          title: 'Página Pai',
          workspaceId: 'workspace-1',
        );

        final childPage = NotionPage.create(
          title: 'Página Filha',
          parentId: parentPage.id,
          workspaceId: 'workspace-1',
        );

        expect(childPage.parentId, parentPage.id);
        expect(childPage.isRoot, isFalse);
      });

      test('Deve identificar página Bloquinho', () {
        final bloquinhoPage = NotionPage.create(
          title: 'Bloquinho',
          workspaceId: 'workspace-1',
        );

        final normalPage = NotionPage.create(
          title: 'Página Normal',
          workspaceId: 'workspace-1',
        );

        expect(bloquinhoPage.isBloquinhoRoot, isTrue);
        expect(normalPage.isBloquinhoRoot, isFalse);
      });

      test('Deve serializar e deserializar página', () {
        final originalPage = NotionPage.create(
          title: 'Página de Teste',
          emoji: '🚀',
          workspaceId: 'workspace-1',
          initialBlocks: [
            NotionBlock.create(
              type: NotionBlockType.heading1,
              content: 'Título',
            ),
            NotionBlock.create(
              type: NotionBlockType.text,
              content: 'Conteúdo',
            ),
          ],
        );

        final json = originalPage.toJson();
        final deserializedPage = NotionPage.fromJson(json);

        expect(deserializedPage.id, originalPage.id);
        expect(deserializedPage.title, originalPage.title);
        expect(deserializedPage.emoji, originalPage.emoji);
        expect(deserializedPage.blocks.length, 2);
        expect(deserializedPage.blocks[0].type, NotionBlockType.heading1);
        expect(deserializedPage.blocks[1].type, NotionBlockType.text);
      });
    });

    group('NotionPageService Tests', () {
      test('Deve criar e recuperar página', () async {
        final page = await pageService.createPage(
          title: 'Teste Service',
          workspaceId: 'test-workspace',
        );

        expect(page.title, 'Teste Service');

        final retrievedPage = await pageService.getPage(page.id);
        expect(retrievedPage, isNotNull);
        expect(retrievedPage!.title, 'Teste Service');
      });

      test('Deve criar página raiz Bloquinho automaticamente', () async {
        final pages = await pageService.getPagesForWorkspace('new-workspace');

        expect(pages.length, 1);
        expect(pages.first.isBloquinhoRoot, isTrue);
        expect(pages.first.title, 'Bloquinho');
      });

      test('Deve atualizar página', () async {
        final page = await pageService.createPage(
          title: 'Página Original',
          workspaceId: 'test-workspace-2',
        );

        final updatedPage = page.copyWith(
          title: 'Página Atualizada',
          blocks: [
            NotionBlock.create(
              type: NotionBlockType.heading1,
              content: 'Novo Título',
            ),
          ],
        );

        await pageService.updatePage(updatedPage);

        final retrievedPage = await pageService.getPage(page.id);
        expect(retrievedPage!.title, 'Página Atualizada');
        expect(retrievedPage.blocks.length, 1);
        expect(retrievedPage.blocks.first.content, 'Novo Título');
      });

      test('Deve criar hierarquia de páginas', () async {
        final parentPage = await pageService.createPage(
          title: 'Página Pai',
          workspaceId: 'hierarchy-test',
        );

        final childPage = await pageService.createPage(
          title: 'Página Filha',
          parentId: parentPage.id,
          workspaceId: 'hierarchy-test',
        );

        // Verificar que o pai foi atualizado
        final updatedParent = await pageService.getPage(parentPage.id);
        expect(updatedParent!.childrenIds, contains(childPage.id));

        // Verificar hierarquia
        final hierarchy = await pageService.getPageHierarchy('hierarchy-test');
        expect(hierarchy.length,
            greaterThanOrEqualTo(3)); // Bloquinho + pai + filho
      });

      test('Deve deletar página (arquivar)', () async {
        final page = await pageService.createPage(
          title: 'Página para Deletar',
          workspaceId: 'delete-test',
        );

        await pageService.deletePage(page.id);

        final pages = await pageService.getPagesForWorkspace('delete-test');
        expect(pages.any((p) => p.id == page.id), isFalse);
      });

      test('Deve duplicar página', () async {
        final originalPage = await pageService.createPage(
          title: 'Página Original',
          emoji: '🎯',
          workspaceId: 'duplicate-test',
          initialBlocks: [
            NotionBlock.create(
              type: NotionBlockType.heading1,
              content: 'Título Original',
            ),
          ],
        );

        final duplicatedPage = await pageService.duplicatePage(originalPage.id);

        expect(duplicatedPage.title, 'Página Original (Cópia)');
        expect(duplicatedPage.emoji, '🎯');
        expect(duplicatedPage.blocks.length, 1);
        expect(duplicatedPage.blocks.first.content, 'Título Original');
        expect(duplicatedPage.id, isNot(originalPage.id));
      });

      test('Deve buscar páginas por conteúdo', () async {
        await pageService.createPage(
          title: 'Página Flutter',
          workspaceId: 'search-test',
          initialBlocks: [
            NotionBlock.create(
              type: NotionBlockType.text,
              content: 'Desenvolvimento mobile com Flutter',
            ),
          ],
        );

        await pageService.createPage(
          title: 'Página React',
          workspaceId: 'search-test',
          initialBlocks: [
            NotionBlock.create(
              type: NotionBlockType.text,
              content: 'Desenvolvimento web com React',
            ),
          ],
        );

        final flutterResults =
            await pageService.searchPages('Flutter', 'search-test');
        final reactResults =
            await pageService.searchPages('React', 'search-test');

        expect(flutterResults.any((p) => p.title.contains('Flutter')), isTrue);
        expect(reactResults.any((p) => p.title.contains('React')), isTrue);
      });

      test('Deve gerenciar favoritos', () async {
        final page = await pageService.createPage(
          title: 'Página Favorita',
          workspaceId: 'favorite-test',
        );

        expect(page.isFavorite, isFalse);

        await pageService.toggleFavorite(page.id);

        final updatedPage = await pageService.getPage(page.id);
        expect(updatedPage!.isFavorite, isTrue);

        final favorites = await pageService.getFavoritePages('favorite-test');
        expect(favorites.any((p) => p.id == page.id), isTrue);
      });

      test('Deve exportar e importar workspace', () async {
        // Criar algumas páginas
        await pageService.createPage(
          title: 'Página Export 1',
          workspaceId: 'export-test',
        );

        await pageService.createPage(
          title: 'Página Export 2',
          workspaceId: 'export-test',
        );

        // Exportar
        final exportData = await pageService.exportWorkspace('export-test');
        expect(exportData['workspaceId'], 'export-test');
        expect(exportData['pages'], isA<List>());

        // Limpar e importar
        await pageService.clearAllData();
        await pageService.importWorkspace(exportData);

        // Verificar importação
        final pages = await pageService.getPagesForWorkspace('export-test');
        expect(pages.length, greaterThanOrEqualTo(2));
      });

      test('Não deve permitir deletar página Bloquinho', () async {
        final pages = await pageService.getPagesForWorkspace('bloquinho-test');
        final bloquinhoPage = pages.firstWhere((p) => p.isBloquinhoRoot);

        expect(
          () async => await pageService.deletePage(bloquinhoPage.id),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Integração Completa Tests', () {
      test('Deve simular workflow completo de usuário', () async {
        const workspaceId = 'integration-test';

        // 1. Carregar workspace (cria Bloquinho automaticamente)
        var pages = await pageService.getPagesForWorkspace(workspaceId);
        expect(pages.length, 1);
        expect(pages.first.isBloquinhoRoot, isTrue);

        // 2. Criar página projeto
        final projectPage = await pageService.createPage(
          title: 'Projeto App Mobile',
          emoji: '📱',
          workspaceId: workspaceId,
          initialBlocks: [
            NotionBlock.create(
              type: NotionBlockType.heading1,
              content: 'Projeto App Mobile',
            ),
            NotionBlock.create(
              type: NotionBlockType.text,
              content: 'Aplicativo para gerenciamento de tarefas.',
            ),
          ],
        );

        // 3. Criar subpáginas
        final designPage = await pageService.createPage(
          title: 'Design System',
          emoji: '🎨',
          parentId: projectPage.id,
          workspaceId: workspaceId,
        );

        final devPage = await pageService.createPage(
          title: 'Desenvolvimento',
          emoji: '💻',
          parentId: projectPage.id,
          workspaceId: workspaceId,
        );

        // 4. Verificar hierarquia
        final hierarchy = await pageService.getPageHierarchy(workspaceId);
        expect(hierarchy.length, 4); // Bloquinho + projeto + 2 subpáginas

        // 5. Atualizar conteúdo da página de desenvolvimento
        final updatedDevPage = devPage.copyWith(
          blocks: [
            NotionBlock.create(
              type: NotionBlockType.heading2,
              content: 'Tasks de Desenvolvimento',
            ),
            NotionBlock.create(
              type: NotionBlockType.todoList,
              content: 'Configurar projeto Flutter',
              properties: NotionBlockProperties({'checked': true}),
            ),
            NotionBlock.create(
              type: NotionBlockType.todoList,
              content: 'Implementar tela de login',
              properties: NotionBlockProperties({'checked': false}),
            ),
            NotionBlock.create(
              type: NotionBlockType.todoList,
              content: 'Configurar estado global',
              properties: NotionBlockProperties({'checked': false}),
            ),
          ],
        );

        await pageService.updatePage(updatedDevPage);

        // 6. Favoritar página do projeto
        await pageService.toggleFavorite(projectPage.id);

        // 7. Buscar por "Flutter"
        final searchResults =
            await pageService.searchPages('Flutter', workspaceId);
        expect(searchResults.length, 1);
        expect(searchResults.first.id, devPage.id);

        // 8. Verificar favoritos
        final favorites = await pageService.getFavoritePages(workspaceId);
        expect(favorites.length, 1);
        expect(favorites.first.id, projectPage.id);

        // 9. Duplicar página de design
        final duplicatedDesign = await pageService.duplicatePage(designPage.id);
        expect(duplicatedDesign.title, 'Design System (Cópia)');

        // 10. Verificar estado final
        pages = await pageService.getPagesForWorkspace(workspaceId);
        expect(pages.length, 5); // Todas as páginas criadas
      });
    });
  });
}
