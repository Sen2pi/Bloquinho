/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 *
*/
import 'package:flutter/foundation.dart';

/// Service for handling platform-specific requirements
class PlatformService {
  static PlatformService? _instance;

  PlatformService._internal();

  static PlatformService get instance {
    _instance ??= PlatformService._internal();
    return _instance!;
  }

  /// Check if the app is running on web platform
  bool get isWeb => kIsWeb;

  /// Check if the app is running on mobile platform
  bool get isMobile => !kIsWeb;

  /// Check if the app is running on desktop platform
  bool get isDesktop {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  /// Check if cloud authentication is required for the current platform
  bool get requiresCloudAuth => isWeb;

  /// Get the current platform name
  String get platformName {
    if (kIsWeb) return 'web';
    if (!kIsWeb) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return 'android';
        case TargetPlatform.iOS:
          return 'ios';
        case TargetPlatform.windows:
          return 'windows';
        case TargetPlatform.macOS:
          return 'macos';
        case TargetPlatform.linux:
          return 'linux';
        default:
          return 'unknown';
      }
    }
    return 'web';
  }

  /// Get user agent information (web only)
  String? get userAgent {
    if (!kIsWeb) return null;
    // Simplified for now - web package removed
    return null;
  }

  /// Check if the browser supports the required features (web only)
  bool get supportsRequiredFeatures {
    if (!kIsWeb) return true;
    // Simplified for now - web package removed
    return true;
  }

  /// Get the domain for web apps
  String? get webDomain {
    if (!kIsWeb) return null;
    // Simplified for now - web package removed
    return null;
  }

  /// Check if running on localhost
  bool get isLocalhost {
    if (!kIsWeb) return false;
    final domain = webDomain;
    return domain == 'localhost' ||
        domain == '127.0.0.1' ||
        domain?.startsWith('192.168.') == true;
  }

  /// Check if running on production domain
  bool get isProduction {
    if (!kIsWeb) return false;
    final domain = webDomain;
    return domain != null && !isLocalhost && !domain.contains('staging');
  }

  /// Get storage type based on platform
  StorageType get recommendedStorageType {
    if (isWeb) return StorageType.cloud;
    if (isDesktop) return StorageType.local;
    return StorageType.hybrid;
  }

  /// Check if the platform supports local file system
  bool get supportsLocalFileSystem => !kIsWeb;

  /// Check if the platform supports cloud storage
  bool get supportsCloudStorage => true;

  /// Get platform-specific error messages
  String getPlatformSpecificMessage(String messageKey) {
    switch (messageKey) {
      case 'storage_required':
        if (isWeb) {
          return 'Web users must authenticate with cloud storage to save documents';
        }
        return 'Local storage is available on this platform';
      case 'auth_required':
        if (isWeb) {
          return 'Please sign in with your Google account to continue';
        }
        return 'Authentication is optional on this platform';
      case 'offline_mode':
        if (isWeb) {
          return 'Limited offline functionality available';
        }
        return 'Full offline mode available';
      default:
        return 'Platform-specific feature';
    }
  }

  /// Get platform capabilities
  PlatformCapabilities get capabilities {
    return PlatformCapabilities(
      supportsLocalStorage: supportsLocalFileSystem,
      supportsCloudStorage: supportsCloudStorage,
      requiresAuth: requiresCloudAuth,
      supportsOfflineMode: !isWeb,
      supportsPushNotifications: !isWeb,
      supportsFileDialog: !isWeb,
      supportsSystemTray: isDesktop,
      supportsFullscreen: !isWeb,
    );
  }
}

/// Enum for storage types
enum StorageType {
  local,
  cloud,
  hybrid;

  String get displayName {
    switch (this) {
      case StorageType.local:
        return 'Local Storage';
      case StorageType.cloud:
        return 'Cloud Storage';
      case StorageType.hybrid:
        return 'Hybrid Storage';
    }
  }
}

/// Platform capabilities model
class PlatformCapabilities {
  final bool supportsLocalStorage;
  final bool supportsCloudStorage;
  final bool requiresAuth;
  final bool supportsOfflineMode;
  final bool supportsPushNotifications;
  final bool supportsFileDialog;
  final bool supportsSystemTray;
  final bool supportsFullscreen;

  const PlatformCapabilities({
    required this.supportsLocalStorage,
    required this.supportsCloudStorage,
    required this.requiresAuth,
    required this.supportsOfflineMode,
    required this.supportsPushNotifications,
    required this.supportsFileDialog,
    required this.supportsSystemTray,
    required this.supportsFullscreen,
  });

  @override
  String toString() {
    return 'PlatformCapabilities('
        'localStorage: $supportsLocalStorage, '
        'cloudStorage: $supportsCloudStorage, '
        'requiresAuth: $requiresAuth, '
        'offline: $supportsOfflineMode'
        ')';
  }
}
