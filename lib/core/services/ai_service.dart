import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'ai_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AIService {
  static const String _huggingFaceBaseUrl =
      'https://api-inference.huggingface.co/models';
  static const String _googleAIBaseUrl =
      'https://generativelanguage.googleapis.com/v1/models';

  /// Gera conteúdo markdown usando Google AI (gratuito) ou Hugging Face
  static Future<String> generateMarkdownContent(String prompt,
      {String? model, required WidgetRef ref}) async {
    try {
      debugPrint('🤖 Tentando Google AI...');
      return await _generateWithGoogleAI(prompt, ref);
    } catch (e) {
      debugPrint('❌ Google AI falhou: $e');
      final huggingFaceToken = AIConfig.getHuggingFaceToken(ref);
      if (huggingFaceToken.isNotEmpty) {
        try {
          debugPrint('🤖 Tentando Hugging Face...');
          return await _generateWithHuggingFace(prompt, model, ref);
        } catch (e) {
          debugPrint('❌ Hugging Face falhou: $e');
          return _generateFallbackContent(prompt);
        }
      } else {
        return _generateFallbackContent(prompt);
      }
    }
  }

  /// ✅ CORRIGIDO: Google AI sem thinkingConfig
  static Future<String> _generateWithGoogleAI(
      String prompt, WidgetRef ref) async {
    final token = AIConfig.getGoogleAIToken(ref);
    if (token.isEmpty) {
      throw Exception(
          'Token do Google AI não configurado. Configure em Settings > Configurações de IA');
    }

    final uri = Uri.parse(
        '$_googleAIBaseUrl/gemini-2.5-flash:generateContent?key=$token');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text':
                    'Gere conteúdo markdown bem estruturado sobre: $prompt\n\n'
                        'Requisitos:\n'
                        '- Use títulos e subtítulos apropriados (# ## ###)\n'
                        '- Inclua listas com marcadores quando relevante\n'
                        '- Use **negrito** para destacar pontos importantes\n'
                        '- Inclua *itálico* para ênfase\n'
                        '- Mantenha a formatação limpa e profissional\n'
                        '- Responda em português brasileiro\n\n'
                        'Responda apenas com o conteúdo markdown:'
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 2048,
          'candidateCount': 1,
          'stopSequences': []
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        final generatedText =
            data['candidates'][0]['content']['parts'][0]['text'];
        return _ensureMarkdownFormat(generatedText);
      } else {
        throw Exception('Resposta vazia da Google AI');
      }
    } else {
      throw Exception(
          'Erro na Google AI: ${response.statusCode} - ${response.body}');
    }
  }

  /// ✅ CORRIGIDO: Hugging Face sem recursão infinita
  static Future<String> _generateWithHuggingFace(
      String prompt, String? model, WidgetRef ref) async {
    final selectedModel = model ?? AIConfig.defaultModel;
    final token = AIConfig.getHuggingFaceToken(ref);

    if (token.isEmpty) {
      throw Exception('Token do Hugging Face não configurado');
    }

    // Lista de modelos para tentar
    final modelsToTry = [
      selectedModel,
      ...AIConfig.alternativeModels.where((m) => m != selectedModel)
    ];

    for (int i = 0; i < modelsToTry.length; i++) {
      final currentModel = modelsToTry[i];

      try {
        debugPrint(
            '🤖 Tentando modelo: $currentModel (${i + 1}/${modelsToTry.length})');

        final uri = Uri.parse('$_huggingFaceBaseUrl/$currentModel');
        final response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'inputs': _buildHuggingFacePrompt(prompt),
            'parameters': {
              'max_length': 1024,
              'temperature': 0.7,
              'do_sample': true,
              'top_p': 0.9,
              'repetition_penalty': 1.1,
              'return_full_text': false,
            },
            'options': {
              'wait_for_model': true,
              'use_cache': false,
            }
          }),
        );

        if (response.statusCode == 200) {
          final result = _extractGeneratedText(response.body);
          if (result.isNotEmpty) {
            debugPrint('✅ Sucesso com modelo: $currentModel');
            return result;
          }
        } else if (response.statusCode == 401) {
          throw Exception(
              'Token inválido. Verifique seu token do Hugging Face');
        } else {
          debugPrint('⚠️ Modelo $currentModel falhou: ${response.statusCode}');
          continue; // Tenta próximo modelo
        }
      } catch (e) {
        debugPrint('❌ Erro com modelo $currentModel: $e');
        if (i == modelsToTry.length - 1) {
          // Último modelo, lança exceção
          throw Exception('Todos os modelos do Hugging Face falharam');
        }
        continue; // Tenta próximo modelo
      }
    }

    throw Exception('Todos os modelos do Hugging Face falharam');
  }

  /// Constrói prompt otimizado para Hugging Face
  static String _buildHuggingFacePrompt(String prompt) {
    return '''
Tópico: $prompt

Crie um documento markdown estruturado com:
- Título principal
- Subtítulos
- Listas com marcadores
- Texto formatado

Documento:
''';
  }

  /// ✅ CORRIGIDO: Extração de texto melhorada
  static String _extractGeneratedText(String responseBody) {
    try {
      final data = jsonDecode(responseBody);
      String generatedText = '';

      if (data is List && data.isNotEmpty) {
        generatedText = data.first['generated_text'] ?? '';
      } else if (data is Map && data.containsKey('generated_text')) {
        generatedText = data['generated_text'] ?? '';
      } else {
        throw Exception('Formato de resposta inválido');
      }

      // Remove o prompt original se presente
      final cleanText = _removeOriginalPrompt(generatedText);
      return _ensureMarkdownFormat(cleanText);
    } catch (e) {
      debugPrint('❌ Erro ao processar resposta: $e');
      rethrow;
    }
  }

  /// Remove prompt original da resposta
  static String _removeOriginalPrompt(String generatedText) {
    final lines = generatedText.split('\n');

    // Remove linhas que parecem ser o prompt original
    final filteredLines = lines.where((line) {
      final trimmed = line.trim();
      return !trimmed.startsWith('Tópico:') &&
          !trimmed.startsWith('Crie um documento') &&
          !trimmed.startsWith('Documento:') &&
          trimmed.isNotEmpty;
    }).toList();

    return filteredLines.join('\n').trim();
  }

  /// Garante formato markdown adequado
  static String _ensureMarkdownFormat(String text) {
    if (text.isEmpty) {
      return '# Conteúdo\n\nNenhum conteúdo foi gerado.';
    }

    String cleaned = text.trim();

    // Garante quebras de linha adequadas
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return cleaned;
  }

  /// ✅ NOVO: Conteúdo de fallback quando todas as APIs falham
  static String _generateFallbackContent(String prompt) {
    return '''
# 📄 $prompt

## Visão Geral
Este documento foi gerado automaticamente sobre o tema: **$prompt**.

## Estrutura Sugerida
- **Introdução**: Apresentação do tema
- **Desenvolvimento**: Pontos principais
- **Detalhes**: Informações específicas
- **Conclusão**: Resumo final

## Nota
*Para obter conteúdo personalizado, verifique:*
- Conexão com a internet
- Configuração das chaves de API
- Disponibilidade dos serviços

---
*Conteúdo gerado como fallback*
''';
  }

  /// Verifica disponibilidade dos serviços
  static Future<bool> isAvailable(WidgetRef ref) async {
    // Testa Google AI primeiro
    try {
      final token = AIConfig.getGoogleAIToken(ref);
      if (token.isNotEmpty) {
        final response = await http.get(
          Uri.parse('$_googleAIBaseUrl/gemini-2.5-flash?key=$token'),
        );
        if (response.statusCode == 200) {
          return true;
        }
      }
    } catch (e) {
      debugPrint('Google AI não disponível: $e');
    }

    // Testa Hugging Face como fallback
    try {
      final token = AIConfig.getHuggingFaceToken(ref);
      if (token.isNotEmpty) {
        final response = await http.get(
          Uri.parse('$_huggingFaceBaseUrl/${AIConfig.defaultModel}'),
          headers: {'Authorization': 'Bearer $token'},
        );
        return response.statusCode == 200;
      }
    } catch (e) {
      debugPrint('Hugging Face não disponível: $e');
    }

    return false;
  }
}
