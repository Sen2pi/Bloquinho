
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
import '../../../core/theme/app_colors.dart';
import '../models/page_model.dart';
import '../providers/pages_provider.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../shared/providers/workspace_provider.dart';

/// Widget para renderizar links de página com badge (ícone + nome)
class PageLinkBadge extends ConsumerWidget {
  final String pageTitle;
  final String? pageId;
  final VoidCallback? onTap;
  final bool isBroken;

  const PageLinkBadge({
    super.key,
    required this.pageTitle,
    this.pageId,
    this.onTap,
    this.isBroken = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Buscar informações da página se temos o ID
    PageModel? page;
    if (pageId != null) {
      final currentProfile = ref.watch(currentProfileProvider);
      final currentWorkspace = ref.watch(currentWorkspaceProvider);
      
      if (currentProfile != null && currentWorkspace != null) {
        final pages = ref.watch(pagesProvider((
          profileName: currentProfile.name,
          workspaceName: currentWorkspace.name
        )));
        
        try {
          page = pages.firstWhere((p) => p.id == pageId);
        } catch (e) {
          // Página não encontrada - manter como broken
        }
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isBroken 
              ? Colors.red.withOpacity(0.1)
              : (isDarkMode 
                  ? AppColors.darkSurface 
                  : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isBroken 
                ? Colors.red.withOpacity(0.3)
                : (isDarkMode 
                    ? AppColors.darkBorder 
                    : AppColors.lightBorder),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone da página
            Text(
              page?.icon ?? '📄',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            // Nome da página
            Flexible(
              child: Text(
                page?.title ?? pageTitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isBroken 
                      ? Colors.red
                      : (isDarkMode 
                          ? AppColors.darkTextPrimary 
                          : AppColors.lightTextPrimary),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Indicador de link quebrado
            if (isBroken) ...[
              const SizedBox(width: 4),
              Icon(
                PhosphorIcons.warning(),
                size: 12,
                color: Colors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
