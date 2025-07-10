import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../models/page_models.dart';

/// Widget para preview em tempo real do markdown
class MarkdownPreviewWidget extends StatelessWidget {
  final String markdown;
  final bool isDarkMode;
  final bool isEditing;
  final VoidCallback? onEdit;

  const MarkdownPreviewWidget({
    super.key,
    required this.markdown,
    this.isDarkMode = false,
    this.isEditing = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (markdown.trim().isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.blockBackgroundDark
            : AppColors.blockBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode
              ? AppColors.darkBorder.withOpacity(0.3)
              : AppColors.lightBorder.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do preview
          Row(
            children: [
              Icon(
                PhosphorIcons.eye(),
                size: 16,
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Preview',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const Spacer(),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    PhosphorIcons.pencil(),
                    size: 14,
                    color: isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Divider
          Container(
            height: 1,
            color: isDarkMode
                ? AppColors.darkBorder.withOpacity(0.2)
                : AppColors.lightBorder.withOpacity(0.2),
          ),
          const SizedBox(height: 12),

          // Conteúdo markdown renderizado
          MarkdownBody(
            data: markdown,
            styleSheet: _buildMarkdownStyle(context),
            selectable: true,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.blockBackgroundDark.withOpacity(0.5)
            : AppColors.blockBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode
              ? AppColors.darkBorder.withOpacity(0.2)
              : AppColors.lightBorder.withOpacity(0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.textT(),
            size: 32,
            color: isDarkMode
                ? AppColors.darkTextSecondary.withOpacity(0.5)
                : AppColors.lightTextSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Comece a digitar para ver o preview',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode
                  ? AppColors.darkTextSecondary.withOpacity(0.7)
                  : AppColors.lightTextSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Use # para títulos, **texto** para negrito',
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode
                  ? AppColors.darkTextSecondary.withOpacity(0.5)
                  : AppColors.lightTextSecondary.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyle(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return MarkdownStyleSheet(
      p: theme.textTheme.bodyMedium?.copyWith(
        color: textColor,
        height: 1.5,
      ),
      h1: theme.textTheme.headlineLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      h2: theme.textTheme.headlineMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      h3: theme.textTheme.headlineSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      h4: theme.textTheme.titleLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
      h5: theme.textTheme.titleMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
      h6: theme.textTheme.titleSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
      em: TextStyle(
        fontStyle: FontStyle.italic,
        color: textColor,
      ),
      strong: TextStyle(
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      del: TextStyle(
        decoration: TextDecoration.lineThrough,
        color: textColor.withOpacity(0.6),
      ),
      blockquote: theme.textTheme.bodyMedium?.copyWith(
        color: textColor.withOpacity(0.8),
        fontStyle: FontStyle.italic,
      ),
      code: TextStyle(
        backgroundColor:
            isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        color: isDarkMode ? Colors.lightBlue.shade300 : Colors.blue.shade800,
        fontFamily: 'monospace',
        fontSize: 13,
      ),
      codeblockDecoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      listBullet: TextStyle(color: textColor),
      tableHead: TextStyle(
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      tableBody: TextStyle(color: textColor),
      tableBorder: TableBorder.all(
        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
      ),
      a: TextStyle(
        color: AppColors.primary,
        decoration: TextDecoration.underline,
      ),
    );
  }
}

/// Widget que combina editor e preview lado a lado
class SplitEditorWidget extends StatefulWidget {
  final String initialText;
  final bool isDarkMode;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const SplitEditorWidget({
    super.key,
    required this.initialText,
    this.isDarkMode = false,
    this.onChanged,
    this.focusNode,
  });

  @override
  State<SplitEditorWidget> createState() => _SplitEditorWidgetState();
}

class _SplitEditorWidgetState extends State<SplitEditorWidget> {
  late TextEditingController _controller;
  bool _showPreview = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    widget.onChanged?.call(_controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar de controles
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isDarkMode
                ? AppColors.sidebarBackgroundDark
                : AppColors.sidebarBackground,
            border: Border(
              bottom: BorderSide(
                color: widget.isDarkMode
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Editor',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showPreview = !_showPreview;
                  });
                },
                icon: Icon(
                  _showPreview ? PhosphorIcons.eyeSlash() : PhosphorIcons.eye(),
                  size: 16,
                ),
                tooltip: _showPreview ? 'Ocultar preview' : 'Mostrar preview',
              ),
            ],
          ),
        ),

        // Conteúdo principal
        Expanded(
          child: _showPreview
              ? Row(
                  children: [
                    // Editor
                    Expanded(
                      child: _buildEditor(),
                    ),

                    // Divisor
                    Container(
                      width: 1,
                      color: widget.isDarkMode
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),

                    // Preview
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: MarkdownPreviewWidget(
                          markdown: _controller.text,
                          isDarkMode: widget.isDarkMode,
                        ),
                      ),
                    ),
                  ],
                )
              : _buildEditor(),
        ),
      ],
    );
  }

  Widget _buildEditor() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
          fontFamily: 'monospace',
          color: widget.isDarkMode
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText:
              'Digite seu conteúdo aqui...\n\n# Use markdown\n**negrito** *itálico*\n- lista\n1. numerada\n> citação',
          hintStyle: TextStyle(
            color: widget.isDarkMode
                ? AppColors.darkTextSecondary.withOpacity(0.5)
                : AppColors.lightTextSecondary.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
