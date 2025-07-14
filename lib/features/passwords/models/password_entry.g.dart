/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordEntry _$PasswordEntryFromJson(Map<String, dynamic> json) =>
    PasswordEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      website: json['website'] as String?,
      notes: json['notes'] as String?,
      category: json['category'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastUsed: json['lastUsed'] == null
          ? null
          : DateTime.parse(json['lastUsed'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      strength:
          $enumDecodeNullable(_$PasswordStrengthEnumMap, json['strength']) ??
              PasswordStrength.weak,
      iconUrl: json['iconUrl'] as String?,
      customIcon: json['customIcon'] as String?,
      customFields: json['customFields'] as Map<String, dynamic>? ?? const {},
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      folderId: json['folderId'] as String?,
      isShared: json['isShared'] as bool? ?? false,
      sharedWith: (json['sharedWith'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      autoFillEnabled: json['autoFillEnabled'] as bool? ?? true,
      workspaceId: json['workspaceId'] as String?,
      passwordHistory: (json['passwordHistory'] as List<dynamic>?)
              ?.map((e) => PasswordHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      masterPassword: json['masterPassword'] as String?,
      isBreached: json['isBreached'] as bool? ?? false,
      breachDate: json['breachDate'] == null
          ? null
          : DateTime.parse(json['breachDate'] as String),
      breachSources: (json['breachSources'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isReused: json['isReused'] as bool? ?? false,
      reusedIn: (json['reusedIn'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      securityNotes: json['securityNotes'] as String?,
      isPinned: json['isPinned'] as bool? ?? false,
      usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
      lastPasswordChange: json['lastPasswordChange'] == null
          ? null
          : DateTime.parse(json['lastPasswordChange'] as String),
      twoFactorSecret: json['twoFactorSecret'] as String?,
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      recoveryEmail: json['recoveryEmail'] as String?,
      recoveryPhone: json['recoveryPhone'] as String?,
      securityQuestions:
          (json['securityQuestions'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as String),
              ) ??
              const {},
      isEmergencyAccess: json['isEmergencyAccess'] as bool? ?? false,
      emergencyContact: json['emergencyContact'] as String?,
      emergencyExpiry: json['emergencyExpiry'] == null
          ? null
          : DateTime.parse(json['emergencyExpiry'] as String),
      vaultId: json['vaultId'] as String?,
      isInVault: json['isInVault'] as bool? ?? false,
      vaultName: json['vaultName'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$PasswordEntryToJson(PasswordEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'username': instance.username,
      'password': instance.password,
      'website': instance.website,
      'notes': instance.notes,
      'category': instance.category,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'lastUsed': instance.lastUsed?.toIso8601String(),
      'isFavorite': instance.isFavorite,
      'isArchived': instance.isArchived,
      'strength': _$PasswordStrengthEnumMap[instance.strength]!,
      'iconUrl': instance.iconUrl,
      'customIcon': instance.customIcon,
      'customFields': instance.customFields,
      'attachments': instance.attachments,
      'folderId': instance.folderId,
      'isShared': instance.isShared,
      'sharedWith': instance.sharedWith,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'autoFillEnabled': instance.autoFillEnabled,
      'workspaceId': instance.workspaceId,
      'passwordHistory': instance.passwordHistory,
      'masterPassword': instance.masterPassword,
      'isBreached': instance.isBreached,
      'breachDate': instance.breachDate?.toIso8601String(),
      'breachSources': instance.breachSources,
      'isReused': instance.isReused,
      'reusedIn': instance.reusedIn,
      'securityNotes': instance.securityNotes,
      'isPinned': instance.isPinned,
      'usageCount': instance.usageCount,
      'lastPasswordChange': instance.lastPasswordChange?.toIso8601String(),
      'twoFactorSecret': instance.twoFactorSecret,
      'twoFactorEnabled': instance.twoFactorEnabled,
      'recoveryEmail': instance.recoveryEmail,
      'recoveryPhone': instance.recoveryPhone,
      'securityQuestions': instance.securityQuestions,
      'isEmergencyAccess': instance.isEmergencyAccess,
      'emergencyContact': instance.emergencyContact,
      'emergencyExpiry': instance.emergencyExpiry?.toIso8601String(),
      'vaultId': instance.vaultId,
      'isInVault': instance.isInVault,
      'vaultName': instance.vaultName,
      'metadata': instance.metadata,
    };

const _$PasswordStrengthEnumMap = {
  PasswordStrength.veryWeak: 'veryWeak',
  PasswordStrength.weak: 'weak',
  PasswordStrength.medium: 'medium',
  PasswordStrength.strong: 'strong',
  PasswordStrength.veryStrong: 'veryStrong',
};

PasswordHistory _$PasswordHistoryFromJson(Map<String, dynamic> json) =>
    PasswordHistory(
      password: json['password'] as String,
      changedAt: DateTime.parse(json['changedAt'] as String),
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$PasswordHistoryToJson(PasswordHistory instance) =>
    <String, dynamic>{
      'password': instance.password,
      'changedAt': instance.changedAt.toIso8601String(),
      'reason': instance.reason,
    };

PasswordFolder _$PasswordFolderFromJson(Map<String, dynamic> json) =>
    PasswordFolder(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      parentId: json['parentId'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] == null
          ? Colors.blue
          : const ColorConverter().fromJson((json['color'] as num).toInt()),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isShared: json['isShared'] as bool? ?? false,
      sharedWith: (json['sharedWith'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      entryCount: (json['entryCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PasswordFolderToJson(PasswordFolder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'parentId': instance.parentId,
      'icon': instance.icon,
      'color': const ColorConverter().toJson(instance.color),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isShared': instance.isShared,
      'sharedWith': instance.sharedWith,
      'entryCount': instance.entryCount,
    };
