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
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../models/custom_pdf_template.dart';
import '../models/pdf_template.dart';

/// Formulário modal para criação de templates customizados
class CustomTemplateForm extends ConsumerStatefulWidget {
  final CustomPdfTemplate? template; // Para edição

  const CustomTemplateForm({
    super.key,
    this.template,
  });

  @override
  ConsumerState<CustomTemplateForm> createState() => _CustomTemplateFormState();
}

class _CustomTemplateFormState extends ConsumerState<CustomTemplateForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _headerTitleController;
  late TextEditingController _footerTextController;

  late IconData _selectedIcon;
  late Color _selectedColor;
  late CustomHeaderConfig _headerConfig;
  late CustomFooterConfig _footerConfig;

  // Variáveis para logos
  Uint8List? _headerLogoBytes;
  Uint8List? _footerLogoBytes;
  LogoSize _headerLogoSize = LogoSize.small;
  LogoSize _footerLogoSize = LogoSize.small;

  @override
  void initState() {
    super.initState();

    // Usar template padrão Bloquinho como base
    final defaultTemplate = PdfTemplates.getTemplate(PdfTemplateType.bloquinho);

    _nameController = TextEditingController(
      text: widget.template?.name ?? 'Meu Template',
    );
    _descriptionController = TextEditingController(
      text: widget.template?.description ?? 'Template personalizado',
    );
    _headerTitleController = TextEditingController(
      text: widget.template?.header.title ?? 'Documento',
    );
    _footerTextController = TextEditingController(
      text: widget.template?.footer.text ?? 'Exported with Bloquinho',
    );

    _selectedIcon = widget.template?.icon ?? Icons.description;
    _selectedColor = widget.template?.previewColor ?? const Color(0xFF5C4033);

    // Configurações padrão baseadas no template Bloquinho
    _headerConfig = widget.template?.header ??
        const CustomHeaderConfig(
          enabled: false,
          title: 'Documento',
          showLogo: true,
          showDate: false,
          showPageNumber: false,
          backgroundColor: '#FFFFFF',
          textColor: '#5C4033',
          fontSize: 12,
          showBorder: false,
          borderColor: '#CCCCCC',
          height: 40,
        );

    _footerConfig = widget.template?.footer ??
        const CustomFooterConfig(
          enabled: true,
          text: 'Exported with Bloquinho',
          showLogo: true,
          showPageNumber: true,
          showExportedText: true,
          backgroundColor: '#FFFFFF',
          textColor: '#5C4033',
          fontSize: 10,
          showBorder: false,
          borderColor: '#CCCCCC',
          height: 25,
        );

    // Carregar logos existentes se estiver editando
    if (widget.template != null) {
      _headerLogoBytes = widget.template!.header.logoBytes;
      _footerLogoBytes = widget.template!.footer.logoBytes;
      _headerLogoSize = widget.template!.header.logoSize;
      _footerLogoSize = widget.template!.footer.logoSize;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _headerTitleController.dispose();
    _footerTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        height: 700,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header do modal
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _selectedColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedIcon,
                    color: _selectedColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.template != null
                          ? 'Editar Template'
                          : 'Criar Template',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Conteúdo do formulário
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informações básicas
                      _buildSectionTitle('Informações Básicas'),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _nameController,
                        label: 'Nome do Template',
                        hint: 'Ex: Meu Template Profissional',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nome é obrigatório';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Descrição',
                        hint: 'Breve descrição do template',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Descrição é obrigatória';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Aparência
                      _buildSectionTitle('Aparência'),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildIconSelector(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildColorSelector(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Configurações do Header
                      _buildSectionTitle('Header'),
                      const SizedBox(height: 16),
                      _buildHeaderConfig(),

                      const SizedBox(height: 24),

                      // Configurações do Footer
                      _buildSectionTitle('Footer'),
                      const SizedBox(height: 16),
                      _buildFooterConfig(),
                    ],
                  ),
                ),
              ),
            ),

            // Botões de ação
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      // Resetar para padrão Bloquinho
                      _resetToDefault();
                    },
                    child: const Text('Usar Padrão Bloquinho'),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _saveTemplate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedColor,
                          foregroundColor: Colors.white,
                        ),
                        child:
                            Text(widget.template != null ? 'Salvar' : 'Criar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _selectedColor,
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _selectedColor),
        ),
      ),
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ícone',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: TemplateIcons.icons.length,
            itemBuilder: (context, index) {
              final icon = TemplateIcons.icons[index];
              final isSelected = icon == _selectedIcon;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? _selectedColor.withOpacity(0.2) : null,
                    borderRadius: BorderRadius.circular(4),
                    border:
                        isSelected ? Border.all(color: _selectedColor) : null,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isSelected ? _selectedColor : Colors.grey[600],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cor',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: TemplateColors.colors.length,
            itemBuilder: (context, index) {
              final color = TemplateColors.colors[index];
              final isSelected = color == _selectedColor;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderConfig() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Ativar Header'),
              value: _headerConfig.enabled,
              onChanged: (value) {
                setState(() {
                  _headerConfig = _headerConfig.copyWith(enabled: value);
                });
              },
            ),
            if (_headerConfig.enabled) ...[
              const SizedBox(height: 16),
              _buildTextField(
                controller: _headerTitleController,
                label: 'Título do Header',
                hint: 'Ex: Documento Bloquinho\nSuporte a múltiplas linhas',
                validator: null,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Mostrar Logo'),
                      value: _headerConfig.showLogo,
                      onChanged: (value) {
                        setState(() {
                          _headerConfig =
                              _headerConfig.copyWith(showLogo: value);
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Mostrar Data'),
                      value: _headerConfig.showDate,
                      onChanged: (value) {
                        setState(() {
                          _headerConfig =
                              _headerConfig.copyWith(showDate: value);
                        });
                      },
                    ),
                  ),
                ],
              ),
              CheckboxListTile(
                title: const Text('Mostrar Borda'),
                value: _headerConfig.showBorder,
                onChanged: (value) {
                  setState(() {
                    _headerConfig = _headerConfig.copyWith(showBorder: value);
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildLogoUpload(true),
              const SizedBox(height: 16),
              _buildLogoSizeSelector(true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooterConfig() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Ativar Footer'),
              value: _footerConfig.enabled,
              onChanged: (value) {
                setState(() {
                  _footerConfig = _footerConfig.copyWith(enabled: value);
                });
              },
            ),
            if (_footerConfig.enabled) ...[
              const SizedBox(height: 16),
              _buildTextField(
                controller: _footerTextController,
                label: 'Texto do Footer',
                hint: 'Ex: Exported with Bloquinho\nSuporte a múltiplas linhas',
                validator: null,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Mostrar Logo'),
                      value: _footerConfig.showLogo,
                      onChanged: (value) {
                        setState(() {
                          _footerConfig =
                              _footerConfig.copyWith(showLogo: value);
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Número da Página'),
                      value: _footerConfig.showPageNumber,
                      onChanged: (value) {
                        setState(() {
                          _footerConfig =
                              _footerConfig.copyWith(showPageNumber: value);
                        });
                      },
                    ),
                  ),
                ],
              ),
              CheckboxListTile(
                title: const Text('Mostrar Borda'),
                value: _footerConfig.showBorder,
                onChanged: (value) {
                  setState(() {
                    _footerConfig = _footerConfig.copyWith(showBorder: value);
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildLogoUpload(false),
              const SizedBox(height: 16),
              _buildLogoSizeSelector(false),
            ],
          ],
        ),
      ),
    );
  }

  void _resetToDefault() {
    setState(() {
      _nameController.text = 'Meu Template';
      _descriptionController.text = 'Template personalizado';
      _headerTitleController.text = 'Documento';
      _footerTextController.text = 'Exported with Bloquinho';
      _selectedIcon = Icons.description;
      _selectedColor = const Color(0xFF5C4033);

      _headerConfig = const CustomHeaderConfig(
        enabled: false,
        title: 'Documento',
        showLogo: true,
        showDate: false,
        showPageNumber: false,
      );

      _footerConfig = const CustomFooterConfig(
        enabled: true,
        text: 'Exported with Bloquinho',
        showLogo: true,
        showPageNumber: true,
        showExportedText: true,
      );
    });
  }

  /// Método para selecionar logo
  Future<void> _pickLogo(bool isHeader) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          setState(() {
            if (isHeader) {
              _headerLogoBytes = file.bytes;
            } else {
              _footerLogoBytes = file.bytes;
            }
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar logo: $e')),
      );
    }
  }

  /// Método para remover logo
  void _removeLogo(bool isHeader) {
    setState(() {
      if (isHeader) {
        _headerLogoBytes = null;
      } else {
        _footerLogoBytes = null;
      }
    });
  }

  /// Widget para seleção de tamanho de logo
  Widget _buildLogoSizeSelector(bool isHeader) {
    final currentSize = isHeader ? _headerLogoSize : _footerLogoSize;
    final onChanged = (LogoSize? size) {
      if (size != null) {
        setState(() {
          if (isHeader) {
            _headerLogoSize = size;
          } else {
            _footerLogoSize = size;
          }
        });
      }
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tamanho do Logo',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<LogoSize>(
                title: const Text('Pequeno'),
                value: LogoSize.small,
                groupValue: currentSize,
                onChanged: onChanged,
              ),
            ),
            Expanded(
              child: RadioListTile<LogoSize>(
                title: const Text('Médio'),
                value: LogoSize.medium,
                groupValue: currentSize,
                onChanged: onChanged,
              ),
            ),
            Expanded(
              child: RadioListTile<LogoSize>(
                title: const Text('Grande'),
                value: LogoSize.large,
                groupValue: currentSize,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Widget para upload de logo
  Widget _buildLogoUpload(bool isHeader) {
    final hasLogo =
        isHeader ? _headerLogoBytes != null : _footerLogoBytes != null;
    final logoBytes = isHeader ? _headerLogoBytes : _footerLogoBytes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logo Personalizado',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickLogo(isHeader),
                icon: const Icon(Icons.upload),
                label: Text(hasLogo ? 'Alterar Logo' : 'Selecionar Logo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor.withOpacity(0.1),
                  foregroundColor: _selectedColor,
                ),
              ),
            ),
            if (hasLogo) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _removeLogo(isHeader),
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Remover Logo',
              ),
            ],
          ],
        ),
        if (hasLogo) ...[
          const SizedBox(height: 8),
          Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                logoBytes!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _saveTemplate() {
    if (_formKey.currentState?.validate() ?? false) {
      final template = CustomPdfTemplate(
        id: widget.template?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        icon: _selectedIcon,
        previewColor: _selectedColor,
        header: _headerConfig.copyWith(
          title: _headerTitleController.text.trim(),
          logoBytes: _headerLogoBytes,
          logoSize: _headerLogoSize,
        ),
        footer: _footerConfig.copyWith(
          text: _footerTextController.text.trim(),
          logoBytes: _footerLogoBytes,
          logoSize: _footerLogoSize,
        ),
        createdAt: widget.template?.createdAt ?? DateTime.now(),
      );

      Navigator.of(context).pop(template);
    }
  }
}
