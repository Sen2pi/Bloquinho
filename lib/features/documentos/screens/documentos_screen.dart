import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../shared/providers/theme_provider.dart';
import '../providers/documentos_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/cartao_credito_list_widget.dart';
import '../widgets/cartao_fidelizacao_list_widget.dart';
import '../widgets/documento_identificacao_list_widget.dart';
import '../widgets/add_cartao_credito_dialog.dart';
import '../widgets/add_cartao_fidelizacao_dialog.dart';
import '../widgets/add_documento_identificacao_dialog.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../models/cartao_credito.dart';
import '../models/cartao_fidelizacao.dart';
import '../models/documento_identificacao.dart';

enum DocumentoTab { cartoesCredito, cartoesFidelizacao, identificacao }

class DocumentosScreen extends ConsumerStatefulWidget {
  const DocumentosScreen({super.key});

  @override
  ConsumerState<DocumentosScreen> createState() => _DocumentosScreenState();
}

class _DocumentosScreenState extends ConsumerState<DocumentosScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DocumentoTab _selectedTab = DocumentoTab.cartoesCredito;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = DocumentoTab.values[_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final documentosState = ref.watch(documentosProvider);
    final stats = ref.watch(documentosStatsProvider);

    return Container(
      color: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      child: Column(
        children: [
          // Header
          _buildHeader(isDarkMode, stats),

          // Tabs
          _buildTabs(isDarkMode),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Cartões de Crédito
                CartaoCreditoListWidget(
                  cartoes: documentosState.cartoesCredito,
                  isLoading: documentosState.isLoading,
                  onAdd: _showAddCartaoCreditoDialog,
                  onEdit: _showEditCartaoCreditoDialog,
                  onDelete: _showDeleteCartaoCreditoDialog,
                ),

                // Cartões de Fidelização
                CartaoFidelizacaoListWidget(
                  cartoes: documentosState.cartoesFidelizacao,
                  isLoading: documentosState.isLoading,
                  onAdd: _showAddCartaoFidelizacaoDialog,
                  onEdit: _showEditCartaoFidelizacaoDialog,
                  onDelete: _showDeleteCartaoFidelizacaoDialog,
                ),

                // Documentos de Identificação
                DocumentoIdentificacaoListWidget(
                  documentos: documentosState.documentosIdentificacao,
                  isLoading: documentosState.isLoading,
                  onAdd: _showAddDocumentoIdentificacaoDialog,
                  onEdit: _showEditDocumentoIdentificacaoDialog,
                  onDelete: _showDeleteDocumentoIdentificacaoDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode, Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.files(),
                size: 24,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Documentos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              if (stats['documentosVencidos'] > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIcons.warning(),
                        size: 16,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${stats['documentosVencidos']} vencidos',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Estatísticas
          Row(
            children: [
              _buildStatCard(
                'Total',
                '${stats['totalDocumentos']}',
                PhosphorIcons.files(),
                isDarkMode,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Crédito',
                '${stats['totalCartoesCredito']}',
                PhosphorIcons.creditCard(),
                isDarkMode,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Fidelização',
                '${stats['totalCartoesFidelizacao']}',
                PhosphorIcons.star(),
                isDarkMode,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Identificação',
                '${stats['totalDocumentosIdentificacao']}',
                PhosphorIcons.identificationCard(),
                isDarkMode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, bool isDarkMode) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: AppColors.primary,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.creditCard(), size: 16),
                const SizedBox(width: 8),
                const Text('Crédito/Débito'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.star(), size: 16),
                const SizedBox(width: 8),
                const Text('Fidelização'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.identificationCard(), size: 16),
                const SizedBox(width: 8),
                const Text('Identificação'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== CARTÕES DE CRÉDITO =====

  void _showAddCartaoCreditoDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCartaoCreditoDialog(
        onAdd: (cartao) {
          ref.read(documentosProvider.notifier).addCartaoCredito(cartao);
        },
      ),
    );
  }

  void _showEditCartaoCreditoDialog(CartaoCredito cartao) {
    showDialog(
      context: context,
      builder: (context) => AddCartaoCreditoDialog(
        cartao: cartao,
        onAdd: (cartaoEditado) {
          ref
              .read(documentosProvider.notifier)
              .updateCartaoCredito(cartaoEditado);
        },
      ),
    );
  }

  void _showDeleteCartaoCreditoDialog(String id) {
    final cartao = ref
        .read(documentosProvider)
        .cartoesCredito
        .firstWhere((c) => c.id == id);
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: 'Excluir Cartão',
        message: 'Tem certeza que deseja excluir este cartão?',
        itemName: '${cartao.nomeBandeira} - ${cartao.numeroMascarado}',
        onConfirm: () {
          ref.read(documentosProvider.notifier).removeCartaoCredito(id);
        },
      ),
    );
  }

  // ===== CARTÕES DE FIDELIZAÇÃO =====

  void _showAddCartaoFidelizacaoDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCartaoFidelizacaoDialog(
        onAdd: (cartao) {
          ref.read(documentosProvider.notifier).addCartaoFidelizacao(cartao);
        },
      ),
    );
  }

  void _showEditCartaoFidelizacaoDialog(CartaoFidelizacao cartao) {
    showDialog(
      context: context,
      builder: (context) => AddCartaoFidelizacaoDialog(
        cartao: cartao,
        onAdd: (cartaoEditado) {
          ref
              .read(documentosProvider.notifier)
              .updateCartaoFidelizacao(cartaoEditado);
        },
      ),
    );
  }

  void _showDeleteCartaoFidelizacaoDialog(String id) {
    final cartao = ref
        .read(documentosProvider)
        .cartoesFidelizacao
        .firstWhere((c) => c.id == id);
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: 'Excluir Cartão de Fidelização',
        message: 'Tem certeza que deseja excluir este cartão de fidelização?',
        itemName: '${cartao.nome} - ${cartao.empresa}',
        onConfirm: () {
          ref.read(documentosProvider.notifier).removeCartaoFidelizacao(id);
        },
      ),
    );
  }

  // ===== DOCUMENTOS DE IDENTIFICAÇÃO =====

  void _showAddDocumentoIdentificacaoDialog() {
    showDialog(
      context: context,
      builder: (context) => AddDocumentoIdentificacaoDialog(
        onAdd: (documento) {
          ref
              .read(documentosProvider.notifier)
              .addDocumentoIdentificacao(documento);
        },
      ),
    );
  }

  void _showEditDocumentoIdentificacaoDialog(DocumentoIdentificacao documento) {
    showDialog(
      context: context,
      builder: (context) => AddDocumentoIdentificacaoDialog(
        documento: documento,
        onAdd: (documentoEditado) {
          ref
              .read(documentosProvider.notifier)
              .updateDocumentoIdentificacao(documentoEditado);
        },
      ),
    );
  }

  void _showDeleteDocumentoIdentificacaoDialog(String id) {
    final documento = ref
        .read(documentosProvider)
        .documentosIdentificacao
        .firstWhere((d) => d.id == id);
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: 'Excluir Documento',
        message:
            'Tem certeza que deseja excluir este documento de identificação?',
        itemName: '${documento.nomeTipo} - ${documento.numeroFormatado}',
        onConfirm: () {
          ref
              .read(documentosProvider.notifier)
              .removeDocumentoIdentificacao(id);
        },
      ),
    );
  }
}
