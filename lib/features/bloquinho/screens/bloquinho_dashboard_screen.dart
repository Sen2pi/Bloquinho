import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../shared/providers/workspace_provider.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/pages_provider.dart';
import '../models/page_model.dart';
import '../widgets/page_tree_widget.dart';

class BloquinhoDashboardScreen extends ConsumerStatefulWidget {
  const BloquinhoDashboardScreen({super.key});

  @override
  ConsumerState<BloquinhoDashboardScreen> createState() =>
      _BloquinhoDashboardScreenState();
}

class _BloquinhoDashboardScreenState
    extends ConsumerState<BloquinhoDashboardScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final currentProfile = ref.watch(currentProfileProvider);
    final currentWorkspace = ref.watch(currentWorkspaceProvider);

    if (currentProfile == null || currentWorkspace == null) {
      return _buildErrorView('Perfil ou workspace não disponível');
    }

    final pages = ref.watch(pagesProvider((
      profileName: currentProfile.name,
      workspaceName: currentWorkspace.name
    )));

    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: _buildAppBar(isDarkMode),
        body: _buildBody(isDarkMode, pages),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      elevation: 0,
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      foregroundColor:
          isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      title: Row(
        children: [
          Text('📚', style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          const Text('Bloquinho Dashboard'),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _toggleExpanded(),
          icon: Icon(_isExpanded
              ? PhosphorIcons.caretUp()
              : PhosphorIcons.caretDown()),
          tooltip: _isExpanded ? 'Recolher' : 'Expandir',
        ),
      ],
    );
  }

  Widget _buildBody(bool isDarkMode, List<PageModel> pages) {
    return Column(
      children: [
        // Dashboard principal
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(isDarkMode, pages),
                const SizedBox(height: 24),
                _buildRecentActivity(isDarkMode, pages),
                const SizedBox(height: 24),
                _buildStorageInfo(isDarkMode, pages),
                const SizedBox(height: 24),
                _buildQuickActions(isDarkMode),
              ],
            ),
          ),
        ),

        // Árvore de páginas (expandível)
        if (_isExpanded)
          Container(
            height: 300,
            decoration: BoxDecoration(
              color:
                  isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color:
                      isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
            ),
            child: PageTreeWidget(
              onPageSelected: (pageId) {
                // Navegar para a página selecionada
                context.push('/workspace/bloquinho/editor/$pageId');
              },
            ),
          ),
      ],
    );
  }

  Widget _buildOverviewCards(bool isDarkMode, List<PageModel> pages) {
    final totalPages = pages.length;
    final rootPages = pages.where((p) => p.isRoot).length;
    final subPages = totalPages - rootPages;
    final totalContent =
        pages.fold<int>(0, (sum, page) => sum + page.content.length);
    final avgContentPerPage = totalPages > 0 ? totalContent / totalPages : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visão Geral',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                isDarkMode,
                '📄',
                'Total de Páginas',
                totalPages.toString(),
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                isDarkMode,
                '📁',
                'Páginas Raiz',
                rootPages.toString(),
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                isDarkMode,
                '📂',
                'Subpáginas',
                subPages.toString(),
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                isDarkMode,
                '📝',
                'Conteúdo Total',
                '${(totalContent / 1024).toStringAsFixed(1)} KB',
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                isDarkMode,
                '📊',
                'Média por Página',
                '${avgContentPerPage.toStringAsFixed(0)} chars',
                Colors.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      bool isDarkMode, String icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(bool isDarkMode, List<PageModel> pages) {
    final recentPages = pages
        .where((p) => p.updatedAt
            .isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Atividade Recente',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
          child: recentPages.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          PhosphorIcons.clock(),
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma atividade recente',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[400],
                                  ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentPages.length > 5 ? 5 : recentPages.length,
                  separatorBuilder: (context, index) => Divider(
                    color: isDarkMode
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final page = recentPages[index];
                    return ListTile(
                      leading: Text(
                        page.icon ?? '📄',
                        style: const TextStyle(fontSize: 20),
                      ),
                      title: Text(page.title),
                      subtitle: Text(
                        'Atualizado em ${_formatDate(page.updatedAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      trailing: Icon(
                        PhosphorIcons.arrowRight(),
                        size: 16,
                        color: Colors.grey[400],
                      ),
                      onTap: () {
                        context.push('/workspace/bloquinho/editor/${page.id}');
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStorageInfo(bool isDarkMode, List<PageModel> pages) {
    final totalContent =
        pages.fold<int>(0, (sum, page) => sum + page.content.length);
    final totalSizeKB = totalContent / 1024;
    final totalSizeMB = totalSizeKB / 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações de Armazenamento',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildStorageRow('📄 Páginas', pages.length.toString()),
              const SizedBox(height: 8),
              _buildStorageRow('📝 Caracteres', totalContent.toString()),
              const SizedBox(height: 8),
              _buildStorageRow(
                  '💾 Tamanho', '${totalSizeMB.toStringAsFixed(2)} MB'),
              const SizedBox(height: 8),
              _buildStorageRow(
                  '📅 Última atualização', _formatDate(DateTime.now())),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStorageRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                isDarkMode,
                PhosphorIcons.plus(),
                'Nova Página',
                'Criar uma nova página',
                () => context.push('/workspace/bloquinho/editor'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                isDarkMode,
                PhosphorIcons.folderPlus(),
                'Nova Subpágina',
                'Criar uma subpágina',
                () => _showSubPageDialog(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                isDarkMode,
                PhosphorIcons.upload(),
                'Importar',
                'Importar páginas do Notion',
                () => _showImportDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                isDarkMode,
                PhosphorIcons.download(),
                'Exportar',
                'Exportar todas as páginas',
                () => _showExportDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(bool isDarkMode, IconData icon, String title,
      String subtitle, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 24, color: AppColors.primary),
                const SizedBox(height: 12),
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
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erro')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.warning(),
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro no Dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _showSubPageDialog() {
    final currentProfile = ref.read(currentProfileProvider);
    final currentWorkspace = ref.read(currentWorkspaceProvider);

    if (currentProfile == null || currentWorkspace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erro: Perfil ou workspace não disponível')),
      );
      return;
    }

    final pages = ref.read(pagesProvider((
      profileName: currentProfile.name,
      workspaceName: currentWorkspace.name
    )));

    if (pages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma página disponível para ser pai')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _ParentPageSelectorDialog(
        pages: pages,
        onParentSelected: (parentId) {
          // Criar subpágina e navegar para ela
          final pagesNotifier = ref.read(pagesNotifierProvider((
            profileName: currentProfile.name,
            workspaceName: currentWorkspace.name
          )));

          final newPage = PageModel.create(
            title: 'Nova Subpágina',
            parentId: parentId,
          );

          pagesNotifier.state = [...pagesNotifier.state, newPage];

          // Navegar para a nova subpágina
          context.push('/workspace/bloquinho/editor/${newPage.id}');

          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showImportDialog() {
    // TODO: Implementar importação
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _showExportDialog() {
    // TODO: Implementar exportação
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutos atrás';
      }
      return '${difference.inHours} horas atrás';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Dialog para selecionar página pai
class _ParentPageSelectorDialog extends StatefulWidget {
  final List<PageModel> pages;
  final Function(String parentId) onParentSelected;

  const _ParentPageSelectorDialog({
    required this.pages,
    required this.onParentSelected,
  });

  @override
  State<_ParentPageSelectorDialog> createState() =>
      _ParentPageSelectorDialogState();
}

class _ParentPageSelectorDialogState extends State<_ParentPageSelectorDialog> {
  String _searchQuery = '';
  List<PageModel> _filteredPages = [];

  @override
  void initState() {
    super.initState();
    _filteredPages = widget.pages;
  }

  void _filterPages(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPages = widget.pages;
      } else {
        _filteredPages = widget.pages
            .where((page) =>
                page.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecionar Página Pai'),
      content: Container(
        width: 400,
        height: 300,
        child: Column(
          children: [
            // Campo de busca
            TextField(
              onChanged: _filterPages,
              decoration: InputDecoration(
                hintText: 'Buscar páginas...',
                prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 16),

            // Lista de páginas
            Expanded(
              child: _filteredPages.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'Nenhuma página disponível'
                            : 'Nenhuma página encontrada para "$_searchQuery"',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredPages.length,
                      itemBuilder: (context, index) {
                        final page = _filteredPages[index];
                        return ListTile(
                          leading: Text(
                            page.icon ?? '📄',
                            style: const TextStyle(fontSize: 20),
                          ),
                          title: Text(page.title),
                          subtitle: page.parentId != null
                              ? Text(
                                  'Subpágina de: ${_getParentTitle(page.parentId!)}')
                              : const Text('Página raiz'),
                          onTap: () {
                            widget.onParentSelected(page.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  String _getParentTitle(String parentId) {
    final parent = widget.pages.firstWhere(
      (p) => p.id == parentId,
      orElse: () => PageModel.create(title: 'Página não encontrada'),
    );
    return parent.title;
  }
}
