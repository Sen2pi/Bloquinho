import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/password_provider.dart';
import '../models/password_entry.dart';
import '../widgets/password_card.dart';
import '../widgets/password_filters.dart';
import '../widgets/password_stats_card.dart';
import '../widgets/add_password_dialog.dart';
import '../widgets/password_generator_dialog.dart';

class PasswordManagerScreen extends ConsumerStatefulWidget {
  const PasswordManagerScreen({super.key});

  @override
  ConsumerState<PasswordManagerScreen> createState() =>
      _PasswordManagerScreenState();
}

class _PasswordManagerScreenState extends ConsumerState<PasswordManagerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(passwordProvider.notifier).setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final passwords = ref.watch(filteredPasswordsProvider);
    final stats = ref.watch(passwordStatsProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final error = ref.watch(errorProvider);

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          // Header
          _buildHeader(isDarkMode, stats),

          // Filtros
          PasswordFilters(
            onCategoryChanged: (category) => ref
                .read(passwordProvider.notifier)
                .setSelectedCategory(category),
            onFolderChanged: (folderId) =>
                ref.read(passwordProvider.notifier).setSelectedFolder(folderId),
            onToggleFavorites: () =>
                ref.read(passwordProvider.notifier).toggleFavoritesOnly(),
            onToggleWeak: () =>
                ref.read(passwordProvider.notifier).toggleWeakOnly(),
            onToggleExpired: () =>
                ref.read(passwordProvider.notifier).toggleExpiredOnly(),
            onClearFilters: () =>
                ref.read(passwordProvider.notifier).clearFilters(),
          ),

          // Conteúdo principal
          Expanded(
            child: _buildContent(isDarkMode, passwords, isLoading, error),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(isDarkMode),
    );
  }

  Widget _buildHeader(bool isDarkMode, Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.lockKey(),
                size: 32,
                color: AppColors.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestor de Palavras-Passe',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                    ),
                    Text(
                      '${stats['total'] ?? 0} senhas armazenadas',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showPasswordGenerator(context),
                icon: Icon(PhosphorIcons.key()),
                tooltip: 'Gerador de Senhas',
              ),
              IconButton(
                onPressed: () => _showImportDialog(context),
                icon: Icon(PhosphorIcons.upload()),
                tooltip: 'Importar',
              ),
              IconButton(
                onPressed: () => _showExportDialog(context),
                icon: Icon(PhosphorIcons.download()),
                tooltip: 'Exportar',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Barra de pesquisa
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Pesquisar senhas...',
              prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                      },
                      icon: Icon(PhosphorIcons.x()),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color:
                      isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              filled: true,
              fillColor:
                  isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDarkMode, List<PasswordEntry> passwords,
      bool isLoading, String? error) {
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
              PhosphorIcons.warning(),
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar senhas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(passwordProvider.notifier).refresh(),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (passwords.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(passwordProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: passwords.length,
        itemBuilder: (context, index) {
          final password = passwords[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PasswordCard(
              password: password,
              onTap: () => _showPasswordDetails(context, password),
              onEdit: () => _showEditPasswordDialog(context, password),
              onDelete: () => _showDeleteConfirmation(context, password),
              onToggleFavorite: () => ref
                  .read(passwordProvider.notifier)
                  .toggleFavorite(password.id),
              onCopyPassword: () =>
                  _copyToClipboard(password.password, 'Senha copiada'),
              onCopyUsername: () =>
                  _copyToClipboard(password.username, 'Utilizador copiado'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.lockKey(),
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhuma senha encontrada',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione sua primeira senha para começar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddPasswordDialog(context),
            icon: Icon(PhosphorIcons.plus()),
            label: const Text('Adicionar Senha'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(bool isDarkMode) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddPasswordDialog(context),
      icon: Icon(PhosphorIcons.plus()),
      label: const Text('Nova Senha'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    );
  }

  // Diálogos e ações
  void _showAddPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddPasswordDialog(),
    );
  }

  void _showEditPasswordDialog(BuildContext context, PasswordEntry password) {
    showDialog(
      context: context,
      builder: (context) => AddPasswordDialog(password: password),
    );
  }

  void _showPasswordDetails(BuildContext context, PasswordEntry password) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPasswordDetailsSheet(password),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PasswordEntry password) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content:
            Text('Tem certeza que deseja excluir "${password.displayTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(passwordProvider.notifier).deletePassword(password.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showPasswordGenerator(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PasswordGeneratorDialog(),
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importar Senhas'),
        content: const Text(
            'Funcionalidade de importação será implementada em breve.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) async {
    try {
      final data = await ref.read(passwordProvider.notifier).exportPasswords();
      // Implementar exportação real aqui
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exportação iniciada...')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro na exportação: $e')),
      );
    }
  }

  Widget _buildPasswordDetailsSheet(PasswordEntry password) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(
                  password.categoryIcon,
                  size: 32,
                  color: password.strengthColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        password.displayTitle,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (password.website != null)
                        Text(
                          password.website!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(PhosphorIcons.x()),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem(
                      'Utilizador',
                      password.username,
                      () => _copyToClipboard(
                          password.username, 'Utilizador copiado')),
                  _buildDetailItem(
                      'Senha',
                      '••••••••',
                      () =>
                          _copyToClipboard(password.password, 'Senha copiada'),
                      isPassword: true),
                  if (password.website != null)
                    _buildDetailItem(
                        'Website',
                        password.website!,
                        () => _copyToClipboard(
                            password.website!, 'Website copiado')),
                  if (password.notes != null && password.notes!.isNotEmpty)
                    _buildDetailItem('Notas', password.notes!, null),
                  if (password.category != null)
                    _buildDetailItem('Categoria', password.category!, null),
                  if (password.tags.isNotEmpty)
                    _buildDetailItem('Tags', password.tags.join(', '), null),
                  _buildDetailItem('Força', password.strengthText, null,
                      color: password.strengthColor),
                  _buildDetailItem(
                      'Criado', _formatDate(password.createdAt), null),
                  _buildDetailItem(
                      'Atualizado', _formatDate(password.updatedAt), null),
                  if (password.lastUsed != null)
                    _buildDetailItem(
                        'Último uso', _formatDate(password.lastUsed!), null),
                  if (password.expiresAt != null)
                    _buildDetailItem(
                        'Expira em', _formatDate(password.expiresAt!), null),
                ],
              ),
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showEditPasswordDialog(context, password);
                    },
                    icon: Icon(PhosphorIcons.pencil()),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _copyToClipboard(password.password, 'Senha copiada');
                    },
                    icon: Icon(PhosphorIcons.copy()),
                    label: const Text('Copiar Senha'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, VoidCallback? onCopy,
      {bool isPassword = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: color,
                        fontFamily: isPassword ? 'monospace' : null,
                      ),
                ),
              ),
              if (onCopy != null)
                IconButton(
                  onPressed: onCopy,
                  icon: Icon(PhosphorIcons.copy()),
                  tooltip: 'Copiar',
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text, String message) {
    // Implementar cópia para clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
