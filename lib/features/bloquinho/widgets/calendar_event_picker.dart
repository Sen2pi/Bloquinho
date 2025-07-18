/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';

// Temporary model for calendar events - replace with your actual event model
class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final Color color;
  final IconData icon;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.color,
    required this.icon,
  });
}

class CalendarEventPicker extends StatefulWidget {
  final String? searchQuery;
  final Function(CalendarEvent) onEventSelected;
  final VoidCallback onDismiss;

  const CalendarEventPicker({
    super.key,
    this.searchQuery,
    required this.onEventSelected,
    required this.onDismiss,
  });

  @override
  State<CalendarEventPicker> createState() => _CalendarEventPickerState();
}

class _CalendarEventPickerState extends State<CalendarEventPicker> {
  final TextEditingController _searchController = TextEditingController();
  List<CalendarEvent> _filteredEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery ?? '';
    _loadEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Replace with actual calendar service
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Dummy data - replace with actual calendar events
      final dummyEvents = [
        CalendarEvent(
          id: '1',
          title: 'Reunião com Cliente',
          description: 'Discussão sobre o projeto',
          startDate: DateTime.now().add(const Duration(days: 1)),
          color: Colors.blue,
          icon: PhosphorIcons.users(),
        ),
        CalendarEvent(
          id: '2',
          title: 'Workshop de Flutter',
          description: 'Aprender novos conceitos',
          startDate: DateTime.now().add(const Duration(days: 2)),
          color: Colors.green,
          icon: PhosphorIcons.graduation(),
        ),
        CalendarEvent(
          id: '3',
          title: 'Entrega do Projeto',
          description: 'Prazo final para entrega',
          startDate: DateTime.now().add(const Duration(days: 5)),
          color: Colors.red,
          icon: PhosphorIcons.package(),
        ),
      ];
      
      _filterEvents(dummyEvents);
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterEvents(List<CalendarEvent> allEvents) {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredEvents = allEvents.take(10).toList();
      });
    } else {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredEvents = allEvents.where((event) {
          return event.title.toLowerCase().contains(query) ||
              event.description.toLowerCase().contains(query);
        }).take(10).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      child: Container(
        width: 320,
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(isDarkMode),
            
            // Search bar
            _buildSearchBar(isDarkMode),
            
            // Content
            Expanded(
              child: _buildContent(isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkSurface.withOpacity(0.8)
            : AppColors.lightSurface.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.calendar(),
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Inserir Evento',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onDismiss,
            icon: Icon(
              PhosphorIcons.x(),
              size: 18,
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Pesquisar eventos...',
          prefixIcon: Icon(
            PhosphorIcons.magnifyingGlass(),
            color: isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          filled: true,
          fillColor:
              isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        style: TextStyle(
          color: isDarkMode
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
        onChanged: (value) => _filterEvents(_filteredEvents),
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_filteredEvents.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        return _buildEventTile(event, isDarkMode);
      },
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.calendar(),
              size: 48,
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum evento encontrado',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente uma busca diferente',
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
    );
  }

  Widget _buildEventTile(CalendarEvent event, bool isDarkMode) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.onEventSelected(event);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: event.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  event.icon,
                  size: 16,
                  color: event.color,
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    if (event.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDate(event.startDate),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDarkMode
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  Text(
                    _formatTime(event.startDate),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDarkMode
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),

              // Arrow
              Icon(
                PhosphorIcons.caretRight(),
                size: 16,
                color: isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class CalendarEventBadge extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback? onTap;

  const CalendarEventBadge({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: event.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: event.color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                event.icon,
                size: 14,
                color: event.color,
              ),
              const SizedBox(width: 4),
              Text(
                event.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: event.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}