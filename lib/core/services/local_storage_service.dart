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

      // Em plataformas nativas, usar pasta do projeto
      final currentDir = Directory.current;
      _basePath = path.join(currentDir.path, _profileFolder);

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
      final profilesDir = Directory(_basePath!);

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
      final profilesDir = Directory(_basePath!);
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
      final profilePath = path.join(_basePath!, safeName);

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

      // Criar workspaces padrão conforme especificado pelo usuário (se não existirem)
      await _createDefaultWorkspaceStructure(profilePath, 'work');
      await _createDefaultWorkspaceStructure(profilePath, 'personal');
      await _createDefaultWorkspaceStructure(profilePath, 'school');

      debugPrint('✅ Workspaces criados: work, personal, school');

      debugPrint('✅ Estrutura criada para perfil: $profilePath');
      return profilePath;
    } catch (e) {
      debugPrint('❌ Erro ao criar estrutura do perfil: $e');
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

      // Criar as 5 pastas principais conforme especificado pelo usuário
      final folders = [
        'bloquinho',
        'documents',
        'agenda',
        'passwords',
        'databases'
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

      debugPrint('✅ Estrutura do workspace criada: $workspacePath');
    } catch (e) {
      debugPrint('❌ Erro ao criar estrutura do workspace: $e');
      throw Exception('Erro ao criar estrutura do workspace: $e');
    }
  }

  /// Criar arquivos padrão para cada pasta
  Future<void> _createDefaultFiles(String folderPath, String folderType) async {
    try {
      switch (folderType) {
        case 'bloquinho':
          // Criar arquivo principal 'bloquinho' conforme especificado
          final bloquinhoFile = File(path.join(folderPath, 'bloquinho.md'));
          if (!await bloquinhoFile.exists()) {
            await bloquinhoFile.writeAsString('''
# Bem-vindo ao Bloquinho! 🎉

Esta é sua página principal do Bloquinho. Aqui você pode:

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

        case 'databases':
          // Criar arquivo de configuração da base de dados
          final dbConfigFile = File(path.join(folderPath, 'config.json'));
          if (!await dbConfigFile.exists()) {
            await dbConfigFile.writeAsString('''
{
  "workspace": "${folderPath.split(path.separator).reversed.elementAt(2)}",
  "createdAt": "${DateTime.now().toIso8601String()}",
  "tables": [],
  "version": "1.0"
}
''');
          }
          break;

        case 'passwords':
          // Criar arquivo de configuração para senhas
          final passwordsConfigFile =
              File(path.join(folderPath, 'config.json'));
          if (!await passwordsConfigFile.exists()) {
            await passwordsConfigFile.writeAsString('''
{
  "workspace": "${folderPath.split(path.separator).reversed.elementAt(2)}",
  "createdAt": "${DateTime.now().toIso8601String()}",
  "passwords": [],
  "categories": ["pessoal", "trabalho", "estudos", "financeiro"],
  "version": "1.0"
}
''');
          }
          break;

        case 'documents':
          // Criar arquivo de índice de documentos
          final docsIndexFile = File(path.join(folderPath, 'index.json'));
          if (!await docsIndexFile.exists()) {
            await docsIndexFile.writeAsString('''
{
  "workspace": "${folderPath.split(path.separator).reversed.elementAt(2)}",
  "createdAt": "${DateTime.now().toIso8601String()}",
  "documents": [],
  "categories": ["pessoal", "trabalho", "estudos"],
  "version": "1.0"
}
''');
          }
          break;

        case 'agenda':
          // Criar arquivo de configuração da agenda
          final agendaConfigFile = File(path.join(folderPath, 'config.json'));
          if (!await agendaConfigFile.exists()) {
            await agendaConfigFile.writeAsString('''
{
  "workspace": "${folderPath.split(path.separator).reversed.elementAt(2)}",
  "createdAt": "${DateTime.now().toIso8601String()}",
  "events": [],
  "reminders": [],
  "categories": ["pessoal", "trabalho", "saúde"],
  "version": "1.0"
}
''');
          }
          break;
      }

      debugPrint('✅ Arquivos padrão criados para: $folderType');
    } catch (e) {
      debugPrint('❌ Erro ao criar arquivos padrão para $folderType: $e');
    }
  }

  /// Salvar perfil no arquivo settings.json
  Future<void> saveProfile(UserProfile profile) async {
    await _ensureInitialized();

    if (kIsWeb) {
      throw Exception('Salvamento de perfil não suportado no web');
    }

    try {
      // Sempre criar/verificar estrutura para garantir migração
      final profilePath = await createProfileStructure(profile.name);

      // Salvar settings.json
      final settingsFile = File(path.join(profilePath, _settingsFile));
      final profileJson = json.encode(profile.toJson());
      await settingsFile.writeAsString(profileJson);

      debugPrint('✅ Perfil salvo na nova estrutura: ${settingsFile.path}');
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
      final profilePath = path.join(_basePath!, safeName);
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
      final photoPath = path.join(_basePath!, safeName, _profilePhotoFile);
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
      final workspacesPath = path.join(_basePath!, safeName, _workspacesFolder);
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
      final profilePath = path.join(_basePath!, safeName);
      final profileDir = Directory(profilePath);

      if (await profileDir.exists()) {
        await profileDir.delete(recursive: true);
        debugPrint('✅ Perfil deletado: $profilePath');
      } else {
        debugPrint('⚠️ Pasta do perfil não encontrada: $profilePath');
      }
    } catch (e) {
      debugPrint('❌ Erro ao deletar perfil: $e');
      throw Exception('Erro ao deletar perfil: $e');
    }
  }

  /// Deletar todos os dados de perfis (limpar pasta profile completamente)
  Future<void> deleteAllProfiles() async {
    await _ensureInitialized();

    if (kIsWeb) {
      throw Exception('Deleção de dados não suportada no web');
    }

    try {
      final profilesDir = Directory(_basePath!);

      if (await profilesDir.exists()) {
        // Deletar recursivamente toda a pasta profile
        await profilesDir.delete(recursive: true);

        // Recriar pasta base vazia
        await profilesDir.create(recursive: true);

        debugPrint('✅ Todos os perfis deletados: $_basePath');
      }
    } catch (e) {
      debugPrint('❌ Erro ao deletar todos os perfis: $e');
      throw Exception('Erro ao deletar todos os perfis: $e');
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

  /// Obter dados por chave (para compatibilidade com sistema de documentos)
  Future<String?> getData(String key) async {
    await _ensureInitialized();

    if (kIsWeb) {
      // No web, usar localStorage
      return null; // Implementar se necessário
    }

    try {
      // Usar o primeiro perfil disponível para armazenar dados
      final profiles = await getExistingProfiles();
      if (profiles.isEmpty) return null;

      final profilePath = await createProfileStructure(profiles.first.name);
      final dataFile = File(path.join(profilePath, '${key}.json'));

      if (await dataFile.exists()) {
        return await dataFile.readAsString();
      }
      return null;
    } catch (e) {
      debugPrint('❌ Erro ao obter dados: $e');
      return null;
    }
  }

  /// Salvar dados por chave (para compatibilidade com sistema de documentos)
  Future<void> saveData(String key, String data) async {
    await _ensureInitialized();

    if (kIsWeb) {
      // No web, usar localStorage
      return; // Implementar se necessário
    }

    try {
      // Usar o primeiro perfil disponível para armazenar dados
      final profiles = await getExistingProfiles();
      if (profiles.isEmpty) {
        // Criar perfil padrão se não existir
        final defaultProfile = UserProfile(
          id: 'default',
          name: 'Default',
          email: 'default@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await saveProfile(defaultProfile);
      }

      final profilePath = await createProfileStructure(
          profiles.isNotEmpty ? profiles.first.name : 'Default');
      final dataFile = File(path.join(profilePath, '${key}.json'));

      await dataFile.writeAsString(data);
      debugPrint('✅ Dados salvos: ${dataFile.path}');
    } catch (e) {
      debugPrint('❌ Erro ao salvar dados: $e');
      throw Exception('Erro ao salvar dados: $e');
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
