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
import 'package:bloquinho/shared/providers/theme_provider.dart';
import 'package:bloquinho/core/theme/app_colors.dart';

/// Estilo de loader para carregamento contínuo (ex: ficheiro, linha)
/// Baseado em `@docs/continuos.txt`
class ContinuousProgressIndicator extends ConsumerWidget {
  const ContinuousProgressIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return LinearProgressIndicator(
      backgroundColor: theme.colorScheme.surfaceVariant,
      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
      minHeight: 2,
    );
  }
}

/// Estilo de loader para carregamento geral (spinner)
/// Baseado em `@docs/spinner.txt`
class AppSpinner extends ConsumerWidget {
  final double size;
  const AppSpinner({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
      ),
    );
  }
}

/// Estilo de loader para criação (barra de progresso)
/// Baseado em `@docs/progress.txt`
class AppProgressBar extends ConsumerWidget {
  final double value; // 0.0 to 1.0
  const AppProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return LinearProgressIndicator(
      value: value,
      backgroundColor: theme.colorScheme.surfaceVariant,
      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
      minHeight: 6,
      borderRadius: BorderRadius.circular(3),
    );
  }
}

/// Estilo de loader para criação (fábrica)
/// Baseado em `@docs/faactory.txt`
class FactoryProgressIndicator extends ConsumerStatefulWidget {
  final double size;
  const FactoryProgressIndicator({super.key, this.size = 48.0});

  @override
  ConsumerState<FactoryProgressIndicator> createState() => _FactoryProgressIndicatorState();
}

class _FactoryProgressIndicatorState extends ConsumerState<FactoryProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RotationTransition(
      turns: _controller,
      child: Icon(
        Icons.settings,
        size: widget.size,
        color: theme.colorScheme.primary,
      ),
    );
  }
}