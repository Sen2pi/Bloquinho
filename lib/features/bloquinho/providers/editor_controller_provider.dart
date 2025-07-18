/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../models/bloco_base_model.dart';
import '../models/bloco_tipo_enum.dart';
import '../models/page_model.dart';
import '../services/clipboard_parser_service.dart';
import '../services/blocos_converter_service.dart';
import '../../../core/services/enhanced_pdf_export_service.dart';
import 'blocos_provider.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';

/// Estado do editor
class EditorControllerState {
  final bool isLoading;
  final bool isSaving;
  final bool hasChanges;
  final bool isReadOnly;
  final String? error;
  final String? documentId;
  final String? documentTitle;
  final DateTime? lastSaved;
  final DateTime? lastModified;
  final String? content;
  final TextSelection? selection;

  const EditorControllerState({
    this.isLoading = false,
    this.isSaving = false,
    this.hasChanges = false,
    this.isReadOnly = false,
    this.error,
    this.documentId,
    this.documentTitle,
    this.lastSaved,
    this.lastModified,
    this.content,
    this.selection,
  });

  EditorControllerState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? hasChanges,
    bool? isReadOnly,
    String? error,
    String? documentId,
    String? documentTitle,
    DateTime? lastSaved,
    DateTime? lastModified,
    String? content,
    TextSelection? selection,
    bool clearError = false,
  }) {
    return EditorControllerState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      hasChanges: hasChanges ?? this.hasChanges,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      error: clearError ? null : (error ?? this.error),
      documentId: documentId ?? this.documentId,
      documentTitle: documentTitle ?? this.documentTitle,
      lastSaved: lastSaved ?? this.lastSaved,
      lastModified: lastModified ?? this.lastModified,
      content: content ?? this.content,
      selection: selection ?? this.selection,
    );
  }

  bool get isInitialized => documentId != null;
  bool get canUndo => false; // TODO: Implementar
  bool get canRedo => false; // TODO: Implementar
  bool get isBusy => isLoading || isSaving;
  bool get canEdit => !isReadOnly && isInitialized;
}

/// Notifier para gerenciar o estado do editor
class EditorControllerNotifier extends StateNotifier<EditorControllerState> {
  static const _uuid = Uuid();
  final ClipboardParserService _clipboardService;
  final BlocosConverterService _converterService;
  final EnhancedPdfExportService _pdfExportService;
  final Ref _ref;

  EditorControllerNotifier(
    this._clipboardService,
    this._converterService,
    this._pdfExportService,
    this._ref,
  ) : super(const EditorControllerState());

  /// Inicializar editor
  Future<void> initialize({
    String? documentId,
    String? documentTitle,
    String? initialContent,
    bool isReadOnly = false,
    Map<String, dynamic>? settings,
    required AppStrings strings,
  }) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      state = state.copyWith(
        documentId: documentId ?? _uuid.v4(),
        documentTitle: documentTitle ?? strings.untitledDocument,
        isLoading: false,
        isReadOnly: isReadOnly,
        lastModified: DateTime.now(),
        content: initialContent ?? '',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '${strings.errorInitializingEditor}: ${e.toString()}',
      );
    }
  }

  /// Inserir bloco
  void insertBlock(BlocoBase bloco) {
    if (!state.canEdit) return;

    try {
      // TODO: Implementar inserção de bloco

      state = state.copyWith(
        hasChanges: true,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      final strings = _ref.read(appStringsProvider);
      state = state.copyWith(
        error: '${strings.errorInsertingBlock}: ${e.toString()}',
      );
    }
  }

  /// Formatar texto
  void formatText(String format) {
    if (!state.canEdit) return;

    try {
      // TODO: Implementar formatação de texto

      state = state.copyWith(
        hasChanges: true,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      final strings = _ref.read(appStringsProvider);
      state = state.copyWith(
        error: '${strings.errorFormattingText}: ${e.toString()}',
      );
    }
  }

  /// Inserir link
  void insertLink(String url, {String? text}) {
    if (!state.canEdit) return;

    try {
      // TODO: Implementar inserção de link

      state = state.copyWith(
        hasChanges: true,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      final strings = _ref.read(appStringsProvider);
      state = state.copyWith(
        error: '${strings.errorInsertingLink}: ${e.toString()}',
      );
    }
  }

  /// Inserir título
  void insertHeading(int level) {
    if (!state.canEdit) return;

    try {
      // TODO: Implementar inserção de título

      state = state.copyWith(
        hasChanges: true,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      final strings = _ref.read(appStringsProvider);
      state = state.copyWith(
        error: '${strings.errorInsertingTitle}: ${e.toString()}',
      );
    }
  }

  /// Inserir lista com marcadores
  void insertBulletList() {
    if (!state.canEdit) return;

    try {
      // TODO: Implementar inserção de lista

      state = state.copyWith(
        hasChanges: true,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      final strings = _ref.read(appStringsProvider);
      state = state.copyWith(
        error: '${strings.errorInsertingList}: ${e.toString()}',
      );
    }
  }

  /// Inserir lista numerada
  void insertNumberedList() {
    if (!state.canEdit) return;

    try {
      // TODO: Implementar inserção de lista numerada

      state = state.copyWith(
        hasChanges: true,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      final strings = _ref.read(appStringsProvider);
      state = state.copyWith(
        error: '${strings.errorInsertingNumberedList}: ${e.toString()}',
      );
    }
  }

  /// Inserir tarefa
  void insertTask() {
    if (!state.canEdit) return;

    try {
      // TODO: Implementar inserção de tarefa

      state = state.copyWith(
        hasChanges: true,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      final strings = _ref.read(appStringsProvider);
      state = state.copyWith(
        error: '${strings.errorInsertingTask}: ${e.toString()}',
      );
    }
  }

  /// Desfazer
  void undo() {
    if (!state.canUndo) return;

    try {
      // TODO: Implementar desfazer

      state = state.copyWith(
        hasChanges: true,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      final strings = _ref.read(appStringsProvider);
      state = state.copyWith(
        error: '${strings.errorUndoing}: ${e.toString()}',
      );
    }
  }

  /// Refazer
  void redo() {
    if (!state.canRedo) return;

    try {
      // TODO: Implementar refazer

      state = state.copyWith(
        hasChanges: true,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      final strings = _ref.read(appStringsProvider);
      state = state.copyWith(
        error: '${strings.errorRedoing}: ${e.toString()}',
      );
    }
  }

  /// Colar do clipboard
  Future<void> pasteFromClipboard() async {
    if (!state.canEdit) return;

    try {
      final parseResult = await _clipboardService.parseClipboard();

      if (parseResult.success && parseResult.blocos.isNotEmpty) {
        for (final bloco in parseResult.blocos) {
          insertBlock(bloco);
        }
      }
    } catch (e) {
      final strings = _ref.read(appStringsProvider);
      state = state.copyWith(
        error: '${strings.errorPastingFromClipboard}: ${e.toString()}',
      );
    }
  }

  /// Salvar documento
  Future<void> saveDocument() async {
    if (state.isSaving) return;

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      // TODO: Implementar salvamento
      await Future.delayed(const Duration(seconds: 1)); // Simular salvamento

      state = state.copyWith(
        isSaving: false,
        hasChanges: false,
        lastSaved: DateTime.now(),
      );
    } catch (e) {
      final strings = _ref.read(appStringsProvider);
      state = state.copyWith(
        isSaving: false,
        error: '${strings.errorSaving}: ${e.toString()}',
      );
    }
  }

  /// Exportar documento
  Future<Map<String, dynamic>> exportDocument({
    String format = 'markdown',
    PageModel? page,
    Widget? contentWidget,
  }) async {
    try {
      final strings = _ref.read(appStringsProvider);

      if (format == 'pdf') {
        if (page == null || contentWidget == null) {
          throw Exception(
              'Página e widget de conteúdo são necessários para exportação PDF');
        }

        final content = state.content ?? '';
        final timestamp =
            DateTime.now().toString().split('.')[0].replaceAll(':', '-');
        final title = state.documentTitle ?? 'Bloquinho_Document_$timestamp';

        final filePath = await _pdfExportService.exportMarkdownAsPdf(
          markdown: content,
          title: title,
          strings: strings,
        );

        final file = filePath != null ? File(filePath) : null;

        return {
          'format': format,
          'file': file,
          'filePath': filePath,
          'exportedAt': DateTime.now().toIso8601String(),
        };
      } else {
        // Exportação markdown (padrão)
        return {
          'format': format,
          'content': state.content ?? '',
          'exportedAt': DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      final strings = _ref.read(appStringsProvider);
      state = state.copyWith(
        error: '${strings.errorExportingDocument}: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Buscar texto
  List<Map<String, dynamic>> findText(String query) {
    // TODO: Implementar busca
    return [];
  }

  /// Obter estatísticas do documento
  Map<String, dynamic> getDocumentStats() {
    final content = state.content ?? '';
    final wordCount = content.trim().isEmpty
        ? 0
        : content.trim().split(RegExp(r'\s+')).length;
    final charCount = content.length;
    final lineCount = content.isEmpty ? 0 : content.split('\n').length;
    return {
      'wordCount': wordCount,
      'characterCount': charCount,
      'lineCount': lineCount,
    };
  }

  /// Alternar modo somente leitura
  void toggleReadOnlyMode() {
    state = state.copyWith(
      isReadOnly: !state.isReadOnly,
    );
  }

  /// Limpar erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Envolve o texto selecionado com uma tag customizada ([color=...], [bg=...], [badge color=...])
  void wrapSelectionWithTag(String tag, String color) {
    if (!state.canEdit) return;
    final content = state.content ?? '';
    final selection = state.selection;
    if (selection == null || selection.isCollapsed) return;
    final start = selection.start;
    final end = selection.end;
    final selectedText = content.substring(start, end);

    // Detectar se já existe tag [color=...] ou [bg=...] ou [badge color=...]
    final colorRegex =
        RegExp(r'\[color=([^\]]+)\](.*?)\[/color\]', dotAll: true);
    final bgRegex = RegExp(r'\[bg=([^\]]+)\](.*?)\[/bg\]', dotAll: true);
    final badgeRegex =
        RegExp(r'\[badge color=([^\]]+)\](.*?)\[/badge\]', dotAll: true);

    String newText = selectedText;
    if (tag == 'color' && colorRegex.hasMatch(selectedText)) {
      // Trocar apenas o valor da cor
      newText = selectedText.replaceAllMapped(
          colorRegex, (m) => '[color=$color]${m[2]}[/color]');
    } else if (tag == 'bg' && bgRegex.hasMatch(selectedText)) {
      newText = selectedText.replaceAllMapped(
          bgRegex, (m) => '[bg=$color]${m[2]}[/bg]');
    } else if (tag == 'badge' && badgeRegex.hasMatch(selectedText)) {
      newText = selectedText.replaceAllMapped(
          badgeRegex, (m) => '[badge color=$color]${m[2]}[/badge]');
    } else {
      // Se não existe, envolver com a tag
      if (tag == 'color') {
        newText = '[color=$color]$selectedText[/color]';
      } else if (tag == 'bg') {
        newText = '[bg=$color]$selectedText[/bg]';
      } else if (tag == 'badge') {
        newText = '[badge color=$color]$selectedText[/badge]';
      }
    }

    final newContent = content.replaceRange(start, end, newText);
    final newSelection =
        TextSelection.collapsed(offset: start + newText.length);
    state = state.copyWith(
        content: newContent, selection: newSelection, hasChanges: true);
  }
}

/// Provider dos serviços
final clipboardParserServiceProvider = Provider((ref) {
  return ClipboardParserService();
});

final blocosConverterServiceProvider = Provider((ref) {
  return BlocosConverterService();
});

final pdfExportServiceProvider = Provider((ref) {
  return EnhancedPdfExportService();
});

/// Provider principal do editor
final editorControllerProvider =
    StateNotifierProvider<EditorControllerNotifier, EditorControllerState>(
        (ref) {
  final clipboardService = ref.watch(clipboardParserServiceProvider);
  final converterService = ref.watch(blocosConverterServiceProvider);
  final pdfExportService = ref.watch(pdfExportServiceProvider);

  return EditorControllerNotifier(
      clipboardService, converterService, pdfExportService, ref);
});

/// Providers derivados

/// Estado do editor
final editorStateProvider = Provider<EditorControllerState>((ref) {
  return ref.watch(editorControllerProvider);
});

/// Verificar se editor está inicializado
final isEditorInitializedProvider = Provider<bool>((ref) {
  return ref.watch(editorControllerProvider).isInitialized;
});

/// Verificar se pode editar
final canEditProvider = Provider<bool>((ref) {
  return ref.watch(editorControllerProvider).canEdit;
});

/// Verificar se pode desfazer
final canUndoProvider = Provider<bool>((ref) {
  return ref.watch(editorControllerProvider).canUndo;
});

/// Verificar se pode refazer
final canRedoProvider = Provider<bool>((ref) {
  return ref.watch(editorControllerProvider).canRedo;
});

/// Verificar se tem alterações
final hasChangesProvider = Provider<bool>((ref) {
  return ref.watch(editorControllerProvider).hasChanges;
});

/// Verificar se está ocupado
final isEditorBusyProvider = Provider<bool>((ref) {
  return ref.watch(editorControllerProvider).isBusy;
});

/// Último erro do editor
final editorErrorProvider = Provider<String?>((ref) {
  return ref.watch(editorControllerProvider).error;
});
