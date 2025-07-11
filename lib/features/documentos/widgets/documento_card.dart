import 'package:flutter/material.dart';
import '../models/documento.dart';

class DocumentoCard extends StatelessWidget {
  final Documento documento;
  final VoidCallback? onTap;
  const DocumentoCard({super.key, required this.documento, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.asset('assets/images/cartao.png', width: 36, height: 36),
        title: Text(documento.titulo),
        subtitle: Text(_descricaoTipo(documento.tipo)),
        onTap: onTap,
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
