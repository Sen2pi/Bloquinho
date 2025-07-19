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
import 'package:path/path.dart' as path;
import '../models/email_tracking_model.dart';
import '../../../core/services/workspace_storage_service.dart';

class EmailTrackingStorageService {
  static final EmailTrackingStorageService _instance = EmailTrackingStorageService._internal();
  factory EmailTrackingStorageService() => _instance;
  EmailTrackingStorageService._internal();

  final WorkspaceStorageService _workspaceStorage = WorkspaceStorageService();
  final String _storageDir = 'email_tracking';
  final String _storageFile = 'emails.json';

  /// Configurar contexto (perfil + workspace)
  Future<void> setContext(String profileName, String workspaceId) async {
    await _workspaceStorage.setContext(profileName, workspaceId);
  }

  /// Obter arquivo de armazenamento
  Future<File> get _storageFileHandle async {
    await _workspaceStorage.initialize();
    final workspacePath = await _workspaceStorage.getCurrentWorkspacePath();
    if (workspacePath == null) {
      throw Exception('Workspace path not found');
    }
    
    final storageDir = Directory(path.join(workspacePath, _storageDir));
    if (!await storageDir.exists()) {
      await storageDir.create(recursive: true);
    }
    
    return File(path.join(storageDir.path, _storageFile));
  }

  /// Carregar todos os emails
  Future<List<EmailTrackingModel>> getEmails() async {
    try {
      final file = await _storageFileHandle;
      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      if (content.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(content);
      return jsonList.map((json) => EmailTrackingModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Carregar emails por ID da candidatura
  Future<List<EmailTrackingModel>> getEmailsByApplicationId(String applicationId) async {
    final allEmails = await getEmails();
    return allEmails.where((email) => email.applicationId == applicationId).toList();
  }

  /// Salvar email
  Future<void> saveEmail(EmailTrackingModel email) async {
    final emails = await getEmails();
    
    final existingIndex = emails.indexWhere((e) => e.id == email.id);
    if (existingIndex != -1) {
      emails[existingIndex] = email;
    } else {
      emails.add(email);
    }

    await _saveEmails(emails);
  }

  /// Remover email
  Future<void> deleteEmail(String emailId) async {
    final emails = await getEmails();
    
    // Encontrar o email a ser removido para obter o caminho do arquivo .eml
    final emailToDelete = emails.firstWhere(
      (email) => email.id == emailId,
      orElse: () => throw Exception('Email não encontrado'),
    );
    
    // Remover o arquivo .eml se existir
    if (emailToDelete.emlFilePath != null) {
      try {
        final emlFile = File(emailToDelete.emlFilePath!);
        if (await emlFile.exists()) {
          await emlFile.delete();
          print('Arquivo .eml removido: ${emailToDelete.emlFilePath}');
        }
      } catch (e) {
        print('Erro ao remover arquivo .eml: $e');
        // Continuar com a remoção do registro mesmo se não conseguir apagar o arquivo
      }
    }
    
    // Remover o email da lista
    emails.removeWhere((email) => email.id == emailId);
    await _saveEmails(emails);
  }

  /// Salvar lista de emails
  Future<void> _saveEmails(List<EmailTrackingModel> emails) async {
    final file = await _storageFileHandle;
    final jsonList = emails.map((email) => email.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
  }

  /// Limpar arquivos .eml órfãos (que não têm correspondência na base de dados)
  Future<void> cleanOrphanedEmlFiles() async {
    try {
      await _workspaceStorage.initialize();
      final workspacePath = await _workspaceStorage.getCurrentWorkspacePath();
      if (workspacePath == null) return;
      
      final emlDir = Directory(path.join(workspacePath, _storageDir));
      if (!await emlDir.exists()) return;
      
      // Obter todos os emails salvos
      final emails = await getEmails();
      final validEmlPaths = emails
          .where((email) => email.emlFilePath != null)
          .map((email) => email.emlFilePath!)
          .toSet();
      
      // Listar todos os arquivos .eml no diretório
      final emlFiles = await emlDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.eml'))
          .cast<File>()
          .toList();
      
      // Remover arquivos órfãos
      int removedCount = 0;
      for (final emlFile in emlFiles) {
        if (!validEmlPaths.contains(emlFile.path)) {
          try {
            await emlFile.delete();
            removedCount++;
            print('Arquivo .eml órfão removido: ${emlFile.path}');
          } catch (e) {
            print('Erro ao remover arquivo órfão ${emlFile.path}: $e');
          }
        }
      }
      
      if (removedCount > 0) {
        print('$removedCount arquivos .eml órfãos foram removidos');
      }
    } catch (e) {
      print('Erro na limpeza de arquivos órfãos: $e');
    }
  }

  /// Remover todos os emails de uma candidatura (usado quando a candidatura é deletada)
  Future<void> deleteEmailsByApplicationId(String applicationId) async {
    final emails = await getEmails();
    final emailsToDelete = emails.where((email) => email.applicationId == applicationId).toList();
    
    // Remover arquivos .eml
    for (final email in emailsToDelete) {
      if (email.emlFilePath != null) {
        try {
          final emlFile = File(email.emlFilePath!);
          if (await emlFile.exists()) {
            await emlFile.delete();
            print('Arquivo .eml removido: ${email.emlFilePath}');
          }
        } catch (e) {
          print('Erro ao remover arquivo .eml: $e');
        }
      }
    }
    
    // Remover registros da base de dados
    final remainingEmails = emails.where((email) => email.applicationId != applicationId).toList();
    await _saveEmails(remainingEmails);
  }
}