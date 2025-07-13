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
    final codeBg = const Color(0xFF23272E);
    final lineNumberColor = Colors.white;
    final borderColor = Colors.white;

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 1100),
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: codeBg,
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
                // Linha vertical branca
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
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
                          color: Colors.white,
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
                      size: 18, color: Colors.white),
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
