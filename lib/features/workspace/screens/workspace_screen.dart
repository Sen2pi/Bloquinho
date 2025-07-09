import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../backup/screens/backup_screen.dart';

class WorkspaceScreen extends ConsumerStatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  bool _isSidebarExpanded = true;
  int _selectedSidebarItem = 0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isSidebarExpanded ? 280 : 60,
            child: _buildSidebar(isDarkMode),
          ),

          // Divisor
          Container(
            width: 1,
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          ),

          // Conteúdo principal
          Expanded(
            child: _buildMainContent(isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isDarkMode) {
    return Container(
      color: isDarkMode
          ? AppColors.sidebarBackgroundDark
          : AppColors.sidebarBackground,
      child: Column(
        children: [
          // Header da sidebar
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (_isSidebarExpanded) ...[
                  // Logo
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        isDarkMode ? 'logoDark.png' : 'logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bloquinho',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
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
          ),

          const Divider(height: 1),

          // Itens da sidebar
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _buildSidebarItem(
                  icon: PhosphorIcons.house(),
                  label: 'Início',
                  index: 0,
                  isDarkMode: isDarkMode,
                ),
                _buildSidebarItem(
                  icon: PhosphorIcons.plus(),
                  label: 'Nova Página',
                  index: 1,
                  isDarkMode: isDarkMode,
                ),
                _buildSidebarItem(
                  icon: PhosphorIcons.folder(),
                  label: 'Documentos',
                  index: 2,
                  isDarkMode: isDarkMode,
                ),
                _buildSidebarItem(
                  icon: PhosphorIcons.database(),
                  label: 'Bases de Dados',
                  index: 3,
                  isDarkMode: isDarkMode,
                ),
                _buildSidebarItem(
                  icon: PhosphorIcons.trash(),
                  label: 'Lixeira',
                  index: 4,
                  isDarkMode: isDarkMode,
                ),
                _buildSidebarItem(
                  icon: PhosphorIcons.user(),
                  label: 'Perfil',
                  index: 8,
                  isDarkMode: isDarkMode,
                ),
                _buildSidebarItem(
                  icon: PhosphorIcons.downloadSimple(),
                  label: 'Backup',
                  index: 7,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 16),
                if (_isSidebarExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Favoritos',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                _buildSidebarItem(
                  icon: PhosphorIcons.star(),
                  label: 'Projeto A',
                  index: 5,
                  isDarkMode: isDarkMode,
                ),
                _buildSidebarItem(
                  icon: PhosphorIcons.star(),
                  label: 'Reuniões',
                  index: 6,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),

          // Footer da sidebar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_isSidebarExpanded) ...[
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Usuário',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isDarkMode,
  }) {
    final isSelected = _selectedSidebarItem == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() {
              _selectedSidebarItem = index;
            });

            // Navegar para telas específicas
            if (index == 7) {
              context.pushNamed('backup');
            } else if (index == 8) {
              context.pushNamed('profile');
            }
          },
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

  Widget _buildMainContent(bool isDarkMode) {
    return Container(
      color: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      child: Column(
        children: [
          // Header do conteúdo
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color:
                      isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Bem-vindo ao Bloquinho',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(PhosphorIcons.magnifyingGlass()),
                  tooltip: 'Pesquisar',
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(PhosphorIcons.bell()),
                  tooltip: 'Notificações',
                ),
              ],
            ),
          ),

          // Conteúdo principal
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIcons.fileText(),
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Comece criando uma nova página',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implementar criação de página
                    },
                    icon: Icon(PhosphorIcons.plus()),
                    label: const Text('Nova Página'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
