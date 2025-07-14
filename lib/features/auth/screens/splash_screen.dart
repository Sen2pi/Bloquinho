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

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Aguardar um tempo mínimo para mostrar splash
      await Future.delayed(const Duration(seconds: 1));

      // Carregar perfil salvo se existir
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

                String statusText = strings.initializing;
                if (isLoading) {
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
