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
import 'package:uuid/uuid.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_strings.dart';
import '../models/interview_model.dart';
import '../models/cv_model.dart';
import '../models/application_model.dart';
import '../providers/job_management_provider.dart';
import '../../agenda/providers/agenda_provider.dart';
import '../../agenda/models/agenda_item.dart';

class InterviewFormScreen extends ConsumerStatefulWidget {
  final InterviewModel? interview; // null para criar novo, não null para editar

  const InterviewFormScreen({super.key, this.interview});

  @override
  ConsumerState<InterviewFormScreen> createState() =>
      _InterviewFormScreenState();
}

class _InterviewFormScreenState extends ConsumerState<InterviewFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _companyController = TextEditingController();
  final _companyLinkController = TextEditingController();
  final _countryController = TextEditingController();
  final _languageController = TextEditingController();
  final _notesController = TextEditingController();

  InterviewType _selectedType = InterviewType.technical;
  InterviewStatus _selectedStatus = InterviewStatus.scheduled;
  DateTime _dateTime = DateTime.now().add(const Duration(days: 1));
  String? _selectedCVId;
  String? _selectedApplicationId;
  double? _salaryProposal;
  double? _annualSalary;

  List<CVModel> _availableCVs = [];
  List<ApplicationModel> _availableApplications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.interview != null) {
      _loadInterviewData(widget.interview!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _companyController.dispose();
    _companyLinkController.dispose();
    _countryController.dispose();
    _languageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final service = ref.read(jobManagementServiceProvider);
      final cvs = await service.getCVs();
      final applications = await service.getApplications();

      setState(() {
        _availableCVs = cvs;
        _availableApplications = applications;
        if (cvs.isNotEmpty && _selectedCVId == null) {
          _selectedCVId = cvs.first.id;
        }
      });
    } catch (e) {
      // Erro ao carregar dados
    }
  }

  void _loadInterviewData(InterviewModel interview) {
    _titleController.text = interview.title;
    _descriptionController.text = interview.description ?? '';
    _companyController.text = interview.company;
    _companyLinkController.text = interview.companyLink ?? '';
    _countryController.text = interview.country;
    _languageController.text = interview.language;
    _notesController.text = interview.notes ?? '';
    _selectedType = interview.type;
    _selectedStatus = interview.status;
    _dateTime = interview.dateTime;
    _selectedCVId = interview.cvId;
    _selectedApplicationId = interview.applicationId;
    _salaryProposal = interview.salaryProposal;
    _annualSalary = interview.annualSalary;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
            widget.interview != null ? 'Editar Entrevista' : 'Nova Entrevista'),
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
              _buildInterviewDetailsSection(isDarkMode, strings),
              const SizedBox(height: 24),
              _buildLinkedDataSection(isDarkMode, strings),
              const SizedBox(height: 24),
              _buildSalarySection(isDarkMode, strings),
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
              'Informações Básicas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título da entrevista',
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'País',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'País é obrigatório';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _languageController,
                    decoration: const InputDecoration(
                      labelText: 'Idioma',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Idioma é obrigatório';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterviewDetailsSection(bool isDarkMode, AppStrings strings) {
    return Card(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalhes da Entrevista',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<InterviewType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo de entrevista',
                border: OutlineInputBorder(),
              ),
              items: InterviewType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(_getTypeLabel(type)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<InterviewStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status da entrevista',
                border: OutlineInputBorder(),
              ),
              items: InterviewStatus.values
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
              title: const Text('Data e hora'),
              subtitle:
                  Text(DateFormat('dd/MM/yyyy - HH:mm').format(_dateTime)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dateTime,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_dateTime),
                  );
                  if (time != null) {
                    setState(() {
                      _dateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição da entrevista',
                border: OutlineInputBorder(),
                hintText: 'Detalhes sobre a entrevista...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkedDataSection(bool isDarkMode, AppStrings strings) {
    return Card(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dados Vinculados',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              value: _selectedCVId != null &&
                      _availableCVs.any((cv) => cv.id == _selectedCVId)
                  ? _selectedCVId
                  : null,
              decoration: const InputDecoration(
                labelText: 'CV utilizado (opcional)',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Nenhum CV selecionado'),
                ),
                ..._availableCVs.map((cv) => DropdownMenuItem(
                      value: cv.id,
                      child: Text(cv.name),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCVId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              value: _selectedApplicationId != null &&
                      _availableApplications
                          .any((app) => app.id == _selectedApplicationId)
                  ? _selectedApplicationId
                  : null,
              decoration: const InputDecoration(
                labelText: 'Candidatura vinculada (opcional)',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Nenhuma candidatura vinculada'),
                ),
                ..._availableApplications.map((app) => DropdownMenuItem(
                      value: app.id,
                      child: Text('${app.title} - ${app.company}'),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedApplicationId = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalarySection(bool isDarkMode, AppStrings strings) {
    return Card(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações Salariais',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Proposta salarial (€)',
                border: OutlineInputBorder(),
                hintText: 'Ex: 50000',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _salaryProposal = double.tryParse(value);
              },
              controller: TextEditingController(
                text: _salaryProposal?.toString() ?? '',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Salário anual (€)',
                border: OutlineInputBorder(),
                hintText: 'Ex: 60000',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _annualSalary = double.tryParse(value);
              },
              controller: TextEditingController(
                text: _annualSalary?.toString() ?? '',
              ),
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
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas pessoais',
                border: OutlineInputBorder(),
                hintText: 'Observações sobre a entrevista...',
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
        onPressed: _isLoading ? null : _saveInterview,
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
                widget.interview != null
                    ? 'Atualizar Entrevista'
                    : 'Criar Entrevista',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  String _getTypeLabel(InterviewType type) {
    switch (type) {
      case InterviewType.rh:
        return 'Recursos Humanos';
      case InterviewType.technical:
        return 'Técnica';
      case InterviewType.teamLead:
        return 'Team Lead';
    }
  }

  String _getStatusLabel(InterviewStatus status) {
    switch (status) {
      case InterviewStatus.scheduled:
        return 'Agendada';
      case InterviewStatus.completed:
        return 'Concluída';
      case InterviewStatus.cancelled:
        return 'Cancelada';
      case InterviewStatus.pending:
        return 'Pendente';
    }
  }

  Future<void> _saveInterview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final service = ref.read(jobManagementServiceProvider);

      InterviewModel interview;

      if (widget.interview != null) {
        // EDITAR entrevista existente
        interview = widget.interview!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          type: _selectedType,
          status: _selectedStatus, // IMPORTANTE: Atualizar o status
          dateTime: _dateTime,
          company: _companyController.text,
          companyLink: _companyLinkController.text.isEmpty
              ? null
              : _companyLinkController.text,
          country: _countryController.text,
          language: _languageController.text,
          salaryProposal: _salaryProposal,
          annualSalary: _annualSalary,
          cvId: _selectedCVId,
          applicationId: _selectedApplicationId,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
      } else {
        // CRIAR nova entrevista
        interview = InterviewModel.create(
          title: _titleController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          type: _selectedType,
          dateTime: _dateTime,
          company: _companyController.text,
          companyLink: _companyLinkController.text.isEmpty
              ? null
              : _companyLinkController.text,
          country: _countryController.text,
          language: _languageController.text,
          salaryProposal: _salaryProposal,
          annualSalary: _annualSalary,
          cvId: _selectedCVId,
          applicationId: _selectedApplicationId,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );

        // IMPORTANTE: Definir o status correto após criar
        interview = interview.copyWith(status: _selectedStatus);
      }

      await service.saveInterview(interview);

      // Criar evento na agenda apenas se for uma nova entrevista
      if (widget.interview == null) {
        try {
          final agendaService = ref.read(agendaServiceProvider);
          final agendaItem = AgendaItem(
            id: const Uuid().v4(),
            title: 'Entrevista: ${interview.title}',
            description:
                'Entrevista na empresa ${interview.company}\n${interview.description ?? ''}',
            startDate: interview.dateTime,
            endDate: interview.dateTime.add(const Duration(hours: 1)),
            type: AgendaItemType.meeting,
            status: TaskStatus.todo,
            priority: Priority.high,
            tags: ['trabalho', 'entrevista', interview.company.toLowerCase()],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await agendaService.createItem(agendaItem);
        } catch (e) {
          // Se falhar ao criar evento na agenda, apenas logar o erro mas não falhar a criação da entrevista
          print('Erro ao criar evento na agenda: $e');
        }
      }

      // Invalidar o provider para forçar reload
      ref.invalidate(interviewsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.interview != null
                ? 'Entrevista atualizada com sucesso!'
                : 'Entrevista criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retorna true indicando sucesso
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar entrevista: $e'),
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
