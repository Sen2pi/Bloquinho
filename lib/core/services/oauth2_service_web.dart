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
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

import '../models/auth_result.dart' as auth;

class OAuth2Service {
  OAuth2Config? _config;
  static oauth2.Client? _googleClient;
  static http.Client? _microsoftClient;

  Future<void> initialize(OAuth2Config config) async {
    _config = config;
  }

  static Future<auth.AuthResult> authenticateGoogle() async {
    return OAuth2Service()._authenticateWithGoogle();
  }

  static Future<auth.AuthResult> authenticateMicrosoft() async {
    return OAuth2Service()._authenticateWithMicrosoft();
  }

  Future<auth.AuthResult> authenticate(String provider) async {
    if (provider == 'google') {
      return _authenticateWithGoogle();
    } else if (provider == 'microsoft') {
      return _authenticateWithMicrosoft();
    }
    return auth.AuthResult.error('Provedor não suportado: $provider');
  }

  Future<auth.AuthResult> _authenticateWithGoogle() async {
    final identifier = _config?.googleClientId ?? '869649040-7sou7ac0k0bpnuebr6e32qr40lfb3ndc.apps.googleusercontent.com';
    final secret = _config?.googleClientSecret ?? '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';

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
        return auth.AuthResult.success(
          accessToken: _googleClient!.credentials.accessToken,
          refreshToken: _googleClient!.credentials.refreshToken,
          userEmail: userInfo['email'],
          userName: userInfo['name'],
          avatarUrl: userInfo['picture'],
          accountData: userInfo,
        );
      } else {
        return auth.AuthResult.error(
            'Falha ao trocar o código pelo token: ${response.body}');
      }
    } catch (e) {
      return auth.AuthResult.error('Erro na autenticação com o Google: $e');
    }
  }

  Future<auth.AuthResult> _authenticateWithMicrosoft() async {
    try {
      // Simplified Microsoft authentication for web
      final authUrl = 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize'
          '?client_id=${_config?.microsoftClientId ?? 'ebe4d0f9-ff8a-43b8-b79a-2e44cdde8b94'}'
          '&response_type=code'
          '&redirect_uri=https://bloquinho.kpsolucoes.pt/oauth_callback.html'
          '&scope=User.Read Files.ReadWrite.All'
          '&response_mode=query';
      
      final completer = Completer<String>();
      final popup = html.window.open(authUrl, 'microsoft_oauth', 'width=600,height=800');

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

      await completer.future;
      // Exchange code for token (simplified)
      return auth.AuthResult.success(
        accessToken: 'mock_microsoft_token',
        userEmail: 'user@outlook.com',
        userName: 'Microsoft User',
      );
    } catch (e) {
      return auth.AuthResult.error('Erro na autenticação Microsoft: $e');
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
          'https://bloquinho.kpsolucoes.pt');
    } else if (code != null) {
      html.window.opener?.postMessage({'type': 'oauth-callback', 'code': code},
          'https://bloquinho.kpsolucoes.pt');
    }
  }

  static Future<oauth2.Client?> restoreGoogleClient() async {
    return _googleClient;
  }

  static Future<http.Client?> restoreMicrosoftClient() async {
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