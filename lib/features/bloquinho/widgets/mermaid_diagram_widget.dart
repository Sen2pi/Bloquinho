import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
// Para Windows
import 'package:webview_windows/webview_windows.dart'
    if (dart.library.io) 'package:webview_windows/webview_windows.dart';

class WindowsMermaidDiagramWidget extends ConsumerStatefulWidget {
  final String diagram;
  final double? height;

  const WindowsMermaidDiagramWidget({
    super.key,
    required this.diagram,
    this.height,
  });

  @override
  ConsumerState<WindowsMermaidDiagramWidget> createState() =>
      _WindowsMermaidDiagramWidgetState();
}

class _WindowsMermaidDiagramWidgetState
    extends ConsumerState<WindowsMermaidDiagramWidget> {
  WebviewController? _webviewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      _initializeWindowsWebView();
    }
  }

  Future<void> _initializeWindowsWebView() async {
    try {
      _webviewController = WebviewController();
      await _webviewController!.initialize();
      await _webviewController!.loadHtmlString(_generateMermaidHtml());

      setState(() => _isLoading = false);
    } catch (e) {
      print('Erro ao inicializar WebView Windows: $e');
      setState(() => _isLoading = false);
    }
  }

  String _generateMermaidHtml() {
    final isDarkMode = ref.read(isDarkModeProvider);
    final theme = isDarkMode ? 'dark' : 'default';

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <script src="https://cdn.jsdelivr.net/npm/mermaid@10.6.1/dist/mermaid.min.js"></script>
    <style>
        body {
            margin: 0;
            padding: 20px;
            background-color: ${isDarkMode ? '#1E293B' : '#FFFFFF'};
            font-family: 'Inter', sans-serif;
        }
        .mermaid {
            display: flex;
            justify-content: center;
            align-items: center;
        }
    </style>
</head>
<body>
    <div class="mermaid">
${widget.diagram}
    </div>
    
    <script>
        mermaid.initialize({
            startOnLoad: true,
            theme: '$theme',
            securityLevel: 'loose',
            flowchart: {
                useMaxWidth: true,
                htmlLabels: true
            }
        });
    </script>
</body>
</html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows) {
      // Fallback para outras plataformas
      return _buildFallbackView();
    }

    return Container(
      height: widget.height ?? 400,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _webviewController != null
                ? Webview(_webviewController!)
                : _buildErrorView(),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Erro ao carregar diagrama Mermaid'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (mounted) _initializeWindowsWebView();
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackView() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_tree, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('Diagrama Mermaid',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.diagram,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _webviewController?.dispose();
    super.dispose();
  }
}
