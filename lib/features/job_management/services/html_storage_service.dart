/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class HtmlStorageService {
  static const String _htmlFolderName = 'cv_html_files';
  
  /// Salva o conteúdo HTML em um arquivo local e retorna o caminho
  Future<String> saveHtmlFile(String htmlContent, String originalFileName) async {
    final directory = await _getHtmlStorageDirectory();
    
    // Gerar um ID único para o arquivo
    final fileId = const Uuid().v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Extrair extensão do arquivo original ou usar .html como padrão
    final extension = path.extension(originalFileName).isEmpty 
        ? '.html' 
        : path.extension(originalFileName);
    
    // Criar nome do arquivo com ID único
    final fileName = '${fileId}_$timestamp$extension';
    final filePath = path.join(directory.path, fileName);
    
    // Salvar o arquivo
    final file = File(filePath);
    await file.writeAsString(htmlContent, encoding: utf8);
    
    return filePath;
  }
  
  /// Lê o conteúdo de um arquivo HTML salvo
  Future<String> readHtmlFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Arquivo HTML não encontrado: $filePath');
    }
    
    return await file.readAsString(encoding: utf8);
  }
  
  /// Remove um arquivo HTML
  Future<void> deleteHtmlFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
  
  /// Obtém o diretório para armazenamento dos arquivos HTML
  Future<Directory> _getHtmlStorageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final htmlDir = Directory(path.join(appDir.path, _htmlFolderName));
    
    if (!await htmlDir.exists()) {
      await htmlDir.create(recursive: true);
    }
    
    return htmlDir;
  }
  
  /// Lista todos os arquivos HTML salvos
  Future<List<FileSystemEntity>> listHtmlFiles() async {
    final directory = await _getHtmlStorageDirectory();
    return directory.listSync().where((entity) => 
        entity is File && 
        (entity.path.endsWith('.html') || entity.path.endsWith('.htm'))
    ).toList();
  }
  
  /// Obtém informações de um arquivo HTML
  Future<Map<String, dynamic>> getFileInfo(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Arquivo não encontrado: $filePath');
    }
    
    final stat = await file.stat();
    final fileName = path.basename(filePath);
    
    return {
      'path': filePath,
      'name': fileName,
      'size': stat.size,
      'modified': stat.modified,
      'created': stat.accessed, // Aproximação para data de criação
    };
  }
  
  /// Limpa arquivos HTML antigos (mais de 30 dias)
  Future<void> cleanupOldFiles({int daysOld = 30}) async {
    final directory = await _getHtmlStorageDirectory();
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    
    final files = await listHtmlFiles();
    
    for (final file in files) {
      final stat = await file.stat();
      if (stat.modified.isBefore(cutoffDate)) {
        await file.delete();
      }
    }
  }
}