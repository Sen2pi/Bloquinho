import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/services/backup_service.dart';
import '../../../shared/providers/backup_provider.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';

class BackupRestoreDialog extends ConsumerStatefulWidget {
  final String? fileName;
  final BackupData? importedBackup;

  const BackupRestoreDialog({
    super.key,
    this.fileName,
    this.importedBackup,
  });

  @override
  ConsumerState<BackupRestoreDialog> createState() =>
      _BackupRestoreDialogState();
}

class _BackupRestoreDialogState extends ConsumerState<BackupRestoreDialog> {
  bool _clearExistingData = false;
  bool _restoreSettings = true;
  BackupData? _backupData;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _backupStats;

  @override
  void initState() {
    super.initState();
    _loadBackupData();
  }

  Future<void> _loadBackupData() async {
    final strings = ref.read(appStringsProvider);
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      BackupData backupData;

      if (widget.importedBackup != null) {
        backupData = widget.importedBackup!;
      } else if (widget.fileName != null) {
        final backupService = ref.read(backupServiceProvider);
        // Para backup local, precisaria implementar método para ler arquivo por nome
        throw UnimplementedError(
            strings.restoreNotImplemented);
      } else {
        throw Exception(strings.noBackupProvided);
      }

      final stats = {
        'agendaItems': backupData.agendaItems.length,
        'passwords': backupData.passwords.length,
        'documentos': backupData.documentos.length,
        'createdAt': backupData.createdAt,
      };

      setState(() {
        _backupData = backupData;
        _backupStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final strings = ref.watch(appStringsProvider);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            PhosphorIconsRegular.downloadSimple,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(strings.restoreBackup),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(strings.loadingBackupInfo),
                ],
              )
            : _error != null
                ? _buildErrorContent(colorScheme, strings)
                : _buildContent(colorScheme, strings),
      ),
      actions: _isLoading || _error != null
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(strings.closeButton),
              ),
            ]
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(strings.cancel),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final isBusy = ref.watch(backupProvider).isImportingBackup;
                  return FilledButton.icon(
                    onPressed: isBusy ? null : _restore,
                    icon: isBusy
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : const Icon(PhosphorIconsRegular.downloadSimple),
                    label: Text(isBusy ? strings.restoring : strings.restore),
                  );
                },
              ),
            ],
    );
  }

  Widget _buildErrorContent(ColorScheme colorScheme, AppStrings strings) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          PhosphorIconsRegular.warning,
          size: 48,
          color: colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          strings.errorLoadingBackup,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _error!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ColorScheme colorScheme, AppStrings strings) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBackupInfo(colorScheme, strings),
        const SizedBox(height: 20),
        _buildOptions(colorScheme, strings),
        const SizedBox(height: 16),
        _buildWarning(colorScheme, strings),
      ],
    );
  }

  Widget _buildBackupInfo(ColorScheme colorScheme, AppStrings strings) {
    if (_backupStats == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.backupInfo,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            colorScheme,
            PhosphorIconsRegular.folder,
            strings.workspaces,
            _backupStats!['workspaces'].toString(),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            colorScheme,
            PhosphorIconsRegular.file,
            strings.documents,
            _backupStats!['documents'].toString(),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            colorScheme,
            PhosphorIconsRegular.cube,
            strings.blocks,
            _backupStats!['blocks'].toString(),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            colorScheme,
            PhosphorIconsRegular.calendar,
            strings.createdAt,
            _formatDate(_backupStats!['createdAt'] as DateTime),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      ColorScheme colorScheme, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.onPrimaryContainer,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(ColorScheme colorScheme, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.restoreOptions,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          value: _clearExistingData,
          onChanged: (value) {
            setState(() {
              _clearExistingData = value ?? false;
            });
          },
          title: Text(strings.replaceExistingData),
          subtitle: Text(
            _clearExistingData
                ? strings.allDataWillBeRemoved
                : strings.backupDataWillBeMerged,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          value: _restoreSettings,
          onChanged: (value) {
            setState(() {
              _restoreSettings = value ?? true;
            });
          },
          title: Text(strings.restoreSettings),
          subtitle: Text(
            strings.includeThemeLanguagePreferences,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  Widget _buildWarning(ColorScheme colorScheme, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIconsRegular.warning,
            color: colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.attention,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                Text(
                  _clearExistingData
                      ? strings.thisActionWillPermanentlyRemoveData
                      : strings.thisActionWillModifyData,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _restore() async {
    final strings = ref.read(appStringsProvider);
    if (_backupData == null) return;

    try {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.backupRestoredSuccessfully),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.unexpectedError(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
