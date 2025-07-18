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
import '../providers/job_management_provider.dart';
import 'application_form_screen.dart';

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
    final applicationsAsync = ref.watch(applicationsNotifierProvider);

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewApplication(),
        backgroundColor: AppColors.primary,
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
      builder: (context) => AlertDialog(
        title: Text(application.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Empresa: ${application.company}'),
              Text('Status: ${_getStatusLabel(application.status, strings)}'),
              Text(
                  'Aplicado em: ${DateFormat('dd/MM/yyyy').format(application.appliedDate)}'),
              if (application.platform != null)
                Text('Plataforma: ${application.platform}'),
              if (application.location != null)
                Text('Localização: ${application.location}'),
              if (application.aiMatchPercentage != null)
                Text('Match AI: ${application.aiMatchPercentage!}%'),
              if (application.description != null) ...[
                const SizedBox(height: 8),
                Text('Descrição: ${application.description}'),
              ],
              if (application.motivationLetter != null) ...[
                const SizedBox(height: 8),
                Text('Carta de motivação: ${application.motivationLetter}'),
              ],
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
              // TODO: Implementar edição
            },
            child: Text('Editar'),
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

  void _createNewApplication() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ApplicationFormScreen(),
      ),
    );
  }

  Color _getMatchColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    if (percentage >= 40) return Colors.yellow;
    return Colors.red;
  }
}
