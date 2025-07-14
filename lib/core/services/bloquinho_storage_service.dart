import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../features/bloquinho/models/page_model.dart';
import 'local_storage_service.dart';
import '../constants/page_icons.dart';

/// Serviço para gerenciar persistência de páginas do Bloquinho
/// Estrutura: data/profile/[nome_profile]/workspaces/[workspace_name]/bloquinho/
class BloquinhoStorageService {
  static const String _bloquinhoFolder = 'bloquinho';
  static const String _pageExtension = '.md';
  static const String _metadataFile = '_metadata.json';

  /// Instância singleton
  static final BloquinhoStorageService _instance =
      BloquinhoStorageService._internal();
  factory BloquinhoStorageService() => _instance;
  BloquinhoStorageService._internal();

  final LocalStorageService _localStorageService = LocalStorageService();

  /// Inicializar o serviço
  Future<void> initialize() async {
    await _localStorageService.initialize();
  }

  /// Obter diretório do Bloquinho para um workspace específico
  Future<Directory?> getBloquinhoDirectory(
      String profileName, String workspaceName) async {
    try {
      // Usar o novo método getWorkspace para obter workspace existente
      final workspaceDir =
          await _localStorageService.getWorkspace(profileName, workspaceName);
      if (workspaceDir == null) return null;

      final bloquinhoDir =
          Directory(path.join(workspaceDir.path, _bloquinhoFolder));
      if (!await bloquinhoDir.exists()) {
        await bloquinhoDir.create(recursive: true);
      }

      return bloquinhoDir;
    } catch (e) {
      
      return null;
    }
  }

  /// Criar diretório do Bloquinho para um workspace
  Future<Directory> createBloquinhoDirectory(
      String profileName, String workspaceName) async {
    try {
      // Primeiro tentar obter workspace existente
      Directory? workspaceDir =
          await _localStorageService.getWorkspace(profileName, workspaceName);

      // Se não existir, criar
      if (workspaceDir == null) {
        final workspacePath = await _localStorageService.createWorkspace(
            profileName, workspaceName);

        if (workspacePath == null) {
          throw Exception('Erro ao criar workspace');
        }

        workspaceDir = Directory(workspacePath);
      }

      final bloquinhoDir =
          Directory(path.join(workspaceDir.path, _bloquinhoFolder));

      if (!await bloquinhoDir.exists()) {
        await bloquinhoDir.create(recursive: true);
      }

      
      return bloquinhoDir;
    } catch (e) {
      
      throw Exception('Erro ao criar diretório do Bloquinho: $e');
    }
  }

  /// Salvar página como arquivo markdown
  Future<void> savePage(
      PageModel page, String profileName, String workspaceName) async {
    try {
      // Tentar obter diretório existente
      Directory? bloquinhoDir =
          await getBloquinhoDirectory(profileName, workspaceName);

      // Se não existir, criar automaticamente
      if (bloquinhoDir == null) {
        bloquinhoDir =
            await createBloquinhoDirectory(profileName, workspaceName);
      }

      // Determinar caminho do arquivo baseado na hierarquia
      String filePath;
      if (page.parentId == null) {
        // Página raiz: salva direto na raiz do bloquinho
        filePath = path.join(
            bloquinhoDir.path, _sanitizeFileName(page.title) + _pageExtension);
      } else {
        // Subpágina: criar diretório dentro do diretório do pai
        final parentPage =
            await _findPageById(page.parentId!, bloquinhoDir.path);
        if (parentPage != null) {
          // Encontrar o diretório do pai
          String parentDirPath;
          if (parentPage.parentId == null) {
            // Pai é página raiz, criar pasta dentro do bloquinho
            parentDirPath = path.join(
                bloquinhoDir.path, _sanitizeFileName(parentPage.title));
          } else {
            // Pai é subpágina, navegar recursivamente
            parentDirPath =
                await _getPageDirectoryPath(parentPage, bloquinhoDir.path);
          }

          // Criar diretório da subpágina dentro do diretório do pai
          final subPageDir = Directory(
              path.join(parentDirPath, _sanitizeFileName(page.title)));
          if (!await subPageDir.exists()) {
            await subPageDir.create(recursive: true);
          }

          filePath = path.join(
              subPageDir.path, _sanitizeFileName(page.title) + _pageExtension);
        } else {
          // Fallback: salvar na raiz se não encontrar pai
          filePath = path.join(bloquinhoDir.path,
              _sanitizeFileName(page.title) + _pageExtension);
        }
      }

      final file = File(filePath);

      // Criar diretório pai se não existir
      final parentDir = Directory(path.dirname(filePath));
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }

      // Salvar conteúdo markdown
      await file.writeAsString(page.content);

      // Salvar metadados da página (incluindo ícone)
      await _savePageMetadata(page, bloquinhoDir.path);
      // Removido debugPrint de ícone e página salva
    } catch (e) {
      throw Exception('Erro ao salvar página: $e');
    }
  }

  /// Carregar página do arquivo markdown
  Future<PageModel?> loadPage(
      String pageId, String profileName, String workspaceName) async {
    try {
      final bloquinhoDir =
          await getBloquinhoDirectory(profileName, workspaceName);
      if (bloquinhoDir == null) return null;

      // Carregar metadados primeiro
      final metadata = await _loadPageMetadata(pageId, bloquinhoDir.path);
      if (metadata == null) return null;

      // Carregar conteúdo markdown
      final content = await _loadPageContent(pageId, bloquinhoDir.path);

      return metadata.copyWith(content: content);
    } catch (e) {
      return null;
    }
  }

  /// Carregar todas as páginas de um workspace
  Future<List<PageModel>> loadAllPages(
      String profileName, String workspaceName) async {
    try {
      final bloquinhoDir =
          await getBloquinhoDirectory(profileName, workspaceName);
      if (bloquinhoDir == null) return [];

      final pages = <PageModel>[];

      // Carregar estrutura hierárquica usando algoritmo tree-like
      await _loadHierarchicalStructureTree(bloquinhoDir, pages, null);

      // Atualizar childrenIds baseado na hierarquia carregada
      _updateChildrenIds(pages);

      return pages;
    } catch (e) {
      return [];
    }
  }

  /// Carregar estrutura hierárquica baseada em diretórios e arquivos .md
  Future<void> _loadHierarchicalStructureTree(
      Directory dir, List<PageModel> pages, String? parentId) async {
    try {
      final entities = await dir.list().toList();
      final dirName = path.basename(dir.path);

      // 1. Se existe um arquivo .md com o mesmo nome do diretório, ele é a página deste nível
      File? pageFile;
      final potentialPageFile =
          File(path.join(dir.path, dirName + _pageExtension));
      if (await potentialPageFile.exists()) {
        pageFile = potentialPageFile;
      } else {
        // Se não existe, buscar o primeiro arquivo .md do diretório
        final mdFiles = entities
            .where((e) => e is File && e.path.endsWith(_pageExtension))
            .cast<File>()
            .toList();
        if (mdFiles.isNotEmpty) {
          pageFile = mdFiles.first;
        }
      }

      PageModel? thisPage;
      if (pageFile != null) {
        final pageId = path.basenameWithoutExtension(pageFile.path);
        final title = _desanitizeFileName(pageId);
        final content = await pageFile.readAsString();
        PageModel? metadata = await _loadPageMetadata(pageId, dir.path);

        // Determinar se esta é uma página raiz (está no diretório raiz do bloquinho)
        final isRootPage = dir.path.endsWith('bloquinho');

        if (metadata != null) {
          // PRESERVAR o ícone dos metadados se existir, senão usar padrão
          final icon = metadata.icon ?? _getDefaultIcon(title);
          // Removido debugPrint de página com metadados encontrada

          // CORREÇÃO: Garantir que página raiz tenha parentId null
          final correctedParentId = isRootPage ? null : parentId;

          thisPage = metadata.copyWith(
            content: content,
            parentId: correctedParentId,
            icon: icon, // PRESERVAR o ícone dos metadados
          );
        } else {
          final defaultIcon = _getDefaultIcon(title);
          // Removido debugPrint de subpágina sem metadados

          thisPage = PageModel.create(
            title: title,
            parentId:
                isRootPage ? null : parentId, // CORREÇÃO: Raiz sempre null
            content: content,
            icon: defaultIcon,
            customId: pageId,
          );
          await _savePageMetadata(thisPage, dir.path);
        }
        pages.add(thisPage);
        parentId = thisPage
            .id; // O parentId para subpastas passa a ser o id desta página
      }

      // 2. Processar TODOS os arquivos .md do diretório (incluindo subpáginas)
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith(_pageExtension)) {
          final fileName = path.basenameWithoutExtension(entity.path);
          // Pular o arquivo principal se já foi processado
          if (fileName == dirName && pageFile != null) continue;

          final title = _desanitizeFileName(fileName);
          final content = await entity.readAsString();
          PageModel? metadata = await _loadPageMetadata(fileName, dir.path);
          PageModel page;
          if (metadata != null) {
            // PRESERVAR o ícone dos metadados se existir, senão usar padrão
            final icon = metadata.icon ?? _getDefaultIcon(title);
            // Removido debugPrint de subpágina com metadados encontrada

            page = metadata.copyWith(
              content: content,
              parentId: parentId,
              icon: icon, // PRESERVAR o ícone dos metadados
            );
          } else {
            final defaultIcon = _getDefaultIcon(title);
            // Removido debugPrint de subpágina sem metadados

            page = PageModel.create(
              title: title,
              parentId: parentId,
              content: content,
              icon: defaultIcon,
              customId: fileName,
            );
            await _savePageMetadata(page, dir.path);
          }
          pages.add(page);
        }
      }

      // 3. Processar subdiretórios DEPOIS de processar todos os arquivos
      final directories = entities.whereType<Directory>().toList();
      for (final directory in directories) {
        final subDirName = path.basename(directory.path);
        if (subDirName.startsWith('.') || subDirName == '_metadata') continue;
        await _loadHierarchicalStructureTree(directory, pages, parentId);
      }
    } catch (e) {
    }
  }

  /// Atualizar childrenIds baseado na hierarquia carregada
  void _updateChildrenIds(List<PageModel> pages) {
    // Criar mapa de parentId -> List<PageModel>
    final childrenMap = <String, List<PageModel>>{};

    for (final page in pages) {
      if (page.parentId != null) {
        childrenMap.putIfAbsent(page.parentId!, () => []).add(page);
      }
    }

    // Atualizar childrenIds de cada página
    for (final page in pages) {
      final children = childrenMap[page.id] ?? [];
      final childrenIds = children.map((child) => child.id).toList();

      if (childrenIds.isNotEmpty) {
        final index = pages.indexOf(page);
        if (index != -1) {
          pages[index] = page.copyWith(childrenIds: childrenIds);
        }
      }
    }

  }

  /// Renomear página (arquivo e pasta)
  Future<void> renamePage(String pageId, String newTitle, String profileName,
      String workspaceName) async {
    try {
      // Tentar obter diretório existente
      Directory? bloquinhoDir =
          await getBloquinhoDirectory(profileName, workspaceName);

      // Se não existir, criar automaticamente
      if (bloquinhoDir == null) {
        bloquinhoDir =
            await createBloquinhoDirectory(profileName, workspaceName);
      }

      // Carregar página atual
      final currentPage = await loadPage(pageId, profileName, workspaceName);
      if (currentPage == null) {
        throw Exception('Página não encontrada');
      }

      // Obter caminhos antigo e novo
      final oldPath = _getPageFilePath(currentPage, bloquinhoDir.path);
      final newPage = currentPage.copyWith(title: newTitle);
      final newPath = _getPageFilePath(newPage, bloquinhoDir.path);

      // Renomear arquivo/pasta
      final oldFile = File(oldPath);
      final newFile = File(newPath);

      if (await oldFile.exists()) {
        if (await newFile.exists()) {
          await newFile.delete(); // Sobrescrever se existir
        }
        await oldFile.rename(newPath);
      }

      // Renomear pasta se existir (para subpáginas)
      final oldDir = Directory(oldPath.replaceAll(_pageExtension, ''));
      final newDir = Directory(newPath.replaceAll(_pageExtension, ''));

      if (await oldDir.exists()) {
        if (await newDir.exists()) {
          await newDir.delete(recursive: true); // Sobrescrever se existir
        }
        await oldDir.rename(newDir.path);
      }

      // Atualizar metadados
      await _savePageMetadata(newPage, bloquinhoDir.path);

    } catch (e) {
      throw Exception('Erro ao renomear página: $e');
    }
  }

  /// Limpa páginas corrompidas (auto-referência) dos metadados e remove arquivo/pasta se necessário
  Future<void> cleanCorruptedPagesAndMetadata(
      String profileName, String workspaceName) async {
    try {
      final bloquinhoDir =
          await getBloquinhoDirectory(profileName, workspaceName);
      if (bloquinhoDir == null) return;
      final metadataFile = File(path.join(bloquinhoDir.path, _metadataFile));
      if (!await metadataFile.exists()) return;

      final content = await metadataFile.readAsString();
      final metadata = Map<String, dynamic>.from(json.decode(content));
      final idsToRemove = <String>[];
      metadata.forEach((id, data) {
        if (data is Map && data['parentId'] == id) {
          idsToRemove.add(id);
        }
      });
      for (final id in idsToRemove) {
        metadata.remove(id);
      }
      if (metadata.isEmpty) {
        await metadataFile.delete();
        // Se não há mais páginas, tentar remover a pasta do bloquinho
        try {
          final files = await bloquinhoDir.list().toList();
          if (files.isEmpty) {
            await bloquinhoDir.delete(recursive: true);
          }
        } catch (e) {
        }
      } else {
        await metadataFile.writeAsString(json.encode(metadata));
      }
      if (idsToRemove.isNotEmpty) {
      }
    } catch (e) {
    }
  }

  /// Deletar página e todas as suas subpáginas
  Future<void> deletePage(
      String pageId, String profileName, String workspaceName) async {
    try {

      // Tentar obter diretório existente
      Directory? bloquinhoDir =
          await getBloquinhoDirectory(profileName, workspaceName);

      // Se não existir, criar automaticamente
      if (bloquinhoDir == null) {
        bloquinhoDir =
            await createBloquinhoDirectory(profileName, workspaceName);
      }

      // Carregar página para obter informações
      final page = await loadPage(pageId, profileName, workspaceName);
      if (page == null) {
        return;
      }


      // Primeiro, deletar todas as subpáginas recursivamente
      for (final childId in page.childrenIds) {
        await deletePage(childId, profileName, workspaceName);
      }

      // Determinar caminho do arquivo baseado na hierarquia (mesma lógica do savePage)
      String filePath;
      if (page.parentId == null) {
        // Página raiz: arquivo direto na raiz do bloquinho
        filePath = path.join(
            bloquinhoDir.path, _sanitizeFileName(page.title) + _pageExtension);
      } else {
        // Subpágina: arquivo dentro do diretório do pai
        final parentPage =
            await _findPageById(page.parentId!, bloquinhoDir.path);
        if (parentPage != null) {
          // Encontrar o diretório do pai
          String parentDirPath;
          if (parentPage.parentId == null) {
            // Pai é página raiz, pasta dentro do bloquinho
            parentDirPath = path.join(
                bloquinhoDir.path, _sanitizeFileName(parentPage.title));
          } else {
            // Pai é subpágina, navegar recursivamente
            parentDirPath =
                await _getPageDirectoryPath(parentPage, bloquinhoDir.path);
          }

          // Caminho do arquivo da subpágina
          filePath = path.join(
              parentDirPath, _sanitizeFileName(page.title) + _pageExtension);
        } else {
          // Fallback: arquivo na raiz se não encontrar pai
          filePath = path.join(bloquinhoDir.path,
              _sanitizeFileName(page.title) + _pageExtension);
        }
      }

      // Determinar caminho da pasta da página
      String pageDirPath;
      if (page.parentId == null) {
        // Página raiz: pasta com nome da página na raiz
        pageDirPath =
            path.join(bloquinhoDir.path, _sanitizeFileName(page.title));
      } else {
        // Subpágina: pasta dentro do diretório do pai
        final parentPage =
            await _findPageById(page.parentId!, bloquinhoDir.path);
        if (parentPage != null) {
          String parentDirPath;
          if (parentPage.parentId == null) {
            parentDirPath = path.join(
                bloquinhoDir.path, _sanitizeFileName(parentPage.title));
          } else {
            parentDirPath =
                await _getPageDirectoryPath(parentPage, bloquinhoDir.path);
          }
          pageDirPath = path.join(parentDirPath, _sanitizeFileName(page.title));
        } else {
          // Fallback
          pageDirPath =
              path.join(bloquinhoDir.path, _sanitizeFileName(page.title));
        }
      }


      // Deletar arquivo da página
      final pageFile = File(filePath);
      if (await pageFile.exists()) {
        await pageFile.delete();
      } else {
      }

      // Deletar pasta da página (e todas as subpáginas)
      final pageDir = Directory(pageDirPath);
      if (await pageDir.exists()) {
        try {
          await pageDir.delete(recursive: true);
        } catch (e) {
          // Tentar deletar arquivos individualmente se a pasta não puder ser removida
          try {
            final files = await pageDir.list().toList();
            for (final file in files) {
              if (file is File) {
                await file.delete();
              }
            }
          } catch (e2) {
          }
        }
      } else {
      }

      // Deletar metadados
      await _deletePageMetadata(pageId, bloquinhoDir.path);

      // Limpeza extra após deleção
      await cleanCorruptedPagesAndMetadata(profileName, workspaceName);
    } catch (e) {
      throw Exception('Erro ao deletar página: $e');
    }
  }

  /// Importar estrutura de pastas do Notion
  Future<List<PageModel>> importFromNotionFolder(
      String folderPath, String profileName, String workspaceName) async {
    try {
      final sourceDir = Directory(folderPath);
      if (!await sourceDir.exists()) {
        throw Exception('Pasta de origem não encontrada');
      }

      final bloquinhoDir =
          await createBloquinhoDirectory(profileName, workspaceName);
      final importedPages = <PageModel>[];

      await _importPagesRecursively(
          sourceDir, bloquinhoDir, importedPages, null);

      return importedPages;
    } catch (e) {
      throw Exception('Erro ao importar do Notion: $e');
    }
  }

  /// Exportar workspace para backup
  Future<File> exportWorkspace(
      String profileName, String workspaceName, String exportPath) async {
    try {
      final workspacesDir =
          await _localStorageService.getWorkspacesDirectory(profileName);
      if (workspacesDir == null) {
        throw Exception('Workspace não encontrado');
      }

      final workspaceDir =
          Directory(path.join(workspacesDir.path, workspaceName));
      if (!await workspaceDir.exists()) {
        throw Exception('Workspace não encontrado');
      }

      // Criar arquivo ZIP do workspace
      final zipFile = File(exportPath);
      // TODO: Implementar compressão ZIP
      // Por enquanto, apenas copiar a pasta manualmente
      await _copyDirectoryRecursively(
          workspaceDir, Directory(path.dirname(exportPath)));

      return zipFile;
    } catch (e) {
      throw Exception('Erro ao exportar workspace: $e');
    }
  }

  // Métodos auxiliares privados

  /// Obter caminho do arquivo da página
  String _getPageFilePath(PageModel page, String bloquinhoPath) {
    final safeTitle = _sanitizeFileName(page.title);

    if (page.parentId == null) {
      // Página raiz
      return path.join(bloquinhoPath, '$safeTitle$_pageExtension');
    } else {
      // Subpágina - criar pasta com nome da página
      final pageDir = path.join(bloquinhoPath, safeTitle);
      return path.join(pageDir, '$safeTitle$_pageExtension');
    }
  }

  /// Salvar metadados da página
  Future<void> _savePageMetadata(PageModel page, String bloquinhoPath) async {
    try {
      final metadataFile = File(path.join(bloquinhoPath, _metadataFile));
      Map<String, dynamic> metadata = {};

      if (await metadataFile.exists()) {
        final content = await metadataFile.readAsString();
        metadata = Map<String, dynamic>.from(json.decode(content));
      }

      metadata[page.id] = page.toMap();
      await metadataFile.writeAsString(json.encode(metadata));

      // Removido debugPrint de metadados salvos
    } catch (e) {
    }
  }

  /// Carregar metadados da página
  Future<PageModel?> _loadPageMetadata(
      String pageId, String bloquinhoPath) async {
    try {
      final metadataFile = File(path.join(bloquinhoPath, _metadataFile));
      if (!await metadataFile.exists()) return null;

      final content = await metadataFile.readAsString();
      final metadata = Map<String, dynamic>.from(json.decode(content));

      final pageData = metadata[pageId];
      if (pageData == null) return null;

      // Removido debugPrint de metadados carregados

      final page = PageModel.fromMap(Map<String, dynamic>.from(pageData));

      // Removido debugPrint de página carregada dos metadados

      return page;
    } catch (e) {
      return null;
    }
  }

  /// Deletar metadados da página
  Future<void> _deletePageMetadata(String pageId, String bloquinhoPath) async {
    try {
      final metadataFile = File(path.join(bloquinhoPath, _metadataFile));
      if (!await metadataFile.exists()) return;

      final content = await metadataFile.readAsString();
      final metadata = Map<String, dynamic>.from(json.decode(content));

      metadata.remove(pageId);
      await metadataFile.writeAsString(json.encode(metadata));
    } catch (e) {
    }
  }

  /// Carregar conteúdo da página
  Future<String> _loadPageContent(String pageId, String bloquinhoPath) async {
    try {
      // Procurar arquivo .md com o pageId
      final dir = Directory(bloquinhoPath);
      final entities = await dir.list().toList();

      for (final entity in entities) {
        if (entity is File && entity.path.endsWith(_pageExtension)) {
          final filePageId = path.basenameWithoutExtension(entity.path);
          if (filePageId == pageId) {
            return await entity.readAsString();
          }
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  /// Importar páginas recursivamente
  Future<void> _importPagesRecursively(Directory sourceDir, Directory targetDir,
      List<PageModel> importedPages, String? parentId) async {
    try {
      final entities = await sourceDir.list().toList();

      for (final entity in entities) {
        if (entity is File && entity.path.endsWith(_pageExtension)) {
          // Importar arquivo markdown
          final title = path.basenameWithoutExtension(entity.path);
          final content = await entity.readAsString();

          final page = PageModel.create(
            title: title,
            parentId: parentId,
            content: content,
          );

          // Salvar página no destino
          final targetFile = File(path.join(
              targetDir.path, '${_sanitizeFileName(title)}$_pageExtension'));
          await targetFile.writeAsString(content);

          importedPages.add(page);
        } else if (entity is Directory) {
          // Verificar se existe arquivo markdown correspondente
          final pageFile = File('${entity.path}$_pageExtension');
          if (await pageFile.exists()) {
            final title = path.basenameWithoutExtension(pageFile.path);
            final content = await pageFile.readAsString();

            final page = PageModel.create(
              title: title,
              parentId: parentId,
              content: content,
            );

            // Criar pasta no destino
            final targetSubDir =
                Directory(path.join(targetDir.path, _sanitizeFileName(title)));
            if (!await targetSubDir.exists()) {
              await targetSubDir.create(recursive: true);
            }

            // Salvar arquivo markdown
            final targetFile = File(path.join(
                targetDir.path, '${_sanitizeFileName(title)}$_pageExtension'));
            await targetFile.writeAsString(content);

            importedPages.add(page);

            // Importar subpáginas recursivamente
            await _importPagesRecursively(
                entity, targetSubDir, importedPages, page.id);
          }
        }
      }
    } catch (e) {
    }
  }

  /// Copiar diretório recursivamente
  Future<void> _copyDirectoryRecursively(
      Directory sourceDir, Directory targetDir) async {
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final entities = await sourceDir.list().toList();
    for (final entity in entities) {
      if (entity is File) {
        final targetFile =
            File(path.join(targetDir.path, entity.path.split('/').last));
        await entity.copy(targetFile.path);
      } else if (entity is Directory) {
        final targetSubDir =
            Directory(path.join(targetDir.path, entity.path.split('/').last));
        await _copyDirectoryRecursively(entity, targetSubDir);
      }
    }
  }

  /// Sanitizar nome de arquivo
  String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  /// Desanitizar nome de arquivo (converter de volta para título legível)
  String _desanitizeFileName(String fileName) {
    return fileName.replaceAll('_', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Obter ícone padrão baseado no título da página
  String _getDefaultIcon(String title) {
    return PageIcons.getIconForTitle(title);
  }

  /// Obter caminho do diretório da página
  Future<String> _getPageDirectoryPath(
      PageModel page, String bloquinhoPath) async {
    if (page.parentId == null) {
      // Página raiz: diretório com nome da página dentro do bloquinho
      return path.join(bloquinhoPath, _sanitizeFileName(page.title));
    } else {
      // Subpágina: diretório do pai + nome da página
      final parentPage = await _findPageById(page.parentId!, bloquinhoPath);
      if (parentPage != null) {
        final parentDir =
            await _getPageDirectoryPath(parentPage, bloquinhoPath);
        return path.join(parentDir, _sanitizeFileName(page.title));
      } else {
        // Fallback: diretório com nome da página dentro do bloquinho
        return path.join(bloquinhoPath, _sanitizeFileName(page.title));
      }
    }
  }

  /// Encontrar página pelo id recursivamente em toda a estrutura
  Future<PageModel?> _findPageById(String id, String dirPath) async {
    try {
      // Primeiro, verificar metadados no diretório atual
      final metadata = await _loadPageMetadata(id, dirPath);
      if (metadata != null) {
        return metadata;
      }

      // Se não encontrar, buscar recursivamente em subdiretórios
      final dir = Directory(dirPath);
      final entities = await dir.list().toList();

      for (final entity in entities) {
        if (entity is Directory &&
            !path.basename(entity.path).startsWith('.')) {
          final found = await _findPageById(id, entity.path);
          if (found != null) return found;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}