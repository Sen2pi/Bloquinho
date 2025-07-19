/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';

/// Modelo de Workspace
class Workspace {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color? color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDefault;
  final Map<String, dynamic> settings;

  const Workspace({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.color,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault = false,
    this.settings = const {},
  });

  Workspace copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDefault,
    Map<String, dynamic>? settings,
  }) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
      settings: settings ?? this.settings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon.codePoint,
      'color': color?.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDefault': isDefault,
      'settings': settings,
    };
  }

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: IconData(json['icon'] ?? Icons.work.codePoint,
          fontFamily: 'MaterialIcons'),
      color: json['color'] != null ? Color(json['color']) : null,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isDefault: json['isDefault'] ?? false,
      settings: json['settings'] ?? {},
    );
  }
}

/// Seção de um workspace
class WorkspaceSection {
  final String id;
  final String name;
  final IconData icon;
  final String? customIconPath; // Caminho para imagem customizada
  final String route;
  final int itemCount;
  final bool hasSubItems;
  final List<WorkspaceSection> subSections;

  const WorkspaceSection({
    required this.id,
    required this.name,
    required this.icon,
    this.customIconPath,
    required this.route,
    this.itemCount = 0,
    this.hasSubItems = false,
    this.subSections = const [],
  });

  WorkspaceSection copyWith({
    String? id,
    String? name,
    IconData? icon,
    String? customIconPath,
    String? route,
    int? itemCount,
    bool? hasSubItems,
    List<WorkspaceSection>? subSections,
  }) {
    return WorkspaceSection(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      customIconPath: customIconPath ?? this.customIconPath,
      route: route ?? this.route,
      itemCount: itemCount ?? this.itemCount,
      hasSubItems: hasSubItems ?? this.hasSubItems,
      subSections: subSections ?? this.subSections,
    );
  }

  /// Retorna true se deve usar ícone customizado
  bool get hasCustomIcon => customIconPath != null;
}

/// Seções padrão do workspace
class WorkspaceSections {
  static const List<WorkspaceSection> defaultSections = [
    WorkspaceSection(
      id: 'bloquinho',
      name: 'Bloquinho', // Não traduzível - marca
      icon: Icons.note_outlined,
      customIconPath: 'assets/images/notas.png',
      route: '/workspace/bloquinho',
      itemCount: 0,
      hasSubItems: true,
    ),
    WorkspaceSection(
      id: 'documents',
      name: 'Documentos',
      icon: Icons.description_outlined,
      route: '/workspace/documents',
      itemCount: 0,
      hasSubItems: true,
    ),
    WorkspaceSection(
      id: 'passwords',
      name: 'Senhas',
      icon: Icons.password_outlined,
      customIconPath: 'assets/images/senha.png',
      route: '/workspace/passwords',
      itemCount: 0,
      hasSubItems: false,
    ),
    WorkspaceSection(
      id: 'agenda',
      name: 'Agenda',
      icon: Icons.calendar_month_outlined,
      customIconPath: 'assets/images/agenda.png',
      route: '/workspace/agenda',
      itemCount: 0,
      hasSubItems: true,
    ),
    WorkspaceSection(
      id: 'database',
      name: 'Base de Dados',
      icon: Icons.storage_outlined,
      customIconPath: 'assets/images/dossier.png',
      route: '/workspace/database',
      itemCount: 0,
      hasSubItems: true,
    ),
    WorkspaceSection(
      id: 'job_management',
      name: 'Gestão de Trabalho',
      icon: Icons.work_outline,
      route: '/workspace/job-management',
      itemCount: 0,
      hasSubItems: true,
    ),
    WorkspaceSection(
      id: 'universidade',
      name: 'Universidade',
      icon: Icons.school,
      route: '/workspace/universidade',
      itemCount: 0,
      hasSubItems: true,
    ),
  ];

  static List<WorkspaceSection> getSectionsForWorkspace(String workspaceId) {
    return defaultSections
        .map((section) => section.copyWith(
              id: '${workspaceId}_${section.id}',
              route: '${section.route}?workspace=$workspaceId',
            ))
        .toList();
  }
}

/// Workspaces predefinidos
class DefaultWorkspaces {
  static final List<Workspace> workspaces = [
    Workspace(
      id: 'personal',
      name: 'Pessoal',
      description: 'Workspace pessoal para notas e documentos',
      icon: Icons.person_outline,
      color: Colors.blue,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDefault: true,
    ),
    Workspace(
      id: 'work',
      name: 'Trabalho',
      description: 'Workspace profissional para projetos',
      icon: Icons.business_outlined,
      color: Colors.orange,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Workspace(
      id: 'study',
      name: 'Estudos',
      description: 'Workspace para materiais de estudo',
      icon: Icons.school_outlined,
      color: Colors.green,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Workspace(
      id: 'escola',
      name: 'Escola',
      description: 'Workspace para gestão académica e universitária',
      icon: Icons.school,
      color: Colors.purple,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
}
