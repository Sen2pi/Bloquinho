import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/providers/language_provider.dart';

// Placeholder para futuro diálogo de importação personalizado
class BackupImportDialog extends ConsumerWidget {
  const BackupImportDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    return AlertDialog(
      title: Text(strings.importBackup),
      content: Text(strings.featureInDevelopment),
    );
  }
}
