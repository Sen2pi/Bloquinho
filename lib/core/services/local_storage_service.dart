import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/user_profile.dart';

/// Serviço para gerenciar a estrutura organizada de dados locais
/// Estrutura: data/profile/[nome_profile]/workspaces/, settings.json, profile_photo.jpg
class LocalStorageService {
  static const String _dataFolder = 'data';
  static const String _profileFolder = 'profile';
  static const String _workspacesFolder = 'workspaces';
  static const String _settingsFile = 'settings.json';
  static const String _profilePhotoFile = 'profile_photo.jpg';

  /// Instância singleton
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

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
      debugPrint('✅ LocalStorageService inicializado: $_basePath');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar LocalStorageService: $e');
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
      debugPrint('❌ Erro ao verificar perfil existente: $e');
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
                json.decode(settingsContent) as Map<String, dynamic>;
            final profile = UserProfile.fromJson(profileData);
            profiles.add(profile);
          } catch (e) {
            debugPrint(
                '⚠️ Erro ao carregar perfil de ${profileFolder.path}: $e');
          }
        }
      }

      return profiles;
    } catch (e) {
      debugPrint('❌ Erro ao obter perfis existentes: $e');
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

      debugPrint('✅ Estrutura criada para perfil: $profilePath');
      return profilePath;
    } catch (e) {
      debugPrint('❌ Erro ao criar estrutura do perfil: $e');
      throw Exception('Erro ao criar estrutura do perfil: $e');
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

      debugPrint('✅ Perfil salvo: ${settingsFile.path}');
    } catch (e) {
      debugPrint('❌ Erro ao salvar perfil: $e');
      throw Exception('Erro ao salvar perfil: $e');
    }
  }

  /// Salvar foto de perfil
  Future<String?> saveProfilePhoto(
      String profileName, dynamic imageData) async {
    await _ensureInitialized();

    if (kIsWeb) {
      debugPrint('⚠️ Salvamento de foto não suportado no web');
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

      debugPrint('✅ Foto de perfil salva: $photoPath');
      return photoPath;
    } catch (e) {
      debugPrint('❌ Erro ao salvar foto de perfil: $e');
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
      debugPrint('❌ Erro ao obter foto de perfil: $e');
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
      debugPrint('❌ Erro ao obter pasta de workspaces: $e');
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

      debugPrint('✅ Workspace criado: $workspacePath');
      return workspaceDir;
    } catch (e) {
      debugPrint('❌ Erro ao criar workspace: $e');
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
      debugPrint('❌ Erro ao listar workspaces: $e');
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
        debugPrint('✅ Perfil deletado: $profilePath');
      }
    } catch (e) {
      debugPrint('❌ Erro ao deletar perfil: $e');
      throw Exception('Erro ao deletar perfil: $e');
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
      debugPrint('❌ Erro ao obter estatísticas: $e');
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
