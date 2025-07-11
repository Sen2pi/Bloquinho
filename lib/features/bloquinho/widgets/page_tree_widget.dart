
import 'package:flutter/material.dart';

class PageTreeWidget extends StatefulWidget {
  const PageTreeWidget({super.key});

  @override
  State<PageTreeWidget> createState() => _PageTreeWidgetState();
}

class _PageTreeWidgetState extends State<PageTreeWidget> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Page Tree Widget'),
    );
  }
}
