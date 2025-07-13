import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final huggingFaceTokenProvider =
    StateNotifierProvider<HuggingFaceTokenNotifier, String>((ref) {
  return HuggingFaceTokenNotifier();
});

class HuggingFaceTokenNotifier extends StateNotifier<String> {
  static const String _boxName = 'app_settings';
  static const String _tokenKey = 'huggingface_token';
  Box<String>? _box;

  HuggingFaceTokenNotifier() : super('') {
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox<String>(_boxName);
      } else {
        _box = Hive.box<String>(_boxName);
      }
      final token = _box?.get(_tokenKey);
      if (token != null && token.isNotEmpty) {
        state = token;
      }
    } catch (e) {
      // Se houver erro ao abrir a box, continua sem token
      print('Erro ao carregar token: $e');
    }
  }

  Future<void> setToken(String token) async {
    state = token;
    await _box?.put(_tokenKey, token);
  }
}
