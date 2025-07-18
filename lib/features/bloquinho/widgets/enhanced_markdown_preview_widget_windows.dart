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
// Windows version - no webview_flutter support
import 'dynamic_colored_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'simple_diagram_widget.dart';
import 'windows_code_block_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'latex_widget.dart';
import 'mermaid_diagram_widget.dart';
import '../../../core/utils/lru_cache.dart';
import '../../../core/services/enhanced_markdown_parser.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:screenshot/screenshot.dart';

import 'dart:io';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/pdf_template.dart';
import '../providers/pdf_template_provider.dart';
import '../providers/custom_template_provider.dart';
import '../models/custom_pdf_template.dart';
import 'pdf_template_selector.dart';

/// Widget de visualização markdown com enhancements HTML moderno
/// Windows version - simplified without webview_flutter
class EnhancedMarkdownPreviewWidget extends ConsumerWidget {
  final String markdown;
  final bool showLineNumbers;
  final bool enableHtmlEnhancements;
  final TextStyle? baseTextStyle;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final bool showScrollbar;
  final ScrollPhysics? scrollPhysics;

  // Cache otimizado para markdown processado
  static final LRUCache<int, String> _markdownCache = LRUCache(maxSize: 100);
  static final LRUCache<int, Widget> _widgetCache = LRUCache(maxSize: 50);

  // Screenshot controller para captura de imagem
  static final ScreenshotController _screenshotController =
      ScreenshotController();
  static final ScrollController _scrollController = ScrollController();

  EnhancedMarkdownPreviewWidget({
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

    // Sanitizar markdown inteiro antes de processar
    final sanitizedMarkdown = sanitizeUtf16(markdown);

    // Cache de widget completo baseado em hash do conteúdo + configurações
    final cacheKey = _generateWidgetCacheKey(isDark);
    final cachedWidget = _widgetCache.get(cacheKey);
    if (cachedWidget != null) return cachedWidget;

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
                          child: _buildOptimizedMarkdown(
                              context, textStyle, ref, sanitizedMarkdown),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Botões de ação otimizados
              _buildOptimizedActionButtons(context, isDark, ref),
            ],
          ),
        ),
      ),
    );

    // Cache do widget completo (removido para Screenshot funcionar)
    // _widgetCache.put(cacheKey, widget);
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
            // Título "Preview" com template selector e preview
            Row(
              children: [
                // Template selector
                const PdfTemplateSelector(),
                // Template preview
                const PdfTemplatePreview(),
              ],
            ),
            const SizedBox(width: 16),
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
              onPressed: () => _exportToPdf(context, ref),
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

  void _copyFormattedText(BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: markdown));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Texto copiado para a área de transferência!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao copiar texto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _exportToPdf(BuildContext context, [WidgetRef? ref]) async {
    print('Botão PDF clicado!');

    // Capturar o contexto do Navigator e ScaffoldMessenger antes das operações assíncronas
    final navigator = Navigator.maybeOf(context);
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);

    if (navigator == null || scaffoldMessenger == null) {
      print('Navigator ou ScaffoldMessenger não encontrado no contexto');
      return;
    }

    try {
      print('Mostrando loader personalizado...');

      // Mostrar loader personalizado
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const BloquinhoLoader(),
      );

      print('Iniciando captura de screenshots...');

      // Capturar screenshots com scroll
      final screenshots = await _captureScreenshotsWithScroll(context);

      print('Screenshots capturados: ${screenshots.length}');

      // Fechar loader usando o navigator capturado
      try {
        navigator.pop();
      } catch (e) {
        print('Erro ao fechar dialog: $e');
      }

      if (screenshots.isNotEmpty) {
        print('Criando PDF com screenshots...');

        // Criar PDF com screenshots
        final pdfPath = await _createPdfFromScreenshots(screenshots, ref);

        print('PDF criado com sucesso em: $pdfPath');

        // Usar o scaffoldMessenger capturado
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('PDF exportado com sucesso!\nSalvo em: $pdfPath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        print('Nenhum screenshot capturado');

        // Usar o scaffoldMessenger capturado
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Erro ao capturar screenshots'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erro ao exportar PDF: $e');

      // Tentar fechar o dialog se ainda estiver aberto
      try {
        navigator.pop();
      } catch (e2) {
        print('Erro ao fechar dialog: $e2');
      }

      // Usar o scaffoldMessenger capturado
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<Uint8List>> _captureScreenshotsWithScroll(
      BuildContext context) async {
    final screenshots = <Uint8List>[];

    try {
      print('Iniciando captura completa com scroll...');

      // Primeiro, vamos à posição inicial
      _scrollController.jumpTo(0);
      await Future.delayed(const Duration(milliseconds: 300));

      // Obter dimensões da tela visível dinamicamente
      final viewportHeight = _scrollController.position.viewportDimension;
      final maxScrollExtent = _scrollController.position.maxScrollExtent;

      // Altura de captura = altura da viewport (tela visível)
      final captureHeight = viewportHeight;

      print('Altura da viewport: $viewportHeight pixels');
      print('Máximo scroll: $maxScrollExtent pixels');

      if (maxScrollExtent <= 0) {
        // Conteúdo cabe em uma tela
        print('Conteúdo cabe em uma tela, capturando único screenshot...');
        final screenshot = await _captureCurrentView();
        if (screenshot != null) {
          screenshots.add(screenshot);
        }
      } else {
        // Conteúdo requer scroll - captura sequencial com sobreposição
        print(
            'Conteúdo requer scroll, iniciando captura sequencial com sobreposição...');

        double currentPosition = 0;
        int pageCount = 0;

        // Calcular avanço com sobreposição: 80% da altura da viewport
        // Isso cria 20% de sobreposição entre screenshots consecutivos
        final scrollAdvance = captureHeight * 0.8;

        while (currentPosition <= maxScrollExtent) {
          pageCount++;
          print('Capturando página $pageCount na posição: $currentPosition');

          // Ir para a posição atual
          _scrollController.jumpTo(currentPosition);
          await Future.delayed(const Duration(
              milliseconds:
                  1200)); // Aguardar renderização completa (aumentado)

          // Capturar screenshot
          final screenshot = await _captureCurrentView();
          if (screenshot != null) {
            screenshots.add(screenshot);
            print('Screenshot $pageCount capturado');
          }

          // Próxima posição: avançar com margem extra para evitar sobreposição
          final nextPosition = currentPosition + scrollAdvance;

          // Se estamos próximos do final, capturar o restante
          if (nextPosition >= maxScrollExtent) {
            print('Capturando página final...');
            _scrollController.jumpTo(maxScrollExtent);
            await Future.delayed(const Duration(
                milliseconds: 1200)); // Aumentado para 1.2 segundos

            final finalScreenshot = await _captureCurrentView();
            if (finalScreenshot != null) {
              screenshots.add(finalScreenshot);
              print('Screenshot final capturado');
            }
            break;
          }

          currentPosition = nextPosition;

          // Limite de segurança
          if (pageCount >= 20) {
            print('Atingido limite máximo de 20 páginas');
            break;
          }
        }
      }

      print('Captura completa finalizada: ${screenshots.length} screenshots');
      return screenshots;
    } catch (e) {
      print('Erro ao capturar screenshots: $e');
      return screenshots;
    }
  }

  /// Remove a função _calculatePreciseNextPosition pois não é mais necessária

  Future<Uint8List?> _captureCurrentView() async {
    try {
      print('Capturando screenshot com Screenshot library...');

      // Aguardar um frame para garantir que o widget está renderizado
      await Future.delayed(const Duration(milliseconds: 300));

      // Usar Screenshot library para capturar com maior qualidade
      final imageBytes = await _screenshotController.capture(
        pixelRatio: 3.0, // Maior resolução para melhor qualidade
        delay: const Duration(milliseconds: 300),
      );

      if (imageBytes != null) {
        print('Screenshot capturado com sucesso (${imageBytes.length} bytes)');
        return imageBytes;
      } else {
        print('Erro: Screenshot é null');
        return null;
      }
    } catch (e, stackTrace) {
      print('Erro ao capturar screenshot: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Combina screenshots verticalmente em uma única imagem longa, removendo sobreposição
  Future<Uint8List?> _combineScreenshotsVertically(
      List<Uint8List> screenshots) async {
    if (screenshots.isEmpty) return null;
    if (screenshots.length == 1) return screenshots.first;

    try {
      print('Combinando ${screenshots.length} screenshots verticalmente...');

      // Decodificar todas as imagens
      final images = <img.Image>[];
      int maxWidth = 0;

      for (final screenshot in screenshots) {
        final image = img.decodeImage(screenshot);
        if (image != null) {
          images.add(image);
          if (image.width > maxWidth) {
            maxWidth = image.width;
          }
        }
      }

      if (images.isEmpty) return null;

      // Calcular altura total removendo sobreposição
      // A sobreposição é de 20% (scrollAdvance = captureHeight * 0.8)
      final overlapRatio = 0.2; // 20% de sobreposição
      int totalHeight = images.first.height; // Primeira imagem completa

      // Para as imagens subsequentes, remover a sobreposição
      for (int i = 1; i < images.length; i++) {
        final image = images[i];
        final overlapHeight = (image.height * overlapRatio).round();
        totalHeight += (image.height - overlapHeight);
      }

      // Criar uma nova imagem combinada
      final combinedImage = img.Image(width: maxWidth, height: totalHeight);

      // Preencher com fundo branco
      img.fill(combinedImage, color: img.ColorRgb8(255, 255, 255));

      // Combinar todas as imagens verticalmente, removendo sobreposição
      int currentY = 0;

      // Primeira imagem vai completa
      img.compositeImage(combinedImage, images.first, dstX: 0, dstY: currentY);
      currentY += images.first.height;

      // Para as imagens subsequentes, remover a sobreposição
      for (int i = 1; i < images.length; i++) {
        final image = images[i];
        final overlapHeight = (image.height * overlapRatio).round();

        // Cortar a parte superior (sobreposição) da imagem
        final croppedImage = img.copyCrop(
          image,
          x: 0,
          y: overlapHeight,
          width: image.width,
          height: image.height - overlapHeight,
        );

        // Adicionar a imagem cortada à imagem combinada
        img.compositeImage(combinedImage, croppedImage,
            dstX: 0, dstY: currentY);
        currentY += croppedImage.height;
      }

      // Codificar a imagem combinada
      final combinedBytes = img.encodePng(combinedImage);
      print(
          'Imagem combinada criada: ${maxWidth}x${totalHeight} pixels (sobreposição removida)');

      return Uint8List.fromList(combinedBytes);
    } catch (e) {
      print('Erro ao combinar screenshots: $e');
      return null;
    }
  }

  /// Cria páginas PDF a partir de uma imagem combinada longa
  Future<void> _createPdfPagesFromCombinedImage(
    pw.Document pdf,
    Uint8List combinedImageBytes,
    pw.MemoryImage? logo,
    PdfColor brownColor,
    pw.Font robotoFont,
    PdfTemplate template,
  ) async {
    try {
      // Decodificar a imagem combinada
      final combinedImage = img.decodeImage(combinedImageBytes);
      if (combinedImage == null) return;

      // Calcular dimensões da página PDF considerando template
      final pageWidth = PdfPageFormat.a4.width;
      final pageHeight = PdfPageFormat.a4.height -
          template.headerHeight -
          template.footerHeight;

      // Calcular quantas páginas serão necessárias
      final imageAspectRatio = combinedImage.width / combinedImage.height;
      final pageAspectRatio = pageWidth / pageHeight;

      // Calcular altura da imagem que cabe na largura da página
      final imageHeightInPage = pageWidth / imageAspectRatio;

      // Se a imagem cabe em uma página
      if (imageHeightInPage <= pageHeight) {
        _addSinglePageToPdf(pdf, combinedImageBytes, logo, brownColor,
            robotoFont, 1, template, 1);
        return;
      }

      // Dividir a imagem em múltiplas páginas
      final totalPages = (imageHeightInPage / pageHeight).ceil();
      final sourceImageHeight = combinedImage.height;
      final heightPerPage = sourceImageHeight / totalPages;

      for (int pageNum = 0; pageNum < totalPages; pageNum++) {
        final startY = (pageNum * heightPerPage).round();
        final endY =
            ((pageNum + 1) * heightPerPage).round().clamp(0, sourceImageHeight);
        final pageImageHeight = endY - startY;

        // Cortar a porção da imagem para esta página
        final pageImage = img.copyCrop(
          combinedImage,
          x: 0,
          y: startY,
          width: combinedImage.width,
          height: pageImageHeight,
        );

        // Codificar a imagem da página
        final pageImageBytes = img.encodePng(pageImage);

        // Adicionar página ao PDF
        _addSinglePageToPdf(pdf, Uint8List.fromList(pageImageBytes), logo,
            brownColor, robotoFont, pageNum + 1, template, totalPages);
      }

      print('PDF criado com $totalPages páginas');
    } catch (e) {
      print('Erro ao criar páginas PDF: $e');
    }
  }

  /// Adiciona uma única página ao PDF
  void _addSinglePageToPdf(
    pw.Document pdf,
    Uint8List imageBytes,
    pw.MemoryImage? logo,
    PdfColor brownColor,
    pw.Font robotoFont,
    int pageNumber,
    PdfTemplate template,
    int totalPages,
  ) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final isDark = false; // Assumir modo claro para PDF
          final widgets = <pw.Widget>[];

          // Header se existir
          final header = template.createHeader(
            pageNumber: pageNumber,
            totalPages: totalPages,
            isDark: isDark,
            logo: logo,
            font: robotoFont,
          );

          // Imagem da página - centralizada e redimensionada
          widgets.add(
            pw.Center(
              child: pw.Container(
                width:
                    PdfPageFormat.a4.width - 40, // Margem de 20px de cada lado
                height: PdfPageFormat.a4.height -
                    template.headerHeight -
                    template.footerHeight -
                    40, // Margem de 20px
                child: pw.Image(
                  pw.MemoryImage(imageBytes),
                  fit: pw.BoxFit.contain,
                  alignment: pw.Alignment.center,
                ),
              ),
            ),
          );

          // Footer
          final footer = template.createFooter(
            pageNumber: pageNumber,
            totalPages: totalPages,
            isDark: isDark,
            logo: logo,
            font: robotoFont,
          );

          widgets.add(
            pw.Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: footer,
            ),
          );

          // Header na parte superior
          if (header != null) {
            widgets.add(
              pw.Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: header,
              ),
            );
          }

          return pw.Stack(children: widgets);
        },
      ),
    );
  }

  /// Cria páginas PDF a partir de uma imagem combinada longa usando template customizado
  Future<void> _createPdfPagesFromCombinedImageWithCustomTemplate(
    pw.Document pdf,
    Uint8List combinedImageBytes,
    pw.MemoryImage? logo,
    PdfColor brownColor,
    pw.Font robotoFont,
    CustomPdfTemplate customTemplate,
  ) async {
    try {
      // Decodificar a imagem combinada
      final combinedImage = img.decodeImage(combinedImageBytes);
      if (combinedImage == null) return;

      // Calcular dimensões da página PDF considerando template customizado
      final pageWidth = PdfPageFormat.a4.width;
      final pageHeight = PdfPageFormat.a4.height -
          customTemplate.headerHeight -
          customTemplate.footerHeight;

      // Calcular quantas páginas serão necessárias
      final imageAspectRatio = combinedImage.width / combinedImage.height;
      final pageAspectRatio = pageWidth / pageHeight;

      // Calcular altura da imagem que cabe na largura da página
      final imageHeightInPage = pageWidth / imageAspectRatio;

      // Se a imagem cabe em uma página
      if (imageHeightInPage <= pageHeight) {
        _addSinglePageToPdfWithCustomTemplate(pdf, combinedImageBytes, logo,
            brownColor, robotoFont, 1, customTemplate, 1);
        return;
      }

      // Dividir a imagem em múltiplas páginas
      final totalPages = (imageHeightInPage / pageHeight).ceil();
      final sourceImageHeight = combinedImage.height;
      final heightPerPage = sourceImageHeight / totalPages;

      for (int pageNum = 0; pageNum < totalPages; pageNum++) {
        final startY = (pageNum * heightPerPage).round();
        final endY =
            ((pageNum + 1) * heightPerPage).round().clamp(0, sourceImageHeight);
        final pageImageHeight = endY - startY;

        // Cortar a porção da imagem para esta página
        final pageImage = img.copyCrop(
          combinedImage,
          x: 0,
          y: startY,
          width: combinedImage.width,
          height: pageImageHeight,
        );

        // Codificar a imagem da página
        final pageImageBytes = img.encodePng(pageImage);

        // Adicionar página ao PDF
        _addSinglePageToPdfWithCustomTemplate(
            pdf,
            Uint8List.fromList(pageImageBytes),
            logo,
            brownColor,
            robotoFont,
            pageNum + 1,
            customTemplate,
            totalPages);
      }

      print('PDF criado com $totalPages páginas usando template customizado');
    } catch (e) {
      print('Erro ao criar páginas PDF com template customizado: $e');
    }
  }

  /// Adiciona uma única página ao PDF usando template customizado
  void _addSinglePageToPdfWithCustomTemplate(
    pw.Document pdf,
    Uint8List imageBytes,
    pw.MemoryImage? logo,
    PdfColor brownColor,
    pw.Font robotoFont,
    int pageNumber,
    CustomPdfTemplate customTemplate,
    int totalPages,
  ) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final isDark = false; // Assumir modo claro para PDF
          final widgets = <pw.Widget>[];

          // Header se existir
          final header = customTemplate.createHeader(
            pageNumber: pageNumber,
            totalPages: totalPages,
            isDark: isDark,
            logo: logo,
            font: robotoFont,
          );

          // Imagem da página - centralizada e redimensionada
          widgets.add(
            pw.Center(
              child: pw.Container(
                width:
                    PdfPageFormat.a4.width - 40, // Margem de 20px de cada lado
                height: PdfPageFormat.a4.height -
                    customTemplate.headerHeight -
                    customTemplate.footerHeight -
                    40, // Margem de 20px
                child: pw.Image(
                  pw.MemoryImage(imageBytes),
                  fit: pw.BoxFit.contain,
                  alignment: pw.Alignment.center,
                ),
              ),
            ),
          );

          // Footer
          final footer = customTemplate.createFooter(
            pageNumber: pageNumber,
            totalPages: totalPages,
            isDark: isDark,
            logo: logo,
            font: robotoFont,
          );

          if (footer != null) {
            widgets.add(
              pw.Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: footer,
              ),
            );
          }

          // Header na parte superior
          if (header != null) {
            widgets.add(
              pw.Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: header,
              ),
            );
          }

          return pw.Stack(children: widgets);
        },
      ),
    );
  }

  /// Corta a área sobreposta de um screenshot baseado na sobreposição esperada
  Future<Uint8List> _trimOverlappingArea(Uint8List currentScreenshot,
      Uint8List previousScreenshot, double overlapRatio) async {
    try {
      // Decodificar imagem atual
      final currentImage = img.decodeImage(currentScreenshot);
      if (currentImage == null) return currentScreenshot;

      // Calcular altura de corte baseada na sobreposição esperada
      final overlapHeight = (currentImage.height * overlapRatio).round();

      // Cortar a parte superior que se sobrepõe
      final trimmedImage = img.copyCrop(
        currentImage,
        x: 0,
        y: overlapHeight,
        width: currentImage.width,
        height: currentImage.height - overlapHeight,
      );

      // Recodificar para PNG
      final trimmedBytes = img.encodePng(trimmedImage);
      return Uint8List.fromList(trimmedBytes);
    } catch (e) {
      print('Erro ao cortar sobreposição: $e');
      return currentScreenshot; // Retornar original em caso de erro
    }
  }

  Future<String> _createPdfFromScreenshots(
      List<Uint8List> screenshots, WidgetRef? ref) async {
    final pdf = pw.Document();

    // Carregar o logo do Bloquinho
    final logoBytes = await _loadLogoBytes();
    pw.MemoryImage? logo;
    if (logoBytes != null) {
      logo = pw.MemoryImage(logoBytes);
    }

    // Cor castanha do tema para o texto
    final brownColor =
        PdfColor.fromHex('#5C4033'); // lightTextPrimary do tema classic

    // Carregar fonte que suporta Unicode
    final robotoFont = await PdfGoogleFonts.robotoRegular();

    // Combinar todos os screenshots em uma única imagem vertical
    final combinedImageBytes = await _combineScreenshotsVertically(screenshots);

    if (combinedImageBytes != null) {
      // Criar páginas PDF a partir da imagem combinada
      // Obter template selecionado
      final currentTemplateType =
          ref?.read(pdfTemplateProvider) ?? PdfTemplateType.bloquinho;
      final selectedCustomTemplate = ref?.read(selectedCustomTemplateProvider);

      // Determinar qual template usar
      PdfTemplate template;
      CustomPdfTemplate? customTemplate;

      if (currentTemplateType == PdfTemplateType.custom &&
          selectedCustomTemplate != null) {
        // Usar template customizado
        final customTemplates = ref?.read(customTemplatesProvider) ?? [];
        customTemplate = customTemplates
            .where((t) => t.id == selectedCustomTemplate)
            .firstOrNull;

        if (customTemplate != null) {
          // Criar um template temporário baseado no customizado
          template = PdfTemplate(
            type: PdfTemplateType.custom,
            name: customTemplate.name,
            description: customTemplate.description,
            icon: customTemplate.icon,
            previewColor: customTemplate.previewColor,
          );
        } else {
          // Fallback para template padrão
          template = PdfTemplates.getTemplate(PdfTemplateType.bloquinho);
        }
      } else {
        // Usar template predefinido
        template = PdfTemplates.getTemplate(currentTemplateType);
      }

      if (customTemplate != null) {
        // Usar template customizado
        await _createPdfPagesFromCombinedImageWithCustomTemplate(pdf,
            combinedImageBytes, logo, brownColor, robotoFont, customTemplate);
      } else {
        // Usar template predefinido
        await _createPdfPagesFromCombinedImage(
            pdf, combinedImageBytes, logo, brownColor, robotoFont, template);
      }
    }

    // Limpar PDFs antigos antes de criar o novo
    await _cleanupOldPdfFiles();

    // Obter pasta Downloads do usuário
    String downloadsPath;
    try {
      // Tentar obter a pasta Downloads do usuário
      final userProfile =
          Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
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

    // PDF exportado com sucesso - apenas salvar, não abrir impressora
    print('PDF exportado com sucesso em: $filePath');

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
      final cutoffTime = now.subtract(
          const Duration(hours: 24)); // Limpar arquivos com mais de 24 horas

      for (final file in files) {
        if (file is File &&
            file.path.endsWith('.pdf') &&
            file.path.contains('markdown_export_')) {
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

  /// Construir markdown otimizado
  Widget _buildOptimizedMarkdown(BuildContext context, TextStyle textStyle,
      WidgetRef ref, String sanitizedMarkdown) {
    // Cache de markdown processado
    final cacheKey = sanitizedMarkdown.hashCode;
    final cachedMarkdown = _markdownCache.get(cacheKey);
    final processedMarkdown =
        cachedMarkdown ?? _processMarkdown(sanitizedMarkdown);

    if (cachedMarkdown == null) {
      _markdownCache.put(cacheKey, processedMarkdown);
    }

    return Markdown(
      data: processedMarkdown,
      styleSheet: _buildMarkdownStyleSheet(textStyle),
      builders: _buildMarkdownBuilders(context, ref),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  /// Processar markdown com enhancements
  String _processMarkdown(String rawMarkdown) {
    if (!enableHtmlEnhancements) return rawMarkdown;

    // Windows version - simplified processing
    return rawMarkdown;
  }

  /// Construir style sheet para markdown
  MarkdownStyleSheet _buildMarkdownStyleSheet(TextStyle baseStyle) {
    return MarkdownStyleSheet(
      h1: baseStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: baseStyle.color,
      ),
      h2: baseStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: baseStyle.color,
      ),
      h3: baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: baseStyle.color,
      ),
      h4: baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: baseStyle.color,
      ),
      h5: baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: baseStyle.color,
      ),
      h6: baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: baseStyle.color,
      ),
      p: baseStyle,
      strong: baseStyle.copyWith(fontWeight: FontWeight.bold),
      em: baseStyle.copyWith(fontStyle: FontStyle.italic),
      code: baseStyle.copyWith(
        fontFamily: 'monospace',
        backgroundColor: Colors.grey.withOpacity(0.2),
      ),
      codeblockDecoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      blockquote: baseStyle.copyWith(
        fontStyle: FontStyle.italic,
        color: Colors.grey[600],
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.blue, width: 4),
        ),
        color: Colors.blue.withOpacity(0.1),
      ),
      listBullet: baseStyle,
      tableHead: baseStyle.copyWith(fontWeight: FontWeight.bold),
      tableBody: baseStyle,
    );
  }

  /// Construir builders customizados para markdown
  Map<String, MarkdownElementBuilder> _buildMarkdownBuilders(
      BuildContext context, WidgetRef ref) {
    return {
      'code': CodeElementBuilder(),
      'pre': PreElementBuilder(),
      'math': MathElementBuilder(),
      'diagram': DiagramElementBuilder(),
      'latex': LatexElementBuilder(),
      'mermaid': MermaidElementBuilder(),
      'colored': ColoredTextElementBuilder(),
      'kbd': KbdElementBuilder(),
      'mark': MarkElementBuilder(),
      'sub': SubscriptElementBuilder(),
      'sup': SuperscriptElementBuilder(),
    };
  }
}

/// Remove caracteres inválidos de UTF-16 para evitar crash do Flutter
String sanitizeUtf16(String input) {
  return input.replaceAll(
      RegExp(
          r'([^ -\uD7FF\uE000-\uFFFF]|[\uD800-\uDBFF](?![\uDC00-\uDFFF])|(?<![\uD800-\uDBFF])[\uDC00-\uDFFF])'),
      '');
}

/// Builder para elementos de código
class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final code = sanitizeUtf16(element.textContent);
    final language =
        element.attributes['class']?.replaceAll('language-', '') ?? '';

    return AdvancedCodeBlock(
      code: code,
      language: language,
      showLineNumbers: true,
    );
  }
}

/// Builder para elementos pre
class PreElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final code = sanitizeUtf16(element.textContent);
    return WindowsCodeBlockWidget(
      code: code,
      language: '',
      showLineNumbers: true,
    );
  }
}

/// Builder para elementos matemáticos
class MathElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final math = sanitizeUtf16(element.textContent);
    return Math.tex(
      math,
      textStyle: preferredStyle,
      onErrorFallback: (error) => Text('Erro na fórmula: $error'),
    );
  }
}

/// Builder para diagramas
class DiagramElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final diagram = sanitizeUtf16(element.textContent);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Diagrama: $diagram',
        style: preferredStyle,
      ),
    );
  }
}

/// Builder para LaTeX
class LatexElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final latex = sanitizeUtf16(element.textContent);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'LaTeX: $latex',
        style: preferredStyle,
      ),
    );
  }
}

/// Builder para Mermaid
class MermaidElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final mermaid = sanitizeUtf16(element.textContent);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Mermaid: $mermaid',
        style: preferredStyle,
      ),
    );
  }
}

/// Builder para texto colorido
class ColoredTextElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final text = sanitizeUtf16(element.textContent);
    return Text(
      text,
      style: preferredStyle,
    );
  }
}

/// Builder para teclas
class KbdElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final key = sanitizeUtf16(element.textContent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
      ),
      child: Text(
        key,
        style: preferredStyle?.copyWith(
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Builder para marcação
class MarkElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final text = sanitizeUtf16(element.textContent);
    return Container(
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text,
        style: preferredStyle,
      ),
    );
  }
}

/// Builder para subscrito
class SubscriptElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final text = sanitizeUtf16(element.textContent);
    return Text(
      text,
      style: preferredStyle?.copyWith(
        fontSize: (preferredStyle?.fontSize ?? 14) * 0.7,
      ),
    );
  }
}

/// Builder para sobrescrito
class SuperscriptElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final text = sanitizeUtf16(element.textContent);
    return Text(
      text,
      style: preferredStyle?.copyWith(
        fontSize: (preferredStyle?.fontSize ?? 14) * 0.7,
      ),
    );
  }
}

/// Widget de loader personalizado com logo do Bloquinho
class BloquinhoLoader extends StatefulWidget {
  const BloquinhoLoader({super.key});

  @override
  State<BloquinhoLoader> createState() => _BloquinhoLoaderState();
}

class _BloquinhoLoaderState extends State<BloquinhoLoader>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 200,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo do Bloquinho
            Container(
              width: 48,
              height: 48,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            // Texto de carregamento
            const Text(
              'Exportando PDF...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            // Animação de loading
            SizedBox(
              width: 90,
              height: 14,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: BloquinhoLoaderPainter(_animation.value),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter para a animação do loader
class BloquinhoLoaderPainter extends CustomPainter {
  final double progress;

  BloquinhoLoaderPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    // Desenhar 4 quadrados animados
    for (int i = 0; i < 4; i++) {
      final x = (size.width / 4) * i + (progress * size.width * 0.5);
      final rect = Rect.fromLTWH(x, 0, 16, 14);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
