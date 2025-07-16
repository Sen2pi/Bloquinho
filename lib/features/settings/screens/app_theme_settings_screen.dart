import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/app_theme.dart';

class AppThemeSettingsScreen extends ConsumerStatefulWidget {
  const AppThemeSettingsScreen({super.key});

  @override
  ConsumerState<AppThemeSettingsScreen> createState() =>
      _AppThemeSettingsScreenState();
}

class _AppThemeSettingsScreenState
    extends ConsumerState<AppThemeSettingsScreen> {
  ThemeMode? _selectedTheme;
  AppThemeType? _previewThemeType;

  @override
  void initState() {
    super.initState();
    _selectedTheme = ref.read(themeProvider);
    _previewThemeType = null;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsProvider.of(ref.watch(languageProvider));
    final currentTheme = ref.watch(themeProvider);
    final currentThemeType = ref.watch(themeConfigProvider).themeType;

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
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final themeType in AppThemeType.values)
                  _buildThemeCard(
                      context, themeType, currentThemeType, strings),
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
                        context,
                        _selectedTheme ?? currentTheme,
                        _previewThemeType ?? currentThemeType,
                        strings),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, AppThemeType themeType,
      AppThemeType currentThemeType, AppStrings strings) {
    final isSelected = currentThemeType == themeType;
    final color = AppColors.getPrimaryColor(themeType);
    final bg = AppColors.getLightBackgroundColor(themeType);
    final text = AppColors.getLightTextPrimaryColor(themeType);
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: isSelected ? 4 : 2,
        color: isSelected ? color.withOpacity(0.1) : null,
        child: InkWell(
          onTap: () {
            setState(() {
              _previewThemeType = themeType;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(themeType.icon, size: 32, color: color),
                const SizedBox(height: 8),
                Text(
                  themeType.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildColorPreview(bg),
                    const SizedBox(width: 4),
                    _buildColorPreview(color),
                    const SizedBox(width: 4),
                    _buildColorPreview(text),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  themeType.description,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorPreview(Color color) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildThemePreview(BuildContext context, ThemeMode mode,
      AppThemeType themeType, AppStrings strings) {
    // Simula uma tela do app com botões, textos, etc, para preview do tema
    final theme = Theme.of(context);
    final color = AppColors.getPrimaryColor(themeType);
    final bg = AppColors.getLightBackgroundColor(themeType);
    final text = AppColors.getLightTextPrimaryColor(themeType);
    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bg,
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
              style: theme.textTheme.headlineSmall?.copyWith(color: text),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Bloquinho App',
              style: theme.textTheme.titleLarge?.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: color),
              onPressed: () {},
              child: Text(strings.startUsingButton),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: color),
              onPressed: () {},
              child: Text(strings.completedButton),
            ),
            const SizedBox(height: 8),
            Text(
              themeType.description,
              style: theme.textTheme.bodyMedium?.copyWith(color: text),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
