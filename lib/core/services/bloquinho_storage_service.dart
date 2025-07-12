import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../features/bloquinho/models/page_model.dart';
import 'local_storage_service.dart';

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
      debugPrint('❌ Erro ao obter diretório do Bloquinho: $e');
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

      debugPrint('✅ Diretório do Bloquinho criado: ${bloquinhoDir.path}');
      return bloquinhoDir;
    } catch (e) {
      debugPrint('❌ Erro ao criar diretório do Bloquinho: $e');
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
        debugPrint('🔄 Criando diretório do Bloquinho automaticamente...');
        bloquinhoDir =
            await createBloquinhoDirectory(profileName, workspaceName);
      }

      // Determinar caminho do arquivo baseado na hierarquia
      final filePath = _getPageFilePath(page, bloquinhoDir.path);
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

      debugPrint(
          '✅ Página salva: $filePath (ícone: ${page.icon ?? 'sem ícone'})');
    } catch (e) {
      debugPrint('❌ Erro ao salvar página: $e');
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
      debugPrint('❌ Erro ao carregar página: $e');
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

      // Carregar estrutura hierárquica completa
      await _loadHierarchicalStructure(bloquinhoDir, pages, null, '');

      // Atualizar childrenIds baseado na hierarquia carregada
      _updateChildrenIds(pages);

      debugPrint('✅ Estrutura hierárquica carregada: ${pages.length} páginas');
      return pages;
    } catch (e) {
      debugPrint('❌ Erro ao carregar páginas: $e');
      return [];
    }
  }

  /// Carregar estrutura hierárquica baseada em pastas e arquivos
  Future<void> _loadHierarchicalStructure(Directory dir, List<PageModel> pages,
      String? parentId, String currentPath) async {
    try {
      final entities = await dir.list().toList();
      // 1. Processar arquivos .md na raiz (páginas raiz)
      final rootMdFiles = entities
          .where((e) => e is File && e.path.endsWith(_pageExtension))
          .cast<File>()
          .toList();
      final dirFolders = entities.whereType<Directory>().toList();
      // Map para associar nome do arquivo ao id da página criada
      final Map<String, String> pageTitleToId = {};
      // Criar páginas raiz
      for (final file in rootMdFiles) {
        final pageId = path.basenameWithoutExtension(file.path);
        final title = _desanitizeFileName(pageId);
        final content = await file.readAsString();
        PageModel? metadata = await _loadPageMetadata(pageId, dir.path);
        PageModel page;
        if (metadata != null) {
          page = metadata.copyWith(content: content, parentId: parentId);
        } else {
          page = PageModel.create(
              title: title, parentId: parentId, content: content);
          await _savePageMetadata(page, dir.path);
        }
        pages.add(page);
        pageTitleToId[title] = page.id;
      }
      // 2. Processar pastas (subpáginas)
      for (final folder in dirFolders) {
        final folderName = path.basename(folder.path);
        final folderMdFile =
            File(path.join(folder.path, folderName + _pageExtension));
        String? parentPageId;
        // O parentId da subpágina é o id da página raiz com mesmo nome da pasta, ou o parentId herdado
        if (pageTitleToId.containsKey(_desanitizeFileName(folderName))) {
          parentPageId = pageTitleToId[_desanitizeFileName(folderName)];
        } else if (pages.isNotEmpty) {
          // fallback: se não achar, usar a última página raiz criada
          parentPageId = pages.last.id;
        } else {
          parentPageId = parentId;
        }
        // Processar subpasta recursivamente
        await _processPageDirectory(folder, pages, parentPageId,
            currentPath.isEmpty ? folderName : '$currentPath/$folderName');
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar estrutura hierárquica: $e');
    }
  }

  /// Processar arquivo de página
  Future<void> _processPageFile(File file, List<PageModel> pages,
      String? parentId, String currentPath) async {
    try {
      final pageId = path.basenameWithoutExtension(file.path);
      final title = _desanitizeFileName(pageId);
      final content = await file.readAsString();

      // Verificar se já existe uma página com este título (evitar duplicatas)
      final existingPage = pages.firstWhere(
        (p) => p.title == title,
        orElse: () => PageModel.create(title: ''),
      );

      if (existingPage.title.isNotEmpty) {
        debugPrint('⚠️ Página já existe, ignorando: ${existingPage.title}');
        return;
      }

      // Tentar carregar metadados existentes
      PageModel? metadata =
          await _loadPageMetadata(pageId, path.dirname(file.path));

      PageModel page;
      if (metadata != null) {
        // Usar metadados existentes, mas atualizar conteúdo e parentId
        page = metadata.copyWith(
          content: content,
          parentId: parentId,
        );
        debugPrint(
            '📄 Página carregada (metadados): ${page.title} (ID: ${page.id})');
      } else {
        // Criar nova página
        page = PageModel.create(
          title: title,
          parentId: parentId,
          content: content,
        );
        debugPrint('📄 Nova página criada: ${page.title} (ID: ${page.id})');

        // Salvar metadados para futuras referências
        await _savePageMetadata(page, path.dirname(file.path));
      }

      pages.add(page);
    } catch (e) {
      debugPrint('❌ Erro ao processar arquivo de página: $e');
    }
  }

  /// Processar diretório de página (subpáginas)
  Future<void> _processPageDirectory(Directory dir, List<PageModel> pages,
      String? parentId, String currentPath) async {
    try {
      final dirName = path.basename(dir.path);
      final pageId = _sanitizeFileName(dirName);
      final title = _desanitizeFileName(dirName);
      final pageFile = File('${dir.path}/$dirName$_pageExtension');
      PageModel? page;
      if (await pageFile.exists()) {
        final content = await pageFile.readAsString();
        PageModel? metadata = await _loadPageMetadata(pageId, dir.path);
        if (metadata != null) {
          page = metadata.copyWith(content: content, parentId: parentId);
        } else {
          page = PageModel.create(
              title: title, parentId: parentId, content: content);
          await _savePageMetadata(page, dir.path);
        }
        pages.add(page);
      }
      // Processar outros arquivos .md dentro da pasta (exceto o principal)
      final entities = await dir.list().toList();
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith(_pageExtension)) {
          final fileName = path.basenameWithoutExtension(entity.path);
          if (fileName != dirName) {
            final subParentId = page?.id ?? parentId;
            await _processPageFile(entity, pages, subParentId, currentPath);
          }
        }
      }
      // Processar subdiretórios recursivamente
      for (final entity in entities) {
        if (entity is Directory) {
          final subParentId = page?.id ?? parentId;
          await _processPageDirectory(entity, pages, subParentId,
              currentPath.isEmpty ? dirName : '$currentPath/$dirName');
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao processar diretório de página: $e');
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

    debugPrint('🔄 ChildrenIds atualizados para ${pages.length} páginas');
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
        debugPrint('🔄 Criando diretório do Bloquinho automaticamente...');
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

      debugPrint('✅ Página renomeada: $oldPath -> $newPath');
    } catch (e) {
      debugPrint('❌ Erro ao renomear página: $e');
      throw Exception('Erro ao renomear página: $e');
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
        debugPrint('🔄 Criando diretório do Bloquinho automaticamente...');
        bloquinhoDir =
            await createBloquinhoDirectory(profileName, workspaceName);
      }

      // Carregar página para obter informações
      final page = await loadPage(pageId, profileName, workspaceName);
      if (page == null) {
        throw Exception('Página não encontrada');
      }

      // Obter caminho da página
      final pagePath = _getPageFilePath(page, bloquinhoDir.path);
      final pageDir = Directory(pagePath.replaceAll(_pageExtension, ''));

      // Deletar arquivo da página
      final pageFile = File(pagePath);
      if (await pageFile.exists()) {
        await pageFile.delete();
      }

      // Deletar pasta da página (e todas as subpáginas)
      if (await pageDir.exists()) {
        await pageDir.delete(recursive: true);
      }

      // Deletar metadados
      await _deletePageMetadata(pageId, bloquinhoDir.path);

      debugPrint('✅ Página deletada: $pagePath');
    } catch (e) {
      debugPrint('❌ Erro ao deletar página: $e');
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

      debugPrint(
          '✅ Importação concluída: ${importedPages.length} páginas importadas');
      return importedPages;
    } catch (e) {
      debugPrint('❌ Erro ao importar do Notion: $e');
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

      debugPrint('✅ Workspace exportado: $exportPath');
      return zipFile;
    } catch (e) {
      debugPrint('❌ Erro ao exportar workspace: $e');
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
    } catch (e) {
      debugPrint('❌ Erro ao salvar metadados: $e');
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

      return PageModel.fromMap(Map<String, dynamic>.from(pageData));
    } catch (e) {
      debugPrint('❌ Erro ao carregar metadados: $e');
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
      debugPrint('❌ Erro ao deletar metadados: $e');
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
      debugPrint('❌ Erro ao carregar conteúdo: $e');
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
      debugPrint('❌ Erro ao importar páginas recursivamente: $e');
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
}
