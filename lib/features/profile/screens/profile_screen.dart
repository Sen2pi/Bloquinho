import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/providers/user_profile_provider.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../core/models/user_profile.dart';
import '../widgets/profile_avatar.dart';
import '../../../shared/providers/storage_settings_provider.dart';
import '../../../core/models/storage_settings.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/models/app_language.dart';

/// Tela principal do perfil do usuário
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);
    final profile = profileState.profile;
    final stats = profileState.stats;
    final isLoading = profileState.isLoading;
    final error = profileState.error;
    final strings = ref.watch(appStringsProvider);

    // Se ainda está carregando mas já tem profile, forçar refresh para corrigir inconsistência
    if (isLoading && profile != null) {
      Future.microtask(() => ref.refresh(userProfileProvider));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(strings.profile),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          if (profile != null)
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, ref, value),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: const Icon(Icons.edit),
                    title: Text(strings.editProfile),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'language',
                  child: ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(strings.changeLanguage),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: ListTile(
                    leading: const Icon(Icons.download),
                    title: Text(strings.exportData),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'refresh',
                  child: ListTile(
                    leading: const Icon(Icons.refresh),
                    title: Text(strings.refresh),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete,
                        color: Theme.of(context).colorScheme.error),
                    title: Text(strings.deleteProfile,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _buildBody(context, ref, profile, stats, isLoading, error),
      floatingActionButton: profile != null
          ? FloatingActionButton(
              onPressed: () => context.pushNamed('profile_edit'),
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    UserProfile? profile,
    Map<String, dynamic> stats,
    bool isLoading,
    String? error,
  ) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      final strings = ref.read(appStringsProvider);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              strings.errorLoadingProfile,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(userProfileProvider.notifier).refresh(),
              child: Text(strings.tryAgain),
            ),
          ],
        ),
      );
    }

    if (profile == null) {
      return _buildEmptyState(context, ref);
    }

    return _buildProfileContent(context, ref, profile, stats);
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final strings = ref.read(appStringsProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            strings.noProfileFound,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            strings.createProfileToStart,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pushNamed('profile_edit'),
            child: Text(strings.createNewProfile),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    Map<String, dynamic> stats,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com avatar e informações básicas
          _buildHeader(context, ref, profile),

          const SizedBox(height: 32),

          // Informações pessoais
          _buildPersonalInfo(context, profile),

          const SizedBox(height: 32),

          // Estatísticas
          _buildStats(context, stats),

          const SizedBox(height: 32),

          // Armazenamento (com proteção contra loading infinito)
          _buildStorageSectionSafe(context, ref, profile),

          const SizedBox(height: 32),

          // Ações rápidas
          _buildQuickActions(context, ref, profile),

          const SizedBox(height: 100), // Espaço para o FAB
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, WidgetRef ref, UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            ProfileAvatar(
              profile: profile,
              size: 100,
              onTap: () => _showAvatarOptions(context, ref),
            ),

            const SizedBox(height: 16),

            // Nome
            Text(
              profile.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),

            // Email
            Text(
              profile.email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),

            if (profile.bio != null) ...[
              const SizedBox(height: 12),
              Text(
                profile.bio!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 16),

            // Badges de status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (profile.isComplete)
                  Chip(
                    label: const Text('Completo'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                if (profile.isPublic)
                  Chip(
                    label: const Text('Público'),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary),
                  ),
              ].expand((widget) => [widget, const SizedBox(width: 8)]).toList()
                ..removeLast(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(BuildContext context, UserProfile profile) {
    final items = <Widget>[];

    if (profile.profession != null) {
      items.add(_buildInfoItem(
        context,
        Icons.work,
        'Profissão',
        profile.profession!,
      ));
    }

    if (profile.location != null) {
      items.add(_buildInfoItem(
        context,
        Icons.location_on,
        'Localização',
        profile.location!,
      ));
    }

    if (profile.phone != null) {
      items.add(_buildInfoItem(
        context,
        Icons.phone,
        'Telefone',
        profile.phone!,
      ));
    }

    if (profile.website != null) {
      items.add(_buildInfoItem(
        context,
        Icons.web,
        'Website',
        profile.website!,
      ));
    }

    if (profile.birthDate != null) {
      items.add(_buildInfoItem(
        context,
        Icons.cake,
        'Data de Nascimento',
        DateFormat('dd/MM/yyyy').format(profile.birthDate!),
      ));
    }

    if (profile.interests.isNotEmpty) {
      items.add(_buildInterests(context, profile.interests));
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações Pessoais',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: items),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterests(BuildContext context, List<String> interests) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Interesses',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: interests
                .map((interest) => Chip(
                      label: Text(interest),
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, Map<String, dynamic> stats) {
    if (stats.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estatísticas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (stats['daysCreated'] != null)
                  _buildStatItem(
                    context,
                    Icons.calendar_today,
                    'Membro há',
                    '${stats['daysCreated']} dias',
                  ),
                if (stats['lastUpdated'] != null)
                  _buildStatItem(
                    context,
                    Icons.update,
                    'Última atualização',
                    DateFormat('dd/MM/yyyy HH:mm').format(stats['lastUpdated']),
                  ),
                if (stats['interestsCount'] != null)
                  _buildStatItem(
                    context,
                    Icons.favorite,
                    'Interesses',
                    '${stats['interestsCount']}',
                  ),
                if (stats['age'] != null)
                  _buildStatItem(
                    context,
                    Icons.cake,
                    'Idade',
                    '${stats['age']} anos',
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageSectionSafe(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) {
    // Versão simplificada para evitar loading infinito
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Armazenamento',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storage),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Armazenamento Local',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          Text(
                            'Dados salvos localmente',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: const Text(
                        'Ativo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/workspace/profile/storage'),
                    icon: const Icon(Icons.settings),
                    label: const Text('Configurar Armazenamento'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStorageSection(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) {
    final storageSettings = ref.watch(storageSettingsProvider);
    final isLocalStorage = ref.watch(isLocalStorageProvider);
    final isConnected = ref.watch(isStorageConnectedProvider);
    final providerName = ref.watch(currentProviderNameProvider);
    final syncStatus = ref.watch(syncStatusTextProvider);
    final localWarning = ref.watch(localStorageWarningProvider);
    final needsSync = ref.watch(needsSyncProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Armazenamento',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status do armazenamento
                Row(
                  children: [
                    Icon(
                      _getStorageIcon(storageSettings.provider),
                      color: _getStorageColor(storageSettings.provider),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            providerName,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          Text(
                            syncStatus,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(storageSettings.status)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(storageSettings.status)
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _getStatusText(storageSettings.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(storageSettings.status),
                        ),
                      ),
                    ),
                  ],
                ),

                // Aviso de armazenamento local
                if (localWarning != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Colors.orange[600],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Dados apenas neste dispositivo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Indicador de sincronização necessária
                if (needsSync && !isLocalStorage) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sync_problem,
                          color: Colors.blue[600],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sincronização pendente',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Botão de configurações
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/workspace/profile/storage'),
                    icon: const Icon(Icons.settings),
                    label: const Text('Configurar Armazenamento'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar Perfil'),
                subtitle: const Text('Alterar informações pessoais'),
                onTap: () => context.pushNamed('profile_edit'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Alterar Foto'),
                subtitle: const Text('Atualizar avatar do perfil'),
                onTap: () => _showAvatarOptions(context, ref),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Exportar Dados'),
                subtitle: const Text('Baixar informações do perfil'),
                onTap: () => _exportProfile(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAvatarOptions(BuildContext context, WidgetRef ref) {
    final hasAvatar = ref.read(hasAvatarProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(userProfileProvider.notifier)
                    .uploadAvatarFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.pop(context);
                ref.read(userProfileProvider.notifier).uploadAvatarFromCamera();
              },
            ),
            if (hasAvatar) ...[
              const Divider(),
              ListTile(
                leading: Icon(Icons.delete,
                    color: Theme.of(context).colorScheme.error),
                title: Text('Remover foto',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(userProfileProvider.notifier).removeAvatar();
                },
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'edit':
        context.pushNamed('profile_edit');
        break;
      case 'language':
        _showLanguageSelector(context, ref);
        break;
      case 'export':
        _exportProfile(context, ref);
        break;
      case 'refresh':
        ref.read(userProfileProvider.notifier).refresh();
        break;
      case 'delete':
        _confirmDeleteProfile(context, ref);
        break;
    }
  }

  void _exportProfile(BuildContext context, WidgetRef ref) async {
    try {
      final data = await ref.read(userProfileProvider.notifier).exportProfile();

      // Aqui você pode implementar o salvamento do arquivo
      // Por enquanto, apenas mostra um diálogo de sucesso
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados exportados com sucesso!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar: $e')),
        );
      }
    }
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    final strings = ref.read(appStringsProvider);
    final currentLanguage = ref.read(languageProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.changeLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((language) {
            return RadioListTile<AppLanguage>(
              title: Text(language.displayName),
              subtitle: Text(language.flag),
              value: language,
              groupValue: currentLanguage,
              onChanged: (AppLanguage? value) async {
                if (value != null) {
                  await ref.read(languageProvider.notifier).setLanguage(value);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.languageChanged)),
                    );
                  }
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProfile(BuildContext context, WidgetRef ref) {
    final strings = ref.read(appStringsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.confirmDeleteProfile),
        content: Text(strings.deleteProfileWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Usar deleteAllData para limpar tudo e retornar ao onboarding
                await ref.read(userProfileProvider.notifier).deleteAllData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(strings.profileDeleted)),
                  );
                  // Navegar para o onboarding
                  context.go('/onboarding');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('${strings.errorDeletingProfile}: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(strings.delete),
          ),
        ],
      ),
    );
  }

  /// Obter ícone do provider de armazenamento
  IconData _getStorageIcon(CloudStorageProvider provider) {
    switch (provider) {
      case CloudStorageProvider.googleDrive:
        return Icons.cloud;
      case CloudStorageProvider.oneDrive:
        return Icons.cloud_outlined;
      case CloudStorageProvider.local:
        return Icons.storage;
    }
  }

  /// Obter cor do provider de armazenamento
  Color _getStorageColor(CloudStorageProvider provider) {
    switch (provider) {
      case CloudStorageProvider.googleDrive:
        return Colors.blue;
      case CloudStorageProvider.oneDrive:
        return Colors.indigo;
      case CloudStorageProvider.local:
        return Colors.grey;
    }
  }

  /// Obter cor do status
  Color _getStatusColor(CloudStorageStatus status) {
    switch (status) {
      case CloudStorageStatus.connected:
        return Colors.green;
      case CloudStorageStatus.syncing:
        return Colors.blue;
      case CloudStorageStatus.connecting:
        return Colors.orange;
      case CloudStorageStatus.error:
        return Colors.red;
      case CloudStorageStatus.disconnected:
        return Colors.grey;
    }
  }

  /// Obter texto do status
  String _getStatusText(CloudStorageStatus status) {
    switch (status) {
      case CloudStorageStatus.connected:
        return 'Conectado';
      case CloudStorageStatus.syncing:
        return 'Sincronizando';
      case CloudStorageStatus.connecting:
        return 'Conectando';
      case CloudStorageStatus.error:
        return 'Erro';
      case CloudStorageStatus.disconnected:
        return 'Desconectado';
    }
  }
}
