import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

/// Serviço para autenticação OAuth2 com Google Drive e OneDrive
class OAuth2Service {
  static const _storage = FlutterSecureStorage();

  // Configurações OAuth2 para Google Drive
  static const String _googleClientId = 'YOUR_GOOGLE_CLIENT_ID';
  static const String _googleClientSecret = 'YOUR_GOOGLE_CLIENT_SECRET';
  static const String _googleAuthUrl =
      'https://accounts.google.com/o/oauth2/v2/auth';
  static const String _googleTokenUrl = 'https://oauth2.googleapis.com/token';
  static const String _googleScopes =
      'https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile';

  // Configurações OAuth2 para Microsoft OneDrive
  static const String _microsoftClientId = 'YOUR_MICROSOFT_CLIENT_ID';
  static const String _microsoftClientSecret = 'YOUR_MICROSOFT_CLIENT_SECRET';
  static const String _microsoftAuthUrl =
      'https://login.microsoftonline.com/common/oauth2/v2.0/authorize';
  static const String _microsoftTokenUrl =
      'https://login.microsoftonline.com/common/oauth2/v2.0/token';
  static const String _microsoftScopes =
      'files.readwrite offline_access user.read';

  static const String _redirectUri = 'com.bloquinho.app://oauth/callback';

  /// Autenticar com Google Drive
  static Future<AuthResult> authenticateWithGoogle() async {
    try {
      // Verificar se já temos credenciais salvas
      final savedCredentials = await _getSavedCredentials('google');
      if (savedCredentials != null) {
        // Verificar se o token ainda é válido
        if (savedCredentials.canRefresh && savedCredentials.isExpired) {
          try {
            final refreshed = await savedCredentials.refresh();
            await _saveCredentials('google', refreshed);
            return await _getGoogleUserInfo(refreshed);
          } catch (e) {
            // Token refresh falhou, fazer novo login
            await _clearCredentials('google');
          }
        } else if (!savedCredentials.isExpired) {
          return await _getGoogleUserInfo(savedCredentials);
        }
      }

      // Fazer novo login
      final grant = oauth2.AuthorizationCodeGrant(
        _googleClientId,
        Uri.parse(_googleAuthUrl),
        Uri.parse(_googleTokenUrl),
        secret: _googleClientSecret,
      );

      final authorizationUrl = grant.getAuthorizationUrl(
        Uri.parse(_redirectUri),
        scopes: _googleScopes.split(' '),
      );

      // Abrir URL no navegador
      if (await canLaunchUrl(authorizationUrl)) {
        await launchUrl(authorizationUrl, mode: LaunchMode.externalApplication);
      } else {
        return AuthResult.error('Não foi possível abrir o navegador');
      }

      // Aguardar callback (em produção, implementar servidor local ou deep linking)
      // Por enquanto, usar processo simulado
      await Future.delayed(const Duration(seconds: 5));

      // Simular recebimento do código de autorização
      final mockAuthCode =
          'mock_auth_code_${DateTime.now().millisecondsSinceEpoch}';

      try {
        final client = await grant.handleAuthorizationCode(mockAuthCode);
        final credentials = client.credentials;

        await _saveCredentials('google', credentials);
        return await _getGoogleUserInfo(credentials);
      } catch (e) {
        return AuthResult.error('Erro no processamento do código: $e');
      }
    } catch (e) {
      return AuthResult.error('Erro na autenticação Google: $e');
    }
  }

  /// Autenticar com Microsoft OneDrive
  static Future<AuthResult> authenticateWithMicrosoft() async {
    try {
      // Verificar se já temos credenciais salvas
      final savedCredentials = await _getSavedCredentials('microsoft');
      if (savedCredentials != null) {
        // Verificar se o token ainda é válido
        if (savedCredentials.canRefresh && savedCredentials.isExpired) {
          try {
            final refreshed = await savedCredentials.refresh();
            await _saveCredentials('microsoft', refreshed);
            return await _getMicrosoftUserInfo(refreshed);
          } catch (e) {
            // Token refresh falhou, fazer novo login
            await _clearCredentials('microsoft');
          }
        } else if (!savedCredentials.isExpired) {
          return await _getMicrosoftUserInfo(savedCredentials);
        }
      }

      // Fazer novo login
      final grant = oauth2.AuthorizationCodeGrant(
        _microsoftClientId,
        Uri.parse(_microsoftAuthUrl),
        Uri.parse(_microsoftTokenUrl),
        secret: _microsoftClientSecret,
      );

      final authorizationUrl = grant.getAuthorizationUrl(
        Uri.parse(_redirectUri),
        scopes: _microsoftScopes.split(' '),
      );

      // Abrir URL no navegador
      if (await canLaunchUrl(authorizationUrl)) {
        await launchUrl(authorizationUrl, mode: LaunchMode.externalApplication);
      } else {
        return AuthResult.error('Não foi possível abrir o navegador');
      }

      // Aguardar callback (em produção, implementar servidor local ou deep linking)
      // Por enquanto, usar processo simulado
      await Future.delayed(const Duration(seconds: 5));

      // Simular recebimento do código de autorização
      final mockAuthCode =
          'mock_auth_code_${DateTime.now().millisecondsSinceEpoch}';

      try {
        final client = await grant.handleAuthorizationCode(mockAuthCode);
        final credentials = client.credentials;

        await _saveCredentials('microsoft', credentials);
        return await _getMicrosoftUserInfo(credentials);
      } catch (e) {
        return AuthResult.error('Erro no processamento do código: $e');
      }
    } catch (e) {
      return AuthResult.error('Erro na autenticação Microsoft: $e');
    }
  }

  /// Obter informações do usuário Google
  static Future<AuthResult> _getGoogleUserInfo(
      oauth2.Credentials credentials) async {
    try {
      final client = oauth2.Client(credentials);
      final response = await client
          .get(Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo'));

      if (response.statusCode == 200) {
        final userInfo = json.decode(response.body);
        return AuthResult.success(
          accountEmail: userInfo['email'],
          accountName: userInfo['name'],
          accountData: {
            ...userInfo,
            'access_token': credentials.accessToken,
            'refresh_token': credentials.refreshToken,
            'expires_at': credentials.expiration?.toIso8601String(),
          },
        );
      } else {
        return AuthResult.error('Erro ao obter informações do usuário Google');
      }
    } catch (e) {
      return AuthResult.error(
          'Erro ao obter informações do usuário Google: $e');
    }
  }

  /// Obter informações do usuário Microsoft
  static Future<AuthResult> _getMicrosoftUserInfo(
      oauth2.Credentials credentials) async {
    try {
      final client = oauth2.Client(credentials);
      final response =
          await client.get(Uri.parse('https://graph.microsoft.com/v1.0/me'));

      if (response.statusCode == 200) {
        final userInfo = json.decode(response.body);
        return AuthResult.success(
          accountEmail: userInfo['mail'] ?? userInfo['userPrincipalName'],
          accountName: userInfo['displayName'],
          accountData: {
            ...userInfo,
            'access_token': credentials.accessToken,
            'refresh_token': credentials.refreshToken,
            'expires_at': credentials.expiration?.toIso8601String(),
          },
        );
      } else {
        return AuthResult.error(
            'Erro ao obter informações do usuário Microsoft');
      }
    } catch (e) {
      return AuthResult.error(
          'Erro ao obter informações do usuário Microsoft: $e');
    }
  }

  /// Salvar credenciais no armazenamento seguro
  static Future<void> _saveCredentials(
      String provider, oauth2.Credentials credentials) async {
    final credentialsData = {
      'accessToken': credentials.accessToken,
      'refreshToken': credentials.refreshToken,
      'expiration': credentials.expiration?.toIso8601String(),
      'scopes': credentials.scopes,
    };

    await _storage.write(
      key: '${provider}_credentials',
      value: json.encode(credentialsData),
    );
  }

  /// Obter credenciais salvas
  static Future<oauth2.Credentials?> _getSavedCredentials(
      String provider) async {
    try {
      final credentialsJson =
          await _storage.read(key: '${provider}_credentials');
      if (credentialsJson == null) return null;

      final credentialsData = json.decode(credentialsJson);

      return oauth2.Credentials(
        credentialsData['accessToken'],
        refreshToken: credentialsData['refreshToken'],
        expiration: credentialsData['expiration'] != null
            ? DateTime.parse(credentialsData['expiration'])
            : null,
        scopes: List<String>.from(credentialsData['scopes'] ?? []),
      );
    } catch (e) {
      print('Erro ao obter credenciais salvas: $e');
      return null;
    }
  }

  /// Limpar credenciais
  static Future<void> _clearCredentials(String provider) async {
    await _storage.delete(key: '${provider}_credentials');
  }

  /// Desconectar do Google
  static Future<void> disconnectFromGoogle() async {
    await _clearCredentials('google');
  }

  /// Desconectar do Microsoft
  static Future<void> disconnectFromMicrosoft() async {
    await _clearCredentials('microsoft');
  }
}

/// Resultado da autenticação
class AuthResult {
  final bool success;
  final String? error;
  final String? accountEmail;
  final String? accountName;
  final Map<String, dynamic>? accountData;

  AuthResult._({
    required this.success,
    this.error,
    this.accountEmail,
    this.accountName,
    this.accountData,
  });

  factory AuthResult.success({
    required String accountEmail,
    String? accountName,
    Map<String, dynamic>? accountData,
  }) {
    return AuthResult._(
      success: true,
      accountEmail: accountEmail,
      accountName: accountName,
      accountData: accountData,
    );
  }

  factory AuthResult.error(String error) {
    return AuthResult._(
      success: false,
      error: error,
    );
  }
}
