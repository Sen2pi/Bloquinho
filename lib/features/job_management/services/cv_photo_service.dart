/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import '../../../core/services/workspace_storage_service.dart';

class CVPhotoService {
  static final CVPhotoService _instance = CVPhotoService._internal();
  factory CVPhotoService() => _instance;
  CVPhotoService._internal();

  final ImagePicker _picker = ImagePicker();
  final WorkspaceStorageService _workspaceStorage = WorkspaceStorageService();
  final String _cvPhotosDir = 'cv_photos';

  /// Configurar contexto (perfil + workspace)
  Future<void> setContext(String profileName, String workspaceId) async {
    await _workspaceStorage.setContext(profileName, workspaceId);
  }

  /// Obter diretório para fotos dos CVs no workspace atual
  Future<Directory> get _cvPhotosDirectory async {
    await _workspaceStorage.initialize();
    final workspacePath = await _workspaceStorage.getCurrentWorkspacePath();
    if (workspacePath == null) {
      throw Exception('Workspace path not found');
    }
    final cvPhotosDir = Directory(path.join(workspacePath, _cvPhotosDir));
    if (!await cvPhotosDir.exists()) {
      await cvPhotosDir.create(recursive: true);
    }
    return cvPhotosDir;
  }

  /// Verificar se já existe uma foto para o CV
  Future<bool> photoExists(String cvName) async {
    try {
      final dir = await _cvPhotosDirectory;
      final photoFile = File('${dir.path}/${_getPhotoFileName(cvName)}');
      return await photoFile.exists();
    } catch (e) {
      return false;
    }
  }

  /// Obter caminho da foto do CV
  Future<String?> getPhotoPath(String cvName) async {
    try {
      final dir = await _cvPhotosDirectory;
      final photoFile = File('${dir.path}/${_getPhotoFileName(cvName)}');
      if (await photoFile.exists()) {
        return photoFile.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fazer upload de foto da galeria
  Future<String?> uploadPhotoFromGallery(String cvName) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        return await _savePhoto(image, cvName);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fazer upload de foto da câmera
  Future<String?> uploadPhotoFromCamera(String cvName) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        return await _savePhoto(image, cvName);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Salvar foto
  Future<String?> _savePhoto(XFile image, String cvName) async {
    try {
      final dir = await _cvPhotosDirectory;
      final fileName = _getPhotoFileName(cvName);
      final photoFile = File('${dir.path}/$fileName');

      // Copiar arquivo para o diretório de fotos dos CVs
      await photoFile.writeAsBytes(await image.readAsBytes());

      return photoFile.path;
    } catch (e) {
      return null;
    }
  }

  /// Remover foto do CV
  Future<bool> removePhoto(String cvName) async {
    try {
      final photoPath = await getPhotoPath(cvName);
      if (photoPath != null) {
        final photoFile = File(photoPath);
        if (await photoFile.exists()) {
          await photoFile.delete();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Limpar fotos órfãs (CVs que não existem mais)
  Future<void> cleanupOrphanPhotos(List<String> existingCVNames) async {
    try {
      final dir = await _cvPhotosDirectory;
      final files = dir.listSync();
      
      for (final file in files) {
        if (file is File && file.path.endsWith('.jpg')) {
          final fileName = file.path.split('/').last;
          final cvName = _extractCVNameFromFileName(fileName);
          
          if (!existingCVNames.contains(cvName)) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      // Ignora erros de limpeza
    }
  }

  /// Gerar nome do arquivo de foto
  String _getPhotoFileName(String cvName) {
    // Remove caracteres especiais e espaços, mantém apenas letras, números e hífens
    final cleanName = cvName
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
    
    return '${cleanName}_${const Uuid().v4().substring(0, 8)}.jpg';
  }

  /// Extrair nome do CV do nome do arquivo
  String _extractCVNameFromFileName(String fileName) {
    // Remove a extensão e o UUID
    final nameWithoutExt = fileName.replaceAll('.jpg', '');
    final parts = nameWithoutExt.split('_');
    if (parts.length > 1) {
      parts.removeLast(); // Remove o UUID
      return parts.join('_').replaceAll('_', ' ');
    }
    return nameWithoutExt.replaceAll('_', ' ');
  }

  /// Obter arquivo de foto
  Future<File?> getPhotoFile(String cvName) async {
    try {
      final photoPath = await getPhotoPath(cvName);
      if (photoPath != null) {
        final file = File(photoPath);
        if (await file.exists()) {
          return file;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
} 