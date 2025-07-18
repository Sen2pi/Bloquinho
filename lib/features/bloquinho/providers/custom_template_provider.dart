/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/custom_pdf_template.dart';
import '../services/template_storage_service.dart';

/// Provider para gerenciar templates customizados
class CustomTemplateNotifier extends StateNotifier<List<CustomPdfTemplate>> {
  final TemplateStorageService _storageService = TemplateStorageService.instance;
  
  CustomTemplateNotifier() : super([]) {
    _loadTemplates();
  }

  /// Carrega templates do armazenamento
  Future<void> _loadTemplates() async {
    try {
      final templates = await _storageService.loadTemplates();
      state = templates;
    } catch (e) {
      print('Erro ao carregar templates: $e');
    }
  }

  /// Adiciona um novo template customizado
  Future<void> addTemplate(CustomPdfTemplate template) async {
    try {
      await _storageService.saveTemplate(template);
      state = [...state, template];
    } catch (e) {
      print('Erro ao salvar template: $e');
      rethrow;
    }
  }

  /// Remove um template customizado
  Future<void> removeTemplate(String id) async {
    try {
      await _storageService.deleteTemplate(id);
      state = state.where((template) => template.id != id).toList();
    } catch (e) {
      print('Erro ao remover template: $e');
      rethrow;
    }
  }

  /// Atualiza um template customizado
  Future<void> updateTemplate(CustomPdfTemplate updatedTemplate) async {
    try {
      await _storageService.saveTemplate(updatedTemplate);
      state = state.map((template) {
        return template.id == updatedTemplate.id ? updatedTemplate : template;
      }).toList();
    } catch (e) {
      print('Erro ao atualizar template: $e');
      rethrow;
    }
  }

  /// Obtém um template por ID
  CustomPdfTemplate? getTemplate(String id) {
    try {
      return state.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Provider para templates customizados
final customTemplatesProvider = StateNotifierProvider<CustomTemplateNotifier, List<CustomPdfTemplate>>((ref) {
  return CustomTemplateNotifier();
});

/// Provider para o template customizado selecionado
final selectedCustomTemplateProvider = StateProvider<String?>((ref) => null);