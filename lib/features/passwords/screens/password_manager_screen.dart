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

import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/password_provider.dart';
import '../models/password_entry.dart';
import '../widgets/password_card.dart';
import '../widgets/password_filters.dart';
import '../widgets/password_stats_card.dart';
import '../widgets/add_password_dialog.dart';
import '../widgets/password_generator_dialog.dart';
import '../services/password_csv_service.dart';

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
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        foregroundColor:
            isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/workspace'),
          tooltip: 'Voltar',
        ),
        title: Row(
          children: [
            Icon(
              PhosphorIcons.lockKey(),
              size: 24,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            const Text('Senhas'),
          ],
        ),
        actions: [
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
      body: Column(
        children: [
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
            textInputAction: TextInputAction.search,
            enableInteractiveSelection: true,
            autocorrect: false,
            enableSuggestions: true,
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
      child: _buildGroupedPasswordsList(passwords, isDarkMode),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selecione um arquivo CSV para importar:'),
            const SizedBox(height: 8),
            const Text(
              '• Formato suportado: NordPass CSV',
              style: TextStyle(fontSize: 12),
            ),
            const Text(
              '• Apenas entradas do tipo "login" serão importadas',
              style: TextStyle(fontSize: 12),
            ),
            const Text(
              '• Dados serão encriptados automaticamente',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _importPasswords();
            },
            child: const Text('Importar'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Senhas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Exportar todas as senhas para CSV:'),
            const SizedBox(height: 8),
            const Text(
              '• Formato: NordPass CSV compatível',
              style: TextStyle(fontSize: 12),
            ),
            const Text(
              '• Arquivo será salvo na pasta Downloads',
              style: TextStyle(fontSize: 12),
            ),
            const Text(
              '• ⚠️ Dados não serão encriptados no CSV',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _exportPasswords();
            },
            child: const Text('Exportar'),
          ),
        ],
      ),
    );
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

  Widget _buildGroupedPasswordsList(List<PasswordEntry> passwords, bool isDarkMode) {
    // Agrupar passwords por categoria
    final groupedPasswords = <String, List<PasswordEntry>>{};
    final pinnedPasswords = <PasswordEntry>[];
    final favoritePasswords = <PasswordEntry>[];
    final weakPasswords = <PasswordEntry>[];
    final expiredPasswords = <PasswordEntry>[];
    
    for (final password in passwords) {
      if (password.isPinned) {
        pinnedPasswords.add(password);
      } else if (password.isFavorite) {
        favoritePasswords.add(password);
      } else if (password.isExpired) {
        expiredPasswords.add(password);
      } else if (password.strength == PasswordStrength.veryWeak || password.strength == PasswordStrength.weak) {
        weakPasswords.add(password);
      } else {
        final category = password.category ?? 'Outras';
        groupedPasswords[category] = groupedPasswords[category] ?? [];
        groupedPasswords[category]!.add(password);
      }
    }
    
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // Seção: Fixadas
        if (pinnedPasswords.isNotEmpty) ..._buildSection(
          'Fixadas',
          pinnedPasswords,
          Icons.push_pin,
          Colors.orange,
          isDarkMode,
        ),
        
        // Seção: Favoritas
        if (favoritePasswords.isNotEmpty) ..._buildSection(
          'Favoritas',
          favoritePasswords,
          Icons.star,
          Colors.amber,
          isDarkMode,
        ),
        
        // Seção: Senhas Fracas
        if (weakPasswords.isNotEmpty) ..._buildSection(
          'Senhas Fracas',
          weakPasswords,
          Icons.warning,
          Colors.orange,
          isDarkMode,
        ),
        
        // Seção: Expiradas
        if (expiredPasswords.isNotEmpty) ..._buildSection(
          'Expiradas',
          expiredPasswords,
          Icons.schedule,
          Colors.red,
          isDarkMode,
        ),
        
        // Seções por categoria
        ...groupedPasswords.entries.expand((entry) => 
          _buildSection(
            entry.key,
            entry.value,
            _getCategoryIcon(entry.key),
            _getCategoryColor(entry.key),
            isDarkMode,
          )
        ).toList(),
      ],
    );
  }
  
  List<Widget> _buildSection(
    String title,
    List<PasswordEntry> passwords,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return [
      // Cabeçalho da seção
      Container(
        margin: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${passwords.length}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Lista de passwords da seção
      ...passwords.map((password) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: _buildCompactPasswordCard(password, isDarkMode),
      )).toList(),
    ];
  }
  
  Widget _buildCompactPasswordCard(PasswordEntry password, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: () => _showPasswordDetails(context, password),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Ícone da categoria
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: password.strengthColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  password.categoryIcon,
                  color: password.strengthColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              
              // Informações principais
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      password.displayTitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (password.website != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        password.domain,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Indicadores de status
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (password.isPinned)
                    Icon(
                      Icons.push_pin,
                      size: 14,
                      color: Colors.orange,
                    ),
                  if (password.isFavorite)
                    Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.amber,
                    ),
                  if (password.hasTwoFactor)
                    Icon(
                      Icons.security,
                      size: 14,
                      color: Colors.green,
                    ),
                  if (password.isExpired)
                    Icon(
                      Icons.warning,
                      size: 14,
                      color: Colors.red,
                    ),
                ],
              ),
              
              const SizedBox(width: 8),
              
              // Ações rápidas
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _copyToClipboard(password.username, 'Utilizador copiado'),
                    icon: Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    tooltip: 'Copiar utilizador',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: () => _copyToClipboard(password.password, 'Senha copiada'),
                    icon: Icon(
                      Icons.lock,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    tooltip: 'Copiar senha',
                    visualDensity: VisualDensity.compact,
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handlePasswordAction(value, password),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Editar'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'favorite',
                        child: ListTile(
                          leading: Icon(password.isFavorite ? Icons.star : Icons.star_border),
                          title: Text(password.isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Excluir', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _handlePasswordAction(String action, PasswordEntry password) {
    switch (action) {
      case 'edit':
        _showEditPasswordDialog(context, password);
        break;
      case 'favorite':
        ref.read(passwordProvider.notifier).toggleFavorite(password.id);
        break;
      case 'delete':
        _showDeleteConfirmation(context, password);
        break;
    }
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'social':
        return Icons.people;
      case 'finance':
        return Icons.account_balance;
      case 'work':
        return Icons.work;
      case 'email':
        return Icons.email;
      case 'shopping':
        return Icons.shopping_cart;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.health_and_safety;
      case 'education':
        return Icons.school;
      default:
        return Icons.folder;
    }
  }
  
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'social':
        return Colors.blue;
      case 'finance':
        return Colors.green;
      case 'work':
        return Colors.purple;
      case 'email':
        return Colors.orange;
      case 'shopping':
        return Colors.pink;
      case 'entertainment':
        return Colors.red;
      case 'health':
        return Colors.teal;
      case 'education':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  Future<void> _importPasswords() async {
    try {
      // Mostrar indicador de carregamento
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Importando senhas...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Importar do CSV
      final passwords = await PasswordCsvService.importFromCsv();
      
      if (passwords.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhuma senha válida encontrada no arquivo'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Adicionar senhas ao provider
      int successCount = 0;
      for (final password in passwords) {
        try {
          await ref.read(passwordProvider.notifier).createPassword(password);
          successCount++;
        } catch (e) {
          // Continuar com as próximas senhas se uma falhar
          continue;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount senhas importadas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao importar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportPasswords() async {
    try {
      // Mostrar indicador de carregamento
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exportando senhas...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Obter todas as senhas
      final passwords = ref.read(filteredPasswordsProvider);
      
      if (passwords.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhuma senha para exportar'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Exportar para CSV
      final filePath = await PasswordCsvService.exportToDownloads(passwords);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${passwords.length} senhas exportadas para:\n$filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
