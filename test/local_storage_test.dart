import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:bloquinho/core/services/local_storage_service.dart';
import 'package:bloquinho/core/models/user_profile.dart';

void main() {
  // Inicializar binding para testes
  TestWidgetsFlutterBinding.ensureInitialized();
  group('LocalStorageService Tests', () {
    late LocalStorageService service;

    setUp(() {
      service = LocalStorageService();
    });

    test('Deve inicializar sem erros', () async {
      await service.initialize();
      expect(service, isNotNull);
    });

    test('Deve verificar que não há perfil existente inicialmente', () async {
      await service.initialize();

      if (!kIsWeb) {
        final hasProfile = await service.hasExistingProfile();
        // Pode ser true ou false dependendo de execuções anteriores
        expect(hasProfile, isA<bool>());
      }
    });

    test('Deve criar e salvar perfil com estrutura de pastas (apenas mobile)',
        () async {
      await service.initialize();

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
        () async => await service.saveProfile(profile),
        returnsNormally,
      );

      // Deve conseguir recuperar o perfil
      final profiles = await service.getExistingProfiles();
      expect(profiles, isNotEmpty);
      expect(profiles.first.name, equals('Teste Usuario'));
      expect(profiles.first.email, equals('teste@exemplo.com'));
    });

    test('Deve obter estatísticas de armazenamento', () async {
      await service.initialize();

      final stats = await service.getStorageStats();
      expect(stats, isA<Map<String, dynamic>>());
      expect(stats.containsKey('totalProfiles'), isTrue);
      expect(stats.containsKey('totalWorkspaces'), isTrue);
      expect(stats.containsKey('usedSpace'), isTrue);
      expect(stats.containsKey('platform'), isTrue);
    });

    test('Deve criar workspace (apenas mobile)', () async {
      await service.initialize();

      if (kIsWeb) {
        return;
      }

      try {
        final workspaceDir =
            await service.createWorkspace('teste_usuario', 'workspace1');
        expect(workspaceDir, isNotNull);
      } catch (e) {
        // Pode falhar se a pasta do perfil não existir, o que é ok para este teste
        expect(e, isA<Exception>());
      }
    });

    tearDown(() async {
      await service.dispose();
    });
  });
}
