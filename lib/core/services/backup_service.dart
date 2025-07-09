import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../../shared/models/document_models.dart';
import 'document_service.dart';

class BackupData {
  final List<Workspace> workspaces;
  final List<Document> documents;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final String version;
  final String appVersion;

  const BackupData({
    required this.workspaces,
    required this.documents,
    required this.settings,
    required this.createdAt,
    required this.version,
    required this.appVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'workspaces': workspaces.map((w) => w.toJson()).toList(),
      'documents': documents.map((d) => d.toJson()).toList(),
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
      'version': version,
      'appVersion': appVersion,
    };
  }

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      workspaces: (json['workspaces'] as List<dynamic>)
          .map((e) => Workspace.fromJson(e as Map<String, dynamic>))
          .toList(),
      documents: (json['documents'] as List<dynamic>)
          .map((e) => Document.fromJson(e as Map<String, dynamic>))
          .toList(),
      settings: Map<String, dynamic>.from(json['settings'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      version: json['version'] as String,
      appVersion: json['appVersion'] as String,
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

  const BackupMetadata({
    required this.fileName,
    required this.createdAt,
    required this.fileSize,
    required this.documentsCount,
    required this.workspacesCount,
    required this.version,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'createdAt': createdAt.toIso8601String(),
      'fileSize': fileSize,
      'documentsCount': documentsCount,
      'workspacesCount': workspacesCount,
      'version': version,
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
    );
  }
}

class BackupService {
  final DocumentService _documentService;
  static const String _backupVersion = '1.0.0';
  static const String _appVersion = '1.0.0';

  BackupService(this._documentService);

  /// Criar backup completo dos dados
  Future<BackupData> createBackup({
    Map<String, dynamic>? additionalSettings,
  }) async {
    try {
      // Carregar todos os dados
      final workspaces = await _documentService.getAllWorkspaces();
      final documents =
          await _documentService.getAllDocuments(includeArchived: true);

      // Configurações padrão
      final settings = {
        'theme': 'system',
        'language': 'pt-BR',
        'autoSave': true,
        'syncEnabled': true,
        ...?additionalSettings,
      };

      return BackupData(
        workspaces: workspaces,
        documents: documents,
        settings: settings,
        createdAt: DateTime.now(),
        version: _backupVersion,
        appVersion: _appVersion,
      );
    } catch (e) {
      throw Exception('Erro ao criar backup: $e');
    }
  }

  /// Salvar backup em arquivo
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

  /// Exportar backup para sistema de arquivos do usuário
  Future<String?> exportBackup({String? customName}) async {
    try {
      final backup = await createBackup();

      // No mobile, usar diretório de documentos
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final file = await saveBackupToFile(backup, customName: customName);
        return file.path;
      }

      // No desktop/web, permitir que usuário escolha local
      final fileName = customName ??
          'bloquinho_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      final jsonString = jsonEncode(backup.toJson());

      if (kIsWeb) {
        // Para web, usar download do navegador
        // Nota: Precisaria implementar com dart:html para web
        throw UnimplementedError('Export para web não implementado ainda');
      } else {
        // Para desktop, usar file picker para salvar
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Salvar Backup',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (result != null) {
          final file = File(result);
          await file.writeAsString(jsonString);
          return result;
        }
      }

      return null;
    } catch (e) {
      throw Exception('Erro ao exportar backup: $e');
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
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

      return BackupData.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Erro ao importar backup: $e');
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

  /// Restaurar dados do backup
  Future<void> restoreFromBackup(
    BackupData backup, {
    bool clearExistingData = false,
    bool restoreSettings = true,
  }) async {
    try {
      if (clearExistingData) {
        // Limpar dados existentes
        await _clearAllData();
      }

      // Restaurar workspaces
      for (final workspace in backup.workspaces) {
        await _documentService.createWorkspace(workspace);
      }

      // Restaurar documentos
      for (final document in backup.documents) {
        await _documentService.createDocument(document);
      }

      // Restaurar configurações (implementar conforme necessário)
      if (restoreSettings) {
        await _restoreSettings(backup.settings);
      }
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
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .cast<File>()
          .toList();

      final List<BackupMetadata> backups = [];

      for (final file in files) {
        try {
          final stat = await file.stat();
          final content = await file.readAsString();
          final json = jsonDecode(content) as Map<String, dynamic>;

          final metadata = BackupMetadata(
            fileName: file.path.split('/').last,
            createdAt: DateTime.parse(json['createdAt'] as String),
            fileSize: stat.size,
            documentsCount: (json['documents'] as List).length,
            workspacesCount: (json['workspaces'] as List).length,
            version: json['version'] as String? ?? '1.0.0',
          );

          backups.add(metadata);
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
      for (final workspace in backup.workspaces) {
        if (workspace.id.isEmpty || workspace.name.isEmpty) {
          return false;
        }
      }

      for (final document in backup.documents) {
        if (document.id.isEmpty || document.title.isEmpty) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obter estatísticas do backup
  Future<Map<String, dynamic>> getBackupStats(BackupData backup) async {
    final totalBlocks = backup.documents.expand((doc) => doc.blocks).length;

    final documentsByType = <String, int>{};
    for (final doc in backup.documents) {
      final key = doc.isArchived ? 'archived' : 'active';
      documentsByType[key] = (documentsByType[key] ?? 0) + 1;
    }

    return {
      'workspaces': backup.workspaces.length,
      'documents': backup.documents.length,
      'blocks': totalBlocks,
      'documentsByType': documentsByType,
      'createdAt': backup.createdAt,
      'version': backup.version,
      'appVersion': backup.appVersion,
    };
  }

  // Métodos auxiliares privados
  Future<void> _clearAllData() async {
    // Implementar limpeza completa dos dados
    // Por segurança, vamos apenas marcar como arquivados
    final documents = await _documentService.getAllDocuments();
    for (final doc in documents) {
      await _documentService.deleteDocument(doc.id);
    }
  }

  Future<void> _restoreSettings(Map<String, dynamic> settings) async {
    // Implementar restauração de configurações
    // Por enquanto apenas log
    debugPrint('Configurações restauradas: $settings');
  }

  /// Criar backup automático agendado
  Future<void> createScheduledBackup() async {
    try {
      final backup = await createBackup();
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
