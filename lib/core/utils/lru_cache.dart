/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

/// Cache LRU (Least Recently Used) universal para otimização de performance
class LRUCache<K, V> {
  final int maxSize;
  final Map<K, V> _cache = <K, V>{};
  final Map<K, int> _accessOrder = <K, int>{};
  int _accessCounter = 0;

  LRUCache({required this.maxSize}) : assert(maxSize > 0);

  /// Obter valor do cache
  V? get(K key) {
    if (_cache.containsKey(key)) {
      _accessOrder[key] = ++_accessCounter;
      return _cache[key];
    }
    return null;
  }

  /// Adicionar valor ao cache
  void put(K key, V value) {
    // Se cache está cheio e a chave não existe, remover o menos usado
    if (_cache.length >= maxSize && !_cache.containsKey(key)) {
      _evictLeastRecentlyUsed();
    }
    
    _cache[key] = value;
    _accessOrder[key] = ++_accessCounter;
  }

  /// Operador [] para acessar valores
  V? operator [](K key) => get(key);

  /// Operador []= para definir valores
  void operator []=(K key, V value) => put(key, value);

  /// Verificar se chave existe no cache
  bool containsKey(K key) => _cache.containsKey(key);

  /// Remover item do cache
  V? remove(K key) {
    _accessOrder.remove(key);
    return _cache.remove(key);
  }

  /// Limpar cache completamente
  void clear() {
    _cache.clear();
    _accessOrder.clear();
    _accessCounter = 0;
  }

  /// Tamanho atual do cache
  int get size => _cache.length;

  /// Verificar se cache está vazio
  bool get isEmpty => _cache.isEmpty;

  /// Verificar se cache está cheio
  bool get isFull => _cache.length >= maxSize;

  /// Obter todas as chaves (ordenadas por acesso)
  List<K> get keys {
    final sortedEntries = _accessOrder.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.map((e) => e.key).toList();
  }

  /// Remover o item menos recentemente usado
  void _evictLeastRecentlyUsed() {
    if (_accessOrder.isEmpty) return;

    // Encontrar chave com menor contador de acesso
    K? lruKey;
    int minAccess = _accessCounter + 1;

    for (final entry in _accessOrder.entries) {
      if (entry.value < minAccess) {
        minAccess = entry.value;
        lruKey = entry.key;
      }
    }

    if (lruKey != null) {
      _cache.remove(lruKey);
      _accessOrder.remove(lruKey);
    }
  }

  /// Estatísticas do cache para debug
  Map<String, dynamic> get stats => {
    'size': size,
    'maxSize': maxSize,
    'hitRate': _accessCounter > 0 ? (size / _accessCounter * 100) : 0,
    'isFull': isFull,
  };

  @override
  String toString() => 'LRUCache(size: $size/$maxSize, hitRate: ${stats['hitRate'].toStringAsFixed(1)}%)';
}

/// Cache com expiração por tempo
class TimedLRUCache<K, V> extends LRUCache<K, V> {
  final Duration expiration;
  final Map<K, DateTime> _timestamps = <K, DateTime>{};

  TimedLRUCache({
    required super.maxSize, 
    required this.expiration,
  });

  @override
  V? get(K key) {
    if (containsKey(key) && !_isExpired(key)) {
      return super.get(key);
    } else if (_isExpired(key)) {
      remove(key);
    }
    return null;
  }

  @override
  void put(K key, V value) {
    super.put(key, value);
    _timestamps[key] = DateTime.now();
  }

  @override
  V? remove(K key) {
    _timestamps.remove(key);
    return super.remove(key);
  }

  @override
  void clear() {
    super.clear();
    _timestamps.clear();
  }

  /// Verificar se item expirou
  bool _isExpired(K key) {
    final timestamp = _timestamps[key];
    if (timestamp == null) return true;
    return DateTime.now().difference(timestamp) > expiration;
  }

  /// Limpar itens expirados
  void cleanExpired() {
    final expiredKeys = <K>[];
    for (final key in _timestamps.keys) {
      if (_isExpired(key)) {
        expiredKeys.add(key);
      }
    }
    for (final key in expiredKeys) {
      remove(key);
    }
  }
}

/// Cache com callback de computação lazy
class ComputedLRUCache<K, V> extends LRUCache<K, V> {
  final V Function(K key) computeValue;

  ComputedLRUCache({
    required super.maxSize,
    required this.computeValue,
  });

  /// Obter valor, computando se necessário
  V getOrCompute(K key) {
    V? cached = get(key);
    if (cached != null) return cached;

    final computed = computeValue(key);
    put(key, computed);
    return computed;
  }
}