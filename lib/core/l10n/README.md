git # Sistema de Internacionalização - Bloquinho

## Idiomas Suportados

- 🇵🇹 **Português** (pt_BR) - Idioma padrão
- 🇺🇸 **English** (en_US)  
- 🇫🇷 **Français** (fr_FR)

## Como Usar

### 1. Em Widgets Consumidores

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    
    return Text(strings.continueButton);
  }
}
```

### 2. Alternar Idioma

```dart
// Alterar para inglês
await ref.read(languageProvider.notifier).setLanguage(AppLanguage.english);

// Alterar para francês  
await ref.read(languageProvider.notifier).setLanguage(AppLanguage.french);
```

### 3. Obter Idioma Atual

```dart
final currentLanguage = ref.watch(languageProvider);
final currentLocale = ref.watch(currentLocaleProvider);
final languageName = ref.watch(currentLanguageNameProvider);
final languageFlag = ref.watch(currentLanguageFlagProvider);
```

## Adicionando Novas Strings

1. Abra `lib/core/l10n/app_strings.dart`
2. Adicione um novo getter na classe `AppStrings`
3. Implemente as traduções para os 3 idiomas

Exemplo:
```dart
String get newString {
  switch (_language) {
    case AppLanguage.portuguese:
      return 'Nova string em português';
    case AppLanguage.english:
      return 'New string in English';
    case AppLanguage.french:
      return 'Nouvelle chaîne en français';
  }
}
```

## Adicionando Novos Idiomas

1. Adicione o novo idioma em `AppLanguage` enum
2. Atualize todas as strings em `AppStrings`
3. Adicione o locale correspondente nos `supportedLocales`

## Estrutura de Arquivos

```
lib/core/
├── l10n/
│   ├── app_strings.dart    # Strings localizadas
│   └── README.md          # Esta documentação
├── models/
│   └── app_language.dart  # Enum de idiomas
└── ...

lib/shared/providers/
└── language_provider.dart # Provider de idiomas
```

## Persistência

O idioma selecionado é automaticamente salvo no Hive e restaurado quando o app é aberto novamente.

## Fluxo de Onboarding

1. **Página 1**: Seleção de idioma (🇵🇹🇺🇸🇫🇷)
2. **Página 2**: Boas-vindas
3. **Página 3**: Criação de perfil  
4. **Página 4**: Seleção de armazenamento

O idioma selecionado na primeira página afeta todas as strings das páginas seguintes. 