import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final googleAITokenProvider =
    StateNotifierProvider<GoogleAITokenNotifier, String>((ref) {
  return GoogleAITokenNotifier();
});

class GoogleAITokenNotifier extends StateNotifier<String> {
  static const String _boxName = 'app_settings';
  static const String _tokenKey = 'googleai_token';
  Box<String>? _box;

  GoogleAITokenNotifier() : super('') {
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      _box = await _ensureBoxIsOpen();
      final token = _box?.get(_tokenKey);
      if (token != null && token.isNotEmpty) {
        state = token;
      }
    } catch (e) {
      // Se houver erro ao abrir a box, continua sem token
      print('Erro ao carregar token Google AI: $e');
    }
  }

  Future<Box<String>?> _ensureBoxIsOpen() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        return await Hive.openBox<String>(_boxName);
      } else {
        return Hive.box<String>(_boxName);
      }
    } catch (e) {
      print('Erro ao abrir box Google AI: $e');
      return null;
    }
  }

  Future<void> setToken(String token) async {
    state = token;
    await _box?.put(_tokenKey, token);
  }
}
