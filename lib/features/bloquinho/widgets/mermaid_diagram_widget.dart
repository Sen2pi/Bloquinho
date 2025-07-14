/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class WindowsMermaidDiagramWidget extends ConsumerStatefulWidget {
  final String diagram;
  final double? height;
  final String? diagramType; // Novo: tipo de diagrama
  final bool showControls; // Novo: mostrar controles de edição

  const WindowsMermaidDiagramWidget({
    super.key,
    required this.diagram,
    this.height,
    this.diagramType,
    this.showControls = false,
  });

  @override
  ConsumerState<WindowsMermaidDiagramWidget> createState() =>
      _WindowsMermaidDiagramWidgetState();
}

class _WindowsMermaidDiagramWidgetState
    extends ConsumerState<WindowsMermaidDiagramWidget> {
  String? svgData;
  bool isLoading = true;
  String? error;
  bool isRetrying = false;

  @override
  void initState() {
    super.initState();
    _generateSvg();
  }

  @override
  void didUpdateWidget(WindowsMermaidDiagramWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.diagram != widget.diagram) {
      _generateSvg();
    }
  }

  Future<void> _generateSvg() async {
    if (isRetrying) return;

    setState(() {
      isLoading = true;
      error = null;
      isRetrying = true;
    });

    try {
      // Múltiplas APIs para redundância
      final apis = [
        'https://mermaid.ink/svg/',
        'https://mermaid.ink/img/',
        'https://kroki.io/mermaid/svg/',
      ];

      String? lastError;

      for (final api in apis) {
        try {
          final encodedDiagram = Uri.encodeComponent(widget.diagram);
          final url = '$api$encodedDiagram';

          final response = await http.get(
            Uri.parse(url),
            headers: {
              'User-Agent': 'Bloquinho/1.0',
              'Accept': 'image/svg+xml,image/png,*/*',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            setState(() {
              svgData = response.body;
              isLoading = false;
              isRetrying = false;
            });
            return;
          } else {
            lastError = 'Erro HTTP: ${response.statusCode}';
          }
        } catch (e) {
          lastError = 'Erro de conexão: $e';
        }
      }

      // Se todas as APIs falharam, usar fallback
      setState(() {
        error = lastError ?? 'Todas as APIs falharam';
        isLoading = false;
        isRetrying = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erro inesperado: $e';
        isLoading = false;
        isRetrying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 400,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return _buildLoadingView();
    }

    if (error != null) {
      return _buildErrorView();
    }

    if (svgData != null) {
      return _buildSvgView();
    }

    return _buildFallbackView();
  }

  Widget _buildLoadingView() {
    return Container(
      color: Colors.grey.shade50,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Gerando diagrama...'),
          ],
        ),
      ),
    );
  }

  Widget _buildSvgView() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.showControls) ...[
            _buildControls(),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: SvgPicture.string(
              svgData!,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Diagrama ${widget.diagramType ?? 'Mermaid'}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 16),
              onPressed: _generateSvg,
              tooltip: 'Atualizar',
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () => _copyDiagram(),
              tooltip: 'Copiar código',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Container(
      color: Colors.red.shade50,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Erro ao gerar diagrama Mermaid',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  error!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: isRetrying ? null : _generateSvg,
                  icon: isRetrying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(isRetrying ? 'Tentando...' : 'Tentar Novamente'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _showCodeView(),
                  icon: const Icon(Icons.code),
                  label: const Text('Ver Código'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackView() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_tree, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Diagrama ${widget.diagramType ?? 'Mermaid'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Código Mermaid:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      onPressed: () => _copyDiagram(),
                      tooltip: 'Copiar código',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SelectableText(
                  widget.diagram,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyDiagram() {
    // Implementar cópia para clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado para a área de transferência'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showCodeView() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Código Mermaid'),
        content: SizedBox(
          width: 500,
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SelectableText(
                    widget.diagram,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fechar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _copyDiagram();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Copiar Código'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Templates pré-definidos para diagramas Mermaid
class MermaidTemplates {
  static const Map<String, String> templates = {
    'flowchart': '''graph TD
    A[Início] --> B{Decisão?}
    B -->|Sim| C[Processo]
    B -->|Não| D[Fim]
    C --> D''',
    'sequence': '''sequenceDiagram
    participant A as Usuário
    participant B as Sistema
    A->>B: Login
    B->>A: Resposta
    A->>B: Dados
    B->>A: Confirmação''',
    'class': '''classDiagram
    class Animal {
        +String name
        +int age
        +makeSound()
    }
    class Dog {
        +bark()
    }
    class Cat {
        +meow()
    }
    Animal <|-- Dog
    Animal <|-- Cat''',
    'er': '''erDiagram
    CUSTOMER ||--o{ ORDER : places
    ORDER ||--|{ ORDER_ITEM : contains
    CUSTOMER {
        string name
        string email
    }
    ORDER {
        int orderNumber
        date orderDate
    }
    ORDER_ITEM {
        int quantity
        float price
    }''',
    'gantt': '''gantt
    title Cronograma do Projeto
    dateFormat  YYYY-MM-DD
    section Fase 1
    Tarefa 1           :done,    des1, 2024-01-01, 2024-01-05
    Tarefa 2           :active,  des2, 2024-01-06, 2024-01-10
    section Fase 2
    Tarefa 3           :         des3, 2024-01-11, 2024-01-15''',
    'pie': '''pie title Distribuição de Vendas
    "Produto A" : 30
    "Produto B" : 25
    "Produto C" : 20
    "Produto D" : 15
    "Produto E" : 10''',
    'mindmap': '''mindmap
  root((Bloquinho))
    Funcionalidades
      Editor
        Rich Text
        Markdown
        LaTeX
      Organização
        Workspaces
        Páginas
        Tags
    Tecnologias
      Flutter
      Dart
      Hive''',
    'gitgraph': '''gitGraph
    commit
    branch develop
    checkout develop
    commit
    commit
    checkout main
    merge develop
    commit''',
    'c4': '''C4Context
    title Diagrama de Contexto
    Person(user, "Usuário", "Usuário do sistema")
    System(system, "Bloquinho", "Sistema de notas")
    Rel(user, system, "Usa", "Interface web/mobile")''',
    'mermaid': '''graph LR
    A[Entrada] --> B{Processo}
    B --> C[Saída]
    B --> D[Erro]
    style A fill:#f9f,stroke:#333,stroke-width:4px
    style B fill:#bbf,stroke:#333,stroke-width:2px
    style C fill:#bfb,stroke:#333,stroke-width:2px
    style D fill:#fbb,stroke:#333,stroke-width:2px''',
  };

  /// Cria um widget Mermaid com template pré-definido
  static WindowsMermaidDiagramWidget fromTemplate(
    String templateName, {
    double? height,
    bool showControls = true,
  }) {
    final template = templates[templateName];
    if (template == null) {
      throw ArgumentError('Template "$templateName" não encontrado');
    }

    return WindowsMermaidDiagramWidget(
      diagram: template,
      height: height,
      diagramType: templateName,
      showControls: showControls,
    );
  }

  /// Lista todos os templates disponíveis
  static List<String> get availableTemplates => templates.keys.toList();

  /// Verifica se o diagrama Mermaid é válido
  static bool isValidMermaid(String diagram) {
    // Verificação básica - verificar se contém palavras-chave Mermaid
    final keywords = [
      'graph',
      'flowchart',
      'sequenceDiagram',
      'classDiagram',
      'erDiagram',
      'gantt',
      'pie',
      'mindmap',
      'gitGraph'
    ];
    return keywords.any(
        (keyword) => diagram.toLowerCase().contains(keyword.toLowerCase()));
  }

  /// Formata diagrama Mermaid para melhor legibilidade
  static String formatMermaid(String diagram) {
    // Remove espaços extras no início e fim
    diagram = diagram.trim();

    // Adiciona quebras de linha se não existirem
    if (!diagram.contains('\n')) {
      diagram = diagram.replaceAll(';', ';\n');
    }

    return diagram;
  }
}
