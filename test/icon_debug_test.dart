import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../lib/core/constants/page_icons.dart';
import '../lib/features/bloquinho/models/page_model.dart';
import '../lib/core/services/bloquinho_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Teste de Debug de Ícones', () {
    late BloquinhoStorageService storageService;
    late Directory tempDir;

    setUpAll(() async {
      // Configurar diretório temporário para testes
      tempDir = await Directory.systemTemp.createTemp('bloquinho_test');
      storageService = BloquinhoStorageService();
      await storageService.initialize();
    });

    tearDownAll(() async {
      // Limpar diretório temporário
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Teste 1: Validação de ícones', () {
      print('\n🔍 TESTE 1: Validação de ícones');

      // Testar ícones válidos
      final validIcons = ['📄', '📝', '💡', '🚀', '✅'];
      for (final icon in validIcons) {
        final isValid = PageIcons.isValidIcon(icon);
        final validIcon = PageIcons.getValidIcon(icon);
        print('  - Ícone "$icon": válido=$isValid, resultado="$validIcon"');
        expect(isValid, true);
        expect(validIcon, icon);
      }

      // Testar ícones inválidos
      final invalidIcons = ['invalid', null, '', '🚀🚀'];
      for (final icon in invalidIcons) {
        final isValid = PageIcons.isValidIcon(icon);
        final validIcon = PageIcons.getValidIcon(icon);
        print('  - Ícone "$icon": válido=$isValid, resultado="$validIcon"');
        expect(isValid, false);
        expect(validIcon, PageIcons.defaultIcon);
      }
    });

    test('Teste 2: Ícones por título', () {
      print('\n🔍 TESTE 2: Ícones por título');

      final testCases = [
        ('Bem-vindo', '👋'),
        ('teste', '🧪'),
        ('nota', '📝'),
        ('projeto', '🚀'),
        ('tarefa', '✅'),
        ('ideia', '💡'),
        ('reunião', '🤝'),
        ('documento', '📄'),
        ('código', '💻'),
        ('design', '🎨'),
        ('página genérica', '📄'), // padrão
      ];

      for (final testCase in testCases) {
        final title = testCase.$1;
        final expectedIcon = testCase.$2;
        final actualIcon = PageIcons.getIconForTitle(title);
        print(
            '  - Título "$title": esperado="$expectedIcon", obtido="$actualIcon"');
        expect(actualIcon, expectedIcon);
      }
    });

    test('Teste 3: Serialização/Deserialização', () {
      print('\n🔍 TESTE 3: Serialização/Deserialização');

      final testIcons = ['📄', '📝', '💡', '🚀', '✅'];

      for (final icon in testIcons) {
        // Criar página com ícone
        final page = PageModel.create(
          title: 'Teste',
          icon: icon,
        );
        print('  - Página criada com ícone: "$icon"');

        // Serializar
        final map = page.toMap();
        final serializedIcon = map['icon'];
        print('  - Ícone serializado: "$serializedIcon"');

        // Deserializar
        final deserializedPage = PageModel.fromMap(map);
        final deserializedIcon = deserializedPage.icon;
        print('  - Ícone deserializado: "$deserializedIcon"');

        // Verificar consistência
        expect(serializedIcon, icon);
        expect(deserializedIcon, icon);
        print('  - ✅ Consistência verificada');
      }
    });

    test('Teste 4: Fluxo completo de salvamento/carregamento', () async {
      print('\n🔍 TESTE 4: Fluxo completo de salvamento/carregamento');

      final testIcon = '💡';
      final testTitle = 'Página de Teste';

      // Criar página
      final page = PageModel.create(
        title: testTitle,
        icon: testIcon,
      );
      print('  - Página criada:');
      print('    - Título: "${page.title}"');
      print('    - Ícone: "${page.icon}"');
      print('    - ID: "${page.id}"');

      // Simular salvamento (sem arquivo real)
      final map = page.toMap();
      print('  - Dados serializados:');
      print('    - Ícone no map: "${map['icon']}"');
      print('    - Título no map: "${map['title']}"');

      // Simular carregamento
      final loadedPage = PageModel.fromMap(map);
      print('  - Página carregada:');
      print('    - Título: "${loadedPage.title}"');
      print('    - Ícone: "${loadedPage.icon}"');
      print('    - ID: "${loadedPage.id}"');

      // Verificar consistência
      expect(loadedPage.title, testTitle);
      expect(loadedPage.icon, testIcon);
      expect(loadedPage.id, page.id);
      print('  - ✅ Fluxo completo verificado');
    });

    test('Teste 5: Lista de ícones disponíveis', () {
      print('\n🔍 TESTE 5: Lista de ícones disponíveis');

      print(
          '  - Total de ícones disponíveis: ${PageIcons.availableIcons.length}');
      print('  - Ícones: ${PageIcons.availableIcons.join(', ')}');

      // Verificar se não há duplicatas
      final uniqueIcons = PageIcons.availableIcons.toSet();
      expect(uniqueIcons.length, PageIcons.availableIcons.length);
      print('  - ✅ Sem duplicatas na lista');

      // Verificar se todos são válidos
      for (final icon in PageIcons.availableIcons) {
        expect(PageIcons.isValidIcon(icon), true);
      }
      print('  - ✅ Todos os ícones são válidos');
    });
  });
}
