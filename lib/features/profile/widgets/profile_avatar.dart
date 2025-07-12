import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_profile.dart';
import '../../../shared/providers/user_profile_provider.dart';

/// Widget para exibir avatar do usuário
class ProfileAvatar extends ConsumerWidget {
  final UserProfile profile;
  final double size;
  final VoidCallback? onTap;
  final bool showEditButton;
  final bool showLoadingIndicator;

  const ProfileAvatar({
    super.key,
    required this.profile,
    this.size = 50,
    this.onTap,
    this.showEditButton = false,
    this.showLoadingIndicator = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUploadingAvatar = ref.watch(isUploadingAvatarProvider);
    final avatarFile = ref.watch(avatarFileProvider);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Avatar principal
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _buildAvatarWidget(context, ref),
            ),
          ),

          // Loading indicator
          if (isUploadingAvatar && showLoadingIndicator)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),

          // Botão de edição
          if (showEditButton && onTap != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: size * 0.15,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarWidget(BuildContext context, WidgetRef ref) {
    debugPrint('🔍 ProfileAvatar - Verificando avatar para: ${profile.name}');
    debugPrint('🔍 ProfileAvatar - avatarUrl: ${profile.avatarUrl}');
    debugPrint('🔍 ProfileAvatar - avatarPath: ${profile.avatarPath}');
    debugPrint(
        '🔍 ProfileAvatar - hasCustomAvatar: ${profile.hasCustomAvatar}');

    // Se tem URL, usar imagem da rede (útil para web e OAuth2)
    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      debugPrint('🔍 ProfileAvatar - Usando avatarUrl: ${profile.avatarUrl}');
      return Image.network(
        profile.avatarUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingAvatar(context);
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('⚠️ ProfileAvatar - Erro ao carregar avatarUrl: $error');
          return _buildFallbackAvatar(context);
        },
      );
    }

    // Se tem arquivo local (mobile), tentar carregar diretamente
    if (profile.avatarPath != null && !kIsWeb) {
      try {
        final file = File(profile.avatarPath!);
        debugPrint(
            '🔍 ProfileAvatar - Verificando arquivo local: ${file.path}');
        debugPrint('🔍 ProfileAvatar - Arquivo existe: ${file.existsSync()}');

        if (file.existsSync()) {
          debugPrint(
              '🔍 ProfileAvatar - Usando avatarPath: ${profile.avatarPath}');
          return Image.file(
            file,
            fit: BoxFit.cover,
            width: size,
            height: size,
            errorBuilder: (context, error, stackTrace) {
              debugPrint(
                  '⚠️ ProfileAvatar - Erro ao carregar avatarPath: $error');
              return _buildFallbackAvatar(context);
            },
          );
        } else {
          debugPrint('⚠️ ProfileAvatar - Arquivo não existe: ${file.path}');
        }
      } catch (e) {
        debugPrint('⚠️ Erro ao carregar avatar local: $e');
      }
    }

    // Fallback para iniciais
    debugPrint(
        '🔍 ProfileAvatar - Usando fallback com iniciais: ${profile.initials}');
    return _buildFallbackAvatar(context);
  }

  Widget _buildAvatarContent(BuildContext context, File? file) {
    if (file != null && file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) =>
            _buildFallbackAvatar(context),
      );
    }

    return _buildFallbackAvatar(context);
  }

  Widget _buildFallbackAvatar(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Center(
        child: Text(
          profile.initials,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingAvatar(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Widget compacto para avatar em listas
class ProfileAvatarCompact extends ConsumerWidget {
  final UserProfile profile;
  final double size;
  final VoidCallback? onTap;

  const ProfileAvatarCompact({
    super.key,
    required this.profile,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProfileAvatar(
      profile: profile,
      size: size,
      onTap: onTap,
      showEditButton: false,
      showLoadingIndicator: false,
    );
  }
}

/// Widget para avatar grande com opções de edição
class ProfileAvatarLarge extends ConsumerWidget {
  final UserProfile profile;
  final VoidCallback? onEditTap;
  final bool showEditButton;

  const ProfileAvatarLarge({
    super.key,
    required this.profile,
    this.onEditTap,
    this.showEditButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProfileAvatar(
      profile: profile,
      size: 120,
      onTap: onEditTap,
      showEditButton: showEditButton,
      showLoadingIndicator: true,
    );
  }
}

/// Widget para avatar em AppBar
class ProfileAvatarAppBar extends ConsumerWidget {
  final UserProfile profile;
  final VoidCallback? onTap;

  const ProfileAvatarAppBar({
    super.key,
    required this.profile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ProfileAvatar(
        profile: profile,
        size: 32,
        onTap: onTap,
        showEditButton: false,
        showLoadingIndicator: false,
      ),
    );
  }
}

/// Widget para placeholder quando não há perfil
class ProfileAvatarPlaceholder extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;

  const ProfileAvatarPlaceholder({
    super.key,
    this.size = 50,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surfaceVariant,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 2,
          ),
        ),
        child: Icon(
          Icons.person,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: size * 0.6,
        ),
      ),
    );
  }
}

/// Widget para avatar em drawer/sidebar
class ProfileAvatarDrawer extends ConsumerWidget {
  final UserProfile? profile;
  final VoidCallback? onTap;

  const ProfileAvatarDrawer({
    super.key,
    this.profile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (profile == null) {
      return ProfileAvatarPlaceholder(
        size: 64,
        onTap: onTap,
      );
    }

    return ProfileAvatar(
      profile: profile!,
      size: 64,
      onTap: onTap,
      showEditButton: false,
      showLoadingIndicator: false,
    );
  }
}

/// Extensão para facilitar o uso do ProfileAvatar
extension ProfileAvatarExtension on UserProfile {
  /// Criar avatar padrão
  Widget avatar({
    double size = 50,
    VoidCallback? onTap,
    bool showEditButton = false,
  }) {
    return Builder(
      builder: (context) => ProfileAvatar(
        profile: this,
        size: size,
        onTap: onTap,
        showEditButton: showEditButton,
      ),
    );
  }

  /// Criar avatar compacto
  Widget avatarCompact({
    double size = 40,
    VoidCallback? onTap,
  }) {
    return ProfileAvatarCompact(
      profile: this,
      size: size,
      onTap: onTap,
    );
  }

  /// Criar avatar grande
  Widget avatarLarge({
    VoidCallback? onEditTap,
    bool showEditButton = true,
  }) {
    return ProfileAvatarLarge(
      profile: this,
      onEditTap: onEditTap,
      showEditButton: showEditButton,
    );
  }
}
