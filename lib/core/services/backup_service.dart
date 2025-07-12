import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../../features/agenda/models/agenda_item.dart';
import '../../features/passwords/models/password_entry.dart';
import '../../features/documentos/models/documento.dart';
import 'bloquinho_storage_service.dart';
import 'local_storage_service.dart';

class BackupData {
  final List<AgendaItem> agendaItems;
  final List<PasswordEntry> passwords;
  final List<Documento> documentos;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final String version;
  final String appVersion;
  final String? workspaceStructure; // Nova: estrutura de pastas do workspace

  const BackupData({
    required this.agendaItems,
    required this.passwords,
    required this.documentos,
    required this.settings,
    required this.createdAt,
    required this.version,
    required this.appVersion,
    this.workspaceStructure,
  });

  Map<String, dynamic> toJson() {
    return {
      'agendaItems': agendaItems.map((a) => a.toJson()).toList(),
      'passwords': passwords.map((p) => p.toJson()).toList(),
      'documentos': documentos.map((d) => d.toJson()).toList(),
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
      'version': version,
      'appVersion': appVersion,
      'workspaceStructure': workspaceStructure,
    };
  }

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      agendaItems: (json['agendaItems'] as List<dynamic>?)
              ?.map((e) => AgendaItem.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      passwords: (json['passwords'] as List<dynamic>?)
              ?.map((e) => PasswordEntry.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      documentos: (json['documentos'] as List<dynamic>?)
              ?.map((e) => Documento.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      version: json['version'] as String,
      appVersion: json['appVersion'] as String,
      workspaceStructure: json['workspaceStructure'] as String?,
    );
  }
}

class BackupMetadata {
  final String fileName;
  final DateTime createdAt;
  final int fileSize;
  final int documentsCount;
  final int workspacesCount;
  final String version;
  final bool hasWorkspaceStructure; // Nova: indica se tem estrutura de pastas

  const BackupMetadata({
    required this.fileName,
    required this.createdAt,
    required this.fileSize,
    required this.documentsCount,
    required this.workspacesCount,
    required this.version,
    this.hasWorkspaceStructure = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'createdAt': createdAt.toIso8601String(),
      'fileSize': fileSize,
      'documentsCount': documentsCount,
      'workspacesCount': workspacesCount,
      'version': version,
      'hasWorkspaceStructure': hasWorkspaceStructure,
    };
  }

  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    return BackupMetadata(
      fileName: json['fileName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      fileSize: json['fileSize'] as int,
      documentsCount: json['documentsCount'] as int,
      workspacesCount: json['workspacesCount'] as int,
      version: json['version'] as String,
      hasWorkspaceStructure: json['hasWorkspaceStructure'] as bool? ?? false,
    );
  }
}

class BackupService {
  static const String _backupVersion =
      '2.0.0'; // Nova versão para estrutura de pastas
  static const String _appVersion = '1.0.0';

  final BloquinhoStorageService _bloquinhoStorage = BloquinhoStorageService();
  final LocalStorageService _localStorage = LocalStorageService();

  BackupService();

  /// Criar backup completo dos dados com estrutura de pastas
  Future<BackupData> createBackup({
    required List<AgendaItem> agendaItems,
    required List<PasswordEntry> passwords,
    required List<Documento> documentos,
    required String profileName,
    required String workspaceName,
    Map<String, dynamic>? additionalSettings,
  }) async {
    try {
      // Configurações padrão
      final settings = {
        'theme': 'system',
        'language': 'pt-BR',
        'autoSave': true,
        'syncEnabled': true,
        ...?additionalSettings,
      };

      // Obter estrutura de pastas do workspace
      String? workspaceStructure;
      try {
        final workspacesDir =
            await _localStorage.getWorkspacesDirectory(profileName);
        if (workspacesDir != null) {
          final workspaceDir =
              Directory(path.join(workspacesDir.path, workspaceName));
          if (await workspaceDir.exists()) {
            workspaceStructure =
                await _serializeDirectoryStructure(workspaceDir);
          }
        }
      } catch (e) {
        debugPrint('⚠️ Erro ao serializar estrutura de pastas: $e');
      }

      return BackupData(
        agendaItems: agendaItems,
        passwords: passwords,
        documentos: documentos,
        settings: settings,
        createdAt: DateTime.now(),
        version: _backupVersion,
        appVersion: _appVersion,
        workspaceStructure: workspaceStructure,
      );
    } catch (e) {
      throw Exception('Erro ao criar backup: $e');
    }
  }

  /// Salvar backup em arquivo (agora inclui estrutura de pastas)
  Future<File> saveBackupToFile(BackupData backup, {String? customName}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final fileName = customName ??
          'bloquinho_backup_${backup.createdAt.millisecondsSinceEpoch}.json';
      final file = File('${backupDir.path}/$fileName');

      final jsonString = jsonEncode(backup.toJson());
      await file.writeAsString(jsonString);

      return file;
    } catch (e) {
      throw Exception('Erro ao salvar backup: $e');
    }
  }

  /// Criar backup completo de workspace (pasta ZIP)
  Future<File> createWorkspaceBackup(String profileName, String workspaceName,
      {String? customName}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final fileName = customName ??
          'workspace_backup_${workspaceName}_${DateTime.now().millisecondsSinceEpoch}.zip';
      final backupFile = File('${backupDir.path}/$fileName');

      // Obter diretório do workspace
      final workspacesDir =
          await _localStorage.getWorkspacesDirectory(profileName);
      if (workspacesDir == null) {
        throw Exception('Workspace não encontrado');
      }

      final workspaceDir =
          Directory(path.join(workspacesDir.path, workspaceName));
      if (!await workspaceDir.exists()) {
        throw Exception('Workspace não encontrado');
      }

      // TODO: Implementar compressão ZIP
      // Por enquanto, copiar pasta diretamente
      await _copyDirectoryRecursively(workspaceDir, backupFile.parent);

      debugPrint('✅ Backup de workspace criado: ${backupFile.path}');
      return backupFile;
    } catch (e) {
      throw Exception('Erro ao criar backup de workspace: $e');
    }
  }

  /// Importar backup de arquivo
  Future<BackupData> importBackupFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Arquivo de backup não encontrado');
      }

      final jsonString = await file.readAsString();
      final jsonMap = Map<String, dynamic>.from(jsonDecode(jsonString));

      return BackupData.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Erro ao importar backup: $e');
    }
  }

  /// Importar workspace de pasta (estrutura do Notion)
  Future<Map<String, dynamic>> importWorkspaceFromFolder(
      String folderPath, String profileName, String workspaceName) async {
    try {
      final sourceDir = Directory(folderPath);
      if (!await sourceDir.exists()) {
        throw Exception('Pasta de origem não encontrada');
      }

      // Criar workspace
      final workspaceDirPath =
          await _localStorage.createWorkspace(profileName, workspaceName);

      if (workspaceDirPath == null) {
        throw Exception('Erro ao criar workspace');
      }

      // Importar estrutura do Bloquinho
      final bloquinhoDir = Directory(path.join(workspaceDirPath, 'bloquinho'));
      if (!await bloquinhoDir.exists()) {
        await bloquinhoDir.create(recursive: true);
      }

      // Copiar estrutura de pastas
      await _copyDirectoryRecursively(sourceDir, bloquinhoDir);

      // Contar páginas importadas
      final importedPages = await _countMarkdownFiles(bloquinhoDir);

      debugPrint('✅ Workspace importado: $importedPages páginas encontradas');

      return {
        'success': true,
        'importedPages': importedPages,
        'workspacePath': workspaceDirPath,
      };
    } catch (e) {
      debugPrint('❌ Erro ao importar workspace: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Importar backup usando file picker
  Future<BackupData?> importBackupWithPicker() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Selecionar Backup',
      );

      if (result != null && result.files.single.path != null) {
        return await importBackupFromFile(result.files.single.path!);
      }

      return null;
    } catch (e) {
      throw Exception('Erro ao importar backup: $e');
    }
  }

  /// Importar pasta do Notion usando file picker
  Future<Map<String, dynamic>?> importNotionFolderWithPicker(
      String profileName, String workspaceName) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['md', 'markdown'],
        dialogTitle: 'Selecionar Pasta do Notion',
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final folderPath = path.dirname(result.files.single.path!);
        return await importWorkspaceFromFolder(
            folderPath, profileName, workspaceName);
      }

      return null;
    } catch (e) {
      throw Exception('Erro ao importar pasta do Notion: $e');
    }
  }

  /// Restaurar dados do backup
  Future<void> restoreFromBackup(
    BackupData backup, {
    required String profileName,
    required String workspaceName,
    bool clearExistingData = false,
    bool restoreSettings = true,
  }) async {
    try {
      if (clearExistingData) {
        // Limpar dados existentes
        await _clearAllData(profileName, workspaceName);
      }

      // Restaurar estrutura de pastas se disponível
      if (backup.workspaceStructure != null) {
        await _restoreWorkspaceStructure(
            backup.workspaceStructure!, profileName, workspaceName);
      }

      // Restaurar configurações
      if (restoreSettings) {
        await _restoreSettings(backup.settings);
      }

      debugPrint('✅ Backup restaurado com sucesso');
    } catch (e) {
      throw Exception('Erro ao restaurar backup: $e');
    }
  }

  /// Listar backups locais
  Future<List<BackupMetadata>> getLocalBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');

      if (!await backupDir.exists()) {
        return [];
      }

      final files = await backupDir
          .list()
          .where((entity) =>
              entity is File &&
              (entity.path.endsWith('.json') || entity.path.endsWith('.zip')))
          .cast<File>()
          .toList();

      final List<BackupMetadata> backups = [];

      for (final file in files) {
        try {
          final stat = await file.stat();

          if (file.path.endsWith('.json')) {
            // Backup JSON tradicional
            final content = await file.readAsString();
            final json = jsonDecode(content) as Map<String, dynamic>;

            final metadata = BackupMetadata(
              fileName: path.basename(file.path),
              createdAt: DateTime.parse(json['createdAt'] as String),
              fileSize: stat.size,
              documentsCount: (json['documentos'] as List).length,
              workspacesCount: (json['agendaItems'] as List).length,
              version: json['version'] as String? ?? '1.0.0',
              hasWorkspaceStructure: json['workspaceStructure'] != null,
            );

            backups.add(metadata);
          } else if (file.path.endsWith('.zip')) {
            // Backup de workspace (ZIP)
            final metadata = BackupMetadata(
              fileName: path.basename(file.path),
              createdAt: stat.modified,
              fileSize: stat.size,
              documentsCount: 0, // TODO: Contar arquivos markdown no ZIP
              workspacesCount: 1,
              version: _backupVersion,
              hasWorkspaceStructure: true,
            );

            backups.add(metadata);
          }
        } catch (e) {
          // Ignorar arquivos corrompidos
          debugPrint('Erro ao ler backup ${file.path}: $e');
        }
      }

      // Ordenar por data de criação (mais recente primeiro)
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return backups;
    } catch (e) {
      throw Exception('Erro ao listar backups: $e');
    }
  }

  /// Deletar backup local
  Future<void> deleteLocalBackup(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/backups/$fileName');

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Erro ao deletar backup: $e');
    }
  }

  /// Validar backup
  Future<bool> validateBackup(BackupData backup) async {
    try {
      // Verificar versão
      if (backup.version != _backupVersion) {
        debugPrint(
            'Aviso: Versão do backup (${backup.version}) diferente da atual ($_backupVersion)');
      }

      // Validar estrutura dos dados
      if (backup.agendaItems.any((item) => item.id.isEmpty)) return false;
      if (backup.passwords.any((item) => item.id.isEmpty)) return false;
      if (backup.documentos.any((item) => item.id.isEmpty)) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obter estatísticas do backup
  Future<Map<String, dynamic>> getBackupStats(BackupData backup) async {
    return {
      'agendaItems': backup.agendaItems.length,
      'passwords': backup.passwords.length,
      'documentos': backup.documentos.length,
      'hasWorkspaceStructure': backup.workspaceStructure != null,
    };
  }

  // Métodos auxiliares privados

  /// Serializar estrutura de diretório
  Future<String> _serializeDirectoryStructure(Directory dir) async {
    try {
      final structure = <String, dynamic>{};
      await _buildDirectoryTree(dir, structure);
      return json.encode(structure);
    } catch (e) {
      debugPrint('❌ Erro ao serializar estrutura: $e');
      return '{}';
    }
  }

  /// Construir árvore de diretório
  Future<void> _buildDirectoryTree(
      Directory dir, Map<String, dynamic> structure) async {
    try {
      final entities = await dir.list().toList();

      for (final entity in entities) {
        final name = path.basename(entity.path);

        if (entity is File) {
          structure[name] = {
            'type': 'file',
            'size': await entity.length(),
            'modified': (await entity.stat()).modified.toIso8601String(),
          };
        } else if (entity is Directory) {
          structure[name] = {
            'type': 'directory',
            'contents': <String, dynamic>{},
          };
          await _buildDirectoryTree(entity, structure[name]['contents']);
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao construir árvore: $e');
    }
  }

  /// Restaurar estrutura de workspace
  Future<void> _restoreWorkspaceStructure(
      String structureJson, String profileName, String workspaceName) async {
    try {
      final structure = Map<String, dynamic>.from(json.decode(structureJson));
      final workspacesDir =
          await _localStorage.getWorkspacesDirectory(profileName);

      if (workspacesDir != null) {
        final workspaceDir =
            Directory(path.join(workspacesDir.path, workspaceName));
        await _restoreDirectoryTree(structure, workspaceDir);
      }
    } catch (e) {
      debugPrint('❌ Erro ao restaurar estrutura: $e');
    }
  }

  /// Restaurar árvore de diretório
  Future<void> _restoreDirectoryTree(
      Map<String, dynamic> structure, Directory targetDir) async {
    try {
      for (final entry in structure.entries) {
        final name = entry.key;
        final data = entry.value as Map<String, dynamic>;

        if (data['type'] == 'file') {
          // TODO: Restaurar conteúdo do arquivo
          final file = File(path.join(targetDir.path, name));
          await file.create();
        } else if (data['type'] == 'directory') {
          final subDir = Directory(path.join(targetDir.path, name));
          await subDir.create(recursive: true);

          final contents = data['contents'] as Map<String, dynamic>;
          await _restoreDirectoryTree(contents, subDir);
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao restaurar árvore: $e');
    }
  }

  /// Copiar diretório recursivamente
  Future<void> _copyDirectoryRecursively(
      Directory source, Directory target) async {
    try {
      if (!await target.exists()) {
        await target.create(recursive: true);
      }

      final entities = await source.list().toList();

      for (final entity in entities) {
        final name = path.basename(entity.path);
        final targetPath = path.join(target.path, name);

        if (entity is File) {
          final targetFile = File(targetPath);
          await entity.copy(targetFile.path);
        } else if (entity is Directory) {
          final targetSubDir = Directory(targetPath);
          await _copyDirectoryRecursively(entity, targetSubDir);
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao copiar diretório: $e');
    }
  }

  /// Contar arquivos markdown
  Future<int> _countMarkdownFiles(Directory dir) async {
    try {
      int count = 0;
      final entities = await dir.list(recursive: true).toList();

      for (final entity in entities) {
        if (entity is File &&
            (entity.path.endsWith('.md') ||
                entity.path.endsWith('.markdown'))) {
          count++;
        }
      }

      return count;
    } catch (e) {
      debugPrint('❌ Erro ao contar arquivos markdown: $e');
      return 0;
    }
  }

  Future<void> _clearAllData(String profileName, String workspaceName) async {
    try {
      final workspacesDir =
          await _localStorage.getWorkspacesDirectory(profileName);
      if (workspacesDir != null) {
        final workspaceDir =
            Directory(path.join(workspacesDir.path, workspaceName));
        if (await workspaceDir.exists()) {
          await workspaceDir.delete(recursive: true);
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao limpar dados: $e');
    }
  }

  Future<void> _restoreSettings(Map<String, dynamic> settings) async {
    // Implementar restauração de configurações
    debugPrint('Configurações restauradas: $settings');
  }

  /// Criar backup automático agendado
  Future<void> createScheduledBackup() async {
    try {
      final backup = await createBackup(
        agendaItems: [],
        passwords: [],
        documentos: [],
        profileName: 'default', // TODO: Obter perfil atual
        workspaceName: 'default', // TODO: Obter workspace atual
      );
      await saveBackupToFile(backup,
          customName:
              'auto_backup_${DateTime.now().millisecondsSinceEpoch}.json');

      // Limpar backups antigos (manter apenas os 5 mais recentes)
      await _cleanupOldBackups();
    } catch (e) {
      debugPrint('Erro ao criar backup automático: $e');
    }
  }

  Future<void> _cleanupOldBackups() async {
    try {
      final backups = await getLocalBackups();
      if (backups.length > 5) {
        final toDelete = backups.skip(5);
        for (final backup in toDelete) {
          await deleteLocalBackup(backup.fileName);
        }
      }
    } catch (e) {
      debugPrint('Erro ao limpar backups antigos: $e');
    }
  }
}
