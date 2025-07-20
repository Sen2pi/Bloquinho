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
import '../models/universidade_page_model.dart';
import '../providers/universidade_provider.dart';
import '../widgets/add_page_dialog.dart';
import '../widgets/universidade_page_editor_widget.dart';

class UniversidadePageTreeWidget extends ConsumerWidget {
  final TipoContextoPage? filtroTipo;
  final String? contextoId;

  const UniversidadePageTreeWidget({
    super.key,
    this.filtroTipo,
    this.contextoId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagesAsync = ref.watch(universidadePagesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Páginas e Documentos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddPageDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Nova Página'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: pagesAsync.when(
                data: (pages) {
                  final filteredPages = _filterPages(pages);
                  final rootPages = filteredPages.where((p) => p.isRoot).toList();
                  
                  if (rootPages.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  
                  return ListView.builder(
                    itemCount: rootPages.length,
                    itemBuilder: (context, index) {
                      return _buildPageNode(context, ref, rootPages[index], filteredPages, 0);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Erro ao carregar páginas: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<UniversidadePageModel> _filterPages(List<UniversidadePageModel> pages) {
    if (filtroTipo == null && contextoId == null) return pages;
    
    return pages.where((page) {
      if (filtroTipo != null && page.tipoContexto != filtroTipo) return false;
      if (contextoId != null && page.contextoId != contextoId) return false;
      return true;
    }).toList();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma página encontrada',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Crie sua primeira página para começar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageNode(
    BuildContext context,
    WidgetRef ref,
    UniversidadePageModel page,
    List<UniversidadePageModel> allPages,
    int depth,
  ) {
    final children = allPages.where((p) => p.parentId == page.id).toList();
    final hasChildren = children.isNotEmpty;

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: depth * 20.0),
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasChildren)
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  )
                else
                  SizedBox(width: hasChildren ? 24 : 0),
                Icon(
                  page.icon != null ? IconData(int.parse(page.icon!), fontFamily: 'MaterialIcons') : Icons.description,
                  color: _getContextoColor(page.tipoContexto),
                ),
              ],
            ),
            title: Text(
              page.titulo,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: depth == 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(page.contextoNome),
                if (page.tipoModulo != null)
                  Text(
                    page.tipoModulo!.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                if (page.arquivos.isNotEmpty)
                  Text(
                    '${page.arquivos.length} arquivo(s)',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[600],
                    ),
                  ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'add_child':
                    _showAddPageDialog(context, ref, parentId: page.id);
                    break;
                  case 'add_module':
                    _showAddModuleDialog(context, ref, page.id);
                    break;
                  case 'manage_files':
                    _showFileManagerDialog(context, ref, page);
                    break;
                  case 'edit':
                    _showEditPageDialog(context, ref, page);
                    break;
                  case 'delete':
                    _showDeleteConfirmation(context, ref, page);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'add_child',
                  child: Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text('Adicionar subpágina'),
                    ],
                  ),
                ),
                if (page.tipoContexto == TipoContextoPage.unidadeCurricular)
                  const PopupMenuItem(
                    value: 'add_module',
                    child: Row(
                      children: [
                        Icon(Icons.library_books),
                        SizedBox(width: 8),
                        Text('Adicionar módulo'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'manage_files',
                  child: Row(
                    children: [
                      Icon(Icons.folder),
                      SizedBox(width: 8),
                      Text('Gerenciar arquivos'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Excluir', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => _openPageEditor(context, page),
          ),
        ),
        ...children.map((child) => _buildPageNode(context, ref, child, allPages, depth + 1)),
      ],
    );
  }

  Color _getContextoColor(TipoContextoPage tipo) {
    switch (tipo) {
      case TipoContextoPage.universidade:
        return Colors.blue;
      case TipoContextoPage.curso:
        return Colors.green;
      case TipoContextoPage.unidadeCurricular:
        return Colors.orange;
      case TipoContextoPage.modulo:
        return Colors.teal;
      case TipoContextoPage.avaliacao:
        return Colors.purple;
      case TipoContextoPage.geral:
        return Colors.grey;
    }
  }

  void _showAddPageDialog(BuildContext context, WidgetRef ref, {String? parentId}) {
    showDialog(
      context: context,
      builder: (context) => AddPageDialog(
        parentId: parentId,
        tipoContexto: filtroTipo,
        contextoId: contextoId,
        onSave: (page) async {
          final service = ref.read(universidadeServiceProvider);
          await service.savePage(page);
          ref.invalidate(universidadePagesProvider);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Página criada com sucesso!')),
            );
          }
        },
      ),
    );
  }

  void _showEditPageDialog(BuildContext context, WidgetRef ref, UniversidadePageModel page) {
    showDialog(
      context: context,
      builder: (context) => AddPageDialog(
        page: page,
        onSave: (updatedPage) async {
          final service = ref.read(universidadeServiceProvider);
          await service.savePage(updatedPage);
          ref.invalidate(universidadePagesProvider);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Página atualizada com sucesso!')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, UniversidadePageModel page) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir a página "${page.titulo}"?\n\nEsta ação também excluirá todas as subpáginas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final service = ref.read(universidadeServiceProvider);
              await service.deletePage(page.id);
              ref.invalidate(universidadePagesProvider);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Página excluída com sucesso!')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showAddModuleDialog(BuildContext context, WidgetRef ref, String unidadeId) {
    final titleController = TextEditingController();
    TipoModulo selectedTipo = TipoModulo.teorica;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Módulo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nome do Módulo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TipoModulo>(
              value: selectedTipo,
              decoration: const InputDecoration(
                labelText: 'Tipo de Módulo',
                border: OutlineInputBorder(),
              ),
              items: TipoModulo.values
                  .map((tipo) => DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo.displayName),
                      ))
                  .toList(),
              onChanged: (value) => selectedTipo = value!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                final modulePage = UniversidadePageModel.create(
                  titulo: title,
                  parentId: unidadeId,
                  tipoContexto: TipoContextoPage.modulo,
                  contextoId: unidadeId,
                  tipoModulo: selectedTipo,
                );
                
                final service = ref.read(universidadeServiceProvider);
                await service.savePage(modulePage);
                ref.invalidate(universidadePagesProvider);
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Módulo criado com sucesso!')),
                  );
                }
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showFileManagerDialog(BuildContext context, WidgetRef ref, UniversidadePageModel page) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Arquivos - ${page.titulo}'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${page.arquivos.length} arquivo(s)'),
                  ElevatedButton.icon(
                    onPressed: () => _showAddFileDialog(context, ref, page),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Adicionar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: page.arquivos.isEmpty
                    ? const Center(
                        child: Text('Nenhum arquivo adicionado'),
                      )
                    : ListView.builder(
                        itemCount: page.arquivos.length,
                        itemBuilder: (context, index) {
                          final arquivo = page.arquivos[index];
                          return ListTile(
                            leading: _getFileIcon(arquivo.tipo),
                            title: Text(arquivo.nome),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(arquivo.tamanhoFormatado),
                                Text(
                                  'Por: ${arquivo.uploadedBy}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (action) {
                                if (action == 'delete') {
                                  _deleteFile(context, ref, page, arquivo.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Excluir', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showAddFileDialog(BuildContext context, WidgetRef ref, UniversidadePageModel page) {
    final nomeController = TextEditingController();
    final descricaoController = TextEditingController();
    String tipoArquivo = 'pdf';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Arquivo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do arquivo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: tipoArquivo,
              decoration: const InputDecoration(
                labelText: 'Tipo de arquivo',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                DropdownMenuItem(value: 'doc', child: Text('Word Document')),
                DropdownMenuItem(value: 'ppt', child: Text('PowerPoint')),
                DropdownMenuItem(value: 'xls', child: Text('Excel')),
                DropdownMenuItem(value: 'txt', child: Text('Texto')),
                DropdownMenuItem(value: 'zip', child: Text('Arquivo comprimido')),
              ],
              onChanged: (value) => tipoArquivo = value!,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nome = nomeController.text.trim();
              if (nome.isNotEmpty) {
                final arquivo = ArquivoAnexo.create(
                  nome: nome,
                  tipo: tipoArquivo,
                  caminho: '/files/${page.id}/$nome',
                  tamanho: 1024,
                  descricao: descricaoController.text.isEmpty 
                    ? null 
                    : descricaoController.text,
                  uploadedBy: 'Professor',
                );

                final updatedPage = page.copyWith(
                  arquivos: [...page.arquivos, arquivo],
                );

                final service = ref.read(universidadeServiceProvider);
                await service.savePage(updatedPage);
                ref.invalidate(universidadePagesProvider);

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Arquivo adicionado com sucesso!')),
                  );
                }
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _deleteFile(BuildContext context, WidgetRef ref, UniversidadePageModel page, String fileId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este arquivo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final updatedFiles = page.arquivos.where((f) => f.id != fileId).toList();
              final updatedPage = page.copyWith(arquivos: updatedFiles);

              final service = ref.read(universidadeServiceProvider);
              await service.savePage(updatedPage);
              ref.invalidate(universidadePagesProvider);

              if (context.mounted) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                _showFileManagerDialog(context, ref, updatedPage);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Widget _getFileIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'doc':
      case 'docx':
        return const Icon(Icons.description, color: Colors.blue);
      case 'ppt':
      case 'pptx':
        return const Icon(Icons.slideshow, color: Colors.orange);
      case 'xls':
      case 'xlsx':
        return const Icon(Icons.grid_on, color: Colors.green);
      case 'txt':
        return const Icon(Icons.text_snippet, color: Colors.grey);
      case 'zip':
      case 'rar':
        return const Icon(Icons.archive, color: Colors.purple);
      default:
        return const Icon(Icons.attach_file, color: Colors.grey);
    }
  }

  void _openPageEditor(BuildContext context, UniversidadePageModel page) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: UniversidadePageEditorWidget(page: page),
        ),
      ),
    );
  }
}