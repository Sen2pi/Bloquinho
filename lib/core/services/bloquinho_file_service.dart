import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Serviço para gerenciar páginas do Bloquinho com estrutura hierárquica
/// Estrutura: bloquinho/[página_principal]/[subpágina]/[arquivo].md
class BloquinhoFileService {
  static const String _pageExtension = '.md';
  static const String _metadataExtension = '.json';

  /// Instância singleton
  static final BloquinhoFileService _instance =
      BloquinhoFileService._internal();
  factory BloquinhoFileService() => _instance;
  BloquinhoFileService._internal();

  /// Salvar página do Bloquinho
  Future<void> savePage({
    required String profileName,
    required String workspaceName,
    required String pageTitle,
    required String content,
    String? parentPageTitle,
    String? pageId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Obter diretório do Bloquinho
      final bloquinhoDir =
          await _getBloquinhoDirectory(profileName, workspaceName);
      if (bloquinhoDir == null) {
        throw Exception('Diretório do Bloquinho não encontrado');
      }

      // Gerar ID da página se não fornecido
      final finalPageId = pageId ?? const Uuid().v4();

      // Determinar caminho da página
      final pagePath =
          _getPagePath(bloquinhoDir.path, pageTitle, parentPageTitle);
      final pageDir = Directory(pagePath);

      // Criar diretório da página se não existir
      if (!await pageDir.exists()) {
        await pageDir.create(recursive: true);
      }

      // Salvar arquivo markdown
      final markdownFile = File(path.join(pagePath, '${pageTitle}.md'));
      await markdownFile.writeAsString(content);

      // Salvar metadados
      final metadataFile =
          File(path.join(pagePath, '${pageTitle}$_metadataExtension'));
      final pageMetadata = {
        'id': finalPageId,
        'title': pageTitle,
        'parentTitle': parentPageTitle,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'contentLength': content.length,
        ...?metadata,
      };
      await metadataFile.writeAsString(json.encode(pageMetadata));
    } catch (e) {
      throw Exception('Erro ao salvar página: $e');
    }
  }

  /// Carregar página do Bloquinho
  Future<Map<String, dynamic>?> loadPage({
    required String profileName,
    required String workspaceName,
    required String pageTitle,
    String? parentPageTitle,
  }) async {
    try {
      // Obter diretório do Bloquinho
      final bloquinhoDir =
          await _getBloquinhoDirectory(profileName, workspaceName);
      if (bloquinhoDir == null) return null;

      // Determinar caminho da página
      final pagePath =
          _getPagePath(bloquinhoDir.path, pageTitle, parentPageTitle);

      // Carregar arquivo markdown
      final markdownFile = File(path.join(pagePath, '${pageTitle}.md'));
      if (!await markdownFile.exists()) return null;

      final content = await markdownFile.readAsString();

      // Carregar metadados
      final metadataFile =
          File(path.join(pagePath, '${pageTitle}$_metadataExtension'));
      Map<String, dynamic> metadata = {};
      if (await metadataFile.exists()) {
        final metadataContent = await metadataFile.readAsString();
        metadata = Map<String, dynamic>.from(json.decode(metadataContent));
      }

      return {
        'content': content,
        'metadata': metadata,
        'path': markdownFile.path,
      };
    } catch (e) {
      return null;
    }
  }

  /// Listar todas as páginas do Bloquinho
  Future<List<Map<String, dynamic>>> listAllPages({
    required String profileName,
    required String workspaceName,
  }) async {
    try {
      // Obter diretório do Bloquinho
      final bloquinhoDir =
          await _getBloquinhoDirectory(profileName, workspaceName);
      if (bloquinhoDir == null) return [];

      final pages = <Map<String, dynamic>>[];
      await _scanPagesRecursively(bloquinhoDir, pages, null);

      return pages;
    } catch (e) {
      return [];
    }
  }

  /// Criar subpágina
  Future<void> createSubPage({
    required String profileName,
    required String workspaceName,
    required String parentPageTitle,
    required String subPageTitle,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    await savePage(
      profileName: profileName,
      workspaceName: workspaceName,
      pageTitle: subPageTitle,
      content: content,
      parentPageTitle: parentPageTitle,
      metadata: metadata,
    );
  }

  /// Renomear página
  Future<void> renamePage({
    required String profileName,
    required String workspaceName,
    required String oldTitle,
    required String newTitle,
    String? parentPageTitle,
  }) async {
    try {
      // Obter diretório do Bloquinho
      final bloquinhoDir =
          await _getBloquinhoDirectory(profileName, workspaceName);
      if (bloquinhoDir == null) {
        throw Exception('Diretório do Bloquinho não encontrado');
      }

      // Determinar caminhos antigo e novo
      final oldPagePath =
          _getPagePath(bloquinhoDir.path, oldTitle, parentPageTitle);
      final newPagePath =
          _getPagePath(bloquinhoDir.path, newTitle, parentPageTitle);

      // Renomear diretório
      final oldDir = Directory(oldPagePath);
      final newDir = Directory(newPagePath);

      if (await oldDir.exists()) {
        if (await newDir.exists()) {
          await newDir.delete(recursive: true);
        }
        await oldDir.rename(newPagePath);
      }

      // Renomear arquivos dentro do diretório
      final oldMarkdownFile = File(path.join(oldPagePath, '${oldTitle}.md'));
      final newMarkdownFile = File(path.join(newPagePath, '${newTitle}.md'));

      if (await oldMarkdownFile.exists()) {
        await oldMarkdownFile.rename(newMarkdownFile.path);
      }

      final oldMetadataFile =
          File(path.join(oldPagePath, '${oldTitle}$_metadataExtension'));
      final newMetadataFile =
          File(path.join(newPagePath, '${newTitle}$_metadataExtension'));

      if (await oldMetadataFile.exists()) {
        await oldMetadataFile.rename(newMetadataFile.path);
      }
    } catch (e) {
      throw Exception('Erro ao renomear página: $e');
    }
  }

  /// Deletar página e todas as suas subpáginas
  Future<void> deletePage({
    required String profileName,
    required String workspaceName,
    required String pageTitle,
    String? parentPageTitle,
  }) async {
    try {
      // Obter diretório do Bloquinho
      final bloquinhoDir =
          await _getBloquinhoDirectory(profileName, workspaceName);
      if (bloquinhoDir == null) {
        throw Exception('Diretório do Bloquinho não encontrado');
      }

      // Determinar caminho da página
      final pagePath =
          _getPagePath(bloquinhoDir.path, pageTitle, parentPageTitle);
      final pageDir = Directory(pagePath);

      if (await pageDir.exists()) {
        await pageDir.delete(recursive: true);
      }
    } catch (e) {
      throw Exception('Erro ao deletar página: $e');
    }
  }

  /// Auto-save com debounce
  Timer? _autoSaveTimer;
  Future<void> autoSave({
    required String profileName,
    required String workspaceName,
    required String pageTitle,
    required String content,
    String? parentPageTitle,
    Map<String, dynamic>? metadata,
  }) async {
    // Cancelar timer anterior
    _autoSaveTimer?.cancel();

    // Configurar novo timer (2 segundos de debounce)
    _autoSaveTimer = Timer(const Duration(seconds: 2), () async {
      try {
        await savePage(
          profileName: profileName,
          workspaceName: workspaceName,
          pageTitle: pageTitle,
          content: content,
          parentPageTitle: parentPageTitle,
          metadata: metadata,
        );
      } catch (e) {
        // Erro no auto-save
      }
    });
  }

  /// Obter diretório do Bloquinho
  Future<Directory?> _getBloquinhoDirectory(
      String profileName, String workspaceName) async {
    try {
      // Usar o FileStorageService para obter o diretório
      // Por enquanto, implementar diretamente
      final appDir = await getApplicationDocumentsDirectory();
      final basePath = path.join(
          appDir.path,
          'data',
          'profile',
          _sanitizeFileName(profileName),
          'workspaces',
          _sanitizeFileName(workspaceName),
          'bloquinho');

      final bloquinhoDir = Directory(basePath);
      if (!await bloquinhoDir.exists()) {
        await bloquinhoDir.create(recursive: true);
      }

      return bloquinhoDir;
    } catch (e) {
      return null;
    }
  }

  /// Determinar caminho da página
  String _getPagePath(
      String bloquinhoPath, String pageTitle, String? parentPageTitle) {
    if (parentPageTitle != null) {
      // Subpágina: bloquinho/[página_principal]/[subpágina]/
      return path.join(bloquinhoPath, _sanitizeFileName(parentPageTitle),
          _sanitizeFileName(pageTitle));
    } else {
      // Página principal: bloquinho/[página_principal]/
      return path.join(bloquinhoPath, _sanitizeFileName(pageTitle));
    }
  }

  /// Escanear páginas recursivamente
  Future<void> _scanPagesRecursively(Directory directory,
      List<Map<String, dynamic>> pages, String? parentTitle) async {
    try {
      final entities = await directory.list(followLinks: false).toList();
      final directories = entities.whereType<Directory>().toList();

      for (final dir in directories) {
        final dirName = path.basename(dir.path);
        final markdownFile = File(path.join(dir.path, '${dirName}.md'));
        final metadataFile =
            File(path.join(dir.path, '${dirName}$_metadataExtension'));

        if (await markdownFile.exists()) {
          final content = await markdownFile.readAsString();
          Map<String, dynamic> metadata = {};

          if (await metadataFile.exists()) {
            final metadataContent = await metadataFile.readAsString();
            metadata = Map<String, dynamic>.from(json.decode(metadataContent));
          }

          pages.add({
            'title': dirName,
            'content': content,
            'metadata': metadata,
            'parentTitle': parentTitle,
            'path': markdownFile.path,
            'hasChildren': await _hasSubPages(dir),
          });
        }

        // Recursivamente escanear subpáginas
        await _scanPagesRecursively(dir, pages, dirName);
      }
    } catch (e) {
      // Erro ao escanear páginas
    }
  }

  /// Verificar se diretório tem subpáginas
  Future<bool> _hasSubPages(Directory directory) async {
    try {
      final entities = await directory.list(followLinks: false).toList();
      final directories = entities.whereType<Directory>().toList();
      return directories.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Sanitizar nome de arquivo/pasta
  String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(' ', '_')
        .toLowerCase();
  }

  /// Limpar timer de auto-save
  void dispose() {
    _autoSaveTimer?.cancel();
  }
}
