import 'dart:convert';

/// Modelo que representa o perfil completo de um usuário
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? bio;
  final String? phone;
  final String? location;
  final String? avatarPath;
  final DateTime? birthDate;
  final String? website;
  final String? profession;
  final List<String> interests;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
    this.phone,
    this.location,
    this.avatarPath,
    this.birthDate,
    this.website,
    this.profession,
    this.interests = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = true,
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

  /// Criar uma cópia do perfil com campos modificados
  UserProfile copyWith({
    String? name,
    String? email,
    String? bio,
    String? phone,
    String? location,
    String? avatarPath,
    DateTime? birthDate,
    String? website,
    String? profession,
    List<String>? interests,
    DateTime? updatedAt,
    bool? isPublic,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      avatarPath: avatarPath ?? this.avatarPath,
      birthDate: birthDate ?? this.birthDate,
      website: website ?? this.website,
      profession: profession ?? this.profession,
      interests: interests ?? this.interests,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isPublic: isPublic ?? this.isPublic,
    );
  }

  /// Converter para Map para serialização JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'bio': bio,
      'phone': phone,
      'location': location,
      'avatarPath': avatarPath,
      'birthDate': birthDate?.toIso8601String(),
      'website': website,
      'profession': profession,
      'interests': interests,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPublic': isPublic,
    };
  }

  /// Criar instância a partir de Map JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      avatarPath: json['avatarPath'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      website: json['website'] as String?,
      profession: json['profession'] as String?,
      interests: List<String>.from(json['interests'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isPublic: json['isPublic'] as bool? ?? true,
    );
  }

  /// Converter para string JSON
  String toJsonString() => json.encode(toJson());

  /// Criar instância a partir de string JSON
  factory UserProfile.fromJsonString(String jsonString) {
    return UserProfile.fromJson(
        json.decode(jsonString) as Map<String, dynamic>);
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
        avatarPath != null;
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
  bool get hasCustomAvatar => avatarPath != null && avatarPath!.isNotEmpty;

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
