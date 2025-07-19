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
import '../models/email_tracking_model.dart';
import '../../../core/services/workspace_storage_service.dart';

class EmlParserService {
  static final EmlParserService _instance = EmlParserService._internal();
  factory EmlParserService() => _instance;
  EmlParserService._internal();

  final WorkspaceStorageService _workspaceStorage = WorkspaceStorageService();
  final String _emlDir = 'email_tracking';

  /// Configurar contexto (perfil + workspace)
  Future<void> setContext(String profileName, String workspaceId) async {
    await _workspaceStorage.setContext(profileName, workspaceId);
  }

  /// Processar arquivo .eml e extrair informações
  Future<EmailTrackingModel?> parseEmlFile(
    String emlFilePath,
    String applicationId,
  ) async {
    try {
      final file = File(emlFilePath);
      if (!await file.exists()) return null;

      final content = await file.readAsString(encoding: latin1);
      
      // Parsear headers do email
      final headers = _parseHeaders(content);
      final body = _parseBody(content);

      // Determinar direção do email (simplificado)
      final direction = _determineDirection(headers);

      // Salvar arquivo .eml no workspace
      final savedEmlPath = await _saveEmlFile(emlFilePath);

      return EmailTrackingModel.create(
        applicationId: applicationId,
        subject: headers['subject'] ?? 'Sem assunto',
        fromEmail: _cleanEmail(headers['from'] ?? ''),
        toEmail: _cleanEmail(headers['to'] ?? ''),
        ccEmail: headers['cc'] != null ? _cleanEmail(headers['cc']!) : null,
        bccEmail: headers['bcc'] != null ? _cleanEmail(headers['bcc']!) : null,
        sentDate: _parseDate(headers['date']),
        body: body,
        direction: direction,
        emlFilePath: savedEmlPath,
      );
    } catch (e) {
      print('Erro ao processar arquivo EML: $e');
      return null;
    }
  }

  /// Obter diretório para emails no workspace atual
  Future<Directory> get _emlDirectory async {
    await _workspaceStorage.initialize();
    final workspacePath = await _workspaceStorage.getCurrentWorkspacePath();
    if (workspacePath == null) {
      throw Exception('Workspace path not found');
    }
    final emlDir = Directory(path.join(workspacePath, _emlDir));
    if (!await emlDir.exists()) {
      await emlDir.create(recursive: true);
    }
    return emlDir;
  }

  /// Salvar arquivo .eml no workspace
  Future<String?> _saveEmlFile(String originalPath) async {
    try {
      final originalFile = File(originalPath);
      if (!await originalFile.exists()) return null;

      final emlDir = await _emlDirectory;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(originalPath)}';
      final newPath = path.join(emlDir.path, fileName);
      
      await originalFile.copy(newPath);
      return newPath;
    } catch (e) {
      return null;
    }
  }

  /// Parsear headers do email
  Map<String, String> _parseHeaders(String content) {
    final headers = <String, String>{};
    final lines = content.split('\n');
    
    String? currentHeader;
    String currentValue = '';
    
    for (final line in lines) {
      if (line.trim().isEmpty) break; // Fim dos headers
      
      if (line.startsWith(' ') || line.startsWith('\t')) {
        // Continuação do header anterior
        currentValue += ' ${line.trim()}';
      } else if (line.contains(':')) {
        // Salvar header anterior se existir
        if (currentHeader != null) {
          headers[currentHeader.toLowerCase()] = currentValue.trim();
        }
        
        // Novo header
        final parts = line.split(':');
        currentHeader = parts[0].trim();
        currentValue = parts.sublist(1).join(':').trim();
      }
    }
    
    // Salvar último header
    if (currentHeader != null) {
      headers[currentHeader.toLowerCase()] = currentValue.trim();
    }
    
    return headers;
  }

  /// Parsear corpo do email
  String _parseBody(String content) {
    final parts = content.split('\n\n');
    if (parts.length > 1) {
      // Pegar tudo após os headers
      final body = parts.sublist(1).join('\n\n');
      
      // Decodificar se for base64 ou quoted-printable (simplificado)
      if (body.contains('Content-Transfer-Encoding: base64')) {
        try {
          final base64Lines = body.split('\n').where((line) => 
            line.trim().isNotEmpty && 
            !line.contains('Content-') && 
            !line.contains('MIME-Version')
          ).join('');
          return utf8.decode(base64.decode(base64Lines));
        } catch (e) {
          return body;
        }
      }
      
      return body;
    }
    return '';
  }

  /// Determinar direção do email
  EmailDirection _determineDirection(Map<String, String> headers) {
    // Lógica simplificada - poderia ser melhorada com configuração do usuário
    final from = headers['from']?.toLowerCase() ?? '';
    final to = headers['to']?.toLowerCase() ?? '';
    
    // Se contém domínios comuns de empresas, provavelmente foi recebido
    if (from.contains('@company.com') || from.contains('@empresa.pt')) {
      return EmailDirection.received;
    }
    
    return EmailDirection.sent;
  }

  /// Limpar endereço de email
  String _cleanEmail(String email) {
    // Remove nome e mantém só o email
    final match = RegExp(r'<([^>]+)>').firstMatch(email);
    if (match != null) {
      return match.group(1) ?? email;
    }
    return email.trim();
  }

  /// Parsear data do email
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null) return DateTime.now();
    
    try {
      // Tentar parsear formato RFC 2822
      return DateTime.parse(dateStr.trim());
    } catch (e) {
      try {
        // Tentar outros formatos comuns
        final cleanDate = dateStr.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
        return DateTime.parse(cleanDate);
      } catch (e) {
        return DateTime.now();
      }
    }
  }

  /// Remover arquivo .eml
  Future<bool> deleteEmlFile(String emlFilePath) async {
    try {
      final file = File(emlFilePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}