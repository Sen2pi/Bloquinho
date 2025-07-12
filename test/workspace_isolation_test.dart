import 'package:flutter_test/flutter_test.dart';
import 'package:bloquinho/core/services/local_storage_service.dart';
import 'package:bloquinho/core/services/bloquinho_storage_service.dart';
import 'package:bloquinho/core/services/database_service.dart';
import 'package:bloquinho/core/models/user_profile.dart';
import 'package:bloquinho/features/bloquinho/models/page_model.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Isolamento e Persistência por Workspace', () {
    const profileName = 'Karim Hussen';
    const workspace1 = 'Pessoal';
    const workspace2 = 'Trabalho';

    final localStorage = LocalStorageService();
    final bloquinhoStorage = BloquinhoStorageService();
    final databaseService = DatabaseService();

    setUpAll(() async {
      await localStorage.initialize();
      await localStorage.deleteProfile(profileName); // Limpar antes
      await localStorage.createProfileStructure(profileName);
      await localStorage.createWorkspace(profileName, workspace1);
      await localStorage.createWorkspace(profileName, workspace2);
    });

    test('Deve criar workspaces isolados', () async {
      await localStorage.initialize();

      // Criar dois workspaces diferentes
      final workspace1Path =
          await localStorage.createWorkspace(profileName, workspace1);
      final workspace2Path =
          await localStorage.createWorkspace(profileName, workspace2);

      expect(workspace1Path, isNotNull);
      expect(workspace2Path, isNotNull);
      expect(workspace1Path, isNot(equals(workspace2Path)));

      // Verificar se os workspaces existem
      final workspace1Exists =
          await localStorage.workspaceExists(profileName, workspace1);
      final workspace2Exists =
          await localStorage.workspaceExists(profileName, workspace2);

      expect(workspace1Exists, isTrue);
      expect(workspace2Exists, isTrue);
    });

    test('Páginas são isoladas por workspace', () async {
      // Criar página no workspace1
      final page1 =
          PageModel.create(title: 'Página Pessoal', content: 'Conteúdo 1');
      await bloquinhoStorage.savePage(page1, profileName, workspace1);
      var pages1 = await bloquinhoStorage.loadAllPages(profileName, workspace1);
      expect(pages1.any((p) => p.title == 'Página Pessoal'), isTrue);

      // Não deve aparecer no workspace2
      var pages2 = await bloquinhoStorage.loadAllPages(profileName, workspace2);
      expect(pages2.any((p) => p.title == 'Página Pessoal'), isFalse);

      // Criar página no workspace2
      final page2 =
          PageModel.create(title: 'Página Trabalho', content: 'Conteúdo 2');
      await bloquinhoStorage.savePage(page2, profileName, workspace2);
      pages2 = await bloquinhoStorage.loadAllPages(profileName, workspace2);
      expect(pages2.any((p) => p.title == 'Página Trabalho'), isTrue);

      // Não deve aparecer no workspace1
      pages1 = await bloquinhoStorage.loadAllPages(profileName, workspace1);
      expect(pages1.any((p) => p.title == 'Página Trabalho'), isFalse);
    });

    test('Database é isolado por workspace', () async {
      await databaseService.initialize();
      databaseService.setCurrentWorkspace(workspace1);
      await databaseService.createTable(name: 'Tabela Pessoal');
      var tables1 = databaseService.tables;
      expect(tables1.any((t) => t.name == 'Tabela Pessoal'), isTrue);

      databaseService.setCurrentWorkspace(workspace2);
      await databaseService.createTable(name: 'Tabela Trabalho');
      var tables2 = databaseService.tables;
      expect(tables2.any((t) => t.name == 'Tabela Trabalho'), isTrue);
      expect(tables2.any((t) => t.name == 'Tabela Pessoal'), isFalse);

      databaseService.setCurrentWorkspace(workspace1);
      tables1 = databaseService.tables;
      expect(tables1.any((t) => t.name == 'Tabela Pessoal'), isTrue);
      expect(tables1.any((t) => t.name == 'Tabela Trabalho'), isFalse);
    });

    tearDownAll(() async {
      await localStorage.deleteProfile(profileName); // Limpar depois
    });
  });
}
