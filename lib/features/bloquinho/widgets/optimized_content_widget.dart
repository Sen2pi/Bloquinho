/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class OptimizedContentWidget extends ConsumerStatefulWidget {
  final String content;
  final Widget Function(String content) builder;
  final Duration debounceDelay;

  const OptimizedContentWidget({
    super.key,
    required this.content,
    required this.builder,
    this.debounceDelay = const Duration(milliseconds: 300),
  });

  @override
  ConsumerState<OptimizedContentWidget> createState() => _OptimizedContentWidgetState();
}

class _OptimizedContentWidgetState extends ConsumerState<OptimizedContentWidget> {
  String _debouncedContent = '';
  Timer? _debounceTimer;
  Widget? _cachedWidget;
  String? _lastRenderedContent;

  @override
  void initState() {
    super.initState();
    _debouncedContent = widget.content;
    _renderContent();
  }

  @override
  void didUpdateWidget(OptimizedContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.content != widget.content) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.debounceDelay, () {
        if (mounted) {
          setState(() {
            _debouncedContent = widget.content;
            _renderContent();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _renderContent() {
    if (_lastRenderedContent != _debouncedContent) {
      _cachedWidget = widget.builder(_debouncedContent);
      _lastRenderedContent = _debouncedContent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _cachedWidget ?? widget.builder(_debouncedContent);
  }
}

class LazyRenderList extends StatefulWidget {
  final List<Widget> children;
  final int initialRenderCount;
  final Duration renderDelay;

  const LazyRenderList({
    super.key,
    required this.children,
    this.initialRenderCount = 5,
    this.renderDelay = const Duration(milliseconds: 16),
  });

  @override
  State<LazyRenderList> createState() => _LazyRenderListState();
}

class _LazyRenderListState extends State<LazyRenderList> {
  int _renderedCount = 0;
  Timer? _renderTimer;

  @override
  void initState() {
    super.initState();
    _renderedCount = widget.initialRenderCount.clamp(0, widget.children.length);
    _scheduleNextRender();
  }

  @override
  void dispose() {
    _renderTimer?.cancel();
    super.dispose();
  }

  void _scheduleNextRender() {
    if (_renderedCount < widget.children.length) {
      _renderTimer = Timer(widget.renderDelay, () {
        if (mounted) {
          setState(() {
            _renderedCount = (_renderedCount + 1).clamp(0, widget.children.length);
          });
          _scheduleNextRender();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...widget.children.take(_renderedCount),
        if (_renderedCount < widget.children.length)
          const SizedBox(
            height: 20,
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class MemoizedWidget extends StatelessWidget {
  final String content;
  final Widget Function(String content) builder;
  static final Map<String, Widget> _cache = {};
  static const int maxCacheSize = 100;

  const MemoizedWidget({
    super.key,
    required this.content,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final cacheKey = content.hashCode.toString();
    
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final widget = builder(content);
    
    // Limitar tamanho do cache
    if (_cache.length >= maxCacheSize) {
      _cache.clear();
    }
    
    _cache[cacheKey] = widget;
    return widget;
  }

  static void clearCache() {
    _cache.clear();
  }
}

class ThrottledBuilder extends StatefulWidget {
  final Widget Function() builder;
  final Duration throttleDuration;

  const ThrottledBuilder({
    super.key,
    required this.builder,
    this.throttleDuration = const Duration(milliseconds: 100),
  });

  @override
  State<ThrottledBuilder> createState() => _ThrottledBuilderState();
}

class _ThrottledBuilderState extends State<ThrottledBuilder> {
  Timer? _throttleTimer;
  bool _needsRebuild = false;
  Widget? _cachedWidget;

  @override
  void initState() {
    super.initState();
    _cachedWidget = widget.builder();
  }

  @override
  void didUpdateWidget(ThrottledBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (_throttleTimer?.isActive == true) {
      _needsRebuild = true;
    } else {
      _rebuild();
    }
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    super.dispose();
  }

  void _rebuild() {
    _throttleTimer?.cancel();
    _throttleTimer = Timer(widget.throttleDuration, () {
      if (mounted) {
        setState(() {
          _cachedWidget = widget.builder();
          _needsRebuild = false;
        });
        
        if (_needsRebuild) {
          _rebuild();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _cachedWidget ?? widget.builder();
  }
}