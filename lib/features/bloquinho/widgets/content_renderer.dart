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
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:bloquinho/core/models/database_models.dart';
import 'package:bloquinho/core/services/database_service.dart';
import '../models/page_model.dart';
import '../providers/pages_provider.dart';
import '../../../shared/providers/workspace_provider.dart';
import '../../../shared/providers/user_profile_provider.dart';
import '../../../core/theme/app_colors.dart';
import 'page_mention_picker.dart';
import 'database_table_picker.dart';
import 'calendar_event_picker.dart';

class ContentRenderer {
  static Widget renderContent(String content, BuildContext context, WidgetRef ref) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      widgets.addAll(_renderLine(line, context, ref));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  static List<Widget> _renderLine(String line, BuildContext context, WidgetRef ref) {
    final widgets = <Widget>[];
    
    // Page mentions: [[Page Name]]
    final pageMentionRegex = RegExp(r'\[\[([^\]]+)\]\]');
    // Table mentions: {{tabela:TableName}}
    final tableMentionRegex = RegExp(r'\{\{tabela:([^}]+)\}\}');
    // Event mentions: {{evento:EventName}}
    final eventMentionRegex = RegExp(r'\{\{evento:([^}]+)\}\}');

    String processedLine = line;
    final spans = <InlineSpan>[];
    int lastIndex = 0;

    // Process page mentions
    for (final match in pageMentionRegex.allMatches(line)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: line.substring(lastIndex, match.start)));
      }
      
      final pageName = match.group(1)!;
      spans.add(WidgetSpan(
        child: PageMentionBadge(
          page: PageModel.create(title: pageName),
          onTap: () => _navigateToPage(context, ref, pageName),
        ),
      ));
      
      lastIndex = match.end;
    }

    // Process table mentions
    for (final match in tableMentionRegex.allMatches(line)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: line.substring(lastIndex, match.start)));
      }
      
      final tableName = match.group(1)!;
      spans.add(WidgetSpan(
        child: _TableMentionBadge(
          tableName: tableName,
          onTap: () => _navigateToTable(context, tableName),
        ),
      ));
      
      lastIndex = match.end;
    }

    // Process event mentions
    for (final match in eventMentionRegex.allMatches(line)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: line.substring(lastIndex, match.start)));
      }
      
      final eventName = match.group(1)!;
      spans.add(WidgetSpan(
        child: _EventMentionBadge(
          eventName: eventName,
          onTap: () => _navigateToEvent(context, eventName),
        ),
      ));
      
      lastIndex = match.end;
    }

    if (lastIndex < line.length) {
      spans.add(TextSpan(text: line.substring(lastIndex)));
    }

    if (spans.isNotEmpty) {
      widgets.add(RichText(text: TextSpan(children: spans)));
    } else {
      widgets.add(Text(line));
    }

    return widgets;
  }

  static void _navigateToPage(BuildContext context, WidgetRef ref, String pageName) {
    final currentProfile = ref.read(currentProfileProvider);
    final currentWorkspace = ref.read(currentWorkspaceProvider);

    if (currentProfile != null && currentWorkspace != null) {
      final pages = ref.read(pagesProvider((
        profileName: currentProfile.name,
        workspaceName: currentWorkspace.name
      )));
      
      final page = pages.firstWhere(
        (p) => p.title == pageName,
        orElse: () => PageModel.create(title: 'Página não encontrada'),
      );
      
      if (page.title != 'Página não encontrada') {
        context.go('/workspace/bloquinho/page/${page.id}');
      }
    }
  }

  static void _navigateToTable(BuildContext context, String tableName) {
    context.go('/workspace/database');
  }

  static void _navigateToEvent(BuildContext context, String eventName) {
    // TODO: Navigate to calendar with specific event
    context.go('/workspace/calendar');
  }
}

class _TableMentionBadge extends StatelessWidget {
  final String tableName;
  final VoidCallback? onTap;

  const _TableMentionBadge({
    required this.tableName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.amber.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIcons.table(),
                size: 14,
                color: Colors.amber[700],
              ),
              const SizedBox(width: 4),
              Text(
                tableName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventMentionBadge extends StatelessWidget {
  final String eventName;
  final VoidCallback? onTap;

  const _EventMentionBadge({
    required this.eventName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIcons.calendar(),
                size: 14,
                color: Colors.green[700],
              ),
              const SizedBox(width: 4),
              Text(
                eventName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}