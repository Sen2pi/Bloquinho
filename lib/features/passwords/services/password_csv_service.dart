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
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/password_entry.dart';
import 'password_encryption_service.dart';
import 'password_service.dart';

class PasswordCsvService {
  static const String _csvFileName = 'bloquinho_passwords_export.csv';
  
  /// Colunas padrão do NordPass
  static const List<String> _nordpassColumns = [
    'name',
    'url',
    'username',
    'password',
    'note',
    'cardholdername',
    'cardnumber',
    'cvc',
    'expirydate',
    'zipcode',
    'folder',
    'full_name',
    'phone_number',
    'email',
    'address1',
    'address2',
    'city',
    'state',
    'country',
    'company',
    'type',
  ];

  /// Exportar passwords para CSV no formato NordPass
  static Future<String> exportToCsv(List<PasswordEntry> passwords) async {
    try {
      // Criar dados CSV
      final csvData = <List<String>>[];
      
      // Adicionar header
      csvData.add(_nordpassColumns);
      
      // Adicionar dados das passwords
      for (final password in passwords) {
        csvData.add([
          password.title,                           // name
          password.website ?? '',                   // url
          password.username,                        // username
          password.password,                        // password
          password.notes ?? '',                     // note
          '',                                       // cardholdername
          '',                                       // cardnumber
          '',                                       // cvc
          '',                                       // expirydate
          '',                                       // zipcode
          password.category ?? '',                  // folder
          '',                                       // full_name
          '',                                       // phone_number
          '',                                       // email
          '',                                       // address1
          '',                                       // address2
          '',                                       // city
          '',                                       // state
          '',                                       // country
          '',                                       // company
          'login',                                  // type
        ]);
      }
      
      // Converter para CSV
      final csv = const ListToCsvConverter().convert(csvData);
      
      // Salvar arquivo
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_csvFileName');
      await file.writeAsString(csv, encoding: utf8);
      
      return file.path;
    } catch (e) {
      throw Exception('Erro ao exportar CSV: $e');
    }
  }

  /// Importar passwords de CSV no formato NordPass
  static Future<List<PasswordEntry>> importFromCsv() async {
    try {
      // Selecionar arquivo
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) {
        throw Exception('Nenhum arquivo selecionado');
      }
      
      final file = File(result.files.first.path!);
      if (!await file.exists()) {
        throw Exception('Arquivo não encontrado');
      }
      
      // Ler conteúdo do arquivo com diferentes encodings
      String content;
      try {
        content = await file.readAsString(encoding: utf8);
      } catch (e) {
        // Tentar com latin1 se UTF-8 falhar
        try {
          content = await file.readAsString(encoding: latin1);
          print('DEBUG CSV - Usando encoding latin1');
        } catch (e2) {
          throw Exception('Erro ao ler arquivo: encoding não suportado');
        }
      }
      
      // Detectar separador do CSV
      final separator = _detectCsvSeparator(content);
      print('DEBUG CSV - Separador detectado: "$separator"');
      
      final csvData = CsvToListConverter(
        fieldDelimiter: separator,
        shouldParseNumbers: false,
      ).convert(content);
      
      if (csvData.isEmpty) {
        throw Exception('Arquivo CSV vazio');
      }
      
      // Debug: Imprimir header
      print('DEBUG CSV - Header encontrado: ${csvData.first}');
      
      // Obter header
      final header = csvData.first.map((e) => e.toString().toLowerCase()).toList();
      print('DEBUG CSV - Header normalizado: $header');
      
      // Mapear colunas do NordPass - versão mais flexível
      final nameIndex = _findColumnIndex(header, [
        'name', 'title', 'item name', 'nome', 'site name', 'service'
      ]);
      final urlIndex = _findColumnIndex(header, [
        'url', 'website', 'site', 'domain', 'web site', 'link'
      ]);
      final usernameIndex = _findColumnIndex(header, [
        'username', 'login', 'user', 'email', 'login name', 'account'
      ]);
      final passwordIndex = _findColumnIndex(header, [
        'password', 'pass', 'senha', 'secret', 'passphrase'
      ]);
      final noteIndex = _findColumnIndex(header, [
        'note', 'notes', 'notas', 'comment', 'comments', 'memo', 'description'
      ]);
      final folderIndex = _findColumnIndex(header, [
        'folder', 'category', 'categoria', 'group', 'grouping'
      ]);
      final typeIndex = _findColumnIndex(header, [
        'type', 'tipo', 'item type', 'record type'
      ]);
      
      print('DEBUG CSV - Índices encontrados:');
      print('  Name: $nameIndex');
      print('  URL: $urlIndex');
      print('  Username: $usernameIndex');
      print('  Password: $passwordIndex');
      print('  Note: $noteIndex');
      print('  Folder: $folderIndex');
      print('  Type: $typeIndex');
      
      // Converter dados
      final passwords = <PasswordEntry>[];
      final now = DateTime.now();
      final passwordService = PasswordService();
      
      int totalRows = 0;
      int validRows = 0;
      int skippedRows = 0;
      
      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        totalRows++;
        
        try {
          // Extrair dados básicos
          final name = _getValueAt(row, nameIndex).trim();
          final username = _getValueAt(row, usernameIndex).trim();
          final password = _getValueAt(row, passwordIndex).trim();
          final type = _getValueAt(row, typeIndex).trim();
          
          print('DEBUG CSV - Linha $i: name="$name", username="$username", password="${password.isNotEmpty ? '[SENHA]' : 'VAZIO'}", type="$type"');
          
          // Verificar se tem pelo menos nome e senha (username pode ser email no website)
          if (name.isEmpty || password.isEmpty) {
            print('DEBUG CSV - Linha $i pulada: nome ou senha vazio');
            skippedRows++;
            continue;
          }
          
          // Se tipo está especificado, aceitar apenas login/password
          if (type.isNotEmpty) {
            final normalizedType = type.toLowerCase();
            if (normalizedType != 'login' && normalizedType != 'password' && normalizedType != 'senha') {
              print('DEBUG CSV - Linha $i pulada: tipo não é login ($type)');
              skippedRows++;
              continue;
            }
          }
          
          // Usar nome como username se username estiver vazio
          final finalUsername = username.isEmpty ? name : username;
          
          // Criar entrada
          final categoryValue = _getValueAt(row, folderIndex).trim();
          final entry = PasswordEntry(
            id: '', // Será gerado pelo serviço
            title: name,
            username: finalUsername,
            password: password,
            website: _getValueAt(row, urlIndex).trim(),
            notes: _getValueAt(row, noteIndex).trim(),
            category: categoryValue.isEmpty ? 'Social' : categoryValue, // Categoria padrão "Social"
            tags: [],
            createdAt: now,
            updatedAt: now,
            isFavorite: false,
            isArchived: false,
            strength: passwordService.validatePasswordStrength(password),
          );
          
          passwords.add(entry);
          validRows++;
          print('DEBUG CSV - Entrada criada: ${entry.title}');
        } catch (e) {
          print('DEBUG CSV - Erro na linha $i: $e');
          skippedRows++;
          continue;
        }
      }
      
      print('DEBUG CSV - Resultado final:');
      print('  Total de linhas: $totalRows');
      print('  Linhas válidas: $validRows');
      print('  Linhas puladas: $skippedRows');
      print('  Senhas importadas: ${passwords.length}');
      
      // Se não encontrou nenhuma senha, dar sugestões
      if (passwords.isEmpty && totalRows > 0) {
        final suggestions = <String>[];
        
        if (nameIndex == -1) {
          suggestions.add('Coluna de nome não encontrada. Colunas esperadas: name, title, item name, nome, site name, service');
        }
        if (passwordIndex == -1) {
          suggestions.add('Coluna de senha não encontrada. Colunas esperadas: password, pass, senha, secret, passphrase');
        }
        if (usernameIndex == -1) {
          suggestions.add('Coluna de usuário não encontrada. Colunas esperadas: username, login, user, email, login name, account');
        }
        
        if (suggestions.isNotEmpty) {
          final errorMsg = 'Formato do CSV não reconhecido:\n${suggestions.join('\n')}\n\nHeader encontrado: $header';
          throw Exception(errorMsg);
        }
      }
      
      return passwords;
    } catch (e) {
      print('DEBUG CSV - Erro geral: $e');
      throw Exception('Erro ao importar CSV: $e');
    }
  }

  /// Encontrar índice da coluna no header
  static int _findColumnIndex(List<String> header, List<String> possibleNames) {
    for (final name in possibleNames) {
      final index = header.indexOf(name.toLowerCase());
      if (index != -1) return index;
    }
    return -1;
  }

  /// Obter valor seguro do array
  static String _getValueAt(List<dynamic> row, int index) {
    if (index == -1 || index >= row.length) return '';
    return row[index]?.toString() ?? '';
  }

  /// Detectar separador do CSV
  static String _detectCsvSeparator(String content) {
    // Analisar as primeiras linhas para detectar o separador
    final lines = content.split('\n').take(3).toList();
    if (lines.isEmpty) return ',';
    
    final separators = [',', ';', '\t', '|'];
    final separatorCounts = <String, int>{};
    
    for (final separator in separators) {
      int count = 0;
      for (final line in lines) {
        if (line.trim().isNotEmpty) {
          count += line.split(separator).length;
        }
      }
      separatorCounts[separator] = count;
    }
    
    // Retornar o separador mais comum
    final mostCommon = separatorCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    return mostCommon.key;
  }

  /// Exportar para Downloads (Android/iOS)
  static Future<String> exportToDownloads(List<PasswordEntry> passwords) async {
    try {
      // Solicitar permissão
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Permissão de armazenamento negada');
        }
      }
      
      // Criar dados CSV
      final csvData = <List<String>>[];
      csvData.add(_nordpassColumns);
      
      for (final password in passwords) {
        csvData.add([
          password.title,
          password.website ?? '',
          password.username,
          password.password,
          password.notes ?? '',
          '', '', '', '', '', // campos de cartão
          password.category ?? '',
          '', '', '', '', '', '', '', '', '', // campos de contato
          'login',
        ]);
      }
      
      final csv = const ListToCsvConverter().convert(csvData);
      
      // Salvar em Downloads
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      } else {
        downloadsDir = await getDownloadsDirectory();
      }
      
      if (downloadsDir == null) {
        throw Exception('Não foi possível acessar a pasta de downloads');
      }
      
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final fileName = 'bloquinho_passwords_$timestamp.csv';
      final file = File('${downloadsDir.path}/$fileName');
      
      await file.writeAsString(csv, encoding: utf8);
      
      return file.path;
    } catch (e) {
      throw Exception('Erro ao exportar para Downloads: $e');
    }
  }

  /// Validar formato do CSV
  static Future<bool> validateCsvFormat(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString(encoding: utf8);
      final csvData = const CsvToListConverter().convert(content);
      
      if (csvData.isEmpty) return false;
      
      final header = csvData.first.map((e) => e.toString().toLowerCase()).toList();
      
      // Verificar se tem pelo menos as colunas essenciais
      final hasName = header.any((col) => ['name', 'title'].contains(col));
      final hasUsername = header.any((col) => ['username', 'login'].contains(col));
      final hasPassword = header.any((col) => ['password'].contains(col));
      
      return hasName && hasUsername && hasPassword;
    } catch (e) {
      return false;
    }
  }

  /// Obter estatísticas do arquivo CSV
  static Future<Map<String, dynamic>> getCsvStats(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString(encoding: utf8);
      final csvData = const CsvToListConverter().convert(content);
      
      if (csvData.isEmpty) {
        return {'total': 0, 'valid': 0, 'invalid': 0};
      }
      
      final header = csvData.first.map((e) => e.toString().toLowerCase()).toList();
      final nameIndex = _findColumnIndex(header, ['name', 'title']);
      final usernameIndex = _findColumnIndex(header, ['username', 'login']);
      final passwordIndex = _findColumnIndex(header, ['password']);
      
      int valid = 0;
      int invalid = 0;
      
      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        final name = _getValueAt(row, nameIndex);
        final username = _getValueAt(row, usernameIndex);
        final password = _getValueAt(row, passwordIndex);
        
        if (name.isNotEmpty && username.isNotEmpty && password.isNotEmpty) {
          valid++;
        } else {
          invalid++;
        }
      }
      
      return {
        'total': csvData.length - 1, // Excluindo header
        'valid': valid,
        'invalid': invalid,
        'columns': header.length,
      };
    } catch (e) {
      throw Exception('Erro ao analisar CSV: $e');
    }
  }
}