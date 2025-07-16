/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

class PageTemplatesPt {
  static const String rootPageTemplate =
      '''# 📊 Documento Markdown Completo com Todas as Funcionalidades

## 🎨 Demonstração de Cores e Formatação

Este documento exemplifica **todas as principais funcionalidades** do Markdown, incluindo <span style="color:red; background-color:#ffeeee; padding:2px 5px; border-radius:3px">**cores personalizadas**</span> e formatação avançada

### Exemplos de Texto <span style="background-color:#0000FF; color:#FFFFFF">Colorido</span>

Aqui temos diferentes estilos de texto:

- <span style="color:red">**Texto vermelho em negrito**</span>
- <span style="color:blue; font-style:italic">Texto azul em itálico</span>
- <span style="color:white; background-color:green; padding:3px 8px; border-radius:5px">✅ Sucesso</span>
- <span style="color:white; background-color:red; padding:3px 8px; border-radius:5px">❌ Erro</span>
- <span style="color:orange; background-color:#fff3cd; padding:3px 8px; border-radius:5px">⚠️ Aviso</span>


## 📝 Hierarquia de Títulos

# Título Nível 1

## Título Nível 2

### Título Nível 3

#### Título Nível 4

##### Título Nível 5

###### Título Nível 6

### Títulos Alternativos

Título Principal
===============

Subtítulo
---------

## 💻 Exemplos de Código

### Código Python

```python
def calcular_fibonacci(n):
    """Calcula a sequência de Fibonacci até n termos"""
    if n <= 0:
        return []
    elif n == 1:
        return [0]
    elif n == 2:
        return [0, 1]
    
    fib = [0, 1]
    for i in range(2, n):
        fib.append(fib[i-1] + fib[i-2])
    
    return fib

# Exemplo de uso
resultado = calcular_fibonacci(10)
```


### Código JavaScript

```javascript
// Classe para gerenciar usuários
class UsuarioManager {
    constructor() {
        this.usuarios = [];
    }
    
    adicionarUsuario(nome, email) {
        const usuario = {
            id: Date.now(),
            nome: nome,
            email: email,
            ativo: true
        };
        this.usuarios.push(usuario);
        return usuario;
    }
    
    buscarUsuario(id) {
        return this.usuarios.find(u => u.id === id);
    }
}

// Uso da classe
const manager = new UsuarioManager();
const novoUsuario = manager.adicionarUsuario("João", "joao@email.com");
console.log(novoUsuario);
```


### Código SQL

```sql
-- Criação de tabela e consultas avançadas
CREATE TABLE vendas (
    id SERIAL PRIMARY KEY,
    produto VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2),
    data_venda DATE,
    vendedor_id INTEGER
);

-- Consulta com agregações
SELECT 
    vendedor_id,
    COUNT(*) as total_vendas,
    SUM(preco) as receita_total,
    AVG(preco) as preco_medio,
    MAX(data_venda) as ultima_venda
FROM vendas 
WHERE data_venda >= '2025-01-01'
GROUP BY vendedor_id
HAVING SUM(preco) > 1000
ORDER BY receita_total DESC;
```


### Código Inline

Para executar o script, use o comando <span style="color:white; background-color:black; padding:2px 5px; border-radius:3px; font-family:monospace">python app.py</span> no terminal.

## 🔢 Fórmulas Matemáticas (LaTeX)

### Fórmulas Inline

A famosa equação de Einstein: \$E = mc^2\$

A fórmula quadrática: \$x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}\$

### Fórmulas em Bloco

Integral definida:

\$
\\int_a^b f(x) \\, dx = F(b) - F(a)
\$

Somatório:

\$
\\sum_{i=1}^{n} i = \\frac{n(n+1)}{2}
\$

### Matrizes

\$\\begin{pmatrix} a & b \\\\ c & d \\end{pmatrix}\$

## 📊 Tabelas Avançadas

### Tabela de Vendas Mensais

| Mês | Vendas | Meta | <span style="color:green">%Atingido</span> | Status |
| :-- | :-- | :-- | :-- | :-- |
| Janeiro | €15.000 | €12.000 | <span style="color:green; font-weight:bold">125%</span> | <span style="color:white; background-color:green; padding:2px 6px; border-radius:3px">✅ Superou</span> |
| Fevereiro | €10.500 | €12.000 | <span style="color:orange; font-weight:bold">87.5%</span> | <span style="color:white; background-color:orange; padding:2px 6px; border-radius:3px">⚠️ Abaixo</span> |
| Março | €14.200 | €12.000 | <span style="color:green; font-weight:bold">118%</span> | <span style="color:white; background-color:green; padding:2px 6px; border-radius:3px">✅ Superou</span> |

## 📋 Listas e Tarefas

### Lista de Tarefas do Projeto

- [x] <span style="color:green">**Análise de requisitos**</span> ✅
- [x] <span style="color:green">**Design da interface**</span> ✅
- [ ] <span style="color:orange">**Desenvolvimento backend**</span> 🔄
    - [x] Configuração do banco de dados
    - [x] API de autenticação
    - [ ] API de usuários
    - [ ] API de relatórios
- [ ] <span style="color:red">**Testes**</span> ⏳
- [ ] <span style="color:red">**Deploy**</span> ⏳

## 📈 Diagramas

### Fluxograma do Processo

```mermaid
graph TD
    A[Início] --> B{Login válido?}
    B -->|Sim| C[Dashboard]
    B -->|Não| D[Tela de erro]
    C --> E{Tipo de usuário?}
    E -->|Admin| F[Painel Admin]
    E -->|User| G[Painel Usuário]
    F --> H[Relatórios]
    G --> I[Perfil]
    H --> J[Fim]
    I --> J
    D --> A
```

## 💬 Citações e Destaques

### Citação Simples

> "A melhor forma de prever o futuro é criá-lo."
> — Peter Drucker

### Caixa de Destaque

<span style="background-color:#e1f5fe; border-left:4px solid #0277bd; padding:10px; display:block; margin:10px 0;">
<strong>💡 Dica Importante:</strong><br>
Sempre faça backup dos seus dados antes de realizar atualizações importantes no sistema.
</span>

## 🔗 Links e Referências

### Links Básicos

- [Documentação Markdown](https://www.markdownguide.org)
- [Mermaid Diagrams](https://mermaid.js.org/)
- [LaTeX Mathematics](https://katex.org/)

## 📝 Parágrafos e Formatação

### Texto com Formatação Mista

Este parágrafo demonstra **texto em negrito**, *texto em itálico*, ***texto em negrito e itálico***, ~~texto riscado~~, e `código inline`.

Também podemos ter <span style="color:blue; text-decoration:underline">texto sublinhado azul</span>, <span style="background-color:yellow">texto destacado</span>, e <span style="color:red; font-weight:bold">texto vermelho em negrito</span>.

## 🏁 Conclusão

Este documento demonstra a versatilidade e poder do Markdown quando combinado com HTML e outras tecnologias. Com essas técnicas, é possível criar documentação rica, colorida e interativa que vai muito além do texto simples.

<span style="background-color:#e8f5e8; border:1px solid #4caf50; border-radius:5px; padding:15px; display:block; margin:20px 0;">
<strong style="color:#2e7d32;">✅ Documento Completo</strong><br>
Este exemplo inclui todas as principais funcionalidades do Markdown moderno, servindo como referência completa para criação de documentos profissionais.
</span>

*Documento criado - Portugal* 🇵🇹
''';

  static const String newPageTemplate = '''# Nova Página

## Introdução

Bem-vindo à sua nova página! Aqui você pode começar a escrever seu conteúdo.

### O que você pode fazer:

- Escrever texto em **negrito** e *itálico*
- Criar listas
- Adicionar código
- Inserir fórmulas matemáticas
- Criar tabelas
- E muito mais!

### Exemplo de Código

```dart
void main() {
  // Olá, mundo!
}
```

### Lista de Tarefas

- [ ] Primeira tarefa
- [ ] Segunda tarefa
- [ ] Terceira tarefa

> **Dica:** Use o menu de formatação para adicionar mais elementos à sua página.
''';
}
