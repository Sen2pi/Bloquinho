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
import '../models/application_model.dart';
import '../models/cv_model.dart';
import '../providers/job_management_provider.dart';

class ApplicationFormScreen extends ConsumerStatefulWidget {
  final ApplicationModel?
      application; // null para criar novo, não null para editar

  const ApplicationFormScreen({super.key, this.application});

  @override
  ConsumerState<ApplicationFormScreen> createState() =>
      _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends ConsumerState<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _companyLinkController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _platformController = TextEditingController();
  final _motivationLetterController = TextEditingController();
  final _notesController = TextEditingController();

  ApplicationStatus _selectedStatus = ApplicationStatus.applied;
  DateTime _appliedDate = DateTime.now();
  String? _selectedCVId;
  List<CVModel> _availableCVs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCVs();
    if (widget.application != null) {
      _loadApplicationData(widget.application!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _companyLinkController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _platformController.dispose();
    _motivationLetterController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCVs() async {
    try {
      final service = ref.read(jobManagementServiceProvider);
      final cvs = await service.getCVs();
      setState(() {
        _availableCVs = cvs;
        if (cvs.isNotEmpty && _selectedCVId == null) {
          _selectedCVId = cvs.first.id;
        }
      });
    } catch (e) {
      // Erro ao carregar CVs
    }
  }

  void _loadApplicationData(ApplicationModel application) {
    _titleController.text = application.title;
    _companyController.text = application.company;
    _companyLinkController.text = application.companyLink ?? '';
    _descriptionController.text = application.description ?? '';
    _locationController.text = application.location ?? '';
    _platformController.text = application.platform ?? '';
    _motivationLetterController.text = application.motivationLetter ?? '';
    _notesController.text = application.notes ?? '';
    _selectedStatus = application.status;
    _appliedDate = application.appliedDate;
    _selectedCVId = application.cvId;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(widget.application != null
            ? 'Editar Candidatura'
            : 'Nova Candidatura'),
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
              _buildCVSelectionSection(isDarkMode, strings),
              const SizedBox(height: 24),
              _buildAdditionalInfoSection(isDarkMode, strings),
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
              'Informações da Vaga',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título da vaga',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Título é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Empresa',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Empresa é obrigatória';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyLinkController,
              decoration: const InputDecoration(
                labelText: 'Link da empresa (opcional)',
                border: OutlineInputBorder(),
                hintText: 'https://empresa.com',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Localização',
                border: OutlineInputBorder(),
                hintText: 'Ex: Remoto, São Paulo, SP',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _platformController,
              decoration: const InputDecoration(
                labelText: 'Plataforma',
                border: OutlineInputBorder(),
                hintText: 'Ex: LinkedIn, Indeed, Glassdoor',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição da vaga',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCVSelectionSection(bool isDarkMode, AppStrings strings) {
    return Card(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CV e Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCVId,
              decoration: const InputDecoration(
                labelText: 'CV utilizado',
                border: OutlineInputBorder(),
              ),
              items: _availableCVs
                  .map((cv) => DropdownMenuItem(
                        value: cv.id,
                        child: Text(cv.name),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCVId = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Selecione um CV';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ApplicationStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status da candidatura',
                border: OutlineInputBorder(),
              ),
              items: ApplicationStatus.values
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(_getStatusLabel(status)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Data da candidatura'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_appliedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _appliedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _appliedDate = date;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection(bool isDarkMode, AppStrings strings) {
    return Card(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações Adicionais',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _motivationLetterController,
              decoration: const InputDecoration(
                labelText: 'Carta de motivação',
                border: OutlineInputBorder(),
                hintText: 'Cole aqui sua carta de motivação...',
              ),
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas pessoais',
                border: OutlineInputBorder(),
                hintText: 'Observações sobre a candidatura...',
              ),
              maxLines: 4,
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
        onPressed: _isLoading ? null : _saveApplication,
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
                widget.application != null
                    ? 'Atualizar Candidatura'
                    : 'Criar Candidatura',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  String _getStatusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return 'Candidatura enviada';
      case ApplicationStatus.inReview:
        return 'Em análise';
      case ApplicationStatus.interviewScheduled:
        return 'Entrevista agendada';
      case ApplicationStatus.rejected:
        return 'Rejeitada';
      case ApplicationStatus.accepted:
        return 'Aceita';
      case ApplicationStatus.withdrawn:
        return 'Retirada';
    }
  }

  Future<void> _saveApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final application = ApplicationModel.create(
        title: _titleController.text,
        company: _companyController.text,
        companyLink: _companyLinkController.text.isEmpty
            ? null
            : _companyLinkController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        appliedDate: _appliedDate,
        location:
            _locationController.text.isEmpty ? null : _locationController.text,
        platform:
            _platformController.text.isEmpty ? null : _platformController.text,
        cvId: _selectedCVId!,
        motivationLetter: _motivationLetterController.text.isEmpty
            ? null
            : _motivationLetterController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      final service = ref.read(jobManagementServiceProvider);
      await service.saveApplication(application);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.application != null
                ? 'Candidatura atualizada com sucesso!'
                : 'Candidatura criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar candidatura: $e'),
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
