import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bloquinho/core/models/workspace.dart';

class WorkspaceNotifier extends StateNotifier<Workspace?> {
  WorkspaceNotifier() : super(DefaultWorkspaces.workspaces.first);

  void selectWorkspace(String workspaceId) {
    state = DefaultWorkspaces.workspaces
        .firstWhere((element) => element.id == workspaceId);
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

final currentWorkspaceSectionsProvider = Provider<List<WorkspaceSection>>((ref) {
  final workspaceId = ref.watch(currentWorkspaceIdProvider);
  if (workspaceId == null) return [];
  return WorkspaceSections.getSectionsForWorkspace(workspaceId);
});

final workspacesProvider = Provider<List<Workspace>>((ref) {
  return DefaultWorkspaces.workspaces;
});
