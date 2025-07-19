/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_strings.dart';
import '../models/cv_model.dart';
import '../providers/job_management_provider.dart';
import '../services/html_cv_parser.dart';
import '../services/html_storage_service.dart';
import '../services/cv_photo_service.dart';

class CVFormScreen extends ConsumerStatefulWidget {
  final CVModel? cv; // null para criar novo, não null para editar

  const CVFormScreen({super.key, this.cv});

  @override
  ConsumerState<CVFormScreen> createState() => _CVFormScreenState();
}

class _CVFormScreenState extends ConsumerState<CVFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetPositionController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _websiteController = TextEditingController();
  final _personalSummaryController = TextEditingController();
  final _skillsController = TextEditingController();
  final _languagesController = TextEditingController();
  final _certificationsController = TextEditingController();
  final _htmlInputController = TextEditingController();

  List<WorkExperience> _experiences = [];
  List<Education> _education = [];
  List<Project> _projects = [];

  bool _isLoading = false;
  bool _showHtmlInput = false;
  String? _selectedFileName;
  bool _isHtmlMode = false;
  String? _htmlContent;
  String? _photoPath;
  final _htmlStorageService = HtmlStorageService();
  final _cvPhotoService = CVPhotoService();

  @override
  void initState() {
    super.initState();
    if (widget.cv != null) {
      _loadCVData(widget.cv!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetPositionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _websiteController.dispose();
    _personalSummaryController.dispose();
    _skillsController.dispose();
    _languagesController.dispose();
    _certificationsController.dispose();
    _htmlInputController.dispose();
    super.dispose();
  }

  void _loadCVData(CVModel cv) {
    if (cv.isHtmlCV) {
      setState(() {
        _isHtmlMode = true;
        _htmlContent = cv.htmlContent;
        _selectedFileName = cv.htmlFilePath != null
            ? cv.htmlFilePath!.split('/').last
            : 'cv_${cv.name}.html';
        _photoPath = cv.photoPath;
      });
    } else {
      _nameController.text = cv.name;
      _targetPositionController.text = cv.targetPosition ?? '';
      _emailController.text = cv.email ?? '';
      _phoneController.text = cv.phone ?? '';
      _addressController.text = cv.address ?? '';
      _linkedinController.text = cv.linkedin ?? '';
      _githubController.text = cv.github ?? '';
      _websiteController.text = cv.website ?? '';
      _personalSummaryController.text = cv.personalSummary ?? '';
      _skillsController.text = cv.skills.join(', ');
      _languagesController.text = cv.languages.join(', ');
      _certificationsController.text = cv.certifications.join(', ');
      _experiences = List.from(cv.experiences);
      _education = List.from(cv.education);
      _projects = List.from(cv.projects);
      _photoPath = cv.photoPath;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(widget.cv != null ? 'Editar CV' : 'Novo CV'),
        backgroundColor:
            isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        foregroundColor:
            isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHtmlImportSection(isDarkMode, strings),
              const SizedBox(height: 24),
              if (_isHtmlMode) ...[
                _buildHtmlNameSection(isDarkMode, strings),
                const SizedBox(height: 24),
                _buildHtmlPhotoSection(isDarkMode, strings),
                const SizedBox(height: 24),
                _buildHtmlPreviewSection(isDarkMode, strings),
                const SizedBox(height: 24),
                _buildHtmlActionsSection(isDarkMode, strings),
              ] else ...[
                _buildBasicInfoSection(isDarkMode, strings),
                const SizedBox(height: 24),
                _buildContactInfoSection(isDarkMode, strings),
                const SizedBox(height: 24),
                _buildExperienceSection(isDarkMode, strings),
                const SizedBox(height: 24),
                _buildEducationSection(isDarkMode, strings),
                const SizedBox(height: 24),
                _buildProjectsSection(isDarkMode, strings),
                const SizedBox(height: 24),
                _buildSkillsSection(isDarkMode, strings),
                const SizedBox(height: 24),
                _buildPreviewSection(isDarkMode, strings),
              ],
              const SizedBox(height: 32),
              _buildSaveButton(isDarkMode, strings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(bool isDarkMode, AppStrings strings) {
    return Card(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações Básicas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome completo',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nome é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetPositionController,
              decoration: const InputDecoration(
                labelText: 'Cargo desejado',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _personalSummaryController,
              decoration: const InputDecoration(
                labelText: 'Resumo pessoal',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection(bool isDarkMode, AppStrings strings) {
    return Card(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações de Contato',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Endereço',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _linkedinController,
              decoration: const InputDecoration(
                labelText: 'LinkedIn',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _githubController,
              decoration: const InputDecoration(
                labelText: 'GitHub',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceSection(bool isDarkMode, AppStrings strings) {
    return Card(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Experiências Profissionais',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: _addExperience,
                  icon: const Icon(Icons.add),
                  tooltip: 'Adicionar experiência',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_experiences.isEmpty)
              Center(
                child: Text(
                  'Nenhuma experiência adicionada',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _experiences.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildExperienceCard(_experiences[index], index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(WorkExperience experience, int index) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${experience.position} - ${experience.company}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => _editExperience(index),
                  icon: const Icon(Icons.edit, size: 20),
                ),
                IconButton(
                  onPressed: () => _removeExperience(index),
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                ),
              ],
            ),
            Text(
              '${DateFormat('MM/yyyy').format(experience.startDate)} - '
              '${experience.endDate != null ? DateFormat('MM/yyyy').format(experience.endDate!) : 'Atual'}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (experience.location != null) ...[
              const SizedBox(height: 4),
              Text(experience.location!,
                  style: TextStyle(color: Colors.grey[600])),
            ],
            if (experience.description != null) ...[
              const SizedBox(height: 8),
              Text(experience.description!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEducationSection(bool isDarkMode, AppStrings strings) {
    return Card(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Educação',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: _addEducation,
                  icon: const Icon(Icons.add),
                  tooltip: 'Adicionar educação',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_education.isEmpty)
              Center(
                child: Text(
                  'Nenhuma educação adicionada',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _education.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildEducationCard(_education[index], index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationCard(Education education, int index) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${education.degree} - ${education.institution}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => _editEducation(index),
                  icon: const Icon(Icons.edit, size: 20),
                ),
                IconButton(
                  onPressed: () => _removeEducation(index),
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                ),
              ],
            ),
            Text(
              '${DateFormat('MM/yyyy').format(education.startDate)} - '
              '${education.endDate != null ? DateFormat('MM/yyyy').format(education.endDate!) : 'Atual'}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (education.field != null) ...[
              const SizedBox(height: 4),
              Text('Área: ${education.field}',
                  style: TextStyle(color: Colors.grey[600])),
            ],
            if (education.description != null) ...[
              const SizedBox(height: 8),
              Text(education.description!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsSection(bool isDarkMode, AppStrings strings) {
    return Card(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Projetos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: _addProject,
                  icon: const Icon(Icons.add),
                  tooltip: 'Adicionar projeto',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_projects.isEmpty)
              Center(
                child: Text(
                  'Nenhum projeto adicionado',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _projects.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildProjectCard(_projects[index], index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(Project project, int index) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => _editProject(index),
                  icon: const Icon(Icons.edit, size: 20),
                ),
                IconButton(
                  onPressed: () => _removeProject(index),
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                ),
              ],
            ),
            if (project.description != null) ...[
              const SizedBox(height: 8),
              Text(project.description!),
            ],
            if (project.technologies.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: project.technologies
                    .map((tech) => Chip(
                          label:
                              Text(tech, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.blue.withOpacity(0.1),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSection(bool isDarkMode, AppStrings strings) {
    return Card(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habilidades e Competências',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _skillsController,
              decoration: const InputDecoration(
                labelText: 'Habilidades (separadas por vírgula)',
                border: OutlineInputBorder(),
                hintText: 'Ex: Flutter, Dart, Firebase, Git',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _languagesController,
              decoration: const InputDecoration(
                labelText: 'Idiomas (separados por vírgula)',
                border: OutlineInputBorder(),
                hintText: 'Ex: Português (Nativo), Inglês (Avançado)',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _certificationsController,
              decoration: const InputDecoration(
                labelText: 'Certificações (separadas por vírgula)',
                border: OutlineInputBorder(),
                hintText: 'Ex: AWS Certified, Google Cloud',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isDarkMode, AppStrings strings) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveCV,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                widget.cv != null ? 'Atualizar CV' : 'Criar CV',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildHtmlImportSection(bool isDarkMode, AppStrings strings) {
    return Card(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Importar CV HTML',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isHtmlMode ? null : _pickHtmlFile,
                    icon: const Icon(Icons.upload_file),
                    label: Text(_selectedFileName ?? 'Selecionar arquivo HTML'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isHtmlMode
                      ? null
                      : () {
                          setState(() {
                            _showHtmlInput = !_showHtmlInput;
                          });
                        },
                  icon: Icon(
                      _showHtmlInput ? Icons.keyboard_hide : Icons.keyboard),
                  label: Text(_showHtmlInput ? 'Ocultar' : 'Colar HTML'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                if (_isHtmlMode) ...[
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isHtmlMode = false;
                        _htmlContent = null;
                        _selectedFileName = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Modo Normal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ],
            ),
            if (_showHtmlInput) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _htmlInputController,
                decoration: const InputDecoration(
                  labelText: 'Cole o código HTML do CV aqui',
                  border: OutlineInputBorder(),
                  hintText: '<html>...</html>',
                ),
                maxLines: 8,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _parseHtmlFromText,
                  icon: const Icon(Icons.transform),
                  label: const Text('Processar HTML'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection(bool isDarkMode, AppStrings strings) {
    return Card(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visualização do CV',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isDarkMode ? Colors.grey[900] : Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho do CV
                  _buildCvHeader(),
                  const SizedBox(height: 16),

                  // Informações de contato
                  if (_emailController.text.isNotEmpty ||
                      _phoneController.text.isNotEmpty ||
                      _addressController.text.isNotEmpty) ...[
                    _buildCvContactInfo(),
                    const SizedBox(height: 16),
                  ],

                  // Resumo pessoal
                  if (_personalSummaryController.text.isNotEmpty) ...[
                    _buildCvSection(
                        'Resumo Pessoal', _personalSummaryController.text),
                    const SizedBox(height: 16),
                  ],

                  // Experiências
                  if (_experiences.isNotEmpty) ...[
                    _buildCvExperiencesPreview(),
                    const SizedBox(height: 16),
                  ],

                  // Educação
                  if (_education.isNotEmpty) ...[
                    _buildCvEducationPreview(),
                    const SizedBox(height: 16),
                  ],

                  // Projetos
                  if (_projects.isNotEmpty) ...[
                    _buildCvProjectsPreview(),
                    const SizedBox(height: 16),
                  ],

                  // Habilidades
                  if (_skillsController.text.isNotEmpty) ...[
                    _buildCvSection('Habilidades', _skillsController.text),
                    const SizedBox(height: 16),
                  ],

                  // Idiomas
                  if (_languagesController.text.isNotEmpty) ...[
                    _buildCvSection('Idiomas', _languagesController.text),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCvHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_nameController.text.isNotEmpty)
          Text(
            _nameController.text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (_targetPositionController.text.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            _targetPositionController.text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCvContactInfo() {
    final contacts = <String>[];

    if (_emailController.text.isNotEmpty) contacts.add(_emailController.text);
    if (_phoneController.text.isNotEmpty) contacts.add(_phoneController.text);
    if (_addressController.text.isNotEmpty)
      contacts.add(_addressController.text);
    if (_linkedinController.text.isNotEmpty)
      contacts.add('LinkedIn: ${_linkedinController.text}');
    if (_githubController.text.isNotEmpty)
      contacts.add('GitHub: ${_githubController.text}');
    if (_websiteController.text.isNotEmpty)
      contacts.add('Website: ${_websiteController.text}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contato',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...contacts.map((contact) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(contact),
            )),
      ],
    );
  }

  Widget _buildCvSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(content),
      ],
    );
  }

  Widget _buildCvExperiencesPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Experiência Profissional',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...(_experiences.take(3).map((exp) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${exp.position} - ${exp.company}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${DateFormat('MM/yyyy').format(exp.startDate)} - ${exp.endDate != null ? DateFormat('MM/yyyy').format(exp.endDate!) : 'Atual'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  if (exp.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      exp.description!.length > 100
                          ? '${exp.description!.substring(0, 100)}...'
                          : exp.description!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ))),
        if (_experiences.length > 3)
          Text(
            'E mais ${_experiences.length - 3} experiência(s)...',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildCvEducationPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Educação',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...(_education.take(2).map((edu) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${edu.degree} - ${edu.institution}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    DateFormat('yyyy').format(edu.startDate),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ))),
        if (_education.length > 2)
          Text(
            'E mais ${_education.length - 2} formação(ões)...',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildCvProjectsPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Projetos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...(_projects.take(2).map((project) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (project.description != null)
                    Text(
                      project.description!.length > 60
                          ? '${project.description!.substring(0, 60)}...'
                          : project.description!,
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ))),
        if (_projects.length > 2)
          Text(
            'E mais ${_projects.length - 2} projeto(s)...',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  // Métodos para gerenciar experiências
  void _addExperience() {
    _showExperienceDialog();
  }

  void _editExperience(int index) {
    _showExperienceDialog(experience: _experiences[index], index: index);
  }

  void _removeExperience(int index) {
    setState(() {
      _experiences.removeAt(index);
    });
  }

  void _showExperienceDialog({WorkExperience? experience, int? index}) {
    final companyController =
        TextEditingController(text: experience?.company ?? '');
    final positionController =
        TextEditingController(text: experience?.position ?? '');
    final locationController =
        TextEditingController(text: experience?.location ?? '');
    final descriptionController =
        TextEditingController(text: experience?.description ?? '');
    DateTime startDate = experience?.startDate ?? DateTime.now();
    DateTime? endDate = experience?.endDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            experience != null ? 'Editar Experiência' : 'Nova Experiência'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: companyController,
                decoration: const InputDecoration(labelText: 'Empresa'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(labelText: 'Cargo'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Localização'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Data de início'),
                      subtitle: Text(DateFormat('MM/yyyy').format(startDate)),
                      onTap: () {
                        // TODO: Implementar seletor de data
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Seletor de data será implementado')),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Data de fim'),
                      subtitle: Text(endDate != null
                          ? DateFormat('MM/yyyy').format(endDate)
                          : 'Atual'),
                      onTap: () {
                        // TODO: Implementar seletor de data
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Seletor de data será implementado')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (companyController.text.isNotEmpty &&
                  positionController.text.isNotEmpty) {
                final newExperience = WorkExperience.create(
                  company: companyController.text,
                  position: positionController.text,
                  location: locationController.text.isEmpty
                      ? null
                      : locationController.text,
                  startDate: startDate,
                  endDate: endDate,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                );

                setState(() {
                  if (index != null) {
                    _experiences[index] = newExperience;
                  } else {
                    _experiences.add(newExperience);
                  }
                });

                Navigator.pop(context);
              }
            },
            child: Text(experience != null ? 'Atualizar' : 'Adicionar'),
          ),
        ],
      ),
    );
  }

  // Métodos para gerenciar educação
  void _addEducation() {
    _showEducationDialog();
  }

  void _editEducation(int index) {
    _showEducationDialog(education: _education[index], index: index);
  }

  void _removeEducation(int index) {
    setState(() {
      _education.removeAt(index);
    });
  }

  void _showEducationDialog({Education? education, int? index}) {
    final institutionController =
        TextEditingController(text: education?.institution ?? '');
    final degreeController =
        TextEditingController(text: education?.degree ?? '');
    final fieldController = TextEditingController(text: education?.field ?? '');
    final descriptionController =
        TextEditingController(text: education?.description ?? '');
    DateTime startDate = education?.startDate ?? DateTime.now();
    DateTime? endDate = education?.endDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(education != null ? 'Editar Educação' : 'Nova Educação'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: institutionController,
                decoration: const InputDecoration(labelText: 'Instituição'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: degreeController,
                decoration: const InputDecoration(labelText: 'Grau/Diploma'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: fieldController,
                decoration: const InputDecoration(labelText: 'Área'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Data de início'),
                      subtitle: Text(DateFormat('MM/yyyy').format(startDate)),
                      onTap: () {
                        // TODO: Implementar seletor de data
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Seletor de data será implementado')),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Data de fim'),
                      subtitle: Text(endDate != null
                          ? DateFormat('MM/yyyy').format(endDate)
                          : 'Atual'),
                      onTap: () {
                        // TODO: Implementar seletor de data
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Seletor de data será implementado')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (institutionController.text.isNotEmpty &&
                  degreeController.text.isNotEmpty) {
                final newEducation = Education.create(
                  institution: institutionController.text,
                  degree: degreeController.text,
                  field: fieldController.text.isEmpty
                      ? null
                      : fieldController.text,
                  startDate: startDate,
                  endDate: endDate,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                );

                setState(() {
                  if (index != null) {
                    _education[index] = newEducation;
                  } else {
                    _education.add(newEducation);
                  }
                });

                Navigator.pop(context);
              }
            },
            child: Text(education != null ? 'Atualizar' : 'Adicionar'),
          ),
        ],
      ),
    );
  }

  // Métodos para gerenciar projetos
  void _addProject() {
    _showProjectDialog();
  }

  void _editProject(int index) {
    _showProjectDialog(project: _projects[index], index: index);
  }

  void _removeProject(int index) {
    setState(() {
      _projects.removeAt(index);
    });
  }

  void _showProjectDialog({Project? project, int? index}) {
    final nameController = TextEditingController(text: project?.name ?? '');
    final descriptionController =
        TextEditingController(text: project?.description ?? '');
    final technologiesController =
        TextEditingController(text: project?.technologies.join(', ') ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project != null ? 'Editar Projeto' : 'Novo Projeto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome do projeto'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: technologiesController,
                decoration: const InputDecoration(
                  labelText: 'Tecnologias',
                  hintText: 'Separadas por vírgula',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final technologies = technologiesController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                final newProject = Project.create(
                  name: nameController.text,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                  technologies: technologies,
                );

                setState(() {
                  if (index != null) {
                    _projects[index] = newProject;
                  } else {
                    _projects.add(newProject);
                  }
                });

                Navigator.pop(context);
              }
            },
            child: Text(project != null ? 'Atualizar' : 'Adicionar'),
          ),
        ],
      ),
    );
  }

  Widget _buildHtmlNameSection(bool isDarkMode, AppStrings strings) {
    return Card(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nome do CV',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do CV',
                hintText: 'Ex: CV Karim Santos - Desenvolvedor',
                border: OutlineInputBorder(),
                helperText: 'Digite um nome para identificar este CV',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nome do CV é obrigatório';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHtmlPhotoSection(bool isDarkMode, AppStrings strings) {
    return Card(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foto do CV',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (_photoPath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_photoPath!),
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Foto atual: ${_photoPath!.split('/').last}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ] else ...[
              Text(
                'Nenhuma foto carregada. Clique em "Adicionar Foto" para selecionar.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Adicionar Foto'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _removePhoto,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remover Foto'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHtmlPreviewSection(bool isDarkMode, AppStrings strings) {
    return Card(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview do CV HTML',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (_htmlContent != null) ...[
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      _htmlContent!,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: isDarkMode
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Nenhum conteúdo HTML carregado',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHtmlActionsSection(bool isDarkMode, AppStrings strings) {
    return Card(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações do CV HTML',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isHtmlMode ? null : _pickHtmlFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Carregar Arquivo HTML'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDarkMode ? AppColors.primary : AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isHtmlMode
                        ? null
                        : () {
                            setState(() {
                              _showHtmlInput = true;
                            });
                          },
                    icon: const Icon(Icons.paste),
                    label: const Text('Colar HTML'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDarkMode ? AppColors.primary : AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isHtmlMode
                  ? () {
                      setState(() {
                        _isHtmlMode = false;
                        _htmlContent = null;
                        _selectedFileName = null;
                        _showHtmlInput = false;
                        _htmlInputController.clear();
                      });
                    }
                  : null,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Voltar ao Modo Normal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.orange : Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickHtmlFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['html', 'htm'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        setState(() {
          _selectedFileName = file.name;
        });

        String htmlContent;
        if (file.bytes != null) {
          htmlContent = String.fromCharCodes(file.bytes!);
        } else if (file.path != null) {
          final fileContent = File(file.path!);
          htmlContent = await fileContent.readAsString();
        } else {
          throw Exception('Não foi possível ler o arquivo');
        }

        await _processHtmlContent(htmlContent, file.name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar arquivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _parseHtmlFromText() async {
    if (_htmlInputController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, cole o código HTML primeiro'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await _processHtmlContent(_htmlInputController.text, 'html_colado.html');
  }

  Future<void> _processHtmlContent(String htmlContent, String fileName) async {
    try {
      setState(() {
        _isLoading = true;
      });

      setState(() {
        _isHtmlMode = true;
        _htmlContent = htmlContent;
        _selectedFileName = fileName;
        _showHtmlInput = false;
        _htmlInputController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CV HTML carregado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao processar HTML: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickPhoto() async {
    try {
      // Verificar se já existe uma foto para este CV
      final photoExists = await _cvPhotoService.photoExists(_nameController.text);
      
      if (photoExists) {
        // Se já existe, usar a foto existente
        final existingPhotoPath = await _cvPhotoService.getPhotoPath(_nameController.text);
        if (existingPhotoPath != null) {
          setState(() {
            _photoPath = existingPhotoPath;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto existente carregada automaticamente'),
              backgroundColor: Colors.green,
            ),
          );
          return;
        }
      }

      // Se não existe, permitir seleção de nova foto
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        if (file.path != null) {
          // Salvar a foto usando o serviço
          final savedPhotoPath = await _cvPhotoService.uploadPhotoFromGallery(_nameController.text);
          if (savedPhotoPath != null) {
            setState(() {
              _photoPath = savedPhotoPath;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto adicionada com sucesso'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removePhoto() async {
    try {
      if (_photoPath != null) {
        // Remover a foto usando o serviço
        await _cvPhotoService.removePhoto(_nameController.text);
        setState(() {
          _photoPath = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto removida com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveCV() async {
    if (_isHtmlMode) {
      await _saveHtmlCV();
    } else {
      await _saveRegularCV();
    }
  }

  Future<void> _saveHtmlCV() async {
    if (!_formKey.currentState!.validate()) return;

    if (_htmlContent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum conteúdo HTML foi carregado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Primeiro salvar o HTML sem a foto
      final htmlFilePath = await _htmlStorageService.saveHtmlFile(_htmlContent!,
          _selectedFileName ?? 'cv_${_nameController.text}.html');

      // Processar HTML para inserir a foto se disponível
      String processedHtmlContent = _htmlContent!;
      if (_photoPath != null) {
        // Copiar a foto para o mesmo diretório do HTML
        final photoName = await _htmlStorageService.copyPhotoToHtmlDirectory(_photoPath!, htmlFilePath);
        if (photoName != null) {
          // Inserir o nome da foto no HTML
          processedHtmlContent = _insertPhotoIntoHtml(_htmlContent!, photoName);
          
          // Salvar novamente o HTML com a foto inserida
          final file = File(htmlFilePath);
          await file.writeAsString(processedHtmlContent);
        }
      }

      final cv = CVModel.createHtml(
        name: _nameController.text,
        htmlContent: processedHtmlContent,
        htmlFilePath: htmlFilePath,
        photoPath: _photoPath,
      );

      final service = ref.read(jobManagementServiceProvider);
      await service.saveCV(cv);

      // Atualiza a lista de CVs
      ref.refresh(cvsNotifierProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.cv != null
                ? 'CV HTML atualizado com sucesso!'
                : 'CV HTML criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar CV HTML: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveRegularCV() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final skills = _skillsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final languages = _languagesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final certifications = _certificationsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final cv = CVModel.create(
        name: _nameController.text,
        targetPosition: _targetPositionController.text.isEmpty
            ? null
            : _targetPositionController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        address:
            _addressController.text.isEmpty ? null : _addressController.text,
        linkedin:
            _linkedinController.text.isEmpty ? null : _linkedinController.text,
        github: _githubController.text.isEmpty ? null : _githubController.text,
        website:
            _websiteController.text.isEmpty ? null : _websiteController.text,
        personalSummary: _personalSummaryController.text.isEmpty
            ? null
            : _personalSummaryController.text,
        experiences: _experiences,
        education: _education,
        projects: _projects,
        skills: skills,
        languages: languages,
        certifications: certifications,
        photoPath: _photoPath,
      );

      final service = ref.read(jobManagementServiceProvider);
      await service.saveCV(cv);

      // Atualiza a lista de CVs
      ref.refresh(cvsNotifierProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.cv != null
                ? 'CV atualizado com sucesso!'
                : 'CV criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar CV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _insertPhotoIntoHtml(String htmlContent, String photoName) {
    // Procura por elementos img com a classe profile-photo
    final RegExp profilePhotoRegex = RegExp(
      r'<img[^>]*class="[^"]*profile-photo[^"]*"[^>]*>',
      multiLine: true,
      caseSensitive: false,
    );

    if (profilePhotoRegex.hasMatch(htmlContent)) {
      // Se encontrou, substitui o src
      return htmlContent.replaceAllMapped(profilePhotoRegex, (match) {
        String imgTag = match.group(0)!;
        
        // Remove src existente se houver
        imgTag = imgTag.replaceAll(RegExp(r'src="[^"]*"'), '');
        
        // Adiciona o novo src antes do fechamento da tag (caminho relativo)
        imgTag = imgTag.replaceAll('>', ' src="$photoName">');
        
        return imgTag;
      });
    } else {
      // Se não encontrou classe profile-photo, procura por outros padrões comuns
      final List<RegExp> photoPatterns = [
        RegExp(r'<img[^>]*class="[^"]*photo[^"]*"[^>]*>', multiLine: true, caseSensitive: false),
        RegExp(r'<img[^>]*class="[^"]*avatar[^"]*"[^>]*>', multiLine: true, caseSensitive: false),
        RegExp(r'<img[^>]*id="[^"]*photo[^"]*"[^>]*>', multiLine: true, caseSensitive: false),
      ];

      for (RegExp pattern in photoPatterns) {
        if (pattern.hasMatch(htmlContent)) {
          return htmlContent.replaceAllMapped(pattern, (match) {
            String imgTag = match.group(0)!;
            
            // Remove src existente se houver
            imgTag = imgTag.replaceAll(RegExp(r'src="[^"]*"'), '');
            
            // Adiciona o novo src antes do fechamento da tag (caminho relativo)
            imgTag = imgTag.replaceAll('>', ' src="$photoName">');
            
            return imgTag;
          });
        }
      }
    }

    return htmlContent;
  }
}
