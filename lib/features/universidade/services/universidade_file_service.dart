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
import '../models/universidade_page_model.dart';
import '../../../core/services/workspace_storage_service.dart';

class UniversidadeFileService {
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

  Directory get _pagesDir {
    return Directory('${_universidadeDir.path}${Platform.pathSeparator}pages');
  }

  Directory get _filesDir {
    return Directory('${_universidadeDir.path}${Platform.pathSeparator}files');
  }

  File get _pagesFile {
    return File('${_universidadeDir.path}${Platform.pathSeparator}pages.json');
  }

  Future<void> _ensureDirectoriesExist() async {
    if (!await _universidadeDir.exists()) {
      await _universidadeDir.create(recursive: true);
    }
    if (!await _pagesDir.exists()) {
      await _pagesDir.create(recursive: true);
    }
    if (!await _filesDir.exists()) {
      await _filesDir.create(recursive: true);
    }
  }

  Future<List<UniversidadePageModel>> getPages() async {
    await _ensureDirectoriesExist();
    
    if (!await _pagesFile.exists()) {
      return [];
    }

    try {
      final content = await _pagesFile.readAsString();
      final List<dynamic> jsonList = json.decode(content);
      return jsonList.map((item) => UniversidadePageModel.fromJson(item)).toList();
    } catch (e) {
      print('Erro ao carregar páginas: $e');
      return [];
    }
  }

  Future<void> savePages(List<UniversidadePageModel> pages) async {
    await _ensureDirectoriesExist();
    
    try {
      final jsonList = pages.map((page) => page.toJson()).toList();
      final content = json.encode(jsonList);
      await _pagesFile.writeAsString(content);
    } catch (e) {
      print('Erro ao salvar páginas: $e');
      rethrow;
    }
  }

  Future<void> savePage(UniversidadePageModel page) async {
    final pages = await getPages();
    final index = pages.indexWhere((p) => p.id == page.id);
    
    if (index >= 0) {
      pages[index] = page;
    } else {
      pages.add(page);
    }
    
    await savePages(pages);
    
    if (page.parentId != null) {
      final parentPages = await getPages();
      final parentIndex = parentPages.indexWhere((p) => p.id == page.parentId);
      if (parentIndex >= 0) {
        final parent = parentPages[parentIndex];
        if (!parent.childrenIds.contains(page.id)) {
          final updatedParent = parent.copyWith(
            childrenIds: [...parent.childrenIds, page.id]
          );
          parentPages[parentIndex] = updatedParent;
          await savePages(parentPages);
        }
      }
    }
  }

  Future<void> deletePage(String pageId) async {
    final pages = await getPages();
    final pageToDelete = pages.firstWhere((p) => p.id == pageId, orElse: () => throw Exception('Página não encontrada'));
    
    if (pageToDelete.parentId != null) {
      final parentIndex = pages.indexWhere((p) => p.id == pageToDelete.parentId);
      if (parentIndex >= 0) {
        final parent = pages[parentIndex];
        final updatedParent = parent.copyWith(
          childrenIds: parent.childrenIds.where((id) => id != pageId).toList()
        );
        pages[parentIndex] = updatedParent;
      }
    }
    
    void deleteRecursively(String id) {
      final page = pages.firstWhere((p) => p.id == id, orElse: () => throw Exception('Página não encontrada'));
      for (final childId in page.childrenIds) {
        deleteRecursively(childId);
      }
      pages.removeWhere((p) => p.id == id);
    }
    
    deleteRecursively(pageId);
    await savePages(pages);
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

  Future<List<UniversidadePageModel>> getRootPages() async {
    final pages = await getPages();
    return pages.where((p) => p.isRoot).toList();
  }

  Future<List<UniversidadePageModel>> getChildPages(String parentId) async {
    final pages = await getPages();
    return pages.where((p) => p.parentId == parentId).toList();
  }

  Future<List<UniversidadePageModel>> searchPages(String query) async {
    final pages = await getPages();
    final lowercaseQuery = query.toLowerCase();
    return pages.where((p) => 
      p.titulo.toLowerCase().contains(lowercaseQuery) ||
      p.conteudo.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  Future<File> saveFile(String fileName, List<int> bytes, {String? contextoId, TipoContextoPage? tipoContexto}) async {
    await _ensureDirectoriesExist();
    
    Directory targetDir = _filesDir;
    if (contextoId != null && tipoContexto != null) {
      targetDir = Directory('${_filesDir.path}${Platform.pathSeparator}${tipoContexto.name}${Platform.pathSeparator}$contextoId');
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }
    }
    
    final file = File('${targetDir.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<List<FileSystemEntity>> getFiles({String? contextoId, TipoContextoPage? tipoContexto}) async {
    await _ensureDirectoriesExist();
    
    Directory targetDir = _filesDir;
    if (contextoId != null && tipoContexto != null) {
      targetDir = Directory('${_filesDir.path}${Platform.pathSeparator}${tipoContexto.name}${Platform.pathSeparator}$contextoId');
      if (!await targetDir.exists()) {
        return [];
      }
    }
    
    return targetDir.listSync();
  }

  Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File?> getFile(String fileName, {String? contextoId, TipoContextoPage? tipoContexto}) async {
    await _ensureDirectoriesExist();
    
    Directory targetDir = _filesDir;
    if (contextoId != null && tipoContexto != null) {
      targetDir = Directory('${_filesDir.path}${Platform.pathSeparator}${tipoContexto.name}${Platform.pathSeparator}$contextoId');
    }
    
    final file = File('${targetDir.path}${Platform.pathSeparator}$fileName');
    return await file.exists() ? file : null;
  }

  Future<Map<String, dynamic>> getFileStats() async {
    await _ensureDirectoriesExist();
    
    int totalFiles = 0;
    int totalSize = 0;
    
    void countFiles(Directory dir) {
      if (dir.existsSync()) {
        for (final entity in dir.listSync(recursive: true)) {
          if (entity is File) {
            totalFiles++;
            totalSize += entity.lengthSync();
          }
        }
      }
    }
    
    countFiles(_filesDir);
    
    return {
      'totalFiles': totalFiles,
      'totalSize': totalSize,
      'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
    };
  }
}