import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/workspace.dart';

/// Estado dos workspaces
class WorkspaceState {
  final List<Workspace> workspaces;
  final Workspace? currentWorkspace;
  final bool isLoading;
  final String? error;

  const WorkspaceState({
    this.workspaces = const [],
    this.currentWorkspace,
    this.isLoading = false,
    this.error,
  });

  WorkspaceState copyWith({
    List<Workspace>? workspaces,
    Workspace? currentWorkspace,
    bool? isLoading,
    String? error,
  }) {
    return WorkspaceState(
      workspaces: workspaces ?? this.workspaces,
      currentWorkspace: currentWorkspace ?? this.currentWorkspace,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier para gerenciar workspaces
class WorkspaceNotifier extends StateNotifier<WorkspaceState> {
  static const _uuid = Uuid();

  WorkspaceNotifier() : super(const WorkspaceState()) {
    _initializeWorkspaces();
  }

  /// Inicializar workspaces padrão
  void _initializeWorkspaces() {
    state = WorkspaceState(
      workspaces: DefaultWorkspaces.workspaces,
      currentWorkspace: DefaultWorkspaces.workspaces.first,
    );
  }

  /// Selecionar workspace atual
  void selectWorkspace(String workspaceId) {
    final workspace = state.workspaces.firstWhere(
      (w) => w.id == workspaceId,
      orElse: () => state.workspaces.first,
    );

    state = state.copyWith(currentWorkspace: workspace);
  }

  /// Criar novo workspace
  void createWorkspace({
    required String name,
    required String description,
    required dynamic icon,
    dynamic color,
  }) {
    final newWorkspace = Workspace(
      id: _uuid.v4(),
      name: name,
      description: description,
      icon: icon,
      color: color,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(
      workspaces: [...state.workspaces, newWorkspace],
    );
  }

  /// Atualizar workspace
  void updateWorkspace(String id, Workspace updatedWorkspace) {
    final updatedWorkspaces = state.workspaces.map((workspace) {
      if (workspace.id == id) {
        return updatedWorkspace.copyWith(updatedAt: DateTime.now());
      }
      return workspace;
    }).toList();

    state = state.copyWith(
      workspaces: updatedWorkspaces,
      currentWorkspace: state.currentWorkspace?.id == id
          ? updatedWorkspace
          : state.currentWorkspace,
    );
  }

  /// Deletar workspace
  void deleteWorkspace(String id) {
    if (state.workspaces.length <= 1) {
      state =
          state.copyWith(error: 'Não é possível excluir o último workspace');
      return;
    }

    final updatedWorkspaces =
        state.workspaces.where((w) => w.id != id).toList();

    Workspace? newCurrentWorkspace = state.currentWorkspace;
    if (state.currentWorkspace?.id == id) {
      newCurrentWorkspace = updatedWorkspaces.first;
    }

    state = state.copyWith(
      workspaces: updatedWorkspaces,
      currentWorkspace: newCurrentWorkspace,
    );
  }

  /// Duplicar workspace
  void duplicateWorkspace(String id) {
    final originalWorkspace = state.workspaces.firstWhere((w) => w.id == id);

    final duplicatedWorkspace = Workspace(
      id: _uuid.v4(),
      name: '${originalWorkspace.name} (Cópia)',
      description: originalWorkspace.description,
      icon: originalWorkspace.icon,
      color: originalWorkspace.color,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      settings: Map.from(originalWorkspace.settings),
    );

    state = state.copyWith(
      workspaces: [...state.workspaces, duplicatedWorkspace],
    );
  }

  /// Limpar erro
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider principal dos workspaces
final workspaceProvider =
    StateNotifierProvider<WorkspaceNotifier, WorkspaceState>(
  (ref) => WorkspaceNotifier(),
);

/// Provider derivado: lista de workspaces
final workspacesProvider = Provider<List<Workspace>>((ref) {
  return ref.watch(workspaceProvider).workspaces;
});

/// Provider derivado: workspace atual
final currentWorkspaceProvider = Provider<Workspace?>((ref) {
  return ref.watch(workspaceProvider).currentWorkspace;
});

/// Provider derivado: seções do workspace atual
final currentWorkspaceSectionsProvider =
    Provider<List<WorkspaceSection>>((ref) {
  final currentWorkspace = ref.watch(currentWorkspaceProvider);
  if (currentWorkspace == null) return [];

  return WorkspaceSections.getSectionsForWorkspace(currentWorkspace.id);
});

/// Provider derivado: se está carregando
final isWorkspaceLoadingProvider = Provider<bool>((ref) {
  return ref.watch(workspaceProvider).isLoading;
});

/// Provider derivado: erro atual
final workspaceErrorProvider = Provider<String?>((ref) {
  return ref.watch(workspaceProvider).error;
});
