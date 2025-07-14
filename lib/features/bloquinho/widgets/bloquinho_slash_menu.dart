/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/bloquinho_slash_command.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/models/app_language.dart';

class BloquinhoSlashMenu extends StatefulWidget {
  final String searchQuery;
  final Function(BloquinhoSlashCommand) onCommandSelected;
  final VoidCallback onDismiss;

  const BloquinhoSlashMenu({
    super.key,
    required this.searchQuery,
    required this.onCommandSelected,
    required this.onDismiss,
  });

  @override
  State<BloquinhoSlashMenu> createState() => _BloquinhoSlashMenuState();
}

class _BloquinhoSlashMenuState extends State<BloquinhoSlashMenu> {
  List<BloquinhoSlashCommand> _filteredCommands = [];
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _filterCommands();
  }

  @override
  void didUpdateWidget(BloquinhoSlashMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _filterCommands();
    }
  }

  void _filterCommands() {
    final strings = AppStringsProvider.of(AppLanguage.portuguese);
    if (widget.searchQuery.isEmpty) {
      _filteredCommands = BloquinhoSlashCommand.popularCommands(strings);
    } else {
      _filteredCommands =
          BloquinhoSlashCommand.search(widget.searchQuery, strings);
    }
  }

  List<BloquinhoSlashCommand> _getCommandsByCategory(String category) {
    return _filteredCommands.where((cmd) => cmd.category == category).toList();
  }

  List<String> _getCategories() {
    final strings = AppStringsProvider.of(AppLanguage.portuguese);
    return strings.slashCommandCategories;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Container(
        width: 320,
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(isDarkMode),

            // Search bar
            if (widget.searchQuery.isEmpty) _buildSearchBar(isDarkMode),

            // Content
            Expanded(
              child: _buildContent(isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkSurface.withOpacity(0.8)
            : AppColors.lightSurface.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.minus(),
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Comandos Bloquinho',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onDismiss,
            icon: Icon(
              PhosphorIcons.x(),
              size: 18,
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Buscar comandos...',
          prefixIcon: Icon(
            PhosphorIcons.magnifyingGlass(),
            color: isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          filled: true,
          fillColor:
              isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        style: TextStyle(
          color: isDarkMode
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    if (_filteredCommands.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    if (widget.searchQuery.isNotEmpty) {
      return _buildSearchResults(isDarkMode);
    }

    return _buildCategorizedContent(isDarkMode);
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.magnifyingGlass(),
              size: 48,
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum comando encontrado',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente uma busca diferente',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredCommands.length,
      itemBuilder: (context, index) {
        final command = _filteredCommands[index];
        return _buildCommandTile(command, isDarkMode);
      },
    );
  }

  Widget _buildCategorizedContent(bool isDarkMode) {
    final strings = AppStringsProvider.of(AppLanguage.portuguese);
    final categories = BloquinhoSlashCommand.categories(strings);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryCommands = _getCommandsByCategory(category);

        if (categoryCommands.isEmpty) return const SizedBox.shrink();

        return _buildCategorySection(category, categoryCommands, isDarkMode);
      },
    );
  }

  Widget _buildCategorySection(
    String category,
    List<BloquinhoSlashCommand> commands,
    bool isDarkMode,
  ) {
    final strings = AppStringsProvider.of(AppLanguage.portuguese);
    final categoryCommand = commands.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                categoryCommand.categoryIcon,
                size: 16,
                color: categoryCommand.categoryColorValue,
              ),
              const SizedBox(width: 8),
              Text(
                categoryCommand.getCategoryName(strings),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: categoryCommand.categoryColorValue,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        // Category commands
        ...commands.map((command) => _buildCommandTile(command, isDarkMode)),
      ],
    );
  }

  Widget _buildCommandTile(BloquinhoSlashCommand command, bool isDarkMode) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.onCommandSelected(command); // Executa ação primeiro
          // O overlay será removido pelo callback _insertSlashCommand
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: command.categoryColorValue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  command.icon,
                  size: 16,
                  color: command.categoryColorValue,
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      command.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      command.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Popular badge
              if (command.isPopular)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Popular',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),

              // Arrow
              Icon(
                PhosphorIcons.caretRight(),
                size: 16,
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget para mostrar preview do comando selecionado
class BloquinhoSlashPreview extends StatelessWidget {
  final BloquinhoSlashCommand command;
  final bool isDarkMode;

  const BloquinhoSlashPreview({
    super.key,
    required this.command,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                command.icon,
                size: 16,
                color: command.categoryColorValue,
              ),
              const SizedBox(width: 8),
              Text(
                command.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            command.description,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color:
                    isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Text(
              command.markdownTemplate,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
