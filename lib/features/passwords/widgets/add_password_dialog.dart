/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_action_button.dart';
import '../providers/password_provider.dart';
import '../models/password_entry.dart';

class AddPasswordDialog extends ConsumerStatefulWidget {
  final PasswordEntry? password;

  const AddPasswordDialog({super.key, this.password});

  @override
  ConsumerState<AddPasswordDialog> createState() => _AddPasswordDialogState();
}

class _AddPasswordDialogState extends ConsumerState<AddPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _websiteController = TextEditingController();
  final _notesController = TextEditingController();
  final _categoryController = TextEditingController();
  final _tagsController = TextEditingController();

  String? _selectedCategory;
  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.password != null) {
      _titleController.text = widget.password!.title;
      _usernameController.text = widget.password!.username;
      _passwordController.text = widget.password!.password;
      _websiteController.text = widget.password!.website ?? '';
      _notesController.text = widget.password!.notes ?? '';
      _categoryController.text = widget.password!.category ?? '';
      _tagsController.text = widget.password!.tags.join(', ');
      _selectedCategory = widget.password!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final isCreating = ref.watch(isCreatingProvider);
    final isUpdating = ref.watch(isUpdatingProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:
                    isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.password != null ? Icons.edit : Icons.add,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.password != null ? 'Editar Senha' : 'Nova Senha',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título *',
                          hintText: 'Ex: Conta do Gmail',
                          prefixIcon: Icon(Icons.title),
                        ),
                        textInputAction: TextInputAction.next,
                        enableInteractiveSelection: true,
                        autocorrect: false,
                        enableSuggestions: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Título é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Username
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Utilizador *',
                          hintText: 'Ex: usuario@gmail.com',
                          prefixIcon: Icon(Icons.person),
                        ),
                        textInputAction: TextInputAction.next,
                        enableInteractiveSelection: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Utilizador é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          labelText: 'Senha *',
                          hintText: 'Digite a senha',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _generatePassword(),
                                icon: Icon(Icons.refresh),
                                tooltip: 'Gerar senha',
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                },
                                icon: Icon(_showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                tooltip: _showPassword
                                    ? 'Ocultar senha'
                                    : 'Mostrar senha',
                              ),
                            ],
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        enableInteractiveSelection: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Senha é obrigatória';
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
                          hintText: 'Ex: https://gmail.com',
                          prefixIcon: Icon(Icons.link),
                        ),
                        textInputAction: TextInputAction.next,
                        enableInteractiveSelection: true,
                        autocorrect: false,
                        enableSuggestions: false,
                      ),
                      const SizedBox(height: 16),

                      // Categoria
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Categoria',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Selecionar categoria'),
                          ),
                          ...[
                            'Social',
                            'Finance',
                            'Work',
                            'Email',
                            'Shopping',
                            'Entertainment',
                            'Health',
                            'Education'
                          ]
                              .map((category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  ))
                              .toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                            _categoryController.text = value ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tags
                      TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Tags',
                          hintText: 'Ex: trabalho, importante, pessoal',
                          prefixIcon: Icon(Icons.tag),
                        ),
                        textInputAction: TextInputAction.next,
                        enableInteractiveSelection: true,
                        autocorrect: false,
                        enableSuggestions: true,
                      ),
                      const SizedBox(height: 16),

                      // Notas
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notas',
                          hintText: 'Informações adicionais...',
                          prefixIcon: Icon(Icons.note),
                          alignLabelWithHint: true,
                        ),
                        textInputAction: TextInputAction.done,
                        enableInteractiveSelection: true,
                        autocorrect: false,
                        enableSuggestions: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:
                    isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedActionButton(
                      text: 'Cancelar',
                      onPressed: () => Navigator.of(context).pop(),
                      type: ButtonType.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedActionButton(
                      text: widget.password != null ? 'Atualizar' : 'Salvar',
                      onPressed: _savePassword,
                      isLoading: isCreating || isUpdating,
                      isEnabled: !(isCreating || isUpdating),
                      icon: widget.password != null ? Icons.update : Icons.save,
                      type: ButtonType.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generatePassword() {
    final generatedPassword =
        ref.read(passwordProvider.notifier).generatePassword();
    setState(() {
      _passwordController.text = generatedPassword;
    });
  }

  void _savePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final passwordEntry = PasswordEntry(
      id: widget.password?.id ?? '',
      title: _titleController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      website: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      category: _selectedCategory,
      tags: _tagsController.text.trim().isEmpty
          ? []
          : _tagsController.text
              .trim()
              .split(',')
              .map((tag) => tag.trim())
              .toList(),
      createdAt: widget.password?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      lastUsed: widget.password?.lastUsed,
      isFavorite: widget.password?.isFavorite ?? false,
      isArchived: widget.password?.isArchived ?? false,
      strength: widget.password?.strength ?? PasswordStrength.weak,
      iconUrl: widget.password?.iconUrl,
      customIcon: widget.password?.customIcon,
      customFields: widget.password?.customFields ?? {},
      attachments: widget.password?.attachments ?? [],
      folderId: widget.password?.folderId,
      isShared: widget.password?.isShared ?? false,
      sharedWith: widget.password?.sharedWith ?? [],
      expiresAt: widget.password?.expiresAt,
      autoFillEnabled: widget.password?.autoFillEnabled ?? true,
    );

    try {
      if (widget.password != null) {
        await ref.read(passwordProvider.notifier).updatePassword(passwordEntry);
      } else {
        await ref.read(passwordProvider.notifier).createPassword(passwordEntry);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.password != null
                ? 'Senha atualizada com sucesso!'
                : 'Senha criada com sucesso!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar senha: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
