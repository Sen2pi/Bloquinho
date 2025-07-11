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
    };

const _$PasswordStrengthEnumMap = {
  PasswordStrength.veryWeak: 'veryWeak',
  PasswordStrength.weak: 'weak',
  PasswordStrength.medium: 'medium',
  PasswordStrength.strong: 'strong',
  PasswordStrength.veryStrong: 'veryStrong',
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
