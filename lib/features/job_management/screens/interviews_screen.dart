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
import '../models/interview_model.dart';
import '../providers/job_management_provider.dart';

class InterviewsScreen extends ConsumerStatefulWidget {
  const InterviewsScreen({super.key});

  @override
  ConsumerState<InterviewsScreen> createState() => _InterviewsScreenState();
}

class _InterviewsScreenState extends ConsumerState<InterviewsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  InterviewType? _selectedType;
  InterviewStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final strings = ref.watch(appStringsProvider);
    final interviewsAsync = ref.watch(interviewsNotifierProvider);

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          _buildSearchAndFilters(isDarkMode, strings),
          Expanded(
            child: interviewsAsync.when(
              data: (interviews) {
                final filteredInterviews = _filterInterviews(interviews);
                if (filteredInterviews.isEmpty) {
                  return _buildEmptyState(isDarkMode, strings);
                }
                return _buildInterviewsList(
                    filteredInterviews, isDarkMode, strings);
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
              hintText: 'Buscar entrevistas...',
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
          Row(
            children: [
              Expanded(
                child: _buildTypeFilter(isDarkMode, strings),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusFilter(isDarkMode, strings),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter(bool isDarkMode, AppStrings strings) {
    return DropdownButtonFormField<InterviewType?>(
      value: _selectedType,
      onChanged: (value) {
        setState(() {
          _selectedType = value;
        });
      },
      decoration: InputDecoration(
        labelText: strings.jobType,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      items: [
        DropdownMenuItem<InterviewType?>(
          value: null,
          child: Text('Todos os tipos'),
        ),
        ...InterviewType.values.map((type) => DropdownMenuItem(
              value: type,
              child: Text(_getTypeLabel(type, strings)),
            )),
      ],
    );
  }

  Widget _buildStatusFilter(bool isDarkMode, AppStrings strings) {
    return DropdownButtonFormField<InterviewStatus?>(
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
        DropdownMenuItem<InterviewStatus?>(
          value: null,
          child: Text('Todos os status'),
        ),
        ...InterviewStatus.values.map((status) => DropdownMenuItem(
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
            PhosphorIcons.chatCentered(),
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            strings.jobNoInterviews,
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
            'Comece criando sua primeira entrevista',
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
            'Erro ao carregar entrevistas',
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

  Widget _buildInterviewsList(
      List<InterviewModel> interviews, bool isDarkMode, AppStrings strings) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: interviews.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final interview = interviews[index];
        return _buildInterviewCard(interview, isDarkMode, strings);
      },
    );
  }

  Widget _buildInterviewCard(
      InterviewModel interview, bool isDarkMode, AppStrings strings) {
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
        onTap: () => _showInterviewDetails(interview, isDarkMode, strings),
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
                      color: _getInterviewTypeColor(interview.type)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getInterviewTypeIcon(interview.type),
                      color: _getInterviewTypeColor(interview.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          interview.title,
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
                          interview.company,
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
                  _buildStatusBadge(interview.status, strings),
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
                    DateFormat('dd/MM/yyyy - HH:mm').format(interview.dateTime),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (interview.salaryProposal != null) ...[
                    Icon(
                      PhosphorIcons.currencyDollar(),
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${interview.salaryProposal}€',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ],
              ),
              if (interview.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  interview.description!,
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

  Widget _buildStatusBadge(InterviewStatus status, AppStrings strings) {
    Color color;
    String text;

    switch (status) {
      case InterviewStatus.scheduled:
        color = Colors.blue;
        text = strings.jobScheduled;
        break;
      case InterviewStatus.completed:
        color = Colors.green;
        text = strings.jobCompleted;
        break;
      case InterviewStatus.cancelled:
        color = Colors.red;
        text = strings.jobCancelled;
        break;
      case InterviewStatus.pending:
        color = Colors.orange;
        text = strings.jobPending;
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

  List<InterviewModel> _filterInterviews(List<InterviewModel> interviews) {
    return interviews.where((interview) {
      final matchesSearch = _searchQuery.isEmpty ||
          interview.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          interview.company.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesType =
          _selectedType == null || interview.type == _selectedType;
      final matchesStatus =
          _selectedStatus == null || interview.status == _selectedStatus;

      return matchesSearch && matchesType && matchesStatus;
    }).toList();
  }

  void _showInterviewDetails(
      InterviewModel interview, bool isDarkMode, AppStrings strings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(interview.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Empresa: ${interview.company}'),
            Text('Tipo: ${_getTypeLabel(interview.type, strings)}'),
            Text('Status: ${_getStatusLabel(interview.status, strings)}'),
            Text(
                'Data: ${DateFormat('dd/MM/yyyy - HH:mm').format(interview.dateTime)}'),
            if (interview.salaryProposal != null)
              Text('Salário: ${interview.salaryProposal}€'),
            if (interview.description != null) ...[
              const SizedBox(height: 8),
              Text('Descrição: ${interview.description}'),
            ],
          ],
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

  String _getTypeLabel(InterviewType type, AppStrings strings) {
    switch (type) {
      case InterviewType.rh:
        return strings.jobInterviewTypeRH;
      case InterviewType.technical:
        return strings.jobInterviewTypeTechnical;
      case InterviewType.teamLead:
        return strings.jobInterviewTypeTeamLead;
    }
  }

  String _getStatusLabel(InterviewStatus status, AppStrings strings) {
    switch (status) {
      case InterviewStatus.scheduled:
        return strings.jobScheduled;
      case InterviewStatus.completed:
        return strings.jobCompleted;
      case InterviewStatus.cancelled:
        return strings.jobCancelled;
      case InterviewStatus.pending:
        return strings.jobPending;
    }
  }

  PhosphorIconData _getInterviewTypeIcon(InterviewType type) {
    switch (type) {
      case InterviewType.rh:
        return PhosphorIcons.user();
      case InterviewType.technical:
        return PhosphorIcons.code();
      case InterviewType.teamLead:
        return PhosphorIcons.crown();
    }
  }

  Color _getInterviewTypeColor(InterviewType type) {
    switch (type) {
      case InterviewType.rh:
        return Colors.purple;
      case InterviewType.technical:
        return Colors.blue;
      case InterviewType.teamLead:
        return Colors.orange;
    }
  }
}
