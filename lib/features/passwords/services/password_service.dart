import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/password_entry.dart';

class PasswordService {
  static const String _boxName = 'passwords';
  static const String _foldersBoxName = 'password_folders';
  static const String _masterKey = 'master_password_hash';
  static const String _settingsKey = 'password_settings';

  static final PasswordService _instance = PasswordService._internal();
  factory PasswordService() => _instance;
  PasswordService._internal();

  late Box<dynamic> _passwordsBox;
  late Box<dynamic> _foldersBox;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Uuid _uuid = const Uuid();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _passwordsBox = await Hive.openBox(_boxName);
      _foldersBox = await Hive.openBox(_foldersBoxName);
      _isInitialized = true;
    } catch (e) {
      throw Exception('Erro ao inicializar PasswordService: $e');
    }
  }

  // Geração de senhas seguras
  String generatePassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
    bool excludeSimilar = true,
  }) {
    const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    const String similar = 'il1Lo0O';

    String chars = '';
    if (includeUppercase) chars += uppercase;
    if (includeLowercase) chars += lowercase;
    if (includeNumbers) chars += numbers;
    if (includeSymbols) chars += symbols;

    if (chars.isEmpty) {
      chars = lowercase + numbers;
    }

    if (excludeSimilar) {
      chars = chars.replaceAll(RegExp('[$similar]'), '');
    }

    final random = Random.secure();
    String password = '';

    // Garantir pelo menos um caractere de cada tipo selecionado
    if (includeUppercase)
      password += uppercase[random.nextInt(uppercase.length)];
    if (includeLowercase)
      password += lowercase[random.nextInt(lowercase.length)];
    if (includeNumbers) password += numbers[random.nextInt(numbers.length)];
    if (includeSymbols) password += symbols[random.nextInt(symbols.length)];

    // Completar o resto da senha
    while (password.length < length) {
      password += chars[random.nextInt(chars.length)];
    }

    // Embaralhar a senha
    final passwordChars = password.split('');
    passwordChars.shuffle(random);
    return passwordChars.join();
  }

  // Validação de força da senha
  PasswordStrength validatePasswordStrength(String password) {
    int score = 0;

    if (password.length >= 8) score += 1;
    if (password.length >= 12) score += 1;
    if (password.contains(RegExp(r'[a-z]'))) score += 1;
    if (password.contains(RegExp(r'[A-Z]'))) score += 1;
    if (password.contains(RegExp(r'[0-9]'))) score += 1;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 1;

    // Penalizar padrões comuns
    if (password.contains(RegExp(r'(.)\1{2,}')))
      score -= 1; // Caracteres repetidos
    if (password.contains(RegExp(r'(123|abc|qwe|asd|zxc)')))
      score -= 1; // Sequências comuns

    switch (score) {
      case 0:
      case 1:
        return PasswordStrength.veryWeak;
      case 2:
        return PasswordStrength.weak;
      case 3:
        return PasswordStrength.medium;
      case 4:
        return PasswordStrength.strong;
      default:
        return PasswordStrength.veryStrong;
    }
  }

  // CRUD Operations
  Future<List<PasswordEntry>> getAllPasswords() async {
    await _ensureInitialized();
    final List<PasswordEntry> passwords = [];

    for (final key in _passwordsBox.keys) {
      final data = _passwordsBox.get(key);
      if (data != null) {
        try {
          final entry = PasswordEntry.fromJson(Map<String, dynamic>.from(data));
          passwords.add(entry);
        } catch (e) {
          // Ignorar entradas corrompidas
          continue;
        }
      }
    }

    return passwords..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<PasswordEntry?> getPasswordById(String id) async {
    await _ensureInitialized();
    final data = _passwordsBox.get(id);
    if (data != null) {
      return PasswordEntry.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  Future<String> createPassword(PasswordEntry entry) async {
    await _ensureInitialized();

    final now = DateTime.now();
    final newEntry = entry.copyWith(
      id: _uuid.v4(),
      createdAt: now,
      updatedAt: now,
      strength: validatePasswordStrength(entry.password),
    );

    await _passwordsBox.put(newEntry.id, newEntry.toJson());
    return newEntry.id;
  }

  Future<void> updatePassword(PasswordEntry entry) async {
    await _ensureInitialized();

    final updatedEntry = entry.copyWith(
      updatedAt: DateTime.now(),
      strength: validatePasswordStrength(entry.password),
    );

    await _passwordsBox.put(updatedEntry.id, updatedEntry.toJson());
  }

  Future<void> deletePassword(String id) async {
    await _ensureInitialized();
    await _passwordsBox.delete(id);
  }

  Future<void> deleteMultiplePasswords(List<String> ids) async {
    await _ensureInitialized();
    for (final id in ids) {
      await _passwordsBox.delete(id);
    }
  }

  // Busca e filtros
  Future<List<PasswordEntry>> searchPasswords(String query) async {
    final allPasswords = await getAllPasswords();
    final lowercaseQuery = query.toLowerCase();

    return allPasswords.where((entry) {
      return entry.title.toLowerCase().contains(lowercaseQuery) ||
          entry.username.toLowerCase().contains(lowercaseQuery) ||
          entry.website?.toLowerCase().contains(lowercaseQuery) == true ||
          entry.notes?.toLowerCase().contains(lowercaseQuery) == true ||
          entry.category?.toLowerCase().contains(lowercaseQuery) == true ||
          entry.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  Future<List<PasswordEntry>> getPasswordsByCategory(String category) async {
    final allPasswords = await getAllPasswords();
    return allPasswords.where((entry) => entry.category == category).toList();
  }

  Future<List<PasswordEntry>> getPasswordsByFolder(String folderId) async {
    final allPasswords = await getAllPasswords();
    return allPasswords.where((entry) => entry.folderId == folderId).toList();
  }

  Future<List<PasswordEntry>> getFavoritePasswords() async {
    final allPasswords = await getAllPasswords();
    return allPasswords.where((entry) => entry.isFavorite).toList();
  }

  Future<List<PasswordEntry>> getExpiredPasswords() async {
    final allPasswords = await getAllPasswords();
    return allPasswords.where((entry) => entry.isExpired).toList();
  }

  Future<List<PasswordEntry>> getExpiringSoonPasswords() async {
    final allPasswords = await getAllPasswords();
    return allPasswords.where((entry) => entry.isExpiringSoon).toList();
  }

  Future<List<PasswordEntry>> getWeakPasswords() async {
    final allPasswords = await getAllPasswords();
    return allPasswords
        .where((entry) =>
            entry.strength == PasswordStrength.veryWeak ||
            entry.strength == PasswordStrength.weak)
        .toList();
  }

  // Estatísticas
  Future<Map<String, dynamic>> getPasswordStats() async {
    final allPasswords = await getAllPasswords();

    final total = allPasswords.length;
    final favorites = allPasswords.where((p) => p.isFavorite).length;
    final expired = allPasswords.where((p) => p.isExpired).length;
    final expiringSoon = allPasswords.where((p) => p.isExpiringSoon).length;
    final weak = allPasswords
        .where((p) =>
            p.strength == PasswordStrength.veryWeak ||
            p.strength == PasswordStrength.weak)
        .length;

    final categories = <String, int>{};
    for (final entry in allPasswords) {
      final category = entry.category ?? 'Sem categoria';
      categories[category] = (categories[category] ?? 0) + 1;
    }

    return {
      'total': total,
      'favorites': favorites,
      'expired': expired,
      'expiringSoon': expiringSoon,
      'weak': weak,
      'categories': categories,
    };
  }

  // Gestão de pastas
  Future<List<PasswordFolder>> getAllFolders() async {
    await _ensureInitialized();
    final List<PasswordFolder> folders = [];

    for (final key in _foldersBox.keys) {
      final data = _foldersBox.get(key);
      if (data != null) {
        try {
          final folder =
              PasswordFolder.fromJson(Map<String, dynamic>.from(data));
          folders.add(folder);
        } catch (e) {
          continue;
        }
      }
    }

    return folders..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<String> createFolder(PasswordFolder folder) async {
    await _ensureInitialized();

    final now = DateTime.now();
    final newFolder = folder.copyWith(
      id: _uuid.v4(),
      createdAt: now,
      updatedAt: now,
    );

    await _foldersBox.put(newFolder.id, newFolder.toJson());
    return newFolder.id;
  }

  Future<void> updateFolder(PasswordFolder folder) async {
    await _ensureInitialized();

    final updatedFolder = folder.copyWith(updatedAt: DateTime.now());
    await _foldersBox.put(updatedFolder.id, updatedFolder.toJson());
  }

  Future<void> deleteFolder(String folderId) async {
    await _ensureInitialized();

    // Mover todas as entradas para fora da pasta
    final passwords = await getPasswordsByFolder(folderId);
    for (final password in passwords) {
      await updatePassword(password.copyWith(folderId: null));
    }

    await _foldersBox.delete(folderId);
  }

  // Backup e exportação
  Future<Map<String, dynamic>> exportPasswords() async {
    final passwords = await getAllPasswords();
    final folders = await getAllFolders();

    return {
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'passwords': passwords.map((p) => p.toJson()).toList(),
      'folders': folders.map((f) => f.toJson()).toList(),
    };
  }

  Future<void> importPasswords(Map<String, dynamic> data) async {
    await _ensureInitialized();

    // Importar pastas primeiro
    if (data['folders'] != null) {
      for (final folderData in data['folders']) {
        try {
          final folder = PasswordFolder.fromJson(folderData);
          await _foldersBox.put(folder.id, folder.toJson());
        } catch (e) {
          // Ignorar pastas corrompidas
          continue;
        }
      }
    }

    // Importar senhas
    if (data['passwords'] != null) {
      for (final passwordData in data['passwords']) {
        try {
          final password = PasswordEntry.fromJson(passwordData);
          await _passwordsBox.put(password.id, password.toJson());
        } catch (e) {
          // Ignorar senhas corrompidas
          continue;
        }
      }
    }
  }

  // Utilitários
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<void> clearAllData() async {
    await _ensureInitialized();
    await _passwordsBox.clear();
    await _foldersBox.clear();
  }

  Future<void> close() async {
    if (_isInitialized) {
      await _passwordsBox.close();
      await _foldersBox.close();
      _isInitialized = false;
    }
  }
}
