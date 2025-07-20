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
import '../models/universidade_model.dart';
import '../models/curso_model.dart';
import '../models/unidade_curricular_model.dart';
import '../models/avaliacao_model.dart';
import '../models/universidade_page_model.dart';
import '../../../core/services/workspace_storage_service.dart';

class UniversidadeService {
  late String _profileName;
  late String _workspaceId;
  bool _initialized = false;

  void setContext(String profileName, String workspaceId) {
    _profileName = profileName;
    _workspaceId = workspaceId;
    _initialized = true;
  }

  Future<void> initialize() async {
    if (!_initialized) {
      throw Exception('Serviço não inicializado. Chame setContext primeiro.');
    }
  }

  Future<String> get _basePath async {
    final storageService = WorkspaceStorageService();
    await storageService.initialize();
    await storageService.setContext(_profileName, _workspaceId);
    final path = await storageService.getCurrentWorkspacePath();
    if (path == null) {
      throw Exception('Workspace path não encontrado para $_profileName/$_workspaceId');
    }
    return path;
  }

  Future<Directory> get _universidadeDir async {
    final basePath = await _basePath;
    return Directory('$basePath${Platform.pathSeparator}universidade');
  }

  Future<File> get _universidadesFile async {
    final dir = await _universidadeDir;
    return File('${dir.path}${Platform.pathSeparator}universidades.json');
  }

  Future<File> get _cursosFile async {
    final dir = await _universidadeDir;
    return File('${dir.path}${Platform.pathSeparator}cursos.json');
  }

  Future<File> get _unidadesCurricularesFile async {
    final dir = await _universidadeDir;
    return File('${dir.path}${Platform.pathSeparator}unidades_curriculares.json');
  }

  Future<File> get _avaliacoesFile async {
    final dir = await _universidadeDir;
    return File('${dir.path}${Platform.pathSeparator}avaliacoes.json');
  }

  Future<File> get _pagesFile async {
    final dir = await _universidadeDir;
    return File('${dir.path}${Platform.pathSeparator}pages.json');
  }

  Future<void> _ensureDirectoryExists() async {
    final dir = await _universidadeDir;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  Future<List<T>> _loadJsonFile<T>(
    File file,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    await _ensureDirectoryExists();
    
    if (!await file.exists()) {
      return [];
    }

    try {
      final content = await file.readAsString();
      final List<dynamic> jsonList = json.decode(content);
      return jsonList.map((item) => fromJson(item)).toList();
    } catch (e) {
      print('Erro ao carregar ${file.path}: $e');
      return [];
    }
  }

  Future<void> _saveJsonFile<T>(
    File file,
    List<T> items,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    await _ensureDirectoryExists();
    
    try {
      final jsonList = items.map(toJson).toList();
      final content = json.encode(jsonList);
      await file.writeAsString(content);
    } catch (e) {
      print('Erro ao salvar ${file.path}: $e');
      rethrow;
    }
  }

  Future<List<UniversidadeModel>> getUniversidades() async {
    final file = await _universidadesFile;
    return _loadJsonFile(file, (json) => UniversidadeModel.fromJson(json));
  }

  Future<void> saveUniversidade(UniversidadeModel universidade) async {
    final universidades = await getUniversidades();
    final index = universidades.indexWhere((u) => u.id == universidade.id);
    
    if (index >= 0) {
      universidades[index] = universidade;
    } else {
      universidades.add(universidade);
    }
    
    final file = await _universidadesFile;
    await _saveJsonFile(file, universidades, (u) => u.toJson());
  }

  Future<void> deleteUniversidade(String id) async {
    final universidades = await getUniversidades();
    universidades.removeWhere((u) => u.id == id);
    final universidadesFile = await _universidadesFile;
    await _saveJsonFile(universidadesFile, universidades, (u) => u.toJson());
    
    final cursos = await getCursos();
    cursos.removeWhere((c) => c.universidadeId == id);
    final cursosFile = await _cursosFile;
    await _saveJsonFile(cursosFile, cursos, (c) => c.toJson());
  }

  Future<UniversidadeModel?> getUniversidade(String id) async {
    final universidades = await getUniversidades();
    try {
      return universidades.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<CursoModel>> getCursos() async {
    final file = await _cursosFile;
    return _loadJsonFile(file, (json) => CursoModel.fromJson(json));
  }

  Future<void> saveCurso(CursoModel curso) async {
    final cursos = await getCursos();
    final index = cursos.indexWhere((c) => c.id == curso.id);
    
    if (index >= 0) {
      cursos[index] = curso;
    } else {
      cursos.add(curso);
    }
    
    final cursosFile = await _cursosFile;
    await _saveJsonFile(cursosFile, cursos, (c) => c.toJson());
    
    final universidade = await getUniversidade(curso.universidadeId);
    if (universidade != null) {
      final cursosIds = universidade.cursoIds.toList();
      if (!cursosIds.contains(curso.id)) {
        cursosIds.add(curso.id);
        await saveUniversidade(universidade.copyWith(cursoIds: cursosIds));
      }
    }
  }

  Future<void> deleteCurso(String id) async {
    final cursos = await getCursos();
    final curso = cursos.firstWhere((c) => c.id == id, orElse: () => throw Exception('Curso não encontrado'));
    cursos.removeWhere((c) => c.id == id);
    final cursosFile = await _cursosFile;
    await _saveJsonFile(cursosFile, cursos, (c) => c.toJson());
    
    final universidade = await getUniversidade(curso.universidadeId);
    if (universidade != null) {
      final cursosIds = universidade.cursoIds.toList();
      cursosIds.remove(id);
      await saveUniversidade(universidade.copyWith(cursoIds: cursosIds));
    }
    
    final unidades = await getUnidadesCurriculares();
    unidades.removeWhere((u) => u.cursoId == id);
    final unidadesFile = await _unidadesCurricularesFile;
    await _saveJsonFile(unidadesFile, unidades, (u) => u.toJson());
  }

  Future<CursoModel?> getCurso(String id) async {
    final cursos = await getCursos();
    try {
      return cursos.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<CursoModel>> getCursosByUniversidade(String universidadeId) async {
    final cursos = await getCursos();
    return cursos.where((c) => c.universidadeId == universidadeId).toList();
  }

  Future<List<UnidadeCurricularModel>> getUnidadesCurriculares() async {
    final file = await _unidadesCurricularesFile;
    return _loadJsonFile(file, (json) => UnidadeCurricularModel.fromJson(json));
  }

  Future<void> saveUnidadeCurricular(UnidadeCurricularModel unidade) async {
    final unidades = await getUnidadesCurriculares();
    final index = unidades.indexWhere((u) => u.id == unidade.id);
    
    if (index >= 0) {
      unidades[index] = unidade;
    } else {
      unidades.add(unidade);
    }
    
    final unidadesFile = await _unidadesCurricularesFile;
    await _saveJsonFile(unidadesFile, unidades, (u) => u.toJson());
    
    final curso = await getCurso(unidade.cursoId);
    if (curso != null) {
      final unidadeIds = curso.unidadeCurricularIds.toList();
      if (!unidadeIds.contains(unidade.id)) {
        unidadeIds.add(unidade.id);
        await saveCurso(curso.copyWith(unidadeCurricularIds: unidadeIds));
      }
    }
  }

  Future<void> deleteUnidadeCurricular(String id) async {
    final unidades = await getUnidadesCurriculares();
    final unidade = unidades.firstWhere((u) => u.id == id, orElse: () => throw Exception('Unidade curricular não encontrada'));
    unidades.removeWhere((u) => u.id == id);
    final unidadesFile = await _unidadesCurricularesFile;
    await _saveJsonFile(unidadesFile, unidades, (u) => u.toJson());
    
    final curso = await getCurso(unidade.cursoId);
    if (curso != null) {
      final unidadeIds = curso.unidadeCurricularIds.toList();
      unidadeIds.remove(id);
      await saveCurso(curso.copyWith(unidadeCurricularIds: unidadeIds));
    }
    
    final avaliacoes = await getAvaliacoes();
    avaliacoes.removeWhere((a) => a.unidadeCurricularId == id);
    final avaliacoesFile = await _avaliacoesFile;
    await _saveJsonFile(avaliacoesFile, avaliacoes, (a) => a.toJson());
  }

  Future<UnidadeCurricularModel?> getUnidadeCurricular(String id) async {
    final unidades = await getUnidadesCurriculares();
    try {
      return unidades.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<UnidadeCurricularModel>> getUnidadesByCurso(String cursoId) async {
    final unidades = await getUnidadesCurriculares();
    return unidades.where((u) => u.cursoId == cursoId).toList();
  }

  Future<List<AvaliacaoModel>> getAvaliacoes() async {
    final file = await _avaliacoesFile;
    return _loadJsonFile(file, (json) => AvaliacaoModel.fromJson(json));
  }

  Future<void> saveAvaliacao(AvaliacaoModel avaliacao) async {
    final avaliacoes = await getAvaliacoes();
    final index = avaliacoes.indexWhere((a) => a.id == avaliacao.id);
    
    if (index >= 0) {
      avaliacoes[index] = avaliacao;
    } else {
      avaliacoes.add(avaliacao);
    }
    
    final avaliacoesFile = await _avaliacoesFile;
    await _saveJsonFile(avaliacoesFile, avaliacoes, (a) => a.toJson());
    
    final unidade = await getUnidadeCurricular(avaliacao.unidadeCurricularId);
    if (unidade != null) {
      final avaliacaoIds = unidade.avaliacaoIds.toList();
      if (!avaliacaoIds.contains(avaliacao.id)) {
        avaliacaoIds.add(avaliacao.id);
        await saveUnidadeCurricular(unidade.copyWith(avaliacaoIds: avaliacaoIds));
      }
    }
  }

  Future<void> deleteAvaliacao(String id) async {
    final avaliacoes = await getAvaliacoes();
    final avaliacao = avaliacoes.firstWhere((a) => a.id == id, orElse: () => throw Exception('Avaliação não encontrada'));
    avaliacoes.removeWhere((a) => a.id == id);
    final avaliacoesFile = await _avaliacoesFile;
    await _saveJsonFile(avaliacoesFile, avaliacoes, (a) => a.toJson());
    
    final unidade = await getUnidadeCurricular(avaliacao.unidadeCurricularId);
    if (unidade != null) {
      final avaliacaoIds = unidade.avaliacaoIds.toList();
      avaliacaoIds.remove(id);
      await saveUnidadeCurricular(unidade.copyWith(avaliacaoIds: avaliacaoIds));
    }
  }

  Future<AvaliacaoModel?> getAvaliacao(String id) async {
    final avaliacoes = await getAvaliacoes();
    try {
      return avaliacoes.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<AvaliacaoModel>> getAvaliacoesByUnidade(String unidadeId) async {
    final avaliacoes = await getAvaliacoes();
    return avaliacoes.where((a) => a.unidadeCurricularId == unidadeId).toList();
  }

  Future<List<UniversidadePageModel>> getPages() async {
    final file = await _pagesFile;
    return _loadJsonFile(file, (json) => UniversidadePageModel.fromJson(json));
  }

  Future<void> savePage(UniversidadePageModel page) async {
    final pages = await getPages();
    final index = pages.indexWhere((p) => p.id == page.id);
    
    if (index >= 0) {
      pages[index] = page;
    } else {
      pages.add(page);
    }
    
    final pagesFile = await _pagesFile;
    await _saveJsonFile(pagesFile, pages, (p) => p.toJson());
  }

  Future<void> deletePage(String id) async {
    final pages = await getPages();
    pages.removeWhere((p) => p.id == id);
    final pagesFile = await _pagesFile;
    await _saveJsonFile(pagesFile, pages, (p) => p.toJson());
  }

  Future<UniversidadePageModel?> getPage(String id) async {
    final pages = await getPages();
    try {
      return pages.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<UniversidadePageModel>> getPagesByContexto(TipoContextoPage tipo, String? contextoId) async {
    final pages = await getPages();
    return pages.where((p) => p.tipoContexto == tipo && p.contextoId == contextoId).toList();
  }

  Future<Map<String, dynamic>> getEstatisticas() async {
    final universidades = await getUniversidades();
    final cursos = await getCursos();
    final unidades = await getUnidadesCurriculares();
    final avaliacoes = await getAvaliacoes();
    
    final avaliacoesRealizadas = avaliacoes.where((a) => a.realizada || a.entregue).length;
    final avaliacoesPendentes = avaliacoes.where((a) => !a.realizada && !a.entregue).length;
    final avaliacoesEmAtraso = avaliacoes.where((a) => a.emAtraso).length;
    
    final cursosAtivos = cursos.where((c) => c.ativo).length;
    final unidadesAtivas = unidades.where((u) => u.ativo).length;
    
    return {
      'totalUniversidades': universidades.length,
      'totalCursos': cursos.length,
      'cursosAtivos': cursosAtivos,
      'totalUnidades': unidades.length,
      'unidadesAtivas': unidadesAtivas,
      'totalAvaliacoes': avaliacoes.length,
      'avaliacoesRealizadas': avaliacoesRealizadas,
      'avaliacoesPendentes': avaliacoesPendentes,
      'avaliacoesEmAtraso': avaliacoesEmAtraso,
    };
  }

  Future<List<CursoModel>> searchCursos(String query) async {
    final cursos = await getCursos();
    final lowercaseQuery = query.toLowerCase();
    return cursos.where((c) => 
      c.nome.toLowerCase().contains(lowercaseQuery) ||
      (c.codigo?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  Future<List<UnidadeCurricularModel>> searchUnidades(String query) async {
    final unidades = await getUnidadesCurriculares();
    final lowercaseQuery = query.toLowerCase();
    return unidades.where((u) => 
      u.nome.toLowerCase().contains(lowercaseQuery) ||
      (u.codigo?.toLowerCase().contains(lowercaseQuery) ?? false) ||
      (u.professor?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  Future<List<AvaliacaoModel>> searchAvaliacoes(String query) async {
    final avaliacoes = await getAvaliacoes();
    final lowercaseQuery = query.toLowerCase();
    return avaliacoes.where((a) => 
      a.nome.toLowerCase().contains(lowercaseQuery) ||
      a.tipo.displayName.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
}