import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/backup_provider.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(backupProvider);
    final notifier = ref.read(backupProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup e Restauração'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.backup),
                  label: const Text('Criar Backup'),
                  onPressed: () async {
                    await notifier.createBackup();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Backup criado com sucesso!')),
                    );
                  },
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.restore),
                  label: const Text('Restaurar Backup'),
                  onPressed: () async {
                    // Aqui você pode implementar um file picker simples
                    // ou usar um caminho fixo para teste
                    // Exemplo: await notifier.importBackupFromFile('CAMINHO/backup.json');
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: state.localBackups.isEmpty
                ? const Center(child: Text('Nenhum backup encontrado.'))
                : ListView.builder(
                    itemCount: state.localBackups.length,
                    itemBuilder: (context, idx) {
                      final backup = state.localBackups[idx];
                      return ListTile(
                        leading: const Icon(Icons.save_alt),
                        title: Text('Backup: ${backup.createdAt.toLocal()}'),
                        subtitle: Text('Agenda: ?  Senhas: ?  Documentos: ?'),
                        // Para exibir estatísticas reais, seria necessário ler o arquivo e decodificar
                        trailing: Text('${backup.fileSize ~/ 1024} KB'),
                        onTap: () async {
                          // Implementar restauração deste backup
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
