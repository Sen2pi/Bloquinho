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
import '../models/password_entry.dart';

class PasswordCard extends StatelessWidget {
  final PasswordEntry password;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onCopyPassword;
  final VoidCallback? onCopyUsername;

  const PasswordCard({
    super.key,
    required this.password,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleFavorite,
    this.onCopyPassword,
    this.onCopyUsername,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Ícone da categoria
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: password.strengthColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      password.categoryIcon,
                      color: password.strengthColor,
                      size: 20,
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
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (password.website != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            password.domain,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Ações rápidas
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onToggleFavorite != null)
                        IconButton(
                          onPressed: onToggleFavorite,
                          icon: Icon(
                            password.isFavorite
                                ? Icons.star
                                : Icons.star_border,
                            color: password.isFavorite
                                ? Colors.amber
                                : Colors.grey[400],
                            size: 20,
                          ),
                          tooltip: password.isFavorite
                              ? 'Remover dos favoritos'
                              : 'Adicionar aos favoritos',
                        ),
                      PopupMenuButton<String>(
                        onSelected: (value) =>
                            _handleMenuAction(value, context),
                        itemBuilder: (context) => [
                          if (onCopyUsername != null)
                            const PopupMenuItem(
                              value: 'copy_username',
                              child: ListTile(
                                leading: Icon(Icons.person),
                                title: Text('Copiar utilizador'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          if (onCopyPassword != null)
                            const PopupMenuItem(
                              value: 'copy_password',
                              child: ListTile(
                                leading: Icon(Icons.lock),
                                title: Text('Copiar senha'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          if (onEdit != null)
                            const PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Editar'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          const PopupMenuDivider(),
                          if (onDelete != null)
                            const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text('Excluir',
                                    style: TextStyle(color: Colors.red)),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                        ],
                        child: Icon(
                          PhosphorIcons.dotsThreeVertical(),
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Informações adicionais
              Row(
                children: [
                  // Força da senha
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: password.strengthColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: password.strengthColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: password.strengthColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          password.strengthText,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: password.strengthColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Categoria
                  if (password.category != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        password.category!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Indicadores especiais
                  if (password.isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIcons.warning(),
                            color: Colors.red,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Expirada',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),

                  if (password.isExpiringSoon && !password.isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIcons.clock(),
                            color: Colors.orange,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Expira em breve',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // Tags
              if (password.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: password.tags
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Colors.blue[700],
                                    fontSize: 10,
                                  ),
                            ),
                          ))
                      .toList(),
                ),
              ],

              // Data de atualização
              const SizedBox(height: 8),
              Text(
                'Atualizado em ${_formatDate(password.updatedAt)}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'copy_username':
        onCopyUsername?.call();
        break;
      case 'copy_password':
        onCopyPassword?.call();
        break;
      case 'edit':
        onEdit?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
}
