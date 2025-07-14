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

class PasswordSecurityWidget extends StatelessWidget {
  final PasswordEntry password;
  final VoidCallback? onViewHistory;
  final VoidCallback? onSetup2FA;
  final VoidCallback? onMoveToVault;
  final VoidCallback? onSetupEmergency;

  const PasswordSecurityWidget({
    super.key,
    required this.password,
    this.onViewHistory,
    this.onSetup2FA,
    this.onMoveToVault,
    this.onSetupEmergency,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  PhosphorIcons.shieldCheck(),
                  color: password.securityColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Segurança',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                _buildSecurityBadge(context),
              ],
            ),
            const SizedBox(height: 16),

            // Indicadores de segurança
            _buildSecurityIndicators(context),

            const SizedBox(height: 16),

            // Ações de segurança
            _buildSecurityActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityBadge(BuildContext context) {
    String text;
    Color color;
    IconData icon;

    switch (password.securityLevel) {
      case SecurityLevel.critical:
        text = 'Crítico';
        color = Colors.red;
        icon = PhosphorIcons.warning();
        break;
      case SecurityLevel.warning:
        text = 'Atenção';
        color = Colors.orange;
        icon = PhosphorIcons.warning();
        break;
      case SecurityLevel.good:
        text = 'Bom';
        color = Colors.green;
        icon = PhosphorIcons.checkCircle();
        break;
      case SecurityLevel.excellent:
        text = 'Excelente';
        color = Colors.blue;
        icon = PhosphorIcons.shieldCheck();
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityIndicators(BuildContext context) {
    final indicators = <Widget>[];

    // Força da senha
    indicators.add(_buildIndicator(
      context,
      icon: PhosphorIcons.lock(),
      label: 'Força',
      value: password.strengthText,
      color: password.strengthColor,
    ));

    // Idade da senha
    if (password.passwordAge > 0) {
      indicators.add(_buildIndicator(
        context,
        icon: PhosphorIcons.clock(),
        label: 'Idade',
        value: '${password.passwordAge} dias',
        color: password.isOldPassword ? Colors.orange : Colors.green,
      ));
    }

    // 2FA
    indicators.add(_buildIndicator(
      context,
      icon: PhosphorIcons.deviceMobile(),
      label: '2FA',
      value: password.hasTwoFactor ? 'Ativo' : 'Inativo',
      color: password.hasTwoFactor ? Colors.green : Colors.grey,
    ));

    // Vault
    indicators.add(_buildIndicator(
      context,
      icon: PhosphorIcons.vault(),
      label: 'Vault',
      value: password.isInSecureVault ? 'Seguro' : 'Padrão',
      color: password.isInSecureVault ? Colors.blue : Colors.grey,
    ));

    // Status de comprometimento
    if (password.isCompromised) {
      indicators.add(_buildIndicator(
        context,
        icon: PhosphorIcons.warning(),
        label: 'Status',
        value: 'Comprometida',
        color: Colors.red,
      ));
    }

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: indicators,
    );
  }

  Widget _buildIndicator(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityActions(BuildContext context) {
    final actions = <Widget>[];

    // Histórico de senhas
    if (password.passwordHistory.isNotEmpty) {
      actions.add(_buildActionButton(
        context,
        icon: PhosphorIcons.clockCounterClockwise(),
        label: 'Histórico',
        onTap: onViewHistory,
        color: AppColors.primary,
      ));
    }

    // Configurar 2FA
    if (!password.hasTwoFactor) {
      actions.add(_buildActionButton(
        context,
        icon: PhosphorIcons.deviceMobile(),
        label: 'Configurar 2FA',
        onTap: onSetup2FA,
        color: Colors.green,
      ));
    }

    // Mover para vault
    if (!password.isInSecureVault) {
      actions.add(_buildActionButton(
        context,
        icon: PhosphorIcons.vault(),
        label: 'Mover para Vault',
        onTap: onMoveToVault,
        color: Colors.blue,
      ));
    }

    // Acesso de emergência
    if (!password.hasEmergencyAccess) {
      actions.add(_buildActionButton(
        context,
        icon: PhosphorIcons.userPlus(),
        label: 'Acesso Emergência',
        onTap: onSetupEmergency,
        color: Colors.orange,
      ));
    }

    if (actions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              PhosphorIcons.checkCircle(),
              color: Colors.green,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Todas as configurações de segurança estão ativas',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                  ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions,
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
