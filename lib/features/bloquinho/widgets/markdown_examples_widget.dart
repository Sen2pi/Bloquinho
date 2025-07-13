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
    const examples = '''
# 🎨 Exemplos de Formatação Avançada

## 🌈 Cores de Texto
<color value="red">Texto vermelho</color>
<color value="blue">Texto azul</color>
<color value="green">Texto verde</color>
<color value="purple">Texto roxo</color>
<color value="orange">Texto laranja</color>
<color value="pink">Texto rosa</color>

## 🎨 Cores de Fundo
<bg color="yellow">Texto com fundo amarelo</bg>
<bg color="lightblue">Texto com fundo azul claro</bg>
<bg color="lightgreen">Texto com fundo verde claro</bg>
<bg color="lightgrey">Texto com fundo cinza claro</bg>

## 📐 Alinhamento de Texto
<align value="left">Texto alinhado à esquerda</align>

<align value="center">Texto centralizado</align>

<align value="right">Texto alinhado à direita</align>

<align value="justify">Texto justificado que ocupa toda a largura disponível para demonstrar o alinhamento</align>

## 🎭 Combinações Avançadas
<color value="white"><bg color="red">Texto branco com fundo vermelho</bg></color>

<align value="center"><color value="blue">Texto azul centralizado</color></align>

<bg color="yellow"><align value="right"><color value="black">Texto preto com fundo amarelo alinhado à direita</color></align></bg>

<color value="purple"><bg color="lightgrey"><align value="center">Texto roxo com fundo cinza centralizado</align></bg></color>

## 📝 Markdown Padrão
**Texto em negrito**
*Texto em itálico*
~~Texto riscado~~
`código inline`

### 📋 Lista
- Item 1
- Item 2
- Item 3

### 💻 Código
```dart
void main() {
  print('Hello World!');
  // Comentário
}
```

### 💬 Citação
> Esta é uma citação de exemplo
> com múltiplas linhas
> para demonstrar a formatação

### 📊 Tabela
| Coluna 1 | Coluna 2 | Coluna 3 |
|----------|----------|----------|
| Dado 1   | Dado 2   | Dado 3   |
| Dado 4   | Dado 5   | Dado 6   |

## 🎯 Como Usar

### 1. Cores de Texto
Use a sintaxe: `<color value="nome_da_cor">texto</color>`

Cores disponíveis:
- red, blue, green, yellow, purple, orange, pink, brown, grey, black, white

### 2. Cores de Fundo
Use a sintaxe: `<bg color="bg-nome_da_cor">texto</bg>`

Cores disponíveis:
- bg-red, bg-blue, bg-green, bg-yellow, bg-purple, bg-orange, bg-pink, bg-brown, bg-grey, bg-black, bg-white

### 3. Alinhamento
Use a sintaxe: `<align value="tipo">texto</align>`

Tipos disponíveis:
- left, center, right, justify

### 4. Combinações
Você pode combinar múltiplas formatações:
```markdown
<color value="white"><bg color="red"><align value="center">Texto formatado</align></bg></color>
```

## 🚀 Funcionalidades

✅ **Cores de texto** - 20 cores predefinidas
✅ **Cores de fundo** - 20 cores predefinidas
✅ **Alinhamento** - 4 tipos (esquerda, centro, direita, justificado)
✅ **Combinações** - Suporte a múltiplas tags aninhadas
✅ **Markdown padrão** - Compatibilidade total
✅ **Performance** - Parsing otimizado
✅ **Temas** - Suporte a tema claro/escuro

## 🎨 Paleta de Cores

### Cores de Texto
<color value="red">Vermelho</color> <color value="blue">Azul</color> <color value="green">Verde</color>
<color value="yellow">Amarelo</color> <color value="purple">Roxo</color> <color value="orange">Laranja</color>
<color value="pink">Rosa</color> <color value="brown">Marrom</color> <color value="grey">Cinza</color>

### Cores de Fundo
<bg color="red">Vermelho</bg> <bg color="blue">Azul</bg> <bg color="green">Verde</bg>
<bg color="yellow">Amarelo</bg> <bg color="purple">Roxo</bg> <bg color="orange">Laranja</bg>
<bg color="pink">Rosa</bg> <bg color="brown">Marrom</bg> <bg color="grey">Cinza</bg>
''';

    return EnhancedMarkdownPreviewWidget(
      markdown: examples,
      enableHtmlEnhancements: true,
      padding: const EdgeInsets.all(16.0),
    );
  }
}
