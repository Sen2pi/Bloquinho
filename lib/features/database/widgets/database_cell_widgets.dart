/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:bloquinho/core/models/database_models.dart';
import 'package:bloquinho/core/l10n/app_strings.dart';
import 'package:bloquinho/shared/providers/language_provider.dart';

/// Widget base para células editáveis
abstract class DatabaseCellWidget extends StatelessWidget {
  final DatabaseCellValue? value;
  final DatabaseColumn column;
  final bool isEditing;
  final ValueChanged<dynamic>? onChanged;
  final VoidCallback? onStartEdit;
  final VoidCallback? onStopEdit;

  const DatabaseCellWidget({
    super.key,
    required this.value,
    required this.column,
    this.isEditing = false,
    this.onChanged,
    this.onStartEdit,
    this.onStopEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditing ? null : onStartEdit,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        width: double.infinity,
        decoration: BoxDecoration(
          border: isEditing
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child:
            isEditing ? buildEditWidget(context) : buildDisplayWidget(context),
      ),
    );
  }

  Widget buildEditWidget(BuildContext context);
  Widget buildDisplayWidget(BuildContext context);
}

/// Widget para células de texto
class TextCellWidget extends DatabaseCellWidget {
  const TextCellWidget({
    super.key,
    required super.value,
    required super.column,
    super.isEditing,
    super.onChanged,
    super.onStartEdit,
    super.onStopEdit,
  });

  @override
  Widget buildEditWidget(BuildContext context) {
    return TextFormField(
      controller: TextEditingController(text: value?.value?.toString() ?? ''),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: onChanged,
      onFieldSubmitted: (_) => onStopEdit?.call(),
      autofocus: true,
      textInputAction: TextInputAction.done,
      enableInteractiveSelection: true,
      autocorrect: false,
      enableSuggestions: true,
      textDirection: TextDirection.ltr,
    );
  }

  @override
  Widget buildDisplayWidget(BuildContext context) {
    final displayText = value?.displayValue ?? '';
    return Text(
      displayText.isEmpty ? 'Vazio' : displayText,
      style: TextStyle(
        color: displayText.isEmpty
            ? Colors.grey
            : Theme.of(context).textTheme.bodyMedium?.color,
        fontStyle: displayText.isEmpty ? FontStyle.italic : null,
      ),
      textDirection: TextDirection.ltr,
    );
  }
}

/// Widget para células numéricas
class NumberCellWidget extends DatabaseCellWidget {
  const NumberCellWidget({
    super.key,
    required super.value,
    required super.column,
    super.isEditing,
    super.onChanged,
    super.onStartEdit,
    super.onStopEdit,
  });

  @override
  Widget buildEditWidget(BuildContext context) {
    return TextFormField(
      controller: TextEditingController(text: value?.value?.toString() ?? ''),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
      ],
      onChanged: (text) {
        final number = double.tryParse(text);
        onChanged?.call(number);
      },
      onFieldSubmitted: (_) => onStopEdit?.call(),
      autofocus: true,
      textInputAction: TextInputAction.done,
      enableInteractiveSelection: true,
      autocorrect: false,
      enableSuggestions: false,
    );
  }

  @override
  Widget buildDisplayWidget(BuildContext context) {
    final numValue = value?.numericValue;
    if (numValue == null) {
      return const Text(
        'Vazio',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    return Text(
      numValue % 1 == 0
          ? numValue.toInt().toString()
          : numValue.toStringAsFixed(2),
      style: const TextStyle(fontVariations: [FontVariation('wght', 500)]),
    );
  }
}

/// Widget para células de checkbox
class CheckboxCellWidget extends DatabaseCellWidget {
  const CheckboxCellWidget({
    super.key,
    required super.value,
    required super.column,
    super.isEditing,
    super.onChanged,
    super.onStartEdit,
    super.onStopEdit,
  });

  @override
  Widget buildEditWidget(BuildContext context) => buildDisplayWidget(context);

  @override
  Widget buildDisplayWidget(BuildContext context) {
    final boolValue = value?.value is bool ? value!.value as bool : false;

    return Center(
      child: Checkbox(
        value: boolValue,
        onChanged: onChanged != null ? (val) => onChanged!(val ?? false) : null,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// Widget para células de seleção
class SelectCellWidget extends DatabaseCellWidget {
  const SelectCellWidget({
    super.key,
    required super.value,
    required super.column,
    super.isEditing,
    super.onChanged,
    super.onStartEdit,
    super.onStopEdit,
  });

  @override
  Widget buildEditWidget(BuildContext context) {
    final options = column.selectOptions;
    final currentValue = value?.value?.toString();

    return DropdownButtonFormField<String>(
      value: options.any((o) => o.id == currentValue) ? currentValue : null,
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Selecionar...', style: TextStyle(color: Colors.grey)),
        ),
        ...options.map((option) => DropdownMenuItem<String>(
              value: option.id,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: option.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(option.name),
                ],
              ),
            )),
      ],
      onChanged: (val) {
        onChanged?.call(val);
        onStopEdit?.call();
      },
      isExpanded: true,
    );
  }

  @override
  Widget buildDisplayWidget(BuildContext context) {
    final options = column.selectOptions;
    final currentValue = value?.value?.toString();

    if (currentValue == null) {
      return const Text(
        'Não selecionado',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    final selectedOption =
        options.where((o) => o.id == currentValue).firstOrNull;
    if (selectedOption == null) {
      return Text(
        currentValue,
        style: const TextStyle(color: Colors.red),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: selectedOption.color.withOpacity(0.2),
        border: Border.all(color: selectedOption.color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        selectedOption.name,
        style: TextStyle(
          color: selectedOption.color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Widget para células de multi-seleção
class MultiSelectCellWidget extends DatabaseCellWidget {
  const MultiSelectCellWidget({
    super.key,
    required super.value,
    required super.column,
    super.isEditing,
    super.onChanged,
    super.onStartEdit,
    super.onStopEdit,
  });

  @override
  Widget buildEditWidget(BuildContext context) {
    final options = column.selectOptions;
    final currentValues = value?.value is List
        ? (value!.value as List).map((e) => e.toString()).toSet()
        : <String>{};

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: options.map((option) {
        final isSelected = currentValues.contains(option.id);
        return CheckboxListTile(
          value: isSelected,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: option.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(option.name),
            ],
          ),
          onChanged: (selected) {
            final newValues = Set<String>.from(currentValues);
            if (selected == true) {
              newValues.add(option.id);
            } else {
              newValues.remove(option.id);
            }
            onChanged?.call(newValues.toList());
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  @override
  Widget buildDisplayWidget(BuildContext context) {
    final options = column.selectOptions;
    final currentValues = value?.value is List
        ? (value!.value as List).map((e) => e.toString()).toSet()
        : <String>{};

    if (currentValues.isEmpty) {
      return const Text(
        'Nenhum selecionado',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    final selectedOptions =
        options.where((o) => currentValues.contains(o.id)).toList();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: selectedOptions
          .map((option) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: option.color.withOpacity(0.2),
                  border: Border.all(color: option.color),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  option.name,
                  style: TextStyle(
                    color: option.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

/// Widget para células de data
class DateCellWidget extends DatabaseCellWidget {
  const DateCellWidget({
    super.key,
    required super.value,
    required super.column,
    super.isEditing,
    super.onChanged,
    super.onStartEdit,
    super.onStopEdit,
  });

  @override
  Widget buildEditWidget(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final currentDate = value?.value is DateTime
            ? value!.value as DateTime
            : DateTime.now();
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: currentDate,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (selectedDate != null) {
          onChanged?.call(selectedDate);
          onStopEdit?.call();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16),
            const SizedBox(width: 8),
            Text(value?.value is DateTime
                ? _formatDate(value!.value as DateTime)
                : 'Selecionar data'),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildDisplayWidget(BuildContext context) {
    if (value?.value is! DateTime) {
      return const Text(
        'Sem data',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(_formatDate(value!.value as DateTime)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

/// Widget para células de URL
class UrlCellWidget extends DatabaseCellWidget {
  const UrlCellWidget({
    super.key,
    required super.value,
    required super.column,
    super.isEditing,
    super.onChanged,
    super.onStartEdit,
    super.onStopEdit,
  });

  @override
  Widget buildEditWidget(BuildContext context) {
    return TextFormField(
      initialValue: value?.value?.toString() ?? '',
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintText: 'https://...',
      ),
      keyboardType: TextInputType.url,
      onChanged: onChanged,
      onFieldSubmitted: (_) => onStopEdit?.call(),
      autofocus: true,
    );
  }

  @override
  Widget buildDisplayWidget(BuildContext context) {
    final url = value?.value?.toString();
    if (url == null || url.isEmpty) {
      return const Text(
        'Sem URL',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    return GestureDetector(
      onTap: () {
        // TODO: Implementar abertura de URL
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Abrir: $url')),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link, size: 14, color: Colors.blue),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              url,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para células de avaliação (rating)
class RatingCellWidget extends DatabaseCellWidget {
  const RatingCellWidget({
    super.key,
    required super.value,
    required super.column,
    super.isEditing,
    super.onChanged,
    super.onStartEdit,
    super.onStopEdit,
  });

  @override
  Widget buildEditWidget(BuildContext context) => buildDisplayWidget(context);

  @override
  Widget buildDisplayWidget(BuildContext context) {
    final rating = value?.numericValue?.toInt() ?? 0;
    final maxRating = 5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final isFilled = index < rating;
        return GestureDetector(
          onTap: onChanged != null ? () => onChanged!(index + 1) : null,
          child: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 16,
          ),
        );
      }),
    );
  }
}

/// Widget para células de progresso
class ProgressCellWidget extends DatabaseCellWidget {
  const ProgressCellWidget({
    super.key,
    required super.value,
    required super.column,
    super.isEditing,
    super.onChanged,
    super.onStartEdit,
    super.onStopEdit,
  });

  @override
  Widget buildEditWidget(BuildContext context) {
    final progress = (value?.numericValue ?? 0).clamp(0.0, 100.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Slider(
          value: progress,
          min: 0,
          max: 100,
          divisions: 100,
          label: '${progress.toInt()}%',
          onChanged: onChanged,
          onChangeEnd: (_) => onStopEdit?.call(),
        ),
        Text('${progress.toInt()}%'),
      ],
    );
  }

  @override
  Widget buildDisplayWidget(BuildContext context) {
    final progress = (value?.numericValue ?? 0).clamp(0.0, 100.0) / 100.0;

    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress < 0.3
                  ? Colors.red
                  : progress < 0.7
                      ? Colors.orange
                      : Colors.green,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${(progress * 100).toInt()}%',
            style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// Widget para células de arquivo
class FileCellWidget extends DatabaseCellWidget {
  const FileCellWidget({
    super.key,
    required super.value,
    required super.column,
    super.isEditing,
    super.onChanged,
    super.onStartEdit,
    super.onStopEdit,
  });

  @override
  Widget buildEditWidget(BuildContext context) => buildDisplayWidget(context);

  @override
  Widget buildDisplayWidget(BuildContext context) {
    final filePath = value?.value?.toString();
    final fileName = filePath?.split('/').last ?? filePath?.split('\\').last;

    return Row(
      children: [
        Expanded(
          child: filePath != null && filePath.isNotEmpty
              ? _buildFileDisplay(context, filePath, fileName ?? 'Arquivo')
              : _buildEmptyState(context),
        ),
        IconButton(
          icon: const Icon(Icons.attach_file, size: 18),
          onPressed: () => _pickFile(context),
          tooltip: 'Selecionar arquivo',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildFileDisplay(
      BuildContext context, String filePath, String fileName) {
    return InkWell(
      onTap: () => _downloadFile(context, filePath, fileName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_drive_file,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                fileName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.download,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Text(
      'Nenhum arquivo',
      style: TextStyle(
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
        fontSize: 12,
      ),
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        onChanged?.call(result.files.single.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar arquivo: $e')),
        );
      }
    }
  }

  Future<void> _downloadFile(
      BuildContext context, String filePath, String fileName) async {
    try {
      if (filePath.startsWith('http')) {
        // URL remota - abrir no navegador
        final uri = Uri.parse(filePath);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        // Arquivo local - copiar para Downloads
        final file = File(filePath);
        if (await file.exists()) {
          // No Windows, abrir a pasta que contém o arquivo
          if (Platform.isWindows) {
            await Process.run('explorer', ['/select,', filePath]);
          } else {
            // Em outras plataformas, tentar abrir o arquivo
            final uri = Uri.file(filePath);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          }
        } else {
          throw 'Arquivo não encontrado';
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir arquivo: $e')),
        );
      }
    }
  }
}

/// Widget para células de imagem
class ImageCellWidget extends DatabaseCellWidget {
  const ImageCellWidget({
    super.key,
    required super.value,
    required super.column,
    super.isEditing,
    super.onChanged,
    super.onStartEdit,
    super.onStopEdit,
  });

  @override
  Widget buildEditWidget(BuildContext context) => buildDisplayWidget(context);

  @override
  Widget buildDisplayWidget(BuildContext context) {
    final imagePath = value?.value?.toString();

    return Row(
      children: [
        Expanded(
          child: imagePath != null && imagePath.isNotEmpty
              ? _buildImageDisplay(context, imagePath)
              : _buildEmptyState(context),
        ),
        IconButton(
          icon: const Icon(Icons.image, size: 18),
          onPressed: () => _pickImage(context),
          tooltip: 'Selecionar imagem',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildImageDisplay(BuildContext context, String imagePath) {
    return InkWell(
      onTap: () => _viewImage(context, imagePath),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: _buildImageWidget(imagePath),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                imagePath.split('/').last.split('\\').last,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.open_in_new,
              size: 14,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: 24,
        height: 24,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.broken_image,
          size: 24,
          color: Colors.grey[400],
        ),
      );
    } else {
      return Image.file(
        File(imagePath),
        width: 24,
        height: 24,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.broken_image,
          size: 24,
          color: Colors.grey[400],
        ),
      );
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Text(
      'Nenhuma imagem',
      style: TextStyle(
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
        fontSize: 12,
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        onChanged?.call(result.files.single.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem: $e')),
        );
      }
    }
  }

  Future<void> _viewImage(BuildContext context, String imagePath) async {
    try {
      if (imagePath.startsWith('http')) {
        // URL remota - abrir no navegador
        final uri = Uri.parse(imagePath);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        // Arquivo local - abrir o arquivo
        final file = File(imagePath);
        if (await file.exists()) {
          final uri = Uri.file(imagePath);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        } else {
          throw 'Arquivo não encontrado';
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir imagem: $e')),
        );
      }
    }
  }
}

/// Widget para células de nota
class NoteCellWidget extends DatabaseCellWidget {
  const NoteCellWidget({
    super.key,
    required super.value,
    required super.column,
    super.isEditing,
    super.onChanged,
    super.onStartEdit,
    super.onStopEdit,
  });

  @override
  Widget buildEditWidget(BuildContext context) {
    return TextFormField(
      initialValue: value?.value?.toString() ?? '',
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(8),
        hintText: 'Digite sua nota...',
      ),
      maxLines: 3,
      onChanged: onChanged,
      onFieldSubmitted: (_) => onStopEdit?.call(),
      autofocus: true,
    );
  }

  @override
  Widget buildDisplayWidget(BuildContext context) {
    final noteText = value?.value?.toString() ?? '';

    if (noteText.isEmpty) {
      return Text(
        'Vazio',
        style: TextStyle(
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
          fontSize: 12,
        ),
      );
    }

    return Text(
      noteText,
      style: Theme.of(context).textTheme.bodySmall,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Widget para células de status
class StatusCellWidget extends DatabaseCellWidget {
  const StatusCellWidget({
    super.key,
    required super.value,
    required super.column,
    super.isEditing,
    super.onChanged,
    super.onStartEdit,
    super.onStopEdit,
  });

  @override
  Widget buildEditWidget(BuildContext context) {
    final options = column.selectOptions;
    final currentValue = value?.value?.toString();

    return DropdownButtonFormField<String>(
      value: options.any((o) => o.id == currentValue) ? currentValue : null,
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      items: options
          .map((option) => DropdownMenuItem<String>(
                value: option.id,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: option.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(option.name),
                  ],
                ),
              ))
          .toList(),
      onChanged: (newValue) {
        onChanged?.call(newValue);
        onStopEdit?.call();
      },
    );
  }

  @override
  Widget buildDisplayWidget(BuildContext context) {
    final options = column.selectOptions;
    final currentValue = value?.value?.toString();

    return InkWell(
      onTap: () => onStartEdit?.call(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: currentValue == null || currentValue.isEmpty
            ? Consumer(
                builder: (context, ref, child) {
                  final strings = ref.watch(appStringsProvider);
                  return Text(
                    strings.clickToChooseStatus,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  );
                },
              )
            : _buildStatusPill(options, currentValue),
      ),
    );
  }

  Widget _buildStatusPill(List<SelectOption> options, String currentValue) {
    final selectedOption = options.firstWhere(
      (o) => o.id == currentValue,
      orElse: () => SelectOption(
        id: currentValue,
        name: currentValue,
        color: Colors.grey,
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: selectedOption.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selectedOption.color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: selectedOption.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            selectedOption.name,
            style: TextStyle(
              color: selectedOption.color.computeLuminance() > 0.5
                  ? Colors.black87
                  : selectedOption.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para células de deadline
class DeadlineCellWidget extends DatabaseCellWidget {
  const DeadlineCellWidget({
    super.key,
    required super.value,
    required super.column,
    super.isEditing,
    super.onChanged,
    super.onStartEdit,
    super.onStopEdit,
  });

  @override
  Widget buildEditWidget(BuildContext context) {
    final currentDate = value?.value is String
        ? DateTime.tryParse(value!.value as String)
        : value?.value as DateTime?;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _pickDate(context, currentDate),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                currentDate != null
                    ? _formatDateTime(currentDate, context)
                    : 'Selecionar data/hora',
                style: TextStyle(
                  color: currentDate != null ? null : Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.clear, size: 18),
          onPressed: () {
            onChanged?.call(null);
            onStopEdit?.call();
          },
          tooltip: 'Limpar',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  @override
  Widget buildDisplayWidget(BuildContext context) {
    final deadline = value?.value is String
        ? DateTime.tryParse(value!.value as String)
        : value?.value as DateTime?;

    return InkWell(
      onTap: () => onStartEdit?.call(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: deadline == null
            ? Consumer(
                builder: (context, ref, child) {
                  final strings = ref.watch(appStringsProvider);
                  return Text(
                    strings.clickToSetDateTime,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  );
                },
              )
            : _buildDeadlineDisplay(context, deadline),
      ),
    );
  }

  Widget _buildDeadlineDisplay(BuildContext context, DateTime deadline) {
    final now = DateTime.now();
    final isOverdue = deadline.isBefore(now);
    final isToday = _isSameDay(deadline, now);
    final isTomorrow = _isSameDay(deadline, now.add(const Duration(days: 1)));

    Color textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    Color backgroundColor = Colors.transparent;

    if (isOverdue) {
      textColor = Colors.red;
      backgroundColor = Colors.red.withOpacity(0.1);
    } else if (isToday) {
      textColor = Colors.orange.shade700;
      backgroundColor = Colors.orange.withOpacity(0.1);
    } else if (isTomorrow) {
      textColor = Colors.blue;
      backgroundColor = Colors.blue.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.warning : Icons.schedule,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDateTime(deadline, context),
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight:
                  isOverdue || isToday ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime? currentDate) async {
    // Usar Consumer para acessar as traduções
    final ref = ProviderScope.containerOf(context);
    final strings = ref.read(appStringsProvider);

    final initialDate = currentDate ?? DateTime.now();

    // Primeiro, selecionar a data
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: strings.selectDate,
      confirmText: strings.next,
      cancelText: strings.cancel,
    );

    if (date != null && context.mounted) {
      // Depois, selecionar a hora
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
        helpText: strings.selectTime,
        confirmText: strings.save,
        cancelText: strings.back,
      );

      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        onChanged?.call(dateTime.toIso8601String());
        onStopEdit?.call();
      } else {
        // Se cancelou na hora, voltar para seleção de data
        if (context.mounted) {
          _pickDate(context, currentDate);
        }
      }
    }
  }

  String _formatDateTime(DateTime dateTime, BuildContext context) {
    // Usar Consumer para acessar as traduções
    final ref = ProviderScope.containerOf(context);
    final strings = ref.read(appStringsProvider);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (dateDay == today) {
      return '${strings.today} $time';
    } else if (dateDay == today.add(const Duration(days: 1))) {
      return '${strings.tomorrow} $time';
    } else if (dateDay == today.subtract(const Duration(days: 1))) {
      return '${strings.yesterday} $time';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} $time';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

/// Factory para criar o widget apropriado para cada tipo de coluna
class DatabaseCellWidgetFactory {
  static DatabaseCellWidget create({
    required DatabaseCellValue? value,
    required DatabaseColumn column,
    bool isEditing = false,
    ValueChanged<dynamic>? onChanged,
    VoidCallback? onStartEdit,
    VoidCallback? onStopEdit,
  }) {
    switch (column.type) {
      case ColumnType.text:
      case ColumnType.email:
      case ColumnType.phone:
        return TextCellWidget(
          value: value,
          column: column,
          isEditing: isEditing,
          onChanged: onChanged,
          onStartEdit: onStartEdit,
          onStopEdit: onStopEdit,
        );

      case ColumnType.number:
        return NumberCellWidget(
          value: value,
          column: column,
          isEditing: isEditing,
          onChanged: onChanged,
          onStartEdit: onStartEdit,
          onStopEdit: onStopEdit,
        );

      case ColumnType.checkbox:
        return CheckboxCellWidget(
          value: value,
          column: column,
          isEditing: isEditing,
          onChanged: onChanged,
          onStartEdit: onStartEdit,
          onStopEdit: onStopEdit,
        );

      case ColumnType.select:
        return SelectCellWidget(
          value: value,
          column: column,
          isEditing: isEditing,
          onChanged: onChanged,
          onStartEdit: onStartEdit,
          onStopEdit: onStopEdit,
        );

      case ColumnType.multiSelect:
        return MultiSelectCellWidget(
          value: value,
          column: column,
          isEditing: isEditing,
          onChanged: onChanged,
          onStartEdit: onStartEdit,
          onStopEdit: onStopEdit,
        );

      case ColumnType.date:
      case ColumnType.datetime:
        return DateCellWidget(
          value: value,
          column: column,
          isEditing: isEditing,
          onChanged: onChanged,
          onStartEdit: onStartEdit,
          onStopEdit: onStopEdit,
        );

      case ColumnType.url:
        return UrlCellWidget(
          value: value,
          column: column,
          isEditing: isEditing,
          onChanged: onChanged,
          onStartEdit: onStartEdit,
          onStopEdit: onStopEdit,
        );

      case ColumnType.rating:
        return RatingCellWidget(
          value: value,
          column: column,
          isEditing: isEditing,
          onChanged: onChanged,
          onStartEdit: onStartEdit,
          onStopEdit: onStopEdit,
        );

      case ColumnType.progress:
        return ProgressCellWidget(
          value: value,
          column: column,
          isEditing: isEditing,
          onChanged: onChanged,
          onStartEdit: onStartEdit,
          onStopEdit: onStopEdit,
        );

      case ColumnType.file:
        return FileCellWidget(
          value: value,
          column: column,
          isEditing: isEditing,
          onChanged: onChanged,
          onStartEdit: onStartEdit,
          onStopEdit: onStopEdit,
        );

      case ColumnType.image:
        return ImageCellWidget(
          value: value,
          column: column,
          isEditing: isEditing,
          onChanged: onChanged,
          onStartEdit: onStartEdit,
          onStopEdit: onStopEdit,
        );

      case ColumnType.note:
        return NoteCellWidget(
          value: value,
          column: column,
          isEditing: isEditing,
          onChanged: onChanged,
          onStartEdit: onStartEdit,
          onStopEdit: onStopEdit,
        );

      case ColumnType.status:
        return StatusCellWidget(
          value: value,
          column: column,
          isEditing: isEditing,
          onChanged: onChanged,
          onStartEdit: onStartEdit,
          onStopEdit: onStopEdit,
        );

      case ColumnType.deadline:
        return DeadlineCellWidget(
          value: value,
          column: column,
          isEditing: isEditing,
          onChanged: onChanged,
          onStartEdit: onStartEdit,
          onStopEdit: onStopEdit,
        );

      // Para tipos não implementados ainda, usar texto padrão
      default:
        return TextCellWidget(
          value: value,
          column: column,
          isEditing: isEditing,
          onChanged: onChanged,
          onStartEdit: onStartEdit,
          onStopEdit: onStopEdit,
        );
    }
  }
}
