import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:flutter/services.dart';

class AdvancedCodeBlock extends StatefulWidget {
  final String code;
  final String? language;
  final bool showLineNumbers;
  final double fontSize;
  final EdgeInsets padding;

  const AdvancedCodeBlock({
    super.key,
    required this.code,
    this.language,
    this.showLineNumbers = true,
    this.fontSize = 14,
    this.padding = const EdgeInsets.all(5),
  });

  @override
  State<AdvancedCodeBlock> createState() => _AdvancedCodeBlockState();
}

class _AdvancedCodeBlockState extends State<AdvancedCodeBlock> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final lines = widget.code.split('\n');
    final maxLineNumber = lines.length;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final containerBg = isDark
        ? const Color(0xFF2D3748)
        : const Color(0xFFF7FAFC); // Cinza claro
    final lineNumberColor = isDark
        ? const Color(0xFFA0AEC0)
        : const Color(0xFF718096); // Cinza claro
    final codeBg = Colors.transparent; // Fundo transparente

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 1100),
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: containerBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Números de linha
                if (widget.showLineNumbers)
                  Container(
                    padding: const EdgeInsets.only(
                        left: 12, right: 8, top: 8, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(
                        maxLineNumber,
                        (i) => Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: lineNumberColor,
                            fontSize: widget.fontSize,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ),
                // Código
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: widget.padding,
                      child: HighlightView(
                        widget.code,
                        language: widget.language ?? 'dart',
                        theme: vs2015Theme,
                        padding: EdgeInsets.zero,
                        textStyle: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: widget.fontSize,
                          height: 1.5,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Botão copiar
            Positioned(
              top: 8,
              right: 16,
              child: Tooltip(
                message: _copied ? 'Copiado!' : 'Copiar código',
                child: IconButton(
                  icon: Icon(_copied ? Icons.check : Icons.copy_rounded,
                      size: 18, color: lineNumberColor),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: widget.code));
                    setState(() => _copied = true);
                    await Future.delayed(const Duration(seconds: 1));
                    setState(() => _copied = false);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
