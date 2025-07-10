import 'dart:convert';
import 'package:bloquinho/core/models/storage_settings.dart';

/// Modelo que representa o perfil completo de um usuário
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? bio;
  final String? phone;
  final String? location;
  final DateTime? birthDate;
  final String? website;
  final String? profession;
  final List<String> interests;
  final String? avatarPath; // Para arquivos locais (mobile)
  final String? avatarUrl; // Para URLs (web/OAuth2)
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final StorageSettings? storageSettings;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
    this.phone,
    this.location,
    this.birthDate,
    this.website,
    this.profession,
    this.interests = const [],
    this.avatarPath,
    this.avatarUrl,
    this.isPublic = true,
    required this.createdAt,
    required this.updatedAt,
    this.storageSettings,
  });

  /// Criar um novo perfil com valores padrão
  factory UserProfile.create({
    required String name,
    required String email,
    String? id,
  }) {
    final now = DateTime.now();
    return UserProfile(
      id: id ?? _generateId(),
      name: name,
      email: email,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Copiar com novos valores
  UserProfile copyWith({
    String? name,
    String? email,
    String? bio,
    String? phone,
    String? location,
    DateTime? birthDate,
    String? website,
    String? profession,
    List<String>? interests,
    String? avatarPath,
    String? avatarUrl,
    bool? isPublic,
    DateTime? updatedAt,
    StorageSettings? storageSettings,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      birthDate: birthDate ?? this.birthDate,
      website: website ?? this.website,
      profession: profession ?? this.profession,
      interests: interests ?? this.interests,
      avatarPath: avatarPath ?? this.avatarPath,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      storageSettings: storageSettings ?? this.storageSettings,
    );
  }

  /// Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'bio': bio,
      'phone': phone,
      'location': location,
      'birthDate': birthDate?.toIso8601String(),
      'website': website,
      'profession': profession,
      'interests': interests,
      'avatarPath': avatarPath,
      'avatarUrl': avatarUrl,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'storageSettings': storageSettings?.toJson(),
    };
  }

  /// Criar a partir de JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      website: json['website'] as String?,
      profession: json['profession'] as String?,
      interests: List<String>.from(json['interests'] ?? []),
      avatarPath: json['avatarPath'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      storageSettings: json['storageSettings'] != null
          ? StorageSettings.fromJson(
              Map<String, dynamic>.from(json['storageSettings']))
          : null,
    );
  }

  /// Converter para string JSON
  String toJsonString() => json.encode(toJson());

  /// Criar instância a partir de string JSON
  factory UserProfile.fromJsonString(String jsonString) {
    return UserProfile.fromJson(
        Map<String, dynamic>.from(json.decode(jsonString)));
  }

  /// Validar se o perfil tem dados obrigatórios válidos
  bool get isValid {
    return name.trim().isNotEmpty &&
        email.trim().isNotEmpty &&
        _isValidEmail(email);
  }

  /// Verificar se o perfil está completo (tem informações principais)
  bool get isComplete {
    return isValid &&
        bio != null &&
        bio!.trim().isNotEmpty &&
        (avatarPath != null || avatarUrl != null);
  }

  /// Obter iniciais do nome para avatar placeholder
  String get initials {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  /// Obter idade se data de nascimento estiver definida
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// Verificar se tem avatar personalizado
  bool get hasCustomAvatar => avatarPath != null || avatarUrl != null;

  /// Verificar se tem configurações de armazenamento
  bool get hasStorageSettings => storageSettings != null;

  /// Verificar se está usando armazenamento local
  bool get isUsingLocalStorage =>
      storageSettings?.provider == CloudStorageProvider.local;

  /// Verificar se está usando armazenamento em nuvem
  bool get isUsingCloudStorage => storageSettings?.isCloudStorage == true;

  /// Verificar se está conectado ao armazenamento em nuvem
  bool get isConnectedToCloud => storageSettings?.isConnected == true;

  /// Obter nome do provider de armazenamento
  String get storageProviderName =>
      storageSettings?.provider.displayName ?? 'Não configurado';

  /// Obter status do armazenamento
  CloudStorageStatus get storageStatus =>
      storageSettings?.status ?? CloudStorageStatus.disconnected;

  /// Obter configurações de armazenamento ou criar padrão local
  StorageSettings get effectiveStorageSettings =>
      storageSettings ?? StorageSettings.local();

  /// Atualizar configurações de armazenamento
  UserProfile updateStorageSettings(StorageSettings newSettings) {
    return copyWith(storageSettings: newSettings);
  }

  /// Remover configurações de armazenamento (voltar ao local)
  UserProfile removeStorageSettings() {
    return copyWith(storageSettings: StorageSettings.local());
  }

  /// Verificar se deve mostrar aviso de armazenamento local
  bool get shouldShowLocalStorageWarning => isUsingLocalStorage;

  /// Obter aviso de armazenamento local
  String? get localStorageWarning {
    if (isUsingLocalStorage) {
      return '⚠️ Armazenamento Local: Os dados ficam apenas neste dispositivo. '
          'Para sincronizar entre dispositivos, configure um armazenamento em nuvem.';
    }
    return null;
  }

  /// Verificar se pode fazer sincronização automática
  bool get canAutoSync => storageSettings?.canAutoBackup == true;

  /// Verificar se precisa sincronizar
  bool get needsSync => storageSettings?.needsSync == true;

  /// Obter tempo desde última sincronização
  Duration? get timeSinceLastSync => storageSettings?.timeSinceLastSync;

  /// Obter texto de status de sincronização
  String get syncStatusText {
    if (isUsingLocalStorage) {
      return 'Armazenamento local - Sincronização não aplicável';
    }

    if (!isConnectedToCloud) {
      return 'Desconectado - Conecte-se para sincronizar';
    }

    if (storageSettings?.isSyncing == true) {
      return 'Sincronizando...';
    }

    final timeSinceSync = timeSinceLastSync;
    if (timeSinceSync == null) {
      return 'Nunca sincronizado';
    }

    if (timeSinceSync.inMinutes < 1) {
      return 'Sincronizado agora';
    } else if (timeSinceSync.inMinutes < 60) {
      return 'Sincronizado há ${timeSinceSync.inMinutes} minutos';
    } else if (timeSinceSync.inHours < 24) {
      return 'Sincronizado há ${timeSinceSync.inHours} horas';
    } else {
      return 'Sincronizado há ${timeSinceSync.inDays} dias';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email)';
  }

  /// Gerar ID único para o perfil
  static String _generateId() {
    return 'profile_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Validar formato de email
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

/// Enum para tipos de validação de perfil
enum ProfileValidationError {
  emptyName,
  emptyEmail,
  invalidEmail,
  nameTooShort,
  bioTooLong,
  invalidPhone,
  invalidWebsite,
}

/// Extensão para obter mensagens de erro de validação
extension ProfileValidationErrorMessage on ProfileValidationError {
  String get message {
    switch (this) {
      case ProfileValidationError.emptyName:
        return 'Nome é obrigatório';
      case ProfileValidationError.emptyEmail:
        return 'Email é obrigatório';
      case ProfileValidationError.invalidEmail:
        return 'Email inválido';
      case ProfileValidationError.nameTooShort:
        return 'Nome deve ter pelo menos 2 caracteres';
      case ProfileValidationError.bioTooLong:
        return 'Bio deve ter no máximo 500 caracteres';
      case ProfileValidationError.invalidPhone:
        return 'Telefone inválido';
      case ProfileValidationError.invalidWebsite:
        return 'Website inválido';
    }
  }
}

/// Validador de perfil
class ProfileValidator {
  /// Validar perfil completo
  static List<ProfileValidationError> validate(UserProfile profile) {
    final errors = <ProfileValidationError>[];

    // Validar nome
    if (profile.name.trim().isEmpty) {
      errors.add(ProfileValidationError.emptyName);
    } else if (profile.name.trim().length < 2) {
      errors.add(ProfileValidationError.nameTooShort);
    }

    // Validar email
    if (profile.email.trim().isEmpty) {
      errors.add(ProfileValidationError.emptyEmail);
    } else if (!UserProfile._isValidEmail(profile.email)) {
      errors.add(ProfileValidationError.invalidEmail);
    }

    // Validar bio
    if (profile.bio != null && profile.bio!.length > 500) {
      errors.add(ProfileValidationError.bioTooLong);
    }

    // Validar telefone
    if (profile.phone != null && profile.phone!.isNotEmpty) {
      if (!_isValidPhone(profile.phone!)) {
        errors.add(ProfileValidationError.invalidPhone);
      }
    }

    // Validar website
    if (profile.website != null && profile.website!.isNotEmpty) {
      if (!_isValidWebsite(profile.website!)) {
        errors.add(ProfileValidationError.invalidWebsite);
      }
    }

    return errors;
  }

  /// Validar formato de telefone
  static bool _isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length >= 10 && cleaned.length <= 15;
  }

  /// Validar formato de website
  static bool _isValidWebsite(String website) {
    return RegExp(
            r'^https?:\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$')
        .hasMatch(website);
  }
}
