import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/services/backup_service.dart';

class BackupCard extends StatelessWidget {
  final BackupMetadata backup;
  final VoidCallback? onExport;
  final VoidCallback? onDelete;
  final VoidCallback? onRestore;

  const BackupCard({
    super.key,
    required this.backup,
    this.onExport,
    this.onDelete,
    this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(colorScheme),
            const SizedBox(height: 12),
            _buildDetails(colorScheme),
            const SizedBox(height: 16),
            _buildActions(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            PhosphorIconsRegular.archive,
            color: colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getDisplayName(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                _formatDate(backup.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            backup.version,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: colorScheme.onTertiaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            colorScheme,
            PhosphorIconsRegular.file,
            'Documentos',
            backup.documentsCount.toString(),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            colorScheme,
            PhosphorIconsRegular.folder,
            'Workspaces',
            backup.workspacesCount.toString(),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            colorScheme,
            PhosphorIconsRegular.hardDrive,
            'Tamanho',
            _formatFileSize(backup.fileSize),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      ColorScheme colorScheme, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onRestore,
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(PhosphorIconsRegular.downloadSimple, size: 16),
            label: const Text('Restaurar'),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onExport,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(PhosphorIconsRegular.export, size: 18),
          tooltip: 'Exportar',
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: onDelete,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.errorContainer,
            foregroundColor: colorScheme.onErrorContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(PhosphorIconsRegular.trash, size: 18),
          tooltip: 'Deletar',
        ),
      ],
    );
  }

  String _getDisplayName() {
    final fileName = backup.fileName;

    // Remover extensão e timestamp para nomes automáticos
    if (fileName.startsWith('bloquinho_backup_') ||
        fileName.startsWith('auto_backup_')) {
      return fileName.startsWith('auto_backup_')
          ? 'Backup Automático'
          : 'Backup Manual';
    }

    // Para nomes personalizados, remover apenas a extensão
    return fileName.replaceAll('.json', '');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Há ${difference.inMinutes} minutos';
      }
      return 'Há ${difference.inHours} horas';
    } else if (difference.inDays == 1) {
      return 'Ontem às ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return 'Há ${difference.inDays} dias';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
