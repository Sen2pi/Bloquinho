/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/page_model.dart';
import '../../../core/services/bloquinho_storage_service.dart';
import '../../../core/constants/page_icons.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../shared/providers/workspace_provider.dart';

class PagesNotifier extends StateNotifier<List<PageModel>> {
  final BloquinhoStorageService _storageService = BloquinhoStorageService();
  bool _isInitialized = false;
  String? _currentProfileName;
  String? _currentWorkspaceName;

  PagesNotifier() : super([]) {
    // Inicializar automaticamente
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await initialize();

      // Carregar páginas do workspace atual se disponível
      if (_currentProfileName != null && _currentWorkspaceName != null) {
        await loadPagesFromWorkspace(
            _currentProfileName, _currentWorkspaceName);
      }
    } catch (e) {
      // Erro na inicialização
    }
  }

  /// Inicializar provider carregando páginas do armazenamento
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _storageService.initialize();
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  /// Carregar páginas do workspace atual
  Future<void> loadPagesFromWorkspace(
      String? profileName, String? workspaceName) async {
    try {
      await initialize();

      // Verificar se temos perfil e workspace válidos
      if (profileName == null || workspaceName == null) {
        state = [];
        return;
      }

      // Verificar se mudou o contexto
      if (_currentProfileName == profileName &&
          _currentWorkspaceName == workspaceName) {
        return;
      }

      // Atualizar contexto atual
      _currentProfileName = profileName;
      _currentWorkspaceName = workspaceName;

      final pages =
          await _storageService.loadAllPages(profileName, workspaceName);

      // CORREÇÃO: Corrigir metadados corrompidos automaticamente
      final correctedPages = _fixCorruptedPages(pages);

      state = correctedPages;
    } catch (e) {
      state = [];
    }
  }

  /// Corrigir páginas com metadados corrompidos
  List<PageModel> _fixCorruptedPages(List<PageModel> pages) {
    final correctedPages = <PageModel>[];
    final seenIds = <String>{};

    for (final page in pages) {
      // Verificar se é uma página duplicada
      if (seenIds.contains(page.id)) {
        continue;
      }
      seenIds.add(page.id);

      // Verificar se tem auto-referência
      if (page.parentId == page.id) {
        // Corrigir: se é a página raiz (Main), parentId = null, senão usar um parent válido
        final correctedPage = page.copyWith(
            parentId: page.title.toLowerCase() == 'main' ? null : 'Main');
        correctedPages.add(correctedPage);
      } else {
        correctedPages.add(page);
      }
    }

    return correctedPages;
  }

  /// Recarregar páginas quando o workspace muda
  Future<void> reloadPages() async {
    await loadPagesFromWorkspace(_currentProfileName, _currentWorkspaceName);
  }

  /// Recarregar páginas quando o workspace muda
  Future<void> reloadPagesForWorkspace(
      String profileName, String workspaceName) async {
    await loadPagesFromWorkspace(profileName, workspaceName);
  }

  PageModel? getById(String id) {
    try {
      return state.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<PageModel> getChildren(String parentId) =>
      state.where((p) => p.parentId == parentId).toList();

  /// Gerar ID único para página baseado no título
  String _generatePageId(String title) {
    // Usar o título como ID, mas sanitizado
    return title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  }

  /// Criar nova página e salvar no armazenamento
  Future<void> createPage({
    required String title,
    String? icon,
    String? parentId,
    String content = '',
  }) async {
    try {
      await initialize();

      // Verificar se temos contexto válido
      if (_currentProfileName == null || _currentWorkspaceName == null) {
        throw Exception('Perfil ou workspace não disponível');
      }

      // PROTEÇÃO: Garantir que parentId não seja igual ao id da página
      final pageId = _generatePageId(title);
      if (parentId == pageId) {
        parentId = null; // Corrigir para null se for auto-referência
      }

      final page = PageModel.create(
        title: title,
        icon: icon,
        parentId: parentId,
        content: content,
      );

      // Adicionar ao estado
      state = [...state, page];

      // Atualizar parent se necessário
      if (parentId != null) {
        _addChild(parentId, page.id);
      }

      // Salvar no armazenamento
      await _savePageToStorage(page);
    } catch (e) {
      throw Exception('Erro ao criar página: $e');
    }
  }

  /// Atualizar página e salvar no armazenamento
  Future<void> updatePage(
    String id, {
    String? title,
    String? icon,
    List<dynamic>? blocks,
    String? content,
  }) async {
    try {
      await initialize();

      // Validar ícone se fornecido
      String? validIcon;
      if (icon != null) {
        validIcon = PageIcons.getValidIcon(icon);
        if (validIcon != icon) {
        }
      }

      final updatedPages = [
        for (final p in state)
          if (p.id == id)
            p.copyWith(
              title: title ?? p.title,
              icon: validIcon ?? p.icon,
              blocks: blocks ?? p.blocks,
              content: content ?? p.content,
              updatedAt: DateTime.now(),
            )
          else
            p
      ];

      state = updatedPages;

      // Salvar no armazenamento
      final updatedPage = getById(id);
      if (updatedPage != null) {
        await _savePageToStorage(updatedPage);
      }
    } catch (e) {
      if (kDebugMode) {
      }
      throw Exception('Erro ao atualizar página: $e');
    }
  }

  /// Auto-save do conteúdo da página
  Future<void> updatePageContent(String id, String content) async {
    try {
      await initialize();

      final updatedPages = [
        for (final p in state)
          if (p.id == id)
            p.copyWith(
              content: content,
              updatedAt: DateTime.now(),
            )
          else
            p
      ];

      state = updatedPages;

      // Salvar no armazenamento
      final updatedPage = getById(id);
      if (updatedPage != null) {
        await _savePageToStorage(updatedPage);
      }
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  /// Renomear página (arquivo e pasta)
  Future<void> renamePage(String id, String newTitle) async {
    try {
      await initialize();

      final page = getById(id);
      if (page == null) {
        throw Exception('Página não encontrada');
      }

      // Verificar se temos contexto válido
      if (_currentProfileName == null || _currentWorkspaceName == null) {
        throw Exception('Perfil ou workspace não disponível');
      }

      // Renomear no armazenamento
      await _storageService.renamePage(
          id, newTitle, _currentProfileName!, _currentWorkspaceName!);

      // Atualizar estado
      await updatePage(id, title: newTitle);
    } catch (e) {
      if (kDebugMode) {
      }
      throw Exception('Erro ao renomear página: $e');
    }
  }

  /// Remover página e todas as suas subpáginas
  Future<void> removePage(String id) async {
    try {
      await initialize();

      final page = getById(id);
      if (page == null) {
        if (kDebugMode) {
        }
        return;
      }

      if (kDebugMode) {
      }

      // Remover filhos recursivamente primeiro
      final childrenToRemove = List<String>.from(page.childrenIds);
      for (final childId in childrenToRemove) {
        if (kDebugMode) {
        }
        await removePage(childId);
      }

      // Remover do estado
      state = state.where((p) => p.id != id).toList();

      // Remover do parent se necessário
      if (page.parentId != null) {
        _removeChild(page.parentId!, id);
      }

      // Deletar do armazenamento (arquivo e pasta)
      if (_currentProfileName != null && _currentWorkspaceName != null) {
        if (kDebugMode) {
        }
        await _storageService.deletePage(
            id, _currentProfileName!, _currentWorkspaceName!);
      }

      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
      throw Exception('Erro ao remover página: $e');
    }
  }

  void _addChild(String parentId, String childId) {
    state = [
      for (final p in state)
        if (p.id == parentId)
          p.copyWith(childrenIds: [...p.childrenIds, childId])
        else
          p
    ];
  }

  void _removeChild(String parentId, String childId) {
    state = [
      for (final p in state)
        if (p.id == parentId)
          p.copyWith(
              childrenIds: p.childrenIds.where((c) => c != childId).toList())
        else
          p
    ];
  }

  /// Salvar página no armazenamento
  Future<void> _savePageToStorage(PageModel page) async {
    try {
      // Verificar se temos contexto válido
      if (_currentProfileName == null || _currentWorkspaceName == null) {
        if (kDebugMode) {
        }
        return;
      }

      await _storageService.savePage(
          page, _currentProfileName!, _currentWorkspaceName!);
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  /// Importar páginas de uma pasta do Notion
  Future<List<PageModel>> importFromNotionFolder(String folderPath) async {
    try {
      await initialize();

      // Verificar se temos contexto válido
      if (_currentProfileName == null || _currentWorkspaceName == null) {
        throw Exception('Perfil ou workspace não disponível');
      }

      final importedPages = await _storageService.importFromNotionFolder(
          folderPath, _currentProfileName!, _currentWorkspaceName!);

      // Adicionar ao estado
      state = [...state, ...importedPages];

      if (kDebugMode) {
      }
      return importedPages;
    } catch (e) {
      if (kDebugMode) {
      }
      throw Exception('Erro ao importar páginas: $e');
    }
  }

  List<PageModel> searchPages(String query) {
    final lowercaseQuery = query.toLowerCase();
    return state.where((page) {
      return page.title.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Map<String, dynamic> getStatistics() {
    final totalPages = state.length;
    final rootPages = state.where((p) => p.isRoot).length;
    final subPages = state.where((p) => p.isSubPage).length;

    return {
      'totalPages': totalPages,
      'rootPages': rootPages,
      'subPages': subPages,
      'activePages': totalPages - subPages,
    };
  }
}

final pagesProvider = StateNotifierProvider.family<PagesNotifier,
    List<PageModel>, ({String? profileName, String? workspaceName})>(
  (ref, context) => PagesNotifier()
    ..loadPagesFromWorkspace(context.profileName, context.workspaceName),
);

// Provider proxy para acessar o notifier
final pagesNotifierProvider = Provider.family<PagesNotifier,
    ({String? profileName, String? workspaceName})>(
  (ref, context) => ref.read(pagesProvider(context).notifier),
);

// Provider para carregar páginas automaticamente quando o contexto muda
final pagesLoaderProvider = Provider<void>((ref) {
  final currentProfile = ref.watch(currentProfileProvider);
  final currentWorkspace = ref.watch(currentWorkspaceProvider);

  if (currentProfile != null && currentWorkspace != null) {
    final pagesNotifier = ref.read(pagesNotifierProvider((
      profileName: currentProfile.name,
      workspaceName: currentWorkspace.name
    )));

    // Carregar páginas quando o contexto muda
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pagesNotifier.loadPagesFromWorkspace(
        currentProfile.name,
        currentWorkspace.name,
      );
    });
  }
});

final currentPagesProvider = Provider<List<PageModel>>((ref) {
  final currentProfile = ref.watch(currentProfileProvider);
  final currentWorkspace = ref.watch(currentWorkspaceProvider);

  if (currentProfile == null || currentWorkspace == null) {
    return [];
  }

  return ref.watch(pagesProvider((
    profileName: currentProfile.name,
    workspaceName: currentWorkspace.name
  )));
});

// Provider para acessar o notifier do contexto atual
final currentPagesNotifierProvider = Provider<PagesNotifier?>((ref) {
  final currentProfile = ref.watch(currentProfileProvider);
  final currentWorkspace = ref.watch(currentWorkspaceProvider);

  if (currentProfile == null || currentWorkspace == null) {
    return null;
  }

  return ref.read(pagesNotifierProvider((
    profileName: currentProfile.name,
    workspaceName: currentWorkspace.name
  )));
});
