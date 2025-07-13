import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'ai_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AIService {
  static const String _huggingFaceBaseUrl =
      'https://api-inference.huggingface.co/models';
  static const String _googleAIBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

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

  /// Otimizado para gerar conteúdo robusto com o Google AI
  static Future<String> _generateWithGoogleAI(
      String prompt, WidgetRef ref) async {
    final token = AIConfig.getGoogleAIToken(ref);
    if (token.isEmpty) {
      throw Exception(
          'Token do Google AI não configurado. Configure em Settings > Configurações de IA');
    }

    // Usando um modelo mais recente e a URL correta da API
    final uri =
        Uri.parse('$_googleAIBaseUrl/gemini-1.5-flash:generateContent?key=$token');

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'text':
                  'Gere uma página markdown robusta e visualmente atraente sobre: $prompt\n\n'
                      '**Diretrizes Estritas:**\n'
                      '1.  **Ícones:** Use emojis (ícones) relevantes para cada seção ou item de lista para melhorar a legibilidade e o apelo visual (ex: ✨, 🚀, 💡, 📄, 🔗).\n'
                      '2.  **Estrutura Avançada:**\n'
                      '    - Utilize títulos e subtítulos (`#`, `##`, `###`) para uma hierarquia clara.\n'
                      '    - Empregue **negrito** e *itálico* para ênfase.\n'
                      '    - Crie `listas com marcadores` ou `numeradas` para organizar informações.\n'
                      '    - Se aplicável, inclua `tabelas` para dados estruturados.\n'
                      '    - Use `blocos de citação` (> citação) para destacar informações importantes.\n'
                      '    - Adicione `links` se o contexto permitir.\n'
                      '    - Inclua `blocos de código` (```) para exemplos de código ou comandos.\n'
      '3.  **Qualidade:** O conteúdo deve ser bem escrito, profissional e informativo.\n'
      '4.  **Idioma:** Responda em português brasileiro.\n'
      '5.  **Saída:** Forneça APENAS o conteúdo markdown, sem nenhum texto ou explicação adicional.'
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.8,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 4096, // Aumentado para páginas mais completas
        'candidateCount': 1,
        'stopSequences': []
      },
      'safetySettings': [
        // Configurações para evitar bloqueios desnecessários
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        }
      ]
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Análise robusta da resposta para evitar erros de '[]'
      if (data['candidates'] != null &&
          data['candidates'] is List &&
          data['candidates'].isNotEmpty) {
        final candidate = data['candidates'][0];
        if (candidate['content'] != null &&
            candidate['content']['parts'] != null &&
            candidate['content']['parts'] is List &&
            candidate['content']['parts'].isNotEmpty) {
          final generatedText = candidate['content']['parts'][0]['text'];
          if (generatedText != null) {
            return _ensureMarkdownFormat(generatedText);
          }
        }
      }

      // Trata casos de conteúdo bloqueado
      if (data['promptFeedback'] != null) {
        final blockReason = data['promptFeedback']['blockReason'];
        debugPrint('Conteúdo bloqueado por: $blockReason.');
        throw Exception(
            'O conteúdo foi bloqueado por políticas de segurança. Motivo: $blockReason');
      }

      throw Exception('Resposta da Google AI com formato inesperado ou vazia.');
    } else if (response.statusCode == 401) {
      throw Exception(
          'Token do Google AI inválido ou expirado. Configure um token válido em Configurações de IA.');
    } else {
      throw Exception(
          'Erro na Google AI: ${response.statusCode} - ${response.body}');
    }
  }

  /// Fallback para Hugging Face com tratamento de erro aprimorado
  static Future<String> _generateWithHuggingFace(
      String prompt, String? model, WidgetRef ref) async {
    final selectedModel = model ?? AIConfig.defaultModel;
    final token = AIConfig.getHuggingFaceToken(ref);

    if (token.isEmpty) {
      throw Exception('Token do Hugging Face não configurado');
    }

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
            'options': {'wait_for_model': true, 'use_cache': false}
          }),
        );

        if (response.statusCode == 200) {
          // A extração de texto agora é mais robusta
          final result = _extractGeneratedText(response.body);
          if (result.isNotEmpty &&
              !result.contains('Nenhum conteúdo foi gerado')) {
            debugPrint('✅ Sucesso com modelo: $currentModel');
            return result;
          }
          // Se o resultado for vazio, trata como falha e tenta o próximo
          debugPrint('⚠️ Modelo $currentModel retornou resposta vazia.');
        } else if (response.statusCode == 401) {
          throw Exception(
              'Token do Hugging Face inválido. Configure um token válido em Configurações de IA.');
        } else {
          debugPrint('⚠️ Modelo $currentModel falhou: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('❌ Erro com modelo $currentModel: $e');
        if (e.toString().contains('Token do Hugging Face inválido')) {
          rethrow;
        }
      }
    }

    throw Exception('Todos os modelos do Hugging Face falharam');
  }

  /// Constrói prompt otimizado para Hugging Face
  static String _buildHuggingFacePrompt(String prompt) {
    return '''
**Tarefa**: Gerar um documento markdown detalhado e bem formatado sobre o tópico abaixo.

**Tópico**: $prompt

**Instruções**:
- Use um título principal (`#`).
- Organize com subtítulos (`##`, `###`).
- Utilize listas (`*` ou `-`) e **negrito** para clareza.
- Opcional: adicione emojis para apelo visual.
- Responda em português.

**Documento Markdown**:
''';
  }

  /// Extração de texto robusta para Hugging Face
  static String _extractGeneratedText(String responseBody) {
    try {
      final data = jsonDecode(responseBody);
      String generatedText = '';

      if (data == null) return '';

      if (data is List && data.isNotEmpty) {
        final firstItem = data.first;
        if (firstItem is Map && firstItem.containsKey('generated_text')) {
          generatedText = firstItem['generated_text'] ?? '';
        }
      } else if (data is Map && data.containsKey('generated_text')) {
        generatedText = data['generated_text'] ?? '';
      } else if (data is List && data.isEmpty) {
        // Resposta '[]' é tratada como falha do modelo
        return '';
      }

      final cleanText = _removeOriginalPrompt(generatedText);
      return _ensureMarkdownFormat(cleanText);
    } catch (e) {
      debugPrint('❌ Erro ao processar resposta do Hugging Face: $e');
      return ''; // Retorna vazio para indicar falha
    }
  }

  /// Remove prompt original da resposta
  static String _removeOriginalPrompt(String generatedText) {
    final lines = generatedText.split('\n');
    final filteredLines = lines.where((line) {
      final trimmed = line.trim();
      return !trimmed.startsWith('**Tarefa**:') &&
          !trimmed.startsWith('**Tópico**:') &&
          !trimmed.startsWith('**Instruções**:') &&
          !trimmed.startsWith('**Documento Markdown**:') &&
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
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return cleaned;
  }

  /// Conteúdo de fallback quando todas as APIs falham
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
    try {
      final token = AIConfig.getGoogleAIToken(ref);
      if (token.isNotEmpty) {
        final response = await http.get(
          Uri.parse('$_googleAIBaseUrl/gemini-1.5-flash?key=$token'),
        );
        if (response.statusCode == 200) return true;
      }
    } catch (e) {
      debugPrint('Google AI não disponível: $e');
    }

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
