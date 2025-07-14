import os
import re

def extract_log_info(md_content):
    date_pattern = r"\*\*Data:\*\* ([\d-]+)"
    subject_pattern = r"# (LOG\d+) - (.+)"
    status_pattern = r"\*\*Status:\*\* (.+)"

    date_match = re.search(date_pattern, md_content)
    subject_match = re.search(subject_pattern, md_content)
    status_match = re.search(status_pattern, md_content)

    date = date_match.group(1) if date_match else "Data não encontrada"
    subject = subject_match.group(2) if subject_match else "Assunto não encontrado"
    status = status_match.group(1) if status_match else "Status não encontrado"

    return date, subject, status

def create_log_summary_from_folder(folder_path):
    log_entries = []
    
    for filename in os.listdir(folder_path):
        if filename.endswith('.md'):
            filepath = os.path.join(folder_path, filename)
            with open(filepath, 'r', encoding='utf-8') as file:
                content = file.read()
                date, subject, status = extract_log_info(content)
                log_entries.append(f"{date} - {subject} - {status}")

    # Ordenar por data (opcional)
    log_entries.sort()

    # Escrever para logs.log
    log_file_path = os.path.join(folder_path, 'logs.log')
    with open(log_file_path, 'w', encoding='utf-8') as log_file:
        for entry in log_entries:
            log_file.write(entry + '\n')

    print(f"Ficheiro logs.log criado em: {log_file_path}")
    print(f"Processados {len(log_entries)} ficheiros markdown")
    return log_file_path

# Usar o script
if __name__ == "__main__":
    folder_path = input("Insira o caminho da pasta com os ficheiros markdown: ")
    create_log_summary_from_folder(folder_path)
