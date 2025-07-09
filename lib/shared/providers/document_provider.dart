import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/document_models.dart';
import '../../core/services/document_service.dart';

// Instância do serviço de documentos
final documentServiceProvider = Provider<DocumentService>((ref) {
  return DocumentService();
});

// Estado dos documentos
class DocumentState {
  final List<Document> documents;
  final bool isLoading;
  final String? error;
  final Document? currentDocument;

  const DocumentState({
    this.documents = const [],
    this.isLoading = false,
    this.error,
    this.currentDocument,
  });

  DocumentState copyWith({
    List<Document>? documents,
    bool? isLoading,
    String? error,
    Document? currentDocument,
    bool clearError = false,
    bool clearCurrentDocument = false,
  }) {
    return DocumentState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentDocument: clearCurrentDocument
          ? null
          : (currentDocument ?? this.currentDocument),
    );
  }
}

// Notifier para gerenciar documentos
class DocumentNotifier extends StateNotifier<DocumentState> {
  final DocumentService _documentService;

  DocumentNotifier(this._documentService) : super(const DocumentState()) {
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final documents = await _documentService.getAllDocuments();
      state = state.copyWith(
        documents: documents,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar documentos: $e',
      );
    }
  }

  Future<Document?> createDocument({
    String title = 'Sem título',
    String icon = '📄',
    String? parentId,
    List<String> tags = const [],
  }) async {
    try {
      // Criar documento com bloco inicial
      final document = Document.create(
        title: title,
        icon: icon,
        parentId: parentId,
        tags: tags,
      ).copyWith(
        blocks: [
          DocumentBlock.create(
            type: BlockType.text,
            content: '',
          ),
        ],
      );

      final createdDocument = await _documentService.createDocument(document);

      // Atualizar lista de documentos
      state = state.copyWith(
        documents: [createdDocument, ...state.documents],
        currentDocument: createdDocument,
      );

      return createdDocument;
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao criar documento: $e',
      );
      return null;
    }
  }

  Future<Document?> getDocument(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final document = await _documentService.getDocument(id);
      state = state.copyWith(
        currentDocument: document,
        isLoading: false,
      );
      return document;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar documento: $e',
      );
      return null;
    }
  }

  Future<void> updateDocument(Document document) async {
    try {
      final updatedDocument = await _documentService.updateDocument(document);

      // Atualizar na lista
      final updatedDocuments = state.documents.map((doc) {
        return doc.id == updatedDocument.id ? updatedDocument : doc;
      }).toList();

      state = state.copyWith(
        documents: updatedDocuments,
        currentDocument: state.currentDocument?.id == updatedDocument.id
            ? updatedDocument
            : state.currentDocument,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao atualizar documento: $e',
      );
    }
  }

  Future<void> deleteDocument(String id) async {
    try {
      await _documentService.deleteDocument(id);

      // Remover da lista
      final updatedDocuments =
          state.documents.where((doc) => doc.id != id).toList();

      state = state.copyWith(
        documents: updatedDocuments,
        currentDocument:
            state.currentDocument?.id == id ? null : state.currentDocument,
        clearCurrentDocument: state.currentDocument?.id == id,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao deletar documento: $e',
      );
    }
  }

  Future<void> searchDocuments(String query) async {
    if (query.isEmpty) {
      await loadDocuments();
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final documents = await _documentService.searchDocuments(query);
      state = state.copyWith(
        documents: documents,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao pesquisar documentos: $e',
      );
    }
  }

  Future<void> toggleFavorite(String id) async {
    final doc = state.documents.firstWhere((d) => d.id == id);
    final updatedDoc = doc.copyWith(isFavorite: !doc.isFavorite);
    await updateDocument(updatedDoc);
  }

  Future<void> archiveDocument(String id) async {
    final doc = state.documents.firstWhere((d) => d.id == id);
    final updatedDoc = doc.copyWith(isArchived: true);
    await updateDocument(updatedDoc);
  }

  void setCurrentDocument(Document? document) {
    state = state.copyWith(
      currentDocument: document,
      clearCurrentDocument: document == null,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Provider principal dos documentos
final documentProvider =
    StateNotifierProvider<DocumentNotifier, DocumentState>((ref) {
  final documentService = ref.watch(documentServiceProvider);
  return DocumentNotifier(documentService);
});

// Providers derivados
final documentsListProvider = Provider<List<Document>>((ref) {
  return ref.watch(documentProvider).documents;
});

final currentDocumentProvider = Provider<Document?>((ref) {
  return ref.watch(documentProvider).currentDocument;
});

final isLoadingDocumentsProvider = Provider<bool>((ref) {
  return ref.watch(documentProvider).isLoading;
});

final documentsErrorProvider = Provider<String?>((ref) {
  return ref.watch(documentProvider).error;
});

final favoriteDocumentsProvider = Provider<List<Document>>((ref) {
  final documents = ref.watch(documentsListProvider);
  return documents.where((doc) => doc.isFavorite && !doc.isArchived).toList();
});

final recentDocumentsProvider = Provider<List<Document>>((ref) {
  final documents = ref.watch(documentsListProvider);
  final sortedDocuments = List<Document>.from(documents)
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return sortedDocuments.take(5).toList();
});

// Estado dos workspaces
class WorkspaceState {
  final List<Workspace> workspaces;
  final Workspace? currentWorkspace;
  final bool isLoading;
  final String? error;

  const WorkspaceState({
    this.workspaces = const [],
    this.currentWorkspace,
    this.isLoading = false,
    this.error,
  });

  WorkspaceState copyWith({
    List<Workspace>? workspaces,
    Workspace? currentWorkspace,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearCurrentWorkspace = false,
  }) {
    return WorkspaceState(
      workspaces: workspaces ?? this.workspaces,
      currentWorkspace: clearCurrentWorkspace
          ? null
          : (currentWorkspace ?? this.currentWorkspace),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Notifier para gerenciar workspaces
class WorkspaceNotifier extends StateNotifier<WorkspaceState> {
  final DocumentService _documentService;

  WorkspaceNotifier(this._documentService) : super(const WorkspaceState()) {
    loadWorkspaces();
  }

  Future<void> loadWorkspaces() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final workspaces = await _documentService.getAllWorkspaces();
      state = state.copyWith(
        workspaces: workspaces,
        currentWorkspace: workspaces.isNotEmpty ? workspaces.first : null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar workspaces: $e',
      );
    }
  }

  Future<void> createWorkspace(Workspace workspace) async {
    try {
      final createdWorkspace =
          await _documentService.createWorkspace(workspace);
      state = state.copyWith(
        workspaces: [...state.workspaces, createdWorkspace],
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao criar workspace: $e',
      );
    }
  }

  void setCurrentWorkspace(Workspace workspace) {
    state = state.copyWith(currentWorkspace: workspace);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Provider dos workspaces
final workspaceProvider =
    StateNotifierProvider<WorkspaceNotifier, WorkspaceState>((ref) {
  final documentService = ref.watch(documentServiceProvider);
  return WorkspaceNotifier(documentService);
});

// Providers derivados de workspace
final workspacesListProvider = Provider<List<Workspace>>((ref) {
  return ref.watch(workspaceProvider).workspaces;
});

final currentWorkspaceProvider = Provider<Workspace?>((ref) {
  return ref.watch(workspaceProvider).currentWorkspace;
});
