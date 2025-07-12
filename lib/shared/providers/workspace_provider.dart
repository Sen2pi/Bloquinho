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
        debugPrint('✅ Contexto atualizado: ${profile.name}/${workspace.id}');
      } else {
        debugPrint('⚠️ Nenhum perfil encontrado para definir contexto');
      }
    } catch (e) {
      debugPrint('❌ Erro ao atualizar contexto do workspace: $e');
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
  return WorkspaceNotifier(storageService);
});

final currentWorkspaceProvider = Provider<Workspace?>((ref) {
  return ref.watch(workspaceProvider);
});

final currentWorkspaceIdProvider = Provider<String?>((ref) {
  final workspace = ref.watch(currentWorkspaceProvider);
  return workspace?.id;
});

final currentWorkspaceSectionsProvider =
    Provider<List<WorkspaceSection>>((ref) {
  final workspaceId = ref.watch(currentWorkspaceIdProvider);
  if (workspaceId == null) return [];
  return WorkspaceSections.getSectionsForWorkspace(workspaceId);
});

final workspacesProvider = Provider<List<Workspace>>((ref) {
  return DefaultWorkspaces.workspaces;
});

/// Provider para forçar recarregamento de dados quando workspace muda
final workspaceChangeProvider = Provider<String>((ref) {
  final workspace = ref.watch(workspaceProvider);
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
  final workspace = ref.watch(workspaceProvider);
  return workspace?.id ?? '';
});

/// Provider para forçar recarregamento de providers específicos
final workspaceReloadTriggerProvider = Provider<String>((ref) {
  final workspace = ref.watch(workspaceProvider);
  return '${workspace?.id ?? ""}_${DateTime.now().millisecondsSinceEpoch}';
});

/// Provider para contexto do workspace (perfil + workspace)
final workspaceContextProvider = Provider<Map<String, String?>>((ref) {
  final notifier = ref.read(workspaceProvider.notifier);
  return notifier.currentContext;
});

/// Provider para verificar se tem contexto definido
final hasWorkspaceContextProvider = Provider<bool>((ref) {
  final notifier = ref.read(workspaceProvider.notifier);
  return notifier.hasContext;
});

/// Provider para definir contexto do workspace
final workspaceContextNotifierProvider = Provider<WorkspaceNotifier>((ref) {
  return ref.read(workspaceProvider.notifier);
});
