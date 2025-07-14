import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mermaid_diagram_widget.dart' as mermaid;
import 'enhanced_markdown_preview_widget.dart';

/// Widget para demonstrar exemplos de diagramas Mermaid
class MermaidExamplesWidget extends ConsumerWidget {
  const MermaidExamplesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemplos de Diagramas Mermaid'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exemplos de Diagramas Mermaid',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Seção de Fluxogramas
            _buildSection('Fluxogramas', [
              _buildExample('Fluxograma Simples', 'flowchart'),
            ]),

            const SizedBox(height: 20),

            // Seção de Diagramas de Sequência
            _buildSection('Diagramas de Sequência', [
              _buildExample('Diagrama de Sequência', 'sequence'),
            ]),

            const SizedBox(height: 20),

            // Seção de Diagramas de Classe
            _buildSection('Diagramas de Classe', [
              _buildExample('Diagrama de Classe', 'class'),
            ]),

            const SizedBox(height: 20),

            // Seção de Diagramas ER
            _buildSection('Diagramas ER', [
              _buildExample('Diagrama ER', 'er'),
            ]),

            const SizedBox(height: 20),

            // Seção de Gantt Charts
            _buildSection('Gantt Charts', [
              _buildExample('Gantt Chart', 'gantt'),
            ]),

            const SizedBox(height: 20),

            // Seção de Gráficos
            _buildSection('Gráficos', [
              _buildExample('Gráfico de Pizza', 'pie'),
            ]),

            const SizedBox(height: 20),

            // Seção de Mapas Mentais
            _buildSection('Mapas Mentais', [
              _buildExample('Mapa Mental', 'mindmap'),
            ]),

            const SizedBox(height: 20),

            // Seção de Git Graphs
            _buildSection('Git Graphs', [
              _buildExample('Git Graph', 'gitgraph'),
            ]),

            const SizedBox(height: 20),

            // Seção de C4 Context
            _buildSection('C4 Context', [
              _buildExample('C4 Context', 'c4'),
            ]),

            const SizedBox(height: 20),

            // Seção de Mermaid Básico
            _buildSection('Mermaid Básico', [
              _buildExample('Mermaid Básico', 'mermaid'),
            ]),

            const SizedBox(height: 20),

            // Seção de Preview Markdown
            _buildMarkdownPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildExample(String name, String template) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          mermaid.MermaidTemplates.fromTemplate(
            template,
            height: 300,
            showControls: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownPreview() {
    const markdownExample = '''
# Exemplos de Diagramas Mermaid em Markdown

## Fluxograma
\`\`\`mermaid
graph TD
    A[Início] --> B{Decisão?}
    B -->|Sim| C[Processo]
    B -->|Não| D[Fim]
    C --> D
\`\`\`

## Diagrama de Sequência
\`\`\`mermaid
sequenceDiagram
    participant A as Usuário
    participant B as Sistema
    A->>B: Login
    B->>A: Resposta
    A->>B: Dados
    B->>A: Confirmação
\`\`\`

## Diagrama de Classe
\`\`\`mermaid
classDiagram
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
    Animal <|-- Cat
\`\`\`

## Diagrama ER
\`\`\`mermaid
erDiagram
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
    }
\`\`\`

## Gantt Chart
\`\`\`mermaid
gantt
    title Cronograma do Projeto
    dateFormat  YYYY-MM-DD
    section Fase 1
    Tarefa 1           :done,    des1, 2024-01-01, 2024-01-05
    Tarefa 2           :active,  des2, 2024-01-06, 2024-01-10
    section Fase 2
    Tarefa 3           :         des3, 2024-01-11, 2024-01-15
\`\`\`

## Gráfico de Pizza
\`\`\`mermaid
pie title Distribuição de Vendas
    "Produto A" : 30
    "Produto B" : 25
    "Produto C" : 20
    "Produto D" : 15
    "Produto E" : 10
\`\`\`

## Mapa Mental
\`\`\`mermaid
mindmap
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
      Hive
\`\`\`
''';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview Markdown com Mermaid',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 600,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: EnhancedMarkdownPreviewWidget(
            markdown: markdownExample,
            enableHtmlEnhancements: true,
          ),
        ),
      ],
    );
  }
}
