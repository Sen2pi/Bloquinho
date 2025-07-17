import 'package:flutter/material.dart';
// Windows version - no webview_flutter support

class WebView extends StatelessWidget {
  final String initialUrl;

  const WebView({Key? key, required this.initialUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Windows doesn't support WebView, show a placeholder
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.web,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'WebView não suportado no Windows',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'URL: $initialUrl',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
