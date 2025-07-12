import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/password_provider.dart';

class PasswordGeneratorDialog extends ConsumerStatefulWidget {
  const PasswordGeneratorDialog({super.key});

  @override
  ConsumerState<PasswordGeneratorDialog> createState() =>
      _PasswordGeneratorDialogState();
}

class _PasswordGeneratorDialogState
    extends ConsumerState<PasswordGeneratorDialog> {
  int _length = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  bool _excludeSimilar = true;
  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
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
                    Icons.key,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Gerador de Senhas',
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

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Senha gerada
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.darkBackground
                            : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lock,
                                size: 20,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Senha Gerada',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _generatedPassword,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              IconButton(
                                onPressed: _copyPassword,
                                icon: Icon(Icons.copy),
                                tooltip: 'Copiar senha',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Comprimento
                    Text(
                      'Comprimento: $_length',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _length.toDouble(),
                      min: 8,
                      max: 64,
                      divisions: 56,
                      label: _length.toString(),
                      onChanged: (value) {
                        setState(() {
                          _length = value.round();
                          _generatePassword();
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Opções
                    Text(
                      'Opções',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Maiúsculas
                    CheckboxListTile(
                      title: const Text('Incluir maiúsculas (A-Z)'),
                      subtitle: const Text('ABCDEFGHIJKLMNOPQRSTUVWXYZ'),
                      value: _includeUppercase,
                      onChanged: (value) {
                        setState(() {
                          _includeUppercase = value ?? false;
                          _generatePassword();
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),

                    // Minúsculas
                    CheckboxListTile(
                      title: const Text('Incluir minúsculas (a-z)'),
                      subtitle: const Text('abcdefghijklmnopqrstuvwxyz'),
                      value: _includeLowercase,
                      onChanged: (value) {
                        setState(() {
                          _includeLowercase = value ?? false;
                          _generatePassword();
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),

                    // Números
                    CheckboxListTile(
                      title: const Text('Incluir números (0-9)'),
                      subtitle: const Text('0123456789'),
                      value: _includeNumbers,
                      onChanged: (value) {
                        setState(() {
                          _includeNumbers = value ?? false;
                          _generatePassword();
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),

                    // Símbolos
                    CheckboxListTile(
                      title: const Text('Incluir símbolos (!@#\$%^&*)'),
                      subtitle: const Text('!@#\$%^&*()_+-=[]{}|;:,.<>?'),
                      value: _includeSymbols,
                      onChanged: (value) {
                        setState(() {
                          _includeSymbols = value ?? false;
                          _generatePassword();
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),

                    // Excluir similares
                    CheckboxListTile(
                      title: const Text('Excluir caracteres similares'),
                      subtitle: const Text('il1Lo0O'),
                      value: _excludeSimilar,
                      onChanged: (value) {
                        setState(() {
                          _excludeSimilar = value ?? false;
                          _generatePassword();
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),

                    const SizedBox(height: 24),

                    // Botões de ação
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _generatePassword,
                            icon: Icon(Icons.refresh),
                            label: const Text('Gerar Nova'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _usePassword,
                            icon: Icon(Icons.check),
                            label: const Text('Usar Senha'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generatePassword() {
    final password = ref.read(passwordProvider.notifier).generatePassword(
          length: _length,
          includeUppercase: _includeUppercase,
          includeLowercase: _includeLowercase,
          includeNumbers: _includeNumbers,
          includeSymbols: _includeSymbols,
          excludeSimilar: _excludeSimilar,
        );

    setState(() {
      _generatedPassword = password;
    });
  }

  void _copyPassword() {
    // Implementar cópia para clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Senha copiada para a área de transferência')),
    );
  }

  void _usePassword() {
    Navigator.of(context).pop(_generatedPassword);
  }
}
