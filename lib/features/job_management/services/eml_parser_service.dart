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

    print('Analisando tipo de conteúdo do email...');
    
    // Verificar se é multipart (case insensitive e várias variações)
    final isMultipart = body.toLowerCase().contains('content-type: multipart/') ||
                       body.toLowerCase().contains('content-type:multipart/') ||
                       body.contains('multipart/') ||
                       body.contains('boundary=');
    
    print('Contém multipart: $isMultipart');
    print('Contém base64: ${body.contains('Content-Transfer-Encoding: base64')}');
    print('Contém quoted-printable: ${body.contains('Content-Transfer-Encoding: quoted-printable')}');
    
    if (isMultipart) {
      print('Email identificado como multipart, processando...');
      return _parseMultipartBody(body);
    }

    // Verificar encoding
    if (body.contains('Content-Transfer-Encoding: base64')) {
      return _decodeBase64Body(body);
    } else if (body.contains('Content-Transfer-Encoding: quoted-printable')) {
      return _decodeQuotedPrintableBody(body);
    }

    // Verificar se parece ser Base64 mesmo sem header explícito
    final cleanedBody = body.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');
    if (_looksLikeBase64(cleanedBody)) {
      print('Conteúdo parece ser Base64 sem header explícito');
      return _decodeBase64Body(body);
    }

    // Se não tem encoding especial, retornar como está (limpando headers extras)
    return _cleanPlainTextBody(body);
  }

  /// Verificar se uma string parece ser Base64
  bool _looksLikeBase64(String text) {
    if (text.length < 20) return false;
    
    // Base64 deve ter apenas caracteres válidos
    if (!RegExp(r'^[A-Za-z0-9+/]*={0,2}$').hasMatch(text)) return false;
    
    // Base64 deve ser múltiplo de 4
    if (text.length % 4 != 0) return false;
    
    // Se tem mais de 100 caracteres consecutivos base64, provavelmente é base64
    return text.length > 100;
  }

  /// Parsear corpo multipart
  String _parseMultipartBody(String body) {
    try {
      print('Processando email multipart...');
      print('Tamanho do corpo: ${body.length} caracteres');
      
      // Procurar por boundary de várias formas
      String? boundary;
      String? rawBoundary;
      
      // Tentar encontrar boundary no Content-Type (incluindo headers do email inteiro)
      final boundaryMatches = [
        RegExp(r'boundary[=\s]*"([^"]+)"', caseSensitive: false).firstMatch(body),
        RegExp(r"boundary[=\s]*'([^']+)'", caseSensitive: false).firstMatch(body),
        RegExp(r'boundary[=\s]*([^;\s\n\r<>"]+)', caseSensitive: false).firstMatch(body),
      ];
      
      for (final match in boundaryMatches) {
        if (match != null) {
          rawBoundary = match.group(1)?.trim();
          if (rawBoundary != null && rawBoundary.isNotEmpty) {
            boundary = '--$rawBoundary';
            print('Boundary encontrado: "$boundary" (raw: "$rawBoundary")');
            break;
          }
        }
      }
      
      if (boundary == null) {
        print('Boundary não encontrado nos headers, procurando no corpo...');
        
        // Tentar encontrar boundaries diretamente no texto (--xxxx)
        final directBoundaryMatch = RegExp(r'^--([a-zA-Z0-9_\-=]+)', multiLine: true).firstMatch(body);
        if (directBoundaryMatch != null) {
          boundary = directBoundaryMatch.group(0);
          print('Boundary direto encontrado: "$boundary"');
        } else {
          print('Nenhum boundary encontrado, tentando parsing como texto simples...');
          return _cleanPlainTextBody(body);
        }
      }
      
      final parts = body.split(boundary!);
      print('Encontradas ${parts.length} partes com boundary "$boundary"');
      
      String? bestContent;
      String? fallbackContent;
      
      for (int i = 0; i < parts.length; i++) {
        final part = parts[i];
        if (part.trim().isEmpty || part.trim() == '--') continue;
        
        print('Processando parte $i (${part.length} chars)...');
        final partLines = part.split('\n');
        print('Primeiras 3 linhas da parte: ${partLines.take(3).join('\\n')}');
        
        // Separar headers do conteúdo da parte
        int partHeaderBodySplit = part.indexOf('\n\n');
        if (partHeaderBodySplit == -1) {
          // Tentar com \r\n\r\n
          partHeaderBodySplit = part.indexOf('\r\n\r\n');
          if (partHeaderBodySplit == -1) {
            print('Parte $i: não foi possível separar headers do corpo');
            // Se não conseguir separar headers, tratar tudo como conteúdo
            final trimmedPart = part.trim();
            if (trimmedPart.isNotEmpty && !trimmedPart.startsWith('-')) {
              fallbackContent ??= _cleanPlainTextBody(trimmedPart);
              print('Parte $i tratada como conteúdo direto');
            }
            continue;
          }
        }
        
        final partHeaders = part.substring(0, partHeaderBodySplit).toLowerCase();
        final partBody = part.substring(partHeaderBodySplit + (partHeaderBodySplit == part.indexOf('\n\n') ? 2 : 4));
        
        print('Headers da parte $i: ${partHeaders.replaceAll('\n', '\\n')}');
        print('Corpo da parte $i (${partBody.length} chars): ${partBody.length > 50 ? partBody.substring(0, 50).replaceAll('\n', '\\n') : partBody.replaceAll('\n', '\\n')}...');
        
        // Verificar tipo de conteúdo (case insensitive)
        final isTextPlain = partHeaders.contains('content-type: text/plain') || 
                           partHeaders.contains('content-type:text/plain');
        final isTextHtml = partHeaders.contains('content-type: text/html') || 
                          partHeaders.contains('content-type:text/html');
        final isQuotedPrintable = partHeaders.contains('content-transfer-encoding: quoted-printable') ||
                                 partHeaders.contains('content-transfer-encoding:quoted-printable');
        final isBase64 = partHeaders.contains('content-transfer-encoding: base64') ||
                        partHeaders.contains('content-transfer-encoding:base64');
        
        print('Parte $i - Plain: $isTextPlain, HTML: $isTextHtml, QP: $isQuotedPrintable, B64: $isBase64');
        
        // Se tem conteúdo de texto, processar
        if ((isTextPlain || isTextHtml) && partBody.trim().isNotEmpty) {
          String processedContent;
          
          if (isBase64) {
            processedContent = _decodeBase64Body(partBody);
          } else if (isQuotedPrintable) {
            processedContent = _decodeQuotedPrintableBody(partBody);
          } else {
            processedContent = _cleanPlainTextBody(partBody);
          }
          
          // Se é HTML, extrair texto
          if (isTextHtml && (processedContent.contains('<') || processedContent.contains('&'))) {
            processedContent = _extractTextFromHtml(processedContent);
          }
          
          // Verificar se o conteúdo processado tem texto útil
          if (processedContent.trim().isNotEmpty && processedContent.length > 10) {
            // Preferir text/plain sobre text/html
            if (isTextPlain) {
              bestContent = processedContent;
              print('Melhor conteúdo encontrado (text/plain): ${processedContent.length > 100 ? processedContent.substring(0, 100) : processedContent}...');
              break; // Usar text/plain como prioridade
            } else if (fallbackContent == null || isTextHtml) {
              fallbackContent = processedContent;
              print('Conteúdo alternativo encontrado: ${processedContent.length > 100 ? processedContent.substring(0, 100) : processedContent}...');
            }
          }
        } else if (partBody.trim().isNotEmpty && !partBody.trim().startsWith('-')) {
          // Se não tem headers específicos mas tem conteúdo, tentar processar
          final cleanContent = _cleanPlainTextBody(partBody);
          if (cleanContent.trim().isNotEmpty && cleanContent.length > 10) {
            fallbackContent ??= cleanContent;
            print('Conteúdo sem headers específicos encontrado na parte $i');
          }
        }
      }
      
      final result = bestContent ?? fallbackContent ?? 'Conteúdo multipart não encontrado';
      print('Resultado final multipart: ${result.length > 200 ? result.substring(0, 200) : result}...');
      return result;
      
    } catch (e) {
      print('Erro ao processar email multipart: $e');
      return 'Erro ao processar email multipart: $e';
    }
  }

  /// Decodificar base64
  String _decodeBase64Body(String body) {
    try {
      String base64Content = '';
      
      // Se contém headers Content-Transfer-Encoding, extrair só o conteúdo depois
      if (body.contains('Content-Transfer-Encoding: base64')) {
        print('Encontrado header Content-Transfer-Encoding: base64');
        final lines = body.split('\n');
        final base64Lines = <String>[];
        
        bool foundTransferEncoding = false;
        bool foundEmptyLine = false;
        
        for (final line in lines) {
          if (line.contains('Content-Transfer-Encoding: base64')) {
            foundTransferEncoding = true;
            continue;
          }
          
          if (foundTransferEncoding && line.trim().isEmpty && !foundEmptyLine) {
            foundEmptyLine = true;
            continue;
          }
          
          if (foundEmptyLine && line.trim().isNotEmpty && 
              !line.contains('Content-') && 
              !line.contains('MIME-Version') &&
              !line.startsWith('--')) {
            base64Lines.add(line.trim());
          }
        }
        
        base64Content = base64Lines.join('');
      } else {
        print('Sem header explícito, tentando extrair Base64 do conteúdo');
        // Extrair todas as linhas que parecem ser base64
        final lines = body.split('\n');
        final base64Lines = <String>[];
        
        for (final line in lines) {
          final trimmedLine = line.trim();
          if (trimmedLine.isNotEmpty && 
              !trimmedLine.contains(':') && // Evitar headers
              !trimmedLine.contains('Content-') && 
              !trimmedLine.contains('MIME-Version') &&
              !trimmedLine.startsWith('--') &&
              RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(trimmedLine)) {
            base64Lines.add(trimmedLine);
          }
        }
        
        base64Content = base64Lines.join('');
      }
      
      if (base64Content.isEmpty) {
        return 'Conteúdo base64 não encontrado';
      }
      
      print('Base64 extraído (${base64Content.length} chars): ${base64Content.length > 100 ? base64Content.substring(0, 100) : base64Content}...');
      
      // Tentar decodificar
      final decoded = utf8.decode(base64.decode(base64Content));
      print('Decodificação bem-sucedida (${decoded.length} chars)');
      print('Primeiros 300 chars decodificados: ${decoded.length > 300 ? decoded.substring(0, 300) : decoded}');
      
      // Se o conteúdo decodificado é HTML, extrair o texto
      if (decoded.toLowerCase().contains('<html>') || 
          decoded.toLowerCase().contains('<body>') ||
          decoded.toLowerCase().contains('<p>')) {
        print('Conteúdo identificado como HTML, extraindo texto...');
        final extractedText = _extractTextFromHtml(decoded);
        print('Texto extraído (${extractedText.length} chars): ${extractedText.length > 200 ? extractedText.substring(0, 200) : extractedText}...');
        return extractedText;
      }
      
      return _cleanPlainTextBody(decoded);
    } catch (e) {
      print('Erro ao decodificar base64: $e');
      // Em caso de erro, tentar mostrar o conteúdo original limitado
      final preview = body.length > 200 ? body.substring(0, 200) : body;
      return 'Erro ao decodificar base64: $preview...';
    }
  }

  /// Decodificar quoted-printable (melhorado)
  String _decodeQuotedPrintableBody(String body) {
    try {
      print('Decodificando quoted-printable...');
      print('Conteúdo original: ${body.length > 200 ? body.substring(0, 200) : body}...');
      
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
      
      String text = textLines.join('\n');
      
      // Decodificação quoted-printable melhorada
      print('Antes da decodificação: ${text.length > 200 ? text.substring(0, 200) : text}...');
      
      // 1. Remover soft line breaks (=\n ou =\r\n)
      text = text.replaceAll(RegExp(r'=\r?\n'), '');
      
      // 2. Decodificar caracteres especiais (=XX onde XX é hex)
      text = text.replaceAllMapped(RegExp(r'=([0-9A-F]{2})'), (match) {
        try {
          final hexValue = match.group(1)!;
          final charCode = int.parse(hexValue, radix: 16);
          
          // Mapear alguns códigos comuns problemáticos
          switch (charCode) {
            case 0xA0: return ' '; // Non-breaking space -> espaço normal
            case 0xC2: return '';  // Prefixo UTF-8 problemático
            case 0x20: return ' '; // Espaço
            case 0x0A: return '\n'; // Line feed
            case 0x0D: return '\r'; // Carriage return
            case 0x09: return '\t'; // Tab
            default:
              return String.fromCharCode(charCode);
          }
        } catch (e) {
          print('Erro ao decodificar hex ${match.group(1)}: $e');
          return match.group(0)!;
        }
      });
      
      // 3. Limpar caracteres problemáticos que sobram
      text = text
          .replaceAll('Â', '') // Remove caracteres Â problemáticos
          .replaceAll(RegExp(r'\x{C2}'), '') // Remove prefixos UTF-8 problemáticos
          .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '') // Remove caracteres de controle
          .replaceAll(RegExp(r'\r\n'), '\n') // Normalizar quebras de linha
          .replaceAll(RegExp(r'\r'), '\n'); // Normalizar quebras de linha
      
      // 4. Normalizar espaços múltiplos mas preservar quebras de linha intencionais
      final normalizedLines = text.split('\n').map((line) {
        return line.replaceAll(RegExp(r'[ \t]+'), ' ').trim();
      }).toList();
      
      text = normalizedLines.join('\n');
      
      // 5. Remover linhas vazias excessivas (mais de 2 seguidas)
      text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
      
      print('Após decodificação: ${text.length > 200 ? text.substring(0, 200) : text}...');
      
      return text.trim();
    } catch (e) {
      print('Erro ao decodificar quoted-printable: $e');
      return 'Erro ao decodificar quoted-printable: $e';
    }
  }

  /// Limpar texto simples
  String _cleanPlainTextBody(String body) {
    final lines = body.split('\n');
    final textLines = <String>[];
    
    bool foundBody = false;
    bool skipHeaders = true;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // Pular headers MIME e boundaries
      if (skipHeaders && (line.startsWith('Content-') || 
          line.startsWith('MIME-Version') ||
          line.startsWith('--') ||
          line.contains('Content-Type:') ||
          line.contains('Content-Transfer-Encoding:'))) {
        continue;
      }
      
      // Primeira linha vazia indica fim dos headers
      if (trimmedLine.isEmpty && !foundBody) {
        foundBody = true;
        skipHeaders = false;
        continue;
      }
      
      // Se já encontrou o corpo ou a linha não parece ser header
      if (foundBody || (!line.contains(':') || line.contains(' '))) {
        // Não adicionar linhas que são claramente boundaries ou headers perdidos
        if (!trimmedLine.startsWith('--') && 
            !trimmedLine.startsWith('Content-') &&
            !trimmedLine.startsWith('MIME-Version')) {
          textLines.add(line);
        }
      }
    }
    
    final result = textLines.join('\n').trim();
    
    // Se não encontrou nada, tentar extrair qualquer texto útil
    if (result.isEmpty) {
      final allLines = body.split('\n');
      final contentLines = <String>[];
      
      for (final line in allLines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty && 
            !trimmed.startsWith('--') &&
            !trimmed.startsWith('Content-') &&
            !trimmed.startsWith('MIME-Version') &&
            !trimmed.contains('boundary=') &&
            trimmed.length > 3) {
          contentLines.add(line);
        }
      }
      
      final fallbackResult = contentLines.join('\n').trim();
      return fallbackResult.isEmpty ? 'Conteúdo de texto não encontrado' : fallbackResult;
    }
    
    return result;
  }

  /// Extrair texto de HTML (conversão melhorada)
  String _extractTextFromHtml(String html) {
    try {
      print('Extraindo texto de HTML...');
      print('HTML original: ${html.length > 300 ? html.substring(0, 300) : html}...');
      
      String text = html;
      
      // 1. Remover comentários HTML
      text = text.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
      
      // 2. Remover scripts e estilos
      text = text.replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true), '');
      text = text.replaceAll(RegExp(r'<style[^>]*>.*?</style>', caseSensitive: false, dotAll: true), '');
      
      // 3. Converter elementos de bloco em quebras de linha
      final blockElements = ['div', 'p', 'br', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'li', 'tr', 'td', 'th'];
      for (final element in blockElements) {
        text = text.replaceAll(RegExp('</$element>', caseSensitive: false), '\n');
        text = text.replaceAll(RegExp('<$element[^>]*>', caseSensitive: false), '\n');
      }
      
      // 4. Remover todas as outras tags HTML
      text = text.replaceAll(RegExp(r'<[^>]+>'), ' ');
      
      // 5. Decodificar entidades HTML comuns
      final htmlEntities = {
        '&nbsp;': ' ',
        '&amp;': '&',
        '&lt;': '<',
        '&gt;': '>',
        '&quot;': '"',
        '&#39;': "'",
        '&apos;': "'",
        '&copy;': '©',
        '&reg;': '®',
        '&trade;': '™',
        '&euro;': '€',
        '&pound;': '£',
        '&yen;': '¥',
        '&sect;': '§',
        '&para;': '¶',
        '&middot;': '·',
        '&bull;': '•',
        '&hellip;': '...',
        '&ndash;': '–',
        '&mdash;': '—',
        '&lsquo;': ''',
        '&rsquo;': ''',
        '&ldquo;': '"',
        '&rdquo;': '"',
      };
      
      for (final entity in htmlEntities.entries) {
        text = text.replaceAll(entity.key, entity.value);
      }
      
      // 6. Decodificar entidades numéricas (&#123; ou &#x1F;)
      text = text.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
        try {
          final charCode = int.parse(match.group(1)!);
          return String.fromCharCode(charCode);
        } catch (e) {
          return match.group(0)!;
        }
      });
      
      text = text.replaceAllMapped(RegExp(r'&#x([0-9A-Fa-f]+);'), (match) {
        try {
          final charCode = int.parse(match.group(1)!, radix: 16);
          return String.fromCharCode(charCode);
        } catch (e) {
          return match.group(0)!;
        }
      });
      
      // 7. Normalizar espaços e quebras de linha
      final lines = text.split('\n')
          .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
          .where((line) => line.isNotEmpty)
          .toList();
      
      text = lines.join('\n');
      
      // 8. Limpar quebras de linha excessivas
      text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
      
      print('Texto extraído: ${text.length > 300 ? text.substring(0, 300) : text}...');
      
      return text.trim();
    } catch (e) {
      print('Erro ao extrair texto do HTML: $e');
      return 'Erro ao extrair texto do HTML: $e';
    }
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