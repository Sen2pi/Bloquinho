# 🚀 Guia de Configuração do Hugging Face para IA

## 📋 Resumo

Este guia explica como configurar o Hugging Face para usar a funcionalidade de IA no Bloquinho.

## 🎯 O que é o Hugging Face?

O **Hugging Face** é uma plataforma gratuita que oferece:
- **Modelos de IA** pré-treinados
- **APIs gratuitas** para inferência
- **Comunidade** de desenvolvedores de IA
- **Ferramentas** para machine learning

## 🔧 Passo a Passo

### 1. **Criar Conta Gratuita**

1. Acesse: https://huggingface.co/
2. Clique em **"Sign Up"**
3. Preencha:
   - **Username**: Seu nome de usuário
   - **Email**: Seu email
   - **Password**: Senha segura
4. Confirme seu email

### 2. **Obter Token de Acesso**

1. Faça login na sua conta
2. Clique no **avatar** no canto superior direito
3. Vá em **"Settings"**
4. No menu lateral, clique em **"Access Tokens"**
5. Clique em **"New token"**
6. Configure:
   - **Name**: `bloquinho-ai-token`
   - **Role**: `Read` (suficiente para inferência)
7. Clique em **"Generate token"**
8. **Copie o token** (algo como `hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`)

### 3. **Configurar no Projeto**

1. Abra o arquivo: `lib/core/services/ai_config.dart`
2. Substitua `'SEU_TOKEN_AQUI'` pelo seu token real:

```dart
static const String huggingFaceToken = 'hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
```

### 4. **Testar a Configuração**

1. Execute o projeto: `flutter run -d windows`
2. Digite `/ia` no editor
3. Descreva o conteúdo desejado
4. Clique em "Gerar Conteúdo"

## 🔍 Verificação

### ✅ Se tudo estiver correto:
- O conteúdo será gerado automaticamente
- Você verá uma página estruturada em markdown
- O sistema funcionará sem erros

### ❌ Se houver problemas:
- Verifique se o token está correto
- Confirme se a conta está ativa
- Teste a conexão com a internet

## 🛠️ Modelo Utilizado

O Bloquinho usa o modelo **`microsoft/DialoGPT-medium`**:
- **Gratuito**: Sem custos
- **Confiável**: Desenvolvido pela Microsoft
- **Português**: Suporte a múltiplos idiomas
- **Estável**: API bem mantida

## 📊 Limites Gratuitos

- **Requisições**: Ilimitadas (com rate limiting)
- **Modelos**: Acesso a milhares de modelos
- **Tamanho**: Até 500 tokens por requisição
- **Velocidade**: Depende da demanda do servidor

## 🔒 Segurança

- **Token**: Mantenha seu token seguro
- **Não compartilhe**: Não exponha o token publicamente
- **Revogação**: Você pode revogar tokens a qualquer momento
- **Logs**: Hugging Face mantém logs de uso

## 🚨 Troubleshooting

### Erro 401 (Unauthorized)
- Token incorreto ou expirado
- Verifique se copiou o token completo

### Erro 429 (Too Many Requests)
- Rate limiting ativo
- Aguarde alguns minutos e tente novamente

### Erro 503 (Service Unavailable)
- Servidor temporariamente indisponível
- Tente novamente em alguns minutos

### Sem Conteúdo Gerado
- Verifique a conexão com a internet
- Teste com prompts mais simples
- Use o fallback local se necessário

## 📞 Suporte

- **Documentação**: https://huggingface.co/docs
- **Comunidade**: https://huggingface.co/community
- **Discord**: https://huggingface.co/join/discord
- **GitHub**: https://github.com/huggingface

## 🎉 Pronto!

Após seguir este guia, você terá:
- ✅ Conta gratuita no Hugging Face
- ✅ Token de acesso configurado
- ✅ IA funcionando no Bloquinho
- ✅ Geração automática de conteúdo

**Agora você pode usar `/ia` para gerar conteúdo automaticamente!** 🤖✨ 