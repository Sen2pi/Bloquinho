import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bloquinho/core/models/workspace.dart';

class WorkspaceNotifier extends StateNotifier<Workspace?> {
  WorkspaceNotifier() : super(DefaultWorkspaces.workspaces.first);

  void selectWorkspace(String workspaceId) {
    final newWorkspace = DefaultWorkspaces.workspaces
        .firstWhere((element) => element.id == workspaceId);

    // Só atualizar se realmente mudou
    if (state?.id != newWorkspace.id) {
      final oldWorkspace = state;
      state = newWorkspace;

      // Forçar recarregamento de todos os providers
      _notifyWorkspaceChange(newWorkspace, oldWorkspace);
    }
  }

  void _notifyWorkspaceChange(Workspace newWorkspace, Workspace? oldWorkspace) {
    // Este método será usado para notificar outros providers sobre mudança de workspace
    // Aqui podemos adicionar lógica para notificar outros providers
    // Por exemplo, forçar recarregamento de dados específicos do workspace
  }
}

final workspaceProvider =
    StateNotifierProvider<WorkspaceNotifier, Workspace?>((ref) {
  return WorkspaceNotifier();
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
