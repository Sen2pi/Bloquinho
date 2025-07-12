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

  // NOVOS CAMPOS PARA FUNCIONALIDADES AVANÇADAS
  final List<PasswordHistory> passwordHistory;
  final String? masterPassword;
  final bool isBreached;
  final DateTime? breachDate;
  final List<String> breachSources;
  final bool isReused;
  final List<String> reusedIn;
  final String? securityNotes;
  final bool isPinned;
  final int usageCount;
  final DateTime? lastPasswordChange;
  final String? twoFactorSecret;
  final bool twoFactorEnabled;
  final String? recoveryEmail;
  final String? recoveryPhone;
  final Map<String, String> securityQuestions;
  final bool isEmergencyAccess;
  final String? emergencyContact;
  final DateTime? emergencyExpiry;
  final String? vaultId;
  final bool isInVault;
  final String? vaultName;
  final Map<String, dynamic> metadata;

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
    this.passwordHistory = const [],
    this.masterPassword,
    this.isBreached = false,
    this.breachDate,
    this.breachSources = const [],
    this.isReused = false,
    this.reusedIn = const [],
    this.securityNotes,
    this.isPinned = false,
    this.usageCount = 0,
    this.lastPasswordChange,
    this.twoFactorSecret,
    this.twoFactorEnabled = false,
    this.recoveryEmail,
    this.recoveryPhone,
    this.securityQuestions = const {},
    this.isEmergencyAccess = false,
    this.emergencyContact,
    this.emergencyExpiry,
    this.vaultId,
    this.isInVault = false,
    this.vaultName,
    this.metadata = const {},
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
    List<PasswordHistory>? passwordHistory,
    String? masterPassword,
    bool? isBreached,
    DateTime? breachDate,
    List<String>? breachSources,
    bool? isReused,
    List<String>? reusedIn,
    String? securityNotes,
    bool? isPinned,
    int? usageCount,
    DateTime? lastPasswordChange,
    String? twoFactorSecret,
    bool? twoFactorEnabled,
    String? recoveryEmail,
    String? recoveryPhone,
    Map<String, String>? securityQuestions,
    bool? isEmergencyAccess,
    String? emergencyContact,
    DateTime? emergencyExpiry,
    String? vaultId,
    bool? isInVault,
    String? vaultName,
    Map<String, dynamic>? metadata,
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
      passwordHistory: passwordHistory ?? this.passwordHistory,
      masterPassword: masterPassword ?? this.masterPassword,
      isBreached: isBreached ?? this.isBreached,
      breachDate: breachDate ?? this.breachDate,
      breachSources: breachSources ?? this.breachSources,
      isReused: isReused ?? this.isReused,
      reusedIn: reusedIn ?? this.reusedIn,
      securityNotes: securityNotes ?? this.securityNotes,
      isPinned: isPinned ?? this.isPinned,
      usageCount: usageCount ?? this.usageCount,
      lastPasswordChange: lastPasswordChange ?? this.lastPasswordChange,
      twoFactorSecret: twoFactorSecret ?? this.twoFactorSecret,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      recoveryEmail: recoveryEmail ?? this.recoveryEmail,
      recoveryPhone: recoveryPhone ?? this.recoveryPhone,
      securityQuestions: securityQuestions ?? this.securityQuestions,
      isEmergencyAccess: isEmergencyAccess ?? this.isEmergencyAccess,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyExpiry: emergencyExpiry ?? this.emergencyExpiry,
      vaultId: vaultId ?? this.vaultId,
      isInVault: isInVault ?? this.isInVault,
      vaultName: vaultName ?? this.vaultName,
      metadata: metadata ?? this.metadata,
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
        passwordHistory,
        masterPassword,
        isBreached,
        breachDate,
        breachSources,
        isReused,
        reusedIn,
        securityNotes,
        isPinned,
        usageCount,
        lastPasswordChange,
        twoFactorSecret,
        twoFactorEnabled,
        recoveryEmail,
        recoveryPhone,
        securityQuestions,
        isEmergencyAccess,
        emergencyContact,
        emergencyExpiry,
        vaultId,
        isInVault,
        vaultName,
        metadata,
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

  // NOVOS MÉTODOS PARA FUNCIONALIDADES AVANÇADAS

  /// Verificar se a senha foi comprometida
  bool get isCompromised => isBreached || isReused;

  /// Obter a senha mais recente do histórico
  String? get previousPassword {
    if (passwordHistory.isEmpty) return null;
    return passwordHistory.first.password;
  }

  /// Verificar se tem 2FA ativo
  bool get hasTwoFactor => twoFactorEnabled && twoFactorSecret != null;

  /// Verificar se tem acesso de emergência
  bool get hasEmergencyAccess => isEmergencyAccess && emergencyContact != null;

  /// Verificar se está em um vault
  bool get isInSecureVault => isInVault && vaultId != null;

  /// Obter idade da senha em dias
  int get passwordAge {
    final changeDate = lastPasswordChange ?? createdAt;
    return DateTime.now().difference(changeDate).inDays;
  }

  /// Verificar se a senha é antiga (mais de 90 dias)
  bool get isOldPassword => passwordAge > 90;

  /// Obter nível de segurança geral
  SecurityLevel get securityLevel {
    if (isCompromised) return SecurityLevel.critical;
    if (isOldPassword) return SecurityLevel.warning;
    if (strength == PasswordStrength.veryWeak ||
        strength == PasswordStrength.weak) {
      return SecurityLevel.warning;
    }
    if (hasTwoFactor) return SecurityLevel.excellent;
    return SecurityLevel.good;
  }

  /// Obter cor baseada no nível de segurança
  Color get securityColor {
    switch (securityLevel) {
      case SecurityLevel.critical:
        return Colors.red;
      case SecurityLevel.warning:
        return Colors.orange;
      case SecurityLevel.good:
        return Colors.green;
      case SecurityLevel.excellent:
        return Colors.blue;
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

enum SecurityLevel {
  critical,
  warning,
  good,
  excellent,
}

@JsonSerializable()
class PasswordHistory extends Equatable {
  final String password;
  final DateTime changedAt;
  final String? reason;

  const PasswordHistory({
    required this.password,
    required this.changedAt,
    this.reason,
  });

  factory PasswordHistory.fromJson(Map<String, dynamic> json) =>
      _$PasswordHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordHistoryToJson(this);

  @override
  List<Object?> get props => [password, changedAt, reason];
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
