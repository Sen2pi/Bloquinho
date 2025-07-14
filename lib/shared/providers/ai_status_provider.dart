/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../core/services/ai_service.dart';
import 'google_ai_token_provider.dart';
import 'huggingface_token_provider.dart';

/// Status da IA
enum AIStatus {
  offline, // Nenhuma IA disponível
  online, // IA disponível e funcional
  testing, // Testando conectividade
}

class AIStatusState {
  final AIStatus status;
  final String? message;
  final bool isGoogleAI;
  final bool isHuggingFace;

  const AIStatusState({
    required this.status,
    this.message,
    this.isGoogleAI = false,
    this.isHuggingFace = false,
  });
}

class AIStatusNotifier extends StateNotifier<AIStatusState> {
  AIStatusNotifier() : super(const AIStatusState(status: AIStatus.testing));

  /// Testa as tokens salvas usando WidgetRef
  Future<void> testAIAvailability(WidgetRef ref) async {
    state = const AIStatusState(status: AIStatus.testing);
    try {
      final isAvailable = await AIService.isAvailable(ref);
      if (isAvailable) {
        final googleToken = ref.read(googleAITokenProvider);
        final huggingToken = ref.read(huggingFaceTokenProvider);
        state = AIStatusState(
          status: AIStatus.online,
          isGoogleAI: googleToken.isNotEmpty,
          isHuggingFace: huggingToken.isNotEmpty,
        );
      } else {
        state = const AIStatusState(status: AIStatus.offline);
      }
    } catch (e) {
      state = AIStatusState(status: AIStatus.offline, message: e.toString());
    }
  }
}

final aiStatusProvider =
    StateNotifierProvider<AIStatusNotifier, AIStatusState>((ref) {
  return AIStatusNotifier();
});
