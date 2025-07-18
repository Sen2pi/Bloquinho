/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/page_model.dart';

class PageCache {
  final Map<String, PageModel> _cache = {};
  final Map<String, String> _contentCache = {};
  final int maxSize;
  
  PageCache({this.maxSize = 50});

  PageModel? getPage(String pageId) {
    return _cache[pageId];
  }

  void cachePage(String pageId, PageModel page) {
    if (_cache.length >= maxSize) {
      // Remove oldest entry
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }
    _cache[pageId] = page;
  }

  String? getContent(String pageId) {
    return _contentCache[pageId];
  }

  void cacheContent(String pageId, String content) {
    if (_contentCache.length >= maxSize) {
      // Remove oldest entry
      final firstKey = _contentCache.keys.first;
      _contentCache.remove(firstKey);
    }
    _contentCache[pageId] = content;
  }

  void removePage(String pageId) {
    _cache.remove(pageId);
    _contentCache.remove(pageId);
  }

  void clear() {
    _cache.clear();
    _contentCache.clear();
  }

  bool hasPage(String pageId) {
    return _cache.containsKey(pageId);
  }

  bool hasContent(String pageId) {
    return _contentCache.containsKey(pageId);
  }

  int get cacheSize => _cache.length;
  int get contentCacheSize => _contentCache.length;
}

final pageCacheProvider = Provider<PageCache>((ref) {
  return PageCache();
});

// Provider para cache de conteúdo de páginas específicas
final pageContentCacheProvider = Provider.family<String?, String>((ref, pageId) {
  final cache = ref.watch(pageCacheProvider);
  return cache.getContent(pageId);
});

// Provider para invalidar cache quando necessário
final cacheInvalidatorProvider = StateProvider<int>((ref) => 0);

void invalidatePageCache(WidgetRef ref, String pageId) {
  final cache = ref.read(pageCacheProvider);
  cache.removePage(pageId);
  ref.read(cacheInvalidatorProvider.notifier).state++;
}

void clearAllPageCache(WidgetRef ref) {
  final cache = ref.read(pageCacheProvider);
  cache.clear();
  ref.read(cacheInvalidatorProvider.notifier).state++;
}