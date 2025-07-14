/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/models/app_language.dart';
import 'core/services/user_profile_service.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/file_storage_service.dart';
import 'core/services/oauth2_service.dart';
import 'core/services/data_directory_service.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/providers/language_provider.dart';
import 'shared/providers/user_profile_provider.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/workspace/screens/workspace_screen.dart';
import 'features/backup/screens/backup_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/profile_edit_screen.dart';
import 'features/profile/screens/storage_settings_screen.dart';
import 'features/agenda/screens/agenda_screen.dart';
import 'features/passwords/screens/password_manager_screen.dart';
import 'features/documentos/screens/documentos_screen.dart';
import 'features/bloquinho/screens/bloquinho_dashboard_screen.dart';
import 'features/bloquinho/screens/bloco_editor_screen.dart';
import 'features/settings/screens/ai_settings_screen.dart';
import 'features/settings/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar DataDirectoryService primeiro
    final dataDirService = DataDirectoryService();
    await dataDirService.initialize();

    // Inicializar Hive para armazenamento local com diretório correto
    final basePath = await dataDirService.getBasePath();
    await Hive.initFlutter(basePath);

    // Inicializar serviços críticos
    await _initializeServices();
  } catch (e) {}

  // Configurar orientação da tela
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    const ProviderScope(
      child: BloquinhoApp(),
    ),
  );
}

/// Inicializar serviços essenciais da aplicação
Future<void> _initializeServices() async {
  try {
    // Hive já foi inicializado no main()

    // Inicializar LocalStorageService (sistema antigo para compatibilidade)
    final localStorageService = LocalStorageService();
    await localStorageService.initialize();

    // Inicializar FileStorageService (novo sistema)
    final fileStorageService = FileStorageService();
    await fileStorageService.initialize();

    // Inicializar OAuth2Service
    await OAuth2Service.initialize();

    // Restaurar sessões OAuth2 existentes (conexões persistentes)
    // Delay para permitir inicialização completa do app
    await Future.delayed(const Duration(milliseconds: 500));
    await OAuth2Service.restoreExistingSessions();

    // UserProfileService será inicializado no provider conforme necessário
  } catch (e) {}
}

class BloquinhoApp extends ConsumerWidget {
  const BloquinhoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final currentLocale = ref.watch(currentLocaleProvider);

    return MaterialApp.router(
      title: 'Bloquinho',
      debugShowCheckedModeBanner: false,

      // Configuração de temas
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Configuração de roteamento
      routerConfig: _router,

      // Configurações de localização
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLanguage.supportedLocales,
      locale: currentLocale,

      // Builder para configurações globais
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling, // Evita zoom de texto do sistema
          ),
          child: child!,
        );
      },
    );
  }
}

// Configuração de rotas com GoRouter
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/workspace',
      name: 'workspace',
      builder: (context, state) => const WorkspaceScreen(),
      routes: [
        GoRoute(
          path: 'backup',
          name: 'backup',
          builder: (context, state) => const BackupScreen(),
        ),
        GoRoute(
          path: 'profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: 'profile/edit',
          name: 'profile_edit',
          builder: (context, state) => const ProfileEditScreen(),
        ),
        GoRoute(
          path: 'profile/storage',
          name: 'storage_settings',
          builder: (context, state) => const StorageSettingsScreen(),
        ),
        GoRoute(
          path: 'agenda',
          name: 'agenda',
          builder: (context, state) => const AgendaScreen(),
        ),
        GoRoute(
          path: 'passwords',
          name: 'passwords',
          builder: (context, state) => const PasswordManagerScreen(),
        ),
        GoRoute(
          path: 'documentos',
          name: 'documentos',
          builder: (context, state) => const DocumentosScreen(),
        ),
        GoRoute(
          path: 'bloquinho',
          name: 'bloquinho_dashboard',
          builder: (context, state) => const BloquinhoDashboardScreen(),
          routes: [
            GoRoute(
              path: 'editor',
              name: 'bloquinho_editor_new',
              builder: (context, state) {
                return const BlocoEditorScreen(
                  documentTitle: 'Nova Página',
                );
              },
            ),
            GoRoute(
              path: 'editor/:pageId',
              name: 'bloquinho_editor',
              builder: (context, state) {
                final pageId = state.pathParameters['pageId'];
                return BlocoEditorScreen(
                  documentId: pageId,
                  documentTitle: 'Página',
                );
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/ai_settings',
      name: 'ai_settings',
      builder: (context, state) => const AISettingsScreen(),
    ),
  ],
  errorBuilder: (context, state) => const NotFoundScreen(),
);

// Tela de autenticação (placeholder)
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 120,
              width: 120,
            ),
            const SizedBox(height: 32),
            const Text(
              'Bloquinho',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Seu workspace pessoal',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                context.goNamed('workspace');
              },
              child: const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}

// Tela de página não encontrada
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página não encontrada'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Página não encontrada',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.goNamed('workspace'),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    );
  }
}
