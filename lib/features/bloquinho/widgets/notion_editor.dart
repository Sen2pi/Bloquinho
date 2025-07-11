import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';

class NotionEditor extends ConsumerStatefulWidget {
  final String initialContent;
  final Function(String) onContentChanged;
  final bool isReadOnly;

  const NotionEditor({
    super.key,
    this.initialContent = '',
    required this.onContentChanged,
    this.isReadOnly = false,
  });

  @override
  ConsumerState<NotionEditor> createState() => _NotionEditorState();
}

class _NotionEditorState extends ConsumerState<NotionEditor> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool _showSlashMenu = false;
  int _slashPosition = 0;
  List<String> _slashCommands = [
    '/text',
    '/heading1',
    '/heading2',
    '/heading3',
    '/bullet',
    '/numbered',
    '/todo',
    '/code',
    '/quote',
    '/divider',
    '/table',
    '/image',
    '/link'
  ];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialContent;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    _checkForSlashCommand(text);
    widget.onContentChanged(text);
  }

  void _checkForSlashCommand(String text) {
    final cursorPosition = _controller.selection.baseOffset;
    if (cursorPosition > 0) {
      final beforeCursor = text.substring(0, cursorPosition);
      final lastSlashIndex = beforeCursor.lastIndexOf('/');

      if (lastSlashIndex != -1 && lastSlashIndex < cursorPosition - 1) {
        final afterSlash = beforeCursor.substring(lastSlashIndex + 1);
        if (afterSlash.isEmpty || afterSlash.contains(' ')) {
          setState(() {
            _showSlashMenu = false;
          });
          return;
        }

        setState(() {
          _showSlashMenu = true;
          _slashPosition = lastSlashIndex;
        });
      } else {
        setState(() {
          _showSlashMenu = false;
        });
      }
    }
  }

  void _insertSlashCommand(String command) {
    final cursorPosition = _controller.selection.baseOffset;
    final text = _controller.text;
    final beforeSlash = text.substring(0, _slashPosition);
    final afterCursor = text.substring(cursorPosition);

    String replacement;
    switch (command) {
      case '/heading1':
        replacement = '# ';
        break;
      case '/heading2':
        replacement = '## ';
        break;
      case '/heading3':
        replacement = '### ';
        break;
      case '/bullet':
        replacement = '• ';
        break;
      case '/numbered':
        replacement = '1. ';
        break;
      case '/todo':
        replacement = '☐ ';
        break;
      case '/code':
        replacement = '```\n\n```';
        break;
      case '/quote':
        replacement = '> ';
        break;
      case '/divider':
        replacement = '---\n';
        break;
      default:
        replacement = '';
    }

    final newText = beforeSlash + replacement + afterCursor;
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(
      offset: _slashPosition + replacement.length,
    );

    setState(() {
      _showSlashMenu = false;
    });
  }

  void _handlePaste() {
    Clipboard.getData(Clipboard.kTextPlain).then((data) {
      if (data?.text != null) {
        final pastedText = data!.text!;
        final convertedText = _convertMarkdownToRichText(pastedText);

        final cursorPosition = _controller.selection.baseOffset;
        final text = _controller.text;
        final beforeCursor = text.substring(0, cursorPosition);
        final afterCursor = text.substring(cursorPosition);

        final newText = beforeCursor + convertedText + afterCursor;
        _controller.text = newText;
        _controller.selection = TextSelection.collapsed(
          offset: cursorPosition + convertedText.length,
        );
      }
    });
  }

  String _convertMarkdownToRichText(String markdown) {
    String result = markdown;

    // Headers
    result = result.replaceAllMapped(
      RegExp(r'^### (.+)$', multiLine: true),
      (match) => '### ${match[1]}\n',
    );
    result = result.replaceAllMapped(
      RegExp(r'^## (.+)$', multiLine: true),
      (match) => '## ${match[1]}\n',
    );
    result = result.replaceAllMapped(
      RegExp(r'^# (.+)$', multiLine: true),
      (match) => '# ${match[1]}\n',
    );

    // Bold and italic
    result = result.replaceAll('**', '**');
    result = result.replaceAll('*', '*');

    // Lists
    result = result.replaceAllMapped(
      RegExp(r'^- (.+)$', multiLine: true),
      (match) => '• ${match[1]}\n',
    );
    result = result.replaceAllMapped(
      RegExp(r'^\d+\. (.+)$', multiLine: true),
      (match) => '1. ${match[1]}\n',
    );

    // Code blocks
    result = result.replaceAllMapped(
      RegExp(r'```(.+?)```', dotAll: true),
      (match) => '```\n${match[1]}\n```\n',
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            scrollController: _scrollController,
            enabled: !widget.isReadOnly,
            maxLines: null,
            expands: true,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Digite / para comandos...',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
            onTap: () {
              if (_showSlashMenu) {
                setState(() {
                  _showSlashMenu = false;
                });
              }
            },
            onChanged: (value) {
              // Handled by _onTextChanged
            },
            inputFormatters: [
              FilteringTextInputFormatter.deny(
                  RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]')),
            ],
          ),
        ),
        if (_showSlashMenu)
          Positioned(
            left: 16,
            top: _calculateSlashMenuPosition(),
            child: _buildSlashMenu(isDarkMode),
          ),
      ],
    );
  }

  double _calculateSlashMenuPosition() {
    // Calcular posição baseada na posição do cursor
    final lineHeight = 20.0;
    final lines = _controller.text.substring(0, _slashPosition).split('\n');
    return (lines.length - 1) * lineHeight + 60;
  }

  Widget _buildSlashMenu(bool isDarkMode) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _slashCommands.map((command) {
          return ListTile(
            dense: true,
            leading: _getCommandIcon(command),
            title: Text(
              command.substring(1),
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            onTap: () => _insertSlashCommand(command),
          );
        }).toList(),
      ),
    );
  }

  Widget _getCommandIcon(String command) {
    IconData icon;
    switch (command) {
      case '/text':
        icon = PhosphorIcons.textT();
        break;
      case '/heading1':
        icon = PhosphorIcons.textH();
        break;
      case '/heading2':
        icon = PhosphorIcons.textH();
        break;
      case '/heading3':
        icon = PhosphorIcons.textH();
        break;
      case '/bullet':
        icon = PhosphorIcons.list();
        break;
      case '/numbered':
        icon = PhosphorIcons.listNumbers();
        break;
      case '/todo':
        icon = PhosphorIcons.checkSquare();
        break;
      case '/code':
        icon = PhosphorIcons.code();
        break;
      case '/quote':
        icon = PhosphorIcons.quotes();
        break;
      case '/divider':
        icon = PhosphorIcons.minus();
        break;
      case '/table':
        icon = PhosphorIcons.table();
        break;
      case '/image':
        icon = PhosphorIcons.image();
        break;
      case '/link':
        icon = PhosphorIcons.link();
        break;
      default:
        icon = PhosphorIcons.textT();
    }

    return Icon(
      icon,
      size: 16,
      color: AppColors.primary,
    );
  }
}
