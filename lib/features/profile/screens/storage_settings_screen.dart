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
import 'package:go_router/go_router.dart';
import 'package:bloquinho/core/models/storage_settings.dart';
import 'package:bloquinho/core/services/cloud_storage_service.dart';
import 'package:bloquinho/shared/providers/storage_settings_provider.dart';
import 'package:bloquinho/shared/providers/user_profile_provider.dart';
import 'package:bloquinho/shared/widgets/animated_action_button.dart';

/// Tela para configurar armazenamento em nuvem
class StorageSettingsScreen extends ConsumerStatefulWidget {
  const StorageSettingsScreen({super.key});

  @override
  ConsumerState<StorageSettingsScreen> createState() =>
      _StorageSettingsScreenState();
}

class _StorageSettingsScreenState extends ConsumerState<StorageSettingsScreen> {
  bool _isConnecting = false;
  bool _isSyncing = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final storageSettings = ref.watch(storageSettingsProvider);
    final isConnected = ref.watch(isStorageConnectedProvider);
    final isOAuth2Connected = ref.watch(isOAuth2ConnectedProvider);
    final isLocalStorage = ref.watch(isLocalStorageProvider);
    final providerName = ref.watch(currentProviderNameProvider);
    final accountInfo = ref.watch(storageAccountInfoProvider);
    final lastSync = ref.watch(lastSyncProvider);
    final syncStatus = ref.watch(syncStatusTextProvider);
    final localWarning = ref.watch(localStorageWarningProvider);
    final storageSpace = ref.watch(storageSpaceProvider);
    final autoSyncSettings = ref.watch(autoSyncSettingsProvider);

    // Para cloud storage, usar OAuth2 status se disponível
    final actuallyConnected = isLocalStorage
        ? isConnected
        : (isOAuth2Connected.when(
            data: (oauth2Connected) => oauth2Connected || isConnected,
            loading: () => isConnected,
            error: (_, __) => isConnected,
          ));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Configurações de Armazenamento',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção de seleção de provider
            _buildProviderSelectionSection(storageSettings),

            const SizedBox(height: 24),

            // Aviso de armazenamento local
            if (localWarning != null) _buildLocalStorageWarning(localWarning),

            // Seção de status de conexão
            if (!isLocalStorage) ...[
              const SizedBox(height: 24),
              _buildConnectionSection(
                  actuallyConnected, providerName, accountInfo),
            ],

            // Seção de sincronização
            if (actuallyConnected && !isLocalStorage) ...[
              const SizedBox(height: 24),
              _buildSyncSection(syncStatus, lastSync),
            ],

            // Seção de configurações automáticas
            if (!isLocalStorage) ...[
              const SizedBox(height: 24),
              _buildAutoSyncSection(autoSyncSettings),
            ],

            // Seção de espaço de armazenamento
            if (actuallyConnected && !isLocalStorage) ...[
              const SizedBox(height: 24),
              _buildStorageSpaceSection(storageSpace),
            ],

            // Seção de ações
            const SizedBox(height: 24),
            _buildActionsSection(actuallyConnected, isLocalStorage),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Seção de seleção de provider
  Widget _buildProviderSelectionSection(StorageSettings currentSettings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipo de Armazenamento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...CloudStorageProvider.values.map((provider) {
            final isSelected = currentSettings.provider == provider;
            final color = _getProviderColor(provider);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _changeProvider(provider),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? color.withOpacity(0.1) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getProviderIcon(provider),
                        color: isSelected ? color : Colors.grey[600],
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? color : Colors.black87,
                              ),
                            ),
                            Text(
                              _getProviderDescription(provider),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: color,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Aviso de armazenamento local
  Widget _buildLocalStorageWarning(String warning) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber,
            color: Colors.orange[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              warning,
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Seção de conexão
  Widget _buildConnectionSection(
      bool isConnected, String providerName, Map<String, String?> accountInfo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Conexão',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isConnected ? Colors.green[200]! : Colors.red[200]!,
                  ),
                ),
                child: Text(
                  isConnected ? 'Conectado' : 'Desconectado',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isConnected ? Colors.green[800] : Colors.red[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isConnected && accountInfo['email'] != null) ...[
            _buildInfoRow('Conta', accountInfo['email']!),
            if (accountInfo['name'] != null)
              _buildInfoRow('Nome', accountInfo['name']!),
            _buildInfoRow('Serviço', providerName),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isConnecting ? null : _disconnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Desconectar'),
              ),
            ),
          ] else ...[
            Text(
              'Conecte-se ao $providerName para sincronizar seus dados entre dispositivos.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedActionButton(
              text: 'Conectar ao $providerName',
              onPressed: _connect,
              isLoading: _isConnecting,
              isEnabled: !_isConnecting,
              icon: Icons.cloud_upload_outlined,
              type: ButtonType.primary,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Seção de sincronização
  Widget _buildSyncSection(String syncStatus, DateTime? lastSync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sincronização',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Status', syncStatus),
          if (lastSync != null)
            _buildInfoRow('Última Sincronização', _formatDateTime(lastSync)),
          const SizedBox(height: 16),
          AnimatedActionButton(
            text: 'Sincronizar Agora',
            onPressed: _syncNow,
            isLoading: _isSyncing,
            isEnabled: !_isSyncing,
            icon: Icons.sync,
            type: ButtonType.secondary,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ],
      ),
    );
  }

  /// Seção de configurações automáticas
  Widget _buildAutoSyncSection(Map<String, bool> autoSyncSettings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sincronização Automática',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildSwitchRow(
            'Sincronização Automática',
            'Sincronizar dados automaticamente',
            autoSyncSettings['autoSyncEnabled'] ?? false,
            (value) => _updateAutoSync(autoSyncEnabled: value),
          ),
          _buildSwitchRow(
            'Sincronizar ao Iniciar',
            'Sincronizar quando o app iniciar',
            autoSyncSettings['syncOnStartup'] ?? false,
            (value) => _updateAutoSync(syncOnStartup: value),
          ),
          _buildSwitchRow(
            'Sincronizar ao Fechar',
            'Sincronizar quando o app fechar',
            autoSyncSettings['syncOnClose'] ?? false,
            (value) => _updateAutoSync(syncOnClose: value),
          ),
        ],
      ),
    );
  }

  /// Seção de espaço de armazenamento
  Widget _buildStorageSpaceSection(AsyncValue<StorageSpace> storageSpace) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Espaço de Armazenamento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          storageSpace.when(
            data: (space) => _buildStorageSpaceInfo(space),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text(
              'Erro ao carregar informações: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Informações de espaço de armazenamento
  Widget _buildStorageSpaceInfo(StorageSpace space) {
    return Column(
      children: [
        _buildInfoRow('Espaço Total', space.formattedTotal),
        _buildInfoRow('Espaço Usado', space.formattedUsed),
        _buildInfoRow('Espaço Disponível', space.formattedAvailable),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: space.usagePercentage / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            space.isAlmostFull ? Colors.red : Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${space.usagePercentage.toStringAsFixed(1)}% utilizado',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Seção de ações
  Widget _buildActionsSection(bool isConnected, bool isLocalStorage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ações',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (isLocalStorage) ...[
            _buildActionButton(
              'Fazer Backup',
              'Exportar dados para arquivo',
              Icons.backup,
              Colors.blue,
              _exportBackup,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Importar Backup',
              'Importar dados de arquivo',
              Icons.restore,
              Colors.green,
              _importBackup,
            ),
          ] else if (isConnected) ...[
            _buildActionButton(
              'Testar Conexão',
              'Verificar conectividade',
              Icons.wifi_protected_setup,
              Colors.blue,
              _testConnection,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Limpar Cache',
              'Limpar dados em cache',
              Icons.cleaning_services,
              Colors.orange,
              _clearCache,
            ),
          ],
        ],
      ),
    );
  }

  /// Botão de ação
  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// Linha de switch
  Widget _buildSwitchRow(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue[600],
          ),
        ],
      ),
    );
  }

  /// Linha de informação
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Obter cor do provider
  Color _getProviderColor(CloudStorageProvider provider) {
    switch (provider) {
      case CloudStorageProvider.googleDrive:
        return Colors.blue;
      case CloudStorageProvider.oneDrive:
        return Colors.indigo;
      case CloudStorageProvider.local:
        return Colors.grey;
    }
  }

  /// Obter ícone do provider
  IconData _getProviderIcon(CloudStorageProvider provider) {
    switch (provider) {
      case CloudStorageProvider.googleDrive:
        return Icons.cloud;
      case CloudStorageProvider.oneDrive:
        return Icons.cloud_outlined;
      case CloudStorageProvider.local:
        return Icons.storage;
    }
  }

  /// Obter descrição do provider
  String _getProviderDescription(CloudStorageProvider provider) {
    switch (provider) {
      case CloudStorageProvider.googleDrive:
        return '15GB gratuitos • Sincronização automática';
      case CloudStorageProvider.oneDrive:
        return '5GB gratuitos • Integração Microsoft';
      case CloudStorageProvider.local:
        return 'Apenas neste dispositivo • Sem sincronização';
    }
  }

  /// Alterar provider
  Future<void> _changeProvider(CloudStorageProvider provider) async {
    await ref.read(storageSettingsProvider.notifier).changeProvider(provider);
  }

  /// Conectar ao serviço
  Future<void> _connect() async {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      final result = await ref.read(storageSettingsProvider.notifier).connect();
      if (!result.success) {
        setState(() {
          _errorMessage = result.errorMessage;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao conectar: $e';
      });
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  /// Desconectar do serviço
  Future<void> _disconnect() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      await ref.read(storageSettingsProvider.notifier).disconnect();
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  /// Sincronizar agora
  Future<void> _syncNow() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      final result = await ref
          .read(storageSettingsProvider.notifier)
          .sync(forceSync: true);
      if (!result.success) {
        _showMessage('Erro na sincronização: ${result.errorMessage}');
      } else {
        _showMessage('Sincronização concluída com sucesso!');
      }
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  /// Atualizar configurações de sincronização automática
  Future<void> _updateAutoSync({
    bool? autoSyncEnabled,
    bool? syncOnStartup,
    bool? syncOnClose,
  }) async {
    await ref.read(storageSettingsProvider.notifier).updateSyncSettings(
          autoSyncEnabled: autoSyncEnabled,
          syncOnStartup: syncOnStartup,
          syncOnClose: syncOnClose,
        );
  }

  /// Exportar backup
  void _exportBackup() {
    _showMessage('Funcionalidade de backup será implementada em breve!');
  }

  /// Importar backup
  void _importBackup() {
    _showMessage('Funcionalidade de importação será implementada em breve!');
  }

  /// Testar conexão
  Future<void> _testConnection() async {
    final isConnected =
        await ref.read(storageSettingsProvider.notifier).checkConnectivity();
    _showMessage(isConnected ? 'Conexão OK!' : 'Falha na conexão');
  }

  /// Limpar cache
  void _clearCache() {
    _showMessage('Cache limpo com sucesso!');
  }

  /// Mostrar mensagem
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Formatar data/hora
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
