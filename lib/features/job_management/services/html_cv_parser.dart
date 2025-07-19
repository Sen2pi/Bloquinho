/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import '../models/cv_model.dart';

class HtmlCvParser {
  Future<Map<String, dynamic>> parseHtml(String htmlContent) async {
    // Parser simplificado que extrai metadados básicos do HTML Europass
    
    final result = <String, dynamic>{
      'name': _extractName(htmlContent),
      'targetPosition': _extractTargetPosition(htmlContent),
      'email': _extractEmail(htmlContent),
      'phone': _extractPhone(htmlContent),
      'address': _extractAddress(htmlContent),
      'linkedin': _extractLinkedIn(htmlContent),
      'github': _extractGitHub(htmlContent),
      'website': _extractWebsite(htmlContent),
      'personalSummary': _extractPersonalSummary(htmlContent),
      'skills': _extractSkills(htmlContent),
      'languages': _extractLanguages(htmlContent),
      'certifications': _extractCertifications(htmlContent),
              'experiences': _extractExperiences(htmlContent),
        'education': _extractEducation(htmlContent),
        'projects': _extractProjects(htmlContent),
    };

    return result;
  }

  String _extractName(String htmlContent) {
    // Extrai o nome do título da página ou tag h1
    final titleMatch = RegExp(r'<title[^>]*>.*?–\s*([^<]+)</title>').firstMatch(htmlContent);
    if (titleMatch != null) {
      return titleMatch.group(1)?.trim() ?? '';
    }
    
    final h1Match = RegExp(r'<h1[^>]*>([^<]+)</h1>').firstMatch(htmlContent);
    if (h1Match != null) {
      return h1Match.group(1)?.trim() ?? '';
    }
    
    return '';
  }

  String _extractTargetPosition(String htmlContent) {
    // Para CVs Europass, pode estar em subtítulos
    final positionMatch = RegExp(r'<h3[^>]*>([^<]*(?:Developer|Engineer|Manager|Analyst|Lead|CEO|CTO)[^<]*)</h3>').firstMatch(htmlContent);
    if (positionMatch != null) {
      return positionMatch.group(1)?.trim() ?? '';
    }
    return '';
  }

  String _extractEmail(String htmlContent) {
    final emailMatch = RegExp(r'[\w\.-]+@[\w\.-]+\.\w+').firstMatch(htmlContent);
    return emailMatch?.group(0) ?? '';
  }

  String _extractPhone(String htmlContent) {
    final phoneMatch = RegExp(r'\+?[\d\s\-\(\)]{7,15}').firstMatch(htmlContent);
    return phoneMatch?.group(0)?.trim() ?? '';
  }

  String _extractAddress(String htmlContent) {
    // Procura por endereços em elementos da tabela de informações
    final addressMatch = RegExp(r'<td>([^<]*(?:Rua|Avenida|Street|Avenue)[^<]*)</td>').firstMatch(htmlContent);
    return addressMatch?.group(1)?.trim() ?? '';
  }

  String _extractLinkedIn(String htmlContent) {
    final linkedinMatch = RegExp(r'linkedin\.com/[^\s"<>]+').firstMatch(htmlContent);
    if (linkedinMatch != null) {
      return 'https://${linkedinMatch.group(0)}';
    }
    return '';
  }

  String _extractGitHub(String htmlContent) {
    final githubMatch = RegExp(r'github\.com/[^\s"<>]+').firstMatch(htmlContent);
    if (githubMatch != null) {
      return 'https://${githubMatch.group(0)}';
    }
    return '';
  }

  String _extractWebsite(String htmlContent) {
    // Procura por links que não sejam redes sociais
    final websiteMatches = RegExp(r'https?://[^\s"<>]+').allMatches(htmlContent);
    for (final match in websiteMatches) {
      final url = match.group(0) ?? '';
      if (!url.contains('linkedin.com') && 
          !url.contains('github.com') && 
          !url.contains('facebook.com') && 
          !url.contains('twitter.com')) {
        return url;
      }
    }
    return '';
  }

  String _extractPersonalSummary(String htmlContent) {
    // Procura por seções de perfil profissional
    final summaryMatch = RegExp(r'<h2[^>]*>(?:Profil|Profile|Resumo|Summary)[^<]*</h2>\s*<[^>]*>\s*<p[^>]*>([^<]+)</p>', caseSensitive: false).firstMatch(htmlContent);
    if (summaryMatch != null) {
      return summaryMatch.group(1)?.trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';
    }
    return '';
  }

  List<String> _extractSkills(String htmlContent) {
    final skills = <String>[];
    
    // Procura por tabelas de competências
    final skillsSection = RegExp(r'<h2[^>]*>(?:Compétences|Skills|Competências)[^<]*</h2>.*?(?=<h2|$)', caseSensitive: false, dotAll: true).firstMatch(htmlContent);
    
    if (skillsSection != null) {
      final skillsContent = skillsSection.group(0) ?? '';
      
      // Extrai conteúdo de células da tabela
      final cellMatches = RegExp(r'<td[^>]*>([^<]+)</td>').allMatches(skillsContent);
      for (final match in cellMatches) {
        final content = match.group(1)?.trim() ?? '';
        if (content.isNotEmpty && !content.contains('&') && content.length > 2) {
          // Divide por vírgulas se houver
          if (content.contains(',')) {
            skills.addAll(content.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty));
          } else {
            skills.add(content);
          }
        }
      }
    }
    
    return skills.toSet().toList(); // Remove duplicatas
  }

  List<String> _extractLanguages(String htmlContent) {
    final languages = <String>[];
    
    // Procura por seção de idiomas
    final languageSection = RegExp(r'<h2[^>]*>(?:Langues|Languages|Idiomas)[^<]*</h2>.*?(?=<h2|$)', caseSensitive: false, dotAll: true).firstMatch(htmlContent);
    
    if (languageSection != null) {
      final languageContent = languageSection.group(0) ?? '';
      
      // Procura por nomes de idiomas em cabeçalhos de tabela
      final languageMatches = RegExp(r'<th[^>]*>([^<]+)</th>').allMatches(languageContent);
      for (final match in languageMatches) {
        final language = match.group(1)?.trim() ?? '';
        if (language.isNotEmpty && language.length > 2) {
          languages.add(language);
        }
      }
    }
    
    return languages.toSet().toList();
  }

  List<String> _extractCertifications(String htmlContent) {
    final certifications = <String>[];
    
    // Procura por seção de formação e certificações
    final certSection = RegExp(r'<h2[^>]*>(?:Formation|Education|Formação|Certification)[^<]*</h2>.*?(?=<h2|$)', caseSensitive: false, dotAll: true).firstMatch(htmlContent);
    
    if (certSection != null) {
      final certContent = certSection.group(0) ?? '';
      
      // Procura por itens de lista
      final listMatches = RegExp(r'<li[^>]*>([^<]+)</li>').allMatches(certContent);
      for (final match in listMatches) {
        final cert = match.group(1)?.trim() ?? '';
        if (cert.isNotEmpty) {
          certifications.add(cert);
        }
      }
    }
    
          return certifications.toSet().toList();
    }

    List<WorkExperience> _extractExperiences(String htmlContent) {
      final experiences = <WorkExperience>[];
      
      // Procura por seção de experiências profissionais
      final experienceSection = RegExp(
        r'<h2[^>]*>(?:Expériences Professionnelles|Professional Experience|Experiências)[^<]*</h2>.*?(?=<h2|$)',
        caseSensitive: false,
        dotAll: true,
      ).firstMatch(htmlContent);
      
      if (experienceSection != null) {
        final experienceContent = experienceSection.group(0) ?? '';
        
        // Procura por cada experiência (h3 seguido de ul)
        final experienceMatches = RegExp(
          r'<h3[^>]*>([^<]+)</h3>\s*<ul[^>]*>(.*?)</ul>',
          caseSensitive: false,
          dotAll: true,
        ).allMatches(experienceContent);
        
        for (final match in experienceMatches) {
          final title = match.group(1)?.trim() ?? '';
          final description = match.group(2)?.trim() ?? '';
          
          if (title.isNotEmpty) {
            // Extrai informações da empresa e cargo
            final companyMatch = RegExp(r'^([^(]+)').firstMatch(title);
            final positionMatch = RegExp(r'—\s*([^(]+)').firstMatch(title);
            final periodMatch = RegExp(r'\(([^)]+)\)').firstMatch(title);
            
            final company = companyMatch?.group(1)?.trim() ?? '';
            final position = positionMatch?.group(1)?.trim() ?? '';
            final period = periodMatch?.group(1)?.trim() ?? '';
            
            // Extrai datas do período
            final dates = _extractDates(period);
            
            // Extrai descrição dos itens da lista
            final achievements = _extractListItems(description);
            
            if (company.isNotEmpty) {
              experiences.add(WorkExperience.create(
                company: company,
                position: position.isNotEmpty ? position : 'Cargo não especificado',
                startDate: dates['start'] ?? DateTime.now(),
                endDate: dates['end'],
                description: achievements.isNotEmpty ? achievements.join('\n') : null,
                achievements: achievements,
              ));
            }
          }
        }
      }
      
      return experiences;
    }

    List<Education> _extractEducation(String htmlContent) {
      final education = <Education>[];
      
      // Procura por seção de formação
      final educationSection = RegExp(
        r'<h2[^>]*>(?:Formation|Education|Formação)[^<]*</h2>.*?(?=<h2|$)',
        caseSensitive: false,
        dotAll: true,
      ).firstMatch(htmlContent);
      
      if (educationSection != null) {
        final educationContent = educationSection.group(0) ?? '';
        
        // Procura por itens de lista de formação
        final listMatches = RegExp(r'<li[^>]*>([^<]+)</li>').allMatches(educationContent);
        
        for (final match in listMatches) {
          final item = match.group(1)?.trim() ?? '';
          if (item.isNotEmpty) {
            // Extrai informações do item de formação
            final degreeMatch = RegExp(r'<b>([^<]+)</b>').firstMatch(item);
            final periodMatch = RegExp(r'\(([^)]+)\)').firstMatch(item);
            final institutionMatch = RegExp(r'—\s*([^(]+)').firstMatch(item);
            
            final degree = degreeMatch?.group(1)?.trim() ?? '';
            final period = periodMatch?.group(1)?.trim() ?? '';
            final institution = institutionMatch?.group(1)?.trim() ?? '';
            
            final dates = _extractDates(period);
            
            if (degree.isNotEmpty) {
              education.add(Education.create(
                institution: institution.isNotEmpty ? institution : 'Instituição não especificada',
                degree: degree,
                startDate: dates['start'] ?? DateTime.now(),
                endDate: dates['end'],
              ));
            }
          }
        }
      }
      
      return education;
    }

    List<Project> _extractProjects(String htmlContent) {
      final projects = <Project>[];
      
      // Procura por seção de projetos (pode estar em experiências ou seção separada)
      final projectSection = RegExp(
        r'<h2[^>]*>(?:Projets|Projects|Projetos)[^<]*</h2>.*?(?=<h2|$)',
        caseSensitive: false,
        dotAll: true,
      ).firstMatch(htmlContent);
      
      if (projectSection != null) {
        final projectContent = projectSection.group(0) ?? '';
        
        // Procura por itens de lista de projetos
        final listMatches = RegExp(r'<li[^>]*>([^<]+)</li>').allMatches(projectContent);
        
        for (final match in listMatches) {
          final item = match.group(1)?.trim() ?? '';
          if (item.isNotEmpty) {
            // Extrai nome do projeto e tecnologias
            final nameMatch = RegExp(r'<b>([^<]+)</b>').firstMatch(item);
            final techMatch = RegExp(r'<b>([^<]+)</b>').allMatches(item);
            
            final name = nameMatch?.group(1)?.trim() ?? '';
            final technologies = techMatch.map((m) => m.group(1)?.trim() ?? '').where((t) => t.isNotEmpty).toList();
            
            if (name.isNotEmpty) {
              projects.add(Project.create(
                name: name,
                description: item.replaceAll(RegExp(r'<[^>]+>'), '').trim(),
                technologies: technologies,
              ));
            }
          }
        }
      }
      
      return projects;
    }

    Map<String, DateTime?> _extractDates(String period) {
      final result = <String, DateTime?>{};
      
      if (period.isEmpty) {
        result['start'] = DateTime.now();
        result['end'] = null;
        return result;
      }
      
      // Procura por padrões de data como "03/2016 – Présent" ou "2022–2025"
      final datePatterns = [
        RegExp(r'(\d{2}/\d{4})\s*–\s*(Présent|Present|Atual)', caseSensitive: false),
        RegExp(r'(\d{4})–(\d{4})'),
        RegExp(r'(\d{2}/\d{4})\s*–\s*(\d{2}/\d{4})'),
      ];
      
      for (final pattern in datePatterns) {
        final match = pattern.firstMatch(period);
        if (match != null) {
          final startStr = match.group(1) ?? '';
          final endStr = match.group(2) ?? '';
          
          result['start'] = _parseDate(startStr);
          result['end'] = endStr.toLowerCase().contains('présent') || 
                         endStr.toLowerCase().contains('present') || 
                         endStr.toLowerCase().contains('atual') ? null : _parseDate(endStr);
          return result;
        }
      }
      
      result['start'] = DateTime.now();
      result['end'] = null;
      return result;
    }

    DateTime? _parseDate(String dateStr) {
      if (dateStr.isEmpty) return null;
      
      try {
        // Tenta diferentes formatos de data
        if (dateStr.contains('/')) {
          final parts = dateStr.split('/');
          if (parts.length == 2) {
            final month = int.tryParse(parts[0]) ?? 1;
            final year = int.tryParse(parts[1]) ?? DateTime.now().year;
            return DateTime(year, month);
          }
        } else if (dateStr.length == 4) {
          final year = int.tryParse(dateStr) ?? DateTime.now().year;
          return DateTime(year);
        }
      } catch (e) {
        // Ignora erros de parsing
      }
      
      return null;
    }

    List<String> _extractListItems(String htmlContent) {
      final items = <String>[];
      
      final listMatches = RegExp(r'<li[^>]*>([^<]+)</li>').allMatches(htmlContent);
      for (final match in listMatches) {
        final item = match.group(1)?.trim() ?? '';
        if (item.isNotEmpty) {
          // Remove tags HTML e limpa o texto
          final cleanItem = item
              .replaceAll(RegExp(r'<[^>]+>'), '')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();
          if (cleanItem.isNotEmpty) {
            items.add(cleanItem);
          }
        }
      }
      
      return items;
    }
}
