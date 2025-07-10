import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/oauth2_service.dart';
import '../core/services/avatar_cache_service.dart';
import '../shared/providers/user_profile_provider.dart';

/// Exemplo prático de uso do sistema de cache de avatares
class OAuthAvatarExample extends ConsumerWidget {
  const OAuthAvatarExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OAuth2 com Cache de Avatares'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sistema de Cache de Avatares',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Botão Google Drive
            ElevatedButton(
              onPressed: () => _authenticateWithGoogle(context, ref),
              child: const Text('Autenticar com Google Drive'),
            ),

            // Botão OneDrive
            ElevatedButton(
              onPressed: () => _authenticateWithMicrosoft(context, ref),
              child: const Text('Autenticar com OneDrive'),
            ),

            const SizedBox(height: 32),

            // Status do perfil
            Consumer(
              builder: (context, ref, child) {
                final profile = ref.watch(currentProfileProvider);
                final isLoading = ref.watch(isProfileLoadingProvider);

                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (profile != null) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Avatar do perfil
                          profile.avatarPath != null
                              ? CircleAvatar(
                                  radius: 50,
                                  backgroundImage: FileImage(
                                    File(profile.avatarPath!),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    profile.initials,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                          const SizedBox(height: 16),

                          // Informações do perfil
                          Text(
                            'Nome: ${profile.name}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            'Email: ${profile.email}',
                            style: const TextStyle(fontSize: 16),
                          ),

                          if (profile.avatarPath != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Avatar: ${profile.avatarPath!.split('/').last}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Nenhum perfil encontrado'),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Informações do cache
            ElevatedButton(
              onPressed: () => _showCacheInfo(context),
              child: const Text('Ver Informações do Cache'),
            ),

            ElevatedButton(
              onPressed: () => _clearCache(context),
              child: const Text('Limpar Cache'),
            ),
          ],
        ),
      ),
    );
  }

  /// Autenticar com Google e criar perfil com avatar
  Future<void> _authenticateWithGoogle(
      BuildContext context, WidgetRef ref) async {
    try {
      // Mostrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Autenticando com Google...')),
      );

      // Autenticar com OAuth2
      final result = await OAuth2Service.authenticateGoogle();

      if (result.success) {
        // Criar perfil com avatar em cache
        await ref.read(userProfileProvider.notifier).createProfileFromOAuth(
              name: result.userName ?? 'Usuário',
              email: result.userEmail ?? 'email@exemplo.com',
              avatarPath: result.avatarPath, // 🎯 Avatar em cache!
            );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.avatarPath != null
                    ? 'Google autenticado com sucesso! Avatar baixado e armazenado.'
                    : 'Google autenticado com sucesso! Avatar não disponível.',
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: ${result.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na autenticação: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Autenticar com Microsoft e criar perfil com avatar
  Future<void> _authenticateWithMicrosoft(
      BuildContext context, WidgetRef ref) async {
    try {
      // Mostrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Autenticando com Microsoft...')),
      );

      // Autenticar com OAuth2
      final result = await OAuth2Service.authenticateMicrosoft();

      if (result.success) {
        // Criar perfil com avatar em cache
        await ref.read(userProfileProvider.notifier).createProfileFromOAuth(
              name: result.userName ?? 'Usuário',
              email: result.userEmail ?? 'email@exemplo.com',
              avatarPath: result.avatarPath, // 🎯 Avatar em cache!
            );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.avatarPath != null
                    ? 'Microsoft autenticado com sucesso! Avatar baixado e armazenado.'
                    : 'Microsoft autenticado com sucesso! Avatar não disponível.',
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: ${result.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na autenticação: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Mostrar informações do cache
  Future<void> _showCacheInfo(BuildContext context) async {
    try {
      final stats = await AvatarCacheService.getCacheStats();

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Informações do Cache'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Arquivos: ${stats['totalFiles']}'),
                Text('Tamanho: ${stats['totalSizeMB']} MB'),
                Text('Diretório: ${stats['cacheDirectory']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao obter informações: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Limpar cache
  Future<void> _clearCache(BuildContext context) async {
    try {
      await AvatarCacheService.clearAllCache();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache limpo com sucesso!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao limpar cache: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Como usar o sistema em outras partes do código:
/// 
/// 1. Autenticar com OAuth2:
///    final result = await OAuth2Service.authenticateGoogle();
/// 
/// 2. Criar perfil com avatar:
///    await ref.read(userProfileProvider.notifier).createProfileFromOAuth(
///      name: result.userName!,
///      email: result.userEmail!,
///      avatarPath: result.avatarPath, // Avatar em cache!
///    );
/// 
/// 3. Usar ProfileAvatar normalmente:
///    ProfileAvatar(profile: profile) // Automaticamente usa cache
/// 
/// 4. Verificar se há avatar em cache:
///    final cachedPath = await AvatarCacheService.getCachedAvatar(userId);
/// 
/// 5. Estatísticas do cache:
///    final stats = await AvatarCacheService.getCacheStats();
/// 
/// 6. Limpeza do cache:
///    await AvatarCacheService.clearAllCache();
/// 
/// O sistema é totalmente automático! 🎯 