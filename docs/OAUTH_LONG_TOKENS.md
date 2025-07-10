# 🔐 Configuração de Tokens OAuth2 de Longa Duração

## 📋 **Visão Geral**

Para que os tokens OAuth2 durem mais tempo (até 1 ano), você precisa configurar adequadamente sua aplicação no Microsoft Azure AD.

## 🏢 **Microsoft Azure AD (OneDrive)**

### **1. Configuração no Azure Portal**

1. **Acesse o Azure Portal**: https://portal.azure.com
2. **Navegue para**: Azure Active Directory → App registrations → Sua app
3. **Configure Token Lifetime Policies**:

### **2. Configurações de Token**

```json
{
  "TokenLifetimePolicy": {
    "Version": 1,
    "DisplayName": "Bloquinho Long Token Policy",
    "Definition": [
      {
        "TokenType": "AccessToken",
        "MaxInactiveTime": "90.00:00:00",
        "MaxActiveTime": "365.00:00:00"
      },
      {
        "TokenType": "RefreshToken",
        "MaxInactiveTime": "90.00:00:00",
        "MaxActiveTime": "365.00:00:00",
        "MaxAge": "365.00:00:00"
      }
    ]
  }
}
```

### **3. Comando PowerShell para Configurar**

```powershell
# Instalar módulo Azure AD
Install-Module -Name AzureAD

# Conectar
Connect-AzureAD

# Criar política de token
$policy = New-AzureADPolicy -Definition @('{"TokenLifetimePolicy":{"Version":1,"DisplayName":"Bloquinho Long Token Policy","Definition":[{"TokenType":"AccessToken","MaxInactiveTime":"90.00:00:00","MaxActiveTime":"365.00:00:00"},{"TokenType":"RefreshToken","MaxInactiveTime":"90.00:00:00","MaxActiveTime":"365.00:00:00","MaxAge":"365.00:00:00"}]}}') -DisplayName "Bloquinho Long Token Policy" -Type "TokenLifetimePolicy"

# Aplicar à aplicação (substitua APP_ID)
Add-AzureADApplicationPolicy -Id "SEU_APP_ID_AQUI" -RefObjectId $policy.Id
```

### **4. Configurações Adicionais no Azure**

#### **A. Manifesto da Aplicação**
No Azure Portal → App registrations → Sua app → Manifest:

```json
{
  "accessTokenAcceptedVersion": 2,
  "allowPublicClient": true,
  "tokenLifetimePolicies": [
    {
      "id": "TOKEN_POLICY_ID",
      "displayName": "Bloquinho Long Token Policy"
    }
  ]
}
```

#### **B. Configurações de API**
- **offline_access**: ✅ Habilitado
- **Refresh token rotation**: ✅ Habilitado
- **Token lifetime**: 365 dias

### **5. Scopes Necessários**

Certifique-se de que sua aplicação tem os scopes corretos:

```dart
final scopes = [
  'https://graph.microsoft.com/Files.ReadWrite',
  'https://graph.microsoft.com/User.Read',
  'offline_access', // ← CRÍTICO para tokens de longa duração
];
```

## 🔄 **Renovação Automática Implementada**

O Bloquinho já implementa **renovação automática** dos tokens:

### **Recursos Implementados:**

1. **✅ Verificação de Expiração**: Tokens são verificados 10 minutos antes de expirar
2. **✅ Renovação Automática**: Refresh tokens são usados para obter novos access tokens
3. **✅ Persistent Storage**: Tokens renovados são salvos automaticamente
4. **✅ Fallback Strategy**: Se a renovação falhar, mantém token atual

### **Logs de Debug:**

```
⏰ Token Microsoft está expirando, tentando renovar...
🔄 Renovando token Microsoft...
✅ Token Microsoft renovado com sucesso!
🕒 Nova expiração: 2025-07-10T13:19:56.107230
```

## 📊 **Duração dos Tokens Após Configuração**

| Tipo | Duração Padrão | Duração com Configuração |
|------|----------------|--------------------------|
| **Access Token** | 1 hora | Até 24 horas |
| **Refresh Token** | 90 dias | Até 365 dias |
| **Renovação Automática** | ❌ | ✅ A cada 10 min antes de expirar |

## 🚀 **Próximos Passos**

1. **Configure no Azure Portal** usando as instruções acima
2. **Teste a aplicação** - os tokens devem durar muito mais
3. **Monitor logs** para verificar renovações automáticas
4. **Backup da configuração** - salve as configurações do Azure

## ⚠️ **Considerações de Segurança**

- **Tokens de longa duração** aumentam o risco se comprometidos
- **Implemente logout adequado** para revogar tokens
- **Monitor uso** através do Azure AD logs
- **Rotacione client secrets** regularmente

## 🔧 **Troubleshooting**

### **Token ainda expira rapidamente?**
- Verifique se a política foi aplicada corretamente
- Confirme que `offline_access` está nos scopes
- Verifique logs do Azure AD para erros

### **Renovação automática não funciona?**
- Confirme que refresh token está sendo salvo
- Verifique conectividade de rede
- Monitor logs de debug do Bloquinho

---

**📝 Documentação criada para**: Bloquinho Flutter App  
**🗓️ Data**: Janeiro 2025  
**🔄 Versão**: 1.0 