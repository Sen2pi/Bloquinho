import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'oauth2_service.dart';

/// Serviço para gerenciar pastas e estrutura de dados na nuvem
class CloudFolderService {
  static const String _appFolderName = 'Bloquinho';

  /// Estrutura de pastas padrão do Bloquinho
  static const Map<String, List<String>> _folderStructure = {
    'profiles': [], // /Bloquinho/profiles/
    'workspaces': [], // /Bloquinho/workspaces/
    'documents': [
      'notes',
      'files',
      'images'
    ], // /Bloquinho/documents/notes/, etc.
    'backups': [], // /Bloquinho/backups/
    'settings': [], // /Bloquinho/settings/
  };

  /// Criar estrutura de pastas no Google Drive
  static Future<Map<String, String>> createGoogleDriveFolders() async {
    final client = await OAuth2Service.restoreGoogleClient();
    if (client == null) {
      throw Exception('Cliente Google Drive não disponível');
    }

    debugPrint('🗂️ Criando estrutura de pastas no Google Drive...');

    final Map<String, String> folderIds = {};

    try {
      // 1. Verificar se pasta principal já existe
      String? appFolderId =
          await _findGoogleDriveFolder(client, _appFolderName, null);

      if (appFolderId == null) {
        // Criar pasta principal
        appFolderId =
            await _createGoogleDriveFolder(client, _appFolderName, null);
        debugPrint('✅ Pasta principal criada: $_appFolderName');
      } else {
        debugPrint('📁 Pasta principal já existe: $_appFolderName');
      }

      folderIds['root'] = appFolderId;

      // 2. Criar subpastas
      for (final entry in _folderStructure.entries) {
        final folderName = entry.key;
        final subFolders = entry.value;

        // Criar pasta principal
        String? folderId =
            await _findGoogleDriveFolder(client, folderName, appFolderId);

        if (folderId == null) {
          folderId =
              await _createGoogleDriveFolder(client, folderName, appFolderId);
          debugPrint('✅ Subpasta criada: $folderName');
        } else {
          debugPrint('📁 Subpasta já existe: $folderName');
        }

        folderIds[folderName] = folderId;

        // Criar sub-subpastas se necessário
        for (final subFolder in subFolders) {
          String? subFolderId =
              await _findGoogleDriveFolder(client, subFolder, folderId);

          if (subFolderId == null) {
            subFolderId =
                await _createGoogleDriveFolder(client, subFolder, folderId);
            debugPrint('✅ Sub-subpasta criada: $folderName/$subFolder');
          } else {
            debugPrint('📁 Sub-subpasta já existe: $folderName/$subFolder');
          }

          folderIds['$folderName/$subFolder'] = subFolderId;
        }
      }

      debugPrint('🎉 Estrutura Google Drive criada com sucesso!');
      return folderIds;
    } catch (e) {
      debugPrint('❌ Erro ao criar estrutura Google Drive: $e');
      rethrow;
    }
  }

  /// Criar estrutura de pastas no OneDrive
  static Future<Map<String, String>> createOneDriveFolders() async {
    final client = await OAuth2Service.restoreMicrosoftClient();
    if (client == null) {
      throw Exception('Cliente OneDrive não disponível');
    }

    debugPrint('🗂️ Criando estrutura de pastas no OneDrive...');

    final Map<String, String> folderIds = {};

    try {
      // 1. Verificar se pasta principal já existe
      String? appFolderId =
          await _findOneDriveFolder(client, _appFolderName, null);

      if (appFolderId == null) {
        // Criar pasta principal
        appFolderId = await _createOneDriveFolder(client, _appFolderName, null);
        debugPrint('✅ Pasta principal criada: $_appFolderName');
      } else {
        debugPrint('📁 Pasta principal já existe: $_appFolderName');
      }

      folderIds['root'] = appFolderId;

      // 2. Criar subpastas
      for (final entry in _folderStructure.entries) {
        final folderName = entry.key;
        final subFolders = entry.value;

        // Criar pasta principal
        String? folderId =
            await _findOneDriveFolder(client, folderName, appFolderId);

        if (folderId == null) {
          folderId =
              await _createOneDriveFolder(client, folderName, appFolderId);
          debugPrint('✅ Subpasta criada: $folderName');
        } else {
          debugPrint('📁 Subpasta já existe: $folderName');
        }

        folderIds[folderName] = folderId;

        // Criar sub-subpastas se necessário
        for (final subFolder in subFolders) {
          String? subFolderId =
              await _findOneDriveFolder(client, subFolder, folderId);

          if (subFolderId == null) {
            subFolderId =
                await _createOneDriveFolder(client, subFolder, folderId);
            debugPrint('✅ Sub-subpasta criada: $folderName/$subFolder');
          } else {
            debugPrint('📁 Sub-subpasta já existe: $folderName/$subFolder');
          }

          folderIds['$folderName/$subFolder'] = subFolderId;
        }
      }

      debugPrint('🎉 Estrutura OneDrive criada com sucesso!');
      return folderIds;
    } catch (e) {
      debugPrint('❌ Erro ao criar estrutura OneDrive: $e');
      rethrow;
    }
  }

  /// Verificar e criar estrutura de pastas automaticamente
  static Future<bool> ensureCloudFoldersExist() async {
    try {
      debugPrint('🔄 Verificando estrutura de pastas na nuvem...');

      bool hasGoogleDrive = await OAuth2Service.isGoogleAuthenticated();
      bool hasOneDrive = await OAuth2Service.isMicrosoftAuthenticated();

      if (!hasGoogleDrive && !hasOneDrive) {
        debugPrint('📱 Nenhuma conexão na nuvem disponível');
        return false;
      }

      // Criar estruturas conforme disponibilidade
      if (hasGoogleDrive) {
        try {
          await createGoogleDriveFolders();
          debugPrint('✅ Estrutura Google Drive verificada/criada');
        } catch (e) {
          debugPrint('⚠️ Erro na estrutura Google Drive: $e');
        }
      }

      if (hasOneDrive) {
        try {
          await createOneDriveFolders();
          debugPrint('✅ Estrutura OneDrive verificada/criada');
        } catch (e) {
          debugPrint('⚠️ Erro na estrutura OneDrive: $e');
        }
      }

      return true;
    } catch (e) {
      debugPrint('❌ Erro ao verificar estrutura de pastas: $e');
      return false;
    }
  }

  /// Buscar pasta no Google Drive
  static Future<String?> _findGoogleDriveFolder(
      http.Client client, String folderName, String? parentId) async {
    try {
      String query =
          "name='$folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false";

      if (parentId != null) {
        query += " and '$parentId' in parents";
      } else {
        query += " and 'root' in parents";
      }

      final response = await client.get(
        Uri.parse(
            'https://www.googleapis.com/drive/v3/files?q=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final files = data['files'] as List;

        if (files.isNotEmpty) {
          return files.first['id'];
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Erro ao buscar pasta Google Drive: $e');
      return null;
    }
  }

  /// Criar pasta no Google Drive
  static Future<String> _createGoogleDriveFolder(
      http.Client client, String folderName, String? parentId) async {
    final metadata = {
      'name': folderName,
      'mimeType': 'application/vnd.google-apps.folder',
      'parents': parentId != null ? [parentId] : ['root'],
    };

    final response = await client.post(
      Uri.parse('https://www.googleapis.com/drive/v3/files'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(metadata),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'];
    }

    throw Exception('Erro ao criar pasta Google Drive: ${response.statusCode}');
  }

  /// Buscar pasta no OneDrive
  static Future<String?> _findOneDriveFolder(
      http.Client client, String folderName, String? parentId) async {
    try {
      String url;

      if (parentId != null) {
        url =
            'https://graph.microsoft.com/v1.0/me/drive/items/$parentId/children?\$filter=name eq \'$folderName\' and folder ne null';
      } else {
        url =
            'https://graph.microsoft.com/v1.0/me/drive/root/children?\$filter=name eq \'$folderName\' and folder ne null';
      }

      final response = await client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['value'] as List;

        if (items.isNotEmpty) {
          return items.first['id'];
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Erro ao buscar pasta OneDrive: $e');
      return null;
    }
  }

  /// Criar pasta no OneDrive
  static Future<String> _createOneDriveFolder(
      http.Client client, String folderName, String? parentId) async {
    final metadata = {
      'name': folderName,
      'folder': {},
      '@microsoft.graph.conflictBehavior': 'rename',
    };

    String url;
    if (parentId != null) {
      url =
          'https://graph.microsoft.com/v1.0/me/drive/items/$parentId/children';
    } else {
      url = 'https://graph.microsoft.com/v1.0/me/drive/root/children';
    }

    final response = await client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(metadata),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'];
    }

    throw Exception('Erro ao criar pasta OneDrive: ${response.statusCode}');
  }

  /// Obter informações de uma pasta específica
  static Future<Map<String, dynamic>?> getFolderInfo(String folderId,
      {bool isOneDrive = false}) async {
    try {
      http.Client? client;
      String url;

      if (isOneDrive) {
        client = await OAuth2Service.restoreMicrosoftClient();
        url = 'https://graph.microsoft.com/v1.0/me/drive/items/$folderId';
      } else {
        client = await OAuth2Service.restoreGoogleClient();
        url = 'https://www.googleapis.com/drive/v3/files/$folderId';
      }

      if (client == null) return null;

      final response = await client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      debugPrint('❌ Erro ao obter info da pasta: $e');
      return null;
    }
  }

  /// Listar arquivos em uma pasta
  static Future<List<Map<String, dynamic>>> listFolderContents(String folderId,
      {bool isOneDrive = false}) async {
    try {
      http.Client? client;
      String url;

      if (isOneDrive) {
        client = await OAuth2Service.restoreMicrosoftClient();
        url =
            'https://graph.microsoft.com/v1.0/me/drive/items/$folderId/children';
      } else {
        client = await OAuth2Service.restoreGoogleClient();
        url =
            'https://www.googleapis.com/drive/v3/files?q=\'$folderId\' in parents and trashed=false';
      }

      if (client == null) return [];

      final response = await client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (isOneDrive) {
          return List<Map<String, dynamic>>.from(data['value'] ?? []);
        } else {
          return List<Map<String, dynamic>>.from(data['files'] ?? []);
        }
      }

      return [];
    } catch (e) {
      debugPrint('❌ Erro ao listar conteúdo da pasta: $e');
      return [];
    }
  }
}
