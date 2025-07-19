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
    emails.removeWhere((email) => email.id == emailId);
    await _saveEmails(emails);
  }

  /// Salvar lista de emails
  Future<void> _saveEmails(List<EmailTrackingModel> emails) async {
    final file = await _storageFileHandle;
    final jsonList = emails.map((email) => email.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
  }
}