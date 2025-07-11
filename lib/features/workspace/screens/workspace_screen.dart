import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../shared/providers/workspace_provider.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../shared/widgets/cloud_sync_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/workspace.dart';
import '../../../core/services/oauth2_service.dart';
import '../../backup/screens/backup_screen.dart';
import '../../profile/widgets/profile_avatar.dart';
import '../../database/screens/database_list_screen.dart';
import '../../database/widgets/database_section_widget.dart';
import '../../../shared/providers/database_provider.dart';
import '../../passwords/screens/password_manager_screen.dart';
import '../../agenda/screens/agenda_screen.dart';
import '../../documentos/screens/documentos_screen.dart';
import '../../bloquinho/screens/bloco_editor_screen.dart';
import '../../bloquinho/widgets/page_tree_widget.dart';

enum Section { bloquinho, agenda, passwords, documentos, database }

class WorkspaceScreen extends ConsumerStatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  bool _isSidebarExpanded = true;
  Section _selectedSection = Section.bloquinho;
  bool _isBloquinhoExpanded = true;

  @override
  void initState() {
    super.initState();
    // Configurar referência para atualizações de status de sincronização
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OAuth2Service.setSyncRef(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final currentWorkspace = ref.watch(currentWorkspaceProvider);
    final workspaceSections = ref.watch(currentWorkspaceSectionsProvider);
    final currentProfile = ref.watch(currentProfileProvider);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isSidebarExpanded ? 280 : 60,
            child: _buildSidebar(isDarkMode, currentWorkspace,
                workspaceSections, currentProfile),
          ),

          // Divisor
          Container(
            width: 1,
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          ),

          // Conteúdo principal
          Expanded(
            child: _buildMainContent(isDarkMode, currentWorkspace),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isDarkMode, Workspace? currentWorkspace,
      List<WorkspaceSection> workspaceSections, dynamic currentProfile) {
    return Container(
      color: isDarkMode
          ? AppColors.sidebarBackgroundDark
          : AppColors.sidebarBackground,
      child: Column(
        children: [
          // Header com seletor de workspace
          _buildWorkspaceHeader(isDarkMode, currentWorkspace),

          const Divider(height: 1),

          // Seções do workspace
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                // Seções principais
                ...workspaceSections.map((section) {
                  if (section.id.contains('database')) {
                    return ListTile(
                      leading: Icon(Icons.storage_outlined, size: 28),
                      title: _isSidebarExpanded
                          ? const Text('Base de Dados')
                          : null,
                      onTap: () => _handleSectionTap('database'),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      horizontalTitleGap: 12,
                    );
                  }
                  if (section.id.contains('bloquinho')) {
                    return Column(
                      children: [
                        ListTile(
                          leading: Image.asset(
                            isDarkMode
                                ? 'assets/images/logoDark.png'
                                : 'assets/images/logo.png',
                            width: 28,
                            height: 28,
                          ),
                          title: _isSidebarExpanded
                              ? const Text('Bloquinho')
                              : null,
                          onTap: () {
                            setState(() {
                              _isBloquinhoExpanded = !_isBloquinhoExpanded;
                            });
                          },
                          trailing: _isSidebarExpanded
                              ? Icon(_isBloquinhoExpanded
                                  ? Icons.arrow_drop_down
                                  : Icons.arrow_right)
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          horizontalTitleGap: 12,
                        ),
                        if (_isBloquinhoExpanded && _isSidebarExpanded)
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: PageTreeWidget(
                              onPageSelected: (pageId) {
                                setState(() {
                                  _selectedSection = Section.bloquinho;
                                  // Aqui você pode passar o pageId para o editor principal
                                  // Exemplo: _editorKey.currentState?.navigateToPage(pageId);
                                });
                              },
                            ),
                          ),
                      ],
                    );
                  }
                  if (section.id.contains('documents') ||
                      section.name.toLowerCase().contains('documentos')) {
                    return const SizedBox
                        .shrink(); // Pular item dinâmico de Documentos
                  }
                  return _buildSectionItem(
                    section: section,
                    isDarkMode: isDarkMode,
                  );
                }),

                const SizedBox(height: 24),

                // Seções de sistema
                if (_isSidebarExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Sistema',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                _buildSidebarItem(
                  icon: PhosphorIcons.downloadSimple(),
                  label: 'Backup',
                  sectionId: 'backup',
                  isDarkMode: isDarkMode,
                  onTap: () => context.pushNamed('backup'),
                ),
                _buildSidebarItem(
                  icon: PhosphorIcons.trash(),
                  label: 'Lixeira',
                  sectionId: 'trash',
                  isDarkMode: isDarkMode,
                  onTap: () => _handleSectionTap('trash'),
                ),
              ],
            ),
          ),

          // Footer com perfil do usuário
          _buildUserProfileFooter(isDarkMode, currentProfile),
        ],
      ),
    );
  }

  Widget _buildWorkspaceHeader(bool isDarkMode, Workspace? currentWorkspace) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (_isSidebarExpanded) ...[
            // Dropdown de workspace
            Expanded(
              child: PopupMenuButton<String>(
                onSelected: (workspaceId) {
                  ref
                      .read(workspaceProvider.notifier)
                      .selectWorkspace(workspaceId);
                },
                itemBuilder: (context) {
                  final workspaces = ref.read(workspacesProvider);
                  return workspaces.map((workspace) {
                    return PopupMenuItem(
                      value: workspace.id,
                      child: Row(
                        children: [
                          Icon(
                            workspace.icon,
                            size: 16,
                            color: workspace.color,
                          ),
                          const SizedBox(width: 8),
                          Text(workspace.name),
                        ],
                      ),
                    );
                  }).toList();
                },
                child: Row(
                  children: [
                    Icon(
                      currentWorkspace?.icon ?? Icons.work,
                      size: 20,
                      color: currentWorkspace?.color ?? AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        currentWorkspace?.name ?? 'Workspace',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, size: 16),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Ícone do workspace quando collapsed
            PopupMenuButton<String>(
              onSelected: (workspaceId) {
                ref
                    .read(workspaceProvider.notifier)
                    .selectWorkspace(workspaceId);
              },
              itemBuilder: (context) {
                final workspaces = ref.read(workspacesProvider);
                return workspaces.map((workspace) {
                  return PopupMenuItem(
                    value: workspace.id,
                    child: Row(
                      children: [
                        Icon(
                          workspace.icon,
                          size: 16,
                          color: workspace.color,
                        ),
                        const SizedBox(width: 8),
                        Text(workspace.name),
                      ],
                    ),
                  );
                }).toList();
              },
              child: Icon(
                currentWorkspace?.icon ?? Icons.work,
                size: 20,
                color: currentWorkspace?.color ?? AppColors.primary,
              ),
            ),
          ],

          // Botão de colapsar
          IconButton(
            onPressed: () {
              setState(() {
                _isSidebarExpanded = !_isSidebarExpanded;
              });
            },
            icon: Icon(
              _isSidebarExpanded
                  ? PhosphorIcons.sidebarSimple()
                  : PhosphorIcons.sidebarSimple(),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionItem({
    required WorkspaceSection section,
    required bool isDarkMode,
  }) {
    final isSelected = false; // Removed _selectedSectionId logic

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _handleSectionTap(section.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isSelected
                  ? (isDarkMode
                      ? AppColors.sidebarItemHoverDark
                      : AppColors.sidebarItemHover)
                  : null,
            ),
            child: Row(
              children: [
                _buildSectionIcon(section, isSelected, isDarkMode),
                if (_isSidebarExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      section.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected ? AppColors.primary : null,
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                    ),
                  ),
                  if (section.itemCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${section.itemCount}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget helper para renderizar ícones customizados ou MaterialIcons
  Widget _buildSectionIcon(
      WorkspaceSection section, bool isSelected, bool isDarkMode) {
    final iconColor = isSelected
        ? AppColors.primary
        : (isDarkMode
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary);

    if (section.hasCustomIcon) {
      return Image.asset(
        section.customIconPath!,
        width: 18,
        height: 18,
        // Removido o filtro de cor para manter as cores originais
        errorBuilder: (context, error, stackTrace) {
          // Fallback para ícone MaterialIcons se a imagem falhar
          return Icon(
            section.icon,
            size: 18,
            color: iconColor,
          );
        },
      );
    }

    return Icon(
      section.icon,
      size: 18,
      color: iconColor,
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required String sectionId,
    required bool isDarkMode,
    VoidCallback? onTap,
  }) {
    final isSelected = false; // Removed _selectedSectionId logic

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap ?? () => _handleSectionTap(sectionId),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isSelected
                  ? (isDarkMode
                      ? AppColors.sidebarItemHoverDark
                      : AppColors.sidebarItemHover)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? AppColors.primary
                      : (isDarkMode
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                ),
                if (_isSidebarExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected ? AppColors.primary : null,
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileFooter(bool isDarkMode, dynamic currentProfile) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_isSidebarExpanded) ...[
            Expanded(
              child: Row(
                children: [
                  // Avatar do usuário
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.pushNamed('profile'),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: currentProfile != null
                            ? ProfileAvatar(
                                profile: currentProfile,
                                size: 32,
                                showLoadingIndicator: false,
                              )
                            : CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primary,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentProfile?.name ?? 'Usuário',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (currentProfile?.email != null)
                          Text(
                            currentProfile.email,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  // Menu de opções do usuário
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleUserMenuAction(value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'profile',
                        child: ListTile(
                          leading: Icon(Icons.person),
                          title: Text('Perfil'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'settings',
                        child: ListTile(
                          leading: Icon(Icons.settings),
                          title: Text('Configurações'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'logout',
                        child: ListTile(
                          leading: Icon(Icons.logout),
                          title: Text('Sair'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_horiz,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Avatar compacto quando collapsed
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.pushNamed('profile'),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: currentProfile != null
                      ? ProfileAvatar(
                          profile: currentProfile,
                          size: 32,
                          showLoadingIndicator: false,
                        )
                      : CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                ),
              ),
            ),
          ],

          // Botão de tema
          IconButton(
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
            icon: Icon(
              isDarkMode ? PhosphorIcons.sun() : PhosphorIcons.moon(),
              size: 20,
            ),
            tooltip: isDarkMode ? 'Tema claro' : 'Tema escuro',
          ),
        ],
      ),
    );
  }

  void _handleSectionTap(String sectionId) {
    setState(() {
      if (sectionId.endsWith('agenda')) {
        _selectedSection = Section.agenda;
      } else if (sectionId.endsWith('passwords')) {
        _selectedSection = Section.passwords;
      } else if (sectionId.endsWith('documentos')) {
        _selectedSection = Section.documentos;
      } else if (sectionId.endsWith('database')) {
        _selectedSection = Section.database;
      } else if (sectionId.endsWith('bloquinho')) {
        _selectedSection = Section.bloquinho;
      }
    });
  }

  void _handleUserMenuAction(String action) {
    switch (action) {
      case 'profile':
        context.pushNamed('profile');
        break;
      case 'settings':
        // Implementar navegação para configurações
        break;
      case 'logout':
        // Implementar logout
        break;
    }
  }

  void _showCreatePageDialog(BuildContext context) {
    // Implementar diálogo de criação de página
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento...')),
    );
  }

  Widget _buildWorkspaceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isDarkMode, Workspace? currentWorkspace) {
    switch (_selectedSection) {
      case Section.agenda:
        return const AgendaScreen();
      case Section.passwords:
        return const PasswordManagerScreen();
      case Section.documentos:
        return const DocumentosScreen();
      case Section.database:
        return const DatabaseListScreen();
      case Section.bloquinho:
        return const BlocoEditorScreen();
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/notas.png', width: 64, height: 64),
              const SizedBox(height: 24),
              Text('Bem-vindo ao Bloquinho!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Selecione uma seção no menu lateral para começar.'),
            ],
          ),
        );
    }
  }
}
