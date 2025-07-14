/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/services/oauth2_service.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';

/// Exemplo de integração OAuth2 no onboarding
/// Este exemplo mostra como integrar autenticação OAuth2 diretamente no onboarding
/// para criar perfil com foto automaticamente
class OnboardingOAuth2Example extends ConsumerStatefulWidget {
  const OnboardingOAuth2Example({super.key});

  @override
  ConsumerState<OnboardingOAuth2Example> createState() =>
      _OnboardingOAuth2ExampleState();
}

class _OnboardingOAuth2ExampleState
    extends ConsumerState<OnboardingOAuth2Example> {
  bool _isAuthenticating = false;
  String? _error;

  /// Autenticar com Google e criar perfil
  Future<void> _authenticateWithGoogle() async {
    final strings = ref.read(appStringsProvider);
    setState(() {
      _isAuthenticating = true;
      _error = null;
    });

    try {
      // Fazer autenticação OAuth2
      final result = await OAuth2Service.authenticateGoogle();

      if (result.success) {
        // Criar perfil com dados do OAuth2
        await ref.read(userProfileProvider.notifier).createProfileFromOAuth(
              name: result.userName ?? strings.user,
              email: result.userEmail ?? '',
              avatarPath: result.avatarPath,
              avatarUrl: result.avatarUrl,
            );

        // Mostrar sucesso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.profileCreatedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );

          // Navegar para workspace
          context.goNamed('workspace');
        }
      } else {
        setState(() {
          _error = result.error;
        });
      }
    } catch (e) {
      setState(() {
        _error = strings.errorAuthenticating.replaceAll('%s', e.toString());
      });
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  /// Autenticar com Microsoft e criar perfil
  Future<void> _authenticateWithMicrosoft() async {
    final strings = ref.read(appStringsProvider);
    setState(() {
      _isAuthenticating = true;
      _error = null;
    });

    try {
      // Fazer autenticação OAuth2
      final result = await OAuth2Service.authenticateMicrosoft();

      if (result.success) {
        // Criar perfil com dados do OAuth2
        await ref.read(userProfileProvider.notifier).createProfileFromOAuth(
              name: result.userName ?? strings.user,
              email: result.userEmail ?? '',
              avatarPath: result.avatarPath,
              avatarUrl: result.avatarUrl,
            );

        // Mostrar sucesso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.profileCreatedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );

          // Navegar para workspace
          context.goNamed('workspace');
        }
      } else {
        setState(() {
          _error = result.error;
        });
      }
    } catch (e) {
      setState(() {
        _error = strings.errorAuthenticating.replaceAll('%s', e.toString());
      });
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo e título
                Icon(
                  PhosphorIcons.userCircle(),
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),

                Text(
                  strings.welcomeToBloquinhoOAuth,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Text(
                  strings.oauthLoginPrompt,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Botões OAuth2
                if (_isAuthenticating)
                  Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(strings.authenticating),
                    ],
                  )
                else ...[
                  // Botão Google
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _authenticateWithGoogle,
                      icon: Icon(PhosphorIcons.googleLogo()),
                      label: Text(strings.continueWithGoogle),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botão Microsoft
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _authenticateWithMicrosoft,
                      icon: Icon(PhosphorIcons.microsoftOutlookLogo()),
                      label: Text(strings.continueWithMicrosoft),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0078D4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Link para criação manual
                  TextButton(
                    onPressed: () {
                      // Navegar para onboarding manual
                      context.goNamed('onboarding');
                    },
                    child: Text(
                      strings.createProfileManually,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],

                // Erro
                if (_error != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIcons.warning(),
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para demonstrar como o perfil com foto fica após OAuth2
class ProfilePreviewWidget extends ConsumerWidget {
  const ProfilePreviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final strings = ref.watch(appStringsProvider);

    if (profile == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: profile.avatarUrl != null
                  ? Image.network(
                      profile.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildFallback(context, profile),
                    )
                  : _buildFallback(context, profile),
            ),
          ),
          const SizedBox(width: 16),

          // Dados do perfil
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    strings.profileConfigured,
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback(BuildContext context, profile) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Center(
        child: Text(
          profile.initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
