/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'dart:convert';
import 'dart:math';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart';

class PasswordEncryptionService {
  static const String _keyStorageKey = 'password_encryption_key';
  static const String _ivStorageKey = 'password_encryption_iv';
  static const String _saltStorageKey = 'password_encryption_salt';
  
  static final PasswordEncryptionService _instance = PasswordEncryptionService._internal();
  factory PasswordEncryptionService() => _instance;
  PasswordEncryptionService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  Key? _encryptionKey;
  IV? _encryptionIV;
  Encrypter? _encrypter;
  
  bool _isInitialized = false;

  /// Inicializar o serviço de encriptação
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Tentar carregar chave existente
      final keyData = await _secureStorage.read(key: _keyStorageKey);
      final ivData = await _secureStorage.read(key: _ivStorageKey);
      
      if (keyData != null && ivData != null) {
        // Usar chave existente
        _encryptionKey = Key.fromBase64(keyData);
        _encryptionIV = IV.fromBase64(ivData);
      } else {
        // Gerar nova chave
        await _generateNewKey();
      }
      
      _encrypter = Encrypter(AES(_encryptionKey!));
      _isInitialized = true;
    } catch (e) {
      throw Exception('Erro ao inicializar encriptação: $e');
    }
  }

  /// Gerar nova chave de encriptação
  Future<void> _generateNewKey() async {
    try {
      // Gerar chave AES-256
      final key = Key.fromSecureRandom(32);
      final iv = IV.fromSecureRandom(16);
      
      // Salvar na secure storage
      await _secureStorage.write(key: _keyStorageKey, value: key.base64);
      await _secureStorage.write(key: _ivStorageKey, value: iv.base64);
      
      _encryptionKey = key;
      _encryptionIV = iv;
    } catch (e) {
      throw Exception('Erro ao gerar chave de encriptação: $e');
    }
  }

  /// Encriptar dados
  Future<String> encrypt(String plainText) async {
    await _ensureInitialized();
    
    try {
      final encrypted = _encrypter!.encrypt(plainText, iv: _encryptionIV!);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Erro ao encriptar dados: $e');
    }
  }

  /// Desencriptar dados
  Future<String> decrypt(String encryptedText) async {
    await _ensureInitialized();
    
    try {
      final encrypted = Encrypted.fromBase64(encryptedText);
      final decrypted = _encrypter!.decrypt(encrypted, iv: _encryptionIV!);
      return decrypted;
    } catch (e) {
      throw Exception('Erro ao desencriptar dados: $e');
    }
  }

  /// Encriptar objeto JSON
  Future<String> encryptJson(Map<String, dynamic> data) async {
    final jsonString = jsonEncode(data);
    return await encrypt(jsonString);
  }

  /// Desencriptar objeto JSON
  Future<Map<String, dynamic>> decryptJson(String encryptedData) async {
    final jsonString = await decrypt(encryptedData);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Encriptar lista de objetos JSON
  Future<String> encryptJsonList(List<Map<String, dynamic>> data) async {
    final jsonString = jsonEncode(data);
    return await encrypt(jsonString);
  }

  /// Desencriptar lista de objetos JSON
  Future<List<Map<String, dynamic>>> decryptJsonList(String encryptedData) async {
    final jsonString = await decrypt(encryptedData);
    final decoded = jsonDecode(jsonString);
    return List<Map<String, dynamic>>.from(decoded);
  }

  /// Gerar hash seguro de senha
  String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Gerar salt aleatório
  String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(saltBytes);
  }

  /// Verificar senha com hash
  bool verifyPassword(String password, String salt, String hash) {
    final computedHash = hashPassword(password, salt);
    return computedHash == hash;
  }

  /// Derivar chave de senha usando PBKDF2
  Future<Key> deriveKeyFromPassword(String password, String salt) async {
    try {
      final saltBytes = base64.decode(salt);
      final passwordBytes = utf8.encode(password);
      
      // Usar PBKDF2 com SHA256
      final key = await _pbkdf2(passwordBytes, saltBytes, 10000, 32);
      return Key(key);
    } catch (e) {
      throw Exception('Erro ao derivar chave da senha: $e');
    }
  }

  /// Implementação simples do PBKDF2
  Future<Uint8List> _pbkdf2(List<int> password, List<int> salt, int iterations, int keyLength) async {
    var hmac = Hmac(sha256, password);
    var result = Uint8List(keyLength);
    var blockCount = (keyLength / 32).ceil();
    
    for (var i = 1; i <= blockCount; i++) {
      var block = _pbkdf2Block(hmac, salt, i, iterations);
      var offset = (i - 1) * 32;
      var length = math.min(32, keyLength - offset);
      result.setRange(offset, offset + length, block);
    }
    
    return result;
  }

  Uint8List _pbkdf2Block(Hmac hmac, List<int> salt, int blockIndex, int iterations) {
    var u = Uint8List(32);
    var saltWithIndex = Uint8List(salt.length + 4);
    saltWithIndex.setAll(0, salt);
    saltWithIndex[salt.length] = (blockIndex >> 24) & 0xff;
    saltWithIndex[salt.length + 1] = (blockIndex >> 16) & 0xff;
    saltWithIndex[salt.length + 2] = (blockIndex >> 8) & 0xff;
    saltWithIndex[salt.length + 3] = blockIndex & 0xff;
    
    var digest = hmac.convert(saltWithIndex);
    u.setAll(0, digest.bytes);
    
    var result = Uint8List.fromList(u);
    
    for (var i = 1; i < iterations; i++) {
      digest = hmac.convert(u);
      u.setAll(0, digest.bytes);
      
      for (var j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }
    
    return result;
  }

  /// Encriptar com senha personalizada
  Future<String> encryptWithPassword(String plainText, String password) async {
    try {
      final salt = generateSalt();
      final key = await deriveKeyFromPassword(password, salt);
      final iv = IV.fromSecureRandom(16);
      final encrypter = Encrypter(AES(key));
      
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      
      // Combinar salt + iv + dados encriptados
      final combined = {
        'salt': salt,
        'iv': iv.base64,
        'data': encrypted.base64,
      };
      
      return base64.encode(utf8.encode(jsonEncode(combined)));
    } catch (e) {
      throw Exception('Erro ao encriptar com senha: $e');
    }
  }

  /// Desencriptar com senha personalizada
  Future<String> decryptWithPassword(String encryptedData, String password) async {
    try {
      final decodedData = utf8.decode(base64.decode(encryptedData));
      final combined = jsonDecode(decodedData) as Map<String, dynamic>;
      
      final salt = combined['salt'] as String;
      final iv = IV.fromBase64(combined['iv'] as String);
      final data = combined['data'] as String;
      
      final key = await deriveKeyFromPassword(password, salt);
      final encrypter = Encrypter(AES(key));
      
      final encrypted = Encrypted.fromBase64(data);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      
      return decrypted;
    } catch (e) {
      throw Exception('Erro ao desencriptar com senha: $e');
    }
  }

  /// Resetar chaves de encriptação
  Future<void> resetEncryption() async {
    try {
      await _secureStorage.delete(key: _keyStorageKey);
      await _secureStorage.delete(key: _ivStorageKey);
      await _secureStorage.delete(key: _saltStorageKey);
      
      _encryptionKey = null;
      _encryptionIV = null;
      _encrypter = null;
      _isInitialized = false;
      
      // Reinicializar com nova chave
      await initialize();
    } catch (e) {
      throw Exception('Erro ao resetar encriptação: $e');
    }
  }

  /// Verificar se está inicializado
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Obter informações sobre a encriptação
  Future<Map<String, dynamic>> getEncryptionInfo() async {
    await _ensureInitialized();
    
    return {
      'algorithm': 'AES-256',
      'mode': 'CBC',
      'keyLength': 32,
      'ivLength': 16,
      'isInitialized': _isInitialized,
      'keyExists': _encryptionKey != null,
    };
  }

  /// Testar encriptação
  Future<bool> testEncryption() async {
    try {
      const testString = 'Bloquinho Password Test';
      final encrypted = await encrypt(testString);
      final decrypted = await decrypt(encrypted);
      
      return decrypted == testString;
    } catch (e) {
      return false;
    }
  }
}