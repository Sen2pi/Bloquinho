import os
import sys
from pathlib import Path

def add_copyright_header():
    """
    Adiciona header de copyright em todos os arquivos de código
    """
    
    # Header de copyright personalizado
    header_text = '''/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */'''
    
    # Pasta atual (ou especifique um caminho)
    folder_path = "."
    
    # Extensões de arquivo para processar
    extensions = ['.dart', '.js', '.ts', '.java', '.cpp', '.c', '.h', '.cs', '.php', '.py']
    
    # Contadores
    files_processed = 0
    files_skipped = 0
    files_error = 0
    
    print(f"🔍 Processando arquivos em: {os.path.abspath(folder_path)}")
    print(f"📝 Extensões: {', '.join(extensions)}")
    print("-" * 60)
    
    for root, dirs, files in os.walk(folder_path):
        # Ignorar pastas específicas
        dirs[:] = [d for d in dirs if d not in ['.git', 'node_modules', 'build', '.dart_tool', 'dist']]
        
        for file in files:
            file_path = os.path.join(root, file)
            file_extension = os.path.splitext(file)[1].lower()
            
            # Processar apenas arquivos com extensões específicas
            if file_extension in extensions:
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    # Verificar se o header já existe
                    if "Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos" in content:
                        print(f"⏭️  Já possui header: {file_path}")
                        files_skipped += 1
                        continue
                    
                    # Adicionar header no início do arquivo
                    new_content = header_text + "\n\n" + content
                    
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    
                    print(f"✅ Header adicionado: {file_path}")
                    files_processed += 1
                    
                except Exception as e:
                    print(f"❌ Erro ao processar {file_path}: {e}")
                    files_error += 1
    
    print("-" * 60)
    print(f"📊 Resumo:")
    print(f"   ✅ Arquivos processados: {files_processed}")
    print(f"   ⏭️  Arquivos ignorados: {files_skipped}")
    print(f"   ❌ Arquivos com erro: {files_error}")
    print(f"   📁 Total analisado: {files_processed + files_skipped + files_error}")

if __name__ == "__main__":
    print("🚀 Iniciando processo de adição de headers...")
    add_copyright_header()
    print("✨ Processo concluído!")
