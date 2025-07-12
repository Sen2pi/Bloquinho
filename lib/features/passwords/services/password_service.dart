import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:uuid/uuid.dart';
import 'package:bloquinho/core/services/workspace_storage_service.dart';
import 'package:bloquinho/core/services/data_directory_service.dart';

import '../models/password_entry.dart';

class PasswordService {
  static const String _boxName = 'passwords';
  static const String _foldersBoxName = 'password_folders';
  static const String _masterKey = 'master_password_hash';
  static const String _settingsKey = 'password_settings';
  static const String _vaultsKey = 'password_vaults';
  static const String _breachDataKey = 'breach_data';

  static final PasswordService _instance = PasswordService._internal();
  factory PasswordService() => _instance;
  PasswordService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Uuid _uuid = const Uuid();
  final WorkspaceStorageService _workspaceStorage = WorkspaceStorageService();

  bool _isInitialized = false;
  String? _currentWorkspaceId;
  String? _currentProfileName;

  // NOVOS CAMPOS PARA FUNCIONALIDADES AVANÇADAS
  final Map<String, List<String>> _breachDatabase = {};
  final Map<String, String> _vaults = {};
  final Map<String, dynamic> _securitySettings = {};

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _workspaceStorage.initialize();
      await _loadBreachDatabase();
      await _loadVaults();
      await _loadSecuritySettings();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Erro ao inicializar PasswordService: $e');
    }
  }

  /// Definir workspace atual
  Future<void> setCurrentWorkspace(String workspaceId) async {
    await _ensureInitialized();

    if (_currentWorkspaceId != workspaceId) {
      _currentWorkspaceId = workspaceId;

      // Definir contexto no WorkspaceStorageService se temos perfil
      if (_currentProfileName != null) {
        await _workspaceStorage.setContext(_currentProfileName!, workspaceId);
      }
    }
  }

  /// Definir perfil atual
  Future<void> setCurrentProfile(String profileName) async {
    await _ensureInitialized();

    if (_currentProfileName != profileName) {
      _currentProfileName = profileName;

      // Definir contexto no WorkspaceStorageService se temos workspace
      if (_currentWorkspaceId != null) {
        await _workspaceStorage.setContext(profileName, _currentWorkspaceId!);
      }
    }
  }

  /// Definir contexto completo (perfil + workspace)
  Future<void> setContext(String profileName, String workspaceId) async {
    await _ensureInitialized();

    final previousContext = '$_currentProfileName/$_currentWorkspaceId';
    final newContext = '$profileName/$workspaceId';

    if (previousContext != newContext) {
      _currentProfileName = profileName;
      _currentWorkspaceId = workspaceId;

      // Definir contexto no WorkspaceStorageService
      await _workspaceStorage.setContext(profileName, workspaceId);
    }
  }

  /// Obter workspace atual
  String? get currentWorkspaceId => _currentWorkspaceId;

  /// Obter perfil atual
  String? get currentProfileName => _currentProfileName;

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

  // NOVAS FUNCIONALIDADES AVANÇADAS

  /// Verificar se uma senha foi comprometida
  Future<bool> checkPasswordBreach(String password) async {
    await _ensureInitialized();

    // Simular verificação de violação (em produção, seria uma API real)
    final hash = sha256.convert(utf8.encode(password)).toString();
    return _breachDatabase.containsKey(hash);
  }

  /// Verificar se uma senha é reutilizada
  Future<bool> checkPasswordReuse(String password, String excludeId) async {
    await _ensureInitialized();

    final allPasswords = await getAllPasswords();
    return allPasswords
        .any((entry) => entry.id != excludeId && entry.password == password);
  }

  /// Adicionar senha ao histórico
  Future<void> addToPasswordHistory(
      PasswordEntry entry, String oldPassword) async {
    await _ensureInitialized();

    final history = PasswordHistory(
      password: oldPassword,
      changedAt: DateTime.now(),
      reason: 'Senha alterada',
    );

    final updatedEntry = entry.copyWith(
      passwordHistory: [
        history,
        ...entry.passwordHistory.take(4)
      ], // Manter apenas 5 últimas
      lastPasswordChange: DateTime.now(),
    );

    await updatePassword(updatedEntry);
  }

  /// Gerar código 2FA
  String generateTwoFactorSecret() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final random = Random.secure();
    return List.generate(16, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// Verificar código 2FA
  bool verifyTwoFactorCode(String secret, String code) {
    // Implementação simplificada de TOTP
    // Em produção, usar biblioteca TOTP real
    if (code.length != 6) return false;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 30000; // 30 segundos
    final expectedCode = _generateTOTP(secret, now);
    return code == expectedCode;
  }

  String _generateTOTP(String secret, int time) {
    // Implementação simplificada
    final hash = sha256.convert(utf8.encode('$secret$time')).toString();
    return hash.substring(0, 6).toUpperCase();
  }

  /// Criar vault seguro
  Future<String> createVault(String name, String description) async {
    await _ensureInitialized();

    final vaultId = _uuid.v4();
    final vault = {
      'id': vaultId,
      'name': name,
      'description': description,
      'createdAt': DateTime.now().toIso8601String(),
      'entryCount': 0,
    };

    _vaults[vaultId] = jsonEncode(vault);
    await _saveVaults();

    return vaultId;
  }

  /// Mover entrada para vault
  Future<void> moveToVault(PasswordEntry entry, String vaultId) async {
    await _ensureInitialized();

    final updatedEntry = entry.copyWith(
      vaultId: vaultId,
      isInVault: true,
      vaultName: _getVaultName(vaultId),
    );

    await updatePassword(updatedEntry);
  }

  String? _getVaultName(String vaultId) {
    try {
      final vaultData = jsonDecode(_vaults[vaultId] ?? '{}');
      return vaultData['name'];
    } catch (e) {
      return null;
    }
  }

  /// Configurar acesso de emergência
  Future<void> setupEmergencyAccess(
      PasswordEntry entry, String contactEmail, int days) async {
    await _ensureInitialized();

    final updatedEntry = entry.copyWith(
      isEmergencyAccess: true,
      emergencyContact: contactEmail,
      emergencyExpiry: DateTime.now().add(Duration(days: days)),
    );

    await updatePassword(updatedEntry);
  }

  /// Verificar acesso de emergência
  Future<bool> checkEmergencyAccess(PasswordEntry entry) async {
    if (!entry.isEmergencyAccess || entry.emergencyExpiry == null) {
      return false;
    }

    return DateTime.now().isBefore(entry.emergencyExpiry!);
  }

  /// Analisar segurança geral
  Future<Map<String, dynamic>> analyzeSecurity() async {
    await _ensureInitialized();

    final allPasswords = await getAllPasswords();
    final analysis = {
      'total': allPasswords.length,
      'compromised': 0,
      'reused': 0,
      'weak': 0,
      'old': 0,
      'with2FA': 0,
      'inVault': 0,
      'expired': 0,
      'expiringSoon': 0,
    };

    for (final entry in allPasswords) {
      if (entry.isCompromised)
        analysis['compromised'] = (analysis['compromised'] as int) + 1;
      if (entry.isReused) analysis['reused'] = (analysis['reused'] as int) + 1;
      if (entry.strength == PasswordStrength.veryWeak ||
          entry.strength == PasswordStrength.weak) {
        analysis['weak'] = (analysis['weak'] as int) + 1;
      }
      if (entry.isOldPassword) analysis['old'] = (analysis['old'] as int) + 1;
      if (entry.hasTwoFactor)
        analysis['with2FA'] = (analysis['with2FA'] as int) + 1;
      if (entry.isInSecureVault)
        analysis['inVault'] = (analysis['inVault'] as int) + 1;
      if (entry.isExpired)
        analysis['expired'] = (analysis['expired'] as int) + 1;
      if (entry.isExpiringSoon)
        analysis['expiringSoon'] = (analysis['expiringSoon'] as int) + 1;
    }

    return analysis;
  }

  /// Sugerir melhorias de segurança
  Future<List<String>> suggestSecurityImprovements(PasswordEntry entry) async {
    final suggestions = <String>[];

    if (entry.strength == PasswordStrength.veryWeak ||
        entry.strength == PasswordStrength.weak) {
      suggestions
          .add('Sua senha é muito fraca. Considere usar uma senha mais forte.');
    }

    if (entry.isOldPassword) {
      suggestions.add(
          'Sua senha não foi alterada há mais de 90 dias. Considere alterá-la.');
    }

    if (entry.isReused) {
      suggestions.add(
          'Esta senha está sendo reutilizada em outras contas. Use senhas únicas.');
    }

    if (entry.isBreached) {
      suggestions.add(
          'Esta senha foi comprometida em uma violação de dados. Altere imediatamente.');
    }

    if (!entry.hasTwoFactor) {
      suggestions
          .add('Ative a autenticação de dois fatores para maior segurança.');
    }

    if (!entry.isInSecureVault) {
      suggestions.add('Considere mover esta entrada para um vault seguro.');
    }

    if (entry.expiresAt != null && entry.isExpired) {
      suggestions.add('Esta senha expirou. Altere-a imediatamente.');
    }

    return suggestions;
  }

  /// Carregar banco de dados de violações (simulado)
  Future<void> _loadBreachDatabase() async {
    // Em produção, isso seria carregado de uma API real
    _breachDatabase.clear();

    // Simular algumas senhas comprometidas conhecidas
    final commonPasswords = [
      'password',
      '123456',
      'qwerty',
      'admin',
      'letmein',
    ];

    for (final password in commonPasswords) {
      final hash = sha256.convert(utf8.encode(password)).toString();
      _breachDatabase[hash] = ['Simulação de violação'];
    }
  }

  /// Carregar vaults
  Future<void> _loadVaults() async {
    try {
      final vaultsData = await _secureStorage.read(key: _vaultsKey);
      if (vaultsData != null) {
        final vaults = jsonDecode(vaultsData) as Map<String, dynamic>;
        _vaults.clear();
        vaults.forEach((key, value) => _vaults[key] = value.toString());
      }
    } catch (e) {
      debugPrint('Erro ao carregar vaults: $e');
    }
  }

  /// Salvar vaults
  Future<void> _saveVaults() async {
    try {
      await _secureStorage.write(key: _vaultsKey, value: jsonEncode(_vaults));
    } catch (e) {
      debugPrint('Erro ao salvar vaults: $e');
    }
  }

  /// Carregar configurações de segurança
  Future<void> _loadSecuritySettings() async {
    try {
      final settingsData = await _secureStorage.read(key: _settingsKey);
      if (settingsData != null) {
        _securitySettings.clear();
        _securitySettings
            .addAll(jsonDecode(settingsData) as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Erro ao carregar configurações de segurança: $e');
    }
  }

  /// Salvar configurações de segurança
  Future<void> _saveSecuritySettings() async {
    try {
      await _secureStorage.write(
          key: _settingsKey, value: jsonEncode(_securitySettings));
    } catch (e) {
      debugPrint('Erro ao salvar configurações de segurança: $e');
    }
  }

  // CRUD Operations
  Future<List<PasswordEntry>> getAllPasswords() async {
    await _ensureInitialized();

    if (_currentWorkspaceId == null) {
      return [];
    }

    final List<PasswordEntry> passwords = [];

    // Carregar do workspace storage primeiro
    final workspaceData =
        await _workspaceStorage.loadWorkspaceData('passwords');
    if (workspaceData != null) {
      final passwordsData = workspaceData['passwords'] as List<dynamic>? ?? [];
      for (final data in passwordsData) {
        try {
          final entry = PasswordEntry.fromJson(Map<String, dynamic>.from(data));
          passwords.add(entry);
        } catch (e) {
          continue;
        }
      }
    }

    return passwords..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<PasswordEntry?> getPasswordById(String id) async {
    await _ensureInitialized();

    final allPasswords = await getAllPasswords();
    try {
      return allPasswords.firstWhere((entry) => entry.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<String> createPassword(PasswordEntry entry) async {
    await _ensureInitialized();

    if (_currentWorkspaceId == null) {
      throw Exception('Workspace não definido');
    }

    final now = DateTime.now();
    final newEntry = entry.copyWith(
      id: _uuid.v4(),
      createdAt: now,
      updatedAt: now,
      strength: validatePasswordStrength(entry.password),
      workspaceId: _currentWorkspaceId, // Definir workspace
      lastPasswordChange: now,
      usageCount: 0,
    );

    // Salvar no workspace storage
    final allPasswords = await getAllPasswords();
    allPasswords.add(newEntry);
    await _savePasswordsToWorkspace(allPasswords);

    return newEntry.id;
  }

  Future<void> updatePassword(PasswordEntry entry) async {
    await _ensureInitialized();

    if (_currentWorkspaceId == null) {
      throw Exception('Workspace não definido');
    }

    final updatedEntry = entry.copyWith(
      updatedAt: DateTime.now(),
      strength: validatePasswordStrength(entry.password),
      workspaceId: _currentWorkspaceId, // Garantir workspace
    );

    // Atualizar no workspace storage
    final allPasswords = await getAllPasswords();
    final index = allPasswords.indexWhere((p) => p.id == entry.id);
    if (index != -1) {
      allPasswords[index] = updatedEntry;
      await _savePasswordsToWorkspace(allPasswords);
    }
  }

  Future<void> deletePassword(String id) async {
    await _ensureInitialized();

    // Remover do workspace storage
    final allPasswords = await getAllPasswords();
    allPasswords.removeWhere((p) => p.id == id);
    await _savePasswordsToWorkspace(allPasswords);
  }

  Future<void> deleteMultiplePasswords(List<String> ids) async {
    await _ensureInitialized();

    // Remover do workspace storage
    final allPasswords = await getAllPasswords();
    allPasswords.removeWhere((p) => ids.contains(p.id));
    await _savePasswordsToWorkspace(allPasswords);
  }

  /// Salvar passwords no workspace storage
  Future<void> _savePasswordsToWorkspace(List<PasswordEntry> passwords) async {
    if (_currentWorkspaceId == null) return;

    final data = {
      'passwords': passwords.map((p) => p.toJson()).toList(),
      'lastModified': DateTime.now().toIso8601String(),
    };

    await _workspaceStorage.saveWorkspaceData('passwords', data);
  }

  /// Salvar folders no workspace storage
  Future<void> _saveFoldersToWorkspace(List<PasswordFolder> folders) async {
    if (_currentWorkspaceId == null) return;

    final data = {
      'folders': folders.map((f) => f.toJson()).toList(),
      'lastModified': DateTime.now().toIso8601String(),
    };

    await _workspaceStorage.saveWorkspaceData('passwords', data);
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

  Future<List<PasswordEntry>> getPasswordsByStrength(
      PasswordStrength strength) async {
    final allPasswords = await getAllPasswords();
    return allPasswords.where((entry) => entry.strength == strength).toList();
  }

  Future<List<PasswordEntry>> getPasswordsByTag(String tag) async {
    final allPasswords = await getAllPasswords();
    return allPasswords.where((entry) => entry.tags.contains(tag)).toList();
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

  // NOVOS FILTROS AVANÇADOS
  Future<List<PasswordEntry>> getCompromisedPasswords() async {
    final allPasswords = await getAllPasswords();
    return allPasswords.where((entry) => entry.isCompromised).toList();
  }

  Future<List<PasswordEntry>> getReusedPasswords() async {
    final allPasswords = await getAllPasswords();
    return allPasswords.where((entry) => entry.isReused).toList();
  }

  Future<List<PasswordEntry>> getOldPasswords() async {
    final allPasswords = await getAllPasswords();
    return allPasswords.where((entry) => entry.isOldPassword).toList();
  }

  Future<List<PasswordEntry>> getPasswordsWith2FA() async {
    final allPasswords = await getAllPasswords();
    return allPasswords.where((entry) => entry.hasTwoFactor).toList();
  }

  Future<List<PasswordEntry>> getPasswordsInVault() async {
    final allPasswords = await getAllPasswords();
    return allPasswords.where((entry) => entry.isInSecureVault).toList();
  }

  Future<List<PasswordEntry>> getPinnedPasswords() async {
    final allPasswords = await getAllPasswords();
    return allPasswords.where((entry) => entry.isPinned).toList();
  }

  // Estatísticas
  Future<Map<String, dynamic>> getPasswordStats() async {
    final allPasswords = await getAllPasswords();

    final stats = <String, dynamic>{
      'total': allPasswords.length,
      'byStrength': <String, int>{},
      'byCategory': <String, int>{},
      'weakPasswords': 0,
      'reusedPasswords': 0,
      'oldPasswords': 0,
      'compromisedPasswords': 0,
      'passwordsWith2FA': 0,
      'passwordsInVault': 0,
      'pinnedPasswords': 0,
      'expiredPasswords': 0,
      'expiringSoonPasswords': 0,
    };

    final passwordHashes = <String, int>{};
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    for (final entry in allPasswords) {
      // Contar por força
      final strengthName = entry.strength.name;
      stats['byStrength'][strengthName] =
          (stats['byStrength'][strengthName] ?? 0) + 1;

      // Contar por categoria
      final category = entry.category ?? 'Sem categoria';
      stats['byCategory'][category] = (stats['byCategory'][category] ?? 0) + 1;

      // Senhas fracas
      if (entry.strength == PasswordStrength.veryWeak ||
          entry.strength == PasswordStrength.weak) {
        stats['weakPasswords']++;
      }

      // Senhas reutilizadas
      final hash = entry.password.hashCode.toString();
      passwordHashes[hash] = (passwordHashes[hash] ?? 0) + 1;
      if (passwordHashes[hash]! > 1) {
        stats['reusedPasswords']++;
      }

      // Senhas antigas
      if (entry.updatedAt.isBefore(thirtyDaysAgo)) {
        stats['oldPasswords']++;
      }

      // Novas estatísticas
      if (entry.isCompromised) stats['compromisedPasswords']++;
      if (entry.hasTwoFactor) stats['passwordsWith2FA']++;
      if (entry.isInSecureVault) stats['passwordsInVault']++;
      if (entry.isPinned) stats['pinnedPasswords']++;
      if (entry.isExpired) stats['expiredPasswords']++;
      if (entry.isExpiringSoon) stats['expiringSoonPasswords']++;
    }

    return stats;
  }

  // Gestão de pastas
  Future<List<PasswordFolder>> getAllFolders() async {
    await _ensureInitialized();
    final List<PasswordFolder> folders = [];

    final workspaceData =
        await _workspaceStorage.loadWorkspaceData('passwords');
    if (workspaceData != null) {
      final foldersData = workspaceData['folders'] as List<dynamic>? ?? [];
      for (final data in foldersData) {
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

    final allFolders = await getAllFolders();
    allFolders.add(newFolder);
    await _saveFoldersToWorkspace(allFolders);

    return newFolder.id;
  }

  Future<void> updateFolder(PasswordFolder folder) async {
    await _ensureInitialized();

    final updatedFolder = folder.copyWith(updatedAt: DateTime.now());
    final allFolders = await getAllFolders();
    final index = allFolders.indexWhere((f) => f.id == folder.id);
    if (index != -1) {
      allFolders[index] = updatedFolder;
      await _saveFoldersToWorkspace(allFolders);
    }
  }

  Future<void> deleteFolder(String folderId) async {
    await _ensureInitialized();

    // Mover todas as entradas para fora da pasta
    final passwords = await getPasswordsByFolder(folderId);
    for (final password in passwords) {
      await updatePassword(password.copyWith(folderId: null));
    }

    final allFolders = await getAllFolders();
    allFolders.removeWhere((f) => f.id == folderId);
    await _saveFoldersToWorkspace(allFolders);
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
          await createFolder(folder);
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
          await createPassword(password);
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
}
