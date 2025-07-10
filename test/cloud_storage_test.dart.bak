import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bloquinho/core/models/storage_settings.dart';
import 'package:bloquinho/core/services/cloud_storage_service.dart';
import 'package:bloquinho/core/services/google_drive_service.dart';
import 'package:bloquinho/core/services/onedrive_service.dart';
import 'package:bloquinho/core/services/sync_service.dart';
import 'package:bloquinho/shared/providers/storage_settings_provider.dart';

void main() {
  group('StorageSettings', () {
    test('deve criar configurações locais por padrão', () {
      final settings = StorageSettings.local();

      expect(settings.provider, CloudStorageProvider.local);
      expect(settings.status, CloudStorageStatus.connected);
      expect(settings.autoSyncEnabled, false);
      expect(settings.syncOnStartup, false);
      expect(settings.syncOnClose, false);
      expect(settings.isLocalStorage, true);
      expect(settings.isCloudStorage, false);
    });

    test('deve criar configurações para Google Drive', () {
      final settings = StorageSettings.googleDrive(
        email: 'test@gmail.com',
        name: 'Test User',
      );

      expect(settings.provider, CloudStorageProvider.googleDrive);
      expect(settings.status, CloudStorageStatus.disconnected);
      expect(settings.accountEmail, 'test@gmail.com');
      expect(settings.accountName, 'Test User');
      expect(settings.isCloudStorage, true);
    });

    test('deve criar configurações para OneDrive', () {
      final settings = StorageSettings.oneDrive(
        email: 'test@outlook.com',
        name: 'Test User',
      );

      expect(settings.provider, CloudStorageProvider.oneDrive);
      expect(settings.status, CloudStorageStatus.disconnected);
      expect(settings.accountEmail, 'test@outlook.com');
      expect(settings.accountName, 'Test User');
      expect(settings.isCloudStorage, true);
    });

    test('deve serializar e deserializar corretamente', () {
      final originalSettings = StorageSettings.googleDrive(
        email: 'test@gmail.com',
        name: 'Test User',
      ).copyWith(
        status: CloudStorageStatus.connected,
        autoSyncEnabled: true,
        lastSyncAt: DateTime.now(),
      );

      final json = originalSettings.toJson();
      final deserializedSettings = StorageSettings.fromJson(json);

      expect(deserializedSettings.provider, originalSettings.provider);
      expect(deserializedSettings.status, originalSettings.status);
      expect(deserializedSettings.accountEmail, originalSettings.accountEmail);
      expect(deserializedSettings.accountName, originalSettings.accountName);
      expect(deserializedSettings.autoSyncEnabled,
          originalSettings.autoSyncEnabled);
    });

    test('deve validar configurações corretamente', () {
      // Configurações válidas
      final validSettings = StorageSettings.googleDrive(
        email: 'valid@gmail.com',
        name: 'Valid User',
      );

      final validErrors = StorageValidator.validate(validSettings);
      expect(validErrors, isEmpty);

      // Configurações inválidas
      final invalidSettings = StorageSettings.googleDrive(
        email: 'invalid-email',
        name: 'Invalid User',
      );

      final invalidErrors = StorageValidator.validate(invalidSettings);
      expect(invalidErrors, isNotEmpty);
      expect(invalidErrors.first, contains('Email da conta inválido'));
    });

    test('deve calcular tempo desde última sincronização', () {
      final now = DateTime.now();
      final settings = StorageSettings.googleDrive()
          .copyWith(lastSyncAt: now.subtract(Duration(hours: 2)));

      final timeSinceSync = settings.timeSinceLastSync;
      expect(timeSinceSync, isNotNull);
      expect(timeSinceSync!.inHours, 2);
    });

    test('deve determinar se precisa sincronizar', () {
      final now = DateTime.now();

      // Não precisa sincronizar (menos de 1 hora)
      final recentSync = StorageSettings.googleDrive()
          .copyWith(lastSyncAt: now.subtract(Duration(minutes: 30)));
      expect(recentSync.needsSync, false);

      // Precisa sincronizar (mais de 1 hora)
      final oldSync = StorageSettings.googleDrive()
          .copyWith(lastSyncAt: now.subtract(Duration(hours: 2)));
      expect(oldSync.needsSync, true);

      // Nunca sincronizou
      final neverSync = StorageSettings.googleDrive();
      expect(neverSync.needsSync, true);
    });
  });

  group('CloudStorageProvider', () {
    test('deve ter nomes de exibição corretos', () {
      expect(CloudStorageProvider.local.displayName, 'Armazenamento Local');
      expect(CloudStorageProvider.googleDrive.displayName, 'Google Drive');
      expect(CloudStorageProvider.oneDrive.displayName, 'OneDrive');
    });

    test('deve identificar providers de cloud storage', () {
      expect(CloudStorageProvider.local.isCloudStorage, false);
      expect(CloudStorageProvider.googleDrive.isCloudStorage, true);
      expect(CloudStorageProvider.oneDrive.isCloudStorage, true);
    });

    test('deve identificar providers que requerem autenticação', () {
      expect(CloudStorageProvider.local.requiresAuth, false);
      expect(CloudStorageProvider.googleDrive.requiresAuth, true);
      expect(CloudStorageProvider.oneDrive.requiresAuth, true);
    });
  });

  group('CloudStorageStatus', () {
    test('deve ter nomes de exibição corretos', () {
      expect(CloudStorageStatus.disconnected.displayName, 'Desconectado');
      expect(CloudStorageStatus.connecting.displayName, 'Conectando...');
      expect(CloudStorageStatus.connected.displayName, 'Conectado');
      expect(CloudStorageStatus.error.displayName, 'Erro de Conexão');
      expect(CloudStorageStatus.syncing.displayName, 'Sincronizando...');
    });

    test('deve identificar status operacionais', () {
      expect(CloudStorageStatus.disconnected.isOperational, false);
      expect(CloudStorageStatus.connecting.isOperational, false);
      expect(CloudStorageStatus.connected.isOperational, true);
      expect(CloudStorageStatus.error.isOperational, false);
      expect(CloudStorageStatus.syncing.isOperational, true);
    });
  });

  group('SyncResult', () {
    test('deve criar resultado de sucesso', () {
      final result = SyncResult.success(
        filesUploaded: 5,
        filesDownloaded: 3,
        filesDeleted: 1,
        duration: Duration(seconds: 30),
      );

      expect(result.success, true);
      expect(result.filesUploaded, 5);
      expect(result.filesDownloaded, 3);
      expect(result.filesDeleted, 1);
      expect(result.totalFiles, 9);
      expect(result.hasChanges, true);
      expect(result.duration.inSeconds, 30);
    });

    test('deve criar resultado de erro', () {
      final result = SyncResult.error(
        'Erro de conexão',
        Duration(seconds: 5),
      );

      expect(result.success, false);
      expect(result.errorMessage, 'Erro de conexão');
      expect(result.totalFiles, 0);
      expect(result.hasChanges, false);
      expect(result.duration.inSeconds, 5);
    });
  });

  group('StorageSpace', () {
    test('deve calcular porcentagem de uso', () {
      final space = StorageSpace(
        totalBytes: 1000,
        usedBytes: 250,
        availableBytes: 750,
        timestamp: DateTime.now(),
      );

      expect(space.usagePercentage, 25.0);
      expect(space.isAlmostFull, false);
      expect(space.isFull, false);
    });

    test('deve detectar quando está quase cheio', () {
      final space = StorageSpace(
        totalBytes: 1000,
        usedBytes: 950,
        availableBytes: 50,
        timestamp: DateTime.now(),
      );

      expect(space.usagePercentage, 95.0);
      expect(space.isAlmostFull, true);
      expect(space.isFull, true);
    });

    test('deve formatar bytes corretamente', () {
      final space = StorageSpace(
        totalBytes: 1073741824, // 1GB
        usedBytes: 536870912, // 512MB
        availableBytes: 536870912, // 512MB
        timestamp: DateTime.now(),
      );

      expect(space.formattedTotal, '1.0 GB');
      expect(space.formattedUsed, '512.0 MB');
      expect(space.formattedAvailable, '512.0 MB');
    });
  });

  group('RemoteFile', () {
    test('deve criar arquivo remoto corretamente', () {
      final file = RemoteFile(
        path: '/test/file.txt',
        name: 'file.txt',
        size: 1024,
        modifiedAt: DateTime.now(),
        mimeType: 'text/plain',
      );

      expect(file.isFile, true);
      expect(file.isFolder, false);
      expect(file.extension, 'txt');
      expect(file.nameWithoutExtension, 'file');
      expect(file.formattedSize, '1.0 KB');
    });

    test('deve criar pasta remota corretamente', () {
      final folder = RemoteFile(
        path: '/test/folder',
        name: 'folder',
        size: 0,
        modifiedAt: DateTime.now(),
        isFolder: true,
      );

      expect(folder.isFile, false);
      expect(folder.isFolder, true);
      expect(folder.extension, '');
      expect(folder.nameWithoutExtension, 'folder');
    });
  });

  group('GoogleDriveService', () {
    late GoogleDriveService service;

    setUp(() {
      service = GoogleDriveService();
    });

    test('deve ter provider correto', () {
      expect(service.provider, CloudStorageProvider.googleDrive);
    });

    test('deve começar desconectado', () {
      expect(service.isConnected, false);
      expect(service.isSyncing, false);
    });

    test('deve autenticar com sucesso', () async {
      final result = await service.authenticate();

      expect(result.success, true);
      expect(result.accountEmail, isNotNull);
      expect(result.accountName, isNotNull);
      expect(service.isConnected, true);
    });

    test('deve sincronizar após autenticação', () async {
      await service.authenticate();

      final syncResult = await service.sync();

      expect(syncResult.success, true);
      expect(syncResult.filesUploaded, greaterThan(0));
    });

    test('deve desconectar corretamente', () async {
      await service.authenticate();
      expect(service.isConnected, true);

      await service.disconnect();
      expect(service.isConnected, false);
    });

    test('deve validar configurações', () {
      final validSettings = StorageSettings.googleDrive(
        email: 'test@gmail.com',
        name: 'Test User',
      );

      final errors = service.validateSettings(validSettings);
      expect(errors, isEmpty);
    });

    test('deve retornar configurações padrão', () {
      final defaultSettings = service.getDefaultSettings();

      expect(defaultSettings.provider, CloudStorageProvider.googleDrive);
      expect(defaultSettings.status, CloudStorageStatus.disconnected);
    });
  });

  group('OneDriveService', () {
    late OneDriveService service;

    setUp(() {
      service = OneDriveService();
    });

    test('deve ter provider correto', () {
      expect(service.provider, CloudStorageProvider.oneDrive);
    });

    test('deve começar desconectado', () {
      expect(service.isConnected, false);
      expect(service.isSyncing, false);
    });

    test('deve autenticar com sucesso', () async {
      final result = await service.authenticate();

      expect(result.success, true);
      expect(result.accountEmail, isNotNull);
      expect(result.accountName, isNotNull);
      expect(service.isConnected, true);
    });

    test('deve sincronizar após autenticação', () async {
      await service.authenticate();

      final syncResult = await service.sync();

      expect(syncResult.success, true);
      expect(syncResult.filesUploaded, greaterThan(0));
    });

    test('deve desconectar corretamente', () async {
      await service.authenticate();
      expect(service.isConnected, true);

      await service.disconnect();
      expect(service.isConnected, false);
    });

    test('deve validar configurações', () {
      final validSettings = StorageSettings.oneDrive(
        email: 'test@outlook.com',
        name: 'Test User',
      );

      final errors = service.validateSettings(validSettings);
      expect(errors, isEmpty);
    });
  });

  group('CloudStorageUtils', () {
    test('deve validar caminhos', () {
      expect(CloudStorageUtils.isValidPath('/valid/path'), true);
      expect(CloudStorageUtils.isValidPath('valid/path'), true);
      expect(CloudStorageUtils.isValidPath(''), false);
      expect(CloudStorageUtils.isValidPath('/invalid<path>'), false);
      expect(CloudStorageUtils.isValidPath('/invalid:path'), false);
    });

    test('deve normalizar caminhos', () {
      expect(CloudStorageUtils.normalizePath('path\\to\\file'), 'path/to/file');
      expect(CloudStorageUtils.normalizePath('path//to//file'), 'path/to/file');
      expect(CloudStorageUtils.normalizePath('/path/to/file'), '/path/to/file');
    });

    test('deve obter diretório pai', () {
      expect(CloudStorageUtils.getParentDirectory('/path/to/file.txt'),
          '/path/to');
      expect(CloudStorageUtils.getParentDirectory('file.txt'), '');
      expect(CloudStorageUtils.getParentDirectory('/file.txt'), '');
    });

    test('deve obter nome do arquivo', () {
      expect(CloudStorageUtils.getFileName('/path/to/file.txt'), 'file.txt');
      expect(CloudStorageUtils.getFileName('file.txt'), 'file.txt');
      expect(CloudStorageUtils.getFileName('/path/to/'), '');
    });

    test('deve identificar tipos de arquivo', () {
      expect(CloudStorageUtils.isImageFile('image.jpg'), true);
      expect(CloudStorageUtils.isImageFile('image.png'), true);
      expect(CloudStorageUtils.isImageFile('document.pdf'), false);

      expect(CloudStorageUtils.isDocumentFile('document.pdf'), true);
      expect(CloudStorageUtils.isDocumentFile('text.txt'), true);
      expect(CloudStorageUtils.isDocumentFile('image.jpg'), false);
    });
  });

  group('StorageSettingsProvider', () {
    test('deve criar provider com estado inicial', () {
      final container = ProviderContainer();

      final settings = container.read(storageSettingsProvider);

      expect(settings.provider, CloudStorageProvider.local);
      expect(settings.status, CloudStorageStatus.connected);
    });

    test('deve alterar provider', () async {
      final container = ProviderContainer();
      final notifier = container.read(storageSettingsProvider.notifier);

      await notifier.changeProvider(CloudStorageProvider.googleDrive);

      final settings = container.read(storageSettingsProvider);
      expect(settings.provider, CloudStorageProvider.googleDrive);
      expect(settings.status, CloudStorageStatus.disconnected);
    });

    test('deve conectar ao serviço', () async {
      final container = ProviderContainer();
      final notifier = container.read(storageSettingsProvider.notifier);

      await notifier.changeProvider(CloudStorageProvider.googleDrive);
      final result = await notifier.connect();

      expect(result.success, true);

      final settings = container.read(storageSettingsProvider);
      expect(settings.isConnected, true);
    });

    test('deve atualizar configurações de sincronização', () async {
      final container = ProviderContainer();
      final notifier = container.read(storageSettingsProvider.notifier);

      await notifier.updateSyncSettings(
        autoSyncEnabled: true,
        syncOnStartup: true,
        syncOnClose: false,
      );

      final settings = container.read(storageSettingsProvider);
      expect(settings.autoSyncEnabled, true);
      expect(settings.syncOnStartup, true);
      expect(settings.syncOnClose, false);
    });

    test('deve sincronizar dados', () async {
      final container = ProviderContainer();
      final notifier = container.read(storageSettingsProvider.notifier);

      await notifier.changeProvider(CloudStorageProvider.googleDrive);
      await notifier.connect();

      final result = await notifier.sync();

      expect(result.success, true);
      expect(result.filesUploaded, greaterThan(0));
    });
  });

  group('SyncService', () {
    late SyncService syncService;
    late ProviderContainer container;

    setUp(() {
      syncService = SyncService();
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('deve inicializar corretamente', () {
      expect(syncService.isSyncing, false);
      expect(syncService.hasPendingSync, false);

      syncService.initialize(container);

      // Deve estar inicializado mas não sincronizando
      expect(syncService.isSyncing, false);
    });

    test('deve detectar necessidade de sincronização', () async {
      syncService.initialize(container);

      // Configurar para cloud storage
      final notifier = container.read(storageSettingsProvider.notifier);
      await notifier.changeProvider(CloudStorageProvider.googleDrive);
      await notifier.connect();

      // Simular necessidade de sincronização
      await notifier.updateSyncSettings(autoSyncEnabled: true);

      // Deve detectar necessidade de sincronização
      expect(syncService.hasPendingSync, true);
    });

    test('deve executar sincronização forçada', () async {
      syncService.initialize(container);

      // Configurar para cloud storage
      final notifier = container.read(storageSettingsProvider.notifier);
      await notifier.changeProvider(CloudStorageProvider.googleDrive);
      await notifier.connect();

      final result = await syncService.forceSyncNow();

      expect(result.success, true);
    });

    test('deve gerenciar ciclo de vida', () async {
      syncService.initialize(container);

      // Configurar para cloud storage
      final notifier = container.read(storageSettingsProvider.notifier);
      await notifier.changeProvider(CloudStorageProvider.googleDrive);
      await notifier.connect();
      await notifier.updateSyncSettings(
        syncOnStartup: true,
        syncOnClose: true,
      );

      // Sincronizar na inicialização
      await syncService.syncOnStartup();

      // Sincronizar ao fechar
      await syncService.syncOnClose();

      // Não deve gerar erros
      expect(true, true);
    });

    test('deve limpar recursos', () {
      syncService.initialize(container);

      syncService.dispose();

      expect(syncService.isSyncing, false);
      expect(syncService.hasPendingSync, false);
    });
  });

  group('Integração Completa', () {
    test('deve funcionar fluxo completo de configuração e sincronização',
        () async {
      final container = ProviderContainer();
      final syncService = SyncService();

      try {
        // Inicializar serviço de sincronização
        syncService.initialize(container);

        // Configurar Google Drive
        final notifier = container.read(storageSettingsProvider.notifier);
        await notifier.changeProvider(CloudStorageProvider.googleDrive);

        // Conectar
        final authResult = await notifier.connect();
        expect(authResult.success, true);

        // Configurar sincronização automática
        await notifier.updateSyncSettings(
          autoSyncEnabled: true,
          syncOnStartup: true,
          syncOnClose: true,
        );

        // Sincronizar
        final syncResult = await notifier.sync();
        expect(syncResult.success, true);

        // Verificar estado final
        final settings = container.read(storageSettingsProvider);
        expect(settings.isConnected, true);
        expect(settings.autoSyncEnabled, true);
        expect(settings.lastSyncAt, isNotNull);

        // Testar sincronização forçada
        final forcedSync = await syncService.forceSyncNow();
        expect(forcedSync.success, true);
      } finally {
        syncService.dispose();
        container.dispose();
      }
    });

    test('deve tratar erros de conexão graciosamente', () async {
      final container = ProviderContainer();
      final syncService = SyncService();

      try {
        syncService.initialize(container);

        // Tentar sincronizar sem conectar
        final result = await syncService.forceSyncNow();
        expect(result.success, false);
        expect(result.errorMessage, contains('configurado'));
      } finally {
        syncService.dispose();
        container.dispose();
      }
    });
  });
}
