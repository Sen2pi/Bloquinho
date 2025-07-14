import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../models/cartao_credito.dart';
import '../models/cartao_fidelizacao.dart';
import '../models/documento_identificacao.dart';
import '../../../core/services/workspace_storage_service.dart';
import '../../../shared/providers/local_storage_provider.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../shared/providers/workspace_provider.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/workspace.dart';

// Provider para WorkspaceStorageService
final workspaceStorageServiceProvider =
    Provider<WorkspaceStorageService>((ref) {
  return WorkspaceStorageService();
});

// Estado dos documentos
class DocumentosState {
  final List<CartaoCredito> cartoesCredito;
  final List<CartaoFidelizacao> cartoesFidelizacao;
  final List<DocumentoIdentificacao> documentosIdentificacao;
  final bool isLoading;
  final String? error;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  const DocumentosState({
    this.cartoesCredito = const [],
    this.cartoesFidelizacao = const [],
    this.documentosIdentificacao = const [],
    this.isLoading = false,
    this.error,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  DocumentosState copyWith({
    List<CartaoCredito>? cartoesCredito,
    List<CartaoFidelizacao>? cartoesFidelizacao,
    List<DocumentoIdentificacao>? documentosIdentificacao,
    bool? isLoading,
    String? error,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool clearError = false,
  }) {
    return DocumentosState(
      cartoesCredito: cartoesCredito ?? this.cartoesCredito,
      cartoesFidelizacao: cartoesFidelizacao ?? this.cartoesFidelizacao,
      documentosIdentificacao:
          documentosIdentificacao ?? this.documentosIdentificacao,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  /// Obter total de documentos
  int get totalDocumentos =>
      cartoesCredito.length +
      cartoesFidelizacao.length +
      documentosIdentificacao.length;

  /// Obter documentos vencidos
  List<dynamic> get documentosVencidos {
    final vencidos = <dynamic>[];

    // Cartões de crédito vencidos
    vencidos.addAll(cartoesCredito.where((cartao) => cartao.vencido));

    // Cartões de fidelização vencidos
    vencidos.addAll(cartoesFidelizacao.where((cartao) => cartao.vencido));

    // Documentos de identificação vencidos
    vencidos.addAll(documentosIdentificacao.where((doc) => doc.vencido));

    return vencidos;
  }

  /// Obter documentos que vencem em breve
  List<dynamic> get documentosVencemEmBreve {
    final vencemEmBreve = <dynamic>[];

    // Documentos de identificação que vencem em breve
    vencemEmBreve
        .addAll(documentosIdentificacao.where((doc) => doc.venceEmBreve));

    return vencemEmBreve;
  }

  /// Obter cartões com pontos expirando
  List<CartaoFidelizacao> get cartoesPontosExpiram {
    return cartoesFidelizacao.where((cartao) => cartao.pontosExpiram).toList();
  }
}

// Notifier para gerenciar documentos
class DocumentosNotifier extends StateNotifier<DocumentosState> {
  final WorkspaceStorageService _storageService;
  String? _currentWorkspaceId;
  String? _currentProfileName;
  bool _isInitialized = false;

  DocumentosNotifier(this._storageService) : super(const DocumentosState()) {
    _loadDocumentos();
  }

  /// Definir contexto do workspace
  Future<void> setContext(String profileName, String workspaceId) async {
    await _storageService.setContext(profileName, workspaceId);
    _currentProfileName = profileName;
    _currentWorkspaceId = workspaceId;
    await _loadDocumentos();
  }

  /// Carregar documentos do storage
  Future<void> _loadDocumentos() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Verificar se temos contexto definido
      if (!_storageService.hasContext) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final workspaceData =
          await _storageService.loadWorkspaceData('documentos');
      if (workspaceData != null) {
        final cartoesCredito =
            (workspaceData['cartoes_credito'] as List<dynamic>? ?? [])
                .map((json) => CartaoCredito.fromJson(json))
                .toList();
        final cartoesFidelizacao =
            (workspaceData['cartoes_fidelizacao'] as List<dynamic>? ?? [])
                .map((json) => CartaoFidelizacao.fromJson(json))
                .toList();
        final documentosIdentificacao =
            (workspaceData['documentos_identificacao'] as List<dynamic>? ?? [])
                .map((json) => DocumentoIdentificacao.fromJson(json))
                .toList();

        state = state.copyWith(
          cartoesCredito: cartoesCredito,
          cartoesFidelizacao: cartoesFidelizacao,
          documentosIdentificacao: documentosIdentificacao,
          isLoading: false,
        );
      } else {
        // Se não há dados, inicializar com listas vazias
        state = state.copyWith(
          cartoesCredito: [],
          cartoesFidelizacao: [],
          documentosIdentificacao: [],
          isLoading: false,
        );
      }

      _isInitialized = true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar documentos: $e',
      );
    }
  }

  /// Salvar documentos no storage
  Future<void> _saveDocumentos() async {
    try {
      // Verificar se temos contexto definido
      if (!_storageService.hasContext) {
        throw Exception('Contexto não definido para salvar documentos');
      }

      final data = {
        'cartoes_credito':
            state.cartoesCredito.map((cartao) => cartao.toJson()).toList(),
        'cartoes_fidelizacao':
            state.cartoesFidelizacao.map((cartao) => cartao.toJson()).toList(),
        'documentos_identificacao':
            state.documentosIdentificacao.map((doc) => doc.toJson()).toList(),
        'lastModified': DateTime.now().toIso8601String(),
      };
      await _storageService.saveWorkspaceData('documentos', data);
    } catch (e) {
      state = state.copyWith(error: 'Erro ao salvar documentos: $e');
    }
  }

  // ===== CARTÕES DE CRÉDITO =====

  /// Adicionar cartão de crédito
  Future<void> addCartaoCredito(CartaoCredito cartao) async {
    state = state.copyWith(isCreating: true, error: null);

    try {
      final updatedCartoes = [...state.cartoesCredito, cartao];
      state = state.copyWith(
        cartoesCredito: updatedCartoes,
        isCreating: false,
      );
      await _saveDocumentos();
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Erro ao adicionar cartão: $e',
      );
    }
  }

  /// Atualizar cartão de crédito
  Future<void> updateCartaoCredito(CartaoCredito cartao) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final updatedCartoes = state.cartoesCredito.map((c) {
        return c.id == cartao.id ? cartao : c;
      }).toList();

      state = state.copyWith(
        cartoesCredito: updatedCartoes,
        isUpdating: false,
      );
      await _saveDocumentos();
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Erro ao atualizar cartão: $e',
      );
    }
  }

  /// Remover cartão de crédito
  Future<void> removeCartaoCredito(String id) async {
    state = state.copyWith(isDeleting: true, error: null);

    try {
      final updatedCartoes =
          state.cartoesCredito.where((c) => c.id != id).toList();
      state = state.copyWith(
        cartoesCredito: updatedCartoes,
        isDeleting: false,
      );
      await _saveDocumentos();
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Erro ao remover cartão: $e',
      );
    }
  }

  /// Buscar cartões de crédito
  List<CartaoCredito> searchCartoesCredito(String query) {
    final lowercaseQuery = query.toLowerCase();
    return state.cartoesCredito.where((cartao) {
      return cartao.nomeImpresso.toLowerCase().contains(lowercaseQuery) ||
          cartao.emissor.toLowerCase().contains(lowercaseQuery) ||
          cartao.numeroMascarado.contains(lowercaseQuery);
    }).toList();
  }

  // ===== CARTÕES DE FIDELIZAÇÃO =====

  /// Adicionar cartão de fidelização
  Future<void> addCartaoFidelizacao(CartaoFidelizacao cartao) async {
    state = state.copyWith(isCreating: true, error: null);

    try {
      final updatedCartoes = [...state.cartoesFidelizacao, cartao];
      state = state.copyWith(
        cartoesFidelizacao: updatedCartoes,
        isCreating: false,
      );
      await _saveDocumentos();
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Erro ao adicionar cartão de fidelização: $e',
      );
    }
  }

  /// Atualizar cartão de fidelização
  Future<void> updateCartaoFidelizacao(CartaoFidelizacao cartao) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final updatedCartoes = state.cartoesFidelizacao.map((c) {
        return c.id == cartao.id ? cartao : c;
      }).toList();

      state = state.copyWith(
        cartoesFidelizacao: updatedCartoes,
        isUpdating: false,
      );
      await _saveDocumentos();
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Erro ao atualizar cartão de fidelização: $e',
      );
    }
  }

  /// Remover cartão de fidelização
  Future<void> removeCartaoFidelizacao(String id) async {
    state = state.copyWith(isDeleting: true, error: null);

    try {
      final updatedCartoes =
          state.cartoesFidelizacao.where((c) => c.id != id).toList();
      state = state.copyWith(
        cartoesFidelizacao: updatedCartoes,
        isDeleting: false,
      );
      await _saveDocumentos();
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Erro ao remover cartão de fidelização: $e',
      );
    }
  }

  /// Buscar cartões de fidelização
  List<CartaoFidelizacao> searchCartoesFidelizacao(String query) {
    final lowercaseQuery = query.toLowerCase();
    return state.cartoesFidelizacao.where((cartao) {
      return cartao.nome.toLowerCase().contains(lowercaseQuery) ||
          cartao.empresa.toLowerCase().contains(lowercaseQuery) ||
          cartao.numeroMascarado.contains(lowercaseQuery);
    }).toList();
  }

  // ===== DOCUMENTOS DE IDENTIFICAÇÃO =====

  /// Adicionar documento de identificação
  Future<void> addDocumentoIdentificacao(
      DocumentoIdentificacao documento) async {
    state = state.copyWith(isCreating: true, error: null);

    try {
      final updatedDocumentos = [...state.documentosIdentificacao, documento];
      state = state.copyWith(
        documentosIdentificacao: updatedDocumentos,
        isCreating: false,
      );
      await _saveDocumentos();
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Erro ao adicionar documento: $e',
      );
    }
  }

  /// Atualizar documento de identificação
  Future<void> updateDocumentoIdentificacao(
      DocumentoIdentificacao documento) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final updatedDocumentos = state.documentosIdentificacao.map((d) {
        return d.id == documento.id ? documento : d;
      }).toList();

      state = state.copyWith(
        documentosIdentificacao: updatedDocumentos,
        isUpdating: false,
      );
      await _saveDocumentos();
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Erro ao atualizar documento: $e',
      );
    }
  }

  /// Remover documento de identificação
  Future<void> removeDocumentoIdentificacao(String id) async {
    state = state.copyWith(isDeleting: true, error: null);

    try {
      final updatedDocumentos =
          state.documentosIdentificacao.where((d) => d.id != id).toList();
      state = state.copyWith(
        documentosIdentificacao: updatedDocumentos,
        isDeleting: false,
      );
      await _saveDocumentos();
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Erro ao remover documento: $e',
      );
    }
  }

  /// Buscar documentos de identificação
  List<DocumentoIdentificacao> searchDocumentosIdentificacao(String query) {
    final lowercaseQuery = query.toLowerCase();
    return state.documentosIdentificacao.where((doc) {
      return doc.nomeCompleto.toLowerCase().contains(lowercaseQuery) ||
          doc.numeroFormatado.contains(lowercaseQuery) ||
          (doc.orgaoEmissor?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  /// Adicionar arquivo PDF ao documento
  Future<void> addPdfToDocumento(String documentoId, String pdfPath) async {
    try {
      final documento =
          state.documentosIdentificacao.firstWhere((d) => d.id == documentoId);
      final updatedDocumento = documento.copyWith(arquivoPdfPath: pdfPath);

      await updateDocumentoIdentificacao(updatedDocumento);
    } catch (e) {
      state = state.copyWith(error: 'Erro ao adicionar PDF: $e');
    }
  }

  /// Adicionar imagem ao documento
  Future<void> addImagemToDocumento(
      String documentoId, String imagemPath) async {
    try {
      final documento =
          state.documentosIdentificacao.firstWhere((d) => d.id == documentoId);
      final updatedDocumento =
          documento.copyWith(arquivoImagemPath: imagemPath);

      await updateDocumentoIdentificacao(updatedDocumento);
    } catch (e) {
      state = state.copyWith(error: 'Erro ao adicionar imagem: $e');
    }
  }

  // ===== UTILIDADES =====

  /// Limpar erro
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Recarregar documentos
  Future<void> reloadDocumentos() async {
    await _loadDocumentos();
  }

  /// Obter estatísticas
  Map<String, dynamic> getStats() {
    return {
      'totalCartoesCredito': state.cartoesCredito.length,
      'totalCartoesFidelizacao': state.cartoesFidelizacao.length,
      'totalDocumentosIdentificacao': state.documentosIdentificacao.length,
      'totalDocumentos': state.totalDocumentos,
      'documentosVencidos': state.documentosVencidos.length,
      'documentosVencemEmBreve': state.documentosVencemEmBreve.length,
      'cartoesPontosExpiram': state.cartoesPontosExpiram.length,
    };
  }
}

// Providers
final documentosProvider =
    StateNotifierProvider<DocumentosNotifier, DocumentosState>((ref) {
  final storageService = ref.watch(workspaceStorageServiceProvider);
  final notifier = DocumentosNotifier(storageService);

  // Inicializa contexto na primeira criação do provider
  final profile = ref.read(currentProfileProvider);
  final workspace = ref.read(currentWorkspaceProvider);
  final defaultWorkspaceId = ref.read(documentosWorkspaceProvider);
  if (profile != null) {
    final workspaceId = workspace?.id ?? defaultWorkspaceId;
    notifier.setContext(profile.name, workspaceId);
  }

  // Observa mudanças de profile/workspace e atualiza contexto
  ref.listen<UserProfile?>(currentProfileProvider, (prevProfile, currProfile) {
    final workspace = ref.read(currentWorkspaceProvider);
    final defaultWorkspaceId = ref.read(documentosWorkspaceProvider);
    if (currProfile != null) {
      final workspaceId = workspace?.id ?? defaultWorkspaceId;
      notifier.setContext(currProfile.name, workspaceId);
    }
  });

  // Observa mudanças de workspace
  ref.listen<Workspace?>(currentWorkspaceProvider,
      (prevWorkspace, currWorkspace) {
    final profile = ref.read(currentProfileProvider);
    final defaultWorkspaceId = ref.read(documentosWorkspaceProvider);
    if (profile != null) {
      final workspaceId = currWorkspace?.id ?? defaultWorkspaceId;
      notifier.setContext(profile.name, workspaceId);
    }
  });

  return notifier;
});

// Provider para estatísticas
final documentosStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final notifier = ref.read(documentosProvider.notifier);
  return notifier.getStats();
});

// Provider para documentos vencidos
final documentosVencidosProvider = Provider<List<dynamic>>((ref) {
  final state = ref.watch(documentosProvider);
  return state.documentosVencidos;
});

// Provider para documentos que vencem em breve
final documentosVencemEmBreveProvider = Provider<List<dynamic>>((ref) {
  final state = ref.watch(documentosProvider);
  return state.documentosVencemEmBreve;
});

// Provider para cartões com pontos expirando
final cartoesPontosExpiramProvider = Provider<List<CartaoFidelizacao>>((ref) {
  final state = ref.watch(documentosProvider);
  return state.cartoesPontosExpiram;
});

// Provider para inicializar contexto do workspace
final documentosContextProvider = Provider<void>((ref) {
  final notifier = ref.read(documentosProvider.notifier);
  final profile = ref.watch(currentProfileProvider);
  final workspace = ref.watch(currentWorkspaceProvider);
  final defaultWorkspaceId = ref.read(documentosWorkspaceProvider);

  if (profile != null) {
    final workspaceId = workspace?.id ?? defaultWorkspaceId;
    // Definir contexto de forma assíncrona
    Future.microtask(() async {
      await notifier.setContext(profile.name, workspaceId);
    });
  }
});
