import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Serviço para cache de avatares de perfil
class AvatarCacheService {
  static const String _avatarsCacheFolder = 'avatars_cache';
  static const String _metadataKey = 'avatars_metadata';
  static const _storage = FlutterSecureStorage();

  /// Baixar e armazenar avatar de URL
  static Future<String?> downloadAndCacheAvatar({
    required String url,
    required String userId,
    String? fileName,
  }) async {
    // No web, cache de arquivos não é totalmente suportado
    if (kIsWeb) {
      return null;
    }

    try {
      // Gerar nome único para o arquivo
      final urlHash = md5.convert(utf8.encode(url)).toString();
      final finalFileName = fileName ?? 'avatar_${userId}_$urlHash.jpg';

      // Obter diretório de cache
      final cacheDir = await _getAvatarsCacheDirectory();
      final filePath = path.join(cacheDir.path, finalFileName);
      final file = File(filePath);

      // Verificar se já existe e é recente (menos de 1 dia)
      if (await file.exists()) {
        final metadata = await _getAvatarMetadata(finalFileName);
        if (metadata != null &&
            DateTime.now().difference(metadata['cachedAt']).inDays < 1) {
          return filePath;
        }
      }

      // Baixar imagem

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Bloquinho/1.0',
          'Accept': 'image/jpeg,image/png,image/gif,image/webp,image/*',
        },
      );

      if (response.statusCode == 200) {
        // Salvar arquivo
        await file.writeAsBytes(response.bodyBytes);

        // Salvar metadata
        await _saveAvatarMetadata(finalFileName, {
          'url': url,
          'userId': userId,
          'cachedAt': DateTime.now().toIso8601String(),
          'filePath': filePath,
          'size': response.bodyBytes.length,
        });

        return filePath;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Obter avatar em cache
  static Future<String?> getCachedAvatar(String userId) async {
    // No web, retornar null (cache não suportado)
    if (kIsWeb) {
      return null;
    }

    try {
      final cacheDir = await _getAvatarsCacheDirectory();
      final files = await cacheDir.list().toList();

      for (final file in files) {
        if (file is File && file.path.contains('avatar_$userId')) {
          if (await file.exists()) {
            return file.path;
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Limpar cache de avatares antigos
  static Future<void> cleanOldCache({int maxDays = 7}) async {
    // No web, não há cache de arquivos para limpar
    if (kIsWeb) {
      return;
    }

    try {
      final cacheDir = await _getAvatarsCacheDirectory();
      final files = await cacheDir.list().toList();
      final now = DateTime.now();

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          if (now.difference(stat.modified).inDays > maxDays) {
            await file.delete();
          }
        }
      }
    } catch (e) {}
  }

  /// Obter tamanho do cache
  static Future<int> getCacheSize() async {
    // No web, retornar 0 (sem cache de arquivos)
    if (kIsWeb) {
      return 0;
    }

    try {
      final cacheDir = await _getAvatarsCacheDirectory();
      final files = await cacheDir.list().toList();
      int totalSize = 0;

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          totalSize += stat.size;
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Limpar todo o cache
  static Future<void> clearAllCache() async {
    try {
      // Limpar metadata (funciona tanto no web quanto mobile)
      await _storage.delete(key: _metadataKey);

      // No web, só limpamos metadata
      if (kIsWeb) {
        return;
      }

      // Em mobile, limpar arquivos também
      final cacheDir = await _getAvatarsCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {}
  }

  /// Obter diretório de cache de avatares (público)
  static Future<Directory> getAvatarsCacheDirectory() async {
    return await _getAvatarsCacheDirectory();
  }

  /// Obter diretório de cache de avatares
  static Future<Directory> _getAvatarsCacheDirectory() async {
    Directory appDir;

    if (kIsWeb) {
      // No web, usar diretório temporário
      appDir = Directory.systemTemp;
    } else {
      try {
        // Em plataformas nativas, usar diretório de documentos
        appDir = await getApplicationDocumentsDirectory();
      } catch (e) {
        // Fallback para diretório temporário
        appDir = Directory.systemTemp;
      }
    }

    final cacheDir = Directory(path.join(appDir.path, _avatarsCacheFolder));

    if (!kIsWeb && !await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }

  /// Salvar metadata do avatar
  static Future<void> _saveAvatarMetadata(
      String fileName, Map<String, dynamic> metadata) async {
    try {
      final existingMetadata = await _getAllAvatarMetadata();
      existingMetadata[fileName] = metadata;

      final jsonString = json.encode(existingMetadata);
      await _storage.write(key: _metadataKey, value: jsonString);
    } catch (e) {}
  }

  /// Obter metadata de um avatar específico
  static Future<Map<String, dynamic>?> _getAvatarMetadata(
      String fileName) async {
    try {
      final allMetadata = await _getAllAvatarMetadata();
      final metadata = allMetadata[fileName];

      if (metadata != null) {
        return {
          ...metadata,
          'cachedAt': DateTime.parse(metadata['cachedAt']),
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obter todos os metadados
  static Future<Map<String, dynamic>> _getAllAvatarMetadata() async {
    try {
      final jsonString = await _storage.read(key: _metadataKey);
      if (jsonString != null) {
        return Map<String, dynamic>.from(json.decode(jsonString));
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Estatísticas do cache
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      if (kIsWeb) {
        return {
          'totalFiles': 0,
          'totalSize': 0,
          'totalSizeMB': '0.00',
          'cacheDirectory': 'N/A (Web)',
          'platform': 'web',
        };
      }

      final cacheDir = await _getAvatarsCacheDirectory();
      final files = await cacheDir.list().toList();
      final totalSize = await getCacheSize();

      return {
        'totalFiles': files.length,
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / 1024 / 1024).toStringAsFixed(2),
        'cacheDirectory': cacheDir.path,
        'platform': 'mobile',
      };
    } catch (e) {
      return {
        'totalFiles': 0,
        'totalSize': 0,
        'totalSizeMB': '0.00',
        'cacheDirectory': 'Error',
        'platform': 'unknown',
      };
    }
  }
}
