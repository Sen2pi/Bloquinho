/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/html_enhancement_parser.dart';
import 'advanced_code_block.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
// Se quiser suporte avançado, pode trocar para:
// import 'package:flutter_markdown_selectionarea/flutter_markdown.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dynamic_colored_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'simple_diagram_widget.dart';
import 'windows_code_block_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'latex_widget.dart';
import 'mermaid_diagram_widget.dart'; // Adicionar import para WindowsMermaidDiagramWidget
import '../../../core/utils/lru_cache.dart';
import '../../../core/services/enhanced_markdown_parser.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'dart:io';

import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

/// Widget de visualização markdown com enhancements HTML moderno
class EnhancedMarkdownPreviewWidget extends ConsumerWidget {
  final String markdown;
  final bool showLineNumbers;
  final bool enableHtmlEnhancements;
  final TextStyle? baseTextStyle;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final bool showScrollbar;
  final ScrollPhysics? scrollPhysics;
  
  // Screenshot controller para capturar o widget
  static final ScreenshotController _screenshotController = ScreenshotController();
  
  // ScrollController para controlar o scroll durante a captura
  static final ScrollController _scrollController = ScrollController();

  // Cache otimizado para markdown processado
  static final LRUCache<int, String> _markdownCache = LRUCache(maxSize: 100);
  static final LRUCache<int, Widget> _widgetCache = LRUCache(maxSize: 50);

  const EnhancedMarkdownPreviewWidget({
    super.key,
    required this.markdown,
    this.showLineNumbers = false,
    this.enableHtmlEnhancements = true,
    this.baseTextStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
    this.backgroundColor,
    this.showScrollbar = true,
    this.scrollPhysics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textStyle = baseTextStyle ?? theme.textTheme.bodyMedium!;
    final isDark = theme.brightness == Brightness.dark;
    final containerColor =
        backgroundColor ?? (isDark ? Colors.transparent : Colors.white);

    // Não usar cache para o widget com Screenshot para evitar problemas
    final widget = Screenshot(
      controller: _screenshotController,
      child: RepaintBoundary(
        child: Container(
          color: containerColor,
          child: Stack(
            children: [
              Scrollbar(
                controller: _scrollController,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: padding,
                      sliver: SliverToBoxAdapter(
                        child: SelectionArea(
                          child: _buildOptimizedMarkdown(context, textStyle, ref),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Botão de cópia formatada
              _buildOptimizedActionButtons(context, isDark, ref),
            ],
          ),
        ),
      ),
    );

    return widget;
  }

  /// Gerar chave de cache para widget
  int _generateWidgetCacheKey(bool isDark) {
    return Object.hash(
      markdown.hashCode,
      showLineNumbers.hashCode,
      enableHtmlEnhancements.hashCode,
      baseTextStyle.hashCode,
      backgroundColor.hashCode,
      isDark.hashCode,
    );
  }

  /// Botões de ação otimizados com RepaintBoundary
  Widget _buildOptimizedActionButtons(
      BuildContext context, bool isDark, WidgetRef ref) {
    return Positioned(
      top: 8,
      right: 8,
      child: RepaintBoundary(
        child: Row(
          children: [
            // Botão de cópia formatada
            _buildActionButton(
              icon: Icons.copy,
              tooltip: 'Copiar texto formatado',
              onPressed: () => _copyFormattedText(context),
              isDark: isDark,
            ),
            // Botão de exportação PDF
            _buildActionButton(
              icon: Icons.picture_as_pdf,
              tooltip: 'Exportar para PDF',
              onPressed: () => _exportToPdf(context),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  /// Botão de ação reutilizável
  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white70 : Colors.grey[600],
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _copyFormattedText(BuildContext context) {
    // Converter markdown para texto formatado limpo
    String formattedText = _convertMarkdownToFormattedText(markdown);

    // Copiando para clipboard...

    // Mostrando SnackBar de confirmação...
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Texto formatado copiado para a área de transferência'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exportToPdf(BuildContext context) async {
    print('Botão PDF clicado!');
    
    try {
      print('Iniciando captura completa com scroll...');
      
      // Capturar múltiplos screenshots com scroll automático
      final screenshots = await _captureFullContentWithScroll();
      
      if (screenshots.isNotEmpty) {
        print('Capturados ${screenshots.length} screenshots para PDF');
        
        // Criar PDF com múltiplos screenshots
        final pdfPath = await _createPdfFromMultipleScreenshots(screenshots);
        
        print('PDF criado com sucesso em: $pdfPath');
        
        // Tentar abrir o PDF
        try {
          await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async {
              final pdf = await _createPdfBytesFromMultipleScreenshots(screenshots);
              return pdf;
            },
          );
        } catch (e) {
          print('Erro ao abrir PDF: $e');
          // Continuar mesmo se não conseguir abrir
        }
      } else {
        print('Nenhum screenshot capturado, tentando método alternativo...');
        await _exportPdfAlternativeMethod(context);
      }
    } catch (e) {
      print('Erro ao exportar PDF: $e');
      print('Tentando método alternativo...');
      await _exportPdfAlternativeMethod(context);
    }
  }
  
  Future<List<Uint8List>> _captureFullContentWithScroll() async {
    final screenshots = <Uint8List>[];
    
    try {
      // Voltar para o início do documento
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      // Aguardar estabilização
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Obter dimensões da tela e do conteúdo
      final screenHeight = 800.0; // Altura aproximada da tela visível
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      final minScrollExtent = _scrollController.position.minScrollExtent;
      
      print('Conteúdo total: ${maxScrollExtent + screenHeight} pixels');
      print('Altura da tela: $screenHeight pixels');
      print('Páginas estimadas: ${((maxScrollExtent + screenHeight) / screenHeight).ceil()}');
      
      if (maxScrollExtent == 0) {
        // Conteúdo cabe em uma página
        print('Conteúdo cabe em uma página, capturando screenshot único...');
        final screenshot = await _screenshotController.capture(
          pixelRatio: 2.0,
          delay: const Duration(milliseconds: 200),
        );
        
        if (screenshot != null) {
          screenshots.add(screenshot);
          print('Screenshot único capturado (${screenshot.length} bytes)');
        }
      } else {
        // Conteúdo precisa de múltiplas páginas
        print('Conteúdo precisa de múltiplas páginas, iniciando captura com scroll...');
        
        double currentPosition = minScrollExtent;
        int pageCount = 0;
        
        while (currentPosition <= maxScrollExtent) {
          pageCount++;
          print('Capturando página $pageCount - posição: $currentPosition');
          
          // Navegar para a posição atual
          await _scrollController.animateTo(
            currentPosition,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          
          // Aguardar estabilização
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Capturar screenshot da posição atual
          final screenshot = await _screenshotController.capture(
            pixelRatio: 2.0,
            delay: const Duration(milliseconds: 200),
          );
          
          if (screenshot != null) {
            screenshots.add(screenshot);
            print('Screenshot $pageCount capturado (${screenshot.length} bytes)');
          } else {
            print('Erro ao capturar screenshot da página $pageCount');
          }
          
          // Avançar para a próxima posição
          currentPosition += screenHeight * 0.8; // Sobreposição de 20% para continuidade
          
          // Limite de segurança para evitar loop infinito
          if (pageCount >= 20) {
            print('Atingido limite máximo de 20 páginas');
            break;
          }
        }
      }
      
      // Voltar para o início
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      print('Captura completa finalizada: ${screenshots.length} screenshots');
      
    } catch (e) {
      print('Erro na captura completa: $e');
      
      // Tentar capturar pelo menos uma página como fallback
      try {
        final screenshot = await _screenshotController.capture(
          pixelRatio: 2.0,
          delay: const Duration(milliseconds: 200),
        );
        
        if (screenshot != null) {
          screenshots.add(screenshot);
          print('Screenshot fallback capturado (${screenshot.length} bytes)');
        }
      } catch (e2) {
        print('Erro no fallback: $e2');
      }
    }
    
    return screenshots;
  }

  Future<void> _exportPdfAlternativeMethod(BuildContext context) async {
    try {
      print('Usando método alternativo com RepaintBoundary...');
      
      // Aguardar um frame para garantir que o widget está renderizado
      await Future.delayed(const Duration(milliseconds: 100));
      
      final renderObject = context.findRenderObject();
      if (renderObject == null) {
        print('RenderObject não encontrado');
        return;
      }
      
      // Procurar pelo RepaintBoundary
      RenderRepaintBoundary? boundary;
      
      if (renderObject is RenderRepaintBoundary) {
        boundary = renderObject;
      } else {
        RenderObject? current = renderObject;
        while (current != null) {
          if (current is RenderRepaintBoundary) {
            boundary = current;
            break;
          }
          current = current.parent;
        }
      }
      
      if (boundary != null) {
        print('Capturando imagem do RepaintBoundary...');
        final image = await boundary.toImage(pixelRatio: 2.0);
        print('Imagem capturada: ${image.width}x${image.height}');
        
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final bytes = byteData.buffer.asUint8List();
          print('Screenshot alternativo capturado (${bytes.length} bytes)');
          
          final pdfPath = await _createPdfFromScreenshot(bytes);
          print('PDF criado com sucesso em: $pdfPath');
          
          // Tentar abrir o PDF
          try {
            await Printing.layoutPdf(
              onLayout: (PdfPageFormat format) async {
                final pdf = await _createPdfBytes(bytes);
                return pdf;
              },
            );
          } catch (e) {
            print('Erro ao abrir PDF: $e');
          }
        } else {
          print('Erro: byteData é null');
        }
      } else {
        print('Nenhum RepaintBoundary encontrado');
      }
    } catch (e) {
      print('Erro no método alternativo: $e');
    }
  }

  Future<String> _createPdfFromMultipleScreenshots(List<Uint8List> screenshots) async {
    final pdfBytes = await _createPdfBytesFromMultipleScreenshots(screenshots);
    
    // Obter pasta Downloads do usuário
    String downloadsPath;
    try {
      final userProfile = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
      if (userProfile != null) {
        downloadsPath = '$userProfile\\Downloads';
      } else {
        final tempDir = await getTemporaryDirectory();
        downloadsPath = tempDir.path;
      }
    } catch (e) {
      print('Erro ao obter pasta Downloads: $e');
      final tempDir = await getTemporaryDirectory();
      downloadsPath = tempDir.path;
    }

    // Criar nome do arquivo
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'markdown_export_$timestamp.pdf';
    final filePath = '$downloadsPath\\$fileName';
    
    // Salvar o PDF
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);
    
    print('PDF salvo em: $filePath');
    return filePath;
  }

  Future<String> _createPdfFromScreenshot(Uint8List screenshot) async {
    final pdfBytes = await _createPdfBytes(screenshot);
    
    // Obter pasta Downloads do usuário
    String downloadsPath;
    try {
      final userProfile = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
      if (userProfile != null) {
        downloadsPath = '$userProfile\\Downloads';
      } else {
        final tempDir = await getTemporaryDirectory();
        downloadsPath = tempDir.path;
      }
    } catch (e) {
      print('Erro ao obter pasta Downloads: $e');
      final tempDir = await getTemporaryDirectory();
      downloadsPath = tempDir.path;
    }

    // Criar nome do arquivo
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'markdown_export_$timestamp.pdf';
    final filePath = '$downloadsPath\\$fileName';
    
    // Salvar o PDF
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);
    
    print('PDF salvo em: $filePath');
    return filePath;
  }
  
  Future<Uint8List> _createPdfBytes(Uint8List screenshot) async {
    final pdf = pw.Document();
    
    // Carregar o logo do Bloquinho
    final logoBytes = await _loadLogoBytes();
    pw.MemoryImage? logo;
    if (logoBytes != null) {
      logo = pw.MemoryImage(logoBytes);
    }
    
    // Cor castanha do tema para o texto
    final brownColor = PdfColor.fromHex('#5C4033');
    
    // Criar imagem do screenshot
    final image = pw.MemoryImage(screenshot);
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Conteúdo principal (screenshot)
              pw.Center(
                child: pw.Image(image),
              ),
              
              // Footer com logo e texto
              pw.Positioned(
                bottom: 10,
                left: 20,
                child: pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    // Logo do Bloquinho
                    if (logo != null)
                      pw.Container(
                        width: 16,
                        height: 16,
                        child: pw.Image(logo),
                      ),
                    
                    if (logo != null)
                      pw.SizedBox(width: 8),
                    
                    // Texto "Exported with Bloquinho"
                    pw.Text(
                      'Exported with Bloquinho',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: brownColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Número da página (canto inferior direito)
              pw.Positioned(
                bottom: 10,
                right: 20,
                child: pw.Text(
                  'pág 1',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: brownColor,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    
    return await pdf.save();
  }

  Future<String> _createPdfFromScreenshots(List<Uint8List> screenshots) async {
    final pdf = pw.Document();
    
    // Carregar o logo do Bloquinho
    final logoBytes = await _loadLogoBytes();
    pw.MemoryImage? logo;
    if (logoBytes != null) {
      logo = pw.MemoryImage(logoBytes);
    }
    
    // Cor castanha do tema para o texto
    final brownColor = PdfColor.fromHex('#5C4033'); // lightTextPrimary do tema classic
    
    for (int i = 0; i < screenshots.length; i++) {
      final screenshot = screenshots[i];
      final image = pw.MemoryImage(screenshot);
      final pageNumber = i + 1;
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // Conteúdo principal (screenshot)
                pw.Center(
                  child: pw.Image(image),
                ),
                
                // Footer com logo e texto
                pw.Positioned(
                  bottom: 10,
                  left: 20,
                  child: pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      // Logo do Bloquinho
                      if (logo != null)
                        pw.Container(
                          width: 16,
                          height: 16,
                          child: pw.Image(logo),
                        ),
                      
                      if (logo != null)
                        pw.SizedBox(width: 8),
                      
                      // Texto "Exported with Bloquinho"
                      pw.Text(
                        'Exported with Bloquinho',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: brownColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Número da página (canto inferior direito)
                pw.Positioned(
                  bottom: 10,
                  right: 20,
                  child: pw.Text(
                    'pág $pageNumber',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: brownColor,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    // Limpar PDFs antigos antes de criar o novo
    await _cleanupOldPdfFiles();

    // Obter pasta Downloads do usuário
    String downloadsPath;
    try {
      // Tentar obter a pasta Downloads do usuário
      final userProfile = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
      if (userProfile != null) {
        downloadsPath = '$userProfile\\Downloads';
      } else {
        // Fallback para diretório temporário
        final tempDir = await getTemporaryDirectory();
        downloadsPath = tempDir.path;
      }
    } catch (e) {
      print('Erro ao obter pasta Downloads: $e');
      final tempDir = await getTemporaryDirectory();
      downloadsPath = tempDir.path;
    }

    // Criar nome do arquivo
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'markdown_export_$timestamp.pdf';
    final filePath = '$downloadsPath\\$fileName';
    
    // Salvar o PDF
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    
    print('PDF salvo em: $filePath');
    
    // Abrir o PDF (opcional)
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      print('Erro ao abrir PDF: $e');
    }
    
    return filePath;
  }
  
  Future<Uint8List?> _loadLogoBytes() async {
    try {
      final byteData = await rootBundle.load('assets/images/logo.png');
      return byteData.buffer.asUint8List();
    } catch (e) {
      print('Erro ao carregar logo: $e');
      return null;
    }
  }

  Future<void> _cleanupOldPdfFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      final now = DateTime.now();
      final cutoffTime = now.subtract(const Duration(hours: 24)); // Limpar arquivos com mais de 24 horas
      
      for (final file in files) {
        if (file is File && file.path.endsWith('.pdf') && file.path.contains('markdown_export_')) {
          final stat = await file.stat();
          if (stat.modified.isBefore(cutoffTime)) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('Erro ao limpar arquivos PDF antigos: $e');
    }
  }

  String _convertMarkdownToFormattedText(String markdown) {
    String formatted = markdown;

    // Removendo cabeçalhos markdown (# ## ### etc)
    formatted =
        formatted.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');

    // Converter **texto** para texto normal (sem markdown)
    formatted = formatted.replaceAllMapped(
      RegExp(r'\*\*(.*?)\*\*'),
      (match) => match.group(1) ?? '',
    );

    // Converter *texto* para texto normal (sem markdown)
    formatted = formatted.replaceAllMapped(
      RegExp(r'\*(.*?)\*'),
      (match) => match.group(1) ?? '',
    );

    // Converter `código` para código (sem backticks)
    formatted = formatted.replaceAllMapped(
      RegExp(r'`(.*?)`'),
      (match) => match.group(1) ?? '',
    );

    // Remover links markdown [texto](url) -> texto
    formatted = formatted.replaceAllMapped(
      RegExp(r'\[(.*?)\]\(.*?\)'),
      (match) => match.group(1) ?? '',
    );

    // Remover blocos de código markdown
    formatted =
        formatted.replaceAll(RegExp(r'```[\s\S]*?```', multiLine: true), '');

    // Remover listas markdown (- * +)
    formatted =
        formatted.replaceAll(RegExp(r'^[\s]*[-*+]\s+', multiLine: true), '');

    // Remover listas numeradas
    formatted =
        formatted.replaceAll(RegExp(r'^[\s]*\d+\.?\s+', multiLine: true), '');

    // Limpar linhas em branco extras
    formatted = formatted.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');

    final result = formatted.trim();
    return result;
  }

  Widget _buildCustomCodeBlock(md.Element element) {
    final textContent = element.textContent;
    final language = _extractLanguage(element) ?? 'text';

    // Sempre usar WindowsCodeBlockWidget para blocos de código
    if (language.toLowerCase() == 'mermaid') {
      return WindowsMermaidDiagramWidget(diagram: textContent);
    }

    return WindowsCodeBlockWidget(
      code: textContent,
      language: language,
      showLineNumbers: true,
      showMacOSHeader: true,
    );
  }

  /// Extrai a linguagem de programação de um elemento de código markdown
  String? _extractLanguage(md.Element element) {
    // Tenta extrair da classe (ex: class="language-dart")
    final classAttr = element.attributes['class'];
    if (classAttr != null && classAttr.startsWith('language-')) {
      return classAttr.substring('language-'.length);
    }
    // Tenta pelo tag (ex: <code dart>)
    if (element.attributes.containsKey('language')) {
      return element.attributes['language'];
    }
    // Tenta pelo info string (ex: ```dart)
    if (element.attributes.containsKey('info')) {
      return element.attributes['info'];
    }
    return null;
  }

  String _sanitizeMarkdown(String input) {
    try {
      // Primeiro, verificar se a string é válida
      input.runes.toList();
      return input;
    } catch (e) {
      // Se não for válida, sanitizar caractere por caractere
      final buffer = StringBuffer();
      final codeUnits = input.codeUnits;

      for (int i = 0; i < codeUnits.length; i++) {
        final codeUnit = codeUnits[i];

        // Verificar se é um caractere UTF-16 válido
        if (_isValidUTF16CodeUnit(codeUnit)) {
          buffer.writeCharCode(codeUnit);
        } else {
          // Substituir caracteres inválidos por espaço
          buffer.write(' ');
        }
      }

      final sanitized = buffer.toString();

      // Limpar sequências de espaços múltiplos
      final cleaned = sanitized.replaceAll(RegExp(r'\s+'), ' ');

      return cleaned;
    }
  }

  bool _isValidUTF16CodeUnit(int codeUnit) {
    // Verificar se é um caractere de controle inválido
    if (codeUnit < 0x20 &&
        codeUnit != 0x09 &&
        codeUnit != 0x0A &&
        codeUnit != 0x0D) {
      return false;
    }

    // Verificar se é um surrogate inválido
    if (codeUnit >= 0xD800 && codeUnit <= 0xDFFF) {
      return false;
    }

    // Verificar se é um caractere não-definido
    if (codeUnit >= 0xFDD0 && codeUnit <= 0xFDEF) {
      return false;
    }

    if (codeUnit == 0xFFFE || codeUnit == 0xFFFF) {
      return false;
    }

    return true;
  }

  Widget _buildOptimizedMarkdown(
      BuildContext context, TextStyle baseStyle, WidgetRef ref) {
    final safeMarkdown = _sanitizeMarkdown(markdown);

    if (!enableHtmlEnhancements) {
      return RepaintBoundary(
        child: MarkdownBody(
          data: safeMarkdown,
          styleSheet: _createBasicStyleSheet(context, baseStyle),
          builders: {
            'code': AdvancedCodeBlockBuilder(),
            'mark': MarkBuilder(),
            'kbd': KbdBuilder(),
            'sub': SubBuilder(),
            'sup': SupBuilder(),
            'details': DetailsBuilder(),
            'summary': SummaryBuilder(),
            'color': ColorBuilder(ref: ref),
            'bg': BgBuilder(ref: ref),
            'badge': BadgeBuilder(ref: ref),
          },
          inlineSyntaxes: [
            LatexInlineSyntax(),
            ColorSyntax(),
            BgSyntax(),
            BadgeSyntax(),
            KbdInlineSyntax(),
            MarkInlineSyntax(),
            SubInlineSyntax(),
            SupInlineSyntax(),
          ],
          blockSyntaxes: [
            LatexBlockSyntax(),
          ],
          selectable: true,
        ),
      );
    }

    // Usando modo avançado (com HTML enhancements)...
    final hash = safeMarkdown.hashCode ^ enableHtmlEnhancements.hashCode;
    String processedContent;
    final cached = _markdownCache.get(hash);
    if (cached != null) {
      processedContent = cached;
    } else {
      try {
        processedContent =
            HtmlEnhancementParser.processWithEnhancements(safeMarkdown);
        _markdownCache.put(hash, processedContent);
      } catch (e) {
        processedContent = safeMarkdown;
      }
    }

    return RepaintBoundary(
      child: MarkdownBody(
        data: processedContent,
        styleSheet: _createEnhancedStyleSheet(context, baseStyle),
        builders: {
          'code': AdvancedCodeBlockBuilder(),
          'mark': MarkBuilder(),
          'kbd': KbdBuilder(),
          'sub': SubBuilder(),
          'sup': SupBuilder(),
          'details': DetailsBuilder(),
          'summary': SummaryBuilder(),
          'latex-inline': LatexBuilder(),
          'latex-block': LatexBuilder(),
          'span': SpanBuilder(ref: ref),
          'div': DynamicColoredDivBuilder(ref: ref),
          'progress': ProgressBuilder(),
          'mermaid': MermaidBuilder(),
          'color': ColorBuilder(ref: ref),
          'bg': BgBuilder(ref: ref),
          'badge': BadgeBuilder(ref: ref),
          'bloquinho-color': BloquinhoColorBuilder(ref: ref),
          'align': AlignBuilder(),
        },
        inlineSyntaxes: [
          LatexInlineSyntax(),
          ColorSyntax(),
          BgSyntax(),
          BadgeSyntax(),
          BloquinhoColorSyntax(),
          SpanInlineSyntax(), // Para <span style="...">...</span>
          KbdInlineSyntax(), // Para <kbd>...</kbd>
          MarkInlineSyntax(), // Para <mark>...</mark>
          SubInlineSyntax(), // Para <sub>...</sub>
          SupInlineSyntax(), // Para <sup>...</sup>
        ],
        blockSyntaxes: [
          LatexBlockSyntax(),
          MermaidBlockSyntax(),
        ],
        selectable: true,
      ),
    );
  }

  Widget _buildEnhancedMarkdown(
      BuildContext context, TextStyle baseStyle, WidgetRef ref) {
    final safeMarkdown = _sanitizeMarkdown(markdown);
    if (!enableHtmlEnhancements) {
      return MarkdownBody(
        data: safeMarkdown,
        styleSheet: _createBasicStyleSheet(context, baseStyle),
        builders: {
          'code': AdvancedCodeBlockBuilder(),
          'mark': MarkBuilder(),
          'kbd': KbdBuilder(),
          'sub': SubBuilder(),
          'sup': SupBuilder(),
          'details': DetailsBuilder(),
          'summary': SummaryBuilder(),
          'color': ColorBuilder(ref: ref),
          'bg': BgBuilder(ref: ref),
          'badge': BadgeBuilder(ref: ref),
        },
        inlineSyntaxes: [
          LatexInlineSyntax(),
          ColorSyntax(),
          BgSyntax(),
          BadgeSyntax(),
          KbdInlineSyntax(), // Para <kbd>...</kbd>
          MarkInlineSyntax(), // Para <mark>...</mark>
          SubInlineSyntax(), // Para <sub>...</sub>
          SupInlineSyntax(), // Para <sup>...</sup>
        ],
        blockSyntaxes: [
          LatexBlockSyntax(),
        ],
        selectable: true,
      );
    }

    // Cache do markdown processado
    final hash = safeMarkdown.hashCode ^ enableHtmlEnhancements.hashCode;
    String processedContent;
    if (_markdownCache.containsKey(hash)) {
      processedContent = _markdownCache[hash]!;
    } else {
      processedContent =
          HtmlEnhancementParser.processWithEnhancements(safeMarkdown);
      _markdownCache[hash] = processedContent;
    }

    return MarkdownBody(
      data: processedContent,
      styleSheet: _createEnhancedStyleSheet(context, baseStyle),
      builders: {
        'code': AdvancedCodeBlockBuilder(),
        'mark': MarkBuilder(),
        'kbd': KbdBuilder(),
        'sub': SubBuilder(),
        'sup': SupBuilder(),
        'details': DetailsBuilder(),
        'summary': SummaryBuilder(),
        'latex-inline': LatexBuilder(),
        'latex-block': LatexBuilder(),
        'span': SpanBuilder(ref: ref),
        'div': DynamicColoredDivBuilder(ref: ref),
        'progress': ProgressBuilder(),
        'mermaid': MermaidBuilder(),
        'color': ColorBuilder(ref: ref),
        'bg': BgBuilder(ref: ref),
        'badge': BadgeBuilder(ref: ref),
        'bloquinho-color': BloquinhoColorBuilder(ref: ref),
        'align': AlignBuilder(),
      },
      inlineSyntaxes: [
        LatexInlineSyntax(),
        ColorSyntax(),
        BgSyntax(),
        BadgeSyntax(),
        BloquinhoColorSyntax(),
        SpanInlineSyntax(), // Para <span style="...">...</span>
        KbdInlineSyntax(), // Para <kbd>...</kbd>
        MarkInlineSyntax(), // Para <mark>...</mark>
        SubInlineSyntax(), // Para <sub>...</sub>
        SupInlineSyntax(), // Para <sup>...</sup>
      ],
      blockSyntaxes: [
        LatexBlockSyntax(),
        MermaidBlockSyntax(),
      ],
      selectable: true,
    );
  }

  /// Cria styleSheet básico para markdown
  MarkdownStyleSheet _createBasicStyleSheet(
      BuildContext context, TextStyle baseStyle) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      h1: baseStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.2,
      ),
      h2: baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.3,
      ),
      h3: baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      h4: baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      h5: baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      h6: baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      p: baseStyle.copyWith(
        fontSize: 16,
        height: 1.6,
        color: textColor,
      ),
      strong: baseStyle.copyWith(
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      em: baseStyle.copyWith(
        fontStyle: FontStyle.italic,
        color: textColor,
      ),
      code: baseStyle.copyWith(
        fontFamily: 'monospace',
        backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        color: textColor,
        fontSize: 14,
      ),
      codeblockDecoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  /// Cria styleSheet avançado com enhancements
  MarkdownStyleSheet _createEnhancedStyleSheet(
      BuildContext context, TextStyle baseStyle) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      h1: baseStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.2,
      ),
      h2: baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.3,
      ),
      h3: baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      h4: baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      h5: baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      h6: baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      p: baseStyle.copyWith(
        fontSize: 16,
        height: 1.6,
        color: textColor,
      ),
      strong: baseStyle.copyWith(
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      em: baseStyle.copyWith(
        fontStyle: FontStyle.italic,
        color: textColor,
      ),
      code: baseStyle.copyWith(
        fontFamily: 'monospace',
        backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        color: textColor,
        fontSize: 14,
      ),
      codeblockDecoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      blockquote: baseStyle.copyWith(
        fontSize: 16,
        fontStyle: FontStyle.italic,
        color: textColor.withOpacity(0.8),
        height: 1.6,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary,
            width: 4,
          ),
        ),
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
      ),
      listBullet: baseStyle.copyWith(
        color: textColor,
        fontSize: 16,
      ),
      tableHead: baseStyle.copyWith(
        fontWeight: FontWeight.bold,
        color: textColor,
        fontSize: 14,
      ),
      tableBody: baseStyle.copyWith(
        color: textColor,
        fontSize: 14,
      ),
    );
  }
}

/// Builder moderno para tabelas
class ModernTableBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Table(
              border: TableBorder.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                width: 1,
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: _buildTableRows(element, theme),
            ),
          ),
        );
      },
    );
  }

  List<TableRow> _buildTableRows(md.Element element, ThemeData theme) {
    final rows = <TableRow>[];
    final isDark = theme.brightness == Brightness.dark;

    for (final child in element.children ?? []) {
      if (child is md.Element && child.tag == 'tr') {
        final cells = <Widget>[];
        bool isHeader = rows.isEmpty;

        for (final cell in child.children ?? []) {
          if (cell is md.Element && (cell.tag == 'td' || cell.tag == 'th')) {
            cells.add(
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isHeader
                      ? (isDark ? Colors.grey[800] : Colors.grey[100])
                      : null,
                ),
                child: Text(
                  cell.textContent,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }
        }
        rows.add(TableRow(children: cells));
      }
    }

    return rows;
  }
}

/// Builder moderno para listas
class ModernListBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (element.children ?? []).map((child) {
          if (child is md.Element && child.tag == 'li') {
            return ModernListItemBuilder()
                .visitElementAfter(child, preferredStyle);
          }
          return const SizedBox.shrink();
        }).toList(),
      ),
    );
  }
}

/// Builder moderno para itens de lista
class ModernListItemBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 8, right: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  element.textContent,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Builder moderno para blockquotes
class ModernBlockquoteBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: theme.colorScheme.primary,
                width: 4,
              ),
            ),
            borderRadius: BorderRadius.circular(8),
            color:
                isDark ? Colors.grey[900]!.withOpacity(0.5) : Colors.grey[50]!,
          ),
          child: Text(
            element.textContent,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
        );
      },
    );
  }
}

/// Builder moderno para títulos
class ModernHeadingBuilder extends MarkdownElementBuilder {
  final int level;

  ModernHeadingBuilder({required this.level});

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        double fontSize;
        FontWeight fontWeight;

        switch (level) {
          case 1:
            fontSize = 28;
            fontWeight = FontWeight.bold;
            break;
          case 2:
            fontSize = 24;
            fontWeight = FontWeight.bold;
            break;
          case 3:
            fontSize = 20;
            fontWeight = FontWeight.w600;
            break;
          case 4:
            fontSize = 18;
            fontWeight = FontWeight.w600;
            break;
          case 5:
            fontSize = 16;
            fontWeight = FontWeight.w600;
            break;
          case 6:
            fontSize = 14;
            fontWeight = FontWeight.w600;
            break;
          default:
            fontSize = 16;
            fontWeight = FontWeight.normal;
        }

        return Container(
          margin: EdgeInsets.only(
            top: level == 1 ? 24 : 20,
            bottom: 12,
          ),
          child: Text(
            element.textContent,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: fontSize,
              fontWeight: fontWeight,
              height: 1.2,
            ),
          ),
        );
      },
    );
  }
}

/// Widget para mostrar preview com toggle entre edit/preview
class MarkdownPreviewToggleWidget extends StatefulWidget {
  final String markdown;
  final bool enableHtmlEnhancements;
  final TextStyle? baseTextStyle;
  final EdgeInsets padding;
  final Color? backgroundColor;

  const MarkdownPreviewToggleWidget({
    super.key,
    required this.markdown,
    this.enableHtmlEnhancements = true,
    this.baseTextStyle,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
  });

  @override
  State<MarkdownPreviewToggleWidget> createState() =>
      _MarkdownPreviewToggleWidgetState();
}

class _MarkdownPreviewToggleWidgetState
    extends State<MarkdownPreviewToggleWidget> {
  bool _isPreviewMode = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _isPreviewMode ? 'Visualização' : 'Edição',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Switch(
                value: _isPreviewMode,
                onChanged: (value) {
                  setState(() {
                    _isPreviewMode = value;
                  });
                },
              ),
            ],
          ),
        ),

        // Content area
        Expanded(
          child: _isPreviewMode
              ? EnhancedMarkdownPreviewWidget(
                  markdown: widget.markdown,
                  enableHtmlEnhancements: widget.enableHtmlEnhancements,
                  baseTextStyle: widget.baseTextStyle,
                  backgroundColor: widget.backgroundColor,
                )
              : _buildEditMode(),
        ),
      ],
    );
  }

  Widget _buildEditMode() {
    return Container(
      padding: widget.padding,
      color: widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        child: Text(
          widget.markdown,
          style: widget.baseTextStyle ?? Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

/// Widget para mostrar exemplos de formatação
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
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
    );
  }
}

// Garantir que o builder de código sempre usa WindowsCodeBlockWidget
class AdvancedCodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final code = element.textContent;
    final language =
        element.attributes['class']?.replaceFirst('language-', '') ?? '';
    if (language == 'mermaid') {
      // Renderizar diagrama Mermaid
      return MermaidBuilder()
          .visitElementAfter(md.Element.text('mermaid', code), preferredStyle);
    }
    if (language == 'latex' || language == 'tex') {
      // Renderizar LaTeX
      return LatexBuilder().visitElementAfter(
          md.Element.text('latex-block', code), preferredStyle);
    }
    // Sempre renderizar código com WindowsCodeBlockWidget
    return WindowsCodeBlockWidget(
      code: code,
      language: language.isEmpty ? 'dart' : language,
      showLineNumbers: true,
      showMacOSHeader: true,
    );
  }
}

// Builders customizados para <mark>, <kbd>, <sub>, <sup>, <details>, <summary>
class MarkBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.yellow[600]?.withOpacity(0.3)
                : Colors.yellow[200],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isDark
                  ? Colors.yellow[500]!.withOpacity(0.4)
                  : Colors.yellow[400]!.withOpacity(0.6),
              width: 0.5,
            ),
          ),
          child: Text(
            element.textContent,
            style: (preferredStyle ?? const TextStyle()).copyWith(
              backgroundColor: Colors.transparent,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        );
      },
    );
  }
}

class KbdBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 2,
              ),
            ],
          ),
          child: Text(
            element.textContent,
            style: (preferredStyle ?? const TextStyle()).copyWith(
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        );
      },
    );
  }
}

class SubBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final baseStyle = preferredStyle ??
            Theme.of(context).textTheme.bodyMedium ??
            const TextStyle();

        return RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Transform.translate(
                  offset: const Offset(0.0, 3.0),
                  child: Text(
                    element.textContent,
                    style: baseStyle.copyWith(
                      fontSize: (baseStyle.fontSize ?? 16) * 0.7,
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SupBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final baseStyle = preferredStyle ??
            Theme.of(context).textTheme.bodyMedium ??
            const TextStyle();

        return RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Transform.translate(
                  offset: const Offset(0.0, -5.0),
                  child: Text(
                    element.textContent,
                    style: baseStyle.copyWith(
                      fontSize: (baseStyle.fontSize ?? 16) * 0.7,
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DetailsBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final summary = element.children?.firstWhere(
        (e) => e is md.Element && e.tag == 'summary',
        orElse: () => md.Element.text('summary', ''));
    final content = element.children
            ?.where((e) => e is! md.Element || e.tag != 'summary')
            .toList() ??
        [];
    return ExpansionTile(
      title: Text(summary?.textContent ?? 'Detalhes'),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content.map((e) => Text(e.textContent)).toList(),
          ),
        ),
      ],
    );
  }
}

class SummaryBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Text(
      element.textContent,
      style: preferredStyle?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

// Suporte a LaTeX inline e bloco
class LatexInlineSyntax extends md.InlineSyntax {
  LatexInlineSyntax() : super(r'\$(?!\$)([^$]+)\$');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final content = match.group(1)?.trim() ?? '';
    if (content.isNotEmpty) {
      parser.addNode(md.Element.text('latex-inline', content));
      return true;
    }
    return false;
  }
}

class LatexBlockSyntax extends md.BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^\${2}([\s\S]*?)\${2}', multiLine: true);

  @override
  md.Node parse(md.BlockParser parser) {
    final lines = <String>[];
    var line = parser.current;

    // Procurar por bloco LaTeX
    if (line.content.startsWith(r'$$')) {
      // Primeiro, verificar se é um bloco de linha única
      if (line.content.endsWith(r'$$') && line.content.length > 4) {
        final content =
            line.content.substring(2, line.content.length - 2).trim();
        parser.advance();
        return md.Element.text('latex-block', content);
      }

      // Caso contrário, processar bloco multi-linha
      lines.add(line.content);
      parser.advance();

      // Continuar lendo até encontrar final do bloco LaTeX
      while (!parser.isDone) {
        line = parser.current;
        lines.add(line.content);
        parser.advance();

        if (line.content.contains(r'$$')) {
          break;
        }
      }

      // Extrair o conteúdo LaTeX preservando estrutura
      final fullContent = lines.join('\n');
      final match = RegExp(r'\$\$([\s\S]*?)\$\$').firstMatch(fullContent);

      if (match != null) {
        final content = match.group(1) ?? '';
        // Preservar quebras de linha e estrutura de matrizes
        final processedContent = content
            .trim()
            .replaceAll(
                RegExp(r'[ \t]+'), ' ') // Normalizar espaços horizontais
            .replaceAll(
                RegExp(r'\n[ \t]*\n'), '\n'); // Remover linhas vazias extras
        return md.Element.text('latex-block', processedContent);
      }
    }

    // Fallback
    return md.Element.text('p', parser.current.content);
  }
}

class LatexBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final latex = element.textContent;
    final isBlock = element.tag == 'latex-block';

    // Usar LaTeXWidget em vez de Math.tex diretamente
    return LaTeXWidget(
      latex: latex,
      isBlock: isBlock,
      fontSize: preferredStyle?.fontSize,
      textColor: preferredStyle?.color,
    );
  }
}

class SpanBuilder extends MarkdownElementBuilder {
  final WidgetRef ref;

  SpanBuilder({required this.ref});

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final text = element.textContent;
    final style = element.attributes['style'] ?? '';
    final styleMap = _parseStyle(style);

    // Processar markdown dentro do texto (para **bold**, *italic*, etc.)
    final processedText = _processMarkdownInText(text);

    // Gerar ID único para este texto
    final textId = 'preview_${element.hashCode}';

    // Aplicar padding/margin se especificado
    final widget = DynamicColoredTextWithProvider(
      text: processedText.text,
      textId: textId,
      baseStyle: (preferredStyle ?? const TextStyle()).copyWith(
        color: styleMap['color'],
        backgroundColor: styleMap['backgroundColor'],
        fontWeight: processedText.isBold
            ? FontWeight.bold
            : (styleMap['fontWeight'] ?? FontWeight.normal),
        fontStyle: processedText.isItalic
            ? FontStyle.italic
            : (styleMap['fontStyle'] ?? FontStyle.normal),
        decoration: styleMap['decoration'],
        fontFamily: styleMap['fontFamily'],
        fontSize: styleMap['fontSize'],
      ),
      showControls: false, // Não mostrar controles no preview
    );

    // Aplicar container se há padding/margin/border
    if (styleMap['padding'] != null ||
        styleMap['margin'] != null ||
        styleMap['borderRadius'] != null) {
      return Container(
        padding: styleMap['padding'] as EdgeInsets?,
        margin: styleMap['margin'] as EdgeInsets?,
        decoration: BoxDecoration(
          color: styleMap['backgroundColor'],
          borderRadius: styleMap['borderRadius'] as BorderRadius?,
          border: styleMap['border'] as Border?,
        ),
        child: widget,
      );
    }

    return widget;
  }

  _ProcessedText _processMarkdownInText(String text) {
    bool isBold = false;
    bool isItalic = false;
    String processedText = text;

    // Processar **bold**
    if (text.contains('**')) {
      isBold = true;
      processedText = processedText.replaceAll('**', '');
    }

    // Processar *italic*
    if (text.contains('*') && !text.contains('**')) {
      isItalic = true;
      processedText = processedText.replaceAll('*', '');
    }

    return _ProcessedText(processedText, isBold, isItalic);
  }

  Map<String, dynamic> _parseStyle(String style) {
    final map = <String, dynamic>{};
    final props = style.split(';');
    for (final prop in props) {
      final parts = prop.split(':');
      if (parts.length != 2) continue;
      final key = parts[0].trim();
      final value = parts[1].trim();
      switch (key) {
        case 'color':
          map['color'] = _parseColor(value);
          break;
        case 'background-color':
          map['backgroundColor'] = _parseColor(value);
          break;
        case 'font-weight':
          map['fontWeight'] =
              value == 'bold' ? FontWeight.bold : FontWeight.normal;
          break;
        case 'font-style':
          map['fontStyle'] =
              value == 'italic' ? FontStyle.italic : FontStyle.normal;
          break;
        case 'text-decoration':
          if (value.contains('underline'))
            map['decoration'] = TextDecoration.underline;
          if (value.contains('line-through'))
            map['decoration'] = TextDecoration.lineThrough;
          break;
        case 'font-family':
          map['fontFamily'] = value;
          break;
        case 'font-size':
          map['fontSize'] = double.tryParse(value.replaceAll('px', ''));
          break;
        case 'padding':
          map['padding'] = _parseEdgeInsets(value);
          break;
        case 'margin':
          map['margin'] = _parseEdgeInsets(value);
          break;
        case 'border-radius':
          map['borderRadius'] = BorderRadius.circular(
              double.tryParse(value.replaceAll('px', '')) ?? 0);
          break;
        case 'border':
          map['border'] = _parseBorder(value);
          break;
        case 'border-left':
          map['borderLeft'] = _parseBorderSide(value, left: true);
          break;
        case 'display':
          map['display'] = value;
          break;
        case 'width':
          map['width'] = double.tryParse(value.replaceAll('px', ''));
          break;
        case 'height':
          map['height'] = double.tryParse(value.replaceAll('px', ''));
          break;
        case 'text-align':
          map['textAlign'] = _parseTextAlign(value);
          break;
        case 'align-items':
          map['alignment'] = _parseAlignment(value);
          break;
      }
    }
    return map;
  }

  Color? _parseColor(String value) {
    if (value.startsWith('#')) {
      return Color(int.parse(value.substring(1), radix: 16) + 0xFF000000);
    }
    switch (value) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'gray':
      case 'grey':
        return Colors.grey;
      default:
    }
    return null;
  }

  EdgeInsets _parseEdgeInsets(String value) {
    final parts = value.replaceAll('px', '').split(' ');
    if (parts.length == 1) {
      final v = double.tryParse(parts[0]) ?? 0;
      return EdgeInsets.all(v);
    } else if (parts.length == 2) {
      final v1 = double.tryParse(parts[0]) ?? 0;
      final v2 = double.tryParse(parts[1]) ?? 0;
      return EdgeInsets.symmetric(vertical: v1, horizontal: v2);
    } else if (parts.length == 4) {
      final top = double.tryParse(parts[0]) ?? 0;
      final right = double.tryParse(parts[1]) ?? 0;
      final bottom = double.tryParse(parts[2]) ?? 0;
      final left = double.tryParse(parts[3]) ?? 0;
      return EdgeInsets.fromLTRB(left, top, right, bottom);
    }
    return EdgeInsets.zero;
  }

  Border? _parseBorder(String value) {
    // Exemplo: 1px solid #FF0000
    final parts = value.split(' ');
    if (parts.length == 3) {
      final width = double.tryParse(parts[0].replaceAll('px', '')) ?? 1;
      final color = _parseColor(parts[2]);
      return Border.all(color: color ?? Colors.black, width: width);
    }
    return null;
  }

  Border? _parseBorderSide(String value, {bool left = false}) {
    // Exemplo: 4px solid #0277bd
    final parts = value.split(' ');
    if (parts.length == 3) {
      final width = double.tryParse(parts[0].replaceAll('px', '')) ?? 1;
      final color = _parseColor(parts[2]);
      if (left) {
        return Border(
            left: BorderSide(color: color ?? Colors.black, width: width));
      }
    }
    return null;
  }

  TextAlign? _parseTextAlign(String value) {
    switch (value) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'left':
        return TextAlign.left;
      case 'justify':
        return TextAlign.justify;
      default:
        return null;
    }
  }

  Alignment? _parseAlignment(String value) {
    switch (value) {
      case 'center':
        return Alignment.center;
      case 'right':
        return Alignment.centerRight;
      case 'left':
        return Alignment.centerLeft;
      case 'top':
        return Alignment.topCenter;
      case 'bottom':
        return Alignment.bottomCenter;
      default:
        return null;
    }
  }
}

class DynamicColoredDivBuilder extends MarkdownElementBuilder {
  final WidgetRef ref;

  DynamicColoredDivBuilder({required this.ref});

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final text = element.textContent;
    final style = element.attributes['style'] ?? '';
    final styleMap = _parseStyle(style);

    // Gerar ID único para este texto
    final textId = 'preview_div_${element.hashCode}';

    // Usar o sistema DynamicColoredText para divs também
    return DynamicColoredTextWithProvider(
      text: text,
      textId: textId,
      baseStyle: (preferredStyle ?? const TextStyle()).copyWith(
        color: styleMap['color'],
        fontWeight: styleMap['fontWeight'],
        fontStyle: styleMap['fontStyle'],
        decoration: styleMap['decoration'],
        fontFamily: styleMap['fontFamily'],
        fontSize: styleMap['fontSize'],
      ),
      showControls: false, // Não mostrar controles no preview
    );
  }

  Map<String, dynamic> _parseStyle(String style) {
    final map = <String, dynamic>{};
    final props = style.split(';');
    for (final prop in props) {
      final parts = prop.split(':');
      if (parts.length != 2) continue;
      final key = parts[0].trim();
      final value = parts[1].trim();
      switch (key) {
        case 'color':
          map['color'] = _parseColor(value);
          break;
        case 'background-color':
          map['backgroundColor'] = _parseColor(value);
          break;
        case 'font-weight':
          map['fontWeight'] =
              value == 'bold' ? FontWeight.bold : FontWeight.normal;
          break;
        case 'font-style':
          map['fontStyle'] =
              value == 'italic' ? FontStyle.italic : FontStyle.normal;
          break;
        case 'text-decoration':
          if (value.contains('underline'))
            map['decoration'] = TextDecoration.underline;
          if (value.contains('line-through'))
            map['decoration'] = TextDecoration.lineThrough;
          break;
        case 'font-family':
          map['fontFamily'] = value;
          break;
        case 'font-size':
          map['fontSize'] = double.tryParse(value.replaceAll('px', ''));
          break;
        case 'padding':
          map['padding'] = _parseEdgeInsets(value);
          break;
        case 'margin':
          map['margin'] = _parseEdgeInsets(value);
          break;
        case 'border-radius':
          map['borderRadius'] = BorderRadius.circular(
              double.tryParse(value.replaceAll('px', '')) ?? 0);
          break;
        case 'border':
          map['border'] = _parseBorder(value);
          break;
        case 'border-left':
          map['borderLeft'] = _parseBorderSide(value, left: true);
          break;
        case 'display':
          map['display'] = value;
          break;
        case 'width':
          map['width'] = double.tryParse(value.replaceAll('px', ''));
          break;
        case 'height':
          map['height'] = double.tryParse(value.replaceAll('px', ''));
          break;
        case 'text-align':
          map['textAlign'] = _parseTextAlign(value);
          break;
        case 'align-items':
          map['alignment'] = _parseAlignment(value);
          break;
      }
    }
    return map;
  }

  Color? _parseColor(String value) {
    if (value.startsWith('#')) {
      return Color(int.parse(value.substring(1), radix: 16) + 0xFF000000);
    }
    switch (value) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'gray':
      case 'grey':
        return Colors.grey;
      default:
        return null;
    }
  }

  EdgeInsets _parseEdgeInsets(String value) {
    final parts = value.replaceAll('px', '').split(' ');
    if (parts.length == 1) {
      final v = double.tryParse(parts[0]) ?? 0;
      return EdgeInsets.all(v);
    } else if (parts.length == 2) {
      final v1 = double.tryParse(parts[0]) ?? 0;
      final v2 = double.tryParse(parts[1]) ?? 0;
      return EdgeInsets.symmetric(vertical: v1, horizontal: v2);
    } else if (parts.length == 4) {
      final top = double.tryParse(parts[0]) ?? 0;
      final right = double.tryParse(parts[1]) ?? 0;
      final bottom = double.tryParse(parts[2]) ?? 0;
      final left = double.tryParse(parts[3]) ?? 0;
      return EdgeInsets.fromLTRB(left, top, right, bottom);
    }
    return EdgeInsets.zero;
  }

  Border? _parseBorder(String value) {
    // Exemplo: 1px solid #FF0000
    final parts = value.split(' ');
    if (parts.length == 3) {
      final width = double.tryParse(parts[0].replaceAll('px', '')) ?? 1;
      final color = _parseColor(parts[2]);
      return Border.all(color: color ?? Colors.black, width: width);
    }
    return null;
  }

  Border? _parseBorderSide(String value, {bool left = false}) {
    // Exemplo: 4px solid #0277bd
    final parts = value.split(' ');
    if (parts.length == 3) {
      final width = double.tryParse(parts[0].replaceAll('px', '')) ?? 1;
      final color = _parseColor(parts[2]);
      if (left) {
        return Border(
            left: BorderSide(color: color ?? Colors.black, width: width));
      }
    }
    return null;
  }

  TextAlign? _parseTextAlign(String value) {
    switch (value) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'left':
        return TextAlign.left;
      case 'justify':
        return TextAlign.justify;
      default:
        return null;
    }
  }

  Alignment? _parseAlignment(String value) {
    switch (value) {
      case 'center':
        return Alignment.center;
      case 'right':
        return Alignment.centerRight;
      case 'left':
        return Alignment.centerLeft;
      case 'top':
        return Alignment.topCenter;
      case 'bottom':
        return Alignment.bottomCenter;
      default:
        return null;
    }
  }
}

class ProgressBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final value = int.tryParse(element.attributes['value'] ?? '0') ?? 0;
    final max = int.tryParse(element.attributes['max'] ?? '100') ?? 100;
    final percent = (value / max).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent,
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: percent < 1.0 ? Colors.blue : Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '${(percent * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MermaidBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final code = element.textContent;
    final html = """
      <!DOCTYPE html>
      <html>
        <head>
          <style>
            body {
              background-color: #1E1E1E;
              color: white;
              display: flex;
              justify-content: center;
              align-items: center;
              height: 100vh;
              margin: 0;
            }
          </style>
        </head>
        <body>
          <pre class="mermaid">
            $code
          </pre>
          <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
          <script>mermaid.initialize({startOnLoad:true, theme: 'dark'});</script>
        </body>
      </html>
    """;

    return SizedBox(
      height: 300,
      child: WindowsMermaidDiagramWidget(
        diagram: code,
      ),
    );
  }
}

class MermaidBlockSyntax extends md.BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^```mermaid\n([\s\S]+?)\n```');

  @override
  md.Node parse(md.BlockParser parser) {
    final match = pattern.firstMatch(parser.current.content);
    if (match != null) {
      final content = match.group(1)!;
      parser.advance();
      return md.Element.text('mermaid', content);
    }
    return md.Element.text('p', parser.current.content);
  }
}

class ColorSyntax extends md.InlineSyntax {
  ColorSyntax() : super(r'<color:(.*?)">(.*?)</color>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final color = match.group(1)!;
    final text = match.group(2)!;
    final attributes = {'color': color};
    final element = md.Element.text('color', text);
    element.attributes.addAll(attributes);
    parser.addNode(element);
    return true;
  }
}

class BgSyntax extends md.InlineSyntax {
  BgSyntax() : super(r'<bg:(.*?)">(.*?)</bg>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final color = match.group(1)!;
    final text = match.group(2)!;
    final attributes = {'bg': color};
    final element = md.Element.text('bg', text);
    element.attributes.addAll(attributes);
    parser.addNode(element);
    return true;
  }
}

class BadgeSyntax extends md.InlineSyntax {
  BadgeSyntax() : super(r'<badge:(.*?)">(.*?)</badge>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final color = match.group(1)!;
    final text = match.group(2)!;
    final attributes = {'color': color};
    final element = md.Element.text('badge', text);
    element.attributes.addAll(attributes);
    parser.addNode(element);
    return true;
  }
}

class BloquinhoColorSyntax extends md.InlineSyntax {
  BloquinhoColorSyntax()
      : super(r'<bloquinho-color:(.*?)">(.*?)</bloquinho-color>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final colorName = match.group(1)!;
    final text = match.group(2)!;
    final attributes = {'colorName': colorName};
    final element = md.Element.text('bloquinho-color', text);
    element.attributes.addAll(attributes);
    parser.addNode(element);
    return true;
  }
}

class SpanInlineSyntax extends md.InlineSyntax {
  SpanInlineSyntax() : super(r'<span style="(.*?)">(.*?)</span>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final style = match.group(1)!;
    final text = match.group(2)!;
    final attributes = {'style': style};
    final element = md.Element.text('span', text);
    element.attributes.addAll(attributes);
    parser.addNode(element);
    return true;
  }
}

class KbdInlineSyntax extends md.InlineSyntax {
  KbdInlineSyntax() : super(r'<kbd>(.*?)</kbd>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final text = match.group(1)!;
    final element = md.Element.text('kbd', text);
    parser.addNode(element);
    return true;
  }
}

class MarkInlineSyntax extends md.InlineSyntax {
  MarkInlineSyntax() : super(r'<mark>(.*?)</mark>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final text = match.group(1)!;
    final element = md.Element.text('mark', text);
    parser.addNode(element);
    return true;
  }
}

class SubInlineSyntax extends md.InlineSyntax {
  SubInlineSyntax() : super(r'<sub>(.*?)</sub>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final text = match.group(1)!;
    final element = md.Element.text('sub', text);
    parser.addNode(element);
    return true;
  }
}

class SupInlineSyntax extends md.InlineSyntax {
  SupInlineSyntax() : super(r'<sup>(.*?)</sup>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final text = match.group(1)!;
    final element = md.Element.text('sup', text);
    parser.addNode(element);
    return true;
  }
}

class ColorBuilder extends MarkdownElementBuilder {
  final WidgetRef ref;

  ColorBuilder({required this.ref});

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final colorName = element.attributes['color'] ?? 'default';
    final text = element.textContent;
    final color = _getColor(colorName);
    return Text(text, style: preferredStyle?.copyWith(color: color));
  }

  Color _getColor(String name) {
    switch (name) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      default:
        return Colors.black;
    }
  }
}

class BgBuilder extends MarkdownElementBuilder {
  final WidgetRef ref;

  BgBuilder({required this.ref});

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final colorName = element.attributes['bg'] ?? 'default';
    final text = element.textContent;
    final color = _getColor(colorName);
    return Container(
      color: color,
      child: Text(text, style: preferredStyle),
    );
  }

  Color _getColor(String name) {
    switch (name) {
      case 'red':
        return Colors.red.withOpacity(0.3);
      case 'blue':
        return Colors.blue.withOpacity(0.3);
      case 'green':
        return Colors.green.withOpacity(0.3);
      default:
        return Colors.transparent;
    }
  }
}

class BadgeBuilder extends MarkdownElementBuilder {
  final WidgetRef ref;

  BadgeBuilder({required this.ref});

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final colorName = element.attributes['color'] ?? 'default';
    final text = element.textContent;
    final color = _getColor(colorName);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: preferredStyle?.copyWith(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Color _getColor(String name) {
    switch (name) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class BloquinhoColorBuilder extends MarkdownElementBuilder {
  final WidgetRef ref;

  BloquinhoColorBuilder({required this.ref});

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final colorName = element.attributes['colorName'] ?? 'default';
    final text = element.textContent;
    final color = _getColor(colorName);
    return Text(text, style: preferredStyle?.copyWith(color: color));
  }

  Color _getColor(String name) {
    // Implementar a lógica para obter a cor do Bloquinho
    return Colors.black;
  }
}

class AlignBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final align = element.attributes['align'] ?? 'left';
    final text = element.textContent;
    return Container(
      width: double.infinity,
      child: Text(
        text,
        textAlign: _getTextAlign(align),
        style: preferredStyle,
      ),
    );
  }

  TextAlign _getTextAlign(String align) {
    switch (align) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }
}

class _ProcessedText {
  final String text;
  final bool isBold;
  final bool isItalic;

  _ProcessedText(this.text, this.isBold, this.isItalic);
}
