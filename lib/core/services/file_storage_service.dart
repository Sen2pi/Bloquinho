/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/user_profile.dart';

/// Serviço para gerenciar a estrutura organizada de dados locais
/// Estrutura: data/profile/[nome_profile]/workspaces/[workspace_name]/[componente]/
class FileStorageService {
  static const String _dataFolder = 'data';
  static const String _profileFolder = 'profile';
  static const String _workspacesFolder = 'workspaces';
  static const String _settingsFile = 'settings.json';
  static const String _profilePhotoFile = 'profile_photo.jpg';

  // Componentes principais
  static const String _bloquinhoFolder = 'bloquinho';
  static const String _documentsFolder = 'documents';
  static const String _agendaFolder = 'agenda';
  static const String _passwordsFolder = 'passwords';
  static const String _databasesFolder = 'databases';

  /// Instância singleton
  static final FileStorageService _instance = FileStorageService._internal();
  factory FileStorageService() => _instance;
  FileStorageService._internal();

  String? _basePath;
  bool _isInitialized = false;

  /// Inicializar o serviço
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (kIsWeb) {
        // No web, usar armazenamento limitado
        _basePath = null;
        _isInitialized = true;
        return;
      }

      // Em plataformas nativas, usar diretório de documentos
      final appDir = await getApplicationDocumentsDirectory();
      _basePath = path.join(appDir.path, _dataFolder);

      // Criar pasta base se não existir
      final baseDir = Directory(_basePath!);
      if (!await baseDir.exists()) {
        await baseDir.create(recursive: true);
      }

      _isInitialized = true;
    } catch (e) {
      throw Exception('Erro ao inicializar armazenamento local: $e');
    }
  }

  /// Verificar se existe um perfil salvo
  Future<bool> hasExistingProfile() async {
    await _ensureInitialized();

    if (kIsWeb) return false;

    try {
      final profilesDir = Directory(path.join(_basePath!, _profileFolder));

      if (!await profilesDir.exists()) {
        return false;
      }

      // Listar pastas de perfis
      final profiles = await profilesDir.list(followLinks: false).toList();
      final profileFolders = profiles.whereType<Directory>().toList();

      // Verificar se existe pelo menos um perfil válido
      for (final profileFolder in profileFolders) {
        final settingsFile = File(path.join(profileFolder.path, _settingsFile));

        if (await settingsFile.exists()) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Obter lista de perfis existentes
  Future<List<UserProfile>> getExistingProfiles() async {
    await _ensureInitialized();

    if (kIsWeb) return [];

    try {
      final profilesDir = Directory(path.join(_basePath!, _profileFolder));
      if (!await profilesDir.exists()) return [];

      final profiles = <UserProfile>[];
      final entities = await profilesDir.list(followLinks: false).toList();
      final profileFolders = entities.whereType<Directory>().toList();

      for (final profileFolder in profileFolders) {
        final settingsFile = File(path.join(profileFolder.path, _settingsFile));
        if (await settingsFile.exists()) {
          try {
            final settingsContent = await settingsFile.readAsString();
            final profileData =
                Map<String, dynamic>.from(json.decode(settingsContent));
            final profile = UserProfile.fromJson(profileData);
            profiles.add(profile);
          } catch (e) {
          }
        }
      }

      return profiles;
    } catch (e) {
      return [];
    }
  }

  /// Obter primeiro perfil válido (para compatibilidade)
  Future<UserProfile?> getFirstProfile() async {
    final profiles = await getExistingProfiles();
    return profiles.isNotEmpty ? profiles.first : null;
  }

  /// Criar estrutura de pastas para um perfil
  Future<String> createProfileStructure(String profileName) async {
    await _ensureInitialized();

    if (kIsWeb) {
      throw Exception('Criação de estrutura de pastas não suportada no web');
    }

    try {
      // Sanitizar nome do perfil para uso como pasta
      final safeName = _sanitizeFileName(profileName);
      final profilePath = path.join(_basePath!, _profileFolder, safeName);

      // Criar pasta do perfil
      final profileDir = Directory(profilePath);
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      // Criar pasta de workspaces
      final workspacesDir =
          Directory(path.join(profilePath, _workspacesFolder));
      if (!await workspacesDir.exists()) {
        await workspacesDir.create(recursive: true);
      }

      // Criar workspace padrão "Pessoal" com estrutura completa
      await _createDefaultWorkspaceStructure(profilePath, 'Pessoal');

      return profilePath;
    } catch (e) {
      throw Exception('Erro ao criar estrutura do perfil: $e');
    }
  }

  /// Criar estrutura padrão do workspace
  Future<void> _createDefaultWorkspaceStructure(
      String profilePath, String workspaceName) async {
    try {
      final safeWorkspaceName = _sanitizeFileName(workspaceName);
      final workspacePath =
          path.join(profilePath, _workspacesFolder, safeWorkspaceName);
      final workspaceDir = Directory(workspacePath);

      if (!await workspaceDir.exists()) {
        await workspaceDir.create(recursive: true);
      }

      // Criar pastas específicas do workspace
      final folders = [
        _bloquinhoFolder,
        _documentsFolder,
        _agendaFolder,
        _passwordsFolder,
        _databasesFolder
      ];

      for (final folder in folders) {
        final folderPath = path.join(workspacePath, folder);
        final folderDir = Directory(folderPath);

        if (!await folderDir.exists()) {
          await folderDir.create(recursive: true);
        }

        // Criar arquivos padrão para cada pasta
        await _createDefaultFiles(folderPath, folder);
      }

    } catch (e) {
      throw Exception('Erro ao criar estrutura do workspace: $e');
    }
  }

  /// Criar arquivos padrão para cada pasta
  Future<void> _createDefaultFiles(String folderPath, String folderType) async {
    try {
      switch (folderType) {
        case _bloquinhoFolder:
          // Criar página inicial do Bloquinho
          final welcomeFile = File(path.join(folderPath, 'Bem-vindo.md'));
          if (!await welcomeFile.exists()) {
            await welcomeFile.writeAsString('''
# Bem-vindo ao Bloquinho! 🎉

Esta é sua primeira página no Bloquinho. Aqui você pode:

- **Criar páginas** para suas notas e ideias
- **Organizar conteúdo** em pastas e subpastas
- **Usar formatação** markdown completa
- **Adicionar links** entre páginas
- **Inserir código** com syntax highlighting

## Começando

1. Clique no botão "+" para criar uma nova página
2. Use a barra lateral para navegar entre páginas
3. Digite "/" para acessar comandos rápidos

Boa escrita! ✨
''');
          }
          break;

        case _databasesFolder:
          // Criar arquivo de configuração da base de dados
          final dbConfigFile = File(path.join(folderPath, 'config.json'));
          if (!await dbConfigFile.exists()) {
            await dbConfigFile.writeAsString('''
{
  "workspace": "Pessoal",
  "createdAt": "${DateTime.now().toIso8601String()}",
  "tables": [],
  "version": "1.0"
}
''');
          }
          break;

        case _documentsFolder:
          // Criar arquivo de índice de documentos
          final docsIndexFile = File(path.join(folderPath, 'index.json'));
          if (!await docsIndexFile.exists()) {
            await docsIndexFile.writeAsString('''
{
  "workspace": "Pessoal",
  "createdAt": "${DateTime.now().toIso8601String()}",
  "documents": [],
  "categories": ["pessoal", "trabalho", "estudos"],
  "version": "1.0"
}
''');
          }
          break;

        case _agendaFolder:
          // Criar arquivo de configuração da agenda
          final agendaConfigFile = File(path.join(folderPath, 'config.json'));
          if (!await agendaConfigFile.exists()) {
            await agendaConfigFile.writeAsString('''
{
  "workspace": "Pessoal",
  "createdAt": "${DateTime.now().toIso8601String()}",
  "events": [],
  "reminders": [],
  "categories": ["pessoal", "trabalho", "saúde"],
  "version": "1.0"
}
''');
          }
          break;

        case _passwordsFolder:
          // Criar arquivo de configuração das senhas
          final passwordsConfigFile =
              File(path.join(folderPath, 'config.json'));
          if (!await passwordsConfigFile.exists()) {
            await passwordsConfigFile.writeAsString('''
{
  "workspace": "Pessoal",
  "createdAt": "${DateTime.now().toIso8601String()}",
  "passwords": [],
  "categories": ["pessoal", "trabalho", "financeiro"],
  "version": "1.0"
}
''');
          }
          break;
      }

    } catch (e) {
    }
  }

  /// Salvar perfil no arquivo settings.json
  Future<void> saveProfile(UserProfile profile) async {
    await _ensureInitialized();

    if (kIsWeb) {
      throw Exception('Salvamento de perfil não suportado no web');
    }

    try {
      // Criar estrutura se não existir
      final profilePath = await createProfileStructure(profile.name);

      // Salvar settings.json
      final settingsFile = File(path.join(profilePath, _settingsFile));
      final profileJson = json.encode(profile.toJson());
      await settingsFile.writeAsString(profileJson);

    } catch (e) {
      throw Exception('Erro ao salvar perfil: $e');
    }
  }

  /// Salvar foto de perfil
  Future<String?> saveProfilePhoto(
      String profileName, dynamic imageData) async {
    await _ensureInitialized();

    if (kIsWeb) {
      return null;
    }

    try {
      // Obter caminho do perfil
      final safeName = _sanitizeFileName(profileName);
      final profilePath = path.join(_basePath!, _profileFolder, safeName);
      final photoPath = path.join(profilePath, _profilePhotoFile);

      if (imageData is File) {
        // Copiar arquivo
        await imageData.copy(photoPath);
      } else if (imageData is List<int>) {
        // Salvar bytes
        final photoFile = File(photoPath);
        await photoFile.writeAsBytes(imageData);
      } else {
        throw Exception('Tipo de imagem não suportado');
      }

      return photoPath;
    } catch (e) {
      return null;
    }
  }

  /// Obter foto de perfil
  Future<File?> getProfilePhoto(String profileName) async {
    await _ensureInitialized();

    if (kIsWeb) return null;

    try {
      final safeName = _sanitizeFileName(profileName);
      final photoPath =
          path.join(_basePath!, _profileFolder, safeName, _profilePhotoFile);
      final photoFile = File(photoPath);

      if (await photoFile.exists()) {
        return photoFile;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obter pasta de workspaces para um perfil
  Future<Directory?> getWorkspacesDirectory(String profileName) async {
    await _ensureInitialized();

    if (kIsWeb) return null;

    try {
      final safeName = _sanitizeFileName(profileName);
      final workspacesPath =
          path.join(_basePath!, _profileFolder, safeName, _workspacesFolder);
      final workspacesDir = Directory(workspacesPath);

      if (await workspacesDir.exists()) {
        return workspacesDir;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Criar workspace para um perfil
  Future<Directory> createWorkspace(
      String profileName, String workspaceName) async {
    await _ensureInitialized();

    if (kIsWeb) {
      throw Exception('Criação de workspace não suportada no web');
    }

    try {
      final safeName = _sanitizeFileName(profileName);
      final safeWorkspaceName = _sanitizeFileName(workspaceName);
      final workspacePath = path.join(_basePath!, _profileFolder, safeName,
          _workspacesFolder, safeWorkspaceName);

      final workspaceDir = Directory(workspacePath);
      if (!await workspaceDir.exists()) {
        await workspaceDir.create(recursive: true);
      }

      // Criar estrutura completa do workspace
      await _createDefaultWorkspaceStructure(
          path.join(_basePath!, _profileFolder, safeName), workspaceName);

      return workspaceDir;
    } catch (e) {
      throw Exception('Erro ao criar workspace: $e');
    }
  }

  /// Listar workspaces de um perfil
  Future<List<String>> getWorkspaces(String profileName) async {
    final workspacesDir = await getWorkspacesDirectory(profileName);
    if (workspacesDir == null) return [];

    try {
      final entities = await workspacesDir.list(followLinks: false).toList();
      final workspaceFolders = entities.whereType<Directory>().toList();
      return workspaceFolders.map((dir) => path.basename(dir.path)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Deletar perfil e todos os seus dados
  Future<void> deleteProfile(String profileName) async {
    await _ensureInitialized();

    if (kIsWeb) {
      throw Exception('Deleção de perfil não suportada no web');
    }

    try {
      final safeName = _sanitizeFileName(profileName);
      final profilePath = path.join(_basePath!, _profileFolder, safeName);
      final profileDir = Directory(profilePath);

      if (await profileDir.exists()) {
        await profileDir.delete(recursive: true);
      }
    } catch (e) {
      throw Exception('Erro ao deletar perfil: $e');
    }
  }

  /// Obter diretório de um componente específico
  Future<Directory?> getComponentDirectory(
      String profileName, String workspaceName, String componentName) async {
    await _ensureInitialized();

    if (kIsWeb) return null;

    try {
      final workspacesDir = await getWorkspacesDirectory(profileName);
      if (workspacesDir == null) return null;

      final workspaceDir =
          Directory(path.join(workspacesDir.path, workspaceName));
      if (!await workspaceDir.exists()) return null;

      final componentDir =
          Directory(path.join(workspaceDir.path, componentName));
      if (!await componentDir.exists()) {
        await componentDir.create(recursive: true);
      }

      return componentDir;
    } catch (e) {
      return null;
    }
  }

  /// Salvar arquivo em um componente específico
  Future<void> saveFile(String profileName, String workspaceName,
      String componentName, String fileName, String content) async {
    await _ensureInitialized();

    if (kIsWeb) {
      throw Exception('Salvamento de arquivo não suportado no web');
    }

    try {
      final componentDir = await getComponentDirectory(
          profileName, workspaceName, componentName);
      if (componentDir == null) {
        throw Exception('Componente não encontrado');
      }

      final filePath = path.join(componentDir.path, fileName);
      final file = File(filePath);

      // Criar diretório pai se não existir
      final parentDir = Directory(path.dirname(filePath));
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }

      await file.writeAsString(content);
    } catch (e) {
      throw Exception('Erro ao salvar arquivo: $e');
    }
  }

  /// Carregar arquivo de um componente específico
  Future<String?> loadFile(String profileName, String workspaceName,
      String componentName, String fileName) async {
    await _ensureInitialized();

    if (kIsWeb) return null;

    try {
      final componentDir = await getComponentDirectory(
          profileName, workspaceName, componentName);
      if (componentDir == null) return null;

      final filePath = path.join(componentDir.path, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Listar arquivos de um componente específico
  Future<List<String>> listFiles(
      String profileName, String workspaceName, String componentName) async {
    await _ensureInitialized();

    if (kIsWeb) return [];

    try {
      final componentDir = await getComponentDirectory(
          profileName, workspaceName, componentName);
      if (componentDir == null) return [];

      final entities = await componentDir.list(followLinks: false).toList();
      final files = entities.whereType<File>().toList();
      return files.map((file) => path.basename(file.path)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Deletar arquivo de um componente específico
  Future<void> deleteFile(String profileName, String workspaceName,
      String componentName, String fileName) async {
    await _ensureInitialized();

    if (kIsWeb) {
      throw Exception('Deleção de arquivo não suportada no web');
    }

    try {
      final componentDir = await getComponentDirectory(
          profileName, workspaceName, componentName);
      if (componentDir == null) {
        throw Exception('Componente não encontrado');
      }

      final filePath = path.join(componentDir.path, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Erro ao deletar arquivo: $e');
    }
  }

  /// Obter estatísticas de armazenamento
  Future<Map<String, dynamic>> getStorageStats() async {
    await _ensureInitialized();

    if (kIsWeb) {
      return {
        'totalProfiles': 0,
        'totalWorkspaces': 0,
        'usedSpace': '0 KB',
        'platform': 'web',
      };
    }

    try {
      final profiles = await getExistingProfiles();
      int totalWorkspaces = 0;

      for (final profile in profiles) {
        final workspaces = await getWorkspaces(profile.name);
        totalWorkspaces += workspaces.length;
      }

      // Calcular espaço usado (aproximado)
      int totalSize = 0;
      final baseDir = Directory(_basePath!);
      if (await baseDir.exists()) {
        await for (final entity
            in baseDir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            try {
              final stat = await entity.stat();
              totalSize += stat.size;
            } catch (e) {
              // Ignorar erros de arquivo
            }
          }
        }
      }

      return {
        'totalProfiles': profiles.length,
        'totalWorkspaces': totalWorkspaces,
        'usedSpace': _formatBytes(totalSize),
        'platform': Platform.operatingSystem,
        'basePath': _basePath,
      };
    } catch (e) {
      return {};
    }
  }

  /// Sanitizar nome de arquivo/pasta
  String _sanitizeFileName(String name) {
    // Remover caracteres especiais e espaços
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(' ', '_')
        .toLowerCase();
  }

  /// Formatar bytes para exibição
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Garantir que o serviço está inicializado
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Obter caminho base dos dados
  Future<String?> getBasePath() async {
    await _ensureInitialized();
    return _basePath;
  }

  /// Fechar serviço e limpar recursos
  Future<void> dispose() async {
    _isInitialized = false;
    _basePath = null;
  }
}