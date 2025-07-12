/// Constantes para ícones de páginas do Bloquinho
/// Lista unificada de emojis usados como ícones de páginas
class PageIcons {
  /// Lista principal de emojis disponíveis para seleção
  static const List<String> availableIcons = [
    '📄', // Documento
    '📝', // Nota
    '📋', // Lista
    '📚', // Livros
    '📖', // Livro aberto
    '📗', // Livro verde
    '📘', // Livro azul
    '📙', // Livro laranja
    '📓', // Caderno
    '📔', // Caderno decorado
    '📕', // Livro vermelho
    '📒', // Caderno espiral
    '📃', // Documento com linhas
    '📑', // Documentos empilhados
    '🔖', // Marcador
    '🏷️', // Etiqueta
    '📌', // Alfinete
    '📍', // Marcador de localização
    '🎯', // Alvo
    '💡', // Lâmpada (ideia)
    '💭', // Balão de pensamento
    '💬', // Balão de fala
    '🔍', // Lupa
    '🔎', // Lupa de busca
    '📊', // Gráfico de barras
    '📈', // Gráfico crescente
    '📉', // Gráfico decrescente
    '✅', // Check verde
    '❌', // X vermelho
    '⚠️', // Aviso
    'ℹ️', // Informação
    '🔔', // Sino
    '🔕', // Sino cortado
    '🔒', // Cadeado fechado
    '🔓', // Cadeado aberto
    '🔐', // Cadeado com chave
    '👋', // Onda (bem-vindo)
    '🧪', // Tubo de ensaio (teste)
    '🚀', // Foguete (projeto)
    '🤝', // Aperto de mãos (reunião)
    '💻', // Computador (código)
    '🎨', // Paleta (design)
  ];

  /// Ícone padrão para páginas sem ícone definido
  static const String defaultIcon = '📄';

  /// Mapeamento de palavras-chave para ícones específicos
  static const Map<String, String> keywordIcons = {
    'bem-vindo': '👋',
    'welcome': '👋',
    'teste': '🧪',
    'test': '🧪',
    'nota': '📝',
    'note': '📝',
    'projeto': '🚀',
    'project': '🚀',
    'tarefa': '✅',
    'task': '✅',
    'ideia': '💡',
    'idea': '💡',
    'reunião': '🤝',
    'meeting': '🤝',
    'documento': '📄',
    'document': '📄',
    'código': '💻',
    'code': '💻',
    'design': '🎨',
    'desenho': '🎨',
  };

  /// Obter ícone baseado em palavras-chave no título
  static String getIconForTitle(String title) {
    final lowerTitle = title.toLowerCase();

    // Verificar palavras-chave específicas
    for (final entry in keywordIcons.entries) {
      if (lowerTitle.contains(entry.key)) {
        return entry.value;
      }
    }

    return defaultIcon;
  }

  /// Verificar se um ícone é válido (está na lista disponível)
  static bool isValidIcon(String? icon) {
    if (icon == null) return false;
    return availableIcons.contains(icon);
  }

  /// Obter ícone válido ou padrão
  static String getValidIcon(String? icon) {
    if (isValidIcon(icon)) {
      return icon!;
    }
    return defaultIcon;
  }
}
