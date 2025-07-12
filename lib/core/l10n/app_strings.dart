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

  // Strings do perfil
  String get profile {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Perfil';
      case AppLanguage.english:
        return 'Profile';
      case AppLanguage.french:
        return 'Profil';
    }
  }

  String get editProfile {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Editar Perfil';
      case AppLanguage.english:
        return 'Edit Profile';
      case AppLanguage.french:
        return 'Modifier le Profil';
    }
  }

  String get changeLanguage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Alterar Idioma';
      case AppLanguage.english:
        return 'Change Language';
      case AppLanguage.french:
        return 'Changer de Langue';
    }
  }

  String get exportData {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Exportar Dados';
      case AppLanguage.english:
        return 'Export Data';
      case AppLanguage.french:
        return 'Exporter les Données';
    }
  }

  String get refresh {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Atualizar';
      case AppLanguage.english:
        return 'Refresh';
      case AppLanguage.french:
        return 'Actualiser';
    }
  }

  String get deleteProfile {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Deletar Perfil';
      case AppLanguage.english:
        return 'Delete Profile';
      case AppLanguage.french:
        return 'Supprimer le Profil';
    }
  }

  String get errorLoadingProfile {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao carregar perfil';
      case AppLanguage.english:
        return 'Error loading profile';
      case AppLanguage.french:
        return 'Erreur lors du chargement du profil';
    }
  }

  String get tryAgain {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tentar novamente';
      case AppLanguage.english:
        return 'Try again';
      case AppLanguage.french:
        return 'Réessayer';
    }
  }

  String get noProfileFound {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nenhum perfil encontrado';
      case AppLanguage.english:
        return 'No profile found';
      case AppLanguage.french:
        return 'Aucun profil trouvé';
    }
  }

  String get createProfileToStart {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Crie um perfil para começar';
      case AppLanguage.english:
        return 'Create a profile to start';
      case AppLanguage.french:
        return 'Créez un profil pour commencer';
    }
  }

  String get createNewProfile {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Criar Novo Perfil';
      case AppLanguage.english:
        return 'Create New Profile';
      case AppLanguage.french:
        return 'Créer un Nouveau Profil';
    }
  }

  String get languageChanged {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Idioma alterado com sucesso';
      case AppLanguage.english:
        return 'Language changed successfully';
      case AppLanguage.french:
        return 'Langue changée avec succès';
    }
  }

  String get confirmDeleteProfile {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Confirmar Deletar Perfil';
      case AppLanguage.english:
        return 'Confirm Delete Profile';
      case AppLanguage.french:
        return 'Confirmer la Suppression du Profil';
    }
  }

  String get deleteProfileWarning {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Esta ação não pode ser desfeita. Todos os dados do perfil serão perdidos.';
      case AppLanguage.english:
        return 'This action cannot be undone. All profile data will be lost.';
      case AppLanguage.french:
        return 'Cette action ne peut pas être annulée. Toutes les données du profil seront perdues.';
    }
  }

  String get delete {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Deletar';
      case AppLanguage.english:
        return 'Delete';
      case AppLanguage.french:
        return 'Supprimer';
    }
  }

  String get profileDeleted {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Perfil deletado com sucesso';
      case AppLanguage.english:
        return 'Profile deleted successfully';
      case AppLanguage.french:
        return 'Profil supprimé avec succès';
    }
  }

  String get errorDeletingProfile {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao deletar perfil';
      case AppLanguage.english:
        return 'Error deleting profile';
      case AppLanguage.french:
        return 'Erreur lors de la suppression du profil';
    }
  }

  // Strings de sincronização
  String get syncStatusTitle {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Status da Sincronização';
      case AppLanguage.english:
        return 'Sync Status';
      case AppLanguage.french:
        return 'Statut de Synchronisation';
    }
  }

  String get syncStatus {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Status';
      case AppLanguage.english:
        return 'Status';
      case AppLanguage.french:
        return 'Statut';
    }
  }

  String get unknown {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Desconhecido';
      case AppLanguage.english:
        return 'Unknown';
      case AppLanguage.french:
        return 'Inconnu';
    }
  }

  String get syncProvider {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Provedor';
      case AppLanguage.english:
        return 'Provider';
      case AppLanguage.french:
        return 'Fournisseur';
    }
  }

  String get googleDrive {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Google Drive';
      case AppLanguage.english:
        return 'Google Drive';
      case AppLanguage.french:
        return 'Google Drive';
    }
  }

  String get oneDrive {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'OneDrive';
      case AppLanguage.english:
        return 'OneDrive';
      case AppLanguage.french:
        return 'OneDrive';
    }
  }

  String get syncLastSync {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Última Sincronização';
      case AppLanguage.english:
        return 'Last Sync';
      case AppLanguage.french:
        return 'Dernière Synchronisation';
    }
  }

  String get syncFiles {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Arquivos Sincronizados';
      case AppLanguage.english:
        return 'Synced Files';
      case AppLanguage.french:
        return 'Fichiers Synchronisés';
    }
  }

  String get syncError {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro de Sincronização';
      case AppLanguage.english:
        return 'Sync Error';
      case AppLanguage.french:
        return 'Erreur de Synchronisation';
    }
  }

  String get syncButton {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Sincronizar';
      case AppLanguage.english:
        return 'Sync';
      case AppLanguage.french:
        return 'Synchroniser';
    }
  }

  String get syncCompleted {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Sincronização concluída';
      case AppLanguage.english:
        return 'Sync completed';
      case AppLanguage.french:
        return 'Synchronisation terminée';
    }
  }

  String get syncErrorOccurred {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro durante a sincronização';
      case AppLanguage.english:
        return 'Error occurred during sync';
      case AppLanguage.french:
        return 'Erreur survenue pendant la synchronisation';
    }
  }

  String get closeButton {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Fechar';
      case AppLanguage.english:
        return 'Close';
      case AppLanguage.french:
        return 'Fermer';
    }
  }

  // Strings de configurações
  String get settingsTitle {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Configurações';
      case AppLanguage.english:
        return 'Settings';
      case AppLanguage.french:
        return 'Paramètres';
    }
  }

  String get settingsLanguage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Idioma';
      case AppLanguage.english:
        return 'Language';
      case AppLanguage.french:
        return 'Langue';
    }
  }

  String get settingsLanguageDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Escolha o idioma da aplicação';
      case AppLanguage.english:
        return 'Choose the application language';
      case AppLanguage.french:
        return 'Choisissez la langue de l\'application';
    }
  }

  String get settingsTheme {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tema';
      case AppLanguage.english:
        return 'Theme';
      case AppLanguage.french:
        return 'Thème';
    }
  }

  String get settingsThemeDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Escolha o tema da aplicação';
      case AppLanguage.english:
        return 'Choose the application theme';
      case AppLanguage.french:
        return 'Choisissez le thème de l\'application';
    }
  }

  String get settingsBackup {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Backup';
      case AppLanguage.english:
        return 'Backup';
      case AppLanguage.french:
        return 'Sauvegarde';
    }
  }

  String get settingsBackupDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Gerencie seus backups';
      case AppLanguage.english:
        return 'Manage your backups';
      case AppLanguage.french:
        return 'Gérez vos sauvegardes';
    }
  }

  String get settingsStorage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Armazenamento';
      case AppLanguage.english:
        return 'Storage';
      case AppLanguage.french:
        return 'Stockage';
    }
  }

  String get settingsStorageDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Configure o armazenamento';
      case AppLanguage.english:
        return 'Configure storage';
      case AppLanguage.french:
        return 'Configurer le stockage';
    }
  }

  String get settingsProfile {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Perfil';
      case AppLanguage.english:
        return 'Profile';
      case AppLanguage.french:
        return 'Profil';
    }
  }

  String get settingsProfileDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Gerencie seu perfil';
      case AppLanguage.english:
        return 'Manage your profile';
      case AppLanguage.french:
        return 'Gérez votre profil';
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
