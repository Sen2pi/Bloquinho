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

  Future<Directory> get _pagesDir async {
    final dir = await _universidadeDir;
    return Directory('${dir.path}${Platform.pathSeparator}pages');
  }

  Future<Directory> get _filesDir async {
    final dir = await _universidadeDir;
    return Directory('${dir.path}${Platform.pathSeparator}files');
  }

  Future<File> get _pagesFile async {
    final dir = await _universidadeDir;
    return File('${dir.path}${Platform.pathSeparator}pages.json');
  }

  Future<void> _ensureDirectoriesExist() async {
    final universidadeDir = await _universidadeDir;
    if (!await universidadeDir.exists()) {
      await universidadeDir.create(recursive: true);
    }
    final pagesDir = await _pagesDir;
    if (!await pagesDir.exists()) {
      await pagesDir.create(recursive: true);
    }
    final filesDir = await _filesDir;
    if (!await filesDir.exists()) {
      await filesDir.create(recursive: true);
    }
  }

  Future<List<UniversidadePageModel>> getPages() async {
    await _ensureDirectoriesExist();
    
    final pagesFile = await _pagesFile;
    if (!await pagesFile.exists()) {
      return [];
    }

    try {
      final content = await pagesFile.readAsString();
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
      final pagesFile = await _pagesFile;
      await pagesFile.writeAsString(content);
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
    
    final filesDir = await _filesDir;
    Directory targetDir = filesDir;
    if (contextoId != null && tipoContexto != null) {
      targetDir = Directory('${filesDir.path}${Platform.pathSeparator}${tipoContexto.name}${Platform.pathSeparator}$contextoId');
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
    
    final filesDir = await _filesDir;
    Directory targetDir = filesDir;
    if (contextoId != null && tipoContexto != null) {
      targetDir = Directory('${filesDir.path}${Platform.pathSeparator}${tipoContexto.name}${Platform.pathSeparator}$contextoId');
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
    
    final filesDir = await _filesDir;
    Directory targetDir = filesDir;
    if (contextoId != null && tipoContexto != null) {
      targetDir = Directory('${filesDir.path}${Platform.pathSeparator}${tipoContexto.name}${Platform.pathSeparator}$contextoId');
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
    
    final filesDir = await _filesDir;
    countFiles(filesDir);
    
    return {
      'totalFiles': totalFiles,
      'totalSize': totalSize,
      'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
    };
  }
}