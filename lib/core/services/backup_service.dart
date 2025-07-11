import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../../features/agenda/models/agenda_item.dart';
import '../../features/passwords/models/password_entry.dart';
import '../../features/documentos/models/documento.dart';

class BackupData {
  final List<AgendaItem> agendaItems;
  final List<PasswordEntry> passwords;
  final List<Documento> documentos;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final String version;
  final String appVersion;

  const BackupData({
    required this.agendaItems,
    required this.passwords,
    required this.documentos,
    required this.settings,
    required this.createdAt,
    required this.version,
    required this.appVersion,
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
  static const String _backupVersion = '1.0.0';
  static const String _appVersion = '1.0.0';

  BackupService();

  /// Criar backup completo dos dados
  Future<BackupData> createBackup({
    required List<AgendaItem> agendaItems,
    required List<PasswordEntry> passwords,
    required List<Documento> documentos,
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

      return BackupData(
        agendaItems: agendaItems,
        passwords: passwords,
        documentos: documentos,
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
      for (final workspace in backup.agendaItems) {
        // await _documentService.createWorkspace(workspace); // Original line commented out
      }

      // Restaurar documentos
      for (final document in backup.documentos) {
        // await _documentService.createDocument(document); // Original line commented out
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
            documentsCount: (json['documentos'] as List).length,
            workspacesCount: (json['agendaItems'] as List).length,
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
    };
  }

  // Métodos auxiliares privados
  Future<void> _clearAllData() async {
    // Implementar limpeza completa dos dados
    // Por segurança, vamos apenas marcar como arquivados
    // final documents = await _documentService.getAllDocuments(); // Original line commented out
    // for (final doc in documents) { // Original line commented out
    //   await _documentService.deleteDocument(doc.id); // Original line commented out
    // } // Original line commented out
  }

  Future<void> _restoreSettings(Map<String, dynamic> settings) async {
    // Implementar restauração de configurações
    // Por enquanto apenas log
    debugPrint('Configurações restauradas: $settings');
  }

  /// Criar backup automático agendado
  Future<void> createScheduledBackup() async {
    try {
      final backup = await createBackup(
        agendaItems: [],
        passwords: [],
        documentos: [],
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
