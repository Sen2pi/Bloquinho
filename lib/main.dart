import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'shared/providers/theme_provider.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/workspace/screens/workspace_screen.dart';
import 'features/backup/screens/backup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive para armazenamento local
  await Hive.initFlutter();

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

class BloquinhoApp extends ConsumerWidget {
  const BloquinhoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

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
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],

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
          path: 'document/:id',
          name: 'document',
          builder: (context, state) {
            final documentId = state.pathParameters['id'] ?? '';
            return DocumentScreen(documentId: documentId);
          },
        ),
        GoRoute(
          path: 'backup',
          name: 'backup',
          builder: (context, state) => const BackupScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthScreen(),
    ),
  ],
  errorBuilder: (context, state) => const NotFoundScreen(),
);

// Tela de documento (placeholder)
class DocumentScreen extends StatelessWidget {
  final String documentId;

  const DocumentScreen({
    super.key,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Documento $documentId'),
      ),
      body: const Center(
        child: Text('Editor de documento em desenvolvimento...'),
      ),
    );
  }
}

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
              'logo.png',
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
