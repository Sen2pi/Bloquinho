import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/bloco_base_model.dart';
import '../models/bloco_tipo_enum.dart';
import '../services/clipboard_parser_service.dart';
import '../services/blocos_converter_service.dart';
import 'blocos_provider.dart';

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
  final Ref _ref;

  EditorControllerNotifier(
    this._clipboardService,
    this._converterService,
    this._ref,
  ) : super(const EditorControllerState());

  /// Inicializar editor
  Future<void> initialize({
    String? documentId,
    String? documentTitle,
    String? initialContent,
    bool isReadOnly = false,
    Map<String, dynamic>? settings,
  }) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      state = state.copyWith(
        documentId: documentId ?? _uuid.v4(),
        documentTitle: documentTitle ?? 'Documento sem título',
        isLoading: false,
        isReadOnly: isReadOnly,
        lastModified: DateTime.now(),
        content: initialContent ?? '',
      );

      debugPrint('✅ Editor inicializado com sucesso');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao inicializar editor: $e',
      );
      debugPrint('❌ Erro ao inicializar editor: $e');
    }
  }

  /// Inserir bloco
  void insertBlock(BlocoBase bloco) {
    if (!state.canEdit) return;

    try {
      // TODO: Implementar inserção de bloco no editor
      debugPrint('Inserindo bloco: ${bloco.tipo}');

      state = state.copyWith(
        hasChanges: true,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao inserir bloco: $e',
      );
    }
  }

  /// Formatar texto
  void formatText(String format) {
    if (!state.canEdit) return;

    try {
      // TODO: Implementar formatação de texto
      debugPrint('Formatando texto: $format');

      state = state.copyWith(
        hasChanges: true,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao formatar texto: $e',
      );
    }
  }

  /// Inserir link
  void insertLink(String url, {String? text}) {
    if (!state.canEdit) return;

    try {
      // TODO: Implementar inserção de link
      debugPrint('Inserindo link: $url');

      state = state.copyWith(
        hasChanges: true,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao inserir link: $e',
      );
    }
  }

  /// Inserir título
  void insertHeading(int level) {
    if (!state.canEdit) return;

    try {
      // TODO: Implementar inserção de título
      debugPrint('Inserindo título nível $level');

      state = state.copyWith(
        hasChanges: true,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao inserir título: $e',
      );
    }
  }

  /// Inserir lista com marcadores
  void insertBulletList() {
    if (!state.canEdit) return;

    try {
      // TODO: Implementar inserção de lista
      debugPrint('Inserindo lista com marcadores');

      state = state.copyWith(
        hasChanges: true,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao inserir lista: $e',
      );
    }
  }

  /// Inserir lista numerada
  void insertNumberedList() {
    if (!state.canEdit) return;

    try {
      // TODO: Implementar inserção de lista numerada
      debugPrint('Inserindo lista numerada');

      state = state.copyWith(
        hasChanges: true,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao inserir lista numerada: $e',
      );
    }
  }

  /// Inserir tarefa
  void insertTask() {
    if (!state.canEdit) return;

    try {
      // TODO: Implementar inserção de tarefa
      debugPrint('Inserindo tarefa');

      state = state.copyWith(
        hasChanges: true,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao inserir tarefa: $e',
      );
    }
  }

  /// Desfazer
  void undo() {
    if (!state.canUndo) return;

    try {
      // TODO: Implementar desfazer
      debugPrint('Desfazendo ação');

      state = state.copyWith(
        hasChanges: true,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao desfazer: $e',
      );
    }
  }

  /// Refazer
  void redo() {
    if (!state.canRedo) return;

    try {
      // TODO: Implementar refazer
      debugPrint('Refazendo ação');

      state = state.copyWith(
        hasChanges: true,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao refazer: $e',
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
      state = state.copyWith(
        error: 'Erro ao colar do clipboard: $e',
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
      state = state.copyWith(
        isSaving: false,
        error: 'Erro ao salvar: $e',
      );
    }
  }

  /// Exportar documento
  Future<Map<String, dynamic>> exportDocument(
      {String format = 'markdown'}) async {
    try {
      // TODO: Implementar exportação
      await Future.delayed(const Duration(seconds: 1)); // Simular exportação

      return {
        'format': format,
        'content': 'Conteúdo exportado',
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao exportar: $e',
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
    return {
      'wordCount': 0,
      'characterCount': 0,
      'lineCount': 0,
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
}

/// Provider dos serviços
final clipboardParserServiceProvider = Provider((ref) {
  return ClipboardParserService();
});

final blocosConverterServiceProvider = Provider((ref) {
  return BlocosConverterService();
});

/// Provider principal do editor
final editorControllerProvider =
    StateNotifierProvider<EditorControllerNotifier, EditorControllerState>(
        (ref) {
  final clipboardService = ref.watch(clipboardParserServiceProvider);
  final converterService = ref.watch(blocosConverterServiceProvider);

  return EditorControllerNotifier(clipboardService, converterService, ref);
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
