import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/user_profile_provider.dart';
import '../../../core/models/user_profile.dart';
import '../widgets/profile_avatar.dart';

/// Tela de edição/criação de perfil
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _professionController = TextEditingController();
  final _interestController = TextEditingController();

  DateTime? _selectedBirthDate;
  List<String> _interests = [];
  bool _isPublic = true;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final profile = ref.read(currentProfileProvider);
    if (profile != null) {
      _isEditMode = true;
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _bioController.text = profile.bio ?? '';
      _phoneController.text = profile.phone ?? '';
      _locationController.text = profile.location ?? '';
      _websiteController.text = profile.website ?? '';
      _professionController.text = profile.profession ?? '';
      _selectedBirthDate = profile.birthDate;
      _interests = List.from(profile.interests);
      _isPublic = profile.isPublic;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _professionController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);
    final isUpdating = profileState.isUpdating;
    final currentProfile = profileState.profile;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Perfil' : 'Criar Perfil'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          if (!isUpdating)
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                _isEditMode ? 'Salvar' : 'Criar',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(context, currentProfile, isUpdating),
    );
  }

  Widget _buildBody(
      BuildContext context, UserProfile? profile, bool isUpdating) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar section
            _buildAvatarSection(context, profile),

            const SizedBox(height: 32),

            // Basic information
            _buildBasicInfoSection(context),

            const SizedBox(height: 24),

            // Personal information
            _buildPersonalInfoSection(context),

            const SizedBox(height: 24),

            // Interests
            _buildInterestsSection(context),

            const SizedBox(height: 24),

            // Privacy settings
            _buildPrivacySection(context),

            const SizedBox(height: 32),

            // Action buttons
            _buildActionButtons(context, isUpdating),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context, UserProfile? profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Foto do Perfil',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (profile != null)
              ProfileAvatarLarge(
                profile: profile,
                onEditTap: () => _showAvatarOptions(context),
              )
            else
              ProfileAvatarPlaceholder(
                size: 120,
                onTap: () => _showAvatarOptions(context),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => _showAvatarOptions(context),
                  icon: const Icon(Icons.camera_alt),
                  label: Text(profile?.hasCustomAvatar == true
                      ? 'Alterar Foto'
                      : 'Adicionar Foto'),
                ),
                if (profile?.hasCustomAvatar == true) ...[
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: () =>
                        ref.read(userProfileProvider.notifier).removeAvatar(),
                    icon: const Icon(Icons.delete),
                    label: const Text('Remover'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações Básicas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            // Nome
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome completo',
                hintText: 'Digite seu nome completo',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome é obrigatório';
                }
                if (value.trim().length < 2) {
                  return 'Nome deve ter pelo menos 2 caracteres';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Digite seu email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email é obrigatório';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Email inválido';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Bio
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Biografia',
                hintText: 'Conte um pouco sobre você',
                prefixIcon: Icon(Icons.info),
              ),
              maxLines: 3,
              maxLength: 500,
              validator: (value) {
                if (value != null && value.length > 500) {
                  return 'Biografia deve ter no máximo 500 caracteres';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações Pessoais',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            // Profissão
            TextFormField(
              controller: _professionController,
              decoration: const InputDecoration(
                labelText: 'Profissão',
                hintText: 'Sua profissão atual',
                prefixIcon: Icon(Icons.work),
              ),
            ),

            const SizedBox(height: 16),

            // Localização
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Localização',
                hintText: 'Cidade, País',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),

            const SizedBox(height: 16),

            // Telefone
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                hintText: '(11) 99999-9999',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
                  if (cleaned.length < 10 || cleaned.length > 15) {
                    return 'Telefone inválido';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Website
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website',
                hintText: 'https://seusite.com',
                prefixIcon: Icon(Icons.web),
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(
                          r'^https?:\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$')
                      .hasMatch(value)) {
                    return 'Website inválido';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Data de nascimento
            InkWell(
              onTap: () => _selectBirthDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data de nascimento',
                  prefixIcon: Icon(Icons.cake),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedBirthDate != null
                      ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                      : 'Selecione uma data',
                  style: _selectedBirthDate != null
                      ? Theme.of(context).textTheme.bodyLarge
                      : Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interesses',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            // Campo para adicionar interesse
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _interestController,
                    decoration: const InputDecoration(
                      labelText: 'Adicionar interesse',
                      hintText: 'Digite um interesse',
                      prefixIcon: Icon(Icons.favorite),
                    ),
                    onFieldSubmitted: (value) => _addInterest(value),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _addInterest(_interestController.text),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Lista de interesses
            if (_interests.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _interests
                    .map((interest) => Chip(
                          label: Text(interest),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () => _removeInterest(interest),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ))
                    .toList(),
              ),
            ] else
              Text(
                'Nenhum interesse adicionado',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacidade',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Perfil público'),
              subtitle: const Text('Permitir que outros vejam seu perfil'),
              value: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isUpdating) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isUpdating ? null : () => context.pop(),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isUpdating ? null : _saveProfile,
            child: isUpdating
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEditMode ? 'Salvar' : 'Criar'),
          ),
        ),
      ],
    );
  }

  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(userProfileProvider.notifier)
                    .uploadAvatarFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.pop(context);
                ref.read(userProfileProvider.notifier).uploadAvatarFromCamera();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _addInterest(String interest) {
    final trimmed = interest.trim();
    if (trimmed.isNotEmpty && !_interests.contains(trimmed)) {
      setState(() {
        _interests.add(trimmed);
        _interestController.clear();
      });
    }
  }

  void _removeInterest(String interest) {
    setState(() {
      _interests.remove(interest);
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (_isEditMode) {
        await ref.read(userProfileProvider.notifier).updateProfile(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              bio: _bioController.text.trim().isEmpty
                  ? null
                  : _bioController.text.trim(),
              phone: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
              location: _locationController.text.trim().isEmpty
                  ? null
                  : _locationController.text.trim(),
              website: _websiteController.text.trim().isEmpty
                  ? null
                  : _websiteController.text.trim(),
              profession: _professionController.text.trim().isEmpty
                  ? null
                  : _professionController.text.trim(),
              birthDate: _selectedBirthDate,
              interests: _interests,
              isPublic: _isPublic,
            );
      } else {
        await ref.read(userProfileProvider.notifier).createProfile(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
            );

        // Atualizar com informações adicionais
        await ref.read(userProfileProvider.notifier).updateProfile(
              bio: _bioController.text.trim().isEmpty
                  ? null
                  : _bioController.text.trim(),
              phone: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
              location: _locationController.text.trim().isEmpty
                  ? null
                  : _locationController.text.trim(),
              website: _websiteController.text.trim().isEmpty
                  ? null
                  : _websiteController.text.trim(),
              profession: _professionController.text.trim().isEmpty
                  ? null
                  : _professionController.text.trim(),
              birthDate: _selectedBirthDate,
              interests: _interests,
              isPublic: _isPublic,
            );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode
                ? 'Perfil atualizado com sucesso!'
                : 'Perfil criado com sucesso!'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar perfil: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
