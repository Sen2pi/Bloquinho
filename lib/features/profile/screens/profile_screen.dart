import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/providers/user_profile_provider.dart';
import '../../../core/models/user_profile.dart';
import '../widgets/profile_avatar.dart';

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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          if (profile != null)
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, ref, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Editar Perfil'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: ListTile(
                    leading: Icon(Icons.download),
                    title: Text('Exportar Dados'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'refresh',
                  child: ListTile(
                    leading: Icon(Icons.refresh),
                    title: Text('Atualizar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete,
                        color: Theme.of(context).colorScheme.error),
                    title: Text('Excluir Perfil',
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
              'Erro ao carregar perfil',
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
              child: const Text('Tentar Novamente'),
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
            'Nenhum perfil encontrado',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Crie seu perfil para começar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pushNamed('profile_edit'),
            child: const Text('Criar Perfil'),
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

  void _confirmDeleteProfile(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Perfil'),
        content: const Text(
          'Tem certeza que deseja excluir seu perfil? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(userProfileProvider.notifier).deleteProfile();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
