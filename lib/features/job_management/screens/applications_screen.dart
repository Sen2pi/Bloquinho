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
import '../models/email_tracking_model.dart';
import '../providers/job_management_provider.dart';
import 'application_form_screen.dart';
import 'package:file_picker/file_picker.dart';

class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ApplicationStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final strings = ref.watch(appStringsProvider);
    final applicationsAsync = ref.watch(applicationsProvider);

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewApplication(),
        backgroundColor: AppColors.primary,
        heroTag: "applications_screen_fab",
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(isDarkMode, strings),
          Expanded(
            child: applicationsAsync.when(
              data: (applications) {
                final filteredApplications = _filterApplications(applications);
                if (filteredApplications.isEmpty) {
                  return _buildEmptyState(isDarkMode, strings);
                }
                return _buildApplicationsList(
                    filteredApplications, isDarkMode, strings);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(error, isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(bool isDarkMode, AppStrings strings) {
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
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar candidaturas...',
              prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color:
                      isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              filled: true,
              fillColor: isDarkMode
                  ? AppColors.darkBackground
                  : AppColors.lightBackground,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusFilter(isDarkMode, strings),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(bool isDarkMode, AppStrings strings) {
    return DropdownButtonFormField<ApplicationStatus?>(
      value: _selectedStatus,
      onChanged: (value) {
        setState(() {
          _selectedStatus = value;
        });
      },
      decoration: InputDecoration(
        labelText: strings.jobStatus,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      items: [
        DropdownMenuItem<ApplicationStatus?>(
          value: null,
          child: Text('Todos os status'),
        ),
        ...ApplicationStatus.values.map((status) => DropdownMenuItem(
              value: status,
              child: Text(_getStatusLabel(status, strings)),
            )),
      ],
    );
  }

  Widget _buildEmptyState(bool isDarkMode, AppStrings strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.paperPlaneTilt(),
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            strings.jobNoApplications,
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
            'Comece criando sua primeira candidatura',
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
            'Erro ao carregar candidaturas',
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

  Widget _buildApplicationsList(List<ApplicationModel> applications,
      bool isDarkMode, AppStrings strings) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: applications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final application = applications[index];
        return _buildApplicationCard(application, isDarkMode, strings);
      },
    );
  }

  Widget _buildApplicationCard(
      ApplicationModel application, bool isDarkMode, AppStrings strings) {
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
        onTap: () => _showApplicationDetails(application, isDarkMode, strings),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      PhosphorIcons.paperPlaneTilt(),
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          application.company,
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
                  _buildStatusBadge(application.status, strings),
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
                    'Aplicado em ${DateFormat('dd/MM/yyyy').format(application.appliedDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (application.platform != null) ...[
                    Icon(
                      PhosphorIcons.globe(),
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      application.platform!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
              if (application.aiMatchPercentage != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.sparkle(),
                      size: 16,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Match AI: ${application.aiMatchPercentage!}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LinearProgressIndicator(
                        value:
                            double.tryParse(application.aiMatchPercentage!) ??
                                0.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getMatchColor(
                              double.tryParse(application.aiMatchPercentage!) ??
                                  0.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (application.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  application.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ApplicationStatus status, AppStrings strings) {
    Color color;
    String text;

    switch (status) {
      case ApplicationStatus.applied:
        color = Colors.blue;
        text = strings.jobApplied;
        break;
      case ApplicationStatus.inReview:
        color = Colors.orange;
        text = strings.jobInReview;
        break;
      case ApplicationStatus.interviewScheduled:
        color = Colors.purple;
        text = strings.jobInterviewScheduled;
        break;
      case ApplicationStatus.rejected:
        color = Colors.red;
        text = strings.jobRejected;
        break;
      case ApplicationStatus.accepted:
        color = Colors.green;
        text = strings.jobAccepted;
        break;
      case ApplicationStatus.withdrawn:
        color = Colors.grey;
        text = strings.jobWithdrawn;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  List<ApplicationModel> _filterApplications(
      List<ApplicationModel> applications) {
    return applications.where((application) {
      final matchesSearch = _searchQuery.isEmpty ||
          application.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          application.company
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      final matchesStatus =
          _selectedStatus == null || application.status == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _showApplicationDetails(
      ApplicationModel application, bool isDarkMode, AppStrings strings) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Header com título e status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.buildings(),
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              application.company,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildStatusBadge(application.status, strings),
                ],
              ),
              const SizedBox(height: 24),
              
              // Conteúdo scrollável
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informações básicas
                      _buildDetailSection(
                        'Informações Básicas',
                        [
                          _buildDetailRow(
                            PhosphorIcons.calendar(),
                            'Data da candidatura',
                            DateFormat('dd/MM/yyyy').format(application.appliedDate),
                          ),
                          if (application.platform != null)
                            _buildDetailRow(
                              PhosphorIcons.globe(),
                              'Plataforma',
                              application.platform!,
                            ),
                          if (application.location != null)
                            _buildDetailRow(
                              PhosphorIcons.mapPin(),
                              'Localização',
                              application.location!,
                            ),
                          if (application.companyLink != null)
                            _buildDetailRow(
                              PhosphorIcons.link(),
                              'Link da empresa',
                              application.companyLink!,
                              isLink: true,
                            ),
                        ],
                        isDarkMode,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Match AI
                      if (application.aiMatchPercentage != null) ...[
                        _buildDetailSection(
                          'Análise AI',
                          [
                            Row(
                              children: [
                                Icon(
                                  PhosphorIcons.sparkle(),
                                  size: 20,
                                  color: Colors.purple,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Match: ${application.aiMatchPercentage!}%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.purple,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: double.tryParse(application.aiMatchPercentage!) ?? 0.0,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getMatchColor(double.tryParse(application.aiMatchPercentage!) ?? 0.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          isDarkMode,
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      // Descrição
                      if (application.description != null) ...[
                        _buildDetailSection(
                          'Descrição da Vaga',
                          [
                            Text(
                              application.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                          isDarkMode,
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      // Carta de motivação
                      if (application.motivationLetter != null) ...[
                        _buildDetailSection(
                          'Carta de Motivação',
                          [
                            Text(
                              application.motivationLetter!,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                          isDarkMode,
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      // Notas
                      if (application.notes != null) ...[
                        _buildDetailSection(
                          'Notas Pessoais',
                          [
                            Text(
                              application.notes!,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                          isDarkMode,
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      // Email Tracking
                      _buildEmailTrackingSection(application, isDarkMode, strings),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Botões de ação
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(PhosphorIcons.x()),
                      label: const Text('Fechar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _editApplication(application);
                      },
                      icon: Icon(PhosphorIcons.pencil()),
                      label: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(application);
                    },
                    icon: Icon(PhosphorIcons.trash()),
                    label: const Text('Apagar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode 
                ? AppColors.darkBackground.withOpacity(0.5)
                : AppColors.lightBackground.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isLink ? Colors.blue : null,
                    decoration: isLink ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editApplication(ApplicationModel application) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicationFormScreen(application: application),
      ),
    );
    
    // Se a candidatura foi editada com sucesso, recarregar a lista
    if (result == true) {
      ref.refresh(applicationsProvider);
    }
  }

  void _showDeleteConfirmation(ApplicationModel application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIcons.warning(), color: Colors.red),
            const SizedBox(width: 8),
            const Text('Confirmar exclusão'),
          ],
        ),
        content: Text('Tem certeza que deseja excluir a candidatura "${application.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final service = ref.read(jobManagementServiceProvider);
                await service.deleteApplication(application.id);
                ref.refresh(applicationsProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Candidatura excluída com sucesso'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir candidatura: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(ApplicationStatus status, AppStrings strings) {
    switch (status) {
      case ApplicationStatus.applied:
        return strings.jobApplied;
      case ApplicationStatus.inReview:
        return strings.jobInReview;
      case ApplicationStatus.interviewScheduled:
        return strings.jobApplicationStatusInterviewScheduled;
      case ApplicationStatus.rejected:
        return strings.jobRejected;
      case ApplicationStatus.accepted:
        return strings.jobAccepted;
      case ApplicationStatus.withdrawn:
        return strings.jobWithdrawn;
    }
  }

  Future<void> _createNewApplication() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const ApplicationFormScreen(),
      ),
    );
    
    // Se a candidatura foi criada/editada com sucesso, recarregar a lista
    if (result == true) {
      ref.refresh(applicationsProvider);
    }
  }

  Color _getMatchColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    if (percentage >= 40) return Colors.yellow;
    return Colors.red;
  }

  Widget _buildEmailTrackingSection(ApplicationModel application, bool isDarkMode, AppStrings strings) {
    return Consumer(
      builder: (context, ref, child) {
        // Load emails for this application
        final emailsAsync = ref.watch(emailTrackingByApplicationProvider(application.id));
        
        return _buildDetailSection(
          'Rastreamento de Emails',
          [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Emails trocados relacionados a esta candidatura',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _uploadEmailFile(application.id),
                  icon: Icon(PhosphorIcons.upload(), size: 16),
                  label: const Text('Adicionar Email'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            emailsAsync.when(
              data: (emails) {
                if (emails.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.envelope(), color: Colors.grey[500], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Nenhum email adicionado ainda',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return Column(
                  children: emails.map((email) => _buildEmailCard(email, isDarkMode)).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIcons.warning(), color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Erro ao carregar emails: $error',
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          isDarkMode,
        );
      },
    );
  }

  Widget _buildEmailCard(EmailTrackingModel email, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showEmailDetails(email, isDarkMode),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: email.direction == EmailDirection.sent 
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      email.direction == EmailDirection.sent ? 'ENVIADO' : 'RECEBIDO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: email.direction == EmailDirection.sent ? Colors.blue : Colors.green,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(email.sentDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _deleteEmail(email),
                    child: Icon(
                      PhosphorIcons.trash(),
                      size: 16,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      email.subject,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    PhosphorIcons.eye(),
                    size: 14,
                    color: Colors.grey[500],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(PhosphorIcons.user(), size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'De: ${email.fromEmail}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(PhosphorIcons.userCircle(), size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Para: ${email.toEmail}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (email.body != null && email.body!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    email.body!.length > 100 
                        ? '${email.body!.substring(0, 100)}...'
                        : email.body!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadEmailFile(String applicationId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['eml'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          final emlParserService = ref.read(emlParserServiceProvider);
          final emailTracking = await emlParserService.parseEmlFile(file.path!, applicationId);
          
          if (emailTracking != null) {
            // Mostrar diálogo para escolher direção do email
            final selectedDirection = await _showDirectionSelectionDialog(emailTracking);
            
            if (selectedDirection != null) {
              // Atualizar email com a direção selecionada
              final updatedEmail = emailTracking.copyWith(direction: selectedDirection);
              
              final emailTrackingStorage = ref.read(emailTrackingStorageServiceProvider);
              await emailTrackingStorage.saveEmail(updatedEmail);
              
              // Invalidar e recarregar a lista de emails para esta candidatura
              ref.invalidate(emailTrackingByApplicationProvider(applicationId));
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email adicionado com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erro ao processar arquivo de email'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar arquivo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteEmail(EmailTrackingModel email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIcons.warning(), color: Colors.red),
            const SizedBox(width: 8),
            const Text('Confirmar exclusão'),
          ],
        ),
        content: Text('Tem certeza que deseja excluir o email "${email.subject}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final emailTrackingStorage = ref.read(emailTrackingStorageServiceProvider);
              await emailTrackingStorage.deleteEmail(email.id);
              
              // Invalidar e recarregar a lista de emails para esta candidatura
              ref.invalidate(emailTrackingByApplicationProvider(email.applicationId));
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email excluído com sucesso'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<EmailDirection?> _showDirectionSelectionDialog(EmailTrackingModel email) async {
    return await showDialog<EmailDirection>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIcons.envelope(), color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Direção do Email'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assunto: ${email.subject}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text('De: ${email.fromEmail}'),
            Text('Para: ${email.toEmail}'),
            const SizedBox(height: 16),
            const Text('Selecione a direção deste email:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, EmailDirection.received),
            icon: Icon(PhosphorIcons.arrowDown(), size: 16),
            label: const Text('Recebido'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, EmailDirection.sent),
            icon: Icon(PhosphorIcons.arrowUp(), size: 16),
            label: const Text('Enviado'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showEmailDetails(EmailTrackingModel email, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.envelope(),
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Detalhes do Email',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: email.direction == EmailDirection.sent 
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        email.direction == EmailDirection.sent ? 'ENVIADO' : 'RECEBIDO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: email.direction == EmailDirection.sent ? Colors.blue : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Conteúdo scrollável
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Informações do email
                        _buildEmailDetailSection(
                          'Informações do Email',
                          [
                            _buildEmailDetailRow(
                              PhosphorIcons.textT(),
                              'Assunto',
                              email.subject,
                            ),
                            _buildEmailDetailRow(
                              PhosphorIcons.calendar(),
                              'Data',
                              DateFormat('dd/MM/yyyy HH:mm').format(email.sentDate),
                            ),
                            _buildEmailDetailRow(
                              PhosphorIcons.user(),
                              'De',
                              email.fromEmail,
                            ),
                            _buildEmailDetailRow(
                              PhosphorIcons.userCircle(),
                              'Para',
                              email.toEmail,
                            ),
                            if (email.ccEmail != null)
                              _buildEmailDetailRow(
                                PhosphorIcons.users(),
                                'CC',
                                email.ccEmail!,
                              ),
                            if (email.bccEmail != null)
                              _buildEmailDetailRow(
                                PhosphorIcons.usersThree(),
                                'BCC',
                                email.bccEmail!,
                              ),
                          ],
                          isDarkMode,
                        ),

                        const SizedBox(height: 20),

                        // Conteúdo do email
                        if (email.body != null && email.body!.isNotEmpty) ...[
                          _buildEmailDetailSection(
                            'Conteúdo do Email',
                            [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDarkMode 
                                      ? AppColors.darkBackground.withOpacity(0.3)
                                      : AppColors.lightBackground.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
                                  ),
                                ),
                                child: SelectableText(
                                  email.body!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDarkMode
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                            isDarkMode,
                          ),
                        ] else ...[
                          _buildEmailDetailSection(
                            'Conteúdo do Email',
                            [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(PhosphorIcons.info(), color: Colors.grey[500], size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Conteúdo do email não disponível',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            isDarkMode,
                          ),
                        ],

                        // Anexos (se houver)
                        if (email.attachments.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildEmailDetailSection(
                            'Anexos',
                            email.attachments.map((attachment) => 
                              Row(
                                children: [
                                  Icon(PhosphorIcons.paperclip(), size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      attachment,
                                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                    ),
                                  ),
                                ],
                              ),
                            ).toList(),
                            isDarkMode,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Botões de ação
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(PhosphorIcons.x()),
                        label: const Text('Fechar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteEmail(email);
                      },
                      icon: Icon(PhosphorIcons.trash()),
                      label: const Text('Excluir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailDetailSection(String title, List<Widget> children, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode 
                ? AppColors.darkBackground.withOpacity(0.5)
                : AppColors.lightBackground.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
