/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msal_js/msal_js.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'dart:js_interop';

import '../models/storage_settings.dart';
import '../models/auth_result.dart';
import 'cloud_storage_service.dart';

class OAuth2Service {
  PublicClientApplication? _publicClientApp;
  OAuth2Config? _config;
  static oauth2.Client? _googleClient;
  static http.Client? _microsoftClient;

  Future<void> initialize(OAuth2Config config) async {
    _config = config;
    if (kIsWeb) {
      final msalConfig = Configuration()
        ..auth = (BrowserAuthOptions()
          ..clientId = _config!.microsoftClientId
          ..authority = 'https://login.microsoftonline.com/common'
          ..redirectUri = 'https://bloquinho.kpsolucoes.pt/oauth_callback.html');
      _publicClientApp = PublicClientApplication(msalConfig);
    }
  }

  static Future<AuthResult> authenticateGoogle() async {
    return OAuth2Service()._authenticateWithGoogle();
  }

  static Future<AuthResult> authenticateMicrosoft() async {
    return OAuth2Service()._authenticateWithMicrosoft();
  }

  Future<AuthResult> authenticate(String provider) async {
    if (provider == 'google') {
      return _authenticateWithGoogle();
    } else if (provider == 'microsoft') {
      return _authenticateWithMicrosoft();
    }
    return AuthResult.error('Provedor não suportado: $provider');
  }

  Future<AuthResult> _authenticateWithGoogle() async {
    final identifier = _config?.googleClientId ?? '';
    final secret = _config?.googleClientSecret ?? '';

    final grant = oauth2.AuthorizationCodeGrant(
      identifier,
      Uri.parse('https://accounts.google.com/o/oauth2/v2/auth'),
      Uri.parse('https://www.googleapis.com/oauth2/v4/token'),
      secret: secret,
    );

    final scopes = [
      'https://www.googleapis.com/auth/drive.file',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ];

    final redirectUrl = Uri.parse('https://bloquinho.kpsolucoes.pt/oauth_callback.html');
    final authUrl = grant.getAuthorizationUrl(redirectUrl, scopes: scopes);

    final completer = Completer<String>();
    final popup = html.window.open(authUrl.toString(), 'oauth', 'width=600,height=800');

    html.window.onMessage.listen((event) {
      if (event.origin != 'https://bloquinho.kpsolucoes.pt') return;
      final data = event.data;
      if (data is Map && data['type'] == 'oauth-callback') {
        if (data['error'] != null) {
          completer.completeError(Exception('Erro no login: ${data['error']}'));
        } else if (data['code'] != null) {
          completer.complete(data['code']);
        }
        popup?.close();
      }
    });

    try {
      final code = await completer.future;
      final response = await http.post(
        Uri.parse('https://www.googleapis.com/oauth2/v4/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': identifier,
          'code': code,
          'grant_type': 'authorization_code',
          'redirect_uri': redirectUrl.toString(),
        },
      );

      if (response.statusCode == 200) {
        _googleClient = oauth2.Client(
            oauth2.Credentials.fromJson(response.body),
            identifier: identifier,
            secret: secret);
        final userInfo = await _getGoogleUserInfo(_googleClient!);
        return AuthResult.success(
          accessToken: _googleClient!.credentials.accessToken,
          refreshToken: _googleClient!.credentials.refreshToken,
          userEmail: userInfo['email'],
          userName: userInfo['name'],
          avatarUrl: userInfo['picture'],
          accountData: userInfo,
        );
      } else {
        return AuthResult.error(
            'Falha ao trocar o código pelo token: ${response.body}');
      }
    } catch (e) {
      return AuthResult.error('Erro na autenticação com o Google: $e');
    }
  }

  Future<AuthResult> _authenticateWithMicrosoft() async {
    if (_publicClientApp == null) {
      return AuthResult.error('MSAL não foi inicializado.');
    }

    try {
      final loginRequest = PopupRequest()
        ..scopes = ['User.Read', 'Files.ReadWrite.All'];
      final response = await _publicClientApp!.loginPopup(loginRequest);

      if (response != null && response.account != null) {
        final account = response.account!;
        _microsoftClient = http.Client(); // Create a standard http client
        return AuthResult.success(
          accessToken: response.accessToken,
          userEmail: account.username,
          userName: account.name,
          accountData: account.idTokenClaims,
        );
      } else {
        return AuthResult.error('Login cancelado ou falhou.');
      }
    } catch (e) {
      return AuthResult.error('Erro na autenticação MSAL: $e');
    }
  }

  Future<Map<String, dynamic>> _getGoogleUserInfo(oauth2.Client client) async {
    final response = await client.get(
      Uri.parse('https://www.googleapis.com/oauth2/v1/userinfo?alt=json'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Erro ao obter informações do usuário Google');
  }

  static Future<void> handleWebCallback() async {
    final uri = Uri.base;
    final code = uri.queryParameters['code'];
    final error = uri.queryParameters['error'];

    if (error != null) {
      html.window.opener?.postMessage(
          {'type': 'oauth-callback', 'error': error},
          html.window.location.origin);
    } else if (code != null) {
      html.window.opener?.postMessage({'type': 'oauth-callback', 'code': code},
          html.window.location.origin);
    }
  }

  static Future<oauth2.Client?> restoreGoogleClient() async {
    // This is a simplified restore. A real implementation would use secure storage.
    return _googleClient;
  }

  static Future<http.Client?> restoreMicrosoftClient() async {
    // This is a simplified restore. A real implementation would use secure storage.
    return _microsoftClient;
  }

  static Future<bool> isGoogleAuthenticated() async {
    return _googleClient != null;
  }

  static Future<bool> isMicrosoftAuthenticated() async {
    return _microsoftClient != null;
  }
}

class OAuth2Config {
  final String googleClientId;
  final String? googleClientSecret;
  final String microsoftClientId;

  const OAuth2Config({
    required this.googleClientId,
    this.googleClientSecret,
    required this.microsoftClientId,
  });
}
