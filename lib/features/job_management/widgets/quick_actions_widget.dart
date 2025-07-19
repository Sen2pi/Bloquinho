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

import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_strings.dart';

class QuickActionsWidget extends StatelessWidget {
  final bool isDarkMode;
  final AppStrings strings;
  final VoidCallback? onNewInterview;
  final VoidCallback? onNewCV;
  final VoidCallback? onNewApplication;
  final VoidCallback? onImportData;

  const QuickActionsWidget({
    super.key,
    required this.isDarkMode,
    required this.strings,
    this.onNewInterview,
    this.onNewCV,
    this.onNewApplication,
    this.onImportData,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: [
        _buildActionCard(
          icon: PhosphorIcons.chatCentered(),
          title: strings.jobNewInterview,
          subtitle: 'Criar nova entrevista',
          color: Colors.blue,
          onTap: onNewInterview,
        ),
        _buildActionCard(
          icon: PhosphorIcons.fileText(),
          title: strings.jobNewCV,
          subtitle: 'Criar novo currículo',
          color: Colors.green,
          onTap: onNewCV,
        ),
        _buildActionCard(
          icon: PhosphorIcons.paperPlaneTilt(),
          title: strings.jobNewApplication,
          subtitle: 'Nova candidatura',
          color: Colors.orange,
          onTap: onNewApplication,
        ),
        _buildActionCard(
          icon: PhosphorIcons.downloadSimple(),
          title: 'Importar Dados',
          subtitle: 'Importar informações',
          color: Colors.purple,
          onTap: onImportData,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required PhosphorIconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}