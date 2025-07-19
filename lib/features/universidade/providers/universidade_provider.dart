/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/universidade_model.dart';
import '../models/curso_model.dart';
import '../models/unidade_curricular_model.dart';
import '../models/avaliacao_model.dart';
import '../models/universidade_page_model.dart';
import '../services/universidade_service.dart';
import '../../../shared/providers/workspace_provider.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../core/models/workspace.dart';

final universidadeServiceProvider = Provider<UniversidadeService>((ref) {
  final service = UniversidadeService();

  ref.listen<Workspace?>(workspaceProvider, (previous, next) async {
    if (next != null) {
      final currentProfile = ref.read(currentProfileProvider);
      if (currentProfile != null) {
        await service.setContext(currentProfile.name, next.id);
      }
    }
  });

  final currentWorkspace = ref.read(workspaceProvider);
  final currentProfile = ref.read(currentProfileProvider);
  if (currentWorkspace != null && currentProfile != null) {
    Future.microtask(() async {
      await service.setContext(currentProfile.name, currentWorkspace.id);
    });
  }

  return service;
});

final universidadesProvider = FutureProvider<List<UniversidadeModel>>((ref) async {
  final service = ref.watch(universidadeServiceProvider);
  await service.initialize();
  return service.getUniversidades();
});

final universidadeProvider = FutureProvider.family<UniversidadeModel?, String>((ref, id) async {
  final service = ref.watch(universidadeServiceProvider);
  await service.initialize();
  return service.getUniversidade(id);
});

final cursosProvider = FutureProvider<List<CursoModel>>((ref) async {
  final service = ref.watch(universidadeServiceProvider);
  await service.initialize();
  return service.getCursos();
});

final cursoProvider = FutureProvider.family<CursoModel?, String>((ref, id) async {
  final service = ref.watch(universidadeServiceProvider);
  await service.initialize();
  return service.getCurso(id);
});

final cursosByUniversidadeProvider = FutureProvider.family<List<CursoModel>, String>((ref, universidadeId) async {
  final service = ref.watch(universidadeServiceProvider);
  await service.initialize();
  return service.getCursosByUniversidade(universidadeId);
});

final unidadesCurricularesProvider = FutureProvider<List<UnidadeCurricularModel>>((ref) async {
  final service = ref.watch(universidadeServiceProvider);
  await service.initialize();
  return service.getUnidadesCurriculares();
});

final unidadeCurricularProvider = FutureProvider.family<UnidadeCurricularModel?, String>((ref, id) async {
  final service = ref.watch(universidadeServiceProvider);
  await service.initialize();
  return service.getUnidadeCurricular(id);
});

final unidadesByCursoProvider = FutureProvider.family<List<UnidadeCurricularModel>, String>((ref, cursoId) async {
  final service = ref.watch(universidadeServiceProvider);
  await service.initialize();
  return service.getUnidadesByCurso(cursoId);
});

final avaliacoesProvider = FutureProvider<List<AvaliacaoModel>>((ref) async {
  final service = ref.watch(universidadeServiceProvider);
  await service.initialize();
  return service.getAvaliacoes();
});

final avaliacaoProvider = FutureProvider.family<AvaliacaoModel?, String>((ref, id) async {
  final service = ref.watch(universidadeServiceProvider);
  await service.initialize();
  return service.getAvaliacao(id);
});

final avaliacoesByUnidadeProvider = FutureProvider.family<List<AvaliacaoModel>, String>((ref, unidadeId) async {
  final service = ref.watch(universidadeServiceProvider);
  await service.initialize();
  return service.getAvaliacoesByUnidade(unidadeId);
});

final universidadePagesProvider = FutureProvider<List<UniversidadePageModel>>((ref) async {
  final service = ref.watch(universidadeServiceProvider);
  await service.initialize();
  return service.getPages();
});

final universidadePageProvider = FutureProvider.family<UniversidadePageModel?, String>((ref, id) async {
  final service = ref.watch(universidadeServiceProvider);
  await service.initialize();
  return service.getPage(id);
});

final pagesByContextoProvider = FutureProvider.family<List<UniversidadePageModel>, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(universidadeServiceProvider);
  await service.initialize();
  final tipo = params['tipo'] as TipoContextoPage;
  final contextoId = params['contextoId'] as String?;
  return service.getPagesByContexto(tipo, contextoId);
});

final estatisticasUniversidadeProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(universidadeServiceProvider);
  await service.initialize();
  return service.getEstatisticas();
});

final searchCursosProvider = FutureProvider.family<List<CursoModel>, String>((ref, query) async {
  final service = ref.watch(universidadeServiceProvider);
  await service.initialize();
  return service.searchCursos(query);
});

final searchUnidadesProvider = FutureProvider.family<List<UnidadeCurricularModel>, String>((ref, query) async {
  final service = ref.watch(universidadeServiceProvider);
  await service.initialize();
  return service.searchUnidades(query);
});

final searchAvaliacoesProvider = FutureProvider.family<List<AvaliacaoModel>, String>((ref, query) async {
  final service = ref.watch(universidadeServiceProvider);
  await service.initialize();
  return service.searchAvaliacoes(query);
});

class UniversidadesNotifier extends StateNotifier<AsyncValue<List<UniversidadeModel>>> {
  UniversidadesNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadUniversidades();
  }

  final Ref ref;

  Future<void> loadUniversidades() async {
    try {
      state = const AsyncValue.loading();
      final service = ref.read(universidadeServiceProvider);
      await service.initialize();
      final universidades = await service.getUniversidades();
      state = AsyncValue.data(universidades);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addUniversidade(UniversidadeModel universidade) async {
    try {
      final service = ref.read(universidadeServiceProvider);
      await service.saveUniversidade(universidade);
      await loadUniversidades();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateUniversidade(UniversidadeModel universidade) async {
    try {
      final service = ref.read(universidadeServiceProvider);
      await service.saveUniversidade(universidade);
      await loadUniversidades();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteUniversidade(String id) async {
    try {
      final service = ref.read(universidadeServiceProvider);
      await service.deleteUniversidade(id);
      await loadUniversidades();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class CursosNotifier extends StateNotifier<AsyncValue<List<CursoModel>>> {
  CursosNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadCursos();
  }

  final Ref ref;

  Future<void> loadCursos() async {
    try {
      state = const AsyncValue.loading();
      final service = ref.read(universidadeServiceProvider);
      await service.initialize();
      final cursos = await service.getCursos();
      state = AsyncValue.data(cursos);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addCurso(CursoModel curso) async {
    try {
      final service = ref.read(universidadeServiceProvider);
      await service.saveCurso(curso);
      await loadCursos();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateCurso(CursoModel curso) async {
    try {
      final service = ref.read(universidadeServiceProvider);
      await service.saveCurso(curso);
      await loadCursos();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteCurso(String id) async {
    try {
      final service = ref.read(universidadeServiceProvider);
      await service.deleteCurso(id);
      await loadCursos();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class UnidadesCurricularesNotifier extends StateNotifier<AsyncValue<List<UnidadeCurricularModel>>> {
  UnidadesCurricularesNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadUnidades();
  }

  final Ref ref;

  Future<void> loadUnidades() async {
    try {
      state = const AsyncValue.loading();
      final service = ref.read(universidadeServiceProvider);
      await service.initialize();
      final unidades = await service.getUnidadesCurriculares();
      state = AsyncValue.data(unidades);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addUnidade(UnidadeCurricularModel unidade) async {
    try {
      final service = ref.read(universidadeServiceProvider);
      await service.saveUnidadeCurricular(unidade);
      await loadUnidades();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateUnidade(UnidadeCurricularModel unidade) async {
    try {
      final service = ref.read(universidadeServiceProvider);
      await service.saveUnidadeCurricular(unidade);
      await loadUnidades();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteUnidade(String id) async {
    try {
      final service = ref.read(universidadeServiceProvider);
      await service.deleteUnidadeCurricular(id);
      await loadUnidades();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class AvaliacoesNotifier extends StateNotifier<AsyncValue<List<AvaliacaoModel>>> {
  AvaliacoesNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadAvaliacoes();
  }

  final Ref ref;

  Future<void> loadAvaliacoes() async {
    try {
      state = const AsyncValue.loading();
      final service = ref.read(universidadeServiceProvider);
      await service.initialize();
      final avaliacoes = await service.getAvaliacoes();
      state = AsyncValue.data(avaliacoes);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addAvaliacao(AvaliacaoModel avaliacao) async {
    try {
      final service = ref.read(universidadeServiceProvider);
      await service.saveAvaliacao(avaliacao);
      await loadAvaliacoes();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateAvaliacao(AvaliacaoModel avaliacao) async {
    try {
      final service = ref.read(universidadeServiceProvider);
      await service.saveAvaliacao(avaliacao);
      await loadAvaliacoes();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteAvaliacao(String id) async {
    try {
      final service = ref.read(universidadeServiceProvider);
      await service.deleteAvaliacao(id);
      await loadAvaliacoes();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final universidadesNotifierProvider = StateNotifierProvider<UniversidadesNotifier, AsyncValue<List<UniversidadeModel>>>((ref) {
  return UniversidadesNotifier(ref);
});

final cursosNotifierProvider = StateNotifierProvider<CursosNotifier, AsyncValue<List<CursoModel>>>((ref) {
  return CursosNotifier(ref);
});

final unidadesCurricularesNotifierProvider = StateNotifierProvider<UnidadesCurricularesNotifier, AsyncValue<List<UnidadeCurricularModel>>>((ref) {
  return UnidadesCurricularesNotifier(ref);
});

final avaliacoesNotifierProvider = StateNotifierProvider<AvaliacoesNotifier, AsyncValue<List<AvaliacaoModel>>>((ref) {
  return AvaliacoesNotifier(ref);
});

final selectedUniversidadeProvider = StateProvider<UniversidadeModel?>((ref) => null);
final selectedCursoProvider = StateProvider<CursoModel?>((ref) => null);
final selectedUnidadeCurricularProvider = StateProvider<UnidadeCurricularModel?>((ref) => null);
final selectedAvaliacaoProvider = StateProvider<AvaliacaoModel?>((ref) => null);

final universidadeDashboardTabProvider = StateProvider<int>((ref) => 0);

final universidadeSearchQueryProvider = StateProvider<String>((ref) => '');
final cursoSearchQueryProvider = StateProvider<String>((ref) => '');
final unidadeSearchQueryProvider = StateProvider<String>((ref) => '');
final avaliacaoSearchQueryProvider = StateProvider<String>((ref) => '');

final isLoadingUniversidadeProvider = StateProvider<bool>((ref) => false);
final isLoadingCursoProvider = StateProvider<bool>((ref) => false);
final isLoadingUnidadeProvider = StateProvider<bool>((ref) => false);
final isLoadingAvaliacaoProvider = StateProvider<bool>((ref) => false);

final universidadeErrorProvider = StateProvider<String?>((ref) => null);
final cursoErrorProvider = StateProvider<String?>((ref) => null);
final unidadeErrorProvider = StateProvider<String?>((ref) => null);
final avaliacaoErrorProvider = StateProvider<String?>((ref) => null);