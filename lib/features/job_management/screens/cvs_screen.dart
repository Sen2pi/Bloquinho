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
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../../shared/providers/theme_provider.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_strings.dart';
import '../models/cv_model.dart';
import '../providers/job_management_provider.dart';
import '../services/cv_service.dart';
import '../services/cv_photo_service.dart';
import 'cv_form_screen.dart';

class CVsScreen extends ConsumerStatefulWidget {
  const CVsScreen({super.key});

  @override
  ConsumerState<CVsScreen> createState() => _CVsScreenState();
}

class _CVsScreenState extends ConsumerState<CVsScreen> {
  final _cvService = CVService();
  final _cvPhotoService = CVPhotoService();
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final strings = ref.watch(appStringsProvider);
    final cvsAsync = ref.watch(cvsNotifierProvider);

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewCV(),
        backgroundColor: AppColors.primary,
        heroTag: "cvs_screen_fab",
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchBar(isDarkMode, strings),
          Expanded(
            child: cvsAsync.when(
              data: (cvs) {
                final filteredCVs = _filterCVs(cvs);
                if (filteredCVs.isEmpty) {
                  return _buildEmptyState(isDarkMode, strings);
                }
                return _buildCVsList(filteredCVs, isDarkMode, strings);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(error, isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar currículos...',
          prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          filled: true,
          fillColor:
              isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, AppStrings strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.fileText(),
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            strings.jobNoCVs,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comece criando seu primeiro currículo',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.warning(),
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Erro ao carregar currículos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCVsList(List<CVModel> cvs, bool isDarkMode, AppStrings strings) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cvs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final cv = cvs[index];
        return _buildCVCard(cv, isDarkMode, strings);
      },
    );
  }

  Widget _buildCVCard(CVModel cv, bool isDarkMode, AppStrings strings) {
    return Card(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: InkWell(
        onTap: () => _showCVDetails(cv, isDarkMode, strings),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (cv.photoPath != null && File(cv.photoPath!).existsSync()) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(cv.photoPath!),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cv.isHtmlCV 
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        cv.isHtmlCV ? PhosphorIcons.code() : PhosphorIcons.fileText(),
                        color: cv.isHtmlCV ? Colors.orange : Colors.green,
                        size: 20,
                      ),
                    ),
                  ],
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cv.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (cv.targetPosition != null)
                          Text(
                            cv.targetPosition!,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) =>
                        _handleMenuAction(value, cv, strings),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(PhosphorIcons.eye()),
                            const SizedBox(width: 8),
                            Text('Ver detalhes'),
                          ],
                        ),
                      ),
                      if (cv.isHtmlCV) ...[
                        PopupMenuItem(
                          value: 'browser',
                          child: Row(
                            children: [
                              Icon(PhosphorIcons.browser()),
                              const SizedBox(width: 8),
                              Text('Abrir no Navegador'),
                            ],
                          ),
                        ),
                      ] else ...[
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(PhosphorIcons.pencil()),
                              const SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'pdf',
                          child: Row(
                            children: [
                              Icon(PhosphorIcons.filePdf()),
                              const SizedBox(width: 8),
                              Text('Exportar PDF'),
                            ],
                          ),
                        ),
                      ],
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(PhosphorIcons.trash(), color: Colors.red),
                            const SizedBox(width: 8),
                            Text('Excluir',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    PhosphorIcons.calendar(),
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Criado em ${DateFormat('dd/MM/yyyy').format(cv.createdAt)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    PhosphorIcons.briefcase(),
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${cv.experiences.length} exp.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: cv.skills
                    .take(3)
                    .map((skill) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            skill,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              if (cv.skills.length > 3) ...[
                const SizedBox(height: 4),
                Text(
                  '+${cv.skills.length - 3} mais',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<CVModel> _filterCVs(List<CVModel> cvs) {
    if (_searchQuery.isEmpty) return cvs;

    return cvs.where((cv) {
      final matchesName =
          cv.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesPosition = cv.targetPosition
              ?.toLowerCase()
              .contains(_searchQuery.toLowerCase()) ??
          false;
      final matchesSkills = cv.skills.any(
          (skill) => skill.toLowerCase().contains(_searchQuery.toLowerCase()));

      return matchesName || matchesPosition || matchesSkills;
    }).toList();
  }

  void _showCVDetails(CVModel cv, bool isDarkMode, AppStrings strings) {
    if (cv.isHtmlCV) {
      _showHtmlCVDetails(cv, isDarkMode, strings);
    } else {
      _showRegularCVDetails(cv, isDarkMode, strings);
    }
  }

  void _showHtmlCVDetails(CVModel cv, bool isDarkMode, AppStrings strings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIcons.code(), color: Colors.orange),
            const SizedBox(width: 8),
            Text('${cv.name} (HTML)'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tipo: CV HTML'),
              if (cv.htmlFilePath != null)
                Text('Arquivo: ${cv.htmlFilePath!.split('/').last}'),
              const SizedBox(height: 8),
              Text('Criado em: ${DateFormat('dd/MM/yyyy').format(cv.createdAt)}'),
              Text('Atualizado em: ${DateFormat('dd/MM/yyyy').format(cv.updatedAt)}'),
              const SizedBox(height: 16),
              Text(
                'Este é um CV HTML. O conteúdo original foi preservado e pode ser visualizado no navegador.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openHtmlInBrowser(cv);
            },
            child: Text('Abrir no Navegador'),
          ),
        ],
      ),
    );
  }

  void _showRegularCVDetails(CVModel cv, bool isDarkMode, AppStrings strings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cv.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (cv.targetPosition != null)
                Text('Cargo desejado: ${cv.targetPosition}'),
              if (cv.email != null) Text('Email: ${cv.email}'),
              if (cv.phone != null) Text('Telefone: ${cv.phone}'),
              const SizedBox(height: 8),
              Text('Experiências: ${cv.experiences.length}'),
              Text('Habilidades: ${cv.skills.length}'),
              Text('Projetos: ${cv.projects.length}'),
              Text('Educação: ${cv.education.length}'),
              const SizedBox(height: 8),
              Text(
                  'Criado em: ${DateFormat('dd/MM/yyyy').format(cv.createdAt)}'),
              Text(
                  'Atualizado em: ${DateFormat('dd/MM/yyyy').format(cv.updatedAt)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportToPDF(cv, strings);
            },
            child: Text('Exportar PDF'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, CVModel cv, AppStrings strings) {
    switch (action) {
      case 'view':
        _showCVDetails(cv, ref.watch(isDarkModeProvider), strings);
        break;
      case 'browser':
        _openHtmlInBrowser(cv);
        break;
      case 'edit':
        // TODO: Implementar edição
        break;
      case 'pdf':
        _exportToPDF(cv, strings);
        break;
      case 'delete':
        _showDeleteConfirmation(cv);
        break;
    }
  }

  void _exportToPDF(CVModel cv, AppStrings strings) async {
    try {
      final path = await CVService.exportCVToPDF(cv: cv, strings: strings);
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF exportado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _createNewCV() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CVFormScreen(),
      ),
    );
  }

  void _openHtmlInBrowser(CVModel cv) async {
    try {
      if (cv.htmlFilePath != null) {
        // Abre o arquivo HTML no navegador padrão
        final file = File(cv.htmlFilePath!);
        if (await file.exists()) {
          // No Windows, usa o comando start para abrir no navegador padrão
          await Process.run('start', [cv.htmlFilePath!], runInShell: true);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CV HTML aberto no navegador'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Arquivo HTML não encontrado'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Caminho do arquivo HTML não disponível'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao abrir CV HTML: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(CVModel cv) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content:
            Text('Tem certeza que deseja excluir o currículo "${cv.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Se é um CV HTML, eliminar o ficheiro
              if (cv.isHtmlCV && cv.htmlFilePath != null) {
                try {
                  final htmlFile = File(cv.htmlFilePath!);
                  if (await htmlFile.exists()) {
                    await htmlFile.delete();
                  }
                  
                  // Eliminar também as fotos do diretório HTML se existirem
                  final htmlDir = Directory(htmlFile.parent.path);
                  if (await htmlDir.exists()) {
                    final files = htmlDir.listSync();
                    for (final file in files) {
                      if (file is File && 
                          (file.path.toLowerCase().endsWith('.jpg') ||
                           file.path.toLowerCase().endsWith('.jpeg') ||
                           file.path.toLowerCase().endsWith('.png') ||
                           file.path.toLowerCase().endsWith('.gif'))) {
                        await file.delete();
                      }
                    }
                  }
                } catch (e) {
                  // Silenciar erros de eliminação de ficheiros
                }
              }
              
              ref.read(cvsNotifierProvider.notifier).deleteCV(cv.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Currículo excluído com sucesso'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
