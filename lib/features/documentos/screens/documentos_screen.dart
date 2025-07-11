import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/documento.dart';
import '../providers/documentos_provider.dart';
import '../widgets/documento_card.dart';
import '../widgets/add_documento_dialog.dart';

class DocumentosScreen extends ConsumerWidget {
  const DocumentosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentos = ref.watch(documentosProvider);
    TipoDocumento? filtro;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentos'),
        actions: [
          PopupMenuButton<TipoDocumento?>(
            icon: const Icon(Icons.filter_alt),
            onSelected: (tipo) {
              filtro = tipo;
              // Forçar rebuild
              (context as Element).markNeedsBuild();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Todos'),
              ),
              ...TipoDocumento.values.map((tipo) => PopupMenuItem(
                    value: tipo,
                    child: Text(_descricaoTipo(tipo)),
                  )),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...documentos.where((d) => filtro == null || d.tipo == filtro).map(
                (doc) => DocumentoCard(documento: doc),
              ),
          if (documentos.isEmpty)
            const Center(child: Text('Nenhum documento cadastrado.')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirDialogoNovoDocumento(context, ref),
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Documento',
      ),
    );
  }

  void _abrirDialogoNovoDocumento(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddDocumentoDialog(
        onAdd: (doc) => ref.read(documentosProvider.notifier).adicionar(doc),
      ),
    );
  }

  String _descricaoTipo(TipoDocumento tipo) {
    switch (tipo) {
      case TipoDocumento.identificacao:
        return 'Identificação';
      case TipoDocumento.cartaoCredito:
        return 'Cartão de Crédito';
      case TipoDocumento.cartaoFidelizacao:
        return 'Cartão de Fidelização';
    }
  }
}
