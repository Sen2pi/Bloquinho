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
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../shared/providers/workspace_provider.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/pages_provider.dart';
import '../models/page_model.dart';
import '../widgets/page_tree_widget.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../core/models/app_language.dart';

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
    final strings = ref.watch(appStringsProvider);

    if (currentProfile == null || currentWorkspace == null) {
      return _buildErrorView(strings.profileOrWorkspaceNotAvailable);
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
        appBar: _buildAppBar(isDarkMode, strings),
        body: _buildBody(isDarkMode, pages, strings),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode, AppStrings strings) {
    return AppBar(
      elevation: 0,
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      foregroundColor:
          isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => context.go('/workspace'),
        tooltip: strings.back,
      ),
      title: Row(
        children: [
          Text('📚', style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(strings.bloquinho),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _toggleExpanded(),
          icon: Icon(_isExpanded
              ? PhosphorIcons.caretUp()
              : PhosphorIcons.caretDown()),
          tooltip: _isExpanded ? strings.collapse : strings.expand,
        ),
      ],
    );
  }

  Widget _buildBody(
      bool isDarkMode, List<PageModel> pages, AppStrings strings) {
    return Column(
      children: [
        // Dashboard principal
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(isDarkMode, pages, strings),
                const SizedBox(height: 24),
                _buildRecentActivity(isDarkMode, pages, strings),
                const SizedBox(height: 24),
                _buildStorageInfo(isDarkMode, pages, strings),
                const SizedBox(height: 24),
                _buildQuickActions(isDarkMode, strings),
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

  Widget _buildOverviewCards(
      bool isDarkMode, List<PageModel> pages, AppStrings strings) {
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
          strings.overview,
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
                strings.totalPages,
                totalPages.toString(),
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                isDarkMode,
                '📁',
                strings.rootPages,
                rootPages.toString(),
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                isDarkMode,
                '📂',
                strings.subpages,
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
                strings.totalContent,
                '${(totalContent / 1024).toStringAsFixed(1)} KB',
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                isDarkMode,
                '📊',
                strings.averagePerPage,
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

  Widget _buildRecentActivity(
      bool isDarkMode, List<PageModel> pages, AppStrings strings) {
    final recentPages = pages
        .where((p) => p.updatedAt
            .isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.recentActivity,
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
                          strings.noRecentActivity,
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
                        '${strings.updatedAt} ${_formatDate(page.updatedAt, strings)}',
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

  Widget _buildStorageInfo(
      bool isDarkMode, List<PageModel> pages, AppStrings strings) {
    final totalContent =
        pages.fold<int>(0, (sum, page) => sum + page.content.length);
    final totalSizeKB = totalContent / 1024;
    final totalSizeMB = totalSizeKB / 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.storageInfo,
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
              _buildStorageRow('📄 ${strings.pages}', pages.length.toString()),
              const SizedBox(height: 8),
              _buildStorageRow(
                  '📝 ${strings.characters}', totalContent.toString()),
              const SizedBox(height: 8),
              _buildStorageRow(
                  '💾 ${strings.size}', '${totalSizeMB.toStringAsFixed(2)} MB'),
              const SizedBox(height: 8),
              _buildStorageRow('📅 ${strings.lastUpdate}',
                  _formatDate(DateTime.now(), strings)),
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

  Widget _buildQuickActions(bool isDarkMode, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.quickActions,
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
                strings.newPage,
                strings.createNewPage,
                () => context.push('/workspace/bloquinho/editor'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                isDarkMode,
                PhosphorIcons.folderPlus(),
                strings.newSubpage,
                strings.createSubpage,
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
                strings.import,
                strings.importFromNotion,
                () => _showImportDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                isDarkMode,
                PhosphorIcons.download(),
                strings.export,
                strings.exportAllPages,
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
    final strings = ref.read(appStringsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(strings.error)),
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
              strings.dashboardError,
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
    final strings = ref.read(appStringsProvider);
    final currentProfile = ref.read(currentProfileProvider);
    final currentWorkspace = ref.read(currentWorkspaceProvider);

    if (currentProfile == null || currentWorkspace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.errorProfileOrWorkspaceNotAvailable)),
      );
      return;
    }

    final pages = ref.read(pagesProvider((
      profileName: currentProfile.name,
      workspaceName: currentWorkspace.name
    )));

    if (pages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.noParentPageAvailable)),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _ParentPageSelectorDialog(
        pages: pages,
        onParentSelected: (parentId) async {
          // Criar subpágina com template baseado no idioma
          final pagesNotifier = ref.read(pagesNotifierProvider((
            profileName: currentProfile.name,
            workspaceName: currentWorkspace.name
          )));

          try {
            // Criar página simples sem template
            final newPage = PageModel.create(
              title: strings.newSubpage,
              parentId: parentId,
            );

            pagesNotifier.state = [...pagesNotifier.state, newPage];

            // Navegar para a nova subpágina
            context.push('/workspace/bloquinho/editor/${newPage.id}');
          } catch (e) {
            // Em caso de erro, mostrar mensagem
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao criar página: $e')),
            );
          }

          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showImportDialog() {
    final strings = ref.read(appStringsProvider);
    // TODO: Implementar importação
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.featureInDevelopment)),
    );
  }

  void _showExportDialog() {
    final strings = ref.read(appStringsProvider);
    // TODO: Implementar exportação
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.featureInDevelopment)),
    );
  }

  String _formatDate(DateTime date, AppStrings strings) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return strings.minutesAgo(difference.inMinutes);
      }
      return strings.hoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      return '${strings.yesterday} ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return strings.daysAgo(difference.inDays);
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}

// Dialog para selecionar página pai
class _ParentPageSelectorDialog extends ConsumerStatefulWidget {
  final List<PageModel> pages;
  final Function(String parentId) onParentSelected;

  const _ParentPageSelectorDialog({
    required this.pages,
    required this.onParentSelected,
  });

  @override
  ConsumerState<_ParentPageSelectorDialog> createState() =>
      _ParentPageSelectorDialogState();
}

class _ParentPageSelectorDialogState
    extends ConsumerState<_ParentPageSelectorDialog> {
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
    final strings = ref.watch(appStringsProvider);
    return AlertDialog(
      title: Text(strings.selectParentPage),
      content: Container(
        width: 400,
        height: 300,
        child: Column(
          children: [
            // Campo de busca
            TextField(
              onChanged: _filterPages,
              decoration: InputDecoration(
                hintText: strings.searchPages,
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
                            ? strings.noPagesAvailable
                            : strings.noPagesFoundFor(_searchQuery),
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
                              ? Text(strings
                                  .subpageOf(_getParentTitle(page.parentId!)))
                              : Text(strings.rootPage),
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
          child: Text(strings.cancel),
        ),
      ],
    );
  }

  String _getParentTitle(String parentId) {
    final strings = ref.read(appStringsProvider);
    final parent = widget.pages.firstWhere(
      (p) => p.id == parentId,
      orElse: () => PageModel.create(title: strings.pageNotFound),
    );
    return parent.title;
  }
}
