/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<int>> _metrics = {};
  Timer? _reportTimer;

  void startTimer(String operation) {
    if (kDebugMode) {
      _timers[operation] = Stopwatch()..start();
    }
  }

  void stopTimer(String operation) {
    if (kDebugMode && _timers.containsKey(operation)) {
      final stopwatch = _timers[operation]!;
      stopwatch.stop();
      
      final duration = stopwatch.elapsedMilliseconds;
      _metrics.putIfAbsent(operation, () => []).add(duration);
      
      // Keep only last 100 measurements
      if (_metrics[operation]!.length > 100) {
        _metrics[operation]!.removeAt(0);
      }
      
      _timers.remove(operation);
      
      // Log slow operations
      if (duration > 100) {
        debugPrint('⚠️ Slow operation: $operation took ${duration}ms');
      }
    }
  }

  void startPeriodicReporting() {
    if (kDebugMode) {
      _reportTimer?.cancel();
      _reportTimer = Timer.periodic(const Duration(minutes: 1), (_) {
        _reportMetrics();
      });
    }
  }

  void stopPeriodicReporting() {
    _reportTimer?.cancel();
  }

  void _reportMetrics() {
    if (_metrics.isEmpty) return;
    
    debugPrint('📊 Performance Report:');
    for (final entry in _metrics.entries) {
      final operation = entry.key;
      final times = entry.value;
      
      if (times.isNotEmpty) {
        final avg = times.reduce((a, b) => a + b) / times.length;
        final max = times.reduce((a, b) => a > b ? a : b);
        debugPrint('  $operation: avg ${avg.toStringAsFixed(1)}ms, max ${max}ms');
      }
    }
  }

  void clearMetrics() {
    _metrics.clear();
  }

  // Frame rate monitoring
  void startFrameRateMonitoring() {
    if (kDebugMode) {
      SchedulerBinding.instance.addTimingsCallback(_onFrameRendered);
    }
  }

  void stopFrameRateMonitoring() {
    if (kDebugMode) {
      SchedulerBinding.instance.removeTimingsCallback(_onFrameRendered);
    }
  }

  void _onFrameRendered(List<FrameTiming> timings) {
    for (final timing in timings) {
      final frameDuration = timing.totalSpan.inMilliseconds;
      
      // Log frames that take longer than 16ms (60fps)
      if (frameDuration > 16) {
        debugPrint('🐌 Slow frame: ${frameDuration}ms');
      }
    }
  }
}

// Mixin para facilitar o uso do monitor de performance
mixin PerformanceTracking {
  final PerformanceMonitor _monitor = PerformanceMonitor();

  void trackOperation(String operation, VoidCallback callback) {
    _monitor.startTimer(operation);
    try {
      callback();
    } finally {
      _monitor.stopTimer(operation);
    }
  }

  Future<T> trackAsyncOperation<T>(String operation, Future<T> Function() callback) async {
    _monitor.startTimer(operation);
    try {
      return await callback();
    } finally {
      _monitor.stopTimer(operation);
    }
  }
}

// Widget para monitorar performance de renderização
class PerformanceWrapper extends StatefulWidget {
  final Widget child;
  final String? label;

  const PerformanceWrapper({
    super.key,
    required this.child,
    this.label,
  });

  @override
  State<PerformanceWrapper> createState() => _PerformanceWrapperState();
}

class _PerformanceWrapperState extends State<PerformanceWrapper> with PerformanceTracking {
  @override
  Widget build(BuildContext context) {
    final label = widget.label ?? 'Widget_${widget.runtimeType}';
    
    return Builder(
      builder: (context) {
        trackOperation('${label}_build', () {});
        return widget.child;
      },
    );
  }
}