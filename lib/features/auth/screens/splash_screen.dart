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
import 'package:flutter_animate/flutter_animate.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../core/services/platform_service.dart';
import '../../../core/services/web_auth_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _isAuthenticating = false;
  String _currentStatus = 'Inicializando...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Aguardar um tempo mínimo para mostrar splash
      await Future.delayed(const Duration(seconds: 1));

      final platformService = PlatformService.instance;
      final webAuthService = WebAuthService.instance;

      // Verificar se é web e precisa de autenticação
      if (platformService.isWeb && !webAuthService.isAuthenticated) {
        setState(() {
          _currentStatus = 'Autenticação necessária para a web';
          _isAuthenticating = true;
        });
        
        // Mostrar dialog de autenticação
        await _showWebAuthDialog();
        
        // Verificar se folder existe e criar se necessário
        final folderExists = await webAuthService.ensureCloudFolderExists();
        if (!folderExists) {
          setState(() {
            _currentStatus = 'Erro ao criar pasta de dados';
          });
          return;
        }
      }

      // Carregar perfil salvo se existir
      setState(() {
        _currentStatus = 'Carregando dados salvos...';
      });
      
      try {
        await ref.read(userProfileProvider.notifier).loadProfile();
      } catch (e) {
        // Continuar mesmo com erro - pode não existir perfil
      }

      // Aguardar mais um pouco para animações
      await Future.delayed(const Duration(milliseconds: 500));

      // Verificar se há perfil criado
      final hasProfile = ref.read(hasProfileProvider);
      final profile = ref.read(currentProfileProvider);

      if (mounted) {
        // Verificação simplificada: se tem perfil, vai para workspace
        if (hasProfile && profile != null) {
          // Usuário já existe, ir para workspace
          context.goNamed('workspace');
        } else {
          // Primeiro acesso ou perfil deletado, mostrar onboarding
          context.goNamed('onboarding');
        }
      }
    } catch (e) {
      // Em caso de erro, mostrar onboarding como fallback
      if (mounted) {
        context.goNamed('onboarding');
      }
    }
  }

  Future<void> _showWebAuthDialog() async {
    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const WebAuthDialog(),
    );

    if (result != true) {
      // Usuário não autenticou, mostrar erro
      setState(() {
        _currentStatus = 'Autenticação necessária para continuar';
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E293B),
                  ]
                : [
                    const Color(0xFFFFFFFF),
                    const Color(0xFFF8FAFC),
                  ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            Hero(
              tag: 'logo',
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    isDarkMode
                        ? 'assets/images/logoDark.png'
                        : 'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
                .animate()
                .scale(
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 600.ms),

            const SizedBox(height: 32),

            // Nome da aplicação
            Text(
              'Bloquinho',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
            )
                .animate(delay: 200.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 16),

            // Descrição
            Text(
              strings.personalWorkspace,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            )
                .animate(delay: 400.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 64),

            // Indicador de carregamento
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            )
                .animate(delay: 600.ms)
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.5, 0.5)),

            const SizedBox(height: 24),

            // Status de carregamento
            Consumer(
              builder: (context, ref, child) {
                final isLoading = ref.watch(isProfileLoadingProvider);
                final hasProfile = ref.watch(hasProfileProvider);

                String statusText = _currentStatus;
                if (_isAuthenticating) {
                  statusText = 'Aguardando autenticação...';
                } else if (isLoading) {
                  statusText = strings.loadingSavedData;
                } else if (hasProfile) {
                  statusText = strings.profileFound;
                } else {
                  statusText = strings.firstAccessDetected;
                }

                return Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog para autenticação na web
class WebAuthDialog extends StatefulWidget {
  const WebAuthDialog({super.key});

  @override
  State<WebAuthDialog> createState() => _WebAuthDialogState();
}

class _WebAuthDialogState extends State<WebAuthDialog> {
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Autenticação Necessária'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Para usar o Bloquinho na web, é necessário autenticar com um serviço de armazenamento em nuvem.',
          ),
          const SizedBox(height: 16),
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          if (_errorMessage != null) const SizedBox(height: 16),
          if (_isAuthenticating)
            const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Autenticando...'),
              ],
            ),
        ],
      ),
      actions: [
        if (!_isAuthenticating) ...[
          TextButton(
            onPressed: () => _authenticateWithProvider('google'),
            child: const Text('Google Drive'),
          ),
          TextButton(
            onPressed: () => _authenticateWithProvider('onedrive'),
            child: const Text('OneDrive'),
          ),
        ],
      ],
    );
  }

  Future<void> _authenticateWithProvider(String provider) async {
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final webAuthService = WebAuthService.instance;
      
      late final result;
      if (provider == 'google') {
        result = await webAuthService.authenticateWithGoogleDrive();
      } else if (provider == 'onedrive') {
        result = await webAuthService.authenticateWithOneDrive();
      } else {
        throw Exception('Provider não suportado');
      }

      if (result.success) {
        // Autenticação bem-sucedida
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() {
          _errorMessage = result.errorMessage ?? 'Erro desconhecido';
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao autenticar: ${e.toString()}';
        _isAuthenticating = false;
      });
    }
  }
}
