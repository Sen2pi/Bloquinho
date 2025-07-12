import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/bloco_base_model.dart';
import '../models/bloco_tipo_enum.dart';

/// Serviço para conversão entre blocos e diferentes formatos
class BlocosConverterService {
  static const _uuid = Uuid();

  /// Converter lista de blocos para Markdown
  String blocosToMarkdown(List<BlocoBase> blocos) {
    if (blocos.isEmpty) return '';

    final buffer = StringBuffer();

    for (int i = 0; i < blocos.length; i++) {
      final bloco = blocos[i];
      final markdown = _blocoToMarkdown(bloco);

      if (markdown.isNotEmpty) {
        buffer.write(markdown);

        // Adicionar quebra de linha entre blocos (exceto no último)
        if (i < blocos.length - 1) {
          buffer.write('\n\n');
        }
      }
    }

    return buffer.toString();
  }

  /// Converter bloco individual para Markdown
  String _blocoToMarkdown(BlocoBase bloco) {
    switch (bloco.tipo) {
      case BlocoTipo.texto:
        final blocoTexto = bloco as BlocoTexto;
        return blocoTexto.conteudo;

      case BlocoTipo.titulo:
        final blocoTitulo = bloco as BlocoTitulo;
        final prefix = '#' * blocoTitulo.nivel;
        return '$prefix ${blocoTitulo.conteudo}';

      case BlocoTipo.lista:
        final blocoLista = bloco as BlocoLista;
        return blocoLista.itens.map((item) => '- $item').join('\n');

      case BlocoTipo.listaNumerada:
        final blocoListaNumerada = bloco as BlocoListaNumerada;
        return blocoListaNumerada.itens
            .asMap()
            .entries
            .map((entry) =>
                '${entry.key + blocoListaNumerada.inicioNumero}. ${entry.value}')
            .join('\n');

      case BlocoTipo.tarefa:
        final blocoTarefa = bloco as BlocoTarefa;
        final checkbox = blocoTarefa.concluida ? '[x]' : '[ ]';
        return '- $checkbox ${blocoTarefa.conteudo}';

      case BlocoTipo.codigo:
        final blocoCodigo = bloco as BlocoCodigo;
        return '```${blocoCodigo.linguagem}\n${blocoCodigo.codigo}\n```';

      case BlocoTipo.equacao:
        final blocoEquacao = bloco as BlocoEquacao;
        if (blocoEquacao.blocoCompleto) {
          return '\$\${blocoEquacao.formula}\$\$';
        } else {
          return '\${blocoEquacao.formula}\$';
        }

      case BlocoTipo.link:
        final blocoLink = bloco as BlocoLink;
        final titulo = blocoLink.titulo ?? blocoLink.url;
        return '[$titulo](${blocoLink.url})';

      case BlocoTipo.imagem:
        final blocoImagem = bloco as BlocoImagem;
        final alt = blocoImagem.textoAlternativo ?? 'Imagem';
        return '![${alt}](${blocoImagem.url})';

      case BlocoTipo.divisor:
        return '---';

      case BlocoTipo.tabela:
        final blocoTabela = bloco as BlocoTabela;
        return _tabelaToMarkdown(blocoTabela);

      default:
        return '';
    }
  }

  /// Converter tabela para Markdown
  String _tabelaToMarkdown(BlocoTabela tabela) {
    if (tabela.cabecalhos.isEmpty) return '';

    final buffer = StringBuffer();

    // Cabeçalhos
    buffer.write('| ${tabela.cabecalhos.join(' | ')} |');
    buffer.write('\n');

    // Separador
    buffer.write('| ${tabela.cabecalhos.map((_) => '---').join(' | ')} |');
    buffer.write('\n');

    // Linhas de dados
    for (final linha in tabela.linhas) {
      buffer.write('| ${linha.join(' | ')} |');
      buffer.write('\n');
    }

    return buffer.toString().trim();
  }

  /// Converter Markdown para lista de blocos
  List<BlocoBase> markdownToBlocos(String markdown) {
    if (markdown.trim().isEmpty) return [];

    final blocos = <BlocoBase>[];
    final lines = markdown.split('\n');

    String currentParagraph = '';
    bool inCodeBlock = false;
    String codeBlockLanguage = '';
    String codeBlockContent = '';
    bool inTable = false;
    List<String> tableHeaders = [];
    List<List<String>> tableRows = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Verificar se está em bloco de código
      if (line.trim().startsWith("```")) {
        if (inCodeBlock) {
          // Fechar bloco de código
          blocos.add(BlocoCodigo(
            id: _uuid.v4(),
            codigo: codeBlockContent.trim(),
            linguagem: codeBlockLanguage,
          ));
          inCodeBlock = false;
          codeBlockContent = '';
          codeBlockLanguage = '';
        } else {
          // Iniciar bloco de código
          _addCurrentParagraph(blocos, currentParagraph);
          currentParagraph = '';

          inCodeBlock = true;
          codeBlockLanguage = line.trim().substring(3);
        }
        continue;
      }

      if (inCodeBlock) {
        codeBlockContent += '$line\n';
        continue;
      }

      // Verificar se é linha de tabela
      if (line.contains('|') && line.trim().isNotEmpty) {
        if (!inTable) {
          _addCurrentParagraph(blocos, currentParagraph);
          currentParagraph = '';
          inTable = true;

          // Primeira linha são os cabeçalhos
          tableHeaders = _parseTableRow(line);
        } else {
          // Verificar se é linha separadora
          if (line.contains('---')) {
            continue; // Pular linha separadora
          }

          // Linha de dados
          final row = _parseTableRow(line);
          tableRows.add(row);
        }
        continue;
      } else if (inTable) {
        // Fim da tabela
        blocos.add(BlocoTabela(
          id: _uuid.v4(),
          cabecalhos: tableHeaders,
          linhas: tableRows,
        ));
        inTable = false;
        tableHeaders.clear();
        tableRows.clear();
      }

      // Linha vazia
      if (line.trim().isEmpty) {
        _addCurrentParagraph(blocos, currentParagraph);
        currentParagraph = '';
        continue;
      }

      // Títulos
      final headerMatch = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(line);
      if (headerMatch != null) {
        _addCurrentParagraph(blocos, currentParagraph);
        currentParagraph = '';

        final level = headerMatch.group(1)!.length;
        final title = headerMatch.group(2)!;
        blocos.add(BlocoTitulo(
          id: _uuid.v4(),
          conteudo: title,
          nivel: level,
        ));
        continue;
      }

      // Divisor
      if (line.trim() == '---') {
        _addCurrentParagraph(blocos, currentParagraph);
        currentParagraph = '';

        blocos.add(BlocoDivisor(id: _uuid.v4()));
        continue;
      }

      // Lista de tarefas
      final taskMatch = RegExp(r'^\s*-\s*\[([x\s])\]\s*(.+)$').firstMatch(line);
      if (taskMatch != null) {
        _addCurrentParagraph(blocos, currentParagraph);
        currentParagraph = '';

        final isChecked = taskMatch.group(1)!.toLowerCase() == 'x';
        final taskText = taskMatch.group(2)!;
        blocos.add(BlocoTarefa(
          id: _uuid.v4(),
          conteudo: taskText,
          concluida: isChecked,
        ));
        continue;
      }

      // Lista com marcadores
      final listMatch = RegExp(r'^\s*-\s+(.+)$').firstMatch(line);
      if (listMatch != null) {
        _addCurrentParagraph(blocos, currentParagraph);
        currentParagraph = '';

        final itemText = listMatch.group(1)!;

        // Verificar se é continuação de lista anterior
        if (blocos.isNotEmpty && blocos.last is BlocoLista) {
          final lastList = blocos.last as BlocoLista;
          final updatedList = BlocoLista(
            id: lastList.id,
            itens: [...lastList.itens, itemText],
            estilo: lastList.estilo,
            indentacao: lastList.indentacao,
          );
          blocos[blocos.length - 1] = updatedList;
        } else {
          blocos.add(BlocoLista(
            id: _uuid.v4(),
            itens: [itemText],
          ));
        }
        continue;
      }

      // Lista numerada
      final numberedMatch = RegExp(r'^\s*(\d+)\.\s+(.+)$').firstMatch(line);
      if (numberedMatch != null) {
        _addCurrentParagraph(blocos, currentParagraph);
        currentParagraph = '';

        final number = int.parse(numberedMatch.group(1)!);
        final itemText = numberedMatch.group(2)!;

        // Verificar se é continuação de lista anterior
        if (blocos.isNotEmpty && blocos.last is BlocoListaNumerada) {
          final lastList = blocos.last as BlocoListaNumerada;
          final updatedList = BlocoListaNumerada(
            id: lastList.id,
            itens: [...lastList.itens, itemText],
            estilo: lastList.estilo,
            indentacao: lastList.indentacao,
            inicioNumero: lastList.inicioNumero,
          );
          blocos[blocos.length - 1] = updatedList;
        } else {
          blocos.add(BlocoListaNumerada(
            id: _uuid.v4(),
            itens: [itemText],
            inicioNumero: number,
          ));
        }
        continue;
      }

      // Equações LaTeX
      final mathBlockMatch = RegExp(r'^\$\$(.+)\$\$').firstMatch(line.trim());
      if (mathBlockMatch != null) {
        _addCurrentParagraph(blocos, currentParagraph);
        currentParagraph = '';

        final formula = mathBlockMatch.group(1)!;
        blocos.add(BlocoEquacao(
          id: _uuid.v4(),
          formula: formula,
          blocoCompleto: true,
        ));
        continue;
      }

      // Linha normal - adicionar ao parágrafo atual
      currentParagraph += '${currentParagraph.isEmpty ? '' : '\n'}$line';
    }

    // Adicionar último parágrafo se houver
    _addCurrentParagraph(blocos, currentParagraph);

    // Finalizar tabela se estiver em uma
    if (inTable) {
      blocos.add(BlocoTabela(
        id: _uuid.v4(),
        cabecalhos: tableHeaders,
        linhas: tableRows,
      ));
    }

    return blocos;
  }

  /// Adicionar parágrafo atual aos blocos se não estiver vazio
  void _addCurrentParagraph(List<BlocoBase> blocos, String paragraph) {
    final cleanParagraph = paragraph.trim();
    if (cleanParagraph.isNotEmpty) {
      blocos.add(BlocoTexto(
        id: _uuid.v4(),
        conteudo: cleanParagraph,
      ));
    }
  }

  /// Parsear linha de tabela
  List<String> _parseTableRow(String line) {
    return line
        .split('|')
        .map((cell) => cell.trim())
        .where((cell) => cell.isNotEmpty)
        .toList();
  }

  /// Converter blocos para HTML
  String blocosToHtml(List<BlocoBase> blocos) {
    if (blocos.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.write('<!DOCTYPE html>\n');
    buffer.write('<html>\n<head>\n');
    buffer.write('<meta charset="UTF-8">\n');
    buffer.write('<title>Documento Bloquinho</title>\n');
    buffer.write('<style>\n');
    buffer.write(_getDefaultCss());
    buffer.write('\n</style>\n</head>\n<body>\n');

    for (final bloco in blocos) {
      final html = _blocoToHtml(bloco);
      if (html.isNotEmpty) {
        buffer.write('$html\n');
      }
    }

    buffer.write('</body>\n</html>');
    return buffer.toString();
  }

  /// Converter bloco individual para HTML
  String _blocoToHtml(BlocoBase bloco) {
    switch (bloco.tipo) {
      case BlocoTipo.texto:
        final blocoTexto = bloco as BlocoTexto;
        return '<p>${_escapeHtml(blocoTexto.conteudo)}</p>';

      case BlocoTipo.titulo:
        final blocoTitulo = bloco as BlocoTitulo;
        return '<h${blocoTitulo.nivel}>${_escapeHtml(blocoTitulo.conteudo)}</h${blocoTitulo.nivel}>';

      case BlocoTipo.lista:
        final blocoLista = bloco as BlocoLista;
        final items = blocoLista.itens
            .map((item) => '<li>${_escapeHtml(item)}</li>')
            .join('\n');
        return '<ul>\n$items\n</ul>';

      case BlocoTipo.listaNumerada:
        final blocoListaNumerada = bloco as BlocoListaNumerada;
        final items = blocoListaNumerada.itens
            .map((item) => '<li>${_escapeHtml(item)}</li>')
            .join('\n');
        return '<ol start="${blocoListaNumerada.inicioNumero}">\n$items\n</ol>';

      case BlocoTipo.tarefa:
        final blocoTarefa = bloco as BlocoTarefa;
        final checked = blocoTarefa.concluida ? 'checked' : '';
        return '<div class="task"><input type="checkbox" $checked disabled> ${_escapeHtml(blocoTarefa.conteudo)}</div>';

      case BlocoTipo.codigo:
        final blocoCodigo = bloco as BlocoCodigo;
        return '<pre><code class="language-${blocoCodigo.linguagem}">${_escapeHtml(blocoCodigo.codigo)}</code></pre>';

      case BlocoTipo.equacao:
        final blocoEquacao = bloco as BlocoEquacao;
        if (blocoEquacao.blocoCompleto) {
          return '<div class="math-block">\$\${_escapeHtml(blocoEquacao.formula)}\$\$</div>';
        } else {
          return '<span class="math-inline">\${_escapeHtml(blocoEquacao.formula)}\$\n</span>';
        }

      case BlocoTipo.link:
        final blocoLink = bloco as BlocoLink;
        final titulo = blocoLink.titulo ?? blocoLink.url;
        return '<a href="${_escapeHtml(blocoLink.url)}">${_escapeHtml(titulo)}</a>';

      case BlocoTipo.imagem:
        final blocoImagem = bloco as BlocoImagem;
        final alt = blocoImagem.textoAlternativo ?? 'Imagem';
        return '<img src="${_escapeHtml(blocoImagem.url)}" alt="${_escapeHtml(alt)}">';

      case BlocoTipo.divisor:
        return '<hr>';

      case BlocoTipo.tabela:
        final blocoTabela = bloco as BlocoTabela;
        return _tabelaToHtml(blocoTabela);

      default:
        return '';
    }
  }

  /// Converter tabela para HTML
  String _tabelaToHtml(BlocoTabela tabela) {
    if (tabela.cabecalhos.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.write('<table>\n');

    // Cabeçalhos
    buffer.write('<thead>\n<tr>\n');
    for (final header in tabela.cabecalhos) {
      buffer.write('<th>${_escapeHtml(header)}</th>\n');
    }
    buffer.write('</tr>\n</thead>\n');

    // Corpo da tabela
    buffer.write('<tbody>\n');
    for (final linha in tabela.linhas) {
      buffer.write('<tr>\n');
      for (final cell in linha) {
        buffer.write('<td>${_escapeHtml(cell)}</td>\n');
      }
      buffer.write('</tr>\n');
    }
    buffer.write('</tbody>\n');

    buffer.write('</table>');
    return buffer.toString();
  }

  /// Escapar caracteres HTML
  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  /// CSS padrão para HTML
  String _getDefaultCss() {
    return '''
body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
  line-height: 1.6;
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
  color: #333;
}

h1, h2, h3, h4, h5, h6 {
  margin-top: 24px;
  margin-bottom: 16px;
  font-weight: 600;
  line-height: 1.25;
}

h1 { font-size: 2em; }
h2 { font-size: 1.5em; }
h3 { font-size: 1.25em; }

p {
  margin-bottom: 16px;
}

ul, ol {
  padding-left: 30px;
  margin-bottom: 16px;
}

li {
  margin-bottom: 4px;
}

.task {
  margin-bottom: 8px;
}

.task input {
  margin-right: 8px;
}

pre {
  background: #f6f8fa;
  border-radius: 6px;
  padding: 16px;
  overflow-x: auto;
  margin-bottom: 16px;
}

code {
  background: #f6f8fa;
  padding: 2px 4px;
  border-radius: 3px;
  font-size: 85%;
}

pre code {
  background: none;
  padding: 0;
}

table {
  border-collapse: collapse;
  width: 100%;
  margin-bottom: 16px;
}

th, td {
  border: 1px solid #dfe2e5;
  padding: 8px 12px;
  text-align: left;
}

th {
  background: #f6f8fa;
  font-weight: 600;
}

hr {
  border: none;
  height: 1px;
  background: #e1e4e8;
  margin: 24px 0;
}

.math-block {
  text-align: center;
  margin: 16px 0;
}

.math-inline {
  font-family: "Computer Modern", serif;
}

img {
  max-width: 100%;
  height: auto;
  margin: 16px 0;
}

a {
  color: #0366d6;
  text-decoration: none;
}

a:hover {
  text-decoration: underline;
}
''';
  }

  /// Converter blocos para JSON
  Map<String, dynamic> blocosToJson(List<BlocoBase> blocos) {
    return {
      'version': '1.0',
      'createdAt': DateTime.now().toIso8601String(),
      'blocos': blocos.map((bloco) => bloco.toJson()).toList(),
    };
  }

  /// Converter JSON para blocos
  List<BlocoBase> jsonToBlocos(Map<String, dynamic> json) {
    final blocosData = json['blocos'] as List?;
    if (blocosData == null) return [];

    return blocosData
        .map((blocoJson) => BlocoBase.fromJson(blocoJson))
        .toList();
  }

  /// Converter blocos para texto simples
  String blocosToPlainText(List<BlocoBase> blocos) {
    if (blocos.isEmpty) return '';

    final buffer = StringBuffer();

    for (int i = 0; i < blocos.length; i++) {
      final bloco = blocos[i];
      final text = _blocoToPlainText(bloco);

      if (text.isNotEmpty) {
        buffer.write(text);

        // Adicionar quebra de linha entre blocos (exceto no último)
        if (i < blocos.length - 1) {
          buffer.write('\n\n');
        }
      }
    }

    return buffer.toString();
  }

  /// Converter bloco individual para texto simples
  String _blocoToPlainText(BlocoBase bloco) {
    switch (bloco.tipo) {
      case BlocoTipo.texto:
        final blocoTexto = bloco as BlocoTexto;
        return blocoTexto.conteudo;

      case BlocoTipo.titulo:
        final blocoTitulo = bloco as BlocoTitulo;
        return blocoTitulo.conteudo;

      case BlocoTipo.lista:
        final blocoLista = bloco as BlocoLista;
        return blocoLista.itens.map((item) => '-  $item').join('\n');

      case BlocoTipo.listaNumerada:
        final blocoListaNumerada = bloco as BlocoListaNumerada;
        return blocoListaNumerada.itens
            .asMap()
            .entries
            .map((entry) =>
                '${entry.key + blocoListaNumerada.inicioNumero}. ${entry.value}')
            .join('\n');

      case BlocoTipo.tarefa:
        final blocoTarefa = bloco as BlocoTarefa;
        final checkbox = blocoTarefa.concluida ? '☑' : '☐';
        return '$checkbox ${blocoTarefa.conteudo}';

      case BlocoTipo.codigo:
        final blocoCodigo = bloco as BlocoCodigo;
        return blocoCodigo.codigo;

      case BlocoTipo.equacao:
        final blocoEquacao = bloco as BlocoEquacao;
        return blocoEquacao.formula;

      case BlocoTipo.link:
        final blocoLink = bloco as BlocoLink;
        final titulo = blocoLink.titulo ?? blocoLink.url;
        return '$titulo (${blocoLink.url})';

      case BlocoTipo.imagem:
        final blocoImagem = bloco as BlocoImagem;
        return blocoImagem.textoAlternativo ?? 'Imagem: ${blocoImagem.url}';

      case BlocoTipo.divisor:
        return '---';

      case BlocoTipo.tabela:
        final blocoTabela = bloco as BlocoTabela;
        return _tabelaToPlainText(blocoTabela);

      default:
        return '';
    }
  }

  /// Converter tabela para texto simples
  String _tabelaToPlainText(BlocoTabela tabela) {
    if (tabela.cabecalhos.isEmpty) return '';

    final buffer = StringBuffer();

    // Cabeçalhos
    buffer.write(tabela.cabecalhos.join(' | '));
    buffer.write('\n');

    // Separador
    buffer.write(tabela.cabecalhos.map((_) => '---').join(' | '));
    buffer.write('\n');

    // Linhas de dados
    for (final linha in tabela.linhas) {
      buffer.write(linha.join(' | '));
      buffer.write('\n');
    }

    return buffer.toString().trim();
  }

  /// Detectar formato de entrada
  FormatoConteudo detectarFormato(String conteudo) {
    if (conteudo.trim().isEmpty) {
      return FormatoConteudo.vazio;
    }

    // JSON
    if (_isJsonFormat(conteudo)) {
      return FormatoConteudo.json;
    }

    // HTML
    if (_isHtmlFormat(conteudo)) {
      return FormatoConteudo.html;
    }

    // Markdown
    if (_isMarkdownFormat(conteudo)) {
      return FormatoConteudo.markdown;
    }

    // Texto simples
    return FormatoConteudo.texto;
  }

  /// Verificar se é formato JSON
  bool _isJsonFormat(String conteudo) {
    try {
      final trimmed = conteudo.trim();
      return (trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'));
    } catch (e) {
      return false;
    }
  }

  /// Verificar se é formato HTML
  bool _isHtmlFormat(String conteudo) {
    final htmlTags = RegExp(r'<[^>]+>');
    return htmlTags.hasMatch(conteudo) &&
        (conteudo.contains('<html>') ||
            conteudo.contains('<p>') ||
            conteudo.contains('<div>') ||
            conteudo.contains('<h1>') ||
            conteudo.contains('<h2>'));
  }

  /// Verificar se é formato Markdown
  bool _isMarkdownFormat(String conteudo) {
    final markdownPatterns = [
      RegExp(r'^#{1,6}\s+'), // Títulos
      RegExp(r'\*\*.*\*\*'), // Negrito
      RegExp(r'\*.*\*'), // Itálico
      RegExp(r'`.*`'), // Código inline
      RegExp(r'^\s*[-\*\+]\s+', multiLine: true), // Listas
      RegExp(r'^\s*\d+\.\s+', multiLine: true), // Listas numeradas
      RegExp(r'\[.*\]\(.*\)'), // Links
      RegExp(r'^```', multiLine: true), // Blocos de código
    ];

    return markdownPatterns.any((pattern) => pattern.hasMatch(conteudo));
  }

  /// Converter de qualquer formato para blocos
  List<BlocoBase> converterParaBlocos(
      String conteudo, FormatoConteudo? formato) {
    final formatoDetectado = formato ?? detectarFormato(conteudo);

    switch (formatoDetectado) {
      case FormatoConteudo.markdown:
        return markdownToBlocos(conteudo);

      case FormatoConteudo.json:
        try {
          // Assumir que é JSON de blocos
          final json = Map<String, dynamic>.from(
              // Aqui seria necessário um parser JSON real
              {'blocos': []});
          return jsonToBlocos(json);
        } catch (e) {
          return [BlocoTexto(id: _uuid.v4(), conteudo: conteudo)];
        }

      case FormatoConteudo.html:
        // Para HTML, converter primeiro para Markdown e depois para blocos
        final markdown = _htmlToMarkdown(conteudo);
        return markdownToBlocos(markdown);

      case FormatoConteudo.texto:
      case FormatoConteudo.vazio:
      default:
        // Dividir em parágrafos por quebras de linha duplas
        final paragrafos =
            conteudo.split('\n\n').where((p) => p.trim().isNotEmpty).toList();

        if (paragrafos.length <= 1) {
          return [BlocoTexto(id: _uuid.v4(), conteudo: conteudo.trim())];
        }

        return paragrafos
            .map((p) => BlocoTexto(id: _uuid.v4(), conteudo: p.trim()))
            .toList();
    }
  }

  /// Conversão básica de HTML para Markdown (simplificada)
  String _htmlToMarkdown(String html) {
    String markdown = html;

    // Títulos
    markdown = markdown.replaceAllMapped(
      RegExp(r'<h([1-6])[^>]*>(.*?)</h[1-6]>', caseSensitive: false),
      (match) {
        final level = int.parse(match.group(1)!);
        final title = match.group(2)!;
        return '${'#' * level} $title';
      },
    );

    // Parágrafos
    markdown = markdown.replaceAllMapped(
      RegExp(r'<p[^>]*>(.*?)</p>', caseSensitive: false),
      (match) => match.group(1)!,
    );

    // Negrito
    markdown = markdown.replaceAllMapped(
      RegExp(r'<(b|strong)[^>]*>(.*?)</(b|strong)>', caseSensitive: false),
      (match) => '**${match.group(2)}**',
    );

    // Itálico
    markdown = markdown.replaceAllMapped(
      RegExp(r'<(i|em)[^>]*>(.*?)</(i|em)>', caseSensitive: false),
      (match) => '*${match.group(2)}*',
    );

    // Links
    markdown = markdown.replaceAllMapped(
      RegExp(r'<a[^>]*href="([^"]*)"[^>]*>(.*?)</a>', caseSensitive: false),
      (match) => '[${match.group(2)}](${match.group(1)})',
    );

    // Código
    markdown = markdown.replaceAllMapped(
      RegExp(r'<code[^>]*>(.*?)</code>', caseSensitive: false),
      (match) => '`${match.group(1)}`',
    );

    // Remover tags HTML restantes
    markdown = markdown.replaceAll(RegExp(r'<[^>]+>'), '');

    // Decodificar entidades HTML básicas
    markdown = markdown
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#x27;', "'");

    return markdown;
  }

  /// Validar estrutura de blocos
  ValidationResult validarBlocos(List<BlocoBase> blocos) {
    final erros = <String>[];
    final avisos = <String>[];

    for (int i = 0; i < blocos.length; i++) {
      final bloco = blocos[i];

      // Validar ID único
      final duplicateIds = blocos.where((b) => b.id == bloco.id).length;

      if (duplicateIds > 1) {
        erros.add('Bloco ${i + 1}: ID duplicado (${bloco.id})');
      }

      // Validações específicas por tipo
      switch (bloco.tipo) {
        case BlocoTipo.titulo:
          final titulo = bloco as BlocoTitulo;
          if (titulo.nivel < 1 || titulo.nivel > 6) {
            erros.add(
                'Bloco ${i + 1}: Nível de título inválido (${titulo.nivel})');
          }
          if (titulo.conteudo.trim().isEmpty) {
            avisos.add('Bloco ${i + 1}: Título vazio');
          }
          break;

        case BlocoTipo.lista:
          final lista = bloco as BlocoLista;
          if (lista.itens.isEmpty) {
            avisos.add('Bloco ${i + 1}: Lista vazia');
          }
          break;

        case BlocoTipo.tabela:
          final tabela = bloco as BlocoTabela;
          if (tabela.cabecalhos.isEmpty) {
            erros.add('Bloco ${i + 1}: Tabela sem cabeçalhos');
          }

          for (int j = 0; j < tabela.linhas.length; j++) {
            if (tabela.linhas[j].length != tabela.cabecalhos.length) {
              avisos.add(
                  'Bloco ${i + 1}: Linha ${j + 1} da tabela tem número diferente de colunas');
            }
          }
          break;

        case BlocoTipo.link:
          final link = bloco as BlocoLink;
          if (!_isValidUrl(link.url)) {
            erros.add('Bloco ${i + 1}: URL inválida (${link.url})');
          }
          break;

        case BlocoTipo.imagem:
          final imagem = bloco as BlocoImagem;
          if (!_isValidUrl(imagem.url)) {
            erros.add('Bloco ${i + 1}: URL de imagem inválida (${imagem.url})');
          }
          break;

        default:
          break;
      }
    }

    return ValidationResult(
      isValid: erros.isEmpty,
      erros: erros,
      avisos: avisos,
    );
  }

  /// Validar URL
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Obter estatísticas dos blocos
  Map<String, dynamic> obterEstatisticas(List<BlocoBase> blocos) {
    final stats = <String, dynamic>{};

    // Contagem por tipo
    final tipoCount = <BlocoTipo, int>{};
    for (final bloco in blocos) {
      tipoCount[bloco.tipo] = (tipoCount[bloco.tipo] ?? 0) + 1;
    }

    stats['total'] = blocos.length;
    stats['por_tipo'] = tipoCount.map((k, v) => MapEntry(k.name, v));

    // Contagem de palavras
    int totalPalavras = 0;
    int totalCaracteres = 0;

    for (final bloco in blocos) {
      final texto = _blocoToPlainText(bloco);
      totalCaracteres += texto.length;
      totalPalavras +=
          texto.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    }

    stats['palavras'] = totalPalavras;
    stats['caracteres'] = totalCaracteres;

    // Estrutura de títulos
    final titulos = blocos
        .whereType<BlocoTitulo>()
        .map((t) => {'nivel': t.nivel, 'conteudo': t.conteudo})
        .toList();

    stats['estrutura_titulos'] = titulos;

    return stats;
  }
}

/// Formatos de conteúdo suportados
enum FormatoConteudo {
  texto,
  markdown,
  html,
  json,
  vazio,
}

/// Resultado de validação
class ValidationResult {
  final bool isValid;
  final List<String> erros;
  final List<String> avisos;

  const ValidationResult({
    required this.isValid,
    required this.erros,
    required this.avisos,
  });

  bool get hasErrors => erros.isNotEmpty;
  bool get hasWarnings => avisos.isNotEmpty;
  int get totalIssues => erros.length + avisos.length;
}

/// Extensões para facilitar uso
extension FormatoConteudoExtension on FormatoConteudo {
  String get displayName {
    switch (this) {
      case FormatoConteudo.texto:
        return 'Texto Simples';
      case FormatoConteudo.markdown:
        return 'Markdown';
      case FormatoConteudo.html:
        return 'HTML';
      case FormatoConteudo.json:
        return 'JSON';
      case FormatoConteudo.vazio:
        return 'Vazio';
    }
  }

  String get fileExtension {
    switch (this) {
      case FormatoConteudo.texto:
        return '.txt';
      case FormatoConteudo.markdown:
        return '.md';
      case FormatoConteudo.html:
        return '.html';
      case FormatoConteudo.json:
        return '.json';
      case FormatoConteudo.vazio:
        return '.txt';
    }
  }
}
