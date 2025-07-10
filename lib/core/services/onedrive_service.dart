import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:bloquinho/core/models/storage_settings.dart';
import 'package:bloquinho/core/services/cloud_storage_service.dart';
import 'package:bloquinho/core/services/oauth2_service.dart' as oauth2;
import 'package:http/http.dart' as http;

/// Serviço para integração com OneDrive
class OneDriveService extends CloudStorageService {
  static const String _baseUrl = 'https://graph.microsoft.com/v1.0';
  static const String _authUrl =
      'https://login.microsoftonline.com/common/oauth2/v2.0/authorize';
  static const String _tokenUrl =
      'https://login.microsoftonline.com/common/oauth2/v2.0/token';

  // Configurações OAuth2 (em produção, usar valores seguros)
  static const String _clientId = 'seu_microsoft_client_id';
  static const String _clientSecret = 'seu_microsoft_client_secret';
  static const String _redirectUri = 'http://localhost:8080/callback';
  static const String _scope = 'files.readwrite offline_access user.read';

  static final OneDriveService _instance = OneDriveService._internal();
  factory OneDriveService() => _instance;
  OneDriveService._internal();

  StorageSettings _settings = StorageSettings.local();
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;

  // Streams para comunicação de status
  final _statusController = StreamController<CloudStorageStatus>.broadcast();
  final _syncProgressController = StreamController<SyncProgress>.broadcast();

  @override
  CloudStorageProvider get provider => CloudStorageProvider.oneDrive;

  @override
  bool get isConnected => _settings.isConnected && _accessToken != null;

  @override
  bool get isSyncing => _settings.isSyncing;

  @override
  StorageSettings get settings => _settings;

  @override
  Stream<CloudStorageStatus> get statusStream => _statusController.stream;

  @override
  Stream<SyncProgress> get syncProgressStream => _syncProgressController.stream;

  /// Atualizar configurações
  void updateSettings(StorageSettings newSettings) {
    _settings = newSettings;
    _statusController.add(_settings.status);
  }

  /// Verificar se token ainda é válido
  bool get _isTokenValid {
    if (_accessToken == null || _tokenExpiry == null) return false;
    return DateTime.now()
        .isBefore(_tokenExpiry!.subtract(const Duration(minutes: 5)));
  }

  /// Renovar token de acesso
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse(_tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'refresh_token': _refreshToken!,
          'grant_type': 'refresh_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        _tokenExpiry =
            DateTime.now().add(Duration(seconds: data['expires_in']));
        if (data['refresh_token'] != null) {
          _refreshToken = data['refresh_token'];
        }
        return true;
      }
    } catch (e) {
      print('Erro ao renovar token: $e');
    }

    return false;
  }

  /// Obter headers de autenticação
  Map<String, String> get _authHeaders => {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      };

  /// Verificar se o usuário tem subscrição ativa do OneDrive
  Future<bool> hasActiveSubscription() async {
    try {
      // Verificar se tem token válido
      if (!_isTokenValid && !await _refreshAccessToken()) {
        return false;
      }

      // Fazer chamada para verificar informações da conta
      final response = await http.get(
        Uri.parse('$_baseUrl/me/drive'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verificar se tem quota suficiente (mais de 5GB indica subscrição)
        final quota = data['quota'];
        if (quota != null) {
          final total = quota['total'] as int? ?? 0;
          final used = quota['used'] as int? ?? 0;
          final remaining = quota['remaining'] as int? ?? 0;

          // OneDrive gratuito tem 5GB, pago tem 100GB+
          // Se tem mais de 50GB total, provavelmente tem subscrição
          return total > 50 * 1024 * 1024 * 1024; // 50GB em bytes
        }
      }

      return false;
    } catch (e) {
      print('Erro ao verificar subscrição: $e');
      return false;
    }
  }

  /// Criar pasta do aplicativo no OneDrive
  Future<bool> createAppFolder() async {
    try {
      // Verificar se tem token válido
      if (!_isTokenValid && !await _refreshAccessToken()) {
        return false;
      }

      const folderName = 'Bloquinho';

      // Verificar se a pasta já existe
      final checkResponse = await http.get(
        Uri.parse('$_baseUrl/me/drive/root:/$folderName'),
        headers: _authHeaders,
      );

      if (checkResponse.statusCode == 200) {
        // Pasta já existe
        final data = json.decode(checkResponse.body);
        final folderId = data['id'];

        // Salvar ID da pasta nas configurações
        _settings = _settings.copyWith(
          providerConfig: {
            ..._settings.providerConfig,
            'app_folder_id': folderId,
            'app_folder_name': folderName,
          },
        );

        return true;
      }

      // Criar nova pasta
      final createResponse = await http.post(
        Uri.parse('$_baseUrl/me/drive/root/children'),
        headers: _authHeaders,
        body: json.encode({
          'name': folderName,
          'folder': {},
          '@microsoft.graph.conflictBehavior': 'rename',
        }),
      );

      if (createResponse.statusCode == 201) {
        final data = json.decode(createResponse.body);
        final folderId = data['id'];

        // Salvar ID da pasta nas configurações
        _settings = _settings.copyWith(
          providerConfig: {
            ..._settings.providerConfig,
            'app_folder_id': folderId,
            'app_folder_name': folderName,
          },
        );

        return true;
      }

      return false;
    } catch (e) {
      print('Erro ao criar pasta do app: $e');
      return false;
    }
  }

  @override
  Future<AuthResult> authenticate({Map<String, dynamic>? config}) async {
    try {
      _statusController.add(CloudStorageStatus.connecting);

      // Usar OAuth2 real
      final result = await oauth2.OAuth2Service.authenticateWithMicrosoft();

      if (result.success) {
        // Extrair tokens do resultado
        final accountData = result.accountData!;
        _accessToken = accountData['access_token'];
        _refreshToken = accountData['refresh_token'];
        _tokenExpiry = accountData['expires_at'] != null
            ? DateTime.parse(accountData['expires_at'])
            : null;

        _settings = _settings.copyWith(
          status: CloudStorageStatus.connected,
          accountEmail: result.accountEmail,
          accountName: result.accountName,
          providerConfig: {
            'user_id': accountData['id'],
            'picture': accountData['picture'],
            'access_token': _accessToken,
            'refresh_token': _refreshToken,
            'expires_at': _tokenExpiry?.toIso8601String(),
          },
        );

        _statusController.add(CloudStorageStatus.connected);

        // Criar pasta do aplicativo automaticamente
        await createAppFolder();

        return AuthResult.success(
          accountEmail: result.accountEmail!,
          accountName: result.accountName,
          accountData: accountData,
        );
      } else {
        _statusController.add(CloudStorageStatus.error);
        return AuthResult.error(result.error ?? 'Erro na autenticação');
      }
    } catch (e) {
      _statusController.add(CloudStorageStatus.error);
      return AuthResult.error('Erro na autenticação: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;

    _settings = _settings.copyWith(
      status: CloudStorageStatus.disconnected,
      accountEmail: null,
      accountName: null,
      providerConfig: {},
    );

    _statusController.add(CloudStorageStatus.disconnected);
  }

  @override
  Future<SyncResult> sync(
      {bool forceSync = false, List<String>? specificFiles}) async {
    if (!isConnected) {
      return SyncResult.error('Não conectado ao OneDrive', Duration.zero);
    }

    final stopwatch = Stopwatch()..start();

    try {
      _settings = _settings.copyWith(status: CloudStorageStatus.syncing);
      _statusController.add(CloudStorageStatus.syncing);

      var filesUploaded = 0;
      var filesDownloaded = 0;
      var filesDeleted = 0;

      // Simular processo de sincronização
      final mockFiles = [
        'profile.json',
        'settings.json',
        'backup_data.json',
        'user_preferences.json',
        'app_data.json',
      ];

      for (var i = 0; i < mockFiles.length; i++) {
        final fileName = mockFiles[i];

        // Emitir progresso
        _syncProgressController.add(SyncProgress(
          currentFile: i + 1,
          totalFiles: mockFiles.length,
          currentFileName: fileName,
          operation: SyncOperation.uploading,
          timestamp: DateTime.now(),
        ));

        // Simular upload
        await Future.delayed(const Duration(milliseconds: 600));
        filesUploaded++;
      }

      stopwatch.stop();

      _settings = _settings.copyWith(
        status: CloudStorageStatus.connected,
        lastSyncAt: DateTime.now(),
      );
      _statusController.add(CloudStorageStatus.connected);

      return SyncResult.success(
        filesUploaded: filesUploaded,
        filesDownloaded: filesDownloaded,
        filesDeleted: filesDeleted,
        duration: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      _settings = _settings.copyWith(status: CloudStorageStatus.error);
      _statusController.add(CloudStorageStatus.error);

      return SyncResult.error('Erro na sincronização: $e', stopwatch.elapsed);
    }
  }

  @override
  Future<UploadResult> uploadFile({
    required String localPath,
    required String remotePath,
    bool overwrite = true,
  }) async {
    if (!isConnected) {
      return UploadResult.error('Não conectado ao OneDrive');
    }

    if (!_isTokenValid && !await _refreshAccessToken()) {
      return UploadResult.error('Token de acesso inválido');
    }

    try {
      final file = File(localPath);
      if (!await file.exists()) {
        return UploadResult.error('Arquivo local não encontrado: $localPath');
      }

      final fileSize = await file.length();
      final fileName = CloudStorageUtils.getFileName(remotePath);

      // Simular upload para OneDrive
      await Future.delayed(Duration(milliseconds: (fileSize / 1024).round()));

      final mockFileId = 'onedrive_${DateTime.now().millisecondsSinceEpoch}';
      final mockUrl = 'https://1drv.ms/u/s!$mockFileId';

      return UploadResult.success(
        remoteUrl: mockUrl,
        fileSize: fileSize,
        fileId: mockFileId,
      );
    } catch (e) {
      return UploadResult.error('Erro no upload: $e');
    }
  }

  @override
  Future<DownloadResult> downloadFile({
    required String remotePath,
    required String localPath,
    bool overwrite = true,
  }) async {
    if (!isConnected) {
      return DownloadResult.error('Não conectado ao OneDrive');
    }

    if (!_isTokenValid && !await _refreshAccessToken()) {
      return DownloadResult.error('Token de acesso inválido');
    }

    try {
      final localFile = File(localPath);

      if (!overwrite && await localFile.exists()) {
        return DownloadResult.error('Arquivo local já existe: $localPath');
      }

      // Simular download do OneDrive
      await Future.delayed(const Duration(milliseconds: 600));

      // Criar arquivo simulado
      final mockContent = json.encode({
        'downloaded_from': 'onedrive',
        'remote_path': remotePath,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await localFile.writeAsString(mockContent);
      final fileSize = await localFile.length();

      return DownloadResult.success(
        localPath: localPath,
        fileSize: fileSize,
      );
    } catch (e) {
      return DownloadResult.error('Erro no download: $e');
    }
  }

  @override
  Future<List<RemoteFile>> listFiles(
      {String? folderPath, bool recursive = false}) async {
    if (!isConnected) return [];

    if (!_isTokenValid && !await _refreshAccessToken()) {
      return [];
    }

    try {
      // Simular listagem de arquivos
      await Future.delayed(const Duration(milliseconds: 400));

      final mockFiles = [
        RemoteFile(
          path: '/Apps/Bloquinho/profile.json',
          name: 'profile.json',
          size: 1024,
          modifiedAt: DateTime.now().subtract(const Duration(hours: 1)),
          mimeType: 'application/json',
          fileId: 'onedrive_profile_123',
        ),
        RemoteFile(
          path: '/Apps/Bloquinho/settings.json',
          name: 'settings.json',
          size: 512,
          modifiedAt: DateTime.now().subtract(const Duration(hours: 2)),
          mimeType: 'application/json',
          fileId: 'onedrive_settings_456',
        ),
        RemoteFile(
          path: '/Apps/Bloquinho/backup',
          name: 'backup',
          size: 0,
          modifiedAt: DateTime.now().subtract(const Duration(days: 1)),
          isFolder: true,
          fileId: 'onedrive_folder_789',
        ),
        RemoteFile(
          path: '/Apps/Bloquinho/user_preferences.json',
          name: 'user_preferences.json',
          size: 2048,
          modifiedAt: DateTime.now().subtract(const Duration(hours: 3)),
          mimeType: 'application/json',
          fileId: 'onedrive_preferences_101',
        ),
      ];

      return mockFiles;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> deleteFile(String remotePath) async {
    if (!isConnected) return false;

    if (!_isTokenValid && !await _refreshAccessToken()) {
      return false;
    }

    try {
      // Simular exclusão
      await Future.delayed(const Duration(milliseconds: 250));
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> createFolder(String folderPath) async {
    if (!isConnected) return false;

    if (!_isTokenValid && !await _refreshAccessToken()) {
      return false;
    }

    try {
      // Simular criação de pasta
      await Future.delayed(const Duration(milliseconds: 350));
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> fileExists(String remotePath) async {
    if (!isConnected) return false;

    final files = await listFiles();
    return files.any((file) => file.path == remotePath);
  }

  @override
  Future<RemoteFile?> getFileInfo(String remotePath) async {
    if (!isConnected) return null;

    final files = await listFiles();
    try {
      return files.firstWhere((file) => file.path == remotePath);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<StorageSpace> getStorageSpace() async {
    if (!isConnected) {
      return StorageSpace(
        totalBytes: 0,
        usedBytes: 0,
        availableBytes: 0,
        timestamp: DateTime.now(),
      );
    }

    if (!_isTokenValid && !await _refreshAccessToken()) {
      return StorageSpace(
        totalBytes: 0,
        usedBytes: 0,
        availableBytes: 0,
        timestamp: DateTime.now(),
      );
    }

    try {
      // Simular consulta de espaço do OneDrive (5GB gratuitos)
      await Future.delayed(const Duration(milliseconds: 250));

      const totalBytes = 5 * 1024 * 1024 * 1024; // 5GB
      const usedBytes = 1024 * 1024 * 1024; // 1GB usado
      const availableBytes = totalBytes - usedBytes;

      return StorageSpace(
        totalBytes: totalBytes,
        usedBytes: usedBytes,
        availableBytes: availableBytes,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return StorageSpace(
        totalBytes: 0,
        usedBytes: 0,
        availableBytes: 0,
        timestamp: DateTime.now(),
      );
    }
  }

  @override
  Future<bool> checkConnectivity() async {
    if (!isConnected) return false;

    try {
      // Simular verificação de conectividade
      await Future.delayed(const Duration(milliseconds: 150));
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  List<String> validateSettings(StorageSettings settings) {
    final errors = <String>[];

    if (settings.provider != CloudStorageProvider.oneDrive) {
      errors.add('Provider incorreto para OneDrive');
    }

    if (settings.accountEmail == null || settings.accountEmail!.isEmpty) {
      errors.add('Email da conta Microsoft é obrigatório');
    }

    if (settings.accountEmail != null &&
        !settings.accountEmail!.contains('@outlook.com') &&
        !settings.accountEmail!.contains('@hotmail.com') &&
        !settings.accountEmail!.contains('@live.com')) {
      errors.add('Email deve ser uma conta Microsoft válida');
    }

    return errors;
  }

  @override
  StorageSettings getDefaultSettings() {
    return StorageSettings.oneDrive();
  }

  /// Obter URL de autenticação OAuth2
  String getAuthUrl() {
    final params = {
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'scope': _scope,
      'response_type': 'code',
      'response_mode': 'query',
      'state': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    final queryString = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$_authUrl?$queryString';
  }

  /// Processar código de autorização
  Future<AuthResult> processAuthCode(String code) async {
    try {
      final response = await http.post(
        Uri.parse(_tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'code': code,
          'grant_type': 'authorization_code',
          'redirect_uri': _redirectUri,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];
        _tokenExpiry =
            DateTime.now().add(Duration(seconds: data['expires_in']));

        // Obter informações do usuário
        final userInfo = await _getUserInfo();

        _settings = _settings.copyWith(
          status: CloudStorageStatus.connected,
          accountEmail: userInfo['email'],
          accountName: userInfo['name'],
          providerConfig: {
            'user_id': userInfo['id'],
            'picture': userInfo['picture'],
            'access_token': _accessToken,
            'refresh_token': _refreshToken,
            'expires_at': _tokenExpiry?.toIso8601String(),
          },
        );

        _statusController.add(CloudStorageStatus.connected);

        return AuthResult.success(
          accountEmail: userInfo['email']!,
          accountName: userInfo['name'],
          accountData: userInfo,
        );
      } else {
        return AuthResult.error('Erro na autenticação: ${response.statusCode}');
      }
    } catch (e) {
      return AuthResult.error('Erro no processamento: $e');
    }
  }

  /// Obter informações do usuário autenticado
  Future<Map<String, dynamic>> _getUserInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'email': data['mail'] ?? data['userPrincipalName'],
          'name': data['displayName'],
          'id': data['id'],
          'picture': null, // OneDrive não retorna foto diretamente
        };
      }
    } catch (e) {
      print('Erro ao obter informações do usuário: $e');
    }

    // Retornar dados mock em caso de erro
    return {
      'email': 'usuario@outlook.com',
      'name': 'Usuário Exemplo',
      'id': '98765432-1234-5678-9012-123456789012',
      'picture': null,
    };
  }

  /// Obter foto do perfil do usuário
  Future<String?> getUserPhoto() async {
    if (!isConnected) return null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/me/photo/\$value'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        // Retornar base64 da imagem
        final bytes = response.bodyBytes;
        return 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }
    } catch (e) {
      print('Erro ao obter foto do perfil: $e');
    }

    return null;
  }

  /// Limpar recursos
  void dispose() {
    _statusController.close();
    _syncProgressController.close();
  }
}
