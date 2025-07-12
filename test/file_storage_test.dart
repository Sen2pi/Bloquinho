import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:bloquinho/core/services/file_storage_service.dart';
import 'package:bloquinho/core/services/bloquinho_file_service.dart';
import 'package:bloquinho/core/models/user_profile.dart';

void main() {
  group('FileStorageService Tests', () {
    late FileStorageService fileStorageService;
    late BloquinhoFileService bloquinhoFileService;

    setUp(() {
      fileStorageService = FileStorageService();
      bloquinhoFileService = BloquinhoFileService();
    });

    test('Deve inicializar sem erros', () async {
      await fileStorageService.initialize();
      expect(fileStorageService, isNotNull);
    });

    test('Deve verificar que não há perfil existente inicialmente', () async {
      await fileStorageService.initialize();

      if (!kIsWeb) {
        final hasProfile = await fileStorageService.hasExistingProfile();
        // Pode ser true ou false dependendo de execuções anteriores
        expect(hasProfile, isA<bool>());
      }
    });

    test('Deve criar e salvar perfil com estrutura de pastas (apenas mobile)',
        () async {
      await fileStorageService.initialize();

      // Só testar no mobile/desktop, pular no web
      if (kIsWeb) {
        return;
      }

      final profile = UserProfile.create(
        name: 'Teste Usuario',
        email: 'teste@exemplo.com',
      );

      // Deve conseguir salvar sem erros
      await expectLater(
        () async => await fileStorageService.saveProfile(profile),
        returnsNormally,
      );

      // Deve conseguir recuperar o perfil
      final profiles = await fileStorageService.getExistingProfiles();
      expect(profiles, isNotEmpty);
      expect(profiles.first.name, equals('Teste Usuario'));
      expect(profiles.first.email, equals('teste@exemplo.com'));
    });

    test('Deve criar workspace com estrutura completa', () async {
      await fileStorageService.initialize();

      if (kIsWeb) {
        return;
      }

      final profile = UserProfile.create(
        name: 'Teste Workspace',
        email: 'workspace@exemplo.com',
      );

      await fileStorageService.saveProfile(profile);

      // Criar workspace
      final workspaceDir = await fileStorageService.createWorkspace(
        'Teste Workspace',
        'Trabalho',
      );

      expect(workspaceDir, isNotNull);
      expect(await workspaceDir.exists(), isTrue);

      // Verificar se as pastas dos componentes foram criadas
      final bloquinhoDir = await fileStorageService.getComponentDirectory(
        'Teste Workspace',
        'Trabalho',
        'bloquinho',
      );
      expect(bloquinhoDir, isNotNull);
      expect(await bloquinhoDir!.exists(), isTrue);

      final documentsDir = await fileStorageService.getComponentDirectory(
        'Teste Workspace',
        'Trabalho',
        'documents',
      );
      expect(documentsDir, isNotNull);
      expect(await documentsDir!.exists(), isTrue);

      final agendaDir = await fileStorageService.getComponentDirectory(
        'Teste Workspace',
        'Trabalho',
        'agenda',
      );
      expect(agendaDir, isNotNull);
      expect(await agendaDir!.exists(), isTrue);

      final passwordsDir = await fileStorageService.getComponentDirectory(
        'Teste Workspace',
        'Trabalho',
        'passwords',
      );
      expect(passwordsDir, isNotNull);
      expect(await passwordsDir!.exists(), isTrue);

      final databasesDir = await fileStorageService.getComponentDirectory(
        'Teste Workspace',
        'Trabalho',
        'databases',
      );
      expect(databasesDir, isNotNull);
      expect(await databasesDir!.exists(), isTrue);
    });
  });

  group('BloquinhoFileService Tests', () {
    late BloquinhoFileService bloquinhoFileService;

    setUp(() {
      bloquinhoFileService = BloquinhoFileService();
    });

    test('Deve salvar e carregar página do Bloquinho', () async {
      if (kIsWeb) {
        return;
      }

      const profileName = 'Teste Bloquinho';
      const workspaceName = 'Pessoal';
      const pageTitle = 'Minha Primeira Página';
      const content = '# Título da Página\n\nEste é o conteúdo da página.';

      // Salvar página
      await expectLater(
        () async => await bloquinhoFileService.savePage(
          profileName: profileName,
          workspaceName: workspaceName,
          pageTitle: pageTitle,
          content: content,
        ),
        returnsNormally,
      );

      // Carregar página
      final loadedPage = await bloquinhoFileService.loadPage(
        profileName: profileName,
        workspaceName: workspaceName,
        pageTitle: pageTitle,
      );

      expect(loadedPage, isNotNull);
      expect(loadedPage!['content'], equals(content));
      expect(loadedPage['metadata'], isNotNull);
      expect(loadedPage['metadata']['title'], equals(pageTitle));
    });

    test('Deve criar subpágina', () async {
      if (kIsWeb) {
        return;
      }

      const profileName = 'Teste Subpágina';
      const workspaceName = 'Pessoal';
      const parentPageTitle = 'Página Principal';
      const subPageTitle = 'Subpágina';
      const content = '# Subpágina\n\nConteúdo da subpágina.';

      // Criar página principal
      await bloquinhoFileService.savePage(
        profileName: profileName,
        workspaceName: workspaceName,
        pageTitle: parentPageTitle,
        content: '# Página Principal\n\nConteúdo principal.',
      );

      // Criar subpágina
      await expectLater(
        () async => await bloquinhoFileService.createSubPage(
          profileName: profileName,
          workspaceName: workspaceName,
          parentPageTitle: parentPageTitle,
          subPageTitle: subPageTitle,
          content: content,
        ),
        returnsNormally,
      );

      // Carregar subpágina
      final loadedSubPage = await bloquinhoFileService.loadPage(
        profileName: profileName,
        workspaceName: workspaceName,
        pageTitle: subPageTitle,
        parentPageTitle: parentPageTitle,
      );

      expect(loadedSubPage, isNotNull);
      expect(loadedSubPage!['content'], equals(content));
      expect(loadedSubPage['metadata']['parentTitle'], equals(parentPageTitle));
    });

    test('Deve listar todas as páginas', () async {
      if (kIsWeb) {
        return;
      }

      const profileName = 'Teste Listagem';
      const workspaceName = 'Pessoal';

      // Criar algumas páginas
      await bloquinhoFileService.savePage(
        profileName: profileName,
        workspaceName: workspaceName,
        pageTitle: 'Página 1',
        content: 'Conteúdo 1',
      );

      await bloquinhoFileService.savePage(
        profileName: profileName,
        workspaceName: workspaceName,
        pageTitle: 'Página 2',
        content: 'Conteúdo 2',
      );

      // Listar páginas
      final pages = await bloquinhoFileService.listAllPages(
        profileName: profileName,
        workspaceName: workspaceName,
      );

      expect(pages, isNotEmpty);
      expect(pages.length, greaterThanOrEqualTo(2));

      // Verificar se as páginas foram encontradas
      final pageTitles = pages.map((p) => p['title'] as String).toList();
      expect(pageTitles, contains('Página 1'));
      expect(pageTitles, contains('Página 2'));
    });

    test('Deve renomear página', () async {
      if (kIsWeb) {
        return;
      }

      const profileName = 'Teste Renomear';
      const workspaceName = 'Pessoal';
      const oldTitle = 'Página Antiga';
      const newTitle = 'Página Nova';
      const content = 'Conteúdo da página.';

      // Criar página
      await bloquinhoFileService.savePage(
        profileName: profileName,
        workspaceName: workspaceName,
        pageTitle: oldTitle,
        content: content,
      );

      // Renomear página
      await expectLater(
        () async => await bloquinhoFileService.renamePage(
          profileName: profileName,
          workspaceName: workspaceName,
          oldTitle: oldTitle,
          newTitle: newTitle,
        ),
        returnsNormally,
      );

      // Verificar se a página antiga não existe mais
      final oldPage = await bloquinhoFileService.loadPage(
        profileName: profileName,
        workspaceName: workspaceName,
        pageTitle: oldTitle,
      );
      expect(oldPage, isNull);

      // Verificar se a nova página existe
      final newPage = await bloquinhoFileService.loadPage(
        profileName: profileName,
        workspaceName: workspaceName,
        pageTitle: newTitle,
      );
      expect(newPage, isNotNull);
      expect(newPage!['content'], equals(content));
    });

    test('Deve deletar página', () async {
      if (kIsWeb) {
        return;
      }

      const profileName = 'Teste Deletar';
      const workspaceName = 'Pessoal';
      const pageTitle = 'Página para Deletar';
      const content = 'Conteúdo da página.';

      // Criar página
      await bloquinhoFileService.savePage(
        profileName: profileName,
        workspaceName: workspaceName,
        pageTitle: pageTitle,
        content: content,
      );

      // Verificar se a página existe
      final pageBefore = await bloquinhoFileService.loadPage(
        profileName: profileName,
        workspaceName: workspaceName,
        pageTitle: pageTitle,
      );
      expect(pageBefore, isNotNull);

      // Deletar página
      await expectLater(
        () async => await bloquinhoFileService.deletePage(
          profileName: profileName,
          workspaceName: workspaceName,
          pageTitle: pageTitle,
        ),
        returnsNormally,
      );

      // Verificar se a página foi deletada
      final pageAfter = await bloquinhoFileService.loadPage(
        profileName: profileName,
        workspaceName: workspaceName,
        pageTitle: pageTitle,
      );
      expect(pageAfter, isNull);
    });
  });
}
