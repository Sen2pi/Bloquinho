import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../shared/providers/theme_provider.dart';

class AppThemeSettingsScreen extends ConsumerStatefulWidget {
  const AppThemeSettingsScreen({super.key});

  @override
  ConsumerState<AppThemeSettingsScreen> createState() =>
      _AppThemeSettingsScreenState();
}

class _AppThemeSettingsScreenState
    extends ConsumerState<AppThemeSettingsScreen> {
  ThemeMode? _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = ref.read(themeProvider);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsProvider.of(ref.watch(languageProvider));
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.settingsTheme),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              strings.settingsTheme,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildThemeCard(context, ThemeMode.light, strings.themeLight,
                    Icons.wb_sunny),
                _buildThemeCard(context, ThemeMode.dark, strings.themeDark,
                    Icons.nightlight_round),
                _buildThemeCard(context, ThemeMode.system, strings.themeSystem,
                    Icons.settings_system_daydream),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.preview, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          strings.preview,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildThemePreview(
                        context, _selectedTheme ?? currentTheme, strings),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(
      BuildContext context, ThemeMode mode, String name, IconData icon) {
    final isSelected = _selectedTheme == mode;
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: isSelected ? 4 : 2,
        color:
            isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedTheme = mode;
            });
            ref.read(themeConfigProvider.notifier).setTheme(mode);
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 32),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemePreview(
      BuildContext context, ThemeMode mode, AppStrings strings) {
    // Simula uma tela do app com botões, textos, etc, para preview do tema
    final theme = Theme.of(context);
    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              strings.preview,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Bloquinho App',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: Text(strings.startUsingButton),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {},
              child: Text(strings.completedButton),
            ),
            const SizedBox(height: 8),
            Text(
              strings.settingsThemeDescription,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
