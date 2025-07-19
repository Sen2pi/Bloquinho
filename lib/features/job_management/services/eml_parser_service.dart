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
      if (!await file.exists()) {
        print('Arquivo EML não existe: $emlFilePath');
        return null;
      }

      final content = await file.readAsString(encoding: latin1);
      print('Conteúdo do arquivo EML lido: ${content.length} caracteres');
      
      // Debug: mostrar início do conteúdo
      print('Primeiras linhas do EML:\n${content.split('\n').take(10).join('\n')}');
      
      // Parsear headers do email
      final headers = _parseHeaders(content);
      print('Headers parseados: ${headers.keys.join(', ')}');
      
      final body = _parseBody(content);
      print('Corpo do email parseado: ${body.length} caracteres');
      print('Primeiros 200 caracteres do corpo: ${body.length > 200 ? body.substring(0, 200) : body}');

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
        body: body.isEmpty ? null : body,
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
    try {
      // Separar headers do corpo usando dupla quebra de linha
      final headerBodySplit = content.indexOf('\n\n');
      if (headerBodySplit == -1) {
        // Tentar com \r\n\r\n
        final headerBodySplitCRLF = content.indexOf('\r\n\r\n');
        if (headerBodySplitCRLF == -1) {
          return 'Conteúdo não encontrado';
        }
        final body = content.substring(headerBodySplitCRLF + 4);
        return _decodeEmailBody(body);
      }
      
      final body = content.substring(headerBodySplit + 2);
      return _decodeEmailBody(body);
    } catch (e) {
      print('Erro ao parsear corpo do email: $e');
      return 'Erro ao processar conteúdo do email';
    }
  }

  /// Decodificar corpo do email baseado no encoding
  String _decodeEmailBody(String body) {
    if (body.trim().isEmpty) {
      return 'Conteúdo vazio';
    }

    // Verificar se é multipart
    if (body.contains('Content-Type: multipart/')) {
      return _parseMultipartBody(body);
    }

    // Verificar encoding
    if (body.contains('Content-Transfer-Encoding: base64')) {
      return _decodeBase64Body(body);
    } else if (body.contains('Content-Transfer-Encoding: quoted-printable')) {
      return _decodeQuotedPrintableBody(body);
    }

    // Se não tem encoding especial, retornar como está (limpando headers extras)
    return _cleanPlainTextBody(body);
  }

  /// Parsear corpo multipart
  String _parseMultipartBody(String body) {
    try {
      // Procurar por boundary
      final boundaryMatch = RegExp(r'boundary[=\s]*([^;\s\n\r]+)').firstMatch(body);
      if (boundaryMatch == null) {
        return _cleanPlainTextBody(body);
      }

      final boundary = '--${boundaryMatch.group(1)}';
      final parts = body.split(boundary);

      for (final part in parts) {
        if (part.trim().isEmpty || part.trim() == '--') continue;
        
        // Procurar por parte text/plain ou text/html
        if (part.contains('Content-Type: text/plain') || 
            part.contains('Content-Type: text/html')) {
          
          final partBodySplit = part.indexOf('\n\n');
          if (partBodySplit != -1) {
            final partBody = part.substring(partBodySplit + 2);
            
            if (part.contains('Content-Transfer-Encoding: base64')) {
              return _decodeBase64Body(partBody);
            } else if (part.contains('Content-Transfer-Encoding: quoted-printable')) {
              return _decodeQuotedPrintableBody(partBody);
            } else {
              return _cleanPlainTextBody(partBody);
            }
          }
        }
      }
      
      return 'Conteúdo multipart não suportado';
    } catch (e) {
      return 'Erro ao processar email multipart';
    }
  }

  /// Decodificar base64
  String _decodeBase64Body(String body) {
    try {
      // Extrair apenas as linhas base64 (sem headers)
      final lines = body.split('\n');
      final base64Lines = <String>[];
      
      bool foundBody = false;
      for (final line in lines) {
        if (line.trim().isEmpty && !foundBody) {
          foundBody = true;
          continue;
        }
        
        if (foundBody && line.trim().isNotEmpty && 
            !line.contains('Content-') && 
            !line.contains('MIME-Version') &&
            !line.startsWith('--')) {
          base64Lines.add(line.trim());
        }
      }
      
      if (base64Lines.isEmpty) {
        return 'Conteúdo base64 não encontrado';
      }
      
      final base64String = base64Lines.join('');
      final decoded = utf8.decode(base64.decode(base64String));
      return _cleanPlainTextBody(decoded);
    } catch (e) {
      return 'Erro ao decodificar base64: ${body.substring(0, 100)}...';
    }
  }

  /// Decodificar quoted-printable (simplificado)
  String _decodeQuotedPrintableBody(String body) {
    try {
      final lines = body.split('\n');
      final textLines = <String>[];
      
      bool foundBody = false;
      for (final line in lines) {
        if (line.trim().isEmpty && !foundBody) {
          foundBody = true;
          continue;
        }
        
        if (foundBody && !line.contains('Content-')) {
          textLines.add(line);
        }
      }
      
      final text = textLines.join('\n');
      // Decodificação básica do quoted-printable
      return text.replaceAll('=\n', '').replaceAllMapped(RegExp(r'=([0-9A-F]{2})'), (match) {
        try {
          return String.fromCharCode(int.parse(match.group(1)!, radix: 16));
        } catch (e) {
          return match.group(0)!;
        }
      });
    } catch (e) {
      return 'Erro ao decodificar quoted-printable';
    }
  }

  /// Limpar texto simples
  String _cleanPlainTextBody(String body) {
    final lines = body.split('\n');
    final textLines = <String>[];
    
    bool foundBody = false;
    for (final line in lines) {
      // Pular headers MIME
      if (line.startsWith('Content-') || 
          line.startsWith('MIME-Version') ||
          line.startsWith('--')) {
        continue;
      }
      
      if (line.trim().isEmpty && !foundBody) {
        foundBody = true;
        continue;
      }
      
      if (foundBody || !line.contains(':')) {
        textLines.add(line);
      }
    }
    
    final result = textLines.join('\n').trim();
    return result.isEmpty ? 'Conteúdo de texto não encontrado' : result;
  }

  /// Determinar direção do email
  EmailDirection _determineDirection(Map<String, String> headers) {
    // Lógica simplificada - poderia ser melhorada com configuração do usuário
    final from = headers['from']?.toLowerCase() ?? '';
    
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