/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/cv_model.dart';
import '../models/application_model.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/l10n/app_strings.dart';

class CVService {
  static const String _cvDirectory = 'job_management/cvs';
  static const String _pdfDirectory = 'job_management/pdfs';

  /// Gera uma introdução personalizada usando AI
  static Future<String> generateAIIntroduction({
    required CVModel cv,
    required String targetPosition,
    required WidgetRef ref,
  }) async {
    try {
      final prompt = _buildIntroductionPrompt(cv, targetPosition);
      
      final aiIntroduction = await AIService.generateMarkdownContent(
        prompt,
        ref: ref,
      );
      
      return _cleanAIResponse(aiIntroduction);
    } catch (e) {
      return _getFallbackIntroduction(cv, targetPosition);
    }
  }

  /// Gera carta de motivação usando AI
  static Future<String> generateMotivationLetter({
    required CVModel cv,
    required ApplicationModel application,
    required WidgetRef ref,
  }) async {
    try {
      final prompt = _buildMotivationLetterPrompt(cv, application);
      
      final motivationLetter = await AIService.generateMarkdownContent(
        prompt,
        ref: ref,
      );
      
      return _cleanAIResponse(motivationLetter);
    } catch (e) {
      return _getFallbackMotivationLetter(cv, application);
    }
  }

  /// Calcula compatibilidade com vaga usando AI
  static Future<double> calculateJobMatch({
    required CVModel cv,
    required ApplicationModel application,
    required WidgetRef ref,
  }) async {
    try {
      final prompt = _buildMatchPrompt(cv, application);
      
      final matchResponse = await AIService.generateMarkdownContent(
        prompt,
        ref: ref,
      );
      
      return _extractPercentageFromResponse(matchResponse);
    } catch (e) {
      return _calculateBasicMatch(cv, application);
    }
  }

  /// Exporta CV para PDF
  static Future<String?> exportCVToPDF({
    required CVModel cv,
    required AppStrings strings,
  }) async {
    try {
      final pdf = pw.Document();
      
      // Adicionar páginas ao PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              _buildPDFHeader(cv),
              pw.SizedBox(height: 20),
              if (cv.aiIntroduction != null) ...[
                _buildPDFSection(strings.jobSummary, cv.aiIntroduction!),
                pw.SizedBox(height: 20),
              ],
              if (cv.experiences.isNotEmpty) ...[
                _buildPDFSection(strings.jobExperience, null),
                ..._buildExperienceList(cv.experiences),
                pw.SizedBox(height: 20),
              ],
              if (cv.education.isNotEmpty) ...[
                _buildPDFSection(strings.jobEducation, null),
                ..._buildEducationList(cv.education),
                pw.SizedBox(height: 20),
              ],
              if (cv.projects.isNotEmpty) ...[
                _buildPDFSection(strings.jobProjects, null),
                ..._buildProjectsList(cv.projects),
                pw.SizedBox(height: 20),
              ],
              if (cv.skills.isNotEmpty) ...[
                _buildPDFSection(strings.jobSkills, cv.skills.join(', ')),
                pw.SizedBox(height: 20),
              ],
              if (cv.languages.isNotEmpty) ...[
                _buildPDFSection(strings.jobLanguages, cv.languages.join(', ')),
                pw.SizedBox(height: 20),
              ],
              if (cv.certifications.isNotEmpty) ...[
                _buildPDFSection(strings.jobCertifications, cv.certifications.join(', ')),
              ],
            ];
          },
        ),
      );

      // Salvar PDF
      final directory = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${directory.path}/$_pdfDirectory');
      await pdfDir.create(recursive: true);
      
      final file = File('${pdfDir.path}/cv_${cv.id}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// Salva CV no sistema de arquivos
  static Future<String?> saveCV(CVModel cv) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cvDir = Directory('${directory.path}/$_cvDirectory');
      await cvDir.create(recursive: true);
      
      final file = File('${cvDir.path}/cv_${cv.id}.json');
      await file.writeAsString(cv.toJson().toString());
      
      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// Carrega CV do sistema de arquivos
  static Future<CVModel?> loadCV(String cvId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_cvDirectory/cv_$cvId.json');
      
      if (!await file.exists()) return null;
      
      final jsonString = await file.readAsString();
      final jsonMap = Map<String, dynamic>.from(
        Uri.splitQueryString(jsonString),
      );
      
      return CVModel.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  // Métodos auxiliares privados

  static String _buildIntroductionPrompt(CVModel cv, String targetPosition) {
    return '''
Crie uma introdução profissional e personalizada para um CV, baseada nas seguintes informações:

**Cargo desejado**: $targetPosition
**Experiências**: ${cv.experiences.map((e) => '${e.position} na ${e.company}').join(', ')}
**Habilidades**: ${cv.skills.join(', ')}
**Educação**: ${cv.education.map((e) => '${e.degree} em ${e.field ?? 'área não especificada'}').join(', ')}

**Instruções**:
1. Crie um parágrafo introdutório de 3-4 frases
2. Destaque as competências mais relevantes para o cargo
3. Seja profissional e direto
4. Não use clichês ou frases genéricas
5. Foque nos resultados e valor agregado

**Formato**: Retorne apenas o texto da introdução, sem formatação markdown.
''';
  }

  static String _buildMotivationLetterPrompt(CVModel cv, ApplicationModel application) {
    return '''
Crie uma carta de motivação personalizada com base nas seguintes informações:

**Vaga**: ${application.title}
**Empresa**: ${application.company}
**Descrição da vaga**: ${application.description ?? 'Não especificada'}

**Perfil do candidato**:
- Experiências: ${cv.experiences.map((e) => '${e.position} na ${e.company}').join(', ')}
- Habilidades: ${cv.skills.join(', ')}
- Educação: ${cv.education.map((e) => '${e.degree} em ${e.field ?? 'área não especificada'}').join(', ')}

**Instruções**:
1. Crie uma carta de motivação de 3-4 parágrafos
2. Primeiro parágrafo: apresentação e interesse na vaga
3. Segundo parágrafo: experiências relevantes e habilidades
4. Terceiro parágrafo: como pode contribuir para a empresa
5. Quarto parágrafo: encerramento profissional
6. Seja específico e personalize para a empresa e vaga
7. Use tom profissional mas não formal demais

**Formato**: Retorne apenas o texto da carta, sem formatação markdown.
''';
  }

  static String _buildMatchPrompt(CVModel cv, ApplicationModel application) {
    return '''
Analise a compatibilidade entre o perfil do candidato e a vaga, e retorne uma porcentagem de compatibilidade.

**Vaga**: ${application.title}
**Empresa**: ${application.company}
**Descrição**: ${application.description ?? 'Não especificada'}

**Perfil do candidato**:
- Experiências: ${cv.experiences.map((e) => '${e.position} na ${e.company} (${e.description ?? 'sem descrição'})').join(', ')}
- Habilidades: ${cv.skills.join(', ')}
- Educação: ${cv.education.map((e) => '${e.degree} em ${e.field ?? 'área não especificada'}').join(', ')}
- Projetos: ${cv.projects.map((p) => '${p.name} - ${p.technologies.join(', ')}').join(', ')}

**Instruções**:
1. Analise a compatibilidade entre habilidades, experiências e requisitos da vaga
2. Considere educação, projetos e experiências relevantes
3. Retorne apenas um número entre 0 e 100 representando a porcentagem de compatibilidade
4. Seja criterioso na avaliação

**Formato**: Retorne apenas o número da porcentagem (ex: 85)
''';
  }

  static String _cleanAIResponse(String response) {
    // Remove markdown formatting e limpa a resposta
    return response
        .replaceAll(RegExp(r'^\s*#+\s*'), '')
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1')
        .replaceAll(RegExp(r'`(.*?)`'), r'$1')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  static double _extractPercentageFromResponse(String response) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(response);
    if (match != null) {
      final percentage = double.tryParse(match.group(1)!) ?? 0.0;
      return percentage.clamp(0.0, 100.0);
    }
    return 0.0;
  }

  static String _getFallbackIntroduction(CVModel cv, String targetPosition) {
    return 'Profissional com experiência em ${cv.experiences.isNotEmpty ? cv.experiences.first.position : targetPosition}, '
        'com habilidades em ${cv.skills.take(3).join(', ')} e formação em '
        '${cv.education.isNotEmpty ? cv.education.first.degree : 'área relacionada'}. '
        'Busco contribuir com minha experiência e conhecimentos para o crescimento da empresa.';
  }

  static String _getFallbackMotivationLetter(CVModel cv, ApplicationModel application) {
    return 'Prezados responsáveis pela seleção,\n\n'
        'Tenho grande interesse na vaga de ${application.title} na ${application.company}. '
        'Possuo experiência em ${cv.experiences.isNotEmpty ? cv.experiences.first.position : 'área relacionada'} '
        'e acredito que minhas habilidades em ${cv.skills.take(3).join(', ')} podem contribuir significativamente '
        'para o sucesso da equipe.\n\n'
        'Aguardo a oportunidade de discutir como posso agregar valor à ${application.company}.\n\n'
        'Atenciosamente,\n${cv.name}';
  }

  static double _calculateBasicMatch(CVModel cv, ApplicationModel application) {
    // Algoritmo básico de compatibilidade
    double score = 0.0;
    
    // Pontuação baseada em experiências
    if (cv.experiences.isNotEmpty) {
      score += 30.0;
    }
    
    // Pontuação baseada em habilidades
    if (cv.skills.isNotEmpty) {
      score += 25.0;
    }
    
    // Pontuação baseada em educação
    if (cv.education.isNotEmpty) {
      score += 20.0;
    }
    
    // Pontuação baseada em projetos
    if (cv.projects.isNotEmpty) {
      score += 15.0;
    }
    
    // Pontuação baseada em certificações
    if (cv.certifications.isNotEmpty) {
      score += 10.0;
    }
    
    return score.clamp(0.0, 100.0);
  }

  // Métodos auxiliares para PDF

  static pw.Widget _buildPDFHeader(CVModel cv) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          cv.name,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            if (cv.email != null) ...[
              pw.Text('Email: ${cv.email}'),
              pw.SizedBox(width: 20),
            ],
            if (cv.phone != null) ...[
              pw.Text('Telefone: ${cv.phone}'),
              pw.SizedBox(width: 20),
            ],
          ],
        ),
        if (cv.address != null) ...[
          pw.SizedBox(height: 5),
          pw.Text('Endereço: ${cv.address}'),
        ],
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildPDFSection(String title, String? content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        if (content != null) pw.Text(content),
      ],
    );
  }

  static List<pw.Widget> _buildExperienceList(List<WorkExperience> experiences) {
    return experiences.map((exp) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${exp.position} - ${exp.company}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '${exp.startDate.year}/${exp.startDate.month.toString().padLeft(2, '0')} - '
            '${exp.endDate?.year.toString() ?? 'Atual'}${exp.endDate != null ? '/${exp.endDate!.month.toString().padLeft(2, '0')}' : ''}',
          ),
          if (exp.description != null) ...[
            pw.SizedBox(height: 5),
            pw.Text(exp.description!),
          ],
        ],
      ),
    )).toList();
  }

  static List<pw.Widget> _buildEducationList(List<Education> education) {
    return education.map((edu) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${edu.degree} - ${edu.institution}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '${edu.startDate.year}/${edu.startDate.month.toString().padLeft(2, '0')} - '
            '${edu.endDate?.year.toString() ?? 'Atual'}${edu.endDate != null ? '/${edu.endDate!.month.toString().padLeft(2, '0')}' : ''}',
          ),
          if (edu.field != null) ...[
            pw.SizedBox(height: 5),
            pw.Text('Área: ${edu.field}'),
          ],
        ],
      ),
    )).toList();
  }

  static List<pw.Widget> _buildProjectsList(List<Project> projects) {
    return projects.map((project) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            project.name,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          if (project.description != null) ...[
            pw.SizedBox(height: 5),
            pw.Text(project.description!),
          ],
          if (project.technologies.isNotEmpty) ...[
            pw.SizedBox(height: 5),
            pw.Text('Tecnologias: ${project.technologies.join(', ')}'),
          ],
        ],
      ),
    )).toList();
  }
}