/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bloquinho/core/models/workspace.dart';
import 'package:bloquinho/core/models/user_profile.dart';
import 'package:bloquinho/core/services/workspace_storage_service.dart';
import 'package:bloquinho/shared/providers/user_profile_provider.dart';

class WorkspaceNotifier extends StateNotifier<Workspace?> {
  final WorkspaceStorageService _storageService;

  WorkspaceNotifier(this._storageService)
      : super(DefaultWorkspaces.workspaces.first);

  /// Obter workspace padrão (Pessoal)
  Workspace get defaultWorkspace => DefaultWorkspaces.workspaces.first;

  /// Obter workspace atual ou padrão se não houver
  Workspace get currentWorkspaceOrDefault {
    final current = state ?? defaultWorkspace;
    return current;
  }

  /// Obter ID do workspace atual ou padrão
  String get currentWorkspaceIdOrDefault {
    final id = currentWorkspaceOrDefault.id;
    return id;
  }

  /// Inicializar workspace padrão se não houver workspace selecionado
  Future<void> initializeDefaultWorkspace() async {
    if (state == null) {
      state = defaultWorkspace;

      // Atualizar contexto no WorkspaceStorageService
      await _updateWorkspaceContext(defaultWorkspace);
    }
  }

  Future<void> selectWorkspace(String workspaceId) async {
    final newWorkspace = DefaultWorkspaces.workspaces
        .firstWhere((element) => element.id == workspaceId);

    // Só atualizar se realmente mudou
    if (state?.id != newWorkspace.id) {
      final oldWorkspace = state;
      state = newWorkspace;

      // Atualizar contexto no WorkspaceStorageService
      await _updateWorkspaceContext(newWorkspace);

      // Forçar recarregamento de todos os providers
      _notifyWorkspaceChange(newWorkspace, oldWorkspace);
    }
  }

  Future<void> _updateWorkspaceContext(Workspace workspace) async {
    try {
      // Obter perfil atual (assumindo que existe)
      final profile = await _getCurrentProfile();
      if (profile != null) {
        await _storageService.setContextFromProfile(profile, workspace.id);
      }
    } catch (e) {
      // Erro ao atualizar contexto do workspace
    }
  }

  Future<UserProfile?> _getCurrentProfile() async {
    try {
      // Tentar obter perfil do provider
      // Como não temos acesso direto ao ref aqui, vamos usar uma abordagem diferente
      // O contexto será definido pelos providers específicos quando necessário
      return null;
    } catch (e) {
      return null;
    }
  }

  void _notifyWorkspaceChange(Workspace newWorkspace, Workspace? oldWorkspace) {
    // Este método será usado para notificar outros providers sobre mudança de workspace
    // Aqui podemos adicionar lógica para notificar outros providers
    // Por exemplo, forçar recarregamento de dados específicos do workspace
  }

  /// Definir contexto manualmente (usado por outros providers)
  Future<void> setContext(UserProfile profile, String workspaceId) async {
    await _storageService.setContextFromProfile(profile, workspaceId);
  }

  /// Obter contexto atual
  Map<String, String?> get currentContext => _storageService.currentContext;

  /// Verificar se tem contexto definido
  bool get hasContext => _storageService.hasContext;
}

final workspaceProvider =
    StateNotifierProvider<WorkspaceNotifier, Workspace?>((ref) {
  final storageService = WorkspaceStorageService();
  final notifier = WorkspaceNotifier(storageService);

  // Inicializar workspace padrão automaticamente
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await notifier.initializeDefaultWorkspace();
  });

  return notifier;
});

final currentWorkspaceProvider = Provider<Workspace?>((ref) {
  final workspace = ref.watch(workspaceProvider);
  return workspace;
});

final currentWorkspaceIdProvider = Provider<String?>((ref) {
  final workspace = ref.watch(currentWorkspaceProvider);
  final id = workspace?.id;
  return id;
});

// NOVO: Provider para workspace atual ou padrão (Pessoal)
final currentWorkspaceOrDefaultProvider = Provider<Workspace>((ref) {
  final notifier = ref.read(workspaceProvider.notifier);
  final workspace = notifier.currentWorkspaceOrDefault;
  return workspace;
});

// NOVO: Provider para ID do workspace atual ou padrão
final currentWorkspaceIdOrDefaultProvider = Provider<String>((ref) {
  final notifier = ref.read(workspaceProvider.notifier);
  final id = notifier.currentWorkspaceIdOrDefault;
  return id;
});

// NOVO: Provider para workspace padrão (Pessoal)
final defaultWorkspaceProvider = Provider<Workspace>((ref) {
  final notifier = ref.read(workspaceProvider.notifier);
  return notifier.defaultWorkspace;
});

final currentWorkspaceSectionsProvider =
    Provider<List<WorkspaceSection>>((ref) {
  final workspaceId = ref.watch(currentWorkspaceIdOrDefaultProvider);
  return WorkspaceSections.getSectionsForWorkspace(workspaceId);
});

final workspacesProvider = Provider<List<Workspace>>((ref) {
  return DefaultWorkspaces.workspaces;
});

/// Provider para forçar recarregamento de dados quando workspace muda
final workspaceChangeProvider = Provider<String>((ref) {
  final workspace = ref.watch(currentWorkspaceProvider);
  return workspace?.id ?? '';
});

/// Provider para notificar mudanças de workspace
final workspaceChangeNotifierProvider =
    StateNotifierProvider<WorkspaceChangeNotifier, String>((ref) {
  return WorkspaceChangeNotifier();
});

class WorkspaceChangeNotifier extends StateNotifier<String> {
  WorkspaceChangeNotifier() : super('');

  void notifyWorkspaceChange(String workspaceId) {
    state = workspaceId;
  }
}

/// Provider para verificar se o workspace mudou
final workspaceChangeDetectorProvider = Provider<String>((ref) {
  final workspace = ref.watch(currentWorkspaceProvider);
  return workspace?.id ?? '';
});

/// Provider para forçar recarregamento de providers específicos
final workspaceReloadTriggerProvider = Provider<String>((ref) {
  final workspace = ref.watch(currentWorkspaceProvider);
  return '${workspace?.id ?? ""}_${DateTime.now().millisecondsSinceEpoch}';
});

/// Provider para contexto do workspace (perfil + workspace)
final workspaceContextProvider = Provider<Map<String, String?>>((ref) {
  final notifier = ref.read(workspaceProvider.notifier);
  return notifier.currentContext;
});

/// Verificar se tem contexto definido
final hasWorkspaceContextProvider = Provider<bool>((ref) {
  final notifier = ref.read(workspaceProvider.notifier);
  return notifier.hasContext;
});

/// Provider para definir contexto do workspace
final workspaceContextNotifierProvider = Provider<WorkspaceNotifier>((ref) {
  return ref.read(workspaceProvider.notifier);
});

// NOVO: Providers específicos para componentes que precisam do workspace default
// (exceto Bloquinho que já está funcional)

/// Provider para documentos com workspace default
final documentosWorkspaceProvider = Provider<String>((ref) {
  final workspaceId = ref.watch(currentWorkspaceIdOrDefaultProvider);
  return workspaceId;
});

/// Provider para agenda com workspace default
final agendaWorkspaceProvider = Provider<String>((ref) {
  final workspaceId = ref.watch(currentWorkspaceIdOrDefaultProvider);
  return workspaceId;
});

/// Provider para senhas com workspace default
final passwordsWorkspaceProvider = Provider<String>((ref) {
  final workspaceId = ref.watch(currentWorkspaceIdOrDefaultProvider);
  return workspaceId;
});

/// Provider para database com workspace default
final databaseWorkspaceProvider = Provider<String>((ref) {
  final workspaceId = ref.watch(currentWorkspaceIdOrDefaultProvider);
  return workspaceId;
});

/// Provider para backup com workspace default
final backupWorkspaceProvider = Provider<String>((ref) {
  final workspaceId = ref.watch(currentWorkspaceIdOrDefaultProvider);
  return workspaceId;
});

/// Provider para profile com workspace default
final profileWorkspaceProvider = Provider<String>((ref) {
  final workspaceId = ref.watch(currentWorkspaceIdOrDefaultProvider);
  return workspaceId;
});
