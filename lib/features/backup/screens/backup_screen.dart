import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'Backup e Sincronização',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: colorScheme.primary,
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
          _buildBackupsTab(),
          _buildImportTab(),
        ],
      ),
      floatingActionButton: _buildCreateBackupFAB(),
    );
  }

  Widget _buildCreateBackupFAB() {
    return Consumer(
      builder: (context, ref, child) {
        final colorScheme = Theme.of(context).colorScheme;
        final isCreating = ref.watch(isCreatingBackupProvider);
        final isBusy = ref.watch(isBackupBusyProvider);

        return FloatingActionButton.extended(
          onPressed: isBusy ? null : () => _createBackup(),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          icon: isCreating
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(colorScheme.onPrimary),
                  ),
                )
              : const Icon(PhosphorIconsRegular.plus),
          label: Text(isCreating ? 'Criando...' : 'Criar Backup'),
        );
      },
    );
  }

  Widget _buildBackupsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final colorScheme = Theme.of(context).colorScheme;
        final backupState = ref.watch(backupProvider);
        final localBackups = backupState.localBackups;

        if (backupState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (backupState.error != null) {
          return _buildErrorWidget(backupState.error!);
        }

        if (localBackups.isEmpty) {
          return _buildEmptyBackupsWidget();
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(backupProvider.notifier).loadLocalBackups(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackupStats(localBackups),
                const SizedBox(height: 16),
                Text(
                  'Backups Locais (${localBackups.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
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

  Widget _buildBackupStats(List<BackupMetadata> backups) {
    if (backups.isEmpty) return const SizedBox.shrink();

    return Consumer(
      builder: (context, ref, child) {
        final colorScheme = Theme.of(context).colorScheme;
        final latestBackup = backups.first;
        final totalSize =
            backups.fold<int>(0, (sum, backup) => sum + backup.fileSize);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.info,
                    color: colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Estatísticas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Total de Backups',
                      backups.length.toString(),
                      PhosphorIconsRegular.archive,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Espaço Usado',
                      _formatFileSize(totalSize),
                      PhosphorIconsRegular.hardDrive,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildStatItem(
                'Último Backup',
                _formatDate(latestBackup.createdAt),
                PhosphorIconsRegular.clock,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Consumer(
      builder: (context, ref, child) {
        final colorScheme = Theme.of(context).colorScheme;
        return Row(
          children: [
            Icon(icon, color: colorScheme.onPrimaryContainer, size: 16),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildImportTab() {
    return Consumer(
      builder: (context, ref, child) {
        final colorScheme = Theme.of(context).colorScheme;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      PhosphorIconsRegular.uploadSimple,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Importar Backup',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selecione um arquivo de backup para restaurar seus dados',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final isImporting =
                              ref.watch(isImportingBackupProvider);
                          final isBusy = ref.watch(isBackupBusyProvider);

                          return ElevatedButton.icon(
                            onPressed:
                                isBusy ? null : () => _importBackupWithPicker(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
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
                                      valueColor: AlwaysStoppedAnimation(
                                          colorScheme.onPrimary),
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
              _buildImportInstructions(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImportInstructions() {
    return Consumer(
      builder: (context, ref, child) {
        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.lightbulb,
                    color: colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Como funciona',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInstructionItem('1. Selecione um arquivo .json de backup'),
              _buildInstructionItem(
                  '2. O backup será validado automaticamente'),
              _buildInstructionItem(
                  '3. Escolha se deseja substituir ou mesclar os dados'),
              _buildInstructionItem(
                  '4. Seus dados serão restaurados com segurança'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstructionItem(String text) {
    return Consumer(
      builder: (context, ref, child) {
        final colorScheme = Theme.of(context).colorScheme;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                PhosphorIconsRegular.check,
                color: colorScheme.onSecondaryContainer,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyBackupsWidget() {
    return Consumer(
      builder: (context, ref, child) {
        final colorScheme = Theme.of(context).colorScheme;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIconsRegular.archive,
                  size: 64,
                  color: colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum backup encontrado',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crie seu primeiro backup para manter seus dados seguros',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _createBackup(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
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
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Consumer(
      builder: (context, ref, child) {
        final colorScheme = Theme.of(context).colorScheme;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIconsRegular.warning,
                  size: 64,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar backups',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(backupProvider.notifier).clearError();
                    ref.read(backupProvider.notifier).loadLocalBackups();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  icon: const Icon(PhosphorIconsRegular.arrowClockwise),
                  label: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        );
      },
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
