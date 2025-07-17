/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

/// Represents the result of an authentication operation.
class AuthResult {
  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final String? userEmail;
  final String? userName;
  final String? avatarUrl;
  final String? avatarPath;
  final Map<String, dynamic>? accountData;
  final String? error;

  /// Creates a successful authentication result.
  AuthResult.success({
    this.accessToken,
    this.refreshToken,
    required this.userEmail,
    this.userName,
    this.avatarUrl,
    this.avatarPath,
    this.accountData,
  })  : success = true,
        error = null;

  /// Creates a failed authentication result.
  AuthResult.error(this.error)
      : success = false,
        accessToken = null,
        refreshToken = null,
        userEmail = null,
        userName = null,
        avatarUrl = null,
        avatarPath = null,
        accountData = null;
}
