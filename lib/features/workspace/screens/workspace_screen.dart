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
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/user_profile_service.dart';
import '../../backup/screens/backup_screen.dart';
import '../../profile/widgets/profile_avatar.dart';
import '../../database/screens/database_list_screen.dart';
import '../../database/widgets/database_section_widget.dart';
import '../../../shared/providers/database_provider.dart';
import '../../passwords/screens/password_manager_screen.dart';
import '../../passwords/providers/password_provider.dart';
import '../../agenda/screens/agenda_screen.dart';
import '../../agenda/providers/agenda_provider.dart';
import '../../documentos/screens/documentos_screen.dart';
import '../../documentos/providers/documentos_provider.dart';
import '../../bloquinho/screens/bloco_editor_screen.dart';
import '../../bloquinho/screens/bloquinho_dashboard_screen.dart';
import '../../bloquinho/widgets/page_tree_widget.dart';
import '../../bloquinho/providers/pages_provider.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';

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
  final GlobalKey<BlocoEditorScreenState> _editorKey =
      GlobalKey<BlocoEditorScreenState>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Configurar referência para atualizações de status de sincronização
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OAuth2Service.setSyncRef(ref);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final currentProfile = ref.watch(currentProfileProvider);
    final currentWorkspace = ref.watch(currentWorkspaceProvider);
    final workspaceSections = ref.watch(currentWorkspaceSectionsProvider);

    // DEBUG: Log do estado atual
    debugPrint('🔍 WorkspaceScreen - currentProfile: ${currentProfile?.name}');
    debugPrint(
        '🔍 WorkspaceScreen - currentWorkspace: ${currentWorkspace?.name} (${currentWorkspace?.id})');
    debugPrint(
        '🔍 WorkspaceScreen - workspaceSections: ${workspaceSections.length} seções');

    // Carregar páginas automaticamente quando o contexto muda
    ref.watch(pagesLoaderProvider);

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(
              isDarkMode, currentProfile, currentWorkspace, workspaceSections),

          // Conteúdo principal
          Expanded(
            child: Column(
              children: [
                // Header do workspace
                _buildWorkspaceHeader(isDarkMode, currentWorkspace),

                // Conteúdo principal
                Expanded(
                  child: _buildMainContent(isDarkMode, currentWorkspace),
                ),
              ],
            ),
          ),
        ],
      ),
      // Floating Action Button para documentos
      floatingActionButton: _buildFloatingActionButton(isDarkMode),
    );
  }

  Widget _buildSidebar(bool isDarkMode, dynamic currentProfile,
      Workspace? currentWorkspace, List<WorkspaceSection> workspaceSections) {
    final appStrings = AppStrings(ref.watch(languageProvider));
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isSidebarExpanded ? 280 : 60,
      child: Container(
        color: isDarkMode
            ? AppColors.sidebarBackgroundDark
            : AppColors.sidebarBackground,
        child: Column(
          children: [
            // Header com seletor de workspace
            _buildWorkspaceHeader(isDarkMode, currentWorkspace),

            // BARRA DE PESQUISA NO TOPO DA SIDEBAR
            if (_isSidebarExpanded)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: _buildSidebarSearchBar(isDarkMode),
              ),

            const Divider(height: 1),

            // Seções do workspace
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  // Seções principais
                  ...workspaceSections.map((section) {
                    if (section.id.contains('database')) {
                      // Sempre usar o ícone dossier.png
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _handleSectionTap('database'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/dossier.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  if (_isSidebarExpanded) ...[
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Base de Dados',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontSize: 14,
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
                    if (section.id.contains('bloquinho')) {
                      return Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  setState(() {
                                    _isBloquinhoExpanded =
                                        !_isBloquinhoExpanded;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        isDarkMode
                                            ? 'assets/images/logoDark.png'
                                            : 'assets/images/logo.png',
                                        width: 20,
                                        height: 20,
                                      ),
                                      if (_isSidebarExpanded) ...[
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Bloquinho',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontSize: 14,
                                                ),
                                          ),
                                        ),
                                        Icon(
                                          _isBloquinhoExpanded
                                              ? Icons.arrow_drop_down
                                              : Icons.arrow_right,
                                          size: 20,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_isBloquinhoExpanded && _isSidebarExpanded)
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: PageTreeWidget(
                                onPageSelected: (pageId) {
                                  setState(() {
                                    _selectedSection = Section.bloquinho;
                                  });
                                  // Navega para a página correta no editor, sempre dentro do layout
                                  context.go(
                                      '/workspace/bloquinho/editor/$pageId');
                                },
                              ),
                            ),
                        ],
                      );
                    }
                    if (section.id.contains('documents') ||
                        section.name.toLowerCase().contains('documentos')) {
                      // Exibir Documentos com ícone cartao.png
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => context.push('/workspace/documentos'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/cartao.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  if (_isSidebarExpanded) ...[
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Documentos',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontSize: 14,
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

            // BOTÃO DONATE ACIMA DO INDICADOR DE NUVEM
            if (_isSidebarExpanded)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: 180,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? AppColors.sidebarItemHoverDark
                          : AppColors.sidebarItemHover,
                      foregroundColor:
                          isDarkMode ? Colors.white : Colors.blue[900],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 8),
                    ),
                    icon: Icon(Icons.volunteer_activism,
                        color: isDarkMode ? Colors.amber[200] : Colors.blue,
                        size: 20),
                    label: Text(appStrings.donateButton,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    onPressed: () =>
                        _showDonateDialog(context, appStrings, isDarkMode),
                  ),
                ),
              ),

            // Footer com perfil do usuário e indicador de nuvem
            _buildUserProfileFooter(isDarkMode, currentProfile),
          ],
        ),
      ),
    );
  }

  // Barra de pesquisa para a sidebar
  Widget _buildSidebarSearchBar(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.sidebarBackgroundDark
            : AppColors.sidebarBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.magnifyingGlass(),
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Pesquisar páginas...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              onChanged: (value) {
                _performSearch(value);
              },
              onSubmitted: (value) {
                _performSearch(value);
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                _clearSearch();
              },
              icon: Icon(
                PhosphorIcons.x(),
                color: Colors.grey[600],
                size: 18,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
        ],
      ),
    );
  }

  // Diálogo de doação com QR code
  void _showDonateDialog(
      BuildContext context, AppStrings appStrings, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode
            ? AppColors.sidebarBackgroundDark
            : AppColors.sidebarBackground,
        title: Text(appStrings.donateDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/qrcode.png', width: 220, height: 220),
            const SizedBox(height: 16),
            Text(
              appStrings.donateDialogDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appStrings.closeButton),
          ),
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
                onSelected: (workspaceId) async {
                  ref
                      .read(workspaceProvider.notifier)
                      .selectWorkspace(workspaceId);

                  // Recarregar todos os providers para o novo workspace
                  final currentProfile = ref.read(currentProfileProvider);
                  final newWorkspace = ref.read(workspaceProvider);

                  if (currentProfile != null && newWorkspace != null) {
                    // Recarregar páginas
                    final pagesNotifier = ref.read(pagesNotifierProvider((
                      profileName: currentProfile.name,
                      workspaceName: newWorkspace.name
                    )));
                    await pagesNotifier.reloadPagesForWorkspace(
                      currentProfile.name,
                      newWorkspace.name,
                    );

                    // Recarregar outros providers
                    await ref
                        .read(passwordProvider.notifier)
                        .setContext(currentProfile.name, newWorkspace.id);
                    await ref
                        .read(agendaProvider.notifier)
                        .setContext(currentProfile.name, newWorkspace.id);
                    await ref
                        .read(documentosProvider.notifier)
                        .setContext(currentProfile.name, newWorkspace.id);

                    // Recarregar database
                    await ref
                        .read(databaseNotifierProvider.notifier)
                        .setContext(currentProfile.name, newWorkspace.id);
                  }
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
              onSelected: (workspaceId) async {
                ref
                    .read(workspaceProvider.notifier)
                    .selectWorkspace(workspaceId);

                // Recarregar todos os providers para o novo workspace
                final currentProfile = ref.read(currentProfileProvider);
                final newWorkspace = ref.read(workspaceProvider);

                if (currentProfile != null && newWorkspace != null) {
                  // Recarregar páginas
                  final pagesNotifier = ref.read(pagesNotifierProvider((
                    profileName: currentProfile.name,
                    workspaceName: newWorkspace.name
                  )));
                  await pagesNotifier.reloadPagesForWorkspace(
                    currentProfile.name,
                    newWorkspace.name,
                  );

                  // Recarregar outros providers
                  await ref
                      .read(passwordProvider.notifier)
                      .setContext(currentProfile.name, newWorkspace.id);
                  await ref
                      .read(agendaProvider.notifier)
                      .setContext(currentProfile.name, newWorkspace.id);
                  await ref
                      .read(documentosProvider.notifier)
                      .setContext(currentProfile.name, newWorkspace.id);

                  // Recarregar database
                  await ref
                      .read(databaseNotifierProvider.notifier)
                      .setContext(currentProfile.name, newWorkspace.id);
                }
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
                            fontSize: 14, // Tamanho uniforme
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
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 11, // Tamanho uniforme
                            ),
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
        width: 20, // Tamanho uniforme
        height: 20, // Tamanho uniforme
        // Removido o filtro de cor para manter as cores originais
        errorBuilder: (context, error, stackTrace) {
          // Fallback para ícone MaterialIcons se a imagem falhar
          return Icon(
            section.icon,
            size: 20, // Tamanho uniforme
            color: iconColor,
          );
        },
      );
    }

    return Icon(
      section.icon,
      size: 20, // Tamanho uniforme
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
          onTap: onTap,
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
                  size: 20, // Tamanho uniforme
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
                            fontSize: 14, // Tamanho uniforme
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
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.sidebarBackgroundDark.withOpacity(0.8)
            : AppColors.sidebarBackground.withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Indicador de estado da nuvem
          if (_isSidebarExpanded) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.sidebarItemHoverDark
                    : AppColors.sidebarItemHover,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const ExpandedCloudSyncIndicator(),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      // Mostrar detalhes da sincronização
                      _showCloudSyncDetails(context);
                    },
                    icon: const Icon(Icons.info_outline, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ] else ...[
            // Indicador compacto quando collapsed
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.sidebarItemHoverDark
                    : AppColors.sidebarItemHover,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const CompactCloudSyncIndicator(),
            ),
            const SizedBox(height: 12),
          ],

          // Perfil do usuário
          if (_isSidebarExpanded) ...[
            Builder(
              builder: (context) {
                debugPrint(
                    '🔍 WorkspaceScreen - currentProfile: ${currentProfile?.name}');
                debugPrint(
                    '🔍 WorkspaceScreen - currentProfile avatarPath: ${currentProfile?.avatarPath}');
                debugPrint(
                    '🔍 WorkspaceScreen - currentProfile avatarUrl: ${currentProfile?.avatarUrl}');
                debugPrint(
                    '🔍 WorkspaceScreen - currentProfile hasCustomAvatar: ${currentProfile?.hasCustomAvatar}');

                return Row(
                  children: [
                    // Avatar
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
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (currentProfile?.email != null)
                            Text(
                              currentProfile.email,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
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
                );
              },
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

  void _handleUserMenuAction(String action) async {
    switch (action) {
      case 'profile':
        context.pushNamed('profile');
        break;
      case 'settings':
        // Implementar navegação para configurações
        break;
      case 'logout':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sair e apagar dados locais?'),
            content: const Text(
                'Tem certeza que deseja sair? Isso irá remover seu perfil e TODOS os dados locais deste dispositivo.\n\n⚠️ Recomenda-se fazer um backup antes de continuar.\n\nEsta ação não pode ser desfeita.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Apagar e Sair'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          // Redirecionar imediatamente para onboarding
          if (mounted) {
            context.goNamed('onboarding');
          }

          // Deletar perfil em background (não bloquear a navegação)
          _deleteProfileInBackground();
        }
        break;
    }
  }

  /// Deletar perfil em background sem bloquear a navegação
  Future<void> _deleteProfileInBackground() async {
    try {
      // Deletar perfil usando o UserProfileService
      await ref.read(userProfileProvider.notifier).deleteProfile();
    } catch (e) {
      // Não mostrar erro ao usuário pois já está no onboarding
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
        return const BloquinhoDashboardScreen();
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

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.sidebarBackgroundDark
            : AppColors.sidebarBackground,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Ícone de pesquisa
          Icon(
            PhosphorIcons.magnifyingGlass(),
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),

          // Campo de pesquisa
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar em Bloquinho e Base de Dados...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              onChanged: (value) {
                _performSearch(value);
              },
              onSubmitted: (value) {
                _performSearch(value);
              },
            ),
          ),

          // Botão de limpar pesquisa
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                _clearSearch();
              },
              icon: Icon(
                PhosphorIcons.x(),
                color: Colors.grey[600],
                size: 18,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      _clearSearch();
      return;
    }

    // Implementar pesquisa em Bloquinho e Base de Dados
    _searchInBloquinho(query);
    _searchInDatabase(query);
  }

  void _searchInBloquinho(String query) {
    // Pesquisar em páginas do Bloquinho
    // TODO: Implementar pesquisa nas páginas do Bloquinho
  }

  void _searchInDatabase(String query) {
    // Pesquisar na Base de Dados
    // TODO: Implementar pesquisa na Base de Dados
  }

  void _clearSearch() {
    // Limpar resultados de pesquisa
  }

  void _showCloudSyncDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const CloudSyncStatusModal(),
    );
  }

  Widget _buildFloatingActionButton(bool isDarkMode) {
    // Só mostrar FAB quando estiver na seção documentos
    if (_selectedSection != Section.documentos) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: () {
        // Mostrar diálogo de adicionar documento baseado na aba atual
        _showAddDocumentDialog();
      },
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      child: Icon(PhosphorIcons.plus()),
    );
  }

  void _showAddDocumentDialog() {
    // Implementar lógica para mostrar o diálogo correto baseado na aba atual
    // Por enquanto, mostrar um snackbar informativo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Use os botões + dentro de cada aba para adicionar documentos'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
