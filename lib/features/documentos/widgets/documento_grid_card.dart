/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';

class DocumentoGridCard extends StatelessWidget {
  final String? imagemPath;
  final String titulo;
  final String? subtitulo;
  final String? informacaoSecundaria;
  final Color corPrimaria;
  final IconData iconePadrao;
  final bool isVencido;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final List<Widget>? actionButtons;

  const DocumentoGridCard({
    super.key,
    this.imagemPath,
    required this.titulo,
    this.subtitulo,
    this.informacaoSecundaria,
    required this.corPrimaria,
    required this.iconePadrao,
    this.isVencido = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.actionButtons,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                corPrimaria,
                corPrimaria.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Área da imagem de capa
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: Colors.black.withOpacity(0.1),
                  ),
                  child: _buildImageArea(),
                ),
              ),
              
              // Área de informações
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Subtítulo
                      if (subtitulo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitulo!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      // Informação secundária
                      if (informacaoSecundaria != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          informacaoSecundaria!,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      const Spacer(),
                      
                      // Indicador de vencido e botões de ação
                      Row(
                        children: [
                          if (isVencido)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'VENCIDO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          
                          const Spacer(),
                          
                          // Botões de ação
                          if (actionButtons != null)
                            ...actionButtons!
                          else ...[
                            if (onEdit != null)
                              _buildActionButton(
                                PhosphorIcons.pencil(),
                                onEdit!,
                                'Editar',
                              ),
                            if (onDelete != null)
                              _buildActionButton(
                                PhosphorIcons.trash(),
                                onDelete!,
                                'Excluir',
                              ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageArea() {
    if (imagemPath != null && imagemPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: Image.file(
          File(imagemPath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultIcon();
          },
        ),
      );
    }
    
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        color: Colors.white.withOpacity(0.1),
      ),
      child: Center(
        child: Icon(
          iconePadrao,
          size: 48,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed, String tooltip) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 12,
          color: Colors.white,
        ),
      ),
    );
  }
}