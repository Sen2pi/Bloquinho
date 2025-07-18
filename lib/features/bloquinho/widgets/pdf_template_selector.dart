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
import '../models/pdf_template.dart';
import '../providers/pdf_template_provider.dart';
import '../models/custom_pdf_template.dart';
import '../providers/custom_template_provider.dart';
import 'custom_template_form.dart';

/// Widget seletor de templates de PDF
class PdfTemplateSelector extends ConsumerWidget {
  const PdfTemplateSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTemplate = ref.watch(currentPdfTemplateProvider);
    final customTemplates = ref.watch(customTemplatesProvider);
    final selectedCustomTemplate = ref.watch(selectedCustomTemplateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopupMenuButton<String>(
      tooltip: 'Selecionar template PDF',
      icon: Icon(
        currentTemplate.icon,
        size: 20,
        color: isDark ? Colors.white70 : Colors.grey[600],
      ),
      onSelected: (String value) {
        if (value == 'create_new') {
          _showCreateTemplateDialog(context, ref);
        } else if (value.startsWith('custom_')) {
          final customId = value.replaceFirst('custom_', '');
          ref.read(selectedCustomTemplateProvider.notifier).state = customId;
          ref.read(pdfTemplateProvider.notifier).state = PdfTemplateType.custom;
        } else {
          final templateType = PdfTemplateType.values.firstWhere(
            (t) => t.name == value,
            orElse: () => PdfTemplateType.bloquinho,
          );
          ref.read(pdfTemplateProvider.notifier).state = templateType;
          ref.read(selectedCustomTemplateProvider.notifier).state = null;
        }
      },
      itemBuilder: (BuildContext context) {
        final items = <PopupMenuEntry<String>>[];

        // Templates predefinidos
        for (final template in PdfTemplates.templates) {
          final isSelected = template.type == currentTemplate.type &&
              selectedCustomTemplate == null;
          items.add(
            PopupMenuItem<String>(
              value: template.type.name,
              child: _buildTemplateItem(template, isSelected, isDark),
            ),
          );
        }

        // Separador se existirem templates customizados
        if (customTemplates.isNotEmpty) {
          items.add(const PopupMenuDivider());

          // Templates customizados
          for (final customTemplate in customTemplates) {
            final isSelected = currentTemplate.type == PdfTemplateType.custom &&
                selectedCustomTemplate == customTemplate.id;
            items.add(
              PopupMenuItem<String>(
                value: 'custom_${customTemplate.id}',
                child: _buildCustomTemplateItem(
                    customTemplate, isSelected, isDark, ref, context),
              ),
            );
          }
        }

        // Separador antes do botão "Criar Template"
        items.add(const PopupMenuDivider());

        // Opção para criar novo template
        items.add(
          PopupMenuItem<String>(
            value: 'create_new',
            child: _buildCreateTemplateItem(isDark),
          ),
        );

        return items;
      },
    );
  }

  Widget _buildTemplateItem(
      PdfTemplate template, bool isSelected, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? Colors.grey[700] : Colors.grey[200])
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Preview icon com cor do template
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: template.previewColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: template.previewColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              template.icon,
              color: template.previewColor,
              size: 16,
            ),
          ),

          const SizedBox(width: 12),

          // Informações do template
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  template.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  template.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Indicador de seleção
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: template.previewColor,
              size: 18,
            ),
        ],
      ),
    );
  }

  Widget _buildCustomTemplateItem(CustomPdfTemplate template, bool isSelected,
      bool isDark, WidgetRef ref, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? Colors.grey[700] : Colors.grey[200])
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Preview icon com cor do template
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: template.previewColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: template.previewColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              template.icon,
              color: template.previewColor,
              size: 16,
            ),
          ),

          const SizedBox(width: 12),

          // Informações do template
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  template.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  template.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Botão de exclusão
          IconButton(
            onPressed: () => _showDeleteConfirmation(context, ref, template),
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red[400],
              size: 18,
            ),
            tooltip: 'Excluir template',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),

          // Indicador de seleção
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: template.previewColor,
              size: 18,
            ),
        ],
      ),
    );
  }

  Widget _buildCreateTemplateItem(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          // Ícone de adicionar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (isDark ? Colors.blue[400] : Colors.blue[500])!
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: (isDark ? Colors.blue[400] : Colors.blue[500])!
                    .withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.add,
              color: isDark ? Colors.blue[400] : Colors.blue[500],
              size: 16,
            ),
          ),

          const SizedBox(width: 12),

          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Criar Template',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.blue[400] : Colors.blue[600],
                  ),
                ),
                Text(
                  'Personalizar novo template',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, CustomPdfTemplate template) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
              'Tem certeza que deseja excluir o template "${template.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await ref
                      .read(customTemplatesProvider.notifier)
                      .removeTemplate(template.id);

                  // Se o template excluído estava selecionado, voltar para o template padrão
                  final selectedId = ref.read(selectedCustomTemplateProvider);
                  if (selectedId == template.id) {
                    ref.read(selectedCustomTemplateProvider.notifier).state =
                        null;
                    ref.read(pdfTemplateProvider.notifier).state =
                        PdfTemplateType.bloquinho;
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir template: $e')),
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateTemplateDialog(BuildContext context, WidgetRef ref) {
    showDialog<CustomPdfTemplate>(
      context: context,
      builder: (BuildContext context) {
        return const CustomTemplateForm();
      },
    ).then((customTemplate) async {
      if (customTemplate != null) {
        await ref
            .read(customTemplatesProvider.notifier)
            .addTemplate(customTemplate);
        ref.read(selectedCustomTemplateProvider.notifier).state =
            customTemplate.id;
        ref.read(pdfTemplateProvider.notifier).state = PdfTemplateType.custom;
      }
    });
  }
}

/// Widget para mostrar preview do template selecionado
class PdfTemplatePreview extends ConsumerWidget {
  const PdfTemplatePreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTemplateType = ref.watch(pdfTemplateProvider);
    final selectedCustomTemplate = ref.watch(selectedCustomTemplateProvider);
    final customTemplates = ref.watch(customTemplatesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determinar qual template mostrar
    String templateName;
    IconData templateIcon;
    Color templateColor;

    if (currentTemplateType == PdfTemplateType.custom &&
        selectedCustomTemplate != null) {
      // Template customizado selecionado
      final customTemplate = customTemplates
          .where((t) => t.id == selectedCustomTemplate)
          .firstOrNull;
      if (customTemplate != null) {
        templateName = customTemplate.name;
        templateIcon = customTemplate.icon;
        templateColor = customTemplate.previewColor;
      } else {
        // Fallback para template padrão
        final template = PdfTemplates.getTemplate(PdfTemplateType.bloquinho);
        templateName = template.name;
        templateIcon = template.icon;
        templateColor = template.previewColor;
      }
    } else {
      // Template predefinido
      final template = PdfTemplates.getTemplate(currentTemplateType);
      templateName = template.name;
      templateIcon = template.icon;
      templateColor = template.previewColor;
    }

    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: templateColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: templateColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            templateIcon,
            color: templateColor,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            templateName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : templateColor,
            ),
          ),
        ],
      ),
    );
  }
}
