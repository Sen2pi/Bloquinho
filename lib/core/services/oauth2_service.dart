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
      print('Erro ao carregar configuração OAuth2: $e');
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

  /// Inicializa o serviço com configuração
  static Future<void> initialize() async {
    _config = await OAuth2Config.loadFromFile() ?? OAuth2Config.defaultConfig;
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
      return AuthResult.failure(
          'Credenciais OAuth2 não configuradas. Consulte docs/OAUTH_SETUP.md');
    }

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
          debugPrint('✅ Avatar URL Google salva: $avatarUrl');
        } else {
          // No mobile, baixar e cachear arquivo
          debugPrint('🔄 Baixando avatar Google: ${userInfo['picture']}');
          avatarPath = await AvatarCacheService.downloadAndCacheAvatar(
            url: userInfo['picture'],
            userId: userInfo['email'] ?? userInfo['id'],
            fileName: 'google_avatar_${userInfo['id']}.jpg',
          );
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
      return AuthResult.failure('Erro na autenticação Google: $e');
    }
  }

  /// Autentica com Microsoft OneDrive
  static Future<AuthResult> authenticateMicrosoft() async {
    if (_config == null) {
      await initialize();
    }

    if (!isConfigured) {
      return AuthResult.failure(
          'Credenciais OAuth2 não configuradas. Consulte docs/OAUTH_SETUP.md');
    }

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
            debugPrint('✅ Avatar Microsoft convertido para data URL');
          } else {
            // No mobile, salvar arquivo localmente
            debugPrint('🔄 Baixando avatar Microsoft para: ${userInfo['id']}');

            final cacheDir =
                await AvatarCacheService.getAvatarsCacheDirectory();
            final fileName = 'microsoft_avatar_${userInfo['id']}.jpg';
            final filePath = '${cacheDir.path}/$fileName';
            final file = File(filePath);

            await file.writeAsBytes(photoResponse.bodyBytes);
            avatarPath = filePath;

            debugPrint('✅ Avatar Microsoft salvo: $filePath');
          }
        }
      } catch (e) {
        debugPrint('⚠️ Erro ao processar avatar Microsoft: $e');
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
    await _storage.write(
      key: 'google_access_token',
      value: client.credentials.accessToken,
    );

    if (client.credentials.refreshToken != null) {
      await _storage.write(
        key: 'google_refresh_token',
        value: client.credentials.refreshToken!,
      );
    }

    await _storage.write(
      key: 'google_expires_at',
      value: client.credentials.expiration?.toIso8601String(),
    );
  }

  /// Salva tokens Microsoft no armazenamento seguro
  static Future<void> _saveMicrosoftTokens(Client client) async {
    await _storage.write(
      key: 'microsoft_access_token',
      value: client.credentials.accessToken,
    );

    if (client.credentials.refreshToken != null) {
      await _storage.write(
        key: 'microsoft_refresh_token',
        value: client.credentials.refreshToken!,
      );
    }

    await _storage.write(
      key: 'microsoft_expires_at',
      value: client.credentials.expiration?.toIso8601String(),
    );
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
}
