/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import '../../../core/models/app_language.dart';
import '../templates/page_templates_pt.dart';
import '../templates/page_templates_en.dart';
import '../templates/page_templates_fr.dart';

enum PageTemplateType {
  rootPage,
  newPage,
}

class PageTemplateService {
  /// Obter template baseado no idioma e tipo de página
  static String getTemplate(AppLanguage language, PageTemplateType type) {
    switch (language) {
      case AppLanguage.portuguese:
        return _getPortugueseTemplate(type);
      case AppLanguage.english:
        return _getEnglishTemplate(type);
      case AppLanguage.french:
        return _getFrenchTemplate(type);
    }
  }

  /// Obter template em português
  static String _getPortugueseTemplate(PageTemplateType type) {
    switch (type) {
      case PageTemplateType.rootPage:
        return PageTemplatesPt.rootPageTemplate;
      case PageTemplateType.newPage:
        return PageTemplatesPt.newPageTemplate;
    }
  }

  /// Obter template em inglês
  static String _getEnglishTemplate(PageTemplateType type) {
    switch (type) {
      case PageTemplateType.rootPage:
        return PageTemplatesEn.rootPageTemplate;
      case PageTemplateType.newPage:
        return PageTemplatesEn.newPageTemplate;
    }
  }

  /// Obter template em francês
  static String _getFrenchTemplate(PageTemplateType type) {
    switch (type) {
      case PageTemplateType.rootPage:
        return PageTemplatesFr.rootPageTemplate;
      case PageTemplateType.newPage:
        return PageTemplatesFr.newPageTemplate;
    }
  }

  /// Método de conveniência para obter template de página raiz
  static String getRootPageTemplate(AppLanguage language) {
    return getTemplate(language, PageTemplateType.rootPage);
  }

  /// Método de conveniência para obter template de nova página
  static String getNewPageTemplate(AppLanguage language) {
    return getTemplate(language, PageTemplateType.newPage);
  }

  /// Verificar se é uma página que deve usar template de página raiz
  static bool isRootPageCandidate(String title) {
    final normalizedTitle = title.toLowerCase().trim();
    
    // Verificar se é uma página principal ou raiz baseada no título
    const rootPageTitles = [
      'main', 'principal', 'início', 'home', 'accueil', 'root', 'raiz',
      'index', 'dashboard', 'workspace', 'workspace main'
    ];
    
    return rootPageTitles.contains(normalizedTitle);
  }

  /// Obter template apropriado baseado no título e idioma
  static String getAppropriateTemplate(String title, AppLanguage language) {
    if (isRootPageCandidate(title)) {
      return getRootPageTemplate(language);
    } else {
      return getNewPageTemplate(language);
    }
  }
}