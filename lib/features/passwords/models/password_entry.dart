import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'password_entry.g.dart';

class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();
  @override
  Color fromJson(int json) => Color(json);
  @override
  int toJson(Color color) => color.value;
}

@JsonSerializable()
class PasswordEntry extends Equatable {
  final String id;
  final String title;
  final String username;
  final String password;
  final String? website;
  final String? notes;
  final String? category;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastUsed;
  final bool isFavorite;
  final bool isArchived;
  final PasswordStrength strength;
  final String? iconUrl;
  final String? customIcon;
  final Map<String, dynamic> customFields;
  final List<String> attachments;
  final String? folderId;
  final bool isShared;
  final List<String> sharedWith;
  final DateTime? expiresAt;
  final bool autoFillEnabled;
  final String? workspaceId;

  const PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.website,
    this.notes,
    this.category,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.lastUsed,
    this.isFavorite = false,
    this.isArchived = false,
    this.strength = PasswordStrength.weak,
    this.iconUrl,
    this.customIcon,
    this.customFields = const {},
    this.attachments = const [],
    this.folderId,
    this.isShared = false,
    this.sharedWith = const [],
    this.expiresAt,
    this.autoFillEnabled = true,
    this.workspaceId,
  });

  factory PasswordEntry.fromJson(Map<String, dynamic> json) =>
      _$PasswordEntryFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordEntryToJson(this);

  PasswordEntry copyWith({
    String? id,
    String? title,
    String? username,
    String? password,
    String? website,
    String? notes,
    String? category,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastUsed,
    bool? isFavorite,
    bool? isArchived,
    PasswordStrength? strength,
    String? iconUrl,
    String? customIcon,
    Map<String, dynamic>? customFields,
    List<String>? attachments,
    String? folderId,
    bool? isShared,
    List<String>? sharedWith,
    DateTime? expiresAt,
    bool? autoFillEnabled,
    String? workspaceId,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastUsed: lastUsed ?? this.lastUsed,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      strength: strength ?? this.strength,
      iconUrl: iconUrl ?? this.iconUrl,
      customIcon: customIcon ?? this.customIcon,
      customFields: customFields ?? this.customFields,
      attachments: attachments ?? this.attachments,
      folderId: folderId ?? this.folderId,
      isShared: isShared ?? this.isShared,
      sharedWith: sharedWith ?? this.sharedWith,
      expiresAt: expiresAt ?? this.expiresAt,
      autoFillEnabled: autoFillEnabled ?? this.autoFillEnabled,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        username,
        password,
        website,
        notes,
        category,
        tags,
        createdAt,
        updatedAt,
        lastUsed,
        isFavorite,
        isArchived,
        strength,
        iconUrl,
        customIcon,
        customFields,
        attachments,
        folderId,
        isShared,
        sharedWith,
        expiresAt,
        autoFillEnabled,
        workspaceId,
      ];

  // Métodos de utilidade
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isExpiringSoon {
    if (expiresAt == null) return false;
    final daysUntilExpiry = expiresAt!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  String get displayTitle => title.isNotEmpty ? title : username;
  String get domain {
    if (website == null || website!.isEmpty) return '';
    try {
      final uri = Uri.parse(website!);
      return uri.host;
    } catch (e) {
      return website!;
    }
  }

  IconData get categoryIcon {
    switch (category?.toLowerCase()) {
      case 'social':
        return Icons.social_distance;
      case 'finance':
        return Icons.account_balance;
      case 'work':
        return Icons.work;
      case 'email':
        return Icons.email;
      case 'shopping':
        return Icons.shopping_cart;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.health_and_safety;
      case 'education':
        return Icons.school;
      default:
        return Icons.lock;
    }
  }

  Color get strengthColor {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return Colors.red;
      case PasswordStrength.weak:
        return Colors.orange;
      case PasswordStrength.medium:
        return Colors.yellow;
      case PasswordStrength.strong:
        return Colors.lightGreen;
      case PasswordStrength.veryStrong:
        return Colors.green;
    }
  }

  String get strengthText {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return 'Muito Fraca';
      case PasswordStrength.weak:
        return 'Fraca';
      case PasswordStrength.medium:
        return 'Média';
      case PasswordStrength.strong:
        return 'Forte';
      case PasswordStrength.veryStrong:
        return 'Muito Forte';
    }
  }
}

enum PasswordStrength {
  veryWeak,
  weak,
  medium,
  strong,
  veryStrong,
}

@JsonSerializable()
class PasswordFolder extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? parentId;
  final String? icon;
  @ColorConverter()
  final Color color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isShared;
  final List<String> sharedWith;
  final int entryCount;

  const PasswordFolder({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    this.icon,
    this.color = Colors.blue,
    required this.createdAt,
    required this.updatedAt,
    this.isShared = false,
    this.sharedWith = const [],
    this.entryCount = 0,
  });

  factory PasswordFolder.fromJson(Map<String, dynamic> json) =>
      _$PasswordFolderFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordFolderToJson(this);

  PasswordFolder copyWith({
    String? id,
    String? name,
    String? description,
    String? parentId,
    String? icon,
    Color? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isShared,
    List<String>? sharedWith,
    int? entryCount,
  }) {
    return PasswordFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isShared: isShared ?? this.isShared,
      sharedWith: sharedWith ?? this.sharedWith,
      entryCount: entryCount ?? this.entryCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        parentId,
        icon,
        color,
        createdAt,
        updatedAt,
        isShared,
        sharedWith,
        entryCount,
      ];
}
