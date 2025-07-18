/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pdf_template.dart';
import '../models/custom_pdf_template.dart';
import 'custom_template_provider.dart';

/// Provider para o template de PDF selecionado
final pdfTemplateProvider = StateProvider<PdfTemplateType>((ref) {
  return PdfTemplateType.bloquinho; // Template padrão
});

/// Provider para obter o template atual
final currentPdfTemplateProvider = Provider<PdfTemplate>((ref) {
  final templateType = ref.watch(pdfTemplateProvider);

  // Se for template customizado, retornar template padrão
  if (templateType == PdfTemplateType.custom) {
    return PdfTemplates.getTemplate(PdfTemplateType.bloquinho);
  }

  return PdfTemplates.getTemplate(templateType);
});

/// Provider para obter o template customizado atual
final currentCustomTemplateProvider = Provider<CustomPdfTemplate?>((ref) {
  final selectedId = ref.watch(selectedCustomTemplateProvider);
  if (selectedId == null) return null;

  final customTemplates = ref.watch(customTemplatesProvider);
  try {
    return customTemplates.firstWhere(
      (template) => template.id == selectedId,
    );
  } catch (e) {
    return null;
  }
});
