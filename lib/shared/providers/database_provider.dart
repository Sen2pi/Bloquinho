import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:bloquinho/core/models/database_models.dart';
import 'package:bloquinho/core/services/database_service.dart';
import 'workspace_provider.dart';
import 'user_profile_provider.dart';
import '../../core/models/user_profile.dart';
import '../../core/models/workspace.dart';

/// Provider para integrar DatabaseService com Workspace
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final databaseService = DatabaseService();

  // Observar mudanças no workspace atual
  ref.listen<String?>(
    currentWorkspaceIdProvider,
    (previous, current) async {
      if (current != null && current != previous) {
        await databaseService.setCurrentWorkspace(current);
      }
    },
  );

  return databaseService;
});

/// Provider derivado: ID do workspace atual
final currentWorkspaceIdProvider = Provider<String?>((ref) {
  return ref.watch(currentWorkspaceProvider)?.id;
});

/// Provider para tabelas do workspace atual
final databaseTablesProvider = FutureProvider<List<DatabaseTable>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.tables;
});

/// Provider para uma tabela específica
final databaseTableProvider =
    FutureProvider.family<DatabaseTable?, String>((ref, tableId) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getTable(tableId);
});

/// Provider para busca de tabelas
final databaseSearchProvider =
    FutureProvider.family<List<DatabaseTable>, String>((ref, query) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.searchTables(query);
});

/// Provider para contar tabelas do workspace atual
final databaseTableCountProvider = Provider<int>((ref) {
  final tables = ref.watch(databaseTablesProvider);

  return tables.when(
    data: (tablesList) => tablesList.length,
    loading: () => 0,
    error: (error, stack) => 0,
  );
});

/// Notifier para operações de database
class DatabaseNotifier extends StateNotifier<AsyncValue<List<DatabaseTable>>> {
  final Ref ref;
  late final DatabaseService _databaseService;
  String? _lastWorkspaceId;
  String? _lastProfileName;
  bool _isInitialized = false;

  DatabaseNotifier(this.ref) : super(const AsyncValue.loading()) {
    _databaseService = ref.read(databaseServiceProvider);

    // Observar mudanças de workspace
    ref.listen<String?>(currentWorkspaceIdProvider, (previous, current) {
      if (current != previous && current != null) {
        _lastWorkspaceId = current;
        _databaseService.setCurrentWorkspace(current);

        // Só recarregar se já foi inicializado
        if (_isInitialized) {
          _loadTables();
        }
      }
    });

    _init();
  }

  /// Inicializar o notifier
  Future<void> _init() async {
    try {
      await _loadTables();
      _isInitialized = true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Carregar tabelas do storage
  Future<void> _loadTables() async {
    try {
      state = const AsyncValue.loading();
      final tables = await _databaseService.tables;
      state = AsyncValue.data(tables);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Definir contexto do workspace
  Future<void> setContext(String profileName, String workspaceId) async {
    await _databaseService.setContext(profileName, workspaceId);
    _lastProfileName = profileName;
    _lastWorkspaceId = workspaceId;
    await _loadTables();
  }

  /// Criar nova tabela
  Future<void> createTable({
    required String name,
    String? description,
    dynamic icon,
    dynamic color,
  }) async {
    try {
      await _databaseService.createTable(
        name: name,
        description: description,
        icon: icon,
        color: color,
      );
      await _loadTables();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Atualizar tabela
  Future<void> updateTable(DatabaseTable table) async {
    try {
      await _databaseService.updateTable(table);
      await _loadTables();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Deletar tabela
  Future<void> deleteTable(String tableId) async {
    try {
      await _databaseService.deleteTable(tableId);
      await _loadTables();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Forçar reload das tabelas (útil após mudança de workspace)
  Future<void> refreshTables() async {
    await _loadTables();
  }
}

/// Provider principal do database com notifier
final databaseNotifierProvider =
    StateNotifierProvider<DatabaseNotifier, AsyncValue<List<DatabaseTable>>>(
        (ref) {
  final notifier = DatabaseNotifier(ref);

  // Inicializa contexto na primeira criação do provider
  final profile = ref.read(currentProfileProvider);
  final workspace = ref.read(currentWorkspaceProvider);
  final defaultWorkspaceId = ref.read(databaseWorkspaceProvider);
  if (profile != null) {
    final workspaceId = workspace?.id ?? defaultWorkspaceId;
    notifier.setContext(profile.name, workspaceId);
  }

  // Observa mudanças de profile/workspace e atualiza contexto
  ref.listen<UserProfile?>(currentProfileProvider, (prevProfile, currProfile) {
    final workspace = ref.read(currentWorkspaceProvider);
    final defaultWorkspaceId = ref.read(databaseWorkspaceProvider);

    debugPrint(
        '🔍 [DatabaseProvider] Profile mudou: ${prevProfile?.name} → ${currProfile?.name}');
    debugPrint(
        '🔍 [DatabaseProvider] Workspace atual: ${workspace?.name} (${workspace?.id})');
    debugPrint('🔍 [DatabaseProvider] Workspace default: $defaultWorkspaceId');

    if (currProfile != null) {
      final workspaceId = workspace?.id ?? defaultWorkspaceId;
      debugPrint(
          '[DatabaseProvider] Mudou workspace/profile: ${currProfile.name}/$workspaceId');
      notifier.setContext(currProfile.name, workspaceId);
    } else {
      debugPrint('[DatabaseProvider] Profile é null, não definindo contexto');
    }
  });

  // Observa mudanças de workspace
  ref.listen<Workspace?>(currentWorkspaceProvider,
      (prevWorkspace, currWorkspace) {
    final profile = ref.read(currentProfileProvider);
    final defaultWorkspaceId = ref.read(databaseWorkspaceProvider);

    debugPrint(
        '🔍 [DatabaseProvider] Workspace mudou: ${prevWorkspace?.name} → ${currWorkspace?.name}');
    debugPrint('🔍 [DatabaseProvider] Profile atual: ${profile?.name}');
    debugPrint('🔍 [DatabaseProvider] Workspace default: $defaultWorkspaceId');

    if (profile != null) {
      final workspaceId = currWorkspace?.id ?? defaultWorkspaceId;
      debugPrint(
          '[DatabaseProvider] Mudou workspace/profile: ${profile.name}/$workspaceId');
      notifier.setContext(profile.name, workspaceId);
    } else {
      debugPrint('[DatabaseProvider] Profile é null, não definindo contexto');
    }
  });

  return notifier;
});

/// Provider para obter apenas a lista de tabelas
final tablesProvider = Provider<List<DatabaseTable>>((ref) {
  return ref
          .watch(databaseNotifierProvider)
          .whenOrNull(data: (tables) => tables) ??
      [];
});

/// Provider para contar o número de tabelas
final tablesCountProvider = Provider<int>((ref) {
  return ref.watch(tablesProvider).length;
});

/// Provider para verificar se existem tabelas
final hasTablesProvider = Provider<bool>((ref) {
  return ref.watch(tablesCountProvider) > 0;
});

// Provider para inicializar contexto do workspace
final databaseContextProvider = Provider<void>((ref) {
  final notifier = ref.read(databaseNotifierProvider.notifier);
  final profile = ref.watch(currentProfileProvider);
  final workspace = ref.watch(currentWorkspaceProvider);

  if (profile != null && workspace != null) {
    // Definir contexto de forma assíncrona
    Future.microtask(() async {
      await notifier.setContext(profile.name, workspace.id);
    });
  }
});
