import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/huggingface_token_provider.dart';
import '../../../shared/providers/google_ai_token_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AISettingsScreen extends ConsumerWidget {
  const AISettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final huggingFaceToken = ref.watch(huggingFaceTokenProvider);
    final googleAIToken = ref.watch(googleAITokenProvider);
    final huggingFaceController = TextEditingController(text: huggingFaceToken);
    final googleAIController = TextEditingController(text: googleAIToken);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de IA'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Configuração de IA',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'O Bloquinho usa Google AI (gratuito) por padrão. Você também pode configurar um token do Hugging Face como alternativa.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Google AI API Key',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: googleAIController,
            decoration: const InputDecoration(
              labelText: 'Google AI API Key',
              border: OutlineInputBorder(),
              helperText: 'Obtida em https://makersuite.google.com/app/apikey',
            ),
            onChanged: (value) {
              ref.read(googleAITokenProvider.notifier).setToken(value.trim());
            },
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          Text(
            'Token Hugging Face (Opcional)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: huggingFaceController,
            decoration: const InputDecoration(
              labelText: 'Token Hugging Face',
              border: OutlineInputBorder(),
              helperText: 'Opcional - usado como alternativa ao Google AI',
            ),
            onChanged: (value) {
              ref
                  .read(huggingFaceTokenProvider.notifier)
                  .setToken(value.trim());
            },
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Google AI'),
                  onPressed: () async {
                    final url =
                        Uri.parse('https://makersuite.google.com/app/apikey');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Hugging Face'),
                  onPressed: () async {
                    final url =
                        Uri.parse('https://huggingface.co/settings/tokens');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Dica: Obtenha sua Google AI API Key gratuita em https://makersuite.google.com/app/apikey. Para Hugging Face, use modelos com "Inference API" pública.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
