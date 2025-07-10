#!/bin/bash

# Script de configuração OAuth2 para Bloquinho
# Este script facilita a configuração inicial das credenciais OAuth2

echo "🚀 Configuração OAuth2 - Bloquinho"
echo "=================================="
echo ""

# Verifica se o arquivo de exemplo existe
if [ ! -f "oauth_config.json.example" ]; then
    echo "❌ Erro: arquivo oauth_config.json.example não encontrado"
    exit 1
fi

# Copia o arquivo de exemplo se não existir
if [ ! -f "oauth_config.json" ]; then
    echo "📄 Copiando arquivo de configuração..."
    cp oauth_config.json.example oauth_config.json
    echo "✅ Arquivo oauth_config.json criado"
else
    echo "ℹ️  Arquivo oauth_config.json já existe"
fi

echo ""
echo "📋 Próximos passos:"
echo ""
echo "1. 🟢 Configure Google Drive:"
echo "   - Acesse: https://console.cloud.google.com/"
echo "   - Crie projeto: 'Bloquinho App'"
echo "   - Ative APIs: Google Drive API e Google+ API"
echo "   - Configure OAuth consent screen (External)"
echo "   - Crie credenciais OAuth 2.0"
echo "   - Copie Client ID e Client Secret"
echo ""
echo "2. 🔵 Configure OneDrive:"
echo "   - Acesse: https://portal.azure.com/"
echo "   - Vá em 'App registrations' → 'New registration'"
echo "   - Nome: 'Bloquinho'"
echo "   - Tipo: 'Personal Microsoft accounts'"
echo "   - Redirect URI: 'http://localhost:8080/oauth/callback'"
echo "   - Adicione permissões: Files.ReadWrite, User.Read, offline_access"
echo "   - Copie Application (client) ID"
echo ""
echo "3. ✏️  Edite o arquivo oauth_config.json:"
echo "   - Substitua YOUR_GOOGLE_CLIENT_ID_HERE"
echo "   - Substitua YOUR_GOOGLE_CLIENT_SECRET_HERE"
echo "   - Substitua YOUR_MICROSOFT_CLIENT_ID_HERE"
echo ""
echo "4. 🧪 Teste a configuração:"
echo "   - Execute: flutter run"
echo "   - Vá ao onboarding"
echo "   - Teste Google Drive ou OneDrive"
echo ""
echo "📚 Para guia detalhado, consulte:"
echo "   - SETUP_OAUTH.md (guia rápido)"
echo "   - docs/OAUTH_SETUP.md (guia completo)"
echo ""
echo "⚠️  IMPORTANTE: Nunca commite o arquivo oauth_config.json!"
echo "   O arquivo já está no .gitignore para sua proteção."
echo ""
echo "🎉 Configuração inicial concluída!"
echo "   Agora configure suas credenciais nos consoles do Google e Microsoft." 