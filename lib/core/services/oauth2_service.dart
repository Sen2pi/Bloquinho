import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:oauth2/oauth2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'avatar_cache_service.dart';
import 'cloud_folder_service.dart';
import '../../shared/providers/cloud_sync_status_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resultado da autenticação OAuth2
class AuthResult {
  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final String? userEmail;
  final String? userName;
  final String? avatarPath; // Para arquivos locais (mobile)
  final String? avatarUrl; // Para URLs (web/OAuth2)
  final String? error;

  const AuthResult({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.userEmail,
    this.userName,
    this.avatarPath,
    this.avatarUrl,
    this.error,
  });

  AuthResult.success({
    required this.accessToken,
    required this.refreshToken,
    this.userEmail,
    this.userName,
    this.avatarPath,
    this.avatarUrl,
  })  : success = true,
        error = null;

  AuthResult.failure(this.error)
      : success = false,
        accessToken = null,
        refreshToken = null,
        userEmail = null,
        userName = null,
        avatarPath = null,
        avatarUrl = null;
}

/// Configuração OAuth2
class OAuth2Config {
  final String googleClientId;
  final String? googleClientSecret;
  final String microsoftClientId;

  const OAuth2Config({
    required this.googleClientId,
    this.googleClientSecret,
    required this.microsoftClientId,
  });

  /// Carrega configuração do arquivo oauth_config.json na raiz do projeto
  static Future<OAuth2Config?> loadFromFile() async {
    try {
      final file = File('oauth_config.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content);
        return OAuth2Config(
          googleClientId: json['google_client_id'] ?? '',
          googleClientSecret: json['google_client_secret'],
          microsoftClientId: json['microsoft_client_id'] ?? '',
        );
      }
    } catch (e) {
    }
    return null;
  }

  /// Configuração padrão com placeholders
  static const OAuth2Config defaultConfig = OAuth2Config(
    googleClientId:
        '559954382422-tssorad2ncrls4q3o5q6ovf4ru4rg5e4.apps.googleusercontent.com ',
    googleClientSecret: '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',
    microsoftClientId: '341ab3c5-0a36-41dc-b27c-80c56fa37719',
  );
}

/// Classe auxiliar para servidor de callback
class _CallbackServer {
  final HttpServer server;
  final int port;

  _CallbackServer(this.server, this.port);
}

/// Serviço OAuth2 para autenticação com Google Drive e OneDrive
class OAuth2Service {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Configuração OAuth2
  static OAuth2Config? _config;

  // Referência para atualizar o status de sincronização
  static WidgetRef? _syncRef;

  /// Inicializa o serviço com configuração
  static Future<void> initialize() async {
    _config = await OAuth2Config.loadFromFile() ?? OAuth2Config.defaultConfig;
  }

  /// Configura a referência do provider para atualizações de status
  static void setSyncRef(WidgetRef ref) {
    _syncRef = ref;

    // Re-verificar status de conexões ativas após SyncRef estar disponível
    _updateStatusAfterSyncRefAvailable();
  }

  /// Re-verifica e atualiza status visual após SyncRef estar disponível
  static Future<void> _updateStatusAfterSyncRefAvailable() async {
    try {

      // Verificar Google
      final googleActive = await isGoogleAuthenticated();
      if (googleActive) {
        if (_syncRef != null) {
          final notifier = _syncRef!.read(cloudSyncStatusProvider.notifier);
          notifier.setConnected(
            provider: 'google',
            lastSync: DateTime.now(),
          );
        }
      }

      // Verificar Microsoft
      final microsoftActive = await isMicrosoftAuthenticated();
      if (microsoftActive) {
        if (_syncRef != null) {
          final notifier = _syncRef!.read(cloudSyncStatusProvider.notifier);
          notifier.setConnected(
            provider: 'microsoft',
            lastSync: DateTime.now(),
          );
        }
      }

      if (!googleActive && !microsoftActive) {
      }
    } catch (e) {
    }
  }

  /// Atualiza o status de sincronização
  static void _updateSyncStatus({
    required CloudSyncStatus status,
    String? provider,
    String? message,
    String? error,
  }) {
    if (_syncRef != null) {
      final notifier = _syncRef!.read(cloudSyncStatusProvider.notifier);

      switch (status) {
        case CloudSyncStatus.connecting:
          notifier.connect(provider ?? 'unknown');
          break;
        case CloudSyncStatus.connected:
          notifier.setConnected(provider: provider ?? 'unknown');
          break;
        case CloudSyncStatus.error:
          notifier.setError(error ?? 'Erro desconhecido');
          break;
        case CloudSyncStatus.syncing:
          notifier.startSync();
          break;
        default:
          break;
      }
    }
  }

  // URLs de autorização
  static const String _googleAuthUrl =
      'https://accounts.google.com/o/oauth2/v2/auth';
  static const String _googleTokenUrl =
      'https://www.googleapis.com/oauth2/v4/token';

  static const String _microsoftAuthUrl =
      'https://login.microsoftonline.com/common/oauth2/v2.0/authorize';
  static const String _microsoftTokenUrl =
      'https://login.microsoftonline.com/common/oauth2/v2.0/token';

  // Redirect URI dinâmico para desenvolvimento
  static String _redirectUri = 'http://localhost:8080/oauth/callback';

  /// Verifica se as credenciais estão configuradas
  static bool get isConfigured {
    return _config != null &&
        _config!.googleClientId != 'YOUR_GOOGLE_CLIENT_ID' &&
        _config!.microsoftClientId != 'YOUR_MICROSOFT_CLIENT_ID';
  }

  /// Autentica com Google Drive
  static Future<AuthResult> authenticateGoogle() async {
    if (_config == null) {
      await initialize();
    }

    if (!isConfigured) {
      _updateSyncStatus(
        status: CloudSyncStatus.error,
        error: 'Credenciais OAuth2 não configuradas',
      );
      return AuthResult.failure(
          'Credenciais OAuth2 não configuradas. Consulte docs/OAUTH_SETUP.md');
    }

    _updateSyncStatus(
      status: CloudSyncStatus.connecting,
      provider: 'google',
    );

    try {
      final client = await _authenticateWithGoogle();
      final userInfo = await _getGoogleUserInfo(client);

      // Salva tokens
      await _saveGoogleTokens(client);

      // Processar avatar conforme plataforma
      String? avatarPath;
      String? avatarUrl;

      if (userInfo['picture'] != null) {
        if (kIsWeb) {
          // No web, salvar apenas a URL
          avatarUrl = userInfo['picture'];
        } else {
          // No mobile, baixar e cachear arquivo
          avatarPath = await AvatarCacheService.downloadAndCacheAvatar(
            url: userInfo['picture'],
            userId: userInfo['email'] ?? userInfo['id'],
            fileName: 'google_avatar_${userInfo['id']}.jpg',
          );
        }
      }

      _updateSyncStatus(
        status: CloudSyncStatus.connected,
        provider: 'google',
      );

      // Criar estrutura de pastas na nuvem automaticamente
      try {
        _updateSyncStatus(status: CloudSyncStatus.syncing, provider: 'google');

        await CloudFolderService.createGoogleDriveFolders();

        // Finalizar sincronização explicitamente
        if (_syncRef != null) {
          final notifier = _syncRef!.read(cloudSyncStatusProvider.notifier);
          notifier.finishSync();
        }
      } catch (e) {
        // Finalizar sincronização mesmo com erro
        if (_syncRef != null) {
          final notifier = _syncRef!.read(cloudSyncStatusProvider.notifier);
          notifier.finishSync();
        }
      }

      return AuthResult.success(
        accessToken: client.credentials.accessToken,
        refreshToken: client.credentials.refreshToken,
        userEmail: userInfo['email'],
        userName: userInfo['name'],
        avatarPath: avatarPath,
        avatarUrl: avatarUrl,
      );
    } catch (e) {
      _updateSyncStatus(
        status: CloudSyncStatus.error,
        provider: 'google',
        error: 'Erro na autenticação: $e',
      );
      return AuthResult.failure('Erro na autenticação Google: $e');
    }
  }

  /// Autentica com Microsoft OneDrive
  static Future<AuthResult> authenticateMicrosoft() async {
    if (_config == null) {
      await initialize();
    }

    if (!isConfigured) {
      _updateSyncStatus(
        status: CloudSyncStatus.error,
        error: 'Credenciais OAuth2 não configuradas',
      );
      return AuthResult.failure(
          'Credenciais OAuth2 não configuradas. Consulte docs/OAUTH_SETUP.md');
    }

    _updateSyncStatus(
      status: CloudSyncStatus.connecting,
      provider: 'microsoft',
    );

    try {
      final client = await _authenticateWithMicrosoft();
      final userInfo = await _getMicrosoftUserInfo(client);

      // Salva tokens
      await _saveMicrosoftTokens(client);

      // Processar avatar conforme plataforma
      String? avatarPath;
      String? avatarUrl;

      try {
        // Obter foto de perfil do Microsoft Graph
        final photoResponse = await client.get(
          Uri.parse('https://graph.microsoft.com/v1.0/me/photo/\$value'),
        );

        if (photoResponse.statusCode == 200) {
          if (kIsWeb) {
            // No web, converter bytes para data URL
            final bytes = photoResponse.bodyBytes;
            final base64 = base64Encode(bytes);
            avatarUrl = 'data:image/jpeg;base64,$base64';
          } else {
            // No mobile, salvar arquivo localmente

            final cacheDir =
                await AvatarCacheService.getAvatarsCacheDirectory();
            final fileName = 'microsoft_avatar_${userInfo['id']}.jpg';
            final filePath = '${cacheDir.path}/$fileName';
            final file = File(filePath);

            await file.writeAsBytes(photoResponse.bodyBytes);
            avatarPath = filePath;

          }
        }
      } catch (e) {
      }

      _updateSyncStatus(
        status: CloudSyncStatus.connected,
        provider: 'microsoft',
      );

      // Criar estrutura de pastas na nuvem automaticamente
      try {
        _updateSyncStatus(
            status: CloudSyncStatus.syncing, provider: 'microsoft');

        await CloudFolderService.createOneDriveFolders();

        // Finalizar sincronização explicitamente
        if (_syncRef != null) {
          final notifier = _syncRef!.read(cloudSyncStatusProvider.notifier);
          notifier.finishSync();
        }
      } catch (e) {
        // Finalizar sincronização mesmo com erro
        if (_syncRef != null) {
          final notifier = _syncRef!.read(cloudSyncStatusProvider.notifier);
          notifier.finishSync();
        }
      }

      return AuthResult.success(
        accessToken: client.credentials.accessToken,
        refreshToken: client.credentials.refreshToken,
        userEmail: userInfo['mail'] ?? userInfo['userPrincipalName'],
        userName: userInfo['displayName'],
        avatarPath: avatarPath,
        avatarUrl: avatarUrl,
      );
    } catch (e) {
      _updateSyncStatus(
        status: CloudSyncStatus.error,
        provider: 'microsoft',
        error: 'Erro na autenticação: $e',
      );
      return AuthResult.failure('Erro na autenticação Microsoft: $e');
    }
  }

  /// Cria servidor HTTP local para capturar callback OAuth2
  static Future<_CallbackServer> _createCallbackServer() async {
    final server = await HttpServer.bind('localhost', 0); // Porta automática
    final port = server.port;
    _redirectUri = 'http://localhost:$port/oauth/callback';

    return _CallbackServer(server, port);
  }

  /// Autentica com Google usando OAuth2
  static Future<Client> _authenticateWithGoogle() async {
    final identifier = _config!.googleClientId;
    final secret = _config!.googleClientSecret;

    // Criar servidor HTTP local
    final callbackServer = await _createCallbackServer();
    final redirectUrl = Uri.parse(_redirectUri);

    final scopes = [
      'https://www.googleapis.com/auth/drive.file',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ];

    final grant = AuthorizationCodeGrant(
      identifier,
      Uri.parse(_googleAuthUrl),
      Uri.parse(_googleTokenUrl),
      secret: secret,
    );

    final authUrl = grant.getAuthorizationUrl(redirectUrl, scopes: scopes);

    // Configurar listener para callback
    final completer = Completer<String>();

    callbackServer.server.listen((request) {
      final uri = request.uri;

      if (uri.path == '/oauth/callback') {
        final code = uri.queryParameters['code'];
        final error = uri.queryParameters['error'];

        // Responder ao navegador
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.html
          ..write('''
            <html>
              <body>
                <h1>${error != null ? 'Erro na autenticação' : 'Autenticação bem-sucedida'}</h1>
                <p>${error != null ? 'Erro: $error' : 'Pode fechar esta janela.'}</p>
                <script>window.close();</script>
              </body>
            </html>
          ''')
          ..close();

        if (error != null) {
          completer.completeError(Exception('Erro OAuth2: $error'));
        } else if (code != null) {
          completer.complete(code);
        } else {
          completer
              .completeError(Exception('Código de autorização não encontrado'));
        }
      }
    });

    try {
      // Lançar navegador
      await launchUrl(authUrl, mode: LaunchMode.externalApplication);

      // Aguardar callback (timeout de 5 minutos)
      final code = await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw Exception('Timeout na autenticação'),
      );

      // Trocar código por token
      final client = await grant.handleAuthorizationCode(code);

      return client;
    } finally {
      // Fechar servidor
      await callbackServer.server.close();
    }
  }

  /// Autentica com Microsoft usando OAuth2
  static Future<Client> _authenticateWithMicrosoft() async {
    final identifier = _config!.microsoftClientId;

    // Criar servidor HTTP local
    final callbackServer = await _createCallbackServer();
    final redirectUrl = Uri.parse(_redirectUri);

    final scopes = [
      'https://graph.microsoft.com/Files.ReadWrite',
      'https://graph.microsoft.com/User.Read',
      'offline_access',
    ];

    final grant = AuthorizationCodeGrant(
      identifier,
      Uri.parse(_microsoftAuthUrl),
      Uri.parse(_microsoftTokenUrl),
    );

    final authUrl = grant.getAuthorizationUrl(redirectUrl, scopes: scopes);

    // Configurar listener para callback
    final completer = Completer<String>();

    callbackServer.server.listen((request) {
      final uri = request.uri;

      if (uri.path == '/oauth/callback') {
        final code = uri.queryParameters['code'];
        final error = uri.queryParameters['error'];

        // Responder ao navegador
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.html
          ..write('''
            <html>
              <body>
                <h1>${error != null ? 'Erro na autenticação' : 'Autenticação bem-sucedida'}</h1>
                <p>${error != null ? 'Erro: $error' : 'Pode fechar esta janela.'}</p>
                <script>window.close();</script>
              </body>
            </html>
          ''')
          ..close();

        if (error != null) {
          completer.completeError(Exception('Erro OAuth2: $error'));
        } else if (code != null) {
          completer.complete(code);
        } else {
          completer
              .completeError(Exception('Código de autorização não encontrado'));
        }
      }
    });

    try {
      // Lançar navegador
      await launchUrl(authUrl, mode: LaunchMode.externalApplication);

      // Aguardar callback (timeout de 5 minutos)
      final code = await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw Exception('Timeout na autenticação'),
      );

      // Trocar código por token
      final client = await grant.handleAuthorizationCode(code);

      return client;
    } finally {
      // Fechar servidor
      await callbackServer.server.close();
    }
  }

  /// Obtém informações do usuário Google
  static Future<Map<String, dynamic>> _getGoogleUserInfo(Client client) async {
    final response = await client.get(
      Uri.parse('https://www.googleapis.com/oauth2/v1/userinfo?alt=json'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Erro ao obter informações do usuário Google');
  }

  /// Obtém informações do usuário Microsoft
  static Future<Map<String, dynamic>> _getMicrosoftUserInfo(
      Client client) async {
    final response = await client.get(
      Uri.parse('https://graph.microsoft.com/v1.0/me'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Erro ao obter informações do usuário Microsoft');
  }

  /// Salva tokens Google no armazenamento seguro
  static Future<void> _saveGoogleTokens(Client client) async {
    try {

      await _storage.write(
        key: 'google_access_token',
        value: client.credentials.accessToken,
      );

      if (client.credentials.refreshToken != null) {
        await _storage.write(
          key: 'google_refresh_token',
          value: client.credentials.refreshToken!,
        );
      } else {
      }

      final expirationStr = client.credentials.expiration?.toIso8601String();
      if (expirationStr != null) {
        await _storage.write(
          key: 'google_expires_at',
          value: expirationStr,
        );
      }

    } catch (e) {
      rethrow;
    }
  }

  /// Salva tokens Microsoft no armazenamento seguro
  static Future<void> _saveMicrosoftTokens(Client client) async {
    try {

      await _storage.write(
        key: 'microsoft_access_token',
        value: client.credentials.accessToken,
      );

      if (client.credentials.refreshToken != null) {
        await _storage.write(
          key: 'microsoft_refresh_token',
          value: client.credentials.refreshToken!,
        );
      } else {
      }

      final expirationStr = client.credentials.expiration?.toIso8601String();
      if (expirationStr != null) {
        await _storage.write(
          key: 'microsoft_expires_at',
          value: expirationStr,
        );
      }

    } catch (e) {
      rethrow;
    }
  }

  /// Obtém token Google salvo
  static Future<String?> getGoogleAccessToken() async {
    return await _storage.read(key: 'google_access_token');
  }

  /// Obtém token Microsoft salvo
  static Future<String?> getMicrosoftAccessToken() async {
    return await _storage.read(key: 'microsoft_access_token');
  }

  /// Verifica se o usuário está autenticado no Google
  static Future<bool> isGoogleAuthenticated() async {
    final token = await getGoogleAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Verifica se o usuário está autenticado no Microsoft
  static Future<bool> isMicrosoftAuthenticated() async {
    final token = await getMicrosoftAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Limpa tokens Google
  static Future<void> clearGoogleTokens() async {
    await _storage.delete(key: 'google_access_token');
    await _storage.delete(key: 'google_refresh_token');
    await _storage.delete(key: 'google_expires_at');
  }

  /// Limpa tokens Microsoft
  static Future<void> clearMicrosoftTokens() async {
    await _storage.delete(key: 'microsoft_access_token');
    await _storage.delete(key: 'microsoft_refresh_token');
    await _storage.delete(key: 'microsoft_expires_at');
  }

  /// Limpa todos os tokens
  static Future<void> clearAllTokens() async {
    await clearGoogleTokens();
    await clearMicrosoftTokens();
  }

  /// Restaura cliente Google a partir de tokens salvos com renovação automática
  static Future<Client?> restoreGoogleClient() async {
    try {
      // Verificar se o token está expirando em breve
      final isExpiring = await _isTokenExpiringSoon('google_expires_at');

      if (isExpiring) {
        final renewedClient = await _refreshGoogleToken();
        if (renewedClient != null) {
          return renewedClient;
        }
      }

      final accessToken = await _storage.read(key: 'google_access_token');
      final refreshToken = await _storage.read(key: 'google_refresh_token');
      final expiresAtStr = await _storage.read(key: 'google_expires_at');

      if (accessToken == null) return null;

      DateTime? expiration;
      if (expiresAtStr != null) {
        expiration = DateTime.parse(expiresAtStr);
      }

      final credentials = Credentials(
        accessToken,
        refreshToken: refreshToken,
        tokenEndpoint: Uri.parse(_googleTokenUrl),
        scopes: [
          'https://www.googleapis.com/auth/drive.file',
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
        expiration: expiration,
      );

      return Client(credentials);
    } catch (e) {
      return null;
    }
  }

  /// Restaura cliente Microsoft a partir de tokens salvos com renovação automática
  static Future<Client?> restoreMicrosoftClient() async {
    try {
      // Verificar se o token está expirando em breve
      final isExpiring = await _isTokenExpiringSoon('microsoft_expires_at');

      if (isExpiring) {
        final renewedClient = await _refreshMicrosoftToken();
        if (renewedClient != null) {
          return renewedClient;
        }
      }

      final accessToken = await _storage.read(key: 'microsoft_access_token');
      final refreshToken = await _storage.read(key: 'microsoft_refresh_token');
      final expiresAtStr = await _storage.read(key: 'microsoft_expires_at');

      if (accessToken == null) return null;

      DateTime? expiration;
      if (expiresAtStr != null) {
        expiration = DateTime.parse(expiresAtStr);
      }

      final credentials = Credentials(
        accessToken,
        refreshToken: refreshToken,
        tokenEndpoint: Uri.parse(_microsoftTokenUrl),
        scopes: [
          'https://graph.microsoft.com/Files.ReadWrite',
          'https://graph.microsoft.com/User.Read',
          'offline_access',
        ],
        expiration: expiration,
      );

      return Client(credentials);
    } catch (e) {
      return null;
    }
  }

  /// Verifica e restaura sessões existentes na inicialização
  static Future<void> restoreExistingSessions() async {

    // Debug: Verificar tokens salvos

    // Tentar restaurar Google
    final googleClient = await restoreGoogleClient();
    if (googleClient != null) {
      try {
        // Verificar se o token ainda é válido
        final userInfo = await _getGoogleUserInfo(googleClient);

        if (_syncRef != null) {
          final notifier = _syncRef!.read(cloudSyncStatusProvider.notifier);
          notifier.setConnected(
            provider: 'google',
            lastSync: DateTime.now(),
          );
        } else {
        }
      } catch (e) {
        await clearGoogleTokens();
      }
    } else {
    }

    // Tentar restaurar Microsoft
    final microsoftClient = await restoreMicrosoftClient();
    if (microsoftClient != null) {
      try {
        // Verificar se o token ainda é válido
        final userInfo = await _getMicrosoftUserInfo(microsoftClient);

        if (_syncRef != null) {
          final notifier = _syncRef!.read(cloudSyncStatusProvider.notifier);
          notifier.setConnected(
            provider: 'microsoft',
            lastSync: DateTime.now(),
          );
        } else {
        }
      } catch (e) {
        await clearMicrosoftTokens();
      }
    } else {
    }

    if (googleClient == null && microsoftClient == null) {
    } else {
      // Verificar estrutura de pastas apenas se não há criação recente
      try {
        // CloudFolderService.ensureCloudFoldersExist() - desabilitado temporariamente para evitar duplicação
      } catch (e) {
      }
    }
  }

  /// Verifica se existe conexão ativa (Google ou Microsoft)
  static Future<bool> hasActiveConnection() async {
    final googleActive = await isGoogleAuthenticated();
    final microsoftActive = await isMicrosoftAuthenticated();
    return googleActive || microsoftActive;
  }

  /// Verifica se o token está próximo de expirar (dentro de 10 minutos)
  static Future<bool> _isTokenExpiringSoon(String expiresAtKey) async {
    try {
      final expiresAtStr = await _storage.read(key: expiresAtKey);
      if (expiresAtStr == null) return true;

      final expiresAt = DateTime.parse(expiresAtStr);
      final now = DateTime.now();
      final difference = expiresAt.difference(now);

      // Se expira em menos de 10 minutos, considerar como "expirando"
      return difference.inMinutes < 10;
    } catch (e) {
      return true; // Em caso de erro, assumir que está expirando
    }
  }

  /// Renova token Microsoft usando refresh token
  static Future<Client?> _refreshMicrosoftToken() async {
    try {

      final refreshToken = await _storage.read(key: 'microsoft_refresh_token');
      if (refreshToken == null) {
        return null;
      }

      final identifier = _config!.microsoftClientId;

      // Fazer request para renovar token
      final response = await http.post(
        Uri.parse(_microsoftTokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': identifier,
          'scope':
              'https://graph.microsoft.com/Files.ReadWrite https://graph.microsoft.com/User.Read offline_access',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Criar novo cliente com token renovado
        final newCredentials = Credentials(
          data['access_token'],
          refreshToken: data['refresh_token'] ??
              refreshToken, // Usar novo ou manter atual
          tokenEndpoint: Uri.parse(_microsoftTokenUrl),
          scopes: [
            'https://graph.microsoft.com/Files.ReadWrite',
            'https://graph.microsoft.com/User.Read',
            'offline_access',
          ],
          expiration:
              DateTime.now().add(Duration(seconds: data['expires_in'] ?? 3600)),
        );

        final newClient = Client(newCredentials);

        // Salvar novos tokens
        await _saveMicrosoftTokens(newClient);

        return newClient;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Renova token Google usando refresh token
  static Future<Client?> _refreshGoogleToken() async {
    try {

      final refreshToken = await _storage.read(key: 'google_refresh_token');
      if (refreshToken == null) {
        return null;
      }

      final identifier = _config!.googleClientId;

      // Fazer request para renovar token
      final response = await http.post(
        Uri.parse(_googleTokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': identifier,
          'scope':
              'https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Criar novo cliente com token renovado
        final newCredentials = Credentials(
          data['access_token'],
          refreshToken: refreshToken, // Google mantém o mesmo refresh token
          tokenEndpoint: Uri.parse(_googleTokenUrl),
          scopes: [
            'https://www.googleapis.com/auth/drive.file',
            'https://www.googleapis.com/auth/userinfo.email',
            'https://www.googleapis.com/auth/userinfo.profile',
          ],
          expiration:
              DateTime.now().add(Duration(seconds: data['expires_in'] ?? 3600)),
        );

        final newClient = Client(newCredentials);

        // Salvar novos tokens
        await _saveGoogleTokens(newClient);

        return newClient;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Obtém o cliente ativo (Google ou Microsoft)
  static Future<Client?> getActiveClient() async {
    // Priorizar Google se ambos estiverem disponíveis
    final googleClient = await restoreGoogleClient();
    if (googleClient != null) return googleClient;

    final microsoftClient = await restoreMicrosoftClient();
    if (microsoftClient != null) return microsoftClient;

    return null;
  }

  /// Debug: Verificar tokens salvos no armazenamento
  static Future<void> _debugSavedTokens() async {
    try {
      // Verificar Google tokens
      final googleAccess = await _storage.read(key: 'google_access_token');
      final googleRefresh = await _storage.read(key: 'google_refresh_token');
      final googleExpires = await _storage.read(key: 'google_expires_at');


      // Verificar Microsoft tokens
      final microsoftAccess =
          await _storage.read(key: 'microsoft_access_token');
      final microsoftRefresh =
          await _storage.read(key: 'microsoft_refresh_token');
      final microsoftExpires = await _storage.read(key: 'microsoft_expires_at');

    } catch (e) {
    }
  }
}