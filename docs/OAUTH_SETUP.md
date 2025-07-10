# Configuração OAuth2 - Google Drive e OneDrive

Este guia mostra como configurar as credenciais OAuth2 reais para permitir que os usuários usem seus próprios Google Drive e OneDrive.

## 🟢 Configuração Google Drive

### Passo 1: Criar Projeto no Google Cloud Console

1. Acesse [Google Cloud Console](https://console.cloud.google.com/)
2. Clique em **"Select a project"** → **"NEW PROJECT"**
3. Nome do projeto: `Bloquinho App`
4. Clique **"CREATE"**

### Passo 2: Ativar APIs

1. No menu lateral, vá em **"APIs & Services"** → **"Library"**
2. Procure e ative as seguintes APIs:
   - **Google Drive API**
   - **Google+ API** (para informações do usuário)

### Passo 3: Configurar OAuth Consent Screen

1. Vá em **"APIs & Services"** → **"OAuth consent screen"**
2. Escolha **"External"** (para uso público)
3. Preencha os campos obrigatórios:
   - **App name**: `Bloquinho`
   - **User support email**: seu email
   - **Developer contact email**: seu email
4. Clique **"SAVE AND CONTINUE"**

### Passo 4: Adicionar Scopes

1. Clique **"ADD OR REMOVE SCOPES"**
2. Adicione os seguintes scopes:
   ```
   https://www.googleapis.com/auth/drive.file
   https://www.googleapis.com/auth/userinfo.email
   https://www.googleapis.com/auth/userinfo.profile
   ```
3. Clique **"UPDATE"** → **"SAVE AND CONTINUE"**

### Passo 5: Criar Credenciais OAuth2

1. Vá em **"APIs & Services"** → **"Credentials"**
2. Clique **"+ CREATE CREDENTIALS"** → **"OAuth 2.0 Client IDs"**
3. **Application type**: Escolha baseado na sua plataforma:
   - **Web application** (para testes/desenvolvimento)
   - **Desktop application** (para aplicação desktop)
   - **Android** (para Android)
   - **iOS** (para iOS)

4. **Authorized redirect URIs** (para Web/Desktop):
   ```
   http://localhost:*/oauth/callback
   com.bloquinho.app://oauth/callback
   ```
   
   **Nota**: Use `http://localhost:*/oauth/callback` ou adicione múltiplas portas:
   ```
   http://localhost:8080/oauth/callback
   http://localhost:8081/oauth/callback
   http://localhost:8082/oauth/callback
   http://localhost:3000/oauth/callback
   http://localhost:3001/oauth/callback
   ```

5. Clique **"CREATE"**
6. **Copie o Client ID e Client Secret** gerados
   PC:
   ID : 559954382422-7d1lo3ucamjtu4qfghm0ho4vcrf1eis6.apps.googleusercontent.com 
   SECRET : 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
   WEB:  
   ID : 559954382422-tssorad2ncrls4q3o5q6ovf4ru4rg5e4.apps.googleusercontent.com 
   SECRET: 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

## 🔵 Configuração OneDrive (Microsoft)

### Passo 1: Registrar Aplicação no Azure Portal

1. Acesse [Azure Portal](https://portal.azure.com/)
2. Vá em **"App registrations"** → **"New registration"**
3. Preencha:
   - **Name**: `Bloquinho`
   - **Supported account types**: `Accounts in any organizational directory and personal Microsoft accounts`
   - **Redirect URI**: 
     - Platform: `Public client/native`
     - URI: `com.bloquinho.app://oauth/callback`

4. Clique **"Register"**

### Passo 2: Configurar Permissões da API

1. Na página da aplicação, vá em **"API permissions"**
2. Clique **"Add a permission"** → **"Microsoft Graph"**
3. Escolha **"Delegated permissions"**
4. Adicione as permissões:
   ```
   Files.ReadWrite
   User.Read
   offline_access
   ```
5. Clique **"Add permissions"**

### Passo 3: Obter Client ID
 ID : 341ab3c5-0a36-41dc-b27c-80c56fa37719
1. Vá em **"Overview"**
2. **Copie o "Application (client) ID"**

### Passo 4: Configurar Autenticação

1. Vá em **"Authentication"**
2. Em **"Advanced settings"**, certifique-se que:
   - **Allow public client flows**: `Yes`
3. Adicione URIs de redirecionamento:
   ```
   http://localhost:8080/oauth/callback
   http://localhost:8081/oauth/callback
   http://localhost:8082/oauth/callback
   http://localhost:3000/oauth/callback
   http://localhost:3001/oauth/callback
   com.bloquinho.app://oauth/callback
   ```
   
   **Nota**: Adicione múltiplas portas pois o sistema usa portas dinâmicas disponíveis.

## 🔧 Configurar no Código

Agora atualize o arquivo `lib/core/services/oauth2_service.dart`:

```dart
// Configurações OAuth2 para Google Drive
static const String _googleClientId = 'SEU_GOOGLE_CLIENT_ID_AQUI';
static const String _googleClientSecret = 'SEU_GOOGLE_CLIENT_SECRET_AQUI'; // Apenas para Desktop/Web

// Configurações OAuth2 para Microsoft OneDrive  
static const String _microsoftClientId = 'SEU_MICROSOFT_CLIENT_ID_AQUI';
// Microsoft não usa client secret para apps públicos
```

## 📱 Configuração por Plataforma

### Para Android

1. **Google Drive**: Adicione o SHA-1 fingerprint no Google Cloud Console
2. **OneDrive**: Configure o package name no Azure Portal

### Para iOS

1. **Google Drive**: Configure o Bundle ID no Google Cloud Console
2. **OneDrive**: Configure o Bundle ID no Azure Portal

### Para Web

1. **Google Drive**: Adicione o domínio nas "Authorized JavaScript origins"
2. **OneDrive**: Adicione o domínio nos redirect URIs

## 🚀 Testando

Para testar se está funcionando:

1. Execute o app
2. Vá para o onboarding
3. Selecione Google Drive ou OneDrive
4. Deve abrir o navegador para autenticação
5. Após autorizar, deve retornar ao app conectado

## 🔒 Segurança

### Boas Práticas:
1. **Nunca commite** Client IDs/Secrets no código público
2. Use **variáveis de ambiente** para credenciais
3. Configure **domínios autorizados** apenas os necessários
4. Revise **permissions** regularmente

### Para Produção:
1. Solicite **verificação** da aplicação no Google
2. Configure **políticas de privacidade**
3. Implemente **refresh token** automático
4. Adicione **logging** para auditoria

## 🆘 Solução de Problemas

### Erro "invalid_client"
- Verifique se o Client ID está correto
- Confirme se a aplicação está ativa

### Erro "redirect_uri_mismatch"
- Verifique se os redirect URIs estão configurados corretamente
- Confirme se estão exatamente iguais (case sensitive)

### Erro "access_denied"
- Usuário negou permissões
- Verifique se as permissões solicitadas são necessárias

### Erro "invalid_scope"
- Verifique se os scopes estão corretos
- Confirme se as APIs estão ativadas

## 📞 Suporte

Se encontrar problemas:

1. Verifique os logs do console
2. Teste com usuários diferentes
3. Confirme configurações nos portais
4. Documente erros específicos para debug

---

**Próximo passo**: Após configurar as credenciais, teste a integração e documente qualquer problema encontrado. 