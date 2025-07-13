import 'package:flutter/material.dart';
import 'enhanced_markdown_preview_widget.dart';

/// Widget para demonstrar exemplos de formatação markdown com enhancements
class MarkdownExamplesWidget extends StatelessWidget {
  const MarkdownExamplesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemplos de Formatação'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: const MarkdownFormattingExamplesWidget(),
    );
  }
}

/// Widget com exemplos específicos de formatação
class MarkdownFormattingExamplesWidget extends StatelessWidget {
  const MarkdownFormattingExamplesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const examples = r'''
# 🎨 Exemplos de Formatação Avançada

## 🌈 Cores de Texto e Fundo
<span style="color:red; background-color:#ffeeee; padding:2px 5px; border-radius:3px">**Texto vermelho com fundo claro**</span>
<span style="color:white; background-color:green; padding:3px 8px; border-radius:5px">✅ Sucesso</span>
<span style="color:white; background-color:red; padding:3px 8px; border-radius:5px">❌ Erro</span>
<span style="color:orange; background-color:#fff3cd; padding:3px 8px; border-radius:5px">⚠️ Aviso</span>

## 🔢 Fórmulas Matemáticas (LaTeX)

**Inline:** A famosa equação de Einstein: $E = mc^2$

**Bloco:**
$$
\int_a^b f(x) \, dx = F(b) - F(a)
$$

## 📈 Diagramas (Mermaid)

```mermaid
graph TD
    A[Início] --> B{Login válido?}
    B -->|Sim| C[Dashboard]
    B -->|Não| D[Tela de erro]
```

## 🛠️ Elementos HTML Avançados

### Detalhes Expansíveis
<details>
<summary><strong>Clique para ver os requisitos</strong></summary>

- **Sistema Operacional:** Windows 10+
- **RAM:** 8GB+

</details>

### Teclas e Atalhos
Para salvar, pressione <kbd>Ctrl</kbd> + <kbd>S</kbd>

### Texto Especial
H<sub>2</sub>O e E=mc<sup>2</sup>
<mark>Texto destacado</mark>

### Barra de Progresso
<div style="background-color:#f0f0f0; border-radius:10px; padding:3px; margin:10px 0;">
<div style="background-color:#28a745; width:75%; height:20px; border-radius:8px; display:flex; align-items:center; justify-content:center; color:white; font-weight:bold; font-size:12px;">
75% Completo
</div>
</div>

''';

    return EnhancedMarkdownPreviewWidget(
      markdown: examples,
      enableHtmlEnhancements: true,
      padding: const EdgeInsets.all(16.0),
    );
  }
}
