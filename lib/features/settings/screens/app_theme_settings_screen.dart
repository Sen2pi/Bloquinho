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
  ThemeMode _selectedThemeMode = ThemeMode.system;
  AppThemeType _selectedLightTheme = AppThemeType.classic;
  AppThemeType _selectedDarkTheme = AppThemeType.midnight;
  AppThemeType? _previewThemeType;
  bool _previewDarkMode = false;

  @override
  void initState() {
    super.initState();
    final config = ref.read(themeConfigProvider);
    _selectedThemeMode = config.themeMode;
    _selectedLightTheme = config.lightThemeType;
    _selectedDarkTheme = config.darkThemeType;
  }


  @override
  Widget build(BuildContext context) {
    final strings = AppStringsProvider.of(ref.watch(languageProvider));
    final currentTheme = ref.watch(themeProvider);
    final currentThemeType = ref.watch(themeConfigProvider).themeType;
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.settingsTheme),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveThemeSettings,
            tooltip: 'Salvar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Seleção de modo de tema
          _buildThemeModeSelector(context, strings),
          
          // Separador
          const Divider(height: 1),
          
          // Abas para Light/Dark
          _buildThemeTabBar(context, strings, isDarkMode),
          
          // Lista de temas
          Expanded(
            child: _buildThemesList(context, strings, isDarkMode),
          ),
          
          // Preview
          _buildPreviewSection(context, strings),
        ],
      ),
    );
  }

  Widget _buildThemeModeSelector(BuildContext context, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Modo de Tema',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildThemeModeOption(
                  context,
                  ThemeMode.light,
                  'Claro',
                  Icons.light_mode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeModeOption(
                  context,
                  ThemeMode.dark,
                  'Escuro',
                  Icons.dark_mode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeModeOption(
                  context,
                  ThemeMode.system,
                  'Sistema',
                  Icons.settings_system_daydream,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeOption(BuildContext context, ThemeMode mode, String title, IconData icon) {
    final isSelected = _selectedThemeMode == mode;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedThemeMode = mode;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppColors.primary : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTabBar(BuildContext context, AppStrings strings, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _previewDarkMode = false;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: !_previewDarkMode ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1,
                  ),
                ),
                child: Text(
                  'Temas Claros',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: !_previewDarkMode ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _previewDarkMode = true;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _previewDarkMode ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1,
                  ),
                ),
                child: Text(
                  'Temas Escuros',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _previewDarkMode ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemesList(BuildContext context, AppStrings strings, bool isDarkMode) {
    final themes = _getThemesForMode(_previewDarkMode);
    final selectedTheme = _previewDarkMode ? _selectedDarkTheme : _selectedLightTheme;
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final themeType = themes[index];
        return _buildThemeListItem(context, themeType, selectedTheme, strings);
      },
    );
  }

  List<AppThemeType> _getThemesForMode(bool isDark) {
    if (isDark) {
      return [
        AppThemeType.midnight,
        AppThemeType.cyberpunk,
        AppThemeType.professional,
        AppThemeType.minimal,
        AppThemeType.creative,
        AppThemeType.nature,
        AppThemeType.tech,
        AppThemeType.aurora,
        AppThemeType.classic,
      ];
    } else {
      return [
        AppThemeType.classic,
        AppThemeType.modern,
        AppThemeType.minimal,
        AppThemeType.colorful,
        AppThemeType.professional,
        AppThemeType.creative,
        AppThemeType.nature,
        AppThemeType.tech,
        AppThemeType.sunset,
        AppThemeType.ocean,
        AppThemeType.forest,
        AppThemeType.desert,
        AppThemeType.vintage,
      ];
    }
  }

  Widget _buildThemeListItem(BuildContext context, AppThemeType themeType, AppThemeType selectedTheme, AppStrings strings) {
    final isSelected = selectedTheme == themeType;
    final color = AppColors.getPrimaryColor(themeType);
    final bg = _previewDarkMode 
        ? AppColors.getDarkBackgroundColor(themeType)
        : AppColors.getLightBackgroundColor(themeType);
    final text = _previewDarkMode 
        ? AppColors.getDarkTextPrimaryColor(themeType)
        : AppColors.getLightTextPrimaryColor(themeType);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: isSelected ? 4 : 1,
        color: isSelected ? color.withOpacity(0.1) : null,
        child: InkWell(
          onTap: () {
            setState(() {
              _previewThemeType = themeType;
              if (_previewDarkMode) {
                _selectedDarkTheme = themeType;
              } else {
                _selectedLightTheme = themeType;
              }
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(themeType.icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        themeType.displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : null,
                        ),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildColorPreview(bg),
                    const SizedBox(width: 4),
                    _buildColorPreview(color),
                    const SizedBox(width: 4),
                    _buildColorPreview(text),
                  ],
                ),
                const SizedBox(width: 16),
                if (isSelected)
                  Icon(Icons.check_circle, color: color, size: 24)
                else
                  Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 24),
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

  Widget _buildPreviewSection(BuildContext context, AppStrings strings) {
    final themeType = _previewThemeType ?? (_previewDarkMode ? _selectedDarkTheme : _selectedLightTheme);
    
    return Container(
      height: 200,
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
                  'Preview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Switch(
                  value: _previewDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _previewDarkMode = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Text(_previewDarkMode ? 'Dark' : 'Light'),
              ],
            ),
          ),
          Expanded(
            child: _buildThemePreview(context, themeType, strings),
          ),
        ],
      ),
    );
  }

  Widget _buildThemePreview(BuildContext context, AppThemeType themeType, AppStrings strings) {
    final color = AppColors.getPrimaryColor(themeType);
    final bg = _previewDarkMode
        ? AppColors.getDarkBackgroundColor(themeType)
        : AppColors.getLightBackgroundColor(themeType);
    final surface = _previewDarkMode
        ? AppColors.getDarkSurfaceColor(themeType)
        : AppColors.getLightSurfaceColor(themeType);
    final text = _previewDarkMode
        ? AppColors.getDarkTextPrimaryColor(themeType)
        : AppColors.getLightTextPrimaryColor(themeType);
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  themeType.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Botão',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: color),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Outline',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveThemeSettings() async {
    try {
      final themeNotifier = ref.read(themeConfigProvider.notifier);
      
      // Salvar modo de tema
      await themeNotifier.setThemeMode(_selectedThemeMode);
      
      // Salvar ambos os temas
      await themeNotifier.setLightThemeType(_selectedLightTheme);
      await themeNotifier.setDarkThemeType(_selectedDarkTheme);
      
      // Mostrar feedback de sucesso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tema salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Mostrar erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar tema: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
