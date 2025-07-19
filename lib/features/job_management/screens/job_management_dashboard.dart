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
import 'package:fl_chart/fl_chart.dart';

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
import '../widgets/modern_quick_actions_widget.dart';
import '../widgets/job_chart_widget.dart';
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
            _buildModernDashboardTab(isDarkMode, strings),
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

  Widget _buildModernDashboardTab(bool isDarkMode, AppStrings strings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ações rápidas modernas
          ModernQuickActionsWidget(
            isDarkMode: isDarkMode,
            strings: strings,
            onNewInterview: () => _createNewInterview(),
            onNewCV: () => _createNewCV(),
            onNewApplication: () => _createNewApplication(),
            onImportData: () => _importData(),
          ),

          const SizedBox(height: 24),

          // Estatísticas principais
          _buildModernStatsSection(isDarkMode, strings),

          const SizedBox(height: 24),

          // Gráficos
          _buildChartsSection(isDarkMode, strings),

          const SizedBox(height: 24),

          // Entrevistas recentes
          _buildRecentInterviewsSection(isDarkMode, strings),

          const SizedBox(height: 24),

          // Resumo mensal moderno
          _buildModernMonthlySummarySection(isDarkMode, strings),
        ],
      ),
    );
  }

  Widget _buildModernStatsSection(bool isDarkMode, AppStrings strings) {
    final statsAsync = ref.watch(jobStatisticsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.chartBar(),
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                strings.statistics,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          statsAsync.when(
            data: (stats) => _buildModernStatsGrid(stats, isDarkMode, strings),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'Erro ao carregar estatísticas',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatsGrid(
      Map<String, dynamic> stats, bool isDarkMode, AppStrings strings) {
    return Row(
      children: [
        Expanded(
          child: _buildModernStatCard(
            title: 'Entrevistas',
            value: stats['totalInterviews']?.toString() ?? '0',
            icon: PhosphorIcons.chatCentered(),
            color: Colors.blue,
            isDarkMode: isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildModernStatCard(
            title: 'CVs',
            value: stats['totalCVs']?.toString() ?? '0',
            icon: PhosphorIcons.fileText(),
            color: Colors.green,
            isDarkMode: isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildModernStatCard(
            title: 'Candidaturas',
            value: stats['totalApplications']?.toString() ?? '0',
            icon: PhosphorIcons.paperPlaneTilt(),
            color: Colors.orange,
            isDarkMode: isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildModernStatCard(
            title: 'Este Mês',
            value: stats['interviewsThisMonth']?.toString() ?? '0',
            icon: PhosphorIcons.calendar(),
            color: Colors.purple,
            isDarkMode: isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildModernStatCard({
    required String title,
    required String value,
    required PhosphorIconData icon,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(bool isDarkMode, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              PhosphorIcons.chartLine(),
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Análise Gráfica',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInterviewsChart(isDarkMode),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildApplicationsChart(isDarkMode),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInterviewsPieChart(isDarkMode),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildApplicationsPieChart(isDarkMode),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInterviewsChart(bool isDarkMode) {
    final interviewsDataAsync = ref.watch(interviewsChartDataProvider);

    return interviewsDataAsync.when(
      data: (data) => JobChartWidget(
        title: 'Entrevistas (Últimos 7 dias)',
        data: data,
        lineColor: Colors.blue,
        fillColor: Colors.blue,
        isDarkMode: isDarkMode,
        subtitle: 'Tendência semanal',
      ),
      loading: () => Container(
        height: 120,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        height: 120,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            'Erro ao carregar dados',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationsChart(bool isDarkMode) {
    final applicationsDataAsync = ref.watch(applicationsChartDataProvider);

    return applicationsDataAsync.when(
      data: (data) => JobChartWidget(
        title: 'Candidaturas (Últimos 7 dias)',
        data: data,
        lineColor: Colors.orange,
        fillColor: Colors.orange,
        isDarkMode: isDarkMode,
        subtitle: 'Tendência semanal',
      ),
      loading: () => Container(
        height: 120,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        height: 120,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            'Erro ao carregar dados',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildInterviewsPieChart(bool isDarkMode) {
    final pieDataAsync = ref.watch(interviewsByTypePieDataProvider);

    return pieDataAsync.when(
      data: (sections) => JobPieChartWidget(
        title: 'Entrevistas por Tipo',
        sections: sections,
        isDarkMode: isDarkMode,
      ),
      loading: () => Container(
        height: 150,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        height: 150,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            'Erro ao carregar dados',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationsPieChart(bool isDarkMode) {
    final pieDataAsync = ref.watch(applicationsByStatusPieDataProvider);

    return pieDataAsync.when(
      data: (sections) => JobPieChartWidget(
        title: 'Candidaturas por Status',
        sections: sections,
        isDarkMode: isDarkMode,
      ),
      loading: () => Container(
        height: 150,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        height: 150,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            'Erro ao carregar dados',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentInterviewsSection(bool isDarkMode, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIcons.clock(),
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    strings.jobRecentInterviews,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
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
      ),
    );
  }

  Widget _buildModernMonthlySummarySection(
      bool isDarkMode, AppStrings strings) {
    final statsAsync = ref.watch(jobStatisticsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.calendar(),
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Resumo Mensal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          statsAsync.when(
            data: (stats) => Column(
              children: [
                _buildModernSummaryRow(
                  icon: PhosphorIcons.chatCentered(),
                  title: 'Entrevistas este mês',
                  value: stats['interviewsThisMonth']?.toString() ?? '0',
                  color: Colors.blue,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 12),
                _buildModernSummaryRow(
                  icon: PhosphorIcons.paperPlaneTilt(),
                  title: 'Candidaturas este mês',
                  value: stats['applicationsThisMonth']?.toString() ?? '0',
                  color: Colors.orange,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 12),
                _buildModernSummaryRow(
                  icon: PhosphorIcons.trendUp(),
                  title: 'Taxa de sucesso',
                  value: '75%',
                  color: Colors.green,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'Erro ao carregar resumo',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSummaryRow({
    required PhosphorIconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontSize: 14,
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
              fontSize: 16,
            ),
          ),
        ],
      ),
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

  void _importData() {
    // Implementar importação de dados
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de importação em desenvolvimento'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _refreshChartData() {
    // Invalidar todos os providers de gráficos para forçar reload
    ref.invalidate(interviewsChartDataProvider);
    ref.invalidate(applicationsChartDataProvider);
    ref.invalidate(interviewsByTypePieDataProvider);
    ref.invalidate(applicationsByStatusPieDataProvider);
    ref.invalidate(monthlyTrendDataProvider);
    ref.invalidate(jobStatisticsProvider);
  }
}
