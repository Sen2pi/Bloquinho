/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/services/data_directory_service.dart';

final googleAITokenProvider =
    StateNotifierProvider<GoogleAITokenNotifier, String>((ref) {
  return GoogleAITokenNotifier();
});

class GoogleAITokenNotifier extends StateNotifier<String> {
  static const String _boxName = 'app_settings';
  static const String _tokenKey = 'googleai_token';
  Box<String>? _box;

  GoogleAITokenNotifier() : super('') {
    _initHive();
  }

  Future<void> _initHive() async {
    try {
      // Hive já foi inicializado globalmente
      final dataDir = await DataDirectoryService().initialize();
      final dbPath = await DataDirectoryService().getBasePath();
      _box = await Hive.openBox<String>(_boxName, path: dbPath);

      // Carregar token salvo
      final savedToken = _box!.get(_tokenKey, defaultValue: '');
      if (savedToken != null && savedToken.isNotEmpty) {
        state = savedToken;
      }
    } catch (e) {
      // Em caso de erro, manter token vazio
      print('Erro ao inicializar Google AI token: $e');
    }
  }

  Future<void> _ensureBoxIsOpen() async {
    if (_box == null || !_box!.isOpen) {
      try {
        final dataDir = await DataDirectoryService().initialize();
        final dbPath = await DataDirectoryService().getBasePath();
        _box = await Hive.openBox<String>(_boxName, path: dbPath);
      } catch (e) {
        // Se não conseguir abrir o box, criar um novo
        final dataDir = await DataDirectoryService().initialize();
        final dbPath = await DataDirectoryService().getBasePath();
        await Hive.deleteBoxFromDisk(_boxName, path: dbPath);
        _box = await Hive.openBox<String>(_boxName, path: dbPath);
      }
    }
  }

  Future<void> setToken(String token) async {
    try {
      state = token;

      // Garantir que o box está aberto antes de salvar
      await _ensureBoxIsOpen();
      await _box!.put(_tokenKey, token);
    } catch (e) {
      print('Erro ao salvar token Google AI: $e');
    }
  }
}
