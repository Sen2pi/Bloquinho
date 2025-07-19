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

  Future<void> setContext(String profileName, String workspaceId) async {
    _profileName = profileName;
    _workspaceId = workspaceId;
    _initialized = true;
  }

  Future<void> initialize() async {
    if (!_initialized) {
      throw Exception('Serviço não inicializado. Chame setContext primeiro.');
    }
  }

  String get _basePath {
    return WorkspaceStorageService.getWorkspacePath(_profileName, _workspaceId);
  }

  Directory get _universidadeDir {
    return Directory('$_basePath${Platform.pathSeparator}universidade');
  }

  File get _universidadesFile {
    return File('${_universidadeDir.path}${Platform.pathSeparator}universidades.json');
  }

  File get _cursosFile {
    return File('${_universidadeDir.path}${Platform.pathSeparator}cursos.json');
  }

  File get _unidadesCurricularesFile {
    return File('${_universidadeDir.path}${Platform.pathSeparator}unidades_curriculares.json');
  }

  File get _avaliacoesFile {
    return File('${_universidadeDir.path}${Platform.pathSeparator}avaliacoes.json');
  }

  File get _pagesFile {
    return File('${_universidadeDir.path}${Platform.pathSeparator}pages.json');
  }

  Future<void> _ensureDirectoryExists() async {
    if (!await _universidadeDir.exists()) {
      await _universidadeDir.create(recursive: true);
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
    return _loadJsonFile(_universidadesFile, (json) => UniversidadeModel.fromJson(json));
  }

  Future<void> saveUniversidade(UniversidadeModel universidade) async {
    final universidades = await getUniversidades();
    final index = universidades.indexWhere((u) => u.id == universidade.id);
    
    if (index >= 0) {
      universidades[index] = universidade;
    } else {
      universidades.add(universidade);
    }
    
    await _saveJsonFile(_universidadesFile, universidades, (u) => u.toJson());
  }

  Future<void> deleteUniversidade(String id) async {
    final universidades = await getUniversidades();
    universidades.removeWhere((u) => u.id == id);
    await _saveJsonFile(_universidadesFile, universidades, (u) => u.toJson());
    
    final cursos = await getCursos();
    cursos.removeWhere((c) => c.universidadeId == id);
    await _saveJsonFile(_cursosFile, cursos, (c) => c.toJson());
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
    return _loadJsonFile(_cursosFile, (json) => CursoModel.fromJson(json));
  }

  Future<void> saveCurso(CursoModel curso) async {
    final cursos = await getCursos();
    final index = cursos.indexWhere((c) => c.id == curso.id);
    
    if (index >= 0) {
      cursos[index] = curso;
    } else {
      cursos.add(curso);
    }
    
    await _saveJsonFile(_cursosFile, cursos, (c) => c.toJson());
    
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
    await _saveJsonFile(_cursosFile, cursos, (c) => c.toJson());
    
    final universidade = await getUniversidade(curso.universidadeId);
    if (universidade != null) {
      final cursosIds = universidade.cursoIds.toList();
      cursosIds.remove(id);
      await saveUniversidade(universidade.copyWith(cursoIds: cursosIds));
    }
    
    final unidades = await getUnidadesCurriculares();
    unidades.removeWhere((u) => u.cursoId == id);
    await _saveJsonFile(_unidadesCurricularesFile, unidades, (u) => u.toJson());
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
    return _loadJsonFile(_unidadesCurricularesFile, (json) => UnidadeCurricularModel.fromJson(json));
  }

  Future<void> saveUnidadeCurricular(UnidadeCurricularModel unidade) async {
    final unidades = await getUnidadesCurriculares();
    final index = unidades.indexWhere((u) => u.id == unidade.id);
    
    if (index >= 0) {
      unidades[index] = unidade;
    } else {
      unidades.add(unidade);
    }
    
    await _saveJsonFile(_unidadesCurricularesFile, unidades, (u) => u.toJson());
    
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
    await _saveJsonFile(_unidadesCurricularesFile, unidades, (u) => u.toJson());
    
    final curso = await getCurso(unidade.cursoId);
    if (curso != null) {
      final unidadeIds = curso.unidadeCurricularIds.toList();
      unidadeIds.remove(id);
      await saveCurso(curso.copyWith(unidadeCurricularIds: unidadeIds));
    }
    
    final avaliacoes = await getAvaliacoes();
    avaliacoes.removeWhere((a) => a.unidadeCurricularId == id);
    await _saveJsonFile(_avaliacoesFile, avaliacoes, (a) => a.toJson());
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
    return _loadJsonFile(_avaliacoesFile, (json) => AvaliacaoModel.fromJson(json));
  }

  Future<void> saveAvaliacao(AvaliacaoModel avaliacao) async {
    final avaliacoes = await getAvaliacoes();
    final index = avaliacoes.indexWhere((a) => a.id == avaliacao.id);
    
    if (index >= 0) {
      avaliacoes[index] = avaliacao;
    } else {
      avaliacoes.add(avaliacao);
    }
    
    await _saveJsonFile(_avaliacoesFile, avaliacoes, (a) => a.toJson());
    
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
    await _saveJsonFile(_avaliacoesFile, avaliacoes, (a) => a.toJson());
    
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
    return _loadJsonFile(_pagesFile, (json) => UniversidadePageModel.fromJson(json));
  }

  Future<void> savePage(UniversidadePageModel page) async {
    final pages = await getPages();
    final index = pages.indexWhere((p) => p.id == page.id);
    
    if (index >= 0) {
      pages[index] = page;
    } else {
      pages.add(page);
    }
    
    await _saveJsonFile(_pagesFile, pages, (p) => p.toJson());
  }

  Future<void> deletePage(String id) async {
    final pages = await getPages();
    pages.removeWhere((p) => p.id == id);
    await _saveJsonFile(_pagesFile, pages, (p) => p.toJson());
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