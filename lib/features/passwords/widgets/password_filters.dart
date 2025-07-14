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

import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';

class PasswordFilters extends StatelessWidget {
  final Function(String?) onCategoryChanged;
  final Function(String?) onFolderChanged;
  final VoidCallback onToggleFavorites;
  final VoidCallback onToggleWeak;
  final VoidCallback onToggleExpired;
  final VoidCallback onClearFilters;

  const PasswordFilters({
    super.key,
    required this.onCategoryChanged,
    required this.onFolderChanged,
    required this.onToggleFavorites,
    required this.onToggleWeak,
    required this.onToggleExpired,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Filtro por categoria
            _buildFilterChip(
              context,
              label: 'Categoria',
              icon: Icons.category,
              onTap: () => _showCategoryFilter(context),
            ),

            const SizedBox(width: 8),

            // Filtro por pasta
            _buildFilterChip(
              context,
              label: 'Pasta',
              icon: Icons.folder,
              onTap: () => _showFolderFilter(context),
            ),

            const SizedBox(width: 8),

            // Filtro de favoritos
            _buildFilterChip(
              context,
              label: 'Favoritos',
              icon: Icons.star,
              onTap: onToggleFavorites,
            ),

            const SizedBox(width: 8),

            // Filtro de senhas fracas
            _buildFilterChip(
              context,
              label: 'Senhas Fracas',
              icon: Icons.warning,
              onTap: onToggleWeak,
              color: Colors.orange,
            ),

            const SizedBox(width: 8),

            // Filtro de senhas expiradas
            _buildFilterChip(
              context,
              label: 'Expiradas',
              icon: Icons.access_time,
              onTap: onToggleExpired,
              color: Colors.red,
            ),

            const SizedBox(width: 8),

            // Limpar filtros
            _buildFilterChip(
              context,
              label: 'Limpar',
              icon: Icons.clear,
              onTap: onClearFilters,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (color ?? AppColors.primary).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color ?? AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color ?? AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter(BuildContext context) {
    final categories = [
      'Social',
      'Finance',
      'Work',
      'Email',
      'Shopping',
      'Entertainment',
      'Health',
      'Education',
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selecionar Categoria',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length + 1, // +1 para "Todas"
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      leading: Icon(Icons.list),
                      title: const Text('Todas as categorias'),
                      onTap: () {
                        onCategoryChanged(null);
                        Navigator.of(context).pop();
                      },
                    );
                  }

                  final category = categories[index - 1];
                  return ListTile(
                    leading: Icon(_getCategoryIcon(category)),
                    title: Text(category),
                    onTap: () {
                      onCategoryChanged(category);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFolderFilter(BuildContext context) {
    // Implementar filtro por pasta quando tivermos pastas
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Filtro por pasta será implementado em breve')),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'social':
        return Icons.social_distance;
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
        return Icons.lock;
    }
  }
}
