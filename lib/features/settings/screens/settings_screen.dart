import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/models/app_language.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/providers/huggingface_token_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final currentLanguage = ref.watch(languageProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Seção de Idioma
          _buildSection(
            context,
            title: strings.settingsLanguage,
            description: strings.settingsLanguageDescription,
            icon: Icons.language,
            onTap: () => _showLanguageDialog(context, ref),
            trailing: _getLanguageDisplayName(currentLanguage),
          ),

          const SizedBox(height: 16),

          // Seção de Tema
          _buildSection(
            context,
            title: strings.settingsTheme,
            description: strings.settingsThemeDescription,
            icon: Icons.palette,
            onTap: () => _showThemeDialog(context, ref),
            trailing: _getThemeDisplayName(themeMode),
          ),

          const SizedBox(height: 16),

          // Seção de Backup
          _buildSection(
            context,
            title: strings.settingsBackup,
            description: strings.settingsBackupDescription,
            icon: Icons.backup,
            onTap: () => context.pushNamed('backup'),
          ),

          const SizedBox(height: 16),

          // Seção de Armazenamento
          _buildSection(
            context,
            title: strings.settingsStorage,
            description: strings.settingsStorageDescription,
            icon: Icons.storage,
            onTap: () => context.pushNamed('storage_settings'),
          ),

          const SizedBox(height: 16),

          // Seção de Perfil
          _buildSection(
            context,
            title: strings.settingsProfile,
            description: strings.settingsProfileDescription,
            icon: Icons.person,
            onTap: () => context.pushNamed('profile'),
          ),

          // Seção de IA
          _buildSection(
            context,
            title: 'Configurações de IA',
            description: 'Token Hugging Face e integração de IA',
            icon: Icons.smart_toy,
            onTap: () => context.pushNamed('ai_settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    String? trailing,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 24),
        title: Text(title),
        subtitle: Text(description),
        trailing: trailing != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trailing,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  String _getLanguageDisplayName(AppLanguage language) {
    switch (language) {
      case AppLanguage.portuguese:
        return 'Português';
      case AppLanguage.english:
        return 'English';
      case AppLanguage.french:
        return 'Français';
    }
  }

  String _getThemeDisplayName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final strings = ref.read(appStringsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.settingsLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context,
              ref,
              AppLanguage.portuguese,
              'Português',
              '🇧🇷',
            ),
            _buildLanguageOption(
              context,
              ref,
              AppLanguage.english,
              'English',
              '🇺🇸',
            ),
            _buildLanguageOption(
              context,
              ref,
              AppLanguage.french,
              'Français',
              '🇫🇷',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    AppLanguage language,
    String name,
    String flag,
  ) {
    final currentLanguage = ref.watch(languageProvider);
    final isSelected = currentLanguage == language;

    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      trailing: isSelected
          ? Icon(
              Icons.check,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () {
        ref.read(languageProvider.notifier).setLanguage(language);
        Navigator.of(context).pop();
      },
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final strings = ref.read(appStringsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.settingsTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context,
              ref,
              ThemeMode.light,
              'Claro',
              Icons.wb_sunny,
            ),
            _buildThemeOption(
              context,
              ref,
              ThemeMode.dark,
              'Escuro',
              Icons.nightlight_round,
            ),
            _buildThemeOption(
              context,
              ref,
              ThemeMode.system,
              'Sistema',
              Icons.settings_system_daydream,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    ThemeMode themeMode,
    String name,
    IconData icon,
  ) {
    final currentTheme = ref.watch(themeProvider);
    final isSelected = currentTheme == themeMode;

    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      trailing: isSelected
          ? Icon(
              Icons.check,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () {
        ref.read(themeProvider.notifier).setTheme(themeMode);
        Navigator.of(context).pop();
      },
    );
  }
}
