/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:bloquinho/core/services/local_storage_service.dart';
import 'package:bloquinho/core/models/user_profile.dart';

/// Serviço para gerenciar armazenamento isolado por workspace
class WorkspaceStorageService {
  static final WorkspaceStorageService _instance =
      WorkspaceStorageService._internal();
  factory WorkspaceStorageService() => _instance;
  WorkspaceStorageService._internal();

  final LocalStorageService _localStorage = LocalStorageService();
  String? _currentProfileName;
  String? _currentWorkspaceId;
  bool _isInitialized = false;

  /// Inicializar o serviço
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _localStorage.initialize();
    _isInitialized = true;
  }

  /// Definir contexto atual (perfil + workspace)
  Future<void> setContext(String profileName, String workspaceId) async {
    await _ensureInitialized();

    final previousContext = '$_currentProfileName/$_currentWorkspaceId';
    final newContext = '$profileName/$workspaceId';

    if (previousContext != newContext) {
      _currentProfileName = profileName;
      _currentWorkspaceId = workspaceId;

      // Só criar estrutura se não existir
      final profilePath = await _localStorage.getProfilePath(profileName);
      if (profilePath == null) {
        await _localStorage.createProfileStructure(profileName);
      }
      // Garantir que o workspace existe
      await _localStorage.ensureWorkspaceExists(profileName, workspaceId);
    }
  }

  /// Definir contexto a partir de UserProfile e workspace ID
  Future<void> setContextFromProfile(
      UserProfile profile, String workspaceId) async {
    await setContext(profile.name, workspaceId);
  }

  /// Obter contexto atual
  Map<String, String?> get currentContext => {
        'profileName': _currentProfileName,
        'workspaceId': _currentWorkspaceId,
      };

  /// Verificar se o contexto está definido
  bool get hasContext =>
      _currentProfileName != null && _currentWorkspaceId != null;

  /// Obter caminho do workspace atual
  Future<String?> getCurrentWorkspacePath() async {
    await _ensureInitialized();

    if (_currentProfileName == null || _currentWorkspaceId == null) {
      return null;
    }

    return await _localStorage.getWorkspacePath(
        _currentProfileName!, _currentWorkspaceId!);
  }

  /// Salvar dados específicos do workspace
  Future<void> saveWorkspaceData(
      String dataType, Map<String, dynamic> data) async {
    await _ensureInitialized();

    if (_currentProfileName == null || _currentWorkspaceId == null) {
      throw Exception('Contexto não definido');
    }

    final workspacePath = await getCurrentWorkspacePath();
    if (workspacePath == null) {
      throw Exception('Workspace não encontrado');
    }

    final dataFile = File(path.join(workspacePath, '$dataType.json'));
    await dataFile.writeAsString(json.encode({
      'workspaceId': _currentWorkspaceId,
      'profileName': _currentProfileName,
      'dataType': dataType,
      'lastModified': DateTime.now().toIso8601String(),
      'data': data,
    }));
  }

  /// Carregar dados específicos do workspace
  Future<Map<String, dynamic>?> loadWorkspaceData(String dataType) async {
    await _ensureInitialized();

    if (_currentProfileName == null || _currentWorkspaceId == null) {
      return null;
    }

    final workspacePath = await getCurrentWorkspacePath();
    if (workspacePath == null) {
      return null;
    }

    final dataFile = File(path.join(workspacePath, '$dataType.json'));
    if (!await dataFile.exists()) {
      // Garantir que o arquivo de dados padrão seja criado
      try {
        await _localStorage.ensureDataFileExists(
            _currentProfileName!, _currentWorkspaceId!, dataType);
      } catch (e) {
        return null;
      }
    }

    try {
      final content = await dataFile.readAsString();
      final jsonData = json.decode(content) as Map<String, dynamic>;

      // Verificar se os dados pertencem ao workspace atual
      if (jsonData['workspaceId'] != _currentWorkspaceId) {
        return null;
      }

      return jsonData['data'] as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Listar todos os workspaces de um perfil
  Future<List<String>> listWorkspaces(String profileName) async {
    await _ensureInitialized();

    final workspacesDir =
        await _localStorage.getWorkspacesDirectory(profileName);
    if (workspacesDir == null) return [];

    try {
      final entities = await workspacesDir.list().toList();
      final workspaces = <String>[];

      for (final entity in entities) {
        if (entity is Directory) {
          workspaces.add(path.basename(entity.path));
        }
      }

      return workspaces;
    } catch (e) {
      return [];
    }
  }

  /// Verificar se dados existem para um workspace
  Future<bool> hasWorkspaceData(String dataType) async {
    await _ensureInitialized();

    if (_currentProfileName == null || _currentWorkspaceId == null) {
      return false;
    }

    final workspacePath = await getCurrentWorkspacePath();
    if (workspacePath == null) return false;

    final dataFile = File(path.join(workspacePath, '$dataType.json'));
    return await dataFile.exists();
  }

  /// Deletar dados de um workspace
  Future<void> deleteWorkspaceData(String dataType) async {
    await _ensureInitialized();

    if (_currentProfileName == null || _currentWorkspaceId == null) {
      throw Exception('Contexto não definido');
    }

    final workspacePath = await getCurrentWorkspacePath();
    if (workspacePath == null) {
      throw Exception('Workspace não encontrado');
    }

    final dataFile = File(path.join(workspacePath, '$dataType.json'));
    if (await dataFile.exists()) {
      await dataFile.delete();
    }
  }

  /// Obter estatísticas do workspace
  Future<Map<String, dynamic>> getWorkspaceStats() async {
    await _ensureInitialized();

    if (_currentProfileName == null || _currentWorkspaceId == null) {
      return {};
    }

    final workspacePath = await getCurrentWorkspacePath();
    if (workspacePath == null) return {};

    try {
      final workspaceDir = Directory(workspacePath);
      if (!await workspaceDir.exists()) return {};

      final stats = <String, dynamic>{
        'workspaceId': _currentWorkspaceId,
        'profileName': _currentProfileName,
        'dataTypes': <String>[],
        'totalFiles': 0,
        'lastModified': null,
      };

      final entities = await workspaceDir.list().toList();
      int totalFiles = 0;
      DateTime? lastModified;

      for (final entity in entities) {
        if (entity is File) {
          totalFiles++;
          final stat = await entity.stat();
          if (lastModified == null || stat.modified.isAfter(lastModified)) {
            lastModified = stat.modified;
          }

          // Identificar tipo de dados pelo nome do arquivo
          final fileName = path.basename(entity.path);
          if (fileName.endsWith('.json')) {
            final dataType = fileName.replaceAll('.json', '');
            if (!stats['dataTypes'].contains(dataType)) {
              (stats['dataTypes'] as List).add(dataType);
            }
          }
        }
      }

      stats['totalFiles'] = totalFiles;
      stats['lastModified'] = lastModified?.toIso8601String();

      return stats;
    } catch (e) {
      return {};
    }
  }

  /// Garantir que o serviço está inicializado
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Limpar contexto atual
  void clearContext() {
    _currentProfileName = null;
    _currentWorkspaceId = null;
  }
}
