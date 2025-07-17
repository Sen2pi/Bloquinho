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
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

import 'platform_service.dart';
import 'cloud_storage_service.dart';
import '../models/storage_settings.dart';
import '../models/auth_result.dart';
import 'oauth2_service_web.dart' as oauth2;

/// Service for handling web authentication and cloud storage requirements
class WebAuthService {
  static WebAuthService? _instance;

  WebAuthService._internal();

  static WebAuthService get instance {
    _instance ??= WebAuthService._internal();
    return _instance!;
  }

  final _authStateController = StreamController<WebAuthState>.broadcast();
  final _platformService = PlatformService.instance;

  WebAuthState _currentState = WebAuthState.unauthenticated;
  CloudStorageService? _cloudStorage;
  StorageSettings? _storageSettings;

  /// Stream of authentication state changes
  Stream<WebAuthState> get authStateStream => _authStateController.stream;

  /// Current authentication state
  WebAuthState get currentState => _currentState;

  /// Check if authentication is required
  bool get isAuthRequired => _platformService.requiresCloudAuth;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentState == WebAuthState.authenticated;

  /// Check if cloud storage is connected
  bool get isCloudConnected => _cloudStorage?.isConnected ?? false;

  /// Current storage settings
  StorageSettings? get storageSettings => _storageSettings;

  /// Initialize the web auth service
  Future<void> initialize() async {
    if (!kIsWeb) return;

    try {
      // Check if there's a saved authentication state
      await _loadStoredAuthState();

      // If required and not authenticated, set state to required
      if (isAuthRequired && !isAuthenticated) {
        _updateState(WebAuthState.required);
      }
    } catch (e) {
      _updateState(WebAuthState.error);
    }
  }

  Future<AuthResult> authenticateWithProvider(String provider) async {
    if (!kIsWeb) {
      return AuthResult.error('Autenticação web só está disponível nesta plataforma.');
    }

    try {
      _updateState(WebAuthState.authenticating);

      final oauth2Service = oauth2.OAuth2Service();
      final config = await _loadOAuth2Config();
      if (config == null) {
        return AuthResult.error('As credenciais OAuth2 não estão configuradas. Consulte a documentação.');
      }
      await oauth2Service.initialize(config);
      final authResult = await oauth2Service.authenticate(provider);

      if (authResult.success) {
        _storageSettings = provider == 'google'
            ? StorageSettings.googleDrive(
                email: authResult.userEmail!,
                name: authResult.userName,
                config: authResult.accountData,
              )
            : StorageSettings.oneDrive(
                email: authResult.userEmail!,
                name: authResult.userName,
                config: authResult.accountData,
              );

        await _saveAuthState();
        await _initializeCloudStorage();

        _updateState(WebAuthState.authenticated);
        return AuthResult.success(
          accountEmail: authResult.userEmail!,
          accountName: authResult.userName,
          accountData: authResult.accountData,
        );
      } else {
        _updateState(WebAuthState.error);
        return AuthResult.error(authResult.error ?? 'Erro desconhecido');
      }
    } catch (e) {
      _updateState(WebAuthState.error);
      return AuthResult.error('Falha na autenticação: ${e.toString()}');
    }
  }

  /// Sign out from cloud storage
  Future<void> signOut() async {
    if (!kIsWeb) return;

    try {
      // Disconnect from cloud storage
      if (_cloudStorage != null) {
        await _cloudStorage!.disconnect();
      }

      // Clear stored authentication state
      await _clearAuthState();

      _storageSettings = null;
      _cloudStorage = null;
      _updateState(WebAuthState.unauthenticated);
    } catch (e) {
      _updateState(WebAuthState.error);
    }
  }

  /// Check if cloud folder exists and create if needed
  Future<bool> ensureCloudFolderExists() async {
    if (_cloudStorage == null) return false;

    try {
      const folderPath = '/Bloquinho';

      // Check if folder exists
      final exists = await _cloudStorage!.fileExists(folderPath);

      if (!exists) {
        // Create the folder
        final created = await _cloudStorage!.createFolder(folderPath);
        if (!created) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get cloud storage service
  CloudStorageService? get cloudStorage => _cloudStorage;

  /// Update authentication state
  void _updateState(WebAuthState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _authStateController.add(newState);
    }
  }

  /// Load stored authentication state
  Future<void> _loadStoredAuthState() async {
    if (!kIsWeb) return;

    try {
      // Check localStorage for auth data
      final authDataString = await _getLocalStorage('bloquinho_auth_data');
      if (authDataString != null) {
        final authData = jsonDecode(authDataString);
        final storageData = authData['storage_settings'];

        if (storageData != null) {
          _storageSettings = StorageSettings(
            provider: storageData['provider'] == 'googleDrive'
                ? CloudStorageProvider.googleDrive
                : CloudStorageProvider.oneDrive,
            accountEmail: storageData['accountEmail'],
            accountName: storageData['accountName'],
            providerConfig: Map<String, dynamic>.from(storageData),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // Initialize cloud storage
          await _initializeCloudStorage();

          _updateState(WebAuthState.authenticated);
        }
      }
    } catch (e) {
      // Ignore errors and continue as unauthenticated
    }
  }

  /// Save authentication state
  Future<void> _saveAuthState() async {
    if (!kIsWeb || _storageSettings == null) return;

    try {
      final authData = {
        'storage_settings': {
          'provider':
              _storageSettings!.provider == CloudStorageProvider.googleDrive
                  ? 'googleDrive'
                  : 'oneDrive',
          'accountEmail': _storageSettings!.accountEmail,
          'accountName': _storageSettings!.accountName,
          'status':
              _storageSettings!.isConnected ? 'connected' : 'disconnected',
                      'accessToken': _storageSettings!.providerConfig['access_token'] ?? '',
          'timestamp': DateTime.now().toIso8601String(),
        },
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _setLocalStorage('bloquinho_auth_data', jsonEncode(authData));
    } catch (e) {
      // Ignore storage errors
    }
  }

  /// Clear authentication state
  Future<void> _clearAuthState() async {
    if (!kIsWeb) return;

    try {
      await _removeLocalStorage('bloquinho_auth_data');
    } catch (e) {
      // Ignore errors
    }
  }

  /// Get value from localStorage
  Future<String?> _getLocalStorage(String key) async {
    if (!kIsWeb) return null;

    try {
      // Use JavaScript interop to access localStorage
      return _evaluateJavaScript('localStorage.getItem("$key")');
    } catch (e) {
      return null;
    }
  }

  /// Set value in localStorage
  Future<void> _setLocalStorage(String key, String value) async {
    if (!kIsWeb) return;

    try {
      _evaluateJavaScript('localStorage.setItem("$key", ${jsonEncode(value)})');
    } catch (e) {
      // Ignore errors
    }
  }

  /// Remove value from localStorage
  Future<void> _removeLocalStorage(String key) async {
    if (!kIsWeb) return;

    try {
      _evaluateJavaScript('localStorage.removeItem("$key")');
    } catch (e) {
      // Ignore errors
    }
  }

  /// Evaluate JavaScript code using dart:js_interop
  String? _evaluateJavaScript(String code) {
    try {
      if (code.startsWith('localStorage.getItem(')) {
        final key = code.substring(21, code.length - 2);
        return html.window.localStorage[key];
      } else if (code.startsWith('localStorage.setItem(')) {
        final parts = code.substring(21, code.length - 1).split(',');
        final key = parts[0].replaceAll('"', '').trim();
        final value = parts[1].trim();
        html.window.localStorage[key] = value.replaceAll('"', '');
        return null;
      } else if (code.startsWith('localStorage.removeItem(')) {
        final key = code.substring(24, code.length - 2);
        html.window.localStorage.remove(key);
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Initialize cloud storage service
  Future<void> _initializeCloudStorage() async {
    if (_storageSettings == null) return;

    try {
      // This would initialize the actual cloud storage service
      // For now, we'll create a mock implementation
      _cloudStorage = _MockCloudStorageService(_storageSettings!);
    } catch (e) {
      _cloudStorage = null;
    }
  }

  Future<oauth2.OAuth2Config?> _loadOAuth2Config() async {
    try {
      return const oauth2.OAuth2Config(
        googleClientId: '869649040-7sou7ac0k0bpnuebr6e32qr40lfb3ndc.apps.googleusercontent.com',
        googleClientSecret: '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',
        microsoftClientId: 'ebe4d0f9-ff8a-43b8-b79a-2e44cdde8b94',
      );
    } catch (e) {
      return null;
    }
  }

  

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}

/// Web authentication states
enum WebAuthState {
  unauthenticated,
  required,
  authenticating,
  authenticated,
  error;

  String get displayName {
    switch (this) {
      case WebAuthState.unauthenticated:
        return 'Not Signed In';
      case WebAuthState.required:
        return 'Sign In Required';
      case WebAuthState.authenticating:
        return 'Signing In...';
      case WebAuthState.authenticated:
        return 'Signed In';
      case WebAuthState.error:
        return 'Authentication Error';
    }
  }
}

/// Mock cloud storage service for demonstration
class _MockCloudStorageService extends CloudStorageService {
  final StorageSettings _settings;
  bool _isConnected = true;

  _MockCloudStorageService(this._settings);

  @override
  CloudStorageProvider get provider => _settings.provider;

  @override
  bool get isConnected => _isConnected;

  @override
  bool get isSyncing => false;

  @override
  StorageSettings get settings => _settings;

  @override
  Future<AuthResult> authenticate({Map<String, dynamic>? config}) async {
    return AuthResult.success(
      accountEmail: _settings.accountEmail ?? 'user@example.com',
      accountName: _settings.accountName ?? 'User',
    );
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
  }

  @override
  Future<bool> createFolder(String folderPath) async {
    // Mock implementation
    return true;
  }

  @override
  Future<bool> fileExists(String remotePath) async {
    // Mock implementation
    return remotePath == '/Bloquinho';
  }

  @override
  Stream<CloudStorageStatus> get statusStream =>
      Stream.value(CloudStorageStatus.connected);

  @override
  Stream<SyncProgress> get syncProgressStream => const Stream.empty();

  // Implement other required methods with mock implementations
  @override
  Future<SyncResult> sync(
      {bool forceSync = false, List<String>? specificFiles}) async {
    return SyncResult.success(duration: const Duration(seconds: 1));
  }

  @override
  Future<UploadResult> uploadFile(
      {required String localPath,
      required String remotePath,
      bool overwrite = true}) async {
    return UploadResult.success(remoteUrl: remotePath);
  }

  @override
  Future<DownloadResult> downloadFile(
      {required String remotePath,
      required String localPath,
      bool overwrite = true}) async {
    return DownloadResult.success(localPath: localPath);
  }

  @override
  Future<List<RemoteFile>> listFiles(
      {String? folderPath, bool recursive = false}) async {
    return [];
  }

  @override
  Future<bool> deleteFile(String remotePath) async {
    return true;
  }

  @override
  Future<RemoteFile?> getFileInfo(String remotePath) async {
    return null;
  }

  @override
  Future<StorageSpace> getStorageSpace() async {
    return StorageSpace(
      totalBytes: 15000000000, // 15GB
      usedBytes: 5000000000, // 5GB
      availableBytes: 10000000000, // 10GB
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<bool> checkConnectivity() async {
    return true;
  }

  @override
  List<String> validateSettings(StorageSettings settings) {
    return [];
  }

  @override
  StorageSettings getDefaultSettings() {
    return _settings;
  }

  @override
  void updateSettings(StorageSettings settings) {
    // Mock implementation
  }
}
