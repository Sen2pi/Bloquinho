/*
 * Teste simples para verificar a exportação PDF
 */

import 'dart:io';
import '../lib/core/services/enhanced_pdf_export_service.dart';

void main() async {
  print('🧪 Testando exportação PDF com EnhancedPdfExportService...');
  
  // Ler arquivo de teste markdown
  final testFile = File('test/enhanced_pdf_test.md');
  if (!await testFile.exists()) {
    print('❌ Arquivo de teste não encontrado: ${testFile.path}');
    return;
  }
  
  final markdown = await testFile.readAsString();
  print('📄 Conteúdo do arquivo de teste carregado (${markdown.length} caracteres)');
  
  // Instanciar serviço de PDF
  final pdfService = EnhancedPdfExportService();
  
  try {
    print('📝 Exportando markdown para PDF...');
    final filePath = await pdfService.exportMarkdownAsPdf(
      markdown: markdown,
      title: 'Teste_Formatacao_Avancada',
      author: 'Sistema de Teste',
      subject: 'Teste de sincronização entre preview e PDF',
    );
    
    if (filePath != null) {
      final file = File(filePath);
      if (await file.exists()) {
        print('✅ PDF gerado com sucesso!');
        print('📍 Localização: $filePath');
        print('📊 Tamanho do arquivo: ${await file.length()} bytes');
        
        // Abrir arquivo automaticamente
        await pdfService.openExportedFile(filePath);
        print('🚀 Arquivo aberto para visualização');
      } else {
        print('❌ PDF não foi criado no local esperado');
      }
    } else {
      print('❌ Falha na geração do PDF');
    }
  } catch (e) {
    print('💥 Erro durante exportação: $e');
  }
}