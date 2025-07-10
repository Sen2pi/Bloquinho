import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cloud_sync_status_provider.dart';

/// Indicador de status da sincronização na nuvem para a topbar
class CloudSyncIndicator extends ConsumerWidget {
  final bool showText;
  final bool showTooltip;
  final VoidCallback? onTap;

  const CloudSyncIndicator({
    super.key,
    this.showText = false,
    this.showTooltip = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icon = ref.watch(cloudSyncIconProvider);
    final color = ref.watch(cloudSyncColorProvider);
    final message = ref.watch(cloudSyncMessageProvider);
    final lastSync = ref.watch(cloudSyncLastSyncProvider);
    final state = ref.watch(cloudSyncStatusProvider);

    Widget indicatorWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícone com animação para status de sincronização
          _buildAnimatedIcon(icon, color, state.status),

          if (showText) ...[
            const SizedBox(width: 6),
            Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );

    // Adicionar tooltip se habilitado
    if (showTooltip) {
      indicatorWidget = Tooltip(
        message: _buildTooltipMessage(message, lastSync, state),
        child: indicatorWidget,
      );
    }

    // Adicionar onTap se fornecido
    if (onTap != null) {
      indicatorWidget = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: indicatorWidget,
      );
    }

    return indicatorWidget;
  }

  /// Constrói ícone com animação para status de sincronização
  Widget _buildAnimatedIcon(
      IconData icon, Color color, CloudSyncStatus status) {
    if (status == CloudSyncStatus.syncing ||
        status == CloudSyncStatus.connecting) {
      return SizedBox(
        width: 16,
        height: 16,
        child: AnimatedRotation(
          turns: 1,
          duration: const Duration(seconds: 2),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      );
    }

    return Icon(
      icon,
      size: 16,
      color: color,
    );
  }

  /// Constrói mensagem do tooltip
  String _buildTooltipMessage(
      String message, String? lastSync, CloudSyncState state) {
    final buffer = StringBuffer();

    buffer.writeln('Status: $message');

    if (state.provider != null) {
      final providerName = state.provider == 'google'
          ? 'Google Drive'
          : state.provider == 'microsoft'
              ? 'OneDrive'
              : state.provider;
      buffer.writeln('Provedor: $providerName');
    }

    if (lastSync != null) {
      buffer.writeln('Última sync: $lastSync');
    }

    if (state.filesCount != null) {
      buffer.writeln('Arquivos: ${state.filesCount}');
    }

    if (state.error != null) {
      buffer.writeln('Erro: ${state.error}');
    }

    return buffer.toString().trim();
  }
}

/// Indicador compacto para uso em AppBar
class CompactCloudSyncIndicator extends CloudSyncIndicator {
  const CompactCloudSyncIndicator({
    super.key,
    super.onTap,
  }) : super(showText: false, showTooltip: true);
}

/// Indicador expandido para uso em drawers ou configurações
class ExpandedCloudSyncIndicator extends CloudSyncIndicator {
  const ExpandedCloudSyncIndicator({
    super.key,
    super.onTap,
  }) : super(showText: true, showTooltip: true);
}

/// Widget de status de sincronização para modal/bottom sheet
class CloudSyncStatusModal extends ConsumerWidget {
  const CloudSyncStatusModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cloudSyncStatusProvider);
    final icon = ref.watch(cloudSyncIconProvider);
    final color = ref.watch(cloudSyncColorProvider);
    final lastSync = ref.watch(cloudSyncLastSyncProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                'Status de Sincronização',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Status atual
          _buildStatusRow(
            'Status',
            state.message ?? 'Desconhecido',
            color,
          ),

          if (state.provider != null) ...[
            const SizedBox(height: 12),
            _buildStatusRow(
              'Provedor',
              state.provider == 'google'
                  ? 'Google Drive'
                  : state.provider == 'microsoft'
                      ? 'OneDrive'
                      : state.provider!,
              null,
            ),
          ],

          if (lastSync != null) ...[
            const SizedBox(height: 12),
            _buildStatusRow('Última Sincronização', lastSync, null),
          ],

          if (state.filesCount != null) ...[
            const SizedBox(height: 12),
            _buildStatusRow('Arquivos', '${state.filesCount}', null),
          ],

          if (state.error != null) ...[
            const SizedBox(height: 12),
            _buildStatusRow('Erro', state.error!, Colors.red),
          ],

          const SizedBox(height: 24),

          // Ações
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (state.status == CloudSyncStatus.connected) ...[
                TextButton.icon(
                  onPressed: () async {
                    final notifier = ref.read(cloudSyncStatusProvider.notifier);

                    try {
                      notifier.startSync();

                      // Simular sincronização real
                      await Future.delayed(const Duration(seconds: 2));

                      // TODO: Implementar sincronização real aqui
                      // Por enquanto, apenas finalizar a sincronização
                      notifier.finishSync(
                        filesCount: 5, // Exemplo
                        lastSync: DateTime.now(),
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sincronização concluída!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      notifier.setError('Erro na sincronização: $e');

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro na sincronização: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.sync),
                  label: const Text('Sincronizar'),
                ),
                const SizedBox(width: 8),
              ],
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color? color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: color != null ? FontWeight.w500 : null,
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper para mostrar modal de status
void showCloudSyncStatusModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const CloudSyncStatusModal(),
  );
}
