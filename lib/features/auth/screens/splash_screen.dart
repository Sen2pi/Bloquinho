import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../shared/providers/user_profile_provider.dart';

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
      // Aguardar um pouco para mostrar a splash screen
      await Future.delayed(const Duration(seconds: 2));

      // Carregar perfil salvo
      await ref.read(userProfileProvider.notifier).loadProfile();

      // Verificar se há perfil válido
      final profileState = ref.read(userProfileProvider);
      final hasProfile = profileState.profile != null;
      final isLoading = profileState.isLoading;

      if (!isLoading) {
        if (hasProfile) {
          final profile = profileState.profile!;

          // Navegar para workspace se perfil estiver completo
          if (profile.isComplete) {
            if (mounted) {
              context.go('/workspace');
            }
          } else {
            // Navegar para onboarding se perfil estiver incompleto
            if (mounted) {
              context.go('/onboarding');
            }
          }
        } else {
          // Navegar para onboarding se não há perfil
          if (mounted) {
            context.go('/onboarding');
          }
        }
      }
    } catch (e) {
      // Em caso de erro, ir para onboarding
      if (mounted) {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo do app
            Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 32),

            // Nome do app
            Text(
              'Bloquinho',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),

            // Subtítulo
            Text(
              'Sua vida organizada',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
