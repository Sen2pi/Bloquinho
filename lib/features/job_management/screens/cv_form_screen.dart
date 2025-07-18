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

import '../../../shared/providers/theme_provider.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_strings.dart';
import '../models/cv_model.dart';
import '../providers/job_management_provider.dart';

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

  List<WorkExperience> _experiences = [];
  List<Education> _education = [];
  List<Project> _projects = [];

  bool _isLoading = false;

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
    super.dispose();
  }

  void _loadCVData(CVModel cv) {
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
    final companyController = TextEditingController(text: experience?.company ?? '');
    final positionController = TextEditingController(text: experience?.position ?? '');
    final locationController = TextEditingController(text: experience?.location ?? '');
    final descriptionController = TextEditingController(text: experience?.description ?? '');
    DateTime startDate = experience?.startDate ?? DateTime.now();
    DateTime? endDate = experience?.endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(experience != null ? 'Editar Experiência' : 'Nova Experiência'),
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
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setDialogState(() {
                              startDate = date;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('Data de fim'),
                        subtitle: Text(endDate != null 
                            ? DateFormat('MM/yyyy').format(endDate)
                            : 'Atual'),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: endDate ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setDialogState(() {
                              endDate = date;
                            });
                          }
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
                    location: locationController.text.isEmpty ? null : locationController.text,
                    startDate: startDate,
                    endDate: endDate,
                    description: descriptionController.text.isEmpty ? null : descriptionController.text,
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
    final institutionController = TextEditingController(text: education?.institution ?? '');
    final degreeController = TextEditingController(text: education?.degree ?? '');
    final fieldController = TextEditingController(text: education?.field ?? '');
    final descriptionController = TextEditingController(text: education?.description ?? '');
    DateTime startDate = education?.startDate ?? DateTime.now();
    DateTime? endDate = education?.endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setDialogState(() {
                              startDate = date;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('Data de fim'),
                        subtitle: Text(endDate != null 
                            ? DateFormat('MM/yyyy').format(endDate)
                            : 'Atual'),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: endDate ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setDialogState(() {
                              endDate = date;
                            });
                          }
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
                    field: fieldController.text.isEmpty ? null : fieldController.text,
                    startDate: startDate,
                    endDate: endDate,
                    description: descriptionController.text.isEmpty ? null : descriptionController.text,
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

  Future<void> _saveCV() async {
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
      );

      final service = ref.read(jobManagementServiceProvider);
      await service.saveCV(cv);

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
}
