import 'package:flutter/material.dart';

/// Enum para linguagens de programação suportadas nos blocos de código
enum ProgrammingLanguage {
  dart('dart', 'Dart', '🎯'),
  python('python', 'Python', '🐍'),
  javascript('javascript', 'JavaScript', '🟨'),
  typescript('typescript', 'TypeScript', '🟦'),
  java('java', 'Java', '☕'),
  csharp('csharp', 'C#', '♯'),
  cpp('cpp', 'C++', '➕'),
  c('c', 'C', '🅲'),
  go('go', 'Go', '💙'),
  rust('rust', 'Rust', '🦀'),
  php('php', 'PHP', '🐘'),
  ruby('ruby', 'Ruby', '💎'),
  swift('swift', 'Swift', '🦅'),
  kotlin('kotlin', 'Kotlin', '🟪'),
  html('html', 'HTML', '🌐'),
  css('css', 'CSS', '🎨'),
  json('json', 'JSON', '🔢'),
  yaml('yaml', 'YAML', '📄'),
  markdown('markdown', 'Markdown', '📝'),
  shell('shell', 'Shell', '💻'),
  sql('sql', 'SQL', '🗄️'),
  text('text', 'Texto', '📄');

  final String code;
  final String displayName;
  final String icon;
  const ProgrammingLanguage(this.code, this.displayName, this.icon);

  static ProgrammingLanguage get defaultLanguage => ProgrammingLanguage.text;

  static List<ProgrammingLanguage> get languages => ProgrammingLanguage.values;

  static ProgrammingLanguage? getByCode(String code) {
    try {
      return ProgrammingLanguage.values.firstWhere((lang) => lang.code == code);
    } catch (_) {
      return null;
    }
  }
}

/// Tema para blocos de código
class CodeTheme {
  final String name;
  final String displayName;
  final Color backgroundColor;
  final Color textColor;
  final Color commentColor;
  final Color keywordColor;
  final Color stringColor;
  final Color numberColor;
  final Color functionColor;
  final Color classColor;
  final Color operatorColor;
  final Color punctuationColor;
  final Color lineNumberColor;
  final Color lineNumberBackgroundColor;
  final Color borderColor;
  final Color headerBackgroundColor;
  final Color headerTextColor;

  const CodeTheme({
    required this.name,
    required this.displayName,
    required this.backgroundColor,
    required this.textColor,
    required this.commentColor,
    required this.keywordColor,
    required this.stringColor,
    required this.numberColor,
    required this.functionColor,
    required this.classColor,
    required this.operatorColor,
    required this.punctuationColor,
    required this.lineNumberColor,
    required this.lineNumberBackgroundColor,
    required this.borderColor,
    required this.headerBackgroundColor,
    required this.headerTextColor,
  });

  /// Temas predefinidos
  static const List<CodeTheme> themes = [
    // Dark themes
    dracula,
    monokai,
    oneDark,
    nightOwl,
    materialOcean,
    palenight,
    synthwave,
    tokyoNight,

    // Light themes
    github,
    solarizedLight,
    xcode,
    vsCode,
    atom,
    sublime,
  ];

  // Dark Themes
  static const dracula = CodeTheme(
    name: 'dracula',
    displayName: 'Dracula',
    backgroundColor: Color(0xFF282A36),
    textColor: Color(0xFFF8F8F2),
    commentColor: Color(0xFF6272A4),
    keywordColor: Color(0xFFFF79C6),
    stringColor: Color(0xFFF1FA8C),
    numberColor: Color(0xFFBD93F9),
    functionColor: Color(0xFF50FA7B),
    classColor: Color(0xFF8BE9FD),
    operatorColor: Color(0xFFFF79C6),
    punctuationColor: Color(0xFFF8F8F2),
    lineNumberColor: Color(0xFF6272A4),
    lineNumberBackgroundColor: Color(0xFF21222C),
    borderColor: Color(0xFF44475A),
    headerBackgroundColor: Color(0xFF21222C),
    headerTextColor: Color(0xFFF8F8F2),
  );

  static const monokai = CodeTheme(
    name: 'monokai',
    displayName: 'Monokai',
    backgroundColor: Color(0xFF272822),
    textColor: Color(0xFFF8F8F2),
    commentColor: Color(0xFF75715E),
    keywordColor: Color(0xFFF92672),
    stringColor: Color(0xFFE6DB74),
    numberColor: Color(0xFFAE81FF),
    functionColor: Color(0xFFA6E22E),
    classColor: Color(0xFF66D9EF),
    operatorColor: Color(0xFFF92672),
    punctuationColor: Color(0xFFF8F8F2),
    lineNumberColor: Color(0xFF75715E),
    lineNumberBackgroundColor: Color(0xFF1D1E19),
    borderColor: Color(0xFF3E3D32),
    headerBackgroundColor: Color(0xFF1D1E19),
    headerTextColor: Color(0xFFF8F8F2),
  );

  static const oneDark = CodeTheme(
    name: 'oneDark',
    displayName: 'One Dark',
    backgroundColor: Color(0xFF282C34),
    textColor: Color(0xFFABB2BF),
    commentColor: Color(0xFF5C6370),
    keywordColor: Color(0xFFC678DD),
    stringColor: Color(0xFF98C379),
    numberColor: Color(0xFFD19A66),
    functionColor: Color(0xFF61AFEF),
    classColor: Color(0xFFE5C07B),
    operatorColor: Color(0xFF56B6C2),
    punctuationColor: Color(0xFFABB2BF),
    lineNumberColor: Color(0xFF5C6370),
    lineNumberBackgroundColor: Color(0xFF21252B),
    borderColor: Color(0xFF3E4451),
    headerBackgroundColor: Color(0xFF21252B),
    headerTextColor: Color(0xFFABB2BF),
  );

  static const nightOwl = CodeTheme(
    name: 'nightOwl',
    displayName: 'Night Owl',
    backgroundColor: Color(0xFF011627),
    textColor: Color(0xFFD6DEEB),
    commentColor: Color(0xFF637777),
    keywordColor: Color(0xFFC792EA),
    stringColor: Color(0xFFECC48D),
    numberColor: Color(0xFFF78C6C),
    functionColor: Color(0xFF82AAFF),
    classColor: Color(0xFFFFCB8B),
    operatorColor: Color(0xFFC792EA),
    punctuationColor: Color(0xFFD6DEEB),
    lineNumberColor: Color(0xFF637777),
    lineNumberBackgroundColor: Color(0xFF01111D),
    borderColor: Color(0xFF1D3B53),
    headerBackgroundColor: Color(0xFF01111D),
    headerTextColor: Color(0xFFD6DEEB),
  );

  static const materialOcean = CodeTheme(
    name: 'materialOcean',
    displayName: 'Material Ocean',
    backgroundColor: Color(0xFF0F111A),
    textColor: Color(0xFFA6ACCD),
    commentColor: Color(0xFF464B5D),
    keywordColor: Color(0xFFC792EA),
    stringColor: Color(0xFFC3E88D),
    numberColor: Color(0xFFF78C6C),
    functionColor: Color(0xFF82AAFF),
    classColor: Color(0xFFFFCB6B),
    operatorColor: Color(0xFF89DDFF),
    punctuationColor: Color(0xFFA6ACCD),
    lineNumberColor: Color(0xFF464B5D),
    lineNumberBackgroundColor: Color(0xFF0A0A0F),
    borderColor: Color(0xFF292D3E),
    headerBackgroundColor: Color(0xFF0A0A0F),
    headerTextColor: Color(0xFFA6ACCD),
  );

  static const palenight = CodeTheme(
    name: 'palenight',
    displayName: 'Palenight',
    backgroundColor: Color(0xFF292D3E),
    textColor: Color(0xFFA6ACCD),
    commentColor: Color(0xFF676E95),
    keywordColor: Color(0xFFC792EA),
    stringColor: Color(0xFFC3E88D),
    numberColor: Color(0xFFF78C6C),
    functionColor: Color(0xFF82AAFF),
    classColor: Color(0xFFFFCB6B),
    operatorColor: Color(0xFF89DDFF),
    punctuationColor: Color(0xFFA6ACCD),
    lineNumberColor: Color(0xFF676E95),
    lineNumberBackgroundColor: Color(0xFF1F1D2E),
    borderColor: Color(0xFF3E4254),
    headerBackgroundColor: Color(0xFF1F1D2E),
    headerTextColor: Color(0xFFA6ACCD),
  );

  static const synthwave = CodeTheme(
    name: 'synthwave',
    displayName: 'Synthwave',
    backgroundColor: Color(0xFF2D1B69),
    textColor: Color(0xFFE2E1E6),
    commentColor: Color(0xFF6E6B5E),
    keywordColor: Color(0xFFF4F4F5),
    stringColor: Color(0xFFF9C846),
    numberColor: Color(0xFFFF7EDB),
    functionColor: Color(0xFF72F1B8),
    classColor: Color(0xFFF4F4F5),
    operatorColor: Color(0xFFF4F4F5),
    punctuationColor: Color(0xFFE2E1E6),
    lineNumberColor: Color(0xFF6E6B5E),
    lineNumberBackgroundColor: Color(0xFF1A103D),
    borderColor: Color(0xFF3B2A5A),
    headerBackgroundColor: Color(0xFF1A103D),
    headerTextColor: Color(0xFFE2E1E6),
  );

  static const tokyoNight = CodeTheme(
    name: 'tokyoNight',
    displayName: 'Tokyo Night',
    backgroundColor: Color(0xFF1A1B26),
    textColor: Color(0xFFA9B1D6),
    commentColor: Color(0xFF565A6E),
    keywordColor: Color(0xFFBB9AF7),
    stringColor: Color(0xFF9ECE6A),
    numberColor: Color(0xFFFF9E64),
    functionColor: Color(0xFF7AA2F7),
    classColor: Color(0xFFF7768E),
    operatorColor: Color(0xFF89DDFF),
    punctuationColor: Color(0xFFA9B1D6),
    lineNumberColor: Color(0xFF565A6E),
    lineNumberBackgroundColor: Color(0xFF16161E),
    borderColor: Color(0xFF292E42),
    headerBackgroundColor: Color(0xFF16161E),
    headerTextColor: Color(0xFFA9B1D6),
  );

  // Light Themes
  static const github = CodeTheme(
    name: 'github',
    displayName: 'GitHub',
    backgroundColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF24292E),
    commentColor: Color(0xFF6A737D),
    keywordColor: Color(0xFFD73A49),
    stringColor: Color(0xFF032F62),
    numberColor: Color(0xFF005CC5),
    functionColor: Color(0xFF6F42C1),
    classColor: Color(0xFFE36209),
    operatorColor: Color(0xFFD73A49),
    punctuationColor: Color(0xFF24292E),
    lineNumberColor: Color(0xFF6A737D),
    lineNumberBackgroundColor: Color(0xFFF6F8FA),
    borderColor: Color(0xFFE1E4E8),
    headerBackgroundColor: Color(0xFFF6F8FA),
    headerTextColor: Color(0xFF24292E),
  );

  static const solarizedLight = CodeTheme(
    name: 'solarizedLight',
    displayName: 'Solarized Light',
    backgroundColor: Color(0xFFFDF6E3),
    textColor: Color(0xFF586E75),
    commentColor: Color(0xFF93A1A1),
    keywordColor: Color(0xFF859900),
    stringColor: Color(0xFF2AA198),
    numberColor: Color(0xFFD33682),
    functionColor: Color(0xFF268BD2),
    classColor: Color(0xFFB58900),
    operatorColor: Color(0xFF859900),
    punctuationColor: Color(0xFF586E75),
    lineNumberColor: Color(0xFF93A1A1),
    lineNumberBackgroundColor: Color(0xFFEEE8D5),
    borderColor: Color(0xFF93A1A1),
    headerBackgroundColor: Color(0xFFEEE8D5),
    headerTextColor: Color(0xFF586E75),
  );

  static const xcode = CodeTheme(
    name: 'xcode',
    displayName: 'Xcode',
    backgroundColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF000000),
    commentColor: Color(0xFF008000),
    keywordColor: Color(0xFF0000FF),
    stringColor: Color(0xFFA31515),
    numberColor: Color(0xFF098658),
    functionColor: Color(0xFF795E26),
    classColor: Color(0xFF267f99),
    operatorColor: Color(0xFF000000),
    punctuationColor: Color(0xFF000000),
    lineNumberColor: Color(0xFF2B91AF),
    lineNumberBackgroundColor: Color(0xFFF5F5F5),
    borderColor: Color(0xFFE1E1E1),
    headerBackgroundColor: Color(0xFFF5F5F5),
    headerTextColor: Color(0xFF000000),
  );

  static const vsCode = CodeTheme(
    name: 'vsCode',
    displayName: 'VS Code',
    backgroundColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF000000),
    commentColor: Color(0xFF008000),
    keywordColor: Color(0xFF0000FF),
    stringColor: Color(0xFFA31515),
    numberColor: Color(0xFF098658),
    functionColor: Color(0xFF795E26),
    classColor: Color(0xFF267f99),
    operatorColor: Color(0xFF000000),
    punctuationColor: Color(0xFF000000),
    lineNumberColor: Color(0xFF858585),
    lineNumberBackgroundColor: Color(0xFFF3F3F3),
    borderColor: Color(0xFFCCCCCC),
    headerBackgroundColor: Color(0xFFF3F3F3),
    headerTextColor: Color(0xFF000000),
  );

  static const atom = CodeTheme(
    name: 'atom',
    displayName: 'Atom',
    backgroundColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF2D3748),
    commentColor: Color(0xFF718096),
    keywordColor: Color(0xFF805AD5),
    stringColor: Color(0xFF38A169),
    numberColor: Color(0xFFE53E3E),
    functionColor: Color(0xFF3182CE),
    classColor: Color(0xFFD69E2E),
    operatorColor: Color(0xFF2D3748),
    punctuationColor: Color(0xFF2D3748),
    lineNumberColor: Color(0xFFA0AEC0),
    lineNumberBackgroundColor: Color(0xFFF7FAFC),
    borderColor: Color(0xFFE2E8F0),
    headerBackgroundColor: Color(0xFFF7FAFC),
    headerTextColor: Color(0xFF2D3748),
  );

  static const sublime = CodeTheme(
    name: 'sublime',
    displayName: 'Sublime',
    backgroundColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF000000),
    commentColor: Color(0xFF008000),
    keywordColor: Color(0xFF0000FF),
    stringColor: Color(0xFFA31515),
    numberColor: Color(0xFF098658),
    functionColor: Color(0xFF795E26),
    classColor: Color(0xFF267f99),
    operatorColor: Color(0xFF000000),
    punctuationColor: Color(0xFF000000),
    lineNumberColor: Color(0xFF2B91AF),
    lineNumberBackgroundColor: Color(0xFFF5F5F5),
    borderColor: Color(0xFFE1E1E1),
    headerBackgroundColor: Color(0xFFF5F5F5),
    headerTextColor: Color(0xFF000000),
  );

  /// Obter tema por nome
  static CodeTheme? getByName(String name) {
    try {
      return themes.firstWhere((theme) => theme.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Obter tema padrão (Dracula)
  static CodeTheme get defaultTheme => dracula;

  /// Obter tema padrão para código sem linguagem especificada
  static CodeTheme get defaultCodeTheme => github;

  /// Detectar linguagem de programação a partir do conteúdo do código
  static ProgrammingLanguage detectLanguageFromContent(String code) {
    // Detectar por padrões específicos no código
    if (code.contains('import ') && code.contains('package:flutter')) {
      return ProgrammingLanguage.getByCode('dart') ??
          ProgrammingLanguage.defaultLanguage;
    }

    if (code.contains('function ') ||
        code.contains('const ') ||
        code.contains('let ') ||
        code.contains('var ') ||
        code.contains('console.log')) {
      return ProgrammingLanguage.getByCode('javascript') ??
          ProgrammingLanguage.defaultLanguage;
    }

    if (code.contains('def ') ||
        code.contains('import ') ||
        code.contains('print(') ||
        code.contains('if __name__')) {
      return ProgrammingLanguage.getByCode('python') ??
          ProgrammingLanguage.defaultLanguage;
    }

    if (code.contains('public class ') ||
        code.contains('public static void main')) {
      return ProgrammingLanguage.getByCode('java') ??
          ProgrammingLanguage.defaultLanguage;
    }

    if (code.contains('using System;') || code.contains('namespace ')) {
      return ProgrammingLanguage.getByCode('csharp') ??
          ProgrammingLanguage.defaultLanguage;
    }

    if (code.contains('<?php') || code.contains('echo ')) {
      return ProgrammingLanguage.getByCode('php') ??
          ProgrammingLanguage.defaultLanguage;
    }

    if (code.contains('package ') || code.contains('func main()')) {
      return ProgrammingLanguage.getByCode('go') ??
          ProgrammingLanguage.defaultLanguage;
    }

    if (code.contains('fn main()') || code.contains('let mut ')) {
      return ProgrammingLanguage.getByCode('rust') ??
          ProgrammingLanguage.defaultLanguage;
    }

    if (code.contains('#include ') || code.contains('int main()')) {
      return ProgrammingLanguage.getByCode('c') ??
          ProgrammingLanguage.defaultLanguage;
    }

    if (code.contains('class ') &&
        code.contains('public:') &&
        code.contains('std::')) {
      return ProgrammingLanguage.getByCode('cpp') ??
          ProgrammingLanguage.defaultLanguage;
    }

    if (code.contains('{') && code.contains('"') && code.contains(':')) {
      return ProgrammingLanguage.getByCode('json') ??
          ProgrammingLanguage.defaultLanguage;
    }

    if (code.contains('<') && code.contains('>') && code.contains('</')) {
      return ProgrammingLanguage.getByCode('xml') ??
          ProgrammingLanguage.defaultLanguage;
    }

    if (code.contains('SELECT ') ||
        code.contains('INSERT ') ||
        code.contains('CREATE TABLE')) {
      return ProgrammingLanguage.getByCode('sql') ??
          ProgrammingLanguage.defaultLanguage;
    }

    if (code.contains('#!/bin/bash') ||
        code.contains('echo ') ||
        code.contains('\$')) {
      return ProgrammingLanguage.getByCode('bash') ??
          ProgrammingLanguage.defaultLanguage;
    }

    // Padrão genérico para texto
    return ProgrammingLanguage.getByCode('text') ??
        ProgrammingLanguage.defaultLanguage;
  }

  // Adiciona utilitário para fundo adaptativo
  static Color adaptiveBackground(BuildContext context,
      {double opacity = 0.95}) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.black.withOpacity(opacity)
        : Colors.white.withOpacity(opacity);
  }
}

class LanguageSyntax {
  final RegExp keywordPattern;
  final RegExp variablePattern;
  final RegExp stringPattern;
  final RegExp numberPattern;
  final RegExp commentPattern;
  final RegExp functionPattern;
  final RegExp classPattern;
  final RegExp operatorPattern;
  final RegExp punctuationPattern;

  const LanguageSyntax({
    required this.keywordPattern,
    required this.variablePattern,
    required this.stringPattern,
    required this.numberPattern,
    required this.commentPattern,
    required this.functionPattern,
    required this.classPattern,
    required this.operatorPattern,
    required this.punctuationPattern,
  });
}

// Sintaxes por linguagem
final Map<String, LanguageSyntax> _languageSyntaxes = {
  'python': LanguageSyntax(
    keywordPattern: RegExp(
        r'\b(def|class|if|else|elif|for|while|return|import|from|as|with|try|except|finally|raise|pass|break|continue|lambda|yield|global|nonlocal|assert|del|in|is|not|or|and)\b'),
    variablePattern: RegExp(r'\b[a-zA-Z_][a-zA-Z0-9_]*\b'),
    stringPattern: RegExp(
        r"""'''(?:[^'\\]|\\.)*'''|\"\"\"(?:[^"\\]|\\.)*\"\"\"|'(?:[^'\\]|\\.)*'|"(?:[^"\\]|\\.)*" """),
    numberPattern: RegExp(r'\b\d+\.?\d*\b'),
    commentPattern: RegExp(r'#.*'),
    functionPattern: RegExp(r'\bdef ([a-zA-Z_][a-zA-Z0-9_]*)'),
    classPattern: RegExp(r'\bclass ([a-zA-Z_][a-zA-Z0-9_]*)'),
    operatorPattern: RegExp(r'[+\-*/%=<>!&|^~]'),
    punctuationPattern: RegExp(r'[(){}\[\];:,.]'),
  ),
  'javascript': LanguageSyntax(
    keywordPattern: RegExp(
        r'\b(const|let|var|function|return|if|else|for|while|class|export|import|async|await|new|this|super|extends|try|catch|finally|throw|break|continue|switch|case|default|typeof|instanceof|in|of|do|void|delete)\b'),
    variablePattern: RegExp(r'\b[a-zA-Z_\$][a-zA-Z0-9_\$]*\b'),
    stringPattern: RegExp(
        r"""'''(?:[^'\\]|\\.)*'''|\"\"\"(?:[^"\\]|\\.)*\"\"\"|'(?:[^'\\]|\\.)*'|"(?:[^"\\]|\\.)*" """),
    numberPattern: RegExp(r'\b\d+\.?\d*\b'),
    commentPattern: RegExp(r'//.*|/\*[\s\S]*?\*/'),
    functionPattern: RegExp(r'\bfunction ([a-zA-Z_\$][a-zA-Z0-9_\$]*)'),
    classPattern: RegExp(r'\bclass ([a-zA-Z_\$][a-zA-Z0-9_\$]*)'),
    operatorPattern: RegExp(r'[+\-*/%=<>!&|^~]'),
    punctuationPattern: RegExp(r'[(){}\[\];:,.]'),
  ),
  // Fallback genérico
  'text': LanguageSyntax(
    keywordPattern: RegExp(r''),
    variablePattern: RegExp(r''),
    stringPattern: RegExp(r''),
    numberPattern: RegExp(r''),
    commentPattern: RegExp(r''),
    functionPattern: RegExp(r''),
    classPattern: RegExp(r''),
    operatorPattern: RegExp(r''),
    punctuationPattern: RegExp(r''),
  ),
};

extension CodeThemeSyntaxExt on CodeTheme {
  static LanguageSyntax getSyntax(String languageCode) {
    return _languageSyntaxes[languageCode] ?? _languageSyntaxes['javascript']!;
  }
}
