# 🚀 Configuração Rápida OAuth2

Este guia rápido mostra como configurar suas credenciais OAuth2 para usar seu próprio Google Drive e OneDrive.

## 📋 Passos Rápidos

### 1. Configure as Credenciais

```bash
# Copie o arquivo de exemplo
cp oauth_config.json.example oauth_config.json
```

### 2. Configure Google Drive

1. Acesse [Google Cloud Console](https://console.cloud.google.com/)
2. Crie novo projeto: `Bloquinho App`
3. Ative APIs: `Google Drive API` e `Google+ API`
4. Configure OAuth consent screen (External)
5. Crie credenciais OAuth 2.0
6. Copie o `Client ID` e `Client Secret`

### 3. Configure OneDrive

1. Acesse [Azure Portal](https://portal.azure.com/)
2. Vá em `App registrations` → `New registration`
3. Nome: `Bloquinho`
4. Tipo: `Personal Microsoft accounts`
5. Redirect URIs: Adicione múltiplas portas:
   - `http://localhost:8080/oauth/callback`
   - `http://localhost:8081/oauth/callback`
   - `http://localhost:8082/oauth/callback`
   - `http://localhost:3000/oauth/callback`
6. Adicione permissões: `Files.ReadWrite`, `User.Read`, `offline_access`
7. Copie o `Application (client) ID`

### 4. Atualize o Arquivo de Configuração

Edite `oauth_config.json`:

```json
{
  "google_client_id": "cole_seu_google_client_id_aqui",
  "google_client_secret": "cole_seu_google_client_secret_aqui",
  "microsoft_client_id": "cole_seu_microsoft_client_id_aqui"
}
```

### 5. Teste a Configuração

```bash
flutter run
```

1. Vá ao onboarding
2. Selecione Google Drive ou OneDrive
3. Deve abrir o navegador para autenticação
4. Após autorizar, retorna ao app conectado

## ⚠️ Problemas Comuns

### Google Drive

**Erro 400: invalid_request**
- ✅ Verifique se o Client ID está correto
- ✅ Confirme se as APIs estão ativadas
- ✅ Configure o OAuth consent screen

**Erro: redirect_uri_mismatch**
- ✅ Adicione múltiplas portas aos redirect URIs:
  - `http://localhost:8080/oauth/callback`
  - `http://localhost:8081/oauth/callback`
  - `http://localhost:8082/oauth/callback`
  - `http://localhost:3000/oauth/callback`

### OneDrive

**Erro: unauthorized_client**
- ✅ Verifique se o Client ID está correto
- ✅ Configure "Allow public client flows" = Yes
- ✅ Adicione as permissões necessárias

**Erro: invalid_client**
- ✅ Confirme se a aplicação foi registrada corretamente
- ✅ Verifique se o redirect URI está configurado

## 🔧 Configuração Avançada

Para configuração detalhada, consulte: [docs/OAUTH_SETUP.md](docs/OAUTH_SETUP.md)

## 📞 Suporte

Se ainda tiver problemas:

1. Verifique se `oauth_config.json` existe e tem as credenciais corretas
2. Confirme se as APIs estão ativadas nos consoles
3. Teste com um usuário diferente
4. Verifique os logs do console para erros específicos

---

**⏰ Tempo estimado**: 15-20 minutos para configurar ambos os serviços 