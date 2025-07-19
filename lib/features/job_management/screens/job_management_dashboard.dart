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
import 'package:go_router/go_router.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../shared/providers/workspace_provider.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_strings.dart';
import '../providers/job_management_provider.dart';
import '../models/interview_model.dart';
import '../widgets/job_stats_card.dart';
import '../widgets/recent_interviews_widget.dart';
import '../widgets/quick_actions_widget.dart';
import 'interviews_screen.dart';
import 'cvs_screen.dart';
import 'applications_screen.dart';

class JobManagementDashboard extends ConsumerStatefulWidget {
  const JobManagementDashboard({super.key});

  @override
  ConsumerState<JobManagementDashboard> createState() =>
      _JobManagementDashboardState();
}

class _JobManagementDashboardState extends ConsumerState<JobManagementDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final strings = ref.watch(appStringsProvider);
    final currentWorkspace = ref.watch(currentWorkspaceProvider);
    final currentProfile = ref.watch(currentProfileProvider);

    // Verificar se estamos no workspace de trabalho
    if (currentWorkspace?.name != 'Trabalho') {
      return _buildWorkspaceRestrictionScreen(isDarkMode, strings);
    }

    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          elevation: 0,
          backgroundColor:
              isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          foregroundColor: isDarkMode
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          title: Row(
            children: [
              Icon(
                PhosphorIcons.briefcase(),
                size: 24,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                strings.jobManagement,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                icon: Icon(PhosphorIcons.chartLine()),
                text: strings.jobDashboard,
              ),
              Tab(
                icon: Icon(PhosphorIcons.chatCentered()),
                text: strings.jobInterviews,
              ),
              Tab(
                icon: Icon(PhosphorIcons.fileText()),
                text: strings.jobCVs,
              ),
              Tab(
                icon: Icon(PhosphorIcons.paperPlaneTilt()),
                text: strings.jobApplications,
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDashboardTab(isDarkMode, strings),
            const InterviewsScreen(),
            const CVsScreen(),
            const ApplicationsScreen(),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(isDarkMode, strings),
      ),
    );
  }

  Widget _buildWorkspaceRestrictionScreen(bool isDarkMode, AppStrings strings) {
    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        foregroundColor:
            isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        title: Text(strings.jobManagement),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.lock(),
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              strings.jobWorkspaceOnly,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Mude para o workspace "Trabalho" para acessar esta funcionalidade.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/workspace'),
              icon: Icon(PhosphorIcons.house()),
              label: Text('Voltar ao Workspace'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab(bool isDarkMode, AppStrings strings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estatísticas principais
          _buildStatsSection(isDarkMode, strings),

          const SizedBox(height: 24),

          // Ações rápidas
          _buildQuickActionsSection(isDarkMode, strings),

          const SizedBox(height: 24),

          // Entrevistas recentes
          _buildRecentInterviewsSection(isDarkMode, strings),

          const SizedBox(height: 24),

          // Resumo mensal
          _buildMonthlySummarySection(isDarkMode, strings),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDarkMode, AppStrings strings) {
    final statsAsync = ref.watch(jobStatisticsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.statistics,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
        ),
        const SizedBox(height: 16),
        statsAsync.when(
          data: (stats) => _buildStatsGrid(stats, isDarkMode, strings),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'Erro ao carregar estatísticas',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
      Map<String, dynamic> stats, bool isDarkMode, AppStrings strings) {
    return Row(
      children: [
        Expanded(
          child: JobStatsCard(
            title: strings.jobTotalInterviews,
            value: stats['totalInterviews']?.toString() ?? '0',
            icon: PhosphorIcons.chatCentered(),
            color: Colors.blue,
            isDarkMode: isDarkMode,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: JobStatsCard(
            title: strings.jobTotalCVs,
            value: stats['totalCVs']?.toString() ?? '0',
            icon: PhosphorIcons.fileText(),
            color: Colors.green,
            isDarkMode: isDarkMode,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: JobStatsCard(
            title: strings.jobTotalApplications,
            value: stats['totalApplications']?.toString() ?? '0',
            icon: PhosphorIcons.paperPlaneTilt(),
            color: Colors.orange,
            isDarkMode: isDarkMode,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: JobStatsCard(
            title: strings.jobThisMonth,
            value: stats['interviewsThisMonth']?.toString() ?? '0',
            icon: PhosphorIcons.calendar(),
            color: Colors.purple,
            isDarkMode: isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(bool isDarkMode, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
        ),
        const SizedBox(height: 16),
        QuickActionsWidget(
          isDarkMode: isDarkMode,
          strings: strings,
        ),
      ],
    );
  }

  Widget _buildRecentInterviewsSection(bool isDarkMode, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strings.jobRecentInterviews,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
            ),
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: Text(
                'Ver todas',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RecentInterviewsWidget(
          isDarkMode: isDarkMode,
          strings: strings,
        ),
      ],
    );
  }

  Widget _buildMonthlySummarySection(bool isDarkMode, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo Mensal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
          ),
          const SizedBox(height: 12),
          _buildMonthlySummaryContent(isDarkMode, strings),
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryContent(bool isDarkMode, AppStrings strings) {
    final statsAsync = ref.watch(jobStatisticsProvider);

    return statsAsync.when(
      data: (stats) {
        return Column(
          children: [
            _buildSummaryRow(
              icon: PhosphorIcons.chatCentered(),
              title: 'Entrevistas este mês',
              value: stats['interviewsThisMonth']?.toString() ?? '0',
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              icon: PhosphorIcons.paperPlaneTilt(),
              title: 'Candidaturas este mês',
              value: stats['applicationsThisMonth']?.toString() ?? '0',
              isDarkMode: isDarkMode,
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Erro ao carregar resumo',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required PhosphorIconData icon,
    required String title,
    required String value,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(bool isDarkMode, AppStrings strings) {
    if (_currentIndex == 0) {
      // Dashboard - mostrar menu de opções
      return FloatingActionButton(
        onPressed: _showQuickActionMenu,
        backgroundColor: AppColors.primary,
        heroTag: "job_dashboard_fab",
        child: Icon(PhosphorIcons.plus(), color: Colors.white),
      );
    } else {
      // Outras abas - ação específica
      return FloatingActionButton(
        onPressed: () => _handleTabSpecificAction(_currentIndex),
        backgroundColor: AppColors.primary,
        heroTag: "job_tab_fab_$_currentIndex",
        child: Icon(PhosphorIcons.plus(), color: Colors.white),
      );
    }
  }

  void _showQuickActionMenu() {
    final strings = ref.read(appStringsProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(PhosphorIcons.chatCentered()),
              title: Text(strings.jobNewInterview),
              onTap: () {
                Navigator.pop(context);
                _handleTabSpecificAction(1);
              },
            ),
            ListTile(
              leading: Icon(PhosphorIcons.fileText()),
              title: Text(strings.jobNewCV),
              onTap: () {
                Navigator.pop(context);
                _handleTabSpecificAction(2);
              },
            ),
            ListTile(
              leading: Icon(PhosphorIcons.paperPlaneTilt()),
              title: Text(strings.jobNewApplication),
              onTap: () {
                Navigator.pop(context);
                _handleTabSpecificAction(3);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleTabSpecificAction(int tabIndex) {
    switch (tabIndex) {
      case 1: // Entrevistas
        _createNewInterview();
        break;
      case 2: // CVs
        _createNewCV();
        break;
      case 3: // Candidaturas
        _createNewApplication();
        break;
    }
  }

  void _createNewInterview() {
    context.push('/job-management/interview/new');
  }

  void _createNewCV() {
    context.push('/job-management/cv/new');
  }

  void _createNewApplication() {
    context.push('/job-management/application/new');
  }
}
