import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/documento.dart';

class DocumentosNotifier extends StateNotifier<List<Documento>> {
  DocumentosNotifier() : super([]);

  void adicionar(Documento doc) {
    state = [...state, doc];
  }

  void remover(String id) {
    state = state.where((d) => d.id != id).toList();
  }

  void replaceAll(List<Documento> items) {
    state = [...items];
  }
}

final documentosProvider =
    StateNotifierProvider<DocumentosNotifier, List<Documento>>(
  (ref) => DocumentosNotifier(),
);
