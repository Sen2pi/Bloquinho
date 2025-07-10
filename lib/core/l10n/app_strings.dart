import 'package:flutter/material.dart';
import '../models/app_language.dart';

/// Sistema básico de strings localizadas
class AppStrings {
  final AppLanguage _language;

  const AppStrings(this._language);

  // Strings da tela de onboarding
  String get chooseLanguage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Escolha seu idioma';
      case AppLanguage.english:
        return 'Choose your language';
      case AppLanguage.french:
        return 'Choisissez votre langue';
    }
  }

  String get languageDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Selecione o idioma de sua preferência\npara usar a aplicação.';
      case AppLanguage.english:
        return 'Select your preferred language\nto use the application.';
      case AppLanguage.french:
        return 'Sélectionnez votre langue préférée\npour utiliser l\'application.';
    }
  }

  String get welcomeToBloquinho {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Bem-vindo ao\nBloquinho';
      case AppLanguage.english:
        return 'Welcome to\nBloquinho';
      case AppLanguage.french:
        return 'Bienvenue à\nBloquinho';
    }
  }

  String get workspaceDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Seu workspace pessoal para organizar\nideias, projetos e conhecimento.';
      case AppLanguage.english:
        return 'Your personal workspace to organize\nideas, projects and knowledge.';
      case AppLanguage.french:
        return 'Votre espace de travail personnel pour organiser\nidées, projets et connaissances.';
    }
  }

  String get createProfile {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Crie seu perfil';
      case AppLanguage.english:
        return 'Create your profile';
      case AppLanguage.french:
        return 'Créez votre profil';
    }
  }

  String get profileDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Adicione suas informações para personalizar sua experiência.';
      case AppLanguage.english:
        return 'Add your information to personalize your experience.';
      case AppLanguage.french:
        return 'Ajoutez vos informations pour personnaliser votre expérience.';
    }
  }

  String get chooseStorage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Escolha seu armazenamento';
      case AppLanguage.english:
        return 'Choose your storage';
      case AppLanguage.french:
        return 'Choisissez votre stockage';
    }
  }

  String get storageDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Selecione onde você deseja armazenar seus dados.';
      case AppLanguage.english:
        return 'Select where you want to store your data.';
      case AppLanguage.french:
        return 'Sélectionnez où vous souhaitez stocker vos données.';
    }
  }

  // Botões
  String get continueButton {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Continuar';
      case AppLanguage.english:
        return 'Continue';
      case AppLanguage.french:
        return 'Continuer';
    }
  }

  String get startButton {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Começar';
      case AppLanguage.english:
        return 'Start';
      case AppLanguage.french:
        return 'Commencer';
    }
  }

  String get startUsingButton {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Começar a usar';
      case AppLanguage.english:
        return 'Start using';
      case AppLanguage.french:
        return 'Commencer à utiliser';
    }
  }

  String get completedButton {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Concluído!';
      case AppLanguage.english:
        return 'Completed!';
      case AppLanguage.french:
        return 'Terminé!';
    }
  }

  // Campos de formulário
  String get fullName {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nome completo';
      case AppLanguage.english:
        return 'Full name';
      case AppLanguage.french:
        return 'Nom complet';
    }
  }

  String get email {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Email';
      case AppLanguage.english:
        return 'Email';
      case AppLanguage.french:
        return 'Email';
    }
  }

  String get addPhoto {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Adicionar foto';
      case AppLanguage.english:
        return 'Add photo';
      case AppLanguage.french:
        return 'Ajouter une photo';
    }
  }

  // Tipos de armazenamento
  String get localStorage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Armazenamento Local';
      case AppLanguage.english:
        return 'Local Storage';
      case AppLanguage.french:
        return 'Stockage Local';
    }
  }

  String get localStorageDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Dados ficam apenas neste dispositivo';
      case AppLanguage.english:
        return 'Data stays only on this device';
      case AppLanguage.french:
        return 'Les données restent uniquement sur cet appareil';
    }
  }

  String get localStorageWarning {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Os dados não serão sincronizados entre dispositivos';
      case AppLanguage.english:
        return 'Data will not be synchronized between devices';
      case AppLanguage.french:
        return 'Les données ne seront pas synchronisées entre les appareils';
    }
  }

  String get googleDriveDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Sincronizar com Google Drive (15GB grátis)';
      case AppLanguage.english:
        return 'Sync with Google Drive (15GB free)';
      case AppLanguage.french:
        return 'Synchroniser avec Google Drive (15GB gratuits)';
    }
  }

  String get oneDriveDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Sincronizar com OneDrive (5GB grátis)';
      case AppLanguage.english:
        return 'Sync with OneDrive (5GB free)';
      case AppLanguage.french:
        return 'Synchroniser avec OneDrive (5GB gratuits)';
    }
  }

  // Validações
  String get pleaseEnterName {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Por favor, insira seu nome';
      case AppLanguage.english:
        return 'Please enter your name';
      case AppLanguage.french:
        return 'Veuillez saisir votre nom';
    }
  }

  String get pleaseEnterEmail {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Por favor, insira seu email';
      case AppLanguage.english:
        return 'Please enter your email';
      case AppLanguage.french:
        return 'Veuillez saisir votre email';
    }
  }

  String get pleaseEnterValidEmail {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Por favor, insira um email válido';
      case AppLanguage.english:
        return 'Please enter a valid email';
      case AppLanguage.french:
        return 'Veuillez saisir un email valide';
    }
  }

  // Mensagens de erro
  String get errorCreatingUser {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao criar usuário';
      case AppLanguage.english:
        return 'Error creating user';
      case AppLanguage.french:
        return 'Erreur lors de la création de l\'utilisateur';
    }
  }

  // Database System Translations
  String get clickToChooseStatus {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Clique para escolher status';
      case AppLanguage.english:
        return 'Click to choose status';
      case AppLanguage.french:
        return 'Cliquez pour choisir le statut';
    }
  }

  String get clickToSetDateTime {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Clique para definir data e hora';
      case AppLanguage.english:
        return 'Click to set date and time';
      case AppLanguage.french:
        return 'Cliquez pour définir la date et l\'heure';
    }
  }

  String get today {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Hoje';
      case AppLanguage.english:
        return 'Today';
      case AppLanguage.french:
        return 'Aujourd\'hui';
    }
  }

  String get tomorrow {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Amanhã';
      case AppLanguage.english:
        return 'Tomorrow';
      case AppLanguage.french:
        return 'Demain';
    }
  }

  String get yesterday {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Ontem';
      case AppLanguage.english:
        return 'Yesterday';
      case AppLanguage.french:
        return 'Hier';
    }
  }

  String get selectDate {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Selecionar Data';
      case AppLanguage.english:
        return 'Select Date';
      case AppLanguage.french:
        return 'Sélectionner la Date';
    }
  }

  String get selectTime {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Selecionar Hora';
      case AppLanguage.english:
        return 'Select Time';
      case AppLanguage.french:
        return 'Sélectionner l\'Heure';
    }
  }

  String get next {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Próximo';
      case AppLanguage.english:
        return 'Next';
      case AppLanguage.french:
        return 'Suivant';
    }
  }

  String get save {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Salvar';
      case AppLanguage.english:
        return 'Save';
      case AppLanguage.french:
        return 'Sauvegarder';
    }
  }

  String get cancel {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Cancelar';
      case AppLanguage.english:
        return 'Cancel';
      case AppLanguage.french:
        return 'Annuler';
    }
  }

  String get back {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Voltar';
      case AppLanguage.english:
        return 'Back';
      case AppLanguage.french:
        return 'Retour';
    }
  }

  // Status options
  String get statusTodo {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Por fazer';
      case AppLanguage.english:
        return 'To do';
      case AppLanguage.french:
        return 'À faire';
    }
  }

  String get statusInProgress {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Em progresso';
      case AppLanguage.english:
        return 'In progress';
      case AppLanguage.french:
        return 'En cours';
    }
  }

  String get statusCompleted {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Concluído';
      case AppLanguage.english:
        return 'Completed';
      case AppLanguage.french:
        return 'Terminé';
    }
  }

  String get noStatus {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Sem status';
      case AppLanguage.english:
        return 'No status';
      case AppLanguage.french:
        return 'Sans statut';
    }
  }

  String get noDeadline {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Sem deadline';
      case AppLanguage.english:
        return 'No deadline';
      case AppLanguage.french:
        return 'Sans échéance';
    }
  }
}

/// Provider de strings localizadas
class AppStringsProvider {
  static AppStrings of(AppLanguage language) {
    return AppStrings(language);
  }
}
