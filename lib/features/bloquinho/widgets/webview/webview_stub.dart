import 'package:flutter/widgets.dart';

class WebView extends StatelessWidget {
  final String initialUrl;

  const WebView({Key? key, required this.initialUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // On web, we can't use webview_flutter, so we'll just show a link
    return Center(
      child: Text('WebView is not supported on this platform.'),
    );
  }
}
