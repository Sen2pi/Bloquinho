/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/huggingface_token_provider.dart';
import '../../shared/providers/google_ai_token_provider.dart';

/// Tipo de provedor de IA
enum AIProvider { huggingFace, googleAI }

/// Configuração para o serviço de IA
class AIConfig {
  /// Provedor padrão
  static const AIProvider defaultProvider = AIProvider.googleAI;

  /// Token padrão do Hugging Face (fallback)
  static const String defaultHuggingFaceToken =
      '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';

  /// Token padrão do Google AI (gratuito)
  static const String defaultGoogleAIToken =
      'AIzaSyByvTPjDORRQ3iUDws9iuTGEwlkvGFnh38';

  /// Modelo padrão para geração de texto (com Inference API pública)
  static const String defaultModel = 'microsoft/DialoGPT-medium';

  /// Modelos alternativos caso o principal falhe
  static const List<String> alternativeModels = [
    'gpt2',
    'distilgpt2',
  ];

  /// Busca o token configurado dinamicamente
  static String getHuggingFaceToken(WidgetRef ref) {
    final userToken = ref.read(huggingFaceTokenProvider);
    if (userToken.isNotEmpty) {
      return userToken;
    }
    return defaultHuggingFaceToken;
  }

  /// Busca o token do Google AI
  static String getGoogleAIToken(WidgetRef ref) {
    // Retorna o token do usuário se não for nulo ou vazio, senão retorna o padrão.
    final userToken = ref.read(googleAITokenProvider);
    return userToken.isNotEmpty ? userToken : defaultGoogleAIToken;
  }

  static bool isConfigured(WidgetRef ref) {
    final huggingFaceToken = getHuggingFaceToken(ref);
    final googleAIToken = getGoogleAIToken(ref);
    return huggingFaceToken.isNotEmpty || googleAIToken.isNotEmpty;
  }
}
