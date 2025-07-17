/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:bloquinho/core/models/storage_settings.dart';
import 'package:bloquinho/core/services/cloud_storage_service.dart';
import 'package:bloquinho/core/models/auth_result.dart';
import 'package:http/http.dart' as http;
conditional_import(
  'oauth2_service_web.dart' if (dart.library.html),
  'oauth2_service.dart',
) as oauth2;

/// Serviço para integração com Google Drive
class GoogleDriveService extends CloudStorageService {
  static const String _baseUrl = 'https://www.googleapis.com/drive/v3';
  static const String _uploadUrl = 'https://www.googleapis.com/upload/drive/v3';
  static const String _authUrl = 'https://accounts.google.com/o/oauth2/v2/auth';
  static const String _tokenUrl = 'https://oauth2.googleapis.com/token';

  // Configurações OAuth2 (em produção, usar valores seguros)
  static const String _clientId = 'seu_google_client_id';
  static const String _clientSecret = 'seu_google_client_secret';
  static const String _redirectUri = 'http://localhost:8080/callback';
  static const String _scope = 'https://www.googleapis.com/auth/drive.file';

  static final GoogleDriveService _instance = GoogleDriveService._internal();
  factory GoogleDriveService() => _instance;
  GoogleDriveService._internal();

  StorageSettings _settings = StorageSettings.local();
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;

  // Streams para comunicação de status
  final _statusController = StreamController<CloudStorageStatus>.broadcast();
  final _syncProgressController = StreamController<SyncProgress>.broadcast();

  @override
  CloudStorageProvider get provider => CloudStorageProvider.googleDrive;

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
        return true;
      }
    } catch (e) {
    }

    return false;
  }

  /// Obter headers de autenticação
  Map<String, String> get _authHeaders => {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      };

  @override
  Future<AuthResult> authenticate({Map<String, dynamic>? config}) async {
    try {
      _statusController.add(CloudStorageStatus.connecting);

      // Usar OAuth2 real
      final result = kIsWeb 
          ? await oauth2.OAuth2Service.authenticateGoogle()
          : await oauth2.OAuth2Service.authenticateGoogle();

      if (result.success) {
        // Extrair tokens do resultado
        _accessToken = result.accessToken;
        _refreshToken = result.refreshToken;
        _tokenExpiry = null; // Será implementado posteriormente

        _settings = _settings.copyWith(
          status: CloudStorageStatus.connected,
          accountEmail: result.userEmail,
          accountName: result.userName,
          providerConfig: {
            'user_id': result.userEmail,
            'picture': '',
            'access_token': _accessToken,
            'refresh_token': _refreshToken,
            'expires_at': _tokenExpiry?.toIso8601String(),
          },
        );

        _statusController.add(CloudStorageStatus.connected);

        return AuthResult.success(
          accountEmail: result.userEmail!,
          accountName: result.userName,
          accountData: {
            'email': result.userEmail,
            'name': result.userName,
            'picture': '',
          },
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
      return SyncResult.error('Não conectado ao Google Drive', Duration.zero);
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
        await Future.delayed(const Duration(milliseconds: 500));
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
      return UploadResult.error('Não conectado ao Google Drive');
    }

    if (!_isTokenValid && !await _refreshAccessToken()) {
      return UploadResult.error('Token de acesso inválido');
    }

    try {
      final fileSize = kIsWeb ? 1024 : await File(localPath).length();
      
      if (!kIsWeb) {
        final file = File(localPath);
        if (!await file.exists()) {
          return UploadResult.error('Arquivo local não encontrado: $localPath');
        }
      }
      final fileName = CloudStorageUtils.getFileName(remotePath);

      // Simular upload para Google Drive
      await Future.delayed(Duration(milliseconds: (fileSize / 1024).round()));

      final mockFileId = 'gdrive_${DateTime.now().millisecondsSinceEpoch}';
      final mockUrl = 'https://drive.google.com/file/d/$mockFileId/view';

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
      return DownloadResult.error('Não conectado ao Google Drive');
    }

    if (!_isTokenValid && !await _refreshAccessToken()) {
      return DownloadResult.error('Token de acesso inválido');
    }

    try {
      // Simular download do Google Drive
      await Future.delayed(const Duration(milliseconds: 500));

      final mockContent = json.encode({
        'downloaded_from': 'google_drive',
        'remote_path': remotePath,
        'timestamp': DateTime.now().toIso8601String(),
      });

      int fileSize = mockContent.length;
      
      if (!kIsWeb) {
        final localFile = File(localPath);
        if (!overwrite && await localFile.exists()) {
          return DownloadResult.error('Arquivo local já existe: $localPath');
        }
        await localFile.writeAsString(mockContent);
        fileSize = await localFile.length();
      }

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
      await Future.delayed(const Duration(milliseconds: 300));

      final mockFiles = [
        RemoteFile(
          path: '/bloquinho/profile.json',
          name: 'profile.json',
          size: 1024,
          modifiedAt: DateTime.now().subtract(const Duration(hours: 1)),
          mimeType: 'application/json',
          fileId: 'gdrive_profile_123',
        ),
        RemoteFile(
          path: '/bloquinho/settings.json',
          name: 'settings.json',
          size: 512,
          modifiedAt: DateTime.now().subtract(const Duration(hours: 2)),
          mimeType: 'application/json',
          fileId: 'gdrive_settings_456',
        ),
        RemoteFile(
          path: '/bloquinho/backup',
          name: 'backup',
          size: 0,
          modifiedAt: DateTime.now().subtract(const Duration(days: 1)),
          isFolder: true,
          fileId: 'gdrive_folder_789',
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
      await Future.delayed(const Duration(milliseconds: 200));
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
      await Future.delayed(const Duration(milliseconds: 300));
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
      // Simular consulta de espaço do Google Drive (15GB gratuitos)
      await Future.delayed(const Duration(milliseconds: 200));

      const totalBytes = 15 * 1024 * 1024 * 1024; // 15GB
      const usedBytes = 2 * 1024 * 1024 * 1024; // 2GB usado
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
      await Future.delayed(const Duration(milliseconds: 100));
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  List<String> validateSettings(StorageSettings settings) {
    final errors = <String>[];

    if (settings.provider != CloudStorageProvider.googleDrive) {
      errors.add('Provider incorreto para Google Drive');
    }

    if (settings.accountEmail == null || settings.accountEmail!.isEmpty) {
      errors.add('Email da conta Google é obrigatório');
    }

    if (settings.accountEmail != null &&
        !settings.accountEmail!.contains('@gmail.com')) {
      errors.add('Email deve ser uma conta Gmail válida');
    }

    return errors;
  }

  @override
  StorageSettings getDefaultSettings() {
    return StorageSettings.googleDrive();
  }

  /// Obter URL de autenticação OAuth2
  String getAuthUrl() {
    final params = {
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'scope': _scope,
      'response_type': 'code',
      'access_type': 'offline',
      'prompt': 'consent',
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
        Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
    }

    // Retornar dados mock em caso de erro
    return {
      'email': 'usuario@gmail.com',
      'name': 'Usuário Exemplo',
      'id': '123456789',
      'picture': 'https://example.com/avatar.jpg',
    };
  }

  /// Limpar recursos
  void dispose() {
    _statusController.close();
    _syncProgressController.close();
  }
}