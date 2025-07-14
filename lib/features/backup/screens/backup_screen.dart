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
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';

import '../../../shared/providers/backup_provider.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../shared/providers/workspace_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/backup_service.dart';
import '../widgets/backup_card.dart';
import '../widgets/backup_restore_dialog.dart';
import '../widgets/backup_import_dialog.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _showAdvancedOptions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(backupProvider.notifier).loadLocalBackups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final backupState = ref.watch(backupProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final currentProfile = ref.watch(currentProfileProvider);
    final currentWorkspace = ref.watch(currentWorkspaceProvider);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(strings.backupAndSync),
        backgroundColor:
            isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        foregroundColor:
            isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showAdvancedOptions = !_showAdvancedOptions;
              });
            },
            icon: Icon(_showAdvancedOptions
                ? PhosphorIcons.caretUp()
                : PhosphorIcons.caretDown()),
            tooltip: strings.advancedOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(isDarkMode, currentProfile, currentWorkspace, strings),
          if (_showAdvancedOptions) _buildAdvancedOptions(isDarkMode, strings),
          Expanded(
            child: _buildBackupList(backupState, isDarkMode, strings),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(isDarkMode, strings),
    );
  }

  Widget _buildHeader(
      bool isDarkMode, dynamic currentProfile, dynamic currentWorkspace, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.downloadSimple(),
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.backupAndSync,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      strings.manageBackupsAndImportNotion,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
          const SizedBox(height: 16),
          _buildStatusCards(isDarkMode, currentProfile, currentWorkspace, strings),
        ],
      ),
    );
  }

  Widget _buildStatusCards(
      bool isDarkMode, dynamic currentProfile, dynamic currentWorkspace, AppStrings strings) {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            isDarkMode,
            PhosphorIcons.user(),
            strings.profile,
            currentProfile?.name ?? strings.notDefined,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatusCard(
            isDarkMode,
            PhosphorIcons.buildings(),
            strings.workspace,
            currentWorkspace?.name ?? strings.notDefined,
            AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
      bool isDarkMode, IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptions(bool isDarkMode, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.advancedOptions,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _createWorkspaceBackup,
                  icon: Icon(PhosphorIcons.archive(), size: 16),
                  label: Text(strings.backupWorkspace),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _importFromNotion,
                  icon: Icon(PhosphorIcons.upload(), size: 16),
                  label: Text(strings.importNotion),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: BorderSide(color: AppColors.secondary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackupList(BackupState backupState, bool isDarkMode, AppStrings strings) {
    if (backupState.localBackups.isEmpty) {
      return _buildEmptyState(isDarkMode, strings);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: backupState.localBackups.length,
      itemBuilder: (context, index) {
        final backup = backupState.localBackups[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BackupCard(
            backup: backup,
            onExport: () => _exportBackup(backup),
            onDelete: () => _deleteBackup(backup, strings),
            onRestore: () => _restoreBackup(backup, strings),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDarkMode, AppStrings strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.archive(),
            size: 64,
            color: isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            strings.noBackupFound,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.createFirstBackup,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(bool isDarkMode, AppStrings strings) {
    return FloatingActionButton.extended(
      onPressed: _createBackup,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: Icon(PhosphorIcons.plus()),
      label: Text(strings.createBackup),
    );
  }

  Future<void> _createBackup() async {
    final strings = ref.read(appStringsProvider);
    try {
      final backup = await ref.read(backupProvider.notifier).createBackup();
      if (backup != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.backupCreatedSuccessfully),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.errorCreatingBackup(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _createWorkspaceBackup() async {
    final strings = ref.read(appStringsProvider);
    try {
      final currentWorkspace = ref.read(currentWorkspaceProvider);
      final currentProfile = ref.read(currentProfileProvider);

      if (currentWorkspace == null || currentProfile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.selectWorkspaceAndProfile),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // TODO: Implementar backup de workspace completo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.featureInDevelopment),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.errorCreatingWorkspaceBackup(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _importFromNotion() async {
    final strings = ref.read(appStringsProvider);
    try {
      final currentWorkspace = ref.read(currentWorkspaceProvider);
      final currentProfile = ref.read(currentProfileProvider);

      if (currentWorkspace == null || currentProfile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.selectWorkspaceAndProfile),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // TODO: Implementar importação de pasta do Notion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.featureInDevelopment),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.errorImportingFromNotion(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _exportBackup(BackupMetadata backup) async {
    final strings = ref.read(appStringsProvider);
    try {
      // TODO: Implementar exportação de backup
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.featureInDevelopment),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.errorExportingBackup(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteBackup(BackupMetadata backup, AppStrings strings) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(strings.confirmExclusion),
          content: Text(
              strings.areYouSureYouWantToDeleteBackup(backup.fileName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(strings.delete),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // TODO: Implementar deleção de backup
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.featureInDevelopment),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.errorDeletingBackup(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _restoreBackup(BackupMetadata backup, AppStrings strings) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(strings.confirmRestore),
          content: Text(
              strings.areYouSureYouWantToRestoreBackup(backup.fileName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: Text(strings.restore),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // TODO: Implementar restauração de backup
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.featureInDevelopment),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.errorRestoringBackup(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
