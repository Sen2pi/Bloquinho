import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../../shared/providers/theme_provider.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../shared/providers/storage_settings_provider.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/storage_settings.dart';
import '../../../core/models/app_language.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/onedrive_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/bloquinho_storage_service.dart';
import '../../../core/models/workspace.dart';
import '../../../core/l10n/app_strings.dart';
import '../../bloquinho/models/page_model.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Dados do usuário
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  dynamic _selectedImage; // Pode ser File ou Uint8List
  CloudStorageProvider _selectedStorage = CloudStorageProvider.local;
  AppLanguage _selectedLanguage = AppLanguage.defaultLanguage;

  // Estados de loading
  bool _isCreatingUser = false;
  bool _isCompleted = false;
  bool _isCheckingOneDrive = false;
  bool _oneDriveAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkOneDriveAvailability();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Verificar se o OneDrive está disponível
  Future<void> _checkOneDriveAvailability() async {
    setState(() {
      _isCheckingOneDrive = true;
    });

    try {
      // Simular verificação de subscrição
      // Em produção, isso faria uma chamada real para verificar a conta
      await Future.delayed(const Duration(milliseconds: 500));

      // Por enquanto, assumir que está disponível
      // TODO: Implementar lógica real de verificação de subscrição
      setState(() {
        _oneDriveAvailable = true;
      });
    } catch (e) {
      setState(() {
        _oneDriveAvailable = false;
      });
    } finally {
      setState(() {
        _isCheckingOneDrive = false;
      });
    }
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        // No web, usar Uint8List
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImage = bytes;
        });
      } else {
        // No mobile, usar File
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _finishOnboarding() async {
    if (!mounted) return;

    // Verificar se temos dados válidos (já validados na página anterior)
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Por favor, volte e preencha todos os campos'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() {
      _isCreatingUser = true;
    });

    try {
      // Salvar perfil
      final userProfileNotifier = ref.read(userProfileProvider.notifier);
      await userProfileNotifier.createProfile(name: name, email: email);

      // Configurar storage
      final storageNotifier = ref.read(storageSettingsProvider.notifier);
      await storageNotifier.changeProvider(_selectedStorage);

      // Se OneDrive foi selecionado, fazer autenticação automática
      if (_selectedStorage == CloudStorageProvider.oneDrive) {
        final onedriveService = OneDriveService();
        final authResult = await onedriveService.authenticate();

        if (authResult.success) {
          // Conectar ao serviço
          await storageNotifier.connect();
        } else {
          throw Exception(
              'Falha na autenticação com OneDrive: ${authResult.errorMessage}');
        }
      }

      // Criar workspaces padrão
      final localStorageService = LocalStorageService();
      await localStorageService.initialize();

      // Criar os 3 workspaces padrão
      final workspaces = ['Pessoal', 'Trabalho', 'Projetos'];
      for (final workspaceName in workspaces) {
        // Criar estrutura de pastas para o perfil
        await localStorageService.createProfileStructure(name);

        // Criar workspace padrão
        final workspacePath =
            await localStorageService.createWorkspace(name, workspaceName);
        if (workspacePath == null) {
          throw Exception('Erro ao criar workspace padrão');
        }

        // Criar estrutura inicial do bloquinho para cada workspace
        final bloquinhoStorage = BloquinhoStorageService();
        await bloquinhoStorage.initialize();
        await bloquinhoStorage.createBloquinhoDirectory(name, workspaceName);

        // Criar página inicial para cada workspace
        // final initialPage = PageModel.create(
        //   title: 'Nova Página',
        //   content:
        //       '# Bem-vindo ao Bloquinho!\n\nEsta é sua primeira página no workspace **$workspaceName**.\n\nComece a escrever para criar seu conteúdo...',
        // );
        // await bloquinhoStorage.savePage(initialPage, name, workspaceName);
      }

      // Mostrar estado de conclusão
      if (mounted) {
        setState(() {
          _isCompleted = true;
        });

        // Aguardar um pouco para mostrar a animação
        await Future.delayed(const Duration(milliseconds: 1000));

        // Navegar para o workspace
        if (context.mounted) {
          context.goNamed('workspace');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar usuário: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingUser = false;
        });
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E293B),
                    const Color(0xFF334155),
                  ]
                : [
                    const Color(0xFFFFFFFF),
                    const Color(0xFFF8FAFC),
                    const Color(0xFFE2E8F0),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Indicador de progresso
              if (_currentPage > 0)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _previousPage,
                        icon: Icon(
                          PhosphorIcons.arrowLeft(),
                          color: isDarkMode
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (_currentPage + 1) / 4,
                          backgroundColor: isDarkMode
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${_currentPage + 1} de 4',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDarkMode
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                      ),
                    ],
                  ),
                ),

              // Conteúdo das páginas
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildLanguageSelectionPage(isDarkMode, strings),
                    _buildWelcomePage(isDarkMode, strings),
                    _buildUserInfoPage(isDarkMode, strings),
                    _buildStorageSelectionPage(isDarkMode, strings),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelectionPage(bool isDarkMode, AppStrings strings) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone de idioma
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.language,
                size: 60,
                color: AppColors.primary,
              ),
            )
                .animate()
                .scale(begin: const Offset(0.5, 0.5), duration: 800.ms)
                .fadeIn(duration: 600.ms),

            const SizedBox(height: 48),

            // Título
            Text(
              strings.chooseLanguage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            )
                .animate(delay: 400.ms)
                .fadeIn(duration: 800.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 16),

            // Subtítulo
            Text(
              strings.languageDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    height: 1.5,
                  ),
            )
                .animate(delay: 600.ms)
                .fadeIn(duration: 800.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 48),

            // Opções de idioma (apenas 3 idiomas)
            Column(
              children: [
                AppLanguage.portuguese,
                AppLanguage.english,
                AppLanguage.french,
              ].map((language) {
                return _buildLanguageOption(
                  language: language,
                  isDarkMode: isDarkMode,
                  delay: 800 +
                      ([
                            AppLanguage.portuguese,
                            AppLanguage.english,
                            AppLanguage.french
                          ].indexOf(language) *
                          200),
                );
              }).toList(),
            ),

            const SizedBox(height: 64),

            // Botão continuar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  // Salvar idioma selecionado
                  await ref
                      .read(languageProvider.notifier)
                      .setLanguage(_selectedLanguage);
                  _nextPage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  strings.continueButton,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
                .animate(delay: 1400.ms)
                .fadeIn(duration: 800.ms)
                .slideY(begin: 0.5, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required AppLanguage language,
    required bool isDarkMode,
    required int delay,
  }) {
    final isSelected = _selectedLanguage == language;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedLanguage = language;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : (isDarkMode ? AppColors.darkSurface : AppColors.lightSurface),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDarkMode ? AppColors.darkBorder : AppColors.lightBorder),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Bandeira
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Center(
                  child: Text(
                    language.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Nome do idioma
              Expanded(
                child: Text(
                  language.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : null,
                      ),
                ),
              ),

              // Indicador de seleção
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 600.ms)
        .slideX(begin: -0.3, end: 0);
  }

  Widget _buildWelcomePage(bool isDarkMode, AppStrings strings) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo animado com caneta e bloco
          Hero(
            tag: 'onboarding_logo',
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Bloco (papel)
                Container(
                  width: 200,
                  height: 260,
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Linhas do bloco
                      for (int i = 0; i < 8; i++)
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 4),
                          height: 2,
                          decoration: BoxDecoration(
                            color: (isDarkMode
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder)
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        )
                            .animate(delay: Duration(milliseconds: 200 * i))
                            .slideX(begin: -1, duration: 400.ms)
                            .fadeIn(),
                      const SizedBox(height: 24),
                      // Logo do app
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          isDarkMode
                              ? 'assets/images/logoDark.png'
                              : 'assets/images/logo.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      )
                          .animate(delay: 800.ms)
                          .scale(
                              begin: const Offset(0.5, 0.5), duration: 600.ms)
                          .fadeIn(),
                    ],
                  ),
                )
                    .animate()
                    .slideY(
                        begin: 0.5, duration: 800.ms, curve: Curves.easeOutBack)
                    .fadeIn(duration: 600.ms),

                // Caneta
                Positioned(
                  right: -20,
                  top: 40,
                  child: Transform.rotate(
                    angle: 0.3,
                    child: Container(
                      width: 8,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    .animate(delay: 1200.ms)
                    .slideX(begin: 1, duration: 600.ms, curve: Curves.easeOut)
                    .fadeIn(),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // Título
          Text(
            strings.welcomeToBloquinho,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
          )
              .animate(delay: 1600.ms)
              .fadeIn(duration: 800.ms)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: 24),

          // Subtítulo
          Text(
            strings.workspaceDescription,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  height: 1.5,
                ),
          )
              .animate(delay: 2000.ms)
              .fadeIn(duration: 800.ms)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: 64),

          // Botão começar
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                strings.startButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
              .animate(delay: 2400.ms)
              .fadeIn(duration: 800.ms)
              .slideY(begin: 0.5, end: 0),
        ],
      ),
    );
  }

  Widget _buildUserInfoPage(bool isDarkMode, AppStrings strings) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // Título
            Text(
              strings.createProfile,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),

            const SizedBox(height: 8),

            Text(
              strings.profileDescription,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
            )
                .animate(delay: 200.ms)
                .fadeIn(duration: 600.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 48),

            // Avatar
            Center(
              child: GestureDetector(
                onTap: _selectImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkMode
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    border: Border.all(
                      color: isDarkMode
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                      width: 2,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipOval(
                          child: kIsWeb
                              ? Image.memory(
                                  _selectedImage as Uint8List,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  _selectedImage as File,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              PhosphorIcons.camera(),
                              size: 32,
                              color: isDarkMode
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              strings.addPhoto,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isDarkMode
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                            ),
                          ],
                        ),
                ),
              ),
            )
                .animate(delay: 400.ms)
                .scale(begin: const Offset(0.8, 0.8), duration: 600.ms)
                .fadeIn(),

            const SizedBox(height: 48),

            // Nome
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: strings.fullName,
                prefixIcon: Icon(PhosphorIcons.user()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textInputAction: TextInputAction.next,
              enableInteractiveSelection: true,
              autocorrect: false,
              enableSuggestions: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return strings.pleaseEnterName;
                }
                return null;
              },
            )
                .animate(delay: 600.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 24),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: strings.email,
                prefixIcon: Icon(PhosphorIcons.envelope()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enableInteractiveSelection: true,
              autocorrect: false,
              enableSuggestions: false,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return strings.pleaseEnterEmail;
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value.trim())) {
                  return strings.pleaseEnterValidEmail;
                }
                return null;
              },
            )
                .animate(delay: 800.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0),

            const Spacer(),

            // Botão continuar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _nextPage();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  strings.continueButton,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
                .animate(delay: 1000.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.5, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSelectionPage(bool isDarkMode, AppStrings strings) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // Título
          Text(
            strings.chooseStorage,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),

          const SizedBox(height: 8),

          Text(
            strings.storageDescription,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 600.ms)
              .slideX(begin: -0.2, end: 0),

          const SizedBox(height: 48),

          // Opções de armazenamento
          _buildStorageOption(
            provider: CloudStorageProvider.local,
            title: strings.localStorage,
            subtitle: strings.localStorageDescription,
            icon: PhosphorIcons.desktop(),
            warning: strings.localStorageWarning,
            isDarkMode: isDarkMode,
            delay: 400,
          ),

          const SizedBox(height: 16),

          _buildStorageOption(
            provider: CloudStorageProvider.googleDrive,
            title: 'Google Drive',
            subtitle: strings.googleDriveDescription,
            icon: PhosphorIcons.cloud(),
            isDarkMode: isDarkMode,
            delay: 600,
          ),

          const SizedBox(height: 16),

          // OneDrive - mostrar apenas se disponível
          if (_isCheckingOneDrive)
            _buildOneDriveCheckingWidget(isDarkMode)
          else if (_oneDriveAvailable)
            _buildStorageOption(
              provider: CloudStorageProvider.oneDrive,
              title: 'OneDrive',
              subtitle: strings.oneDriveDescription,
              icon: PhosphorIcons.cloud(),
              isDarkMode: isDarkMode,
              delay: 800,
            )
          else
            _buildOneDriveUnavailableWidget(isDarkMode),

          const Spacer(),

          // Botão finalizar
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed:
                  (_isCreatingUser || _isCompleted) ? null : _finishOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isCompleted ? AppColors.success : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isCompleted
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          strings.completedButton,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : _isCreatingUser
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          strings.startUsingButton,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
            ),
          )
              .animate(delay: 1000.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.5, end: 0),
        ],
      ),
    );
  }

  Widget _buildStorageOption({
    required CloudStorageProvider provider,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDarkMode,
    required int delay,
    String? warning,
  }) {
    final isSelected = _selectedStorage == provider;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStorage = provider;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : (isDarkMode ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDarkMode ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Ícone
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDarkMode
                        ? AppColors.darkBorder
                        : AppColors.lightBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
            ),

            const SizedBox(width: 16),

            // Conteúdo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primary : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                  ),
                  if (warning != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIcons.warning(),
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              warning,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.warning,
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

            // Indicador de seleção
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  /// Widget para mostrar carregamento do OneDrive
  Widget _buildOneDriveCheckingWidget(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Ícone com loading
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Conteúdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OneDrive',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Verificando disponibilidade...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget para mostrar OneDrive não disponível
  Widget _buildOneDriveUnavailableWidget(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkSurface.withOpacity(0.5)
            : AppColors.lightSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? AppColors.darkBorder.withOpacity(0.5)
              : AppColors.lightBorder.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Ícone desabilitado
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.darkBorder.withOpacity(0.5)
                  : AppColors.lightBorder.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              PhosphorIcons.cloud(),
              color: isDarkMode
                  ? AppColors.darkTextSecondary.withOpacity(0.5)
                  : AppColors.lightTextSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 16),
          // Conteúdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OneDrive',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? AppColors.darkTextSecondary.withOpacity(0.7)
                            : AppColors.lightTextSecondary.withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Requer subscrição ativa do OneDrive',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextSecondary.withOpacity(0.5)
                            : AppColors.lightTextSecondary.withOpacity(0.5),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
