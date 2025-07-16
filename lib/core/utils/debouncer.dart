/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Classe para debounce de operações
class Debouncer {
  final Duration delay;
  Timer? _timer;
  VoidCallback? _lastCallback;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  /// Executar operação com debounce
  void call(VoidCallback callback) {
    _lastCallback = callback;
    _timer?.cancel();
    _timer = Timer(delay, () {
      _lastCallback?.call();
      _lastCallback = null;
    });
  }

  /// Cancelar operação pendente
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _lastCallback = null;
  }

  /// Executar imediatamente se há callback pendente
  void flush() {
    if (_lastCallback != null) {
      _timer?.cancel();
      _lastCallback!.call();
      _lastCallback = null;
    }
  }

  /// Verificar se há operação pendente
  bool get isPending => _timer?.isActive == true;

  /// Dispose do debouncer
  void dispose() {
    cancel();
  }
}

/// Debouncer para operações assíncronas
class AsyncDebouncer {
  final Duration delay;
  Timer? _timer;
  Future<void> Function()? _lastCallback;
  Completer<void>? _completer;

  AsyncDebouncer({this.delay = const Duration(milliseconds: 300)});

  /// Executar operação assíncrona com debounce
  Future<void> call(Future<void> Function() callback) {
    _lastCallback = callback;
    _timer?.cancel();
    
    // Se já existe um completer ativo, complete com o novo
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete();
    }
    
    _completer = Completer<void>();
    
    _timer = Timer(delay, () async {
      try {
        await _lastCallback?.call();
        if (!_completer!.isCompleted) {
          _completer!.complete();
        }
      } catch (e) {
        if (!_completer!.isCompleted) {
          _completer!.completeError(e);
        }
      } finally {
        _lastCallback = null;
      }
    });
    
    return _completer!.future;
  }

  /// Cancelar operação pendente
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _lastCallback = null;
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete();
    }
  }

  /// Executar imediatamente se há callback pendente
  Future<void> flush() async {
    if (_lastCallback != null) {
      _timer?.cancel();
      try {
        await _lastCallback!.call();
        if (!_completer!.isCompleted) {
          _completer!.complete();
        }
      } catch (e) {
        if (!_completer!.isCompleted) {
          _completer!.completeError(e);
        }
      } finally {
        _lastCallback = null;
      }
    }
  }

  /// Verificar se há operação pendente
  bool get isPending => _timer?.isActive == true;

  /// Dispose do debouncer
  void dispose() {
    cancel();
  }
}

/// Throttle - executa no máximo uma vez por período
class Throttler {
  final Duration interval;
  DateTime? _lastExecution;
  Timer? _timer;

  Throttler({this.interval = const Duration(milliseconds: 100)});

  /// Executar operação com throttle
  void call(VoidCallback callback) {
    final now = DateTime.now();
    
    if (_lastExecution == null || now.difference(_lastExecution!) >= interval) {
      // Executar imediatamente
      _lastExecution = now;
      callback();
    } else {
      // Agendar para executar quando o intervalo passar
      _timer?.cancel();
      final timeToWait = interval - now.difference(_lastExecution!);
      _timer = Timer(timeToWait, () {
        _lastExecution = DateTime.now();
        callback();
      });
    }
  }

  /// Cancelar execução agendada
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Verificar se há execução agendada
  bool get isPending => _timer?.isActive == true;

  /// Dispose do throttler
  void dispose() {
    cancel();
  }
}

/// Mixin para adicionar debouncing a qualquer classe
mixin DebounceMixin {
  final Map<String, Debouncer> _debouncers = {};

  /// Debounce uma operação com chave específica
  void debounce(
    String key, 
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _debouncers[key] ??= Debouncer(delay: delay);
    _debouncers[key]!.call(callback);
  }

  /// Cancelar debounce específico
  void cancelDebounce(String key) {
    _debouncers[key]?.cancel();
  }

  /// Executar debounce específico imediatamente
  void flushDebounce(String key) {
    _debouncers[key]?.flush();
  }

  /// Limpar todos os debouncers
  void disposeAllDebouncers() {
    for (final debouncer in _debouncers.values) {
      debouncer.dispose();
    }
    _debouncers.clear();
  }
}

/// Mixin para debouncing assíncrono
mixin AsyncDebounceMixin {
  final Map<String, AsyncDebouncer> _asyncDebouncers = {};

  /// Debounce uma operação assíncrona com chave específica
  Future<void> debounceAsync(
    String key, 
    Future<void> Function() callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _asyncDebouncers[key] ??= AsyncDebouncer(delay: delay);
    return _asyncDebouncers[key]!.call(callback);
  }

  /// Cancelar debounce assíncrono específico
  void cancelAsyncDebounce(String key) {
    _asyncDebouncers[key]?.cancel();
  }

  /// Executar debounce assíncrono específico imediatamente
  Future<void> flushAsyncDebounce(String key) async {
    await _asyncDebouncers[key]?.flush();
  }

  /// Limpar todos os debouncers assíncronos
  void disposeAllAsyncDebouncers() {
    for (final debouncer in _asyncDebouncers.values) {
      debouncer.dispose();
    }
    _asyncDebouncers.clear();
  }
}