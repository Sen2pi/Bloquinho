import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/backup_provider.dart';
import '../../../core/services/backup_service.dart';
import '../widgets/backup_card.dart';
import '../widgets/backup_import_dialog.dart';
import '../widgets/backup_restore_dialog.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(
          'Backup e Sincronização',
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: colors.onSurface),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.primary,
          unselectedLabelColor: colors.onSurface.withOpacity(0.6),
          indicatorColor: colors.primary,
          tabs: const [
            Tab(
              icon: Icon(PhosphorIconsRegular.downloadSimple),
              text: 'Meus Backups',
            ),
            Tab(
              icon: Icon(PhosphorIconsRegular.uploadSimple),
              text: 'Importar',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBackupsTab(colors),
          _buildImportTab(colors),
        ],
      ),
      floatingActionButton: _buildCreateBackupFAB(colors),
    );
  }

  Widget _buildCreateBackupFAB(AppColors colors) {
    return Consumer(
      builder: (context, ref, child) {
        final isCreating = ref.watch(isCreatingBackupProvider);
        final isBusy = ref.watch(isBackupBusyProvider);

        return FloatingActionButton.extended(
          onPressed: isBusy ? null : () => _createBackup(),
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          icon: isCreating
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(colors.onPrimary),
                  ),
                )
              : const Icon(PhosphorIconsRegular.plus),
          label: Text(isCreating ? 'Criando...' : 'Criar Backup'),
        );
      },
    );
  }

  Widget _buildBackupsTab(AppColors colors) {
    return Consumer(
      builder: (context, ref, child) {
        final backupState = ref.watch(backupProvider);
        final localBackups = backupState.localBackups;

        if (backupState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (backupState.error != null) {
          return _buildErrorWidget(colors, backupState.error!);
        }

        if (localBackups.isEmpty) {
          return _buildEmptyBackupsWidget(colors);
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(backupProvider.notifier).loadLocalBackups(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackupStats(colors, localBackups),
                const SizedBox(height: 16),
                Text(
                  'Backups Locais (${localBackups.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: localBackups.length,
                    itemBuilder: (context, index) {
                      final backup = localBackups[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BackupCard(
                          backup: backup,
                          onExport: () => _exportBackup(backup.fileName),
                          onDelete: () => _deleteBackup(backup.fileName),
                          onRestore: () => _showRestoreDialog(backup.fileName),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackupStats(AppColors colors, List<BackupMetadata> backups) {
    if (backups.isEmpty) return const SizedBox.shrink();

    final latestBackup = backups.first;
    final totalSize =
        backups.fold<int>(0, (sum, backup) => sum + backup.fileSize);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsRegular.info,
                color: colors.onPrimaryContainer,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Estatísticas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  colors,
                  'Total de Backups',
                  backups.length.toString(),
                  PhosphorIconsRegular.archive,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  colors,
                  'Espaço Usado',
                  _formatFileSize(totalSize),
                  PhosphorIconsRegular.harddrive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatItem(
            colors,
            'Último Backup',
            _formatDate(latestBackup.createdAt),
            PhosphorIconsRegular.clock,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      AppColors colors, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: colors.onPrimaryContainer, size: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colors.onPrimaryContainer.withOpacity(0.8),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImportTab(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.outline.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  PhosphorIconsRegular.uploadSimple,
                  size: 48,
                  color: colors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Importar Backup',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecione um arquivo de backup para restaurar seus dados',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final isImporting = ref.watch(isImportingBackupProvider);
                      final isBusy = ref.watch(isBackupBusyProvider);

                      return ElevatedButton.icon(
                        onPressed:
                            isBusy ? null : () => _importBackupWithPicker(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: isImporting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(colors.onPrimary),
                                ),
                              )
                            : const Icon(PhosphorIconsRegular.folderOpen),
                        label: Text(isImporting
                            ? 'Importando...'
                            : 'Selecionar Arquivo'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildImportInstructions(colors),
        ],
      ),
    );
  }

  Widget _buildImportInstructions(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsRegular.lightbulb,
                color: colors.onSecondaryContainer,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Como funciona',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.onSecondaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionItem(
            colors,
            '1. Selecione um arquivo .json de backup',
          ),
          _buildInstructionItem(
            colors,
            '2. O backup será validado automaticamente',
          ),
          _buildInstructionItem(
            colors,
            '3. Escolha se deseja substituir ou mesclar os dados',
          ),
          _buildInstructionItem(
            colors,
            '4. Seus dados serão restaurados com segurança',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(AppColors colors, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            PhosphorIconsRegular.check,
            color: colors.onSecondaryContainer,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBackupsWidget(AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsRegular.archive,
              size: 64,
              color: colors.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum backup encontrado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crie seu primeiro backup para manter seus dados seguros',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _createBackup(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(PhosphorIconsRegular.plus),
              label: const Text('Criar Primeiro Backup'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(AppColors colors, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsRegular.warning,
              size: 64,
              color: colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar backups',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.error,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(backupProvider.notifier).clearError();
                ref.read(backupProvider.notifier).loadLocalBackups();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
              icon: const Icon(PhosphorIconsRegular.arrowClockwise),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos de ação
  Future<void> _createBackup() async {
    final backup = await ref.read(backupProvider.notifier).createBackup();

    if (backup != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Backup criado com sucesso!'),
          backgroundColor: Theme.of(context).primaryColor,
          action: SnackBarAction(
            label: 'Exportar',
            textColor: Colors.white,
            onPressed: () => _exportLastBackup(),
          ),
        ),
      );
    }
  }

  Future<void> _exportBackup(String fileName) async {
    // Implementar exportação de backup específico
    final filePath = await ref.read(backupProvider.notifier).exportBackup();

    if (filePath != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup exportado para: $filePath'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    }
  }

  Future<void> _exportLastBackup() async {
    final filePath = await ref.read(backupProvider.notifier).exportBackup();

    if (filePath != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup exportado para: $filePath'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    }
  }

  Future<void> _deleteBackup(String fileName) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Backup'),
        content: const Text(
          'Tem certeza que deseja deletar este backup? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await ref.read(backupProvider.notifier).deleteLocalBackup(fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup deletado')),
        );
      }
    }
  }

  Future<void> _importBackupWithPicker() async {
    final backup =
        await ref.read(backupProvider.notifier).importBackupWithPicker();

    if (backup != null && mounted) {
      await _showRestoreDialog(null, importedBackup: backup);
    }
  }

  Future<void> _showRestoreDialog(String? fileName,
      {BackupData? importedBackup}) async {
    await showDialog(
      context: context,
      builder: (context) => BackupRestoreDialog(
        fileName: fileName,
        importedBackup: importedBackup,
      ),
    );
  }

  // Utilitários
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
