/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'bloco_tipo_enum.dart';

abstract class BlocoBase {
  final String id;
  final BlocoTipo tipo;

  BlocoBase({required this.id, required this.tipo});

  Map<String, dynamic> toJson();

  factory BlocoBase.fromJson(Map<String, dynamic> json) {
    switch (json['tipo']) {
      case 'texto':
        return BlocoTexto.fromJson(json);
      case 'titulo':
        return BlocoTitulo.fromJson(json);
      case 'lista':
        return BlocoLista.fromJson(json);
      case 'listaNumerada':
        return BlocoListaNumerada.fromJson(json);
      case 'tarefa':
        return BlocoTarefa.fromJson(json);
      case 'tabela':
        return BlocoTabela.fromJson(json);
      case 'codigo':
        return BlocoCodigo.fromJson(json);
      case 'equacao':
        return BlocoEquacao.fromJson(json);
      case 'imagem':
        return BlocoImagem.fromJson(json);
      case 'video':
        return BlocoVideo.fromJson(json);
      case 'link':
        return BlocoLink.fromJson(json);
      case 'divisor':
        return BlocoDivisor.fromJson(json);
      case 'coluna':
        return BlocoColuna.fromJson(json);
      case 'baseDados':
        return BlocoBaseDados.fromJson(json);
      case 'wiki':
        return BlocoWiki.fromJson(json);
      case 'pagina':
        return BlocoPagina.fromJson(json);
      case 'blocoSincronizado':
        return BlocoBlocoSincronizado.fromJson(json);
      default:
        throw Exception('Tipo de bloco desconhecido: ${json['tipo']}');
    }
  }
}

// 1. Bloco de Texto
class BlocoTexto extends BlocoBase {
  final String conteudo;
  final Map<String, dynamic> formatacao;

  BlocoTexto({
    required String id,
    required this.conteudo,
    this.formatacao = const {},
  }) : super(id: id, tipo: BlocoTipo.texto);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': 'texto',
        'conteudo': conteudo,
        'formatacao': formatacao,
      };

  factory BlocoTexto.fromJson(Map<String, dynamic> json) => BlocoTexto(
        id: json['id'],
        conteudo: json['conteudo'],
        formatacao: json['formatacao'] ?? {},
      );
}

// 2. Bloco de Título
class BlocoTitulo extends BlocoBase {
  final String conteudo;
  final int nivel; // 1-6 (H1 a H6)
  final Map<String, dynamic> formatacao;

  BlocoTitulo({
    required String id,
    required this.conteudo,
    this.nivel = 1,
    this.formatacao = const {},
  }) : super(id: id, tipo: BlocoTipo.titulo);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': 'titulo',
        'conteudo': conteudo,
        'nivel': nivel,
        'formatacao': formatacao,
      };

  factory BlocoTitulo.fromJson(Map<String, dynamic> json) => BlocoTitulo(
        id: json['id'],
        conteudo: json['conteudo'],
        nivel: json['nivel'] ?? 1,
        formatacao: json['formatacao'] ?? {},
      );
}

// 3. Bloco de Lista
class BlocoLista extends BlocoBase {
  final List<String> itens;
  final String estilo; // 'bullet', 'dash', 'arrow'
  final int indentacao;

  BlocoLista({
    required String id,
    required this.itens,
    this.estilo = 'bullet',
    this.indentacao = 0,
  }) : super(id: id, tipo: BlocoTipo.lista);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': 'lista',
        'itens': itens,
        'estilo': estilo,
        'indentacao': indentacao,
      };

  factory BlocoLista.fromJson(Map<String, dynamic> json) => BlocoLista(
        id: json['id'],
        itens: List<String>.from(json['itens']),
        estilo: json['estilo'] ?? 'bullet',
        indentacao: json['indentacao'] ?? 0,
      );
}

// 4. Bloco de Lista Numerada
class BlocoListaNumerada extends BlocoBase {
  final List<String> itens;
  final String estilo; // 'numeric', 'alphabetic', 'roman'
  final int indentacao;
  final int inicioNumero;

  BlocoListaNumerada({
    required String id,
    required this.itens,
    this.estilo = 'numeric',
    this.indentacao = 0,
    this.inicioNumero = 1,
  }) : super(id: id, tipo: BlocoTipo.listaNumerada);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': 'listaNumerada',
        'itens': itens,
        'estilo': estilo,
        'indentacao': indentacao,
        'inicioNumero': inicioNumero,
      };

  factory BlocoListaNumerada.fromJson(Map<String, dynamic> json) =>
      BlocoListaNumerada(
        id: json['id'],
        itens: List<String>.from(json['itens']),
        estilo: json['estilo'] ?? 'numeric',
        indentacao: json['indentacao'] ?? 0,
        inicioNumero: json['inicioNumero'] ?? 1,
      );
}

// 5. Bloco de Tarefa
class BlocoTarefa extends BlocoBase {
  final String conteudo;
  final bool concluida;
  final DateTime? prazo;
  final String? prioridade; // 'baixa', 'media', 'alta'
  final List<String> subtarefas;

  BlocoTarefa({
    required String id,
    required this.conteudo,
    this.concluida = false,
    this.prazo,
    this.prioridade,
    this.subtarefas = const [],
  }) : super(id: id, tipo: BlocoTipo.tarefa);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': 'tarefa',
        'conteudo': conteudo,
        'concluida': concluida,
        'prazo': prazo?.toIso8601String(),
        'prioridade': prioridade,
        'subtarefas': subtarefas,
      };

  factory BlocoTarefa.fromJson(Map<String, dynamic> json) => BlocoTarefa(
        id: json['id'],
        conteudo: json['conteudo'],
        concluida: json['concluida'] ?? false,
        prazo: json['prazo'] != null ? DateTime.parse(json['prazo']) : null,
        prioridade: json['prioridade'],
        subtarefas: List<String>.from(json['subtarefas'] ?? []),
      );
}

// 6. Bloco de Tabela
class BlocoTabela extends BlocoBase {
  final List<String> cabecalhos;
  final List<List<String>> linhas;
  final Map<String, dynamic> configuracoes;

  BlocoTabela({
    required String id,
    required this.cabecalhos,
    required this.linhas,
    this.configuracoes = const {},
  }) : super(id: id, tipo: BlocoTipo.tabela);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': 'tabela',
        'cabecalhos': cabecalhos,
        'linhas': linhas,
        'configuracoes': configuracoes,
      };

  factory BlocoTabela.fromJson(Map<String, dynamic> json) => BlocoTabela(
        id: json['id'],
        cabecalhos: List<String>.from(json['cabecalhos']),
        linhas: List<List<String>>.from(
          json['linhas'].map((linha) => List<String>.from(linha)),
        ),
        configuracoes: json['configuracoes'] ?? {},
      );
}

// 7. Bloco de Código
class BlocoCodigo extends BlocoBase {
  final String codigo;
  final String linguagem;
  final bool mostrarNumeroLinhas;
  final String tema;
  final bool destacarSintaxe;

  BlocoCodigo({
    required String id,
    required this.codigo,
    this.linguagem = 'text',
    this.mostrarNumeroLinhas = false,
    this.tema = 'default',
    this.destacarSintaxe = true,
  }) : super(id: id, tipo: BlocoTipo.codigo);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': 'codigo',
        'codigo': codigo,
        'linguagem': linguagem,
        'mostrarNumeroLinhas': mostrarNumeroLinhas,
        'tema': tema,
        'destacarSintaxe': destacarSintaxe,
      };

  factory BlocoCodigo.fromJson(Map<String, dynamic> json) => BlocoCodigo(
        id: json['id'],
        codigo: json['codigo'],
        linguagem: json['linguagem'] ?? 'text',
        mostrarNumeroLinhas: json['mostrarNumeroLinhas'] ?? false,
        tema: json['tema'] ?? 'default',
        destacarSintaxe: json['destacarSintaxe'] ?? true,
      );
}

// 8. Bloco de Equação
class BlocoEquacao extends BlocoBase {
  final String formula;
  final bool blocoCompleto; // true = display, false = inline
  final Map<String, dynamic> configuracoes;

  BlocoEquacao({
    required String id,
    required this.formula,
    this.blocoCompleto = true,
    this.configuracoes = const {},
  }) : super(id: id, tipo: BlocoTipo.equacao);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': 'equacao',
        'formula': formula,
        'blocoCompleto': blocoCompleto,
        'configuracoes': configuracoes,
      };

  factory BlocoEquacao.fromJson(Map<String, dynamic> json) => BlocoEquacao(
        id: json['id'],
        formula: json['formula'],
        blocoCompleto: json['blocoCompleto'] ?? true,
        configuracoes: json['configuracoes'] ?? {},
      );
}

// 9. Bloco de Imagem
class BlocoImagem extends BlocoBase {
  final String url;
  final String? legenda;
  final String? textoAlternativo;
  final double? largura;
  final double? altura;
  final String alinhamento; // 'left', 'center', 'right'

  BlocoImagem({
    required String id,
    required this.url,
    this.legenda,
    this.textoAlternativo,
    this.largura,
    this.altura,
    this.alinhamento = 'center',
  }) : super(id: id, tipo: BlocoTipo.imagem);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': 'imagem',
        'url': url,
        'legenda': legenda,
        'textoAlternativo': textoAlternativo,
        'largura': largura,
        'altura': altura,
        'alinhamento': alinhamento,
      };

  factory BlocoImagem.fromJson(Map<String, dynamic> json) => BlocoImagem(
        id: json['id'],
        url: json['url'],
        legenda: json['legenda'],
        textoAlternativo: json['textoAlternativo'],
        largura: json['largura']?.toDouble(),
        altura: json['altura']?.toDouble(),
        alinhamento: json['alinhamento'] ?? 'center',
      );
}

// 10. Bloco de Vídeo
class BlocoVideo extends BlocoBase {
  final String url;
  final String? legenda;
  final String? thumbnail;
  final double? largura;
  final double? altura;
  final bool autoplay;
  final bool loop;
  final bool controls;

  BlocoVideo({
    required String id,
    required this.url,
    this.legenda,
    this.thumbnail,
    this.largura,
    this.altura,
    this.autoplay = false,
    this.loop = false,
    this.controls = true,
  }) : super(id: id, tipo: BlocoTipo.video);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': 'video',
        'url': url,
        'legenda': legenda,
        'thumbnail': thumbnail,
        'largura': largura,
        'altura': altura,
        'autoplay': autoplay,
        'loop': loop,
        'controls': controls,
      };

  factory BlocoVideo.fromJson(Map<String, dynamic> json) => BlocoVideo(
        id: json['id'],
        url: json['url'],
        legenda: json['legenda'],
        thumbnail: json['thumbnail'],
        largura: json['largura']?.toDouble(),
        altura: json['altura']?.toDouble(),
        autoplay: json['autoplay'] ?? false,
        loop: json['loop'] ?? false,
        controls: json['controls'] ?? true,
      );
}

// 11. Bloco de Link
class BlocoLink extends BlocoBase {
  final String url;
  final String? titulo;
  final String? descricao;
  final String? thumbnail;
  final bool abrirNovaAba;
  final Map<String, dynamic> metadados;

  BlocoLink({
    required String id,
    required this.url,
    this.titulo,
    this.descricao,
    this.thumbnail,
    this.abrirNovaAba = true,
    this.metadados = const {},
  }) : super(id: id, tipo: BlocoTipo.link);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': 'link',
        'url': url,
        'titulo': titulo,
        'descricao': descricao,
        'thumbnail': thumbnail,
        'abrirNovaAba': abrirNovaAba,
        'metadados': metadados,
      };

  factory BlocoLink.fromJson(Map<String, dynamic> json) => BlocoLink(
        id: json['id'],
        url: json['url'],
        titulo: json['titulo'],
        descricao: json['descricao'],
        thumbnail: json['thumbnail'],
        abrirNovaAba: json['abrirNovaAba'] ?? true,
        metadados: json['metadados'] ?? {},
      );
}

// 12. Bloco Divisor
class BlocoDivisor extends BlocoBase {
  final String estilo; // 'linha', 'pontilhado', 'tracejado'
  final String cor;
  final double espessura;

  BlocoDivisor({
    required String id,
    this.estilo = 'linha',
    this.cor = '#E0E0E0',
    this.espessura = 1.0,
  }) : super(id: id, tipo: BlocoTipo.divisor);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': 'divisor',
        'estilo': estilo,
        'cor': cor,
        'espessura': espessura,
      };

  factory BlocoDivisor.fromJson(Map<String, dynamic> json) => BlocoDivisor(
        id: json['id'],
        estilo: json['estilo'] ?? 'linha',
        cor: json['cor'] ?? '#E0E0E0',
        espessura: json['espessura']?.toDouble() ?? 1.0,
      );
}

// 13. Bloco de Coluna
class BlocoColuna extends BlocoBase {
  final List<List<String>>
      colunas; // Lista de colunas, cada coluna é uma lista de IDs de blocos
  final List<double> proporcoes; // Proporções das colunas
  final double espacamento;

  BlocoColuna({
    required String id,
    required this.colunas,
    required this.proporcoes,
    this.espacamento = 16.0,
  }) : super(id: id, tipo: BlocoTipo.coluna);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': 'coluna',
        'colunas': colunas,
        'proporcoes': proporcoes,
        'espacamento': espacamento,
      };

  factory BlocoColuna.fromJson(Map<String, dynamic> json) => BlocoColuna(
        id: json['id'],
        colunas: List<List<String>>.from(
          json['colunas'].map((coluna) => List<String>.from(coluna)),
        ),
        proporcoes: List<double>.from(json['proporcoes']),
        espacamento: json['espacamento']?.toDouble() ?? 16.0,
      );
}

// 14. Bloco de Base de Dados
class BlocoBaseDados extends BlocoBase {
  final String nome;
  final List<Map<String, dynamic>> colunas;
  final List<Map<String, dynamic>> linhas;
  final Map<String, dynamic> configuracoes;
  final String visualizacao; // 'tabela', 'kanban', 'calendario', 'lista'

  BlocoBaseDados({
    required String id,
    required this.nome,
    required this.colunas,
    required this.linhas,
    this.configuracoes = const {},
    this.visualizacao = 'tabela',
  }) : super(id: id, tipo: BlocoTipo.baseDados);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': 'baseDados',
        'nome': nome,
        'colunas': colunas,
        'linhas': linhas,
        'configuracoes': configuracoes,
        'visualizacao': visualizacao,
      };

  factory BlocoBaseDados.fromJson(Map<String, dynamic> json) => BlocoBaseDados(
        id: json['id'],
        nome: json['nome'],
        colunas: List<Map<String, dynamic>>.from(json['colunas']),
        linhas: List<Map<String, dynamic>>.from(json['linhas']),
        configuracoes: json['configuracoes'] ?? {},
        visualizacao: json['visualizacao'] ?? 'tabela',
      );
}

// 15. Bloco Wiki
class BlocoWiki extends BlocoBase {
  final String titulo;
  final String conteudo;
  final List<String> tags;
  final Map<String, String> metadados;
  final List<String> referencias;

  BlocoWiki({
    required String id,
    required this.titulo,
    required this.conteudo,
    this.tags = const [],
    this.metadados = const {},
    this.referencias = const [],
  }) : super(id: id, tipo: BlocoTipo.wiki);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': 'wiki',
        'titulo': titulo,
        'conteudo': conteudo,
        'tags': tags,
        'metadados': metadados,
        'referencias': referencias,
      };

  factory BlocoWiki.fromJson(Map<String, dynamic> json) => BlocoWiki(
        id: json['id'],
        titulo: json['titulo'],
        conteudo: json['conteudo'],
        tags: List<String>.from(json['tags'] ?? []),
        metadados: Map<String, String>.from(json['metadados'] ?? {}),
        referencias: List<String>.from(json['referencias'] ?? []),
      );
}

// 16. Bloco de Página
class BlocoPagina extends BlocoBase {
  final String titulo;
  final String? icone;
  final String? capa;
  final List<String> blocos; // IDs dos blocos filhos
  final Map<String, dynamic> propriedades;
  final bool publico;

  BlocoPagina({
    required String id,
    required this.titulo,
    this.icone,
    this.capa,
    this.blocos = const [],
    this.propriedades = const {},
    this.publico = false,
  }) : super(id: id, tipo: BlocoTipo.pagina);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': 'pagina',
        'titulo': titulo,
        'icone': icone,
        'capa': capa,
        'blocos': blocos,
        'propriedades': propriedades,
        'publico': publico,
      };

  factory BlocoPagina.fromJson(Map<String, dynamic> json) => BlocoPagina(
        id: json['id'],
        titulo: json['titulo'],
        icone: json['icone'],
        capa: json['capa'],
        blocos: List<String>.from(json['blocos'] ?? []),
        propriedades: json['propriedades'] ?? {},
        publico: json['publico'] ?? false,
      );
}

// 17. Bloco Sincronizado
class BlocoBlocoSincronizado extends BlocoBase {
  final String blocoOrigemId;
  final String conteudo;
  final Map<String, dynamic> configuracoes;
  final DateTime ultimaAtualizacao;

  BlocoBlocoSincronizado({
    required String id,
    required this.blocoOrigemId,
    required this.conteudo,
    this.configuracoes = const {},
    required this.ultimaAtualizacao,
  }) : super(id: id, tipo: BlocoTipo.blocoSincronizado);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': 'blocoSincronizado',
        'blocoOrigemId': blocoOrigemId,
        'conteudo': conteudo,
        'configuracoes': configuracoes,
        'ultimaAtualizacao': ultimaAtualizacao.toIso8601String(),
      };

  factory BlocoBlocoSincronizado.fromJson(Map<String, dynamic> json) =>
      BlocoBlocoSincronizado(
        id: json['id'],
        blocoOrigemId: json['blocoOrigemId'],
        conteudo: json['conteudo'],
        configuracoes: json['configuracoes'] ?? {},
        ultimaAtualizacao: DateTime.parse(json['ultimaAtualizacao']),
      );
}
