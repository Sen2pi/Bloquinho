import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../models/user_profile.dart';

/// Exceções específicas do serviço de perfil
class UserProfileException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const UserProfileException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'UserProfileException: $message';
}

/// Serviço principal para gerenciamento de perfil de usuário
class UserProfileService {
  static const String _boxName = 'user_profile';
  static const String _profileKey = 'current_profile';
  static const String _avatarsFolder = 'avatars';

  Box<String>? _box;
  UserProfile? _cachedProfile;
  final ImagePicker _imagePicker = ImagePicker();

  /// Instância singleton
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  /// Inicializar o serviço
  Future<void> initialize() async {
    try {
      if (_box == null || !_box!.isOpen) {
        _box = await Hive.openBox<String>(_boxName);
      }

      // Carregar perfil em cache
      await _loadCachedProfile();
    } catch (e) {
      throw UserProfileException(
        'Erro ao inicializar serviço de perfil',
        originalError: e,
      );
    }
  }

  /// Obter perfil atual (do cache ou armazenamento)
  Future<UserProfile?> getCurrentProfile() async {
    await _ensureInitialized();

    if (_cachedProfile != null) {
      return _cachedProfile;
    }

    return await _loadProfileFromStorage();
  }

  /// Salvar ou atualizar perfil
  Future<UserProfile> saveProfile(UserProfile profile) async {
    await _ensureInitialized();

    try {
      // Validar antes de salvar
      final errors = ProfileValidator.validate(profile);
      if (errors.isNotEmpty) {
        throw UserProfileException(
          'Dados inválidos: ${errors.map((e) => e.message).join(', ')}',
          code: 'VALIDATION_ERROR',
        );
      }

      // Atualizar timestamp de modificação
      final updatedProfile = profile.copyWith(updatedAt: DateTime.now());

      // Salvar no armazenamento local
      await _box!.put(_profileKey, updatedProfile.toJsonString());

      // Atualizar cache
      _cachedProfile = updatedProfile;

      return updatedProfile;
    } catch (e) {
      if (e is UserProfileException) rethrow;
      throw UserProfileException(
        'Erro ao salvar perfil',
        originalError: e,
      );
    }
  }

  /// Criar novo perfil
  Future<UserProfile> createProfile({
    required String name,
    required String email,
  }) async {
    await _ensureInitialized();

    final profile = UserProfile.create(name: name, email: email);
    return await saveProfile(profile);
  }

  /// Criar perfil com avatar a partir do OAuth2
  Future<UserProfile> createProfileFromOAuth({
    required String name,
    required String email,
    String? avatarPath,
    String? avatarUrl,
  }) async {
    await _ensureInitialized();

    final profile = UserProfile.create(name: name, email: email);

    // Adicionar avatar se disponível
    if (avatarPath != null || avatarUrl != null) {
      final updatedProfile = profile.copyWith(
        avatarPath: avatarPath,
        avatarUrl: avatarUrl,
      );
      return await saveProfile(updatedProfile);
    }

    return await saveProfile(profile);
  }

  /// Atualizar campos específicos do perfil
  Future<UserProfile> updateProfile({
    String? name,
    String? email,
    String? bio,
    String? phone,
    String? location,
    DateTime? birthDate,
    String? website,
    String? profession,
    List<String>? interests,
    bool? isPublic,
  }) async {
    final currentProfile = await getCurrentProfile();
    if (currentProfile == null) {
      throw UserProfileException(
        'Nenhum perfil encontrado para atualizar',
        code: 'NO_PROFILE',
      );
    }

    final updatedProfile = currentProfile.copyWith(
      name: name,
      email: email,
      bio: bio,
      phone: phone,
      location: location,
      birthDate: birthDate,
      website: website,
      profession: profession,
      interests: interests,
      isPublic: isPublic,
    );

    return await saveProfile(updatedProfile);
  }

  /// Upload de avatar a partir da galeria
  Future<UserProfile> uploadAvatarFromGallery() async {
    // No web, não suporta upload de avatar ainda
    if (kIsWeb) {
      throw UserProfileException(
        'Upload de avatar não suportado na versão web',
        code: 'WEB_NOT_SUPPORTED',
      );
    }

    final currentProfile = await getCurrentProfile();
    if (currentProfile == null) {
      throw UserProfileException(
        'Nenhum perfil encontrado',
        code: 'NO_PROFILE',
      );
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image == null) return currentProfile;

      return await _processAndSaveAvatar(image, currentProfile);
    } catch (e) {
      throw UserProfileException(
        'Erro ao selecionar imagem da galeria',
        originalError: e,
      );
    }
  }

  /// Upload de avatar a partir da câmera
  Future<UserProfile> uploadAvatarFromCamera() async {
    // No web, não suporta upload de avatar ainda
    if (kIsWeb) {
      throw UserProfileException(
        'Upload de avatar não suportado na versão web',
        code: 'WEB_NOT_SUPPORTED',
      );
    }

    final currentProfile = await getCurrentProfile();
    if (currentProfile == null) {
      throw UserProfileException(
        'Nenhum perfil encontrado',
        code: 'NO_PROFILE',
      );
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image == null) return currentProfile;

      return await _processAndSaveAvatar(image, currentProfile);
    } catch (e) {
      throw UserProfileException(
        'Erro ao tirar foto',
        originalError: e,
      );
    }
  }

  /// Remover avatar atual
  Future<UserProfile> removeAvatar() async {
    final currentProfile = await getCurrentProfile();
    if (currentProfile == null) {
      throw UserProfileException(
        'Nenhum perfil encontrado',
        code: 'NO_PROFILE',
      );
    }

    try {
      // Deletar arquivo de avatar anterior se existir
      if (currentProfile.avatarPath != null) {
        await _deleteAvatarFile(currentProfile.avatarPath!);
      }

      // Atualizar perfil removendo avatar
      final updatedProfile = currentProfile.copyWith(avatarPath: '');
      return await saveProfile(updatedProfile);
    } catch (e) {
      throw UserProfileException(
        'Erro ao remover avatar',
        originalError: e,
      );
    }
  }

  /// Obter arquivo de avatar se existir
  Future<File?> getAvatarFile() async {
    // No web, avatares são tratados de forma diferente
    if (kIsWeb) {
      return null;
    }

    final profile = await getCurrentProfile();
    if (profile?.avatarPath == null) return null;

    try {
      final file = File(profile!.avatarPath!);
      return await file.exists() ? file : null;
    } catch (e) {
      debugPrint('⚠️ Erro ao verificar arquivo de avatar: $e');
      return null;
    }
  }

  /// Deletar perfil atual
  Future<void> deleteProfile() async {
    await _ensureInitialized();

    try {
      final currentProfile = await getCurrentProfile();

      // Deletar avatar se existir
      if (currentProfile?.avatarPath != null) {
        await _deleteAvatarFile(currentProfile!.avatarPath!);
      }

      // Remover do armazenamento
      await _box!.delete(_profileKey);

      // Limpar cache
      _cachedProfile = null;
    } catch (e) {
      throw UserProfileException(
        'Erro ao deletar perfil',
        originalError: e,
      );
    }
  }

  /// Verificar se existe perfil criado
  Future<bool> hasProfile() async {
    await _ensureInitialized();
    return _box!.containsKey(_profileKey);
  }

  /// Obter estatísticas do perfil
  Future<Map<String, dynamic>> getProfileStats() async {
    final profile = await getCurrentProfile();
    if (profile == null) return {};

    return {
      'isComplete': profile.isComplete,
      'hasAvatar': profile.hasCustomAvatar,
      'daysCreated': DateTime.now().difference(profile.createdAt).inDays,
      'lastUpdated': profile.updatedAt,
      'interestsCount': profile.interests.length,
      'age': profile.age,
    };
  }

  /// Exportar dados do perfil
  Future<Map<String, dynamic>> exportProfile() async {
    final profile = await getCurrentProfile();
    if (profile == null) {
      throw UserProfileException(
        'Nenhum perfil para exportar',
        code: 'NO_PROFILE',
      );
    }

    final stats = await getProfileStats();

    return {
      'profile': profile.toJson(),
      'stats': stats,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Limpar cache (força recarregamento)
  void clearCache() {
    _cachedProfile = null;
  }

  /// Processar e salvar imagem de avatar
  Future<UserProfile> _processAndSaveAvatar(
      XFile image, UserProfile profile) async {
    try {
      // Obter diretório para avatars
      final avatarsDir = await _getAvatarsDirectory();

      // Gerar nome único para o arquivo
      final fileName =
          'avatar_${profile.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final avatarPath = path.join(avatarsDir.path, fileName);

      // Deletar avatar anterior se existir
      if (profile.avatarPath != null) {
        await _deleteAvatarFile(profile.avatarPath!);
      }

      // Copiar nova imagem
      final imageFile = File(image.path);
      final savedFile = await imageFile.copy(avatarPath);

      // Atualizar perfil com novo avatar
      final updatedProfile = profile.copyWith(avatarPath: savedFile.path);
      return await saveProfile(updatedProfile);
    } catch (e) {
      throw UserProfileException(
        'Erro ao processar avatar',
        originalError: e,
      );
    }
  }

  /// Obter diretório para avatars
  Future<Directory> _getAvatarsDirectory() async {
    if (kIsWeb) {
      // No web, retornar diretório temporário (mas não é usado realmente)
      return Directory.systemTemp;
    }

    try {
      // Em plataformas nativas, usar diretório de documentos
      final appDir = await getApplicationDocumentsDirectory();
      final avatarsDir = Directory(path.join(appDir.path, _avatarsFolder));

      if (!await avatarsDir.exists()) {
        await avatarsDir.create(recursive: true);
      }

      return avatarsDir;
    } catch (e) {
      debugPrint('⚠️ Erro ao obter diretório de avatars: $e');
      throw UserProfileException(
        'Erro ao criar diretório de avatars',
        originalError: e,
      );
    }
  }

  /// Deletar arquivo de avatar
  Future<void> _deleteAvatarFile(String avatarPath) async {
    try {
      final file = File(avatarPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Log do erro mas não falha a operação
      debugPrint('Erro ao deletar avatar: $e');
    }
  }

  /// Carregar perfil do armazenamento
  Future<UserProfile?> _loadProfileFromStorage() async {
    try {
      final profileJson = _box!.get(_profileKey);
      if (profileJson == null) return null;

      final profile = UserProfile.fromJsonString(profileJson);
      _cachedProfile = profile;
      return profile;
    } catch (e) {
      debugPrint('Erro ao carregar perfil do armazenamento: $e');
      return null;
    }
  }

  /// Carregar perfil em cache
  Future<void> _loadCachedProfile() async {
    _cachedProfile = await _loadProfileFromStorage();
  }

  /// Garantir que o serviço está inicializado
  Future<void> _ensureInitialized() async {
    if (_box == null || !_box!.isOpen) {
      await initialize();
    }
  }

  /// Fechar serviço e limpar recursos
  Future<void> dispose() async {
    await _box?.close();
    _box = null;
    _cachedProfile = null;
  }
}
