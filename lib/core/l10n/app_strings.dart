/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

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

  // --- STRINGS FALTANTES PARA BLOQUINHO E AGENDA ---
  String get saving {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Salvando...';
      case AppLanguage.english:
        return 'Saving...';
      case AppLanguage.french:
        return 'Enregistrement...';
    }
  }

  String get saved {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Salvo!';
      case AppLanguage.english:
        return 'Saved!';
      case AppLanguage.french:
        return 'Enregistré!';
    }
  }

  String get editorError {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro no editor';
      case AppLanguage.english:
        return 'Editor error';
      case AppLanguage.french:
        return 'Erreur de l\'éditeur';
    }
  }

  String get featureInDevelopment {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Funcionalidade em desenvolvimento';
      case AppLanguage.english:
        return 'Feature in development';
      case AppLanguage.french:
        return 'Fonctionnalité en développement';
    }
  }

  String get export {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Exportar';
      case AppLanguage.english:
        return 'Export';
      case AppLanguage.french:
        return 'Exporter';
    }
  }

  String get agenda {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Agenda';
      case AppLanguage.english:
        return 'Agenda';
      case AppLanguage.french:
        return 'Agenda';
    }
  }

  String get statistics {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Estatísticas';
      case AppLanguage.english:
        return 'Statistics';
      case AppLanguage.french:
        return 'Statistiques';
    }
  }

  String get syncWithDatabase {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Sincronizar com Base de Dados';
      case AppLanguage.english:
        return 'Sync with Database';
      case AppLanguage.french:
        return 'Synchroniser avec la base de données';
    }
  }

  String get newItem {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Novo item';
      case AppLanguage.english:
        return 'New item';
      case AppLanguage.french:
        return 'Nouvel élément';
    }
  }

  String get editItem {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Editar item';
      case AppLanguage.english:
        return 'Edit item';
      case AppLanguage.french:
        return 'Modifier l\'élément';
    }
  }

  String get errorLoadingAgenda {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao carregar agenda';
      case AppLanguage.english:
        return 'Error loading agenda';
      case AppLanguage.french:
        return 'Erreur lors du chargement de l\'agenda';
    }
  }

  String get backupAndSync {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Backup e Sincronização';
      case AppLanguage.english:
        return 'Backup and Sync';
      case AppLanguage.french:
        return 'Sauvegarde et synchronisation';
    }
  }

  String get advancedOptions {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Opções avançadas';
      case AppLanguage.english:
        return 'Advanced options';
      case AppLanguage.french:
        return 'Options avancées';
    }
  }

  String get restore {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Restaurar';
      case AppLanguage.english:
        return 'Restore';
      case AppLanguage.french:
        return 'Restaurer';
    }
  }

  String get import {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Importar';
      case AppLanguage.english:
        return 'Import';
      case AppLanguage.french:
        return 'Importer';
    }
  }

  // --- MÉTODOS UTILITÁRIOS ---
  String minutesAgo(int minutes) {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Há $minutes min';
      case AppLanguage.english:
        return '$minutes min ago';
      case AppLanguage.french:
        return 'Il y a $minutes min';
    }
  }

  String hoursAgo(int hours) {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Há $hours h';
      case AppLanguage.english:
        return '$hours h ago';
      case AppLanguage.french:
        return 'Il y a $hours h';
    }
  }

  String daysAgo(int days) {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Há $days dias';
      case AppLanguage.english:
        return '$days days ago';
      case AppLanguage.french:
        return 'Il y a $days jours';
    }
  }

  // --- ERROS E FEEDBACKS ---
  String get errorInitializingEditor {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao inicializar o editor';
      case AppLanguage.english:
        return 'Error initializing editor';
      case AppLanguage.french:
        return 'Erreur lors de l\'initialisation de l\'éditeur';
    }
  }

  String get errorProfileOrWorkspaceNotAvailable {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Perfil ou workspace não disponível';
      case AppLanguage.english:
        return 'Profile or workspace not available';
      case AppLanguage.french:
        return 'Profil ou espace de travail non disponible';
    }
  }

  String get untitledPage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Página sem título';
      case AppLanguage.english:
        return 'Untitled page';
      case AppLanguage.french:
        return 'Page sans titre';
    }
  }

  String get chooseIcon {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Escolher ícone';
      case AppLanguage.english:
        return 'Choose icon';
      case AppLanguage.french:
        return 'Choisir une icône';
    }
  }

  String get editTitle {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Editar título';
      case AppLanguage.english:
        return 'Edit title';
      case AppLanguage.french:
        return 'Modifier le titre';
    }
  }

  String get pageTitle {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Título da página';
      case AppLanguage.english:
        return 'Page title';
      case AppLanguage.french:
        return 'Titre de la page';
    }
  }

  String get typeTitle {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tipo de título';
      case AppLanguage.english:
        return 'Type title';
      case AppLanguage.french:
        return 'Type de titre';
    }
  }

  String get startWriting {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Comece a escrever...';
      case AppLanguage.english:
        return 'Start writing...';
      case AppLanguage.french:
        return 'Commencez à écrire...';
    }
  }

  String get insertBlock {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Inserir bloco';
      case AppLanguage.english:
        return 'Insert block';
      case AppLanguage.french:
        return 'Insérer un bloc';
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

  // Botão Donate
  String get donateButton {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Doar';
      case AppLanguage.english:
        return 'Donate';
      case AppLanguage.french:
        return 'Faire un don';
    }
  }

  String get donateDialogTitle {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Apoie o Bloquinho!';
      case AppLanguage.english:
        return 'Support Bloquinho!';
      case AppLanguage.french:
        return 'Soutenez Bloquinho !';
    }
  }

  String get donateDialogDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Aponte a câmera do seu celular para doar via PayPal. Obrigado pelo apoio! ❤️';
      case AppLanguage.english:
        return 'Point your phone camera to donate via PayPal. Thank you for your support! ❤️';
      case AppLanguage.french:
        return 'Scannez avec votre téléphone pour faire un don via PayPal. Merci pour votre soutien ! ❤️';
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

  // Novas strings
  String get aiSettings {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Configurações de IA';
      case AppLanguage.english:
        return 'AI Settings';
      case AppLanguage.french:
        return 'Paramètres IA';
    }
  }

  String get aiSettingsDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Token Hugging Face e integração de IA';
      case AppLanguage.english:
        return 'Hugging Face token and AI integration';
      case AppLanguage.french:
        return 'Jeton Hugging Face et intégration IA';
    }
  }

  String get themeLight {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Claro';
      case AppLanguage.english:
        return 'Light';
      case AppLanguage.french:
        return 'Clair';
    }
  }

  String get themeDark {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Escuro';
      case AppLanguage.english:
        return 'Dark';
      case AppLanguage.french:
        return 'Sombre';
    }
  }

  String get themeSystem {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Sistema';
      case AppLanguage.english:
        return 'System';
      case AppLanguage.french:
        return 'Système';
    }
  }

  String get profileCreatedSuccessfully {
    switch (_language) {
      case AppLanguage.portuguese:
        return '✅ Perfil criado com sucesso!';
      case AppLanguage.english:
        return '✅ Profile created successfully!';
      case AppLanguage.french:
        return '✅ Profil créé avec succès !';
    }
  }

  String get errorAuthenticating {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao autenticar: %s';
      case AppLanguage.english:
        return 'Error authenticating: %s';
      case AppLanguage.french:
        return 'Erreur d\'authentification: %s';
    }
  }

  String get welcomeToBloquinhoOAuth {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Bem-vindo ao Bloquinho';
      case AppLanguage.english:
        return 'Welcome to Bloquinho';
      case AppLanguage.french:
        return 'Bienvenue à Bloquinho';
    }
  }

  String get oauthLoginPrompt {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Faça login com sua conta para começar\nSeu perfil e foto serão configurados automaticamente';
      case AppLanguage.english:
        return 'Log in with your account to get started\nYour profile and photo will be set up automatically';
      case AppLanguage.french:
        return 'Connectez-vous avec votre compte pour commencer\nVotre profil et votre photo seront configurés automatiquement';
    }
  }

  String get authenticating {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Autenticando...';
      case AppLanguage.english:
        return 'Authenticating...';
      case AppLanguage.french:
        return 'Authentification...';
    }
  }

  String get continueWithGoogle {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Continuar com Google';
      case AppLanguage.english:
        return 'Continue with Google';
      case AppLanguage.french:
        return 'Continuer avec Google';
    }
  }

  String get continueWithMicrosoft {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Continuar com Microsoft';
      case AppLanguage.english:
        return 'Continue with Microsoft';
      case AppLanguage.french:
        return 'Continuer avec Microsoft';
    }
  }

  String get createProfileManually {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Ou criar perfil manualmente';
      case AppLanguage.english:
        return 'Or create profile manually';
      case AppLanguage.french:
        return 'Ou créer un profil manuellement';
    }
  }

  String get profileConfigured {
    switch (_language) {
      case AppLanguage.portuguese:
        return '✅ Perfil configurado';
      case AppLanguage.english:
        return '✅ Profile configured';
      case AppLanguage.french:
        return '✅ Profil configuré';
    }
  }

  String get pleaseFillAllFields {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Por favor, volte e preencha todos os campos';
      case AppLanguage.english:
        return 'Please go back and fill in all fields';
      case AppLanguage.french:
        return 'Veuillez revenir en arrière et remplir tous les champs';
    }
  }

  String get oneDriveAuthFailed {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Falha na autenticação com OneDrive: %s';
      case AppLanguage.english:
        return 'OneDrive authentication failed: %s';
      case AppLanguage.french:
        return 'Échec de l\'authentification OneDrive: %s';
    }
  }

  String get errorCreatingWorkspace {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao criar workspace padrão';
      case AppLanguage.english:
        return 'Error creating default workspace';
      case AppLanguage.french:
        return 'Erreur lors de la création de l\'espace de travail par défaut';
    }
  }

  String get personalWorkspace {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Pessoal';
      case AppLanguage.english:
        return 'Personal';
      case AppLanguage.french:
        return 'Personnel';
    }
  }

  String get workWorkspace {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Trabalho';
      case AppLanguage.english:
        return 'Work';
      case AppLanguage.french:
        return 'Travail';
    }
  }

  String get projectsWorkspace {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Projetos';
      case AppLanguage.english:
        return 'Projects';
      case AppLanguage.french:
        return 'Projets';
    }
  }

  String get pagesOf {
    switch (_language) {
      case AppLanguage.portuguese:
        return '%s de 4';
      case AppLanguage.english:
        return '%s of 4';
      case AppLanguage.french:
        return '%s sur 4';
    }
  }

  String get clickToEdit {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Clique para editar...';
      case AppLanguage.english:
        return 'Click to edit...';
      case AppLanguage.french:
        return 'Cliquez pour modifier...';
    }
  }

  String get newPage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nova Página';
      case AppLanguage.english:
        return 'New Page';
      case AppLanguage.french:
        return 'Nouvelle Page';
    }
  }

  String get pageNotFound {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Página não encontrada';
      case AppLanguage.english:
        return 'Page not found';
      case AppLanguage.french:
        return 'Page non trouvée';
    }
  }

  String get checkingAvailability {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Verificando disponibilidade...';
      case AppLanguage.english:
        return 'Checking availability...';
      case AppLanguage.french:
        return 'Vérification de la disponibilité...';
    }
  }

  String get oneDriveSubscriptionRequired {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Requer subscrição ativa do OneDrive';
      case AppLanguage.english:
        return 'Requires active OneDrive subscription';
      case AppLanguage.french:
        return 'Nécessite un abonnement OneDrive actif';
    }
  }

  String get initializing {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Inicializando...';
      case AppLanguage.english:
        return 'Initializing...';
      case AppLanguage.french:
        return 'Initialisation...';
    }
  }

  String get loadingSavedData {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Carregando dados salvos...';
      case AppLanguage.english:
        return 'Loading saved data...';
      case AppLanguage.french:
        return 'Chargement des données sauvegardées...';
    }
  }

  String get profileFound {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Perfil encontrado!';
      case AppLanguage.english:
        return 'Profile found!';
      case AppLanguage.french:
        return 'Profil trouvé !';
    }
  }

  String get firstAccessDetected {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Primeiro acesso detectado';
      case AppLanguage.english:
        return 'First access detected';
      case AppLanguage.french:
        return 'Premier accès détecté';
    }
  }

  String get title1 {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Título 1';
      case AppLanguage.english:
        return 'Title 1';
      case AppLanguage.french:
        return 'Titre 1';
    }
  }

  String get largeHeader {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Cabeçalho grande';
      case AppLanguage.english:
        return 'Large header';
      case AppLanguage.french:
        return 'Grand en-tête';
    }
  }

  String get title2 {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Título 2';
      case AppLanguage.english:
        return 'Title 2';
      case AppLanguage.french:
        return 'Titre 2';
    }
  }

  String get mediumHeader {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Cabeçalho médio';
      case AppLanguage.english:
        return 'Medium header';
      case AppLanguage.french:
        return 'En-tête moyen';
    }
  }

  String get title3 {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Título 3';
      case AppLanguage.english:
        return 'Title 3';
      case AppLanguage.french:
        return 'Titre 3';
    }
  }

  String get smallHeader {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Cabeçalho pequeno';
      case AppLanguage.english:
        return 'Small header';
      case AppLanguage.french:
        return 'Petit en-tête';
    }
  }

  String get title4 {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Título 4';
      case AppLanguage.english:
        return 'Title 4';
      case AppLanguage.french:
        return 'Titre 4';
    }
  }

  String get verySmallHeader {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Cabeçalho muito pequeno';
      case AppLanguage.english:
        return 'Very small header';
      case AppLanguage.french:
        return 'Très petit en-tête';
    }
  }

  String get list {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Lista';
      case AppLanguage.english:
        return 'List';
      case AppLanguage.french:
        return 'Liste';
    }
  }

  String get bulletList {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Lista com marcadores';
      case AppLanguage.english:
        return 'Bullet list';
      case AppLanguage.french:
        return 'Liste à puces';
    }
  }

  // --- STRINGS MASSIVAS PARA BLOQUINHO, AGENDA E BACKUP ---
  String get newSubpage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nova subpágina';
      case AppLanguage.english:
        return 'New subpage';
      case AppLanguage.french:
        return 'Nouvelle sous-page';
    }
  }

  String get errorExportingDocument {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao exportar documento';
      case AppLanguage.english:
        return 'Error exporting document';
      case AppLanguage.french:
        return 'Erreur lors de l\'exportation du document';
    }
  }

  String get titleUpdatedSuccessfully {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Título atualizado com sucesso';
      case AppLanguage.english:
        return 'Title updated successfully';
      case AppLanguage.french:
        return 'Titre mis à jour avec succès';
    }
  }

  String get search {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Buscar';
      case AppLanguage.english:
        return 'Search';
      case AppLanguage.french:
        return 'Rechercher';
    }
  }

  String get undo {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Desfazer';
      case AppLanguage.english:
        return 'Undo';
      case AppLanguage.french:
        return 'Annuler';
    }
  }

  String get redo {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Refazer';
      case AppLanguage.english:
        return 'Redo';
      case AppLanguage.french:
        return 'Rétablir';
    }
  }

  String get zoom {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Zoom';
      case AppLanguage.english:
        return 'Zoom';
      case AppLanguage.french:
        return 'Zoom';
    }
  }

  String get searchInDocument {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Buscar no documento';
      case AppLanguage.english:
        return 'Search in document';
      case AppLanguage.french:
        return 'Rechercher dans le document';
    }
  }

  String get exportDocument {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Exportar documento';
      case AppLanguage.english:
        return 'Export document';
      case AppLanguage.french:
        return 'Exporter le document';
    }
  }

  String get markdown {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Markdown';
      case AppLanguage.english:
        return 'Markdown';
      case AppLanguage.french:
        return 'Markdown';
    }
  }

  String get plainTextFormat {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Texto simples';
      case AppLanguage.english:
        return 'Plain text';
      case AppLanguage.french:
        return 'Texte brut';
    }
  }

  String get pdf {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'PDF';
      case AppLanguage.english:
        return 'PDF';
      case AppLanguage.french:
        return 'PDF';
    }
  }

  String get portableDocument {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Documento portátil';
      case AppLanguage.english:
        return 'Portable document';
      case AppLanguage.french:
        return 'Document portable';
    }
  }

  String get html {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'HTML';
      case AppLanguage.english:
        return 'HTML';
      case AppLanguage.french:
        return 'HTML';
    }
  }

  String get webPage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Página web';
      case AppLanguage.english:
        return 'Web page';
      case AppLanguage.french:
        return 'Page web';
    }
  }

  String get documentTitle {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Título do documento';
      case AppLanguage.english:
        return 'Document title';
      case AppLanguage.french:
        return 'Titre du document';
    }
  }

  String get insertLink {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Inserir link';
      case AppLanguage.english:
        return 'Insert link';
      case AppLanguage.french:
        return 'Insérer un lien';
    }
  }

  String get linkTextOptional {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Texto do link (opcional)';
      case AppLanguage.english:
        return 'Link text (optional)';
      case AppLanguage.french:
        return 'Texte du lien (optionnel)';
    }
  }

  String get insert {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Inserir';
      case AppLanguage.english:
        return 'Insert';
      case AppLanguage.french:
        return 'Insérer';
    }
  }

  String get manageBackupsAndImportNotion {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Gerencie backups e importe do Notion';
      case AppLanguage.english:
        return 'Manage backups and import from Notion';
      case AppLanguage.french:
        return 'Gérer les sauvegardes et importer depuis Notion';
    }
  }

  String get notDefined {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Não definido';
      case AppLanguage.english:
        return 'Not defined';
      case AppLanguage.french:
        return 'Non défini';
    }
  }

  String get backupWorkspace {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Backup do workspace';
      case AppLanguage.english:
        return 'Workspace backup';
      case AppLanguage.french:
        return 'Sauvegarde de l\'espace de travail';
    }
  }

  String get importNotion {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Importar do Notion';
      case AppLanguage.english:
        return 'Import from Notion';
      case AppLanguage.french:
        return 'Importer depuis Notion';
    }
  }

  String get noBackupFound {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nenhum backup encontrado';
      case AppLanguage.english:
        return 'No backup found';
      case AppLanguage.french:
        return 'Aucune sauvegarde trouvée';
    }
  }

  String get createFirstBackup {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Crie seu primeiro backup';
      case AppLanguage.english:
        return 'Create your first backup';
      case AppLanguage.french:
        return 'Créez votre première sauvegarde';
    }
  }

  String get createBackup {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Criar backup';
      case AppLanguage.english:
        return 'Create backup';
      case AppLanguage.french:
        return 'Créer une sauvegarde';
    }
  }

  String get backupCreatedSuccessfully {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Backup criado com sucesso';
      case AppLanguage.english:
        return 'Backup created successfully';
      case AppLanguage.french:
        return 'Sauvegarde créée avec succès';
    }
  }

  String errorCreatingBackup(String error) {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao criar backup: $error';
      case AppLanguage.english:
        return 'Error creating backup: $error';
      case AppLanguage.french:
        return 'Erreur lors de la création de la sauvegarde : $error';
    }
  }

  String get selectWorkspaceAndProfile {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Selecione workspace e perfil';
      case AppLanguage.english:
        return 'Select workspace and profile';
      case AppLanguage.french:
        return 'Sélectionnez l\'espace de travail et le profil';
    }
  }

  String errorCreatingWorkspaceBackup(String error) {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao criar backup do workspace: $error';
      case AppLanguage.english:
        return 'Error creating workspace backup: $error';
      case AppLanguage.french:
        return 'Erreur lors de la sauvegarde de l\'espace de travail : $error';
    }
  }

  // --- JOB MANAGEMENT STRINGS ---
  String get jobManagement {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Gestão de Trabalho';
      case AppLanguage.english:
        return 'Job Management';
      case AppLanguage.french:
        return 'Gestion du Travail';
    }
  }

  String get jobDashboard {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Dashboard de Trabalho';
      case AppLanguage.english:
        return 'Job Dashboard';
      case AppLanguage.french:
        return 'Tableau de Bord Travail';
    }
  }

  String get jobInterviews {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Entrevistas';
      case AppLanguage.english:
        return 'Interviews';
      case AppLanguage.french:
        return 'Entretiens';
    }
  }

  String get jobCVs {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'CVs';
      case AppLanguage.english:
        return 'CVs';
      case AppLanguage.french:
        return 'CVs';
    }
  }

  String get jobApplications {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Candidaturas';
      case AppLanguage.english:
        return 'Applications';
      case AppLanguage.french:
        return 'Candidatures';
    }
  }

  String get jobNewInterview {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nova Entrevista';
      case AppLanguage.english:
        return 'New Interview';
      case AppLanguage.french:
        return 'Nouvel Entretien';
    }
  }

  String get jobNewCV {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Novo CV';
      case AppLanguage.english:
        return 'New CV';
      case AppLanguage.french:
        return 'Nouveau CV';
    }
  }

  String get jobNewApplication {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nova Candidatura';
      case AppLanguage.english:
        return 'New Application';
      case AppLanguage.french:
        return 'Nouvelle Candidature';
    }
  }

  String get jobInterviewType {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tipo de Entrevista';
      case AppLanguage.english:
        return 'Interview Type';
      case AppLanguage.french:
        return 'Type d\'Entretien';
    }
  }

  String get jobInterviewTypeRH {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'RH';
      case AppLanguage.english:
        return 'HR';
      case AppLanguage.french:
        return 'RH';
    }
  }

  String get jobInterviewTypeTechnical {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Técnica';
      case AppLanguage.english:
        return 'Technical';
      case AppLanguage.french:
        return 'Technique';
    }
  }

  String get jobInterviewTypeTeamLead {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Team Lead';
      case AppLanguage.english:
        return 'Team Lead';
      case AppLanguage.french:
        return 'Chef d\'Équipe';
    }
  }

  String get jobSalaryProposal {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Proposta Salarial';
      case AppLanguage.english:
        return 'Salary Proposal';
      case AppLanguage.french:
        return 'Proposition Salariale';
    }
  }

  String get jobAnnualSalary {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Salário Anual';
      case AppLanguage.english:
        return 'Annual Salary';
      case AppLanguage.french:
        return 'Salaire Annuel';
    }
  }

  String get jobCompany {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Empresa';
      case AppLanguage.english:
        return 'Company';
      case AppLanguage.french:
        return 'Entreprise';
    }
  }

  String get jobCountry {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'País';
      case AppLanguage.english:
        return 'Country';
      case AppLanguage.french:
        return 'Pays';
    }
  }

  String get jobLanguage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Idioma';
      case AppLanguage.english:
        return 'Language';
      case AppLanguage.french:
        return 'Langue';
    }
  }

  String get jobDateTime {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Data e Hora';
      case AppLanguage.english:
        return 'Date and Time';
      case AppLanguage.french:
        return 'Date et Heure';
    }
  }

  String get jobInterviewWentWell {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Como correu a entrevista?';
      case AppLanguage.english:
        return 'How did the interview go?';
      case AppLanguage.french:
        return 'Comment s\'est déroulé l\'entretien ?';
    }
  }

  String get jobCompanyLink {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Link da Empresa';
      case AppLanguage.english:
        return 'Company Link';
      case AppLanguage.french:
        return 'Lien de l\'Entreprise';
    }
  }

  String get jobDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Descrição';
      case AppLanguage.english:
        return 'Description';
      case AppLanguage.french:
        return 'Description';
    }
  }

  String get jobJobTitle {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Título da Vaga';
      case AppLanguage.english:
        return 'Job Title';
      case AppLanguage.french:
        return 'Titre du Poste';
    }
  }

  String get jobExperience {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Experiência';
      case AppLanguage.english:
        return 'Experience';
      case AppLanguage.french:
        return 'Expérience';
    }
  }

  String get jobProjects {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Projetos';
      case AppLanguage.english:
        return 'Projects';
      case AppLanguage.french:
        return 'Projets';
    }
  }

  String get jobSkills {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Habilidades';
      case AppLanguage.english:
        return 'Skills';
      case AppLanguage.french:
        return 'Compétences';
    }
  }

  String get jobEducation {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Educação';
      case AppLanguage.english:
        return 'Education';
      case AppLanguage.french:
        return 'Éducation';
    }
  }

  String get jobLanguages {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Idiomas';
      case AppLanguage.english:
        return 'Languages';
      case AppLanguage.french:
        return 'Langues';
    }
  }

  String get jobCertifications {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Certificações';
      case AppLanguage.english:
        return 'Certifications';
      case AppLanguage.french:
        return 'Certifications';
    }
  }

  String get jobTargetPosition {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Cargo Desejado';
      case AppLanguage.english:
        return 'Target Position';
      case AppLanguage.french:
        return 'Poste Visé';
    }
  }

  String get jobPersonalInfo {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Informações Pessoais';
      case AppLanguage.english:
        return 'Personal Information';
      case AppLanguage.french:
        return 'Informations Personnelles';
    }
  }

  String get jobPhone {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Telefone';
      case AppLanguage.english:
        return 'Phone';
      case AppLanguage.french:
        return 'Téléphone';
    }
  }

  String get jobAddress {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Endereço';
      case AppLanguage.english:
        return 'Address';
      case AppLanguage.french:
        return 'Adresse';
    }
  }

  String get jobLinkedIn {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'LinkedIn';
      case AppLanguage.english:
        return 'LinkedIn';
      case AppLanguage.french:
        return 'LinkedIn';
    }
  }

  String get jobGitHub {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'GitHub';
      case AppLanguage.english:
        return 'GitHub';
      case AppLanguage.french:
        return 'GitHub';
    }
  }

  String get jobWebsite {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Website';
      case AppLanguage.english:
        return 'Website';
      case AppLanguage.french:
        return 'Site Web';
    }
  }

  String get jobSummary {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Resumo';
      case AppLanguage.english:
        return 'Summary';
      case AppLanguage.french:
        return 'Résumé';
    }
  }

  String get jobAIIntroduction {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Introdução IA';
      case AppLanguage.english:
        return 'AI Introduction';
      case AppLanguage.french:
        return 'Introduction IA';
    }
  }

  String get jobGenerateAIIntroduction {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Gerar Introdução com IA';
      case AppLanguage.english:
        return 'Generate AI Introduction';
      case AppLanguage.french:
        return 'Générer Introduction IA';
    }
  }

  String get jobExportToPDF {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Exportar para PDF';
      case AppLanguage.english:
        return 'Export to PDF';
      case AppLanguage.french:
        return 'Exporter en PDF';
    }
  }

  String get jobApplicationStatus {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Status da Candidatura';
      case AppLanguage.english:
        return 'Application Status';
      case AppLanguage.french:
        return 'Statut de la Candidature';
    }
  }

  String get jobApplicationStatusApplied {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Candidatado';
      case AppLanguage.english:
        return 'Applied';
      case AppLanguage.french:
        return 'Postulé';
    }
  }

  String get jobApplicationStatusInReview {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Em Análise';
      case AppLanguage.english:
        return 'In Review';
      case AppLanguage.french:
        return 'En Cours d\'Examen';
    }
  }

  String get jobApplicationStatusInterviewScheduled {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Entrevista Agendada';
      case AppLanguage.english:
        return 'Interview Scheduled';
      case AppLanguage.french:
        return 'Entretien Programmé';
    }
  }

  String get jobApplicationStatusRejected {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Rejeitado';
      case AppLanguage.english:
        return 'Rejected';
      case AppLanguage.french:
        return 'Rejeté';
    }
  }

  String get jobApplicationStatusAccepted {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Aceito';
      case AppLanguage.english:
        return 'Accepted';
      case AppLanguage.french:
        return 'Accepté';
    }
  }

  String get jobApplicationStatusWithdrawn {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Retirado';
      case AppLanguage.english:
        return 'Withdrawn';
      case AppLanguage.french:
        return 'Retiré';
    }
  }

  String get jobMotivationLetter {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Carta de Motivação';
      case AppLanguage.english:
        return 'Motivation Letter';
      case AppLanguage.french:
        return 'Lettre de Motivation';
    }
  }

  String get jobGenerateMotivationLetter {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Gerar Carta de Motivação';
      case AppLanguage.english:
        return 'Generate Motivation Letter';
      case AppLanguage.french:
        return 'Générer Lettre de Motivation';
    }
  }

  String get jobMatchPercentage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Percentagem de Compatibilidade';
      case AppLanguage.english:
        return 'Match Percentage';
      case AppLanguage.french:
        return 'Pourcentage de Compatibilité';
    }
  }

  String get jobPlatform {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Plataforma';
      case AppLanguage.english:
        return 'Platform';
      case AppLanguage.french:
        return 'Plateforme';
    }
  }

  String get jobLocation {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Localização';
      case AppLanguage.english:
        return 'Location';
      case AppLanguage.french:
        return 'Localisation';
    }
  }

  String get jobNotes {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Notas';
      case AppLanguage.english:
        return 'Notes';
      case AppLanguage.french:
        return 'Notes';
    }
  }

  String get jobRating {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Avaliação';
      case AppLanguage.english:
        return 'Rating';
      case AppLanguage.french:
        return 'Évaluation';
    }
  }

  String get jobRecentInterviews {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Entrevistas Recentes';
      case AppLanguage.english:
        return 'Recent Interviews';
      case AppLanguage.french:
        return 'Entretiens Récents';
    }
  }

  String get jobTotalCVs {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Total de CVs';
      case AppLanguage.english:
        return 'Total CVs';
      case AppLanguage.french:
        return 'Total CVs';
    }
  }

  String get jobTotalApplications {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Total de Candidaturas';
      case AppLanguage.english:
        return 'Total Applications';
      case AppLanguage.french:
        return 'Total Candidatures';
    }
  }

  String get jobTotalInterviews {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Total de Entrevistas';
      case AppLanguage.english:
        return 'Total Interviews';
      case AppLanguage.french:
        return 'Total Entretiens';
    }
  }

  String get jobThisMonth {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Este Mês';
      case AppLanguage.english:
        return 'This Month';
      case AppLanguage.french:
        return 'Ce Mois';
    }
  }

  String get jobInterviewStatus {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Status da Entrevista';
      case AppLanguage.english:
        return 'Interview Status';
      case AppLanguage.french:
        return 'Statut de l\'Entretien';
    }
  }

  String get jobInterviewStatusScheduled {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Agendado';
      case AppLanguage.english:
        return 'Scheduled';
      case AppLanguage.french:
        return 'Programmé';
    }
  }

  String get jobInterviewStatusCompleted {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Concluído';
      case AppLanguage.english:
        return 'Completed';
      case AppLanguage.french:
        return 'Terminé';
    }
  }

  String get jobInterviewStatusCancelled {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Cancelado';
      case AppLanguage.english:
        return 'Cancelled';
      case AppLanguage.french:
        return 'Annulé';
    }
  }

  String get jobInterviewStatusPending {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Pendente';
      case AppLanguage.english:
        return 'Pending';
      case AppLanguage.french:
        return 'En Attente';
    }
  }

  String get jobScheduled {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Agendado';
      case AppLanguage.english:
        return 'Scheduled';
      case AppLanguage.french:
        return 'Programmé';
    }
  }

  String get jobCompleted {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Concluído';
      case AppLanguage.english:
        return 'Completed';
      case AppLanguage.french:
        return 'Terminé';
    }
  }

  String get jobCancelled {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Cancelado';
      case AppLanguage.english:
        return 'Cancelled';
      case AppLanguage.french:
        return 'Annulé';
    }
  }

  String get jobPending {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Pendente';
      case AppLanguage.english:
        return 'Pending';
      case AppLanguage.french:
        return 'En Attente';
    }
  }

  String get jobNoInterviews {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nenhuma entrevista encontrada';
      case AppLanguage.english:
        return 'No interviews found';
      case AppLanguage.french:
        return 'Aucun entretien trouvé';
    }
  }

  String get jobType {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tipo';
      case AppLanguage.english:
        return 'Type';
      case AppLanguage.french:
        return 'Type';
    }
  }

  String get jobStatus {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Status';
      case AppLanguage.english:
        return 'Status';
      case AppLanguage.french:
        return 'Statut';
    }
  }

  String get jobNoCVs {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nenhum CV encontrado';
      case AppLanguage.english:
        return 'No CVs found';
      case AppLanguage.french:
        return 'Aucun CV trouvé';
    }
  }

  String get jobNoApplications {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nenhuma candidatura encontrada';
      case AppLanguage.english:
        return 'No applications found';
      case AppLanguage.french:
        return 'Aucune candidature trouvée';
    }
  }

  String get jobApplied {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Candidatado';
      case AppLanguage.english:
        return 'Applied';
      case AppLanguage.french:
        return 'Postulé';
    }
  }

  String get jobInReview {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Em Análise';
      case AppLanguage.english:
        return 'In Review';
      case AppLanguage.french:
        return 'En Cours d\'Examen';
    }
  }

  String get jobInterviewScheduled {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Entrevista Agendada';
      case AppLanguage.english:
        return 'Interview Scheduled';
      case AppLanguage.french:
        return 'Entretien Programmé';
    }
  }

  String get jobRejected {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Rejeitado';
      case AppLanguage.english:
        return 'Rejected';
      case AppLanguage.french:
        return 'Rejeté';
    }
  }

  String get jobAccepted {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Aceito';
      case AppLanguage.english:
        return 'Accepted';
      case AppLanguage.french:
        return 'Accepté';
    }
  }

  String get jobWithdrawn {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Retirado';
      case AppLanguage.english:
        return 'Withdrawn';
      case AppLanguage.french:
        return 'Retiré';
    }
  }

  String get jobAddExperience {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Adicionar Experiência';
      case AppLanguage.english:
        return 'Add Experience';
      case AppLanguage.french:
        return 'Ajouter Expérience';
    }
  }

  String get jobAddProject {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Adicionar Projeto';
      case AppLanguage.english:
        return 'Add Project';
      case AppLanguage.french:
        return 'Ajouter Projet';
    }
  }

  String get jobAddEducation {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Adicionar Educação';
      case AppLanguage.english:
        return 'Add Education';
      case AppLanguage.french:
        return 'Ajouter Éducation';
    }
  }

  String get jobPosition {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Cargo';
      case AppLanguage.english:
        return 'Position';
      case AppLanguage.french:
        return 'Poste';
    }
  }

  String get jobStartDate {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Data de Início';
      case AppLanguage.english:
        return 'Start Date';
      case AppLanguage.french:
        return 'Date de Début';
    }
  }

  String get jobEndDate {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Data de Fim';
      case AppLanguage.english:
        return 'End Date';
      case AppLanguage.french:
        return 'Date de Fin';
    }
  }

  String get jobCurrentlyWorking {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Trabalhando Atualmente';
      case AppLanguage.english:
        return 'Currently Working';
      case AppLanguage.french:
        return 'Travaille Actuellement';
    }
  }

  String get jobAchievements {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Conquistas';
      case AppLanguage.english:
        return 'Achievements';
      case AppLanguage.french:
        return 'Réalisations';
    }
  }

  String get jobTechnologies {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tecnologias';
      case AppLanguage.english:
        return 'Technologies';
      case AppLanguage.french:
        return 'Technologies';
    }
  }

  String get jobRepository {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Repositório';
      case AppLanguage.english:
        return 'Repository';
      case AppLanguage.french:
        return 'Dépôt';
    }
  }

  String get jobProjectURL {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'URL do Projeto';
      case AppLanguage.english:
        return 'Project URL';
      case AppLanguage.french:
        return 'URL du Projet';
    }
  }

  String get jobDegree {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Grau';
      case AppLanguage.english:
        return 'Degree';
      case AppLanguage.french:
        return 'Diplôme';
    }
  }

  String get jobInstitution {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Instituição';
      case AppLanguage.english:
        return 'Institution';
      case AppLanguage.french:
        return 'Institution';
    }
  }

  String get jobField {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Área';
      case AppLanguage.english:
        return 'Field';
      case AppLanguage.french:
        return 'Domaine';
    }
  }

  String get jobGrade {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nota';
      case AppLanguage.english:
        return 'Grade';
      case AppLanguage.french:
        return 'Note';
    }
  }

  String get jobCreatePage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Criar Página';
      case AppLanguage.english:
        return 'Create Page';
      case AppLanguage.french:
        return 'Créer Page';
    }
  }

  String get jobEditPage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Editar Página';
      case AppLanguage.english:
        return 'Edit Page';
      case AppLanguage.french:
        return 'Modifier Page';
    }
  }

  String get jobPageCreated {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Página criada com sucesso';
      case AppLanguage.english:
        return 'Page created successfully';
      case AppLanguage.french:
        return 'Page créée avec succès';
    }
  }

  String get jobCVCreated {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'CV criado com sucesso';
      case AppLanguage.english:
        return 'CV created successfully';
      case AppLanguage.french:
        return 'CV créé avec succès';
    }
  }

  String get jobInterviewCreated {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Entrevista criada com sucesso';
      case AppLanguage.english:
        return 'Interview created successfully';
      case AppLanguage.french:
        return 'Entretien créé avec succès';
    }
  }

  String get jobApplicationCreated {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Candidatura criada com sucesso';
      case AppLanguage.english:
        return 'Application created successfully';
      case AppLanguage.french:
        return 'Candidature créée avec succès';
    }
  }

  String get jobErrorCreatingCV {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao criar CV';
      case AppLanguage.english:
        return 'Error creating CV';
      case AppLanguage.french:
        return 'Erreur lors de la création du CV';
    }
  }

  String get jobErrorCreatingInterview {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao criar entrevista';
      case AppLanguage.english:
        return 'Error creating interview';
      case AppLanguage.french:
        return 'Erreur lors de la création de l\'entretien';
    }
  }

  String get jobErrorCreatingApplication {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao criar candidatura';
      case AppLanguage.english:
        return 'Error creating application';
      case AppLanguage.french:
        return 'Erreur lors de la création de la candidature';
    }
  }

  String get jobSelectCV {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Selecionar CV';
      case AppLanguage.english:
        return 'Select CV';
      case AppLanguage.french:
        return 'Sélectionner CV';
    }
  }

  String get jobLinkedCV {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'CV Vinculado';
      case AppLanguage.english:
        return 'Linked CV';
      case AppLanguage.french:
        return 'CV Lié';
    }
  }

  String get jobLinkedApplication {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Candidatura Vinculada';
      case AppLanguage.english:
        return 'Linked Application';
      case AppLanguage.french:
        return 'Candidature Liée';
    }
  }

  String get jobAIGenerating {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Gerando com IA...';
      case AppLanguage.english:
        return 'Generating with AI...';
      case AppLanguage.french:
        return 'Génération avec IA...';
    }
  }

  String get jobAIGenerationComplete {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Geração da IA concluída';
      case AppLanguage.english:
        return 'AI generation completed';
      case AppLanguage.french:
        return 'Génération IA terminée';
    }
  }

  String get jobPDFExported {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'PDF exportado com sucesso';
      case AppLanguage.english:
        return 'PDF exported successfully';
      case AppLanguage.french:
        return 'PDF exporté avec succès';
    }
  }

  String get jobErrorExportingPDF {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao exportar PDF';
      case AppLanguage.english:
        return 'Error exporting PDF';
      case AppLanguage.french:
        return 'Erreur lors de l\'exportation PDF';
    }
  }

  String get jobViewCV {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Ver CV';
      case AppLanguage.english:
        return 'View CV';
      case AppLanguage.french:
        return 'Voir CV';
    }
  }

  String get jobEditCV {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Editar CV';
      case AppLanguage.english:
        return 'Edit CV';
      case AppLanguage.french:
        return 'Modifier CV';
    }
  }

  String get jobDeleteCV {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Deletar CV';
      case AppLanguage.english:
        return 'Delete CV';
      case AppLanguage.french:
        return 'Supprimer CV';
    }
  }

  String get jobAppliedDate {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Data de Candidatura';
      case AppLanguage.english:
        return 'Applied Date';
      case AppLanguage.french:
        return 'Date de Candidature';
    }
  }

  String get jobCreatedAt {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Criado em';
      case AppLanguage.english:
        return 'Created at';
      case AppLanguage.french:
        return 'Créé le';
    }
  }

  String get jobUpdatedAt {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Atualizado em';
      case AppLanguage.english:
        return 'Updated at';
      case AppLanguage.french:
        return 'Mis à jour le';
    }
  }

  String get jobFilterByType {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Filtrar por Tipo';
      case AppLanguage.english:
        return 'Filter by Type';
      case AppLanguage.french:
        return 'Filtrer par Type';
    }
  }

  String get jobFilterByStatus {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Filtrar por Status';
      case AppLanguage.english:
        return 'Filter by Status';
      case AppLanguage.french:
        return 'Filtrer par Statut';
    }
  }

  String get jobSearchPlaceholder {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Pesquisar...';
      case AppLanguage.english:
        return 'Search...';
      case AppLanguage.french:
        return 'Rechercher...';
    }
  }

  String get jobNoInterviewsFound {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nenhuma entrevista encontrada';
      case AppLanguage.english:
        return 'No interviews found';
      case AppLanguage.french:
        return 'Aucun entretien trouvé';
    }
  }

  String get jobNoCVsFound {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nenhum CV encontrado';
      case AppLanguage.english:
        return 'No CVs found';
      case AppLanguage.french:
        return 'Aucun CV trouvé';
    }
  }

  String get jobNoApplicationsFound {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nenhuma candidatura encontrada';
      case AppLanguage.english:
        return 'No applications found';
      case AppLanguage.french:
        return 'Aucune candidature trouvée';
    }
  }

  String get jobWorkspaceOnly {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Disponível apenas no workspace de trabalho';
      case AppLanguage.english:
        return 'Available only in work workspace';
      case AppLanguage.french:
        return 'Disponible uniquement dans l\'espace de travail';
    }
  }

  String errorImportingFromNotion(String error) {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao importar do Notion: $error';
      case AppLanguage.english:
        return 'Error importing from Notion: $error';
      case AppLanguage.french:
        return 'Erreur lors de l\'importation depuis Notion : $error';
    }
  }

  String errorExportingBackup(String error) {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao exportar backup: $error';
      case AppLanguage.english:
        return 'Error exporting backup: $error';
      case AppLanguage.french:
        return 'Erreur lors de l\'exportation de la sauvegarde : $error';
    }
  }

  String get confirmExclusion {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Confirmar exclusão';
      case AppLanguage.english:
        return 'Confirm exclusion';
      case AppLanguage.french:
        return 'Confirmer la suppression';
    }
  }

  String areYouSureYouWantToDeleteBackup(String name) {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tem certeza que deseja excluir o backup $name?';
      case AppLanguage.english:
        return 'Are you sure you want to delete backup $name?';
      case AppLanguage.french:
        return 'Êtes-vous sûr de vouloir supprimer la sauvegarde $name ?';
    }
  }

  String errorDeletingBackup(String error) {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao excluir backup: $error';
      case AppLanguage.english:
        return 'Error deleting backup: $error';
      case AppLanguage.french:
        return 'Erreur lors de la suppression de la sauvegarde : $error';
    }
  }

  String get confirmRestore {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Confirmar restauração';
      case AppLanguage.english:
        return 'Confirm restore';
      case AppLanguage.french:
        return 'Confirmer la restauration';
    }
  }

  String areYouSureYouWantToRestoreBackup(String name) {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tem certeza que deseja restaurar o backup $name?';
      case AppLanguage.english:
        return 'Are you sure you want to restore backup $name?';
      case AppLanguage.french:
        return 'Êtes-vous sûr de vouloir restaurer la sauvegarde $name ?';
    }
  }

  String errorRestoringBackup(String error) {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao restaurar backup: $error';
      case AppLanguage.english:
        return 'Error restoring backup: $error';
      case AppLanguage.french:
        return 'Erreur lors de la restauration de la sauvegarde : $error';
    }
  }

  // --- STRINGS FINAIS PARA BLOQUINHO, AGENDA E BACKUP ---
  String get errorNoContext {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Sem contexto';
      case AppLanguage.english:
        return 'No context';
      case AppLanguage.french:
        return 'Pas de contexte';
    }
  }

  String get page {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Página';
      case AppLanguage.english:
        return 'Page';
      case AppLanguage.french:
        return 'Page';
    }
  }

  String get editorNotInitialized {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Editor não inicializado';
      case AppLanguage.english:
        return 'Editor not initialized';
      case AppLanguage.french:
        return 'Éditeur non initialisé';
    }
  }

  String lineAndColumn(int line, int column) {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Linha $line, Coluna $column';
      case AppLanguage.english:
        return 'Line $line, Column $column';
      case AppLanguage.french:
        return 'Ligne $line, Colonne $column';
    }
  }

  String wordAndCharCount(int words, int chars) {
    switch (_language) {
      case AppLanguage.portuguese:
        return '$words palavras, $chars caracteres';
      case AppLanguage.english:
        return '$words words, $chars chars';
      case AppLanguage.french:
        return '$words mots, $chars caractères';
    }
  }

  String resultsFound(int count) {
    switch (_language) {
      case AppLanguage.portuguese:
        return '$count resultados encontrados';
      case AppLanguage.english:
        return '$count results found';
      case AppLanguage.french:
        return '$count résultats trouvés';
    }
  }

  String get documentSavedSuccessfully {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Documento salvo com sucesso';
      case AppLanguage.english:
        return 'Document saved successfully';
      case AppLanguage.french:
        return 'Document enregistré avec succès';
    }
  }

  String errorSavingDocument(String error) {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao salvar documento: $error';
      case AppLanguage.english:
        return 'Error saving document: $error';
      case AppLanguage.french:
        return 'Erreur lors de l\'enregistrement du document: $error';
    }
  }

  String get documentExportedSuccessfully {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Documento exportado com sucesso';
      case AppLanguage.english:
        return 'Document exported successfully';
      case AppLanguage.french:
        return 'Document exporté avec succès';
    }
  }

  String get numberedList {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Lista numerada';
      case AppLanguage.english:
        return 'Numbered list';
      case AppLanguage.french:
        return 'Liste numérotée';
    }
  }

  String get numberedListDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Crie uma lista numerada';
      case AppLanguage.english:
        return 'Create a numbered list';
      case AppLanguage.french:
        return 'Créer une liste numérotée';
    }
  }

  String get checklist {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Checklist';
      case AppLanguage.english:
        return 'Checklist';
      case AppLanguage.french:
        return 'Checklist';
    }
  }

  String get todoList {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Lista de tarefas';
      case AppLanguage.english:
        return 'To-do list';
      case AppLanguage.french:
        return 'Liste de tâches';
    }
  }

  String get doneItem {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Item concluído';
      case AppLanguage.english:
        return 'Done item';
      case AppLanguage.french:
        return 'Élément terminé';
    }
  }

  String get checkedChecklistItem {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Item marcado';
      case AppLanguage.english:
        return 'Checked item';
      case AppLanguage.french:
        return 'Élément coché';
    }
  }

  String get text {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Texto';
      case AppLanguage.english:
        return 'Text';
      case AppLanguage.french:
        return 'Texte';
    }
  }

  String get simpleParagraph {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Parágrafo simples';
      case AppLanguage.english:
        return 'Simple paragraph';
      case AppLanguage.french:
        return 'Paragraphe simple';
    }
  }

  String get bold {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Negrito';
      case AppLanguage.english:
        return 'Bold';
      case AppLanguage.french:
        return 'Gras';
    }
  }

  String get boldText {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Texto em negrito';
      case AppLanguage.english:
        return 'Bold text';
      case AppLanguage.french:
        return 'Texte en gras';
    }
  }

  String get italic {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Itálico';
      case AppLanguage.english:
        return 'Italic';
      case AppLanguage.french:
        return 'Italique';
    }
  }

  String get italicText {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Texto em itálico';
      case AppLanguage.english:
        return 'Italic text';
      case AppLanguage.french:
        return 'Texte en italique';
    }
  }

  String get strikethrough {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tachado';
      case AppLanguage.english:
        return 'Strikethrough';
      case AppLanguage.french:
        return 'Barré';
    }
  }

  String get strikethroughText {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Texto tachado';
      case AppLanguage.english:
        return 'Strikethrough text';
      case AppLanguage.french:
        return 'Texte barré';
    }
  }

  // --- STRINGS PARA AGENDA ---
  String get itemsOnAgenda {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Itens na agenda';
      case AppLanguage.english:
        return 'Items on agenda';
      case AppLanguage.french:
        return 'Éléments à l\'agenda';
    }
  }

  String get searchInAgenda {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Buscar na agenda';
      case AppLanguage.english:
        return 'Search in agenda';
      case AppLanguage.french:
        return 'Rechercher dans l\'agenda';
    }
  }

  String get calendar {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Calendário';
      case AppLanguage.english:
        return 'Calendar';
      case AppLanguage.french:
        return 'Calendrier';
    }
  }

  String get kanban {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Kanban';
      case AppLanguage.english:
        return 'Kanban';
      case AppLanguage.french:
        return 'Kanban';
    }
  }

  String get overdue {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Atrasado';
      case AppLanguage.english:
        return 'Overdue';
      case AppLanguage.french:
        return 'En retard';
    }
  }

  String get dueSoon {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Vencendo em breve';
      case AppLanguage.english:
        return 'Due soon';
      case AppLanguage.french:
        return 'Bientôt dû';
    }
  }

  String get clear {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Limpar';
      case AppLanguage.english:
        return 'Clear';
      case AppLanguage.french:
        return 'Effacer';
    }
  }

  String get syncWithDatabaseDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Sincronizar com banco de dados';
      case AppLanguage.english:
        return 'Sync with database';
      case AppLanguage.french:
        return 'Synchroniser avec la base de données';
    }
  }

  String get agendaStats {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Estatísticas da agenda';
      case AppLanguage.english:
        return 'Agenda stats';
      case AppLanguage.french:
        return 'Statistiques de l\'agenda';
    }
  }

  String get agendaDashboard {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Painel da agenda';
      case AppLanguage.english:
        return 'Agenda dashboard';
      case AppLanguage.french:
        return 'Tableau de bord de l\'agenda';
    }
  }

  String get thisWeek {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Esta semana';
      case AppLanguage.english:
        return 'This week';
      case AppLanguage.french:
        return 'Cette semaine';
    }
  }

  String get thisMonth {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Este mês';
      case AppLanguage.english:
        return 'This month';
      case AppLanguage.french:
        return 'Ce mois';
    }
  }

  String get noEvents {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nenhum evento';
      case AppLanguage.english:
        return 'No events';
      case AppLanguage.french:
        return 'Aucun événement';
    }
  }

  String get noItemsOnAgenda {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nenhum item na agenda';
      case AppLanguage.english:
        return 'No items on agenda';
      case AppLanguage.french:
        return 'Aucun élément à l\'agenda';
    }
  }

  String get addAnItemToStart {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Adicione um item para começar';
      case AppLanguage.english:
        return 'Add an item to start';
      case AppLanguage.french:
        return 'Ajoutez un élément pour commencer';
    }
  }

  String get addAnEventToStart {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Adicione um evento para começar';
      case AppLanguage.english:
        return 'Add an event to start';
      case AppLanguage.french:
        return 'Ajoutez un événement pour commencer';
    }
  }

  String moreItems(int count) {
    switch (_language) {
      case AppLanguage.portuguese:
        return '+$count itens';
      case AppLanguage.english:
        return '+$count items';
      case AppLanguage.french:
        return '+$count éléments';
    }
  }

  String get noTime {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Sem horário';
      case AppLanguage.english:
        return 'No time';
      case AppLanguage.french:
        return 'Pas d\'heure';
    }
  }

  String get total {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Total';
      case AppLanguage.english:
        return 'Total';
      case AppLanguage.french:
        return 'Total';
    }
  }

  String get events {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Eventos';
      case AppLanguage.english:
        return 'Events';
      case AppLanguage.french:
        return 'Événements';
    }
  }

  String get tasks {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tarefas';
      case AppLanguage.english:
        return 'Tasks';
      case AppLanguage.french:
        return 'Tâches';
    }
  }

  String get meetings {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Reuniões';
      case AppLanguage.english:
        return 'Meetings';
      case AppLanguage.french:
        return 'Réunions';
    }
  }

  String get reminders {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Lembretes';
      case AppLanguage.english:
        return 'Reminders';
      case AppLanguage.french:
        return 'Rappels';
    }
  }

  String get completed {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Concluído';
      case AppLanguage.english:
        return 'Completed';
      case AppLanguage.french:
        return 'Terminé';
    }
  }

  String itemsSyncedWithDatabase(int count) {
    switch (_language) {
      case AppLanguage.portuguese:
        return '$count itens sincronizados com banco de dados';
      case AppLanguage.english:
        return '$count items synced with database';
      case AppLanguage.french:
        return '$count éléments synchronisés avec la base de données';
    }
  }

  String get title {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Título';
      case AppLanguage.english:
        return 'Title';
      case AppLanguage.french:
        return 'Titre';
    }
  }

  String get typeItemTitle {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Digite o título do item';
      case AppLanguage.english:
        return 'Type item title';
      case AppLanguage.french:
        return 'Tapez le titre de l\'élément';
    }
  }

  String get titleIsRequired {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Título é obrigatório';
      case AppLanguage.english:
        return 'Title is required';
      case AppLanguage.french:
        return 'Le titre est requis';
    }
  }

  String get type {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tipo';
      case AppLanguage.english:
        return 'Type';
      case AppLanguage.french:
        return 'Type';
    }
  }

  String get status {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Status';
      case AppLanguage.english:
        return 'Status';
      case AppLanguage.french:
        return 'Statut';
    }
  }

  String get priority {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Prioridade';
      case AppLanguage.english:
        return 'Priority';
      case AppLanguage.french:
        return 'Priorité';
    }
  }

  String get description {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Descrição';
      case AppLanguage.english:
        return 'Description';
      case AppLanguage.french:
        return 'Description';
    }
  }

  String get typeDescriptionOptional {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Digite a descrição (opcional)';
      case AppLanguage.english:
        return 'Type description (optional)';
      case AppLanguage.french:
        return 'Tapez la description (optionnel)';
    }
  }

  String get location {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Localização';
      case AppLanguage.english:
        return 'Location';
      case AppLanguage.french:
        return 'Emplacement';
    }
  }

  String get typeLocationOptional {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Digite a localização (opcional)';
      case AppLanguage.english:
        return 'Type location (optional)';
      case AppLanguage.french:
        return 'Tapez l\'emplacement (optionnel)';
    }
  }

  String get startDateTime {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Data/hora de início';
      case AppLanguage.english:
        return 'Start date/time';
      case AppLanguage.french:
        return 'Date/heure de début';
    }
  }

  String get endDateTime {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Data/hora de fim';
      case AppLanguage.english:
        return 'End date/time';
      case AppLanguage.french:
        return 'Date/heure de fin';
    }
  }

  String get deadlineDateTime {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Data/hora limite';
      case AppLanguage.english:
        return 'Deadline date/time';
      case AppLanguage.french:
        return 'Date/heure limite';
    }
  }

  String get allDay {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Dia inteiro';
      case AppLanguage.english:
        return 'All day';
      case AppLanguage.french:
        return 'Toute la journée';
    }
  }

  String get recurring {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Recorrente';
      case AppLanguage.english:
        return 'Recurring';
      case AppLanguage.french:
        return 'Récurrent';
    }
  }

  String get attendees {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Participantes';
      case AppLanguage.english:
        return 'Attendees';
      case AppLanguage.french:
        return 'Participants';
    }
  }

  String get typeAttendeesCommaSeparated {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Digite os participantes separados por vírgula';
      case AppLanguage.english:
        return 'Type attendees comma separated';
      case AppLanguage.french:
        return 'Tapez les participants séparés par des virgules';
    }
  }

  String get tags {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tags';
      case AppLanguage.english:
        return 'Tags';
      case AppLanguage.french:
        return 'Étiquettes';
    }
  }

  String get typeTagsCommaSeparated {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Digite as tags separadas por vírgula';
      case AppLanguage.english:
        return 'Type tags comma separated';
      case AppLanguage.french:
        return 'Tapez les étiquettes séparées par des virgules';
    }
  }

  String get update {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Atualizar';
      case AppLanguage.english:
        return 'Update';
      case AppLanguage.french:
        return 'Mettre à jour';
    }
  }

  String get create {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Criar';
      case AppLanguage.english:
        return 'Create';
      case AppLanguage.french:
        return 'Créer';
    }
  }

  String get selectDateTime {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Selecionar data/hora';
      case AppLanguage.english:
        return 'Select date/time';
      case AppLanguage.french:
        return 'Sélectionner date/heure';
    }
  }

  String get event {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Evento';
      case AppLanguage.english:
        return 'Event';
      case AppLanguage.french:
        return 'Événement';
    }
  }

  String get task {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tarefa';
      case AppLanguage.english:
        return 'Task';
      case AppLanguage.french:
        return 'Tâche';
    }
  }

  String get reminder {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Lembrete';
      case AppLanguage.english:
        return 'Reminder';
      case AppLanguage.french:
        return 'Rappel';
    }
  }

  String get meeting {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Reunião';
      case AppLanguage.english:
        return 'Meeting';
      case AppLanguage.french:
        return 'Réunion';
    }
  }

  String get statusCancelled {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Cancelado';
      case AppLanguage.english:
        return 'Cancelled';
      case AppLanguage.french:
        return 'Annulé';
    }
  }

  String get priorityLow {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Baixa';
      case AppLanguage.english:
        return 'Low';
      case AppLanguage.french:
        return 'Faible';
    }
  }

  String get priorityMedium {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Média';
      case AppLanguage.english:
        return 'Medium';
      case AppLanguage.french:
        return 'Moyenne';
    }
  }

  String get priorityHigh {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Alta';
      case AppLanguage.english:
        return 'High';
      case AppLanguage.french:
        return 'Élevée';
    }
  }

  String get priorityUrgent {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Urgente';
      case AppLanguage.english:
        return 'Urgent';
      case AppLanguage.french:
        return 'Urgent';
    }
  }

  String get edit {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Editar';
      case AppLanguage.english:
        return 'Edit';
      case AppLanguage.french:
        return 'Modifier';
    }
  }

  String get copy {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Copiar';
      case AppLanguage.english:
        return 'Copy';
      case AppLanguage.french:
        return 'Copier';
    }
  }

  String get complete {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Concluir';
      case AppLanguage.english:
        return 'Complete';
      case AppLanguage.french:
        return 'Terminer';
    }
  }

  String get noItems {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nenhum item';
      case AppLanguage.english:
        return 'No items';
      case AppLanguage.french:
        return 'Aucun élément';
    }
  }

  String get dragItemsHere {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Arraste itens aqui';
      case AppLanguage.english:
        return 'Drag items here';
      case AppLanguage.french:
        return 'Glissez les éléments ici';
    }
  }

  String get date {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Data';
      case AppLanguage.english:
        return 'Date';
      case AppLanguage.french:
        return 'Date';
    }
  }

  String get time {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Hora';
      case AppLanguage.english:
        return 'Time';
      case AppLanguage.french:
        return 'Heure';
    }
  }

  String get createdAt {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Criado em';
      case AppLanguage.english:
        return 'Created at';
      case AppLanguage.french:
        return 'Créé le';
    }
  }

  String get updatedAt {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Atualizado em';
      case AppLanguage.english:
        return 'Updated at';
      case AppLanguage.french:
        return 'Mis à jour le';
    }
  }

  String areYouSureYouWantToDelete(String itemName) {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tem certeza que deseja excluir "$itemName"?';
      case AppLanguage.english:
        return 'Are you sure you want to delete "$itemName"?';
      case AppLanguage.french:
        return 'Êtes-vous sûr de vouloir supprimer "$itemName"?';
    }
  }

  String noEventsForDate(String date) {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nenhum evento para $date';
      case AppLanguage.english:
        return 'No events for $date';
      case AppLanguage.french:
        return 'Aucun événement pour $date';
    }
  }

  // --- STRINGS PARA BLOQUINHO ---
  String get profileOrWorkspaceNotAvailable {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Perfil ou workspace não disponível';
      case AppLanguage.english:
        return 'Profile or workspace not available';
      case AppLanguage.french:
        return 'Profil ou workspace non disponible';
    }
  }

  String get collapse {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Recolher';
      case AppLanguage.english:
        return 'Collapse';
      case AppLanguage.french:
        return 'Réduire';
    }
  }

  String get expand {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Expandir';
      case AppLanguage.english:
        return 'Expand';
      case AppLanguage.french:
        return 'Développer';
    }
  }

  String get overview {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Visão geral';
      case AppLanguage.english:
        return 'Overview';
      case AppLanguage.french:
        return 'Aperçu';
    }
  }

  String get totalPages {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Total de páginas';
      case AppLanguage.english:
        return 'Total pages';
      case AppLanguage.french:
        return 'Pages totales';
    }
  }

  String get rootPages {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Páginas raiz';
      case AppLanguage.english:
        return 'Root pages';
      case AppLanguage.french:
        return 'Pages racines';
    }
  }

  String get subpages {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Subpáginas';
      case AppLanguage.english:
        return 'Subpages';
      case AppLanguage.french:
        return 'Sous-pages';
    }
  }

  String get totalContent {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Conteúdo total';
      case AppLanguage.english:
        return 'Total content';
      case AppLanguage.french:
        return 'Contenu total';
    }
  }

  String get averagePerPage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Média por página';
      case AppLanguage.english:
        return 'Average per page';
      case AppLanguage.french:
        return 'Moyenne par page';
    }
  }

  String get recentActivity {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Atividade recente';
      case AppLanguage.english:
        return 'Recent activity';
      case AppLanguage.french:
        return 'Activité récente';
    }
  }

  String get noRecentActivity {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nenhuma atividade recente';
      case AppLanguage.english:
        return 'No recent activity';
      case AppLanguage.french:
        return 'Aucune activité récente';
    }
  }

  String get storageInfo {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Informações de armazenamento';
      case AppLanguage.english:
        return 'Storage info';
      case AppLanguage.french:
        return 'Informations de stockage';
    }
  }

  String get pages {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Páginas';
      case AppLanguage.english:
        return 'Pages';
      case AppLanguage.french:
        return 'Pages';
    }
  }

  String get characters {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Caracteres';
      case AppLanguage.english:
        return 'Characters';
      case AppLanguage.french:
        return 'Caractères';
    }
  }

  String get size {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tamanho';
      case AppLanguage.english:
        return 'Size';
      case AppLanguage.french:
        return 'Taille';
    }
  }

  String get lastUpdate {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Última atualização';
      case AppLanguage.english:
        return 'Last update';
      case AppLanguage.french:
        return 'Dernière mise à jour';
    }
  }

  String get quickActions {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Ações rápidas';
      case AppLanguage.english:
        return 'Quick actions';
      case AppLanguage.french:
        return 'Actions rapides';
    }
  }

  String get createNewPage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Criar nova página';
      case AppLanguage.english:
        return 'Create new page';
      case AppLanguage.french:
        return 'Créer une nouvelle page';
    }
  }

  String get createSubpage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Criar subpágina';
      case AppLanguage.english:
        return 'Create subpage';
      case AppLanguage.french:
        return 'Créer une sous-page';
    }
  }

  String get importFromNotion {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Importar do Notion';
      case AppLanguage.english:
        return 'Import from Notion';
      case AppLanguage.french:
        return 'Importer depuis Notion';
    }
  }

  String get exportAllPages {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Exportar todas as páginas';
      case AppLanguage.english:
        return 'Export all pages';
      case AppLanguage.french:
        return 'Exporter toutes les pages';
    }
  }

  String get error {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro';
      case AppLanguage.english:
        return 'Error';
      case AppLanguage.french:
        return 'Erreur';
    }
  }

  String get dashboardError {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro no painel';
      case AppLanguage.english:
        return 'Dashboard error';
      case AppLanguage.french:
        return 'Erreur du tableau de bord';
    }
  }

  String get noParentPageAvailable {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nenhuma página pai disponível';
      case AppLanguage.english:
        return 'No parent page available';
      case AppLanguage.french:
        return 'Aucune page parent disponible';
    }
  }

  String get selectParentPage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Selecionar página pai';
      case AppLanguage.english:
        return 'Select parent page';
      case AppLanguage.french:
        return 'Sélectionner la page parent';
    }
  }

  String get searchPages {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Buscar páginas';
      case AppLanguage.english:
        return 'Search pages';
      case AppLanguage.french:
        return 'Rechercher des pages';
    }
  }

  String get noPagesAvailable {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nenhuma página disponível';
      case AppLanguage.english:
        return 'No pages available';
      case AppLanguage.french:
        return 'Aucune page disponible';
    }
  }

  String noPagesFoundFor(String query) {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nenhuma página encontrada para "$query"';
      case AppLanguage.english:
        return 'No pages found for "$query"';
      case AppLanguage.french:
        return 'Aucune page trouvée pour "$query"';
    }
  }

  String subpageOf(String parentTitle) {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Subpágina de $parentTitle';
      case AppLanguage.english:
        return 'Subpage of $parentTitle';
      case AppLanguage.french:
        return 'Sous-page de $parentTitle';
    }
  }

  String get rootPage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Página raiz';
      case AppLanguage.english:
        return 'Root page';
      case AppLanguage.french:
        return 'Page racine';
    }
  }

  String get untitledDocument {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Documento sem título';
      case AppLanguage.english:
        return 'Untitled document';
      case AppLanguage.french:
        return 'Document sans titre';
    }
  }

  // --- STRINGS PARA BACKUP ---

  String get workspaces {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Workspaces';
      case AppLanguage.english:
        return 'Workspaces';
      case AppLanguage.french:
        return 'Workspaces';
    }
  }

  String get blocks {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Blocos';
      case AppLanguage.english:
        return 'Blocks';
      case AppLanguage.french:
        return 'Blocs';
    }
  }

  String get restoreNotImplemented {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Restauração não implementada';
      case AppLanguage.english:
        return 'Restore not implemented';
      case AppLanguage.french:
        return 'Restauration non implémentée';
    }
  }

  String get noBackupProvided {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nenhum backup fornecido';
      case AppLanguage.english:
        return 'No backup provided';
      case AppLanguage.french:
        return 'Aucune sauvegarde fournie';
    }
  }

  String get restoreBackup {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Restaurar backup';
      case AppLanguage.english:
        return 'Restore backup';
      case AppLanguage.french:
        return 'Restaurer la sauvegarde';
    }
  }

  String get loadingBackupInfo {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Carregando informações do backup';
      case AppLanguage.english:
        return 'Loading backup info';
      case AppLanguage.french:
        return 'Chargement des informations de sauvegarde';
    }
  }

  String get restoring {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Restaurando';
      case AppLanguage.english:
        return 'Restoring';
      case AppLanguage.french:
        return 'Restauration';
    }
  }

  String get errorLoadingBackup {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao carregar backup';
      case AppLanguage.english:
        return 'Error loading backup';
      case AppLanguage.french:
        return 'Erreur lors du chargement de la sauvegarde';
    }
  }

  String get backupInfo {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Informações do backup';
      case AppLanguage.english:
        return 'Backup info';
      case AppLanguage.french:
        return 'Informations de sauvegarde';
    }
  }

  String get restoreOptions {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Opções de restauração';
      case AppLanguage.english:
        return 'Restore options';
      case AppLanguage.french:
        return 'Options de restauration';
    }
  }

  String get replaceExistingData {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Substituir dados existentes';
      case AppLanguage.english:
        return 'Replace existing data';
      case AppLanguage.french:
        return 'Remplacer les données existantes';
    }
  }

  String get allDataWillBeRemoved {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Todos os dados serão removidos';
      case AppLanguage.english:
        return 'All data will be removed';
      case AppLanguage.french:
        return 'Toutes les données seront supprimées';
    }
  }

  String get backupDataWillBeMerged {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Dados do backup serão mesclados';
      case AppLanguage.english:
        return 'Backup data will be merged';
      case AppLanguage.french:
        return 'Les données de sauvegarde seront fusionnées';
    }
  }

  String get restoreSettings {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Restaurar configurações';
      case AppLanguage.english:
        return 'Restore settings';
      case AppLanguage.french:
        return 'Restaurer les paramètres';
    }
  }

  String get includeThemeLanguagePreferences {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Incluir preferências de tema e idioma';
      case AppLanguage.english:
        return 'Include theme and language preferences';
      case AppLanguage.french:
        return 'Inclure les préférences de thème et de langue';
    }
  }

  String get attention {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Atenção';
      case AppLanguage.english:
        return 'Attention';
      case AppLanguage.french:
        return 'Attention';
    }
  }

  String get thisActionWillPermanentlyRemoveData {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Esta ação removerá permanentemente os dados';
      case AppLanguage.english:
        return 'This action will permanently remove data';
      case AppLanguage.french:
        return 'Cette action supprimera définitivement les données';
    }
  }

  String get thisActionWillModifyData {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Esta ação modificará os dados';
      case AppLanguage.english:
        return 'This action will modify data';
      case AppLanguage.french:
        return 'Cette action modifiera les données';
    }
  }

  String get backupRestoredSuccessfully {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Backup restaurado com sucesso';
      case AppLanguage.english:
        return 'Backup restored successfully';
      case AppLanguage.french:
        return 'Sauvegarde restaurée avec succès';
    }
  }

  String unexpectedError(String error) {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro inesperado: $error';
      case AppLanguage.english:
        return 'Unexpected error: $error';
      case AppLanguage.french:
        return 'Erreur inattendue: $error';
    }
  }

  String get importBackup {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Importar backup';
      case AppLanguage.english:
        return 'Import backup';
      case AppLanguage.french:
        return 'Importer la sauvegarde';
    }
  }

  String get automaticBackup {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Backup automático';
      case AppLanguage.english:
        return 'Automatic backup';
      case AppLanguage.french:
        return 'Sauvegarde automatique';
    }
  }

  String get manualBackup {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Backup manual';
      case AppLanguage.english:
        return 'Manual backup';
      case AppLanguage.french:
        return 'Sauvegarde manuelle';
    }
  }

  // --- STRINGS PARA COMANDOS SLASH ---
  String get inlineCode {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Código inline';
      case AppLanguage.english:
        return 'Inline code';
      case AppLanguage.french:
        return 'Code en ligne';
    }
  }

  String get inlineCodeDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Código inline com formatação';
      case AppLanguage.english:
        return 'Inline code with formatting';
      case AppLanguage.french:
        return 'Code en ligne avec formatage';
    }
  }

  String get quote {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Citação';
      case AppLanguage.english:
        return 'Quote';
      case AppLanguage.french:
        return 'Citation';
    }
  }

  String get quoteBlock {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Bloco de citação';
      case AppLanguage.english:
        return 'Quote block';
      case AppLanguage.french:
        return 'Bloc de citation';
    }
  }

  String get callout {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Callout';
      case AppLanguage.english:
        return 'Callout';
      case AppLanguage.french:
        return 'Callout';
    }
  }

  String get calloutBlock {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Bloco callout';
      case AppLanguage.english:
        return 'Callout block';
      case AppLanguage.french:
        return 'Bloc callout';
    }
  }

  String get codeBlock {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Bloco de código';
      case AppLanguage.english:
        return 'Code block';
      case AppLanguage.french:
        return 'Bloc de code';
    }
  }

  String get codeBlockWithSyntaxHighlighting {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Bloco de código com destaque de sintaxe';
      case AppLanguage.english:
        return 'Code block with syntax highlighting';
      case AppLanguage.french:
        return 'Bloc de code avec coloration syntaxique';
    }
  }

  String get javascriptCode {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Código JavaScript';
      case AppLanguage.english:
        return 'JavaScript code';
      case AppLanguage.french:
        return 'Code JavaScript';
    }
  }

  String get pythonCode {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Código Python';
      case AppLanguage.english:
        return 'Python code';
      case AppLanguage.french:
        return 'Code Python';
    }
  }

  String get dartCode {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Código Dart';
      case AppLanguage.english:
        return 'Dart code';
      case AppLanguage.french:
        return 'Code Dart';
    }
  }

  String get htmlCode {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Código HTML';
      case AppLanguage.english:
        return 'HTML code';
      case AppLanguage.french:
        return 'Code HTML';
    }
  }

  String get cssCode {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Código CSS';
      case AppLanguage.english:
        return 'CSS code';
      case AppLanguage.french:
        return 'Code CSS';
    }
  }

  String get jsonCode {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Código JSON';
      case AppLanguage.english:
        return 'JSON code';
      case AppLanguage.french:
        return 'Code JSON';
    }
  }

  String get latexEquation {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Equação LaTeX';
      case AppLanguage.english:
        return 'LaTeX equation';
      case AppLanguage.french:
        return 'Équation LaTeX';
    }
  }

  String get inlineEquation {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Equação inline';
      case AppLanguage.english:
        return 'Inline equation';
      case AppLanguage.french:
        return 'Équation en ligne';
    }
  }

  String get inlineEquationDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Equação matemática inline';
      case AppLanguage.english:
        return 'Inline mathematical equation';
      case AppLanguage.french:
        return 'Équation mathématique en ligne';
    }
  }

  String get integral {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Integral';
      case AppLanguage.english:
        return 'Integral';
      case AppLanguage.french:
        return 'Intégrale';
    }
  }

  String get integralSymbol {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Símbolo de integral';
      case AppLanguage.english:
        return 'Integral symbol';
      case AppLanguage.french:
        return 'Symbole d\'intégrale';
    }
  }

  String get summation {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Somatório';
      case AppLanguage.english:
        return 'Summation';
      case AppLanguage.french:
        return 'Sommation';
    }
  }

  String get summationSymbol {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Símbolo de somatório';
      case AppLanguage.english:
        return 'Summation symbol';
      case AppLanguage.french:
        return 'Symbole de sommation';
    }
  }

  String get product {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Produtório';
      case AppLanguage.english:
        return 'Product';
      case AppLanguage.french:
        return 'Produit';
    }
  }

  String get productSymbol {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Símbolo de produtório';
      case AppLanguage.english:
        return 'Product symbol';
      case AppLanguage.french:
        return 'Symbole de produit';
    }
  }

  String get limit {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Limite';
      case AppLanguage.english:
        return 'Limit';
      case AppLanguage.french:
        return 'Limite';
    }
  }

  String get limitSymbol {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Símbolo de limite';
      case AppLanguage.english:
        return 'Limit symbol';
      case AppLanguage.french:
        return 'Symbole de limite';
    }
  }

  String get derivative {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Derivada';
      case AppLanguage.english:
        return 'Derivative';
      case AppLanguage.french:
        return 'Dérivée';
    }
  }

  String get derivativeSymbol {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Símbolo de derivada';
      case AppLanguage.english:
        return 'Derivative symbol';
      case AppLanguage.french:
        return 'Symbole de dérivée';
    }
  }

  String get matrix {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Matriz';
      case AppLanguage.english:
        return 'Matrix';
      case AppLanguage.french:
        return 'Matrice';
    }
  }

  String get latexMatrix {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Matriz LaTeX';
      case AppLanguage.english:
        return 'LaTeX matrix';
      case AppLanguage.french:
        return 'Matrice LaTeX';
    }
  }

  String get mermaidDiagram {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Diagrama Mermaid';
      case AppLanguage.english:
        return 'Mermaid diagram';
      case AppLanguage.french:
        return 'Diagramme Mermaid';
    }
  }

  String get mermaidDiagramDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Diagrama criado com Mermaid';
      case AppLanguage.english:
        return 'Diagram created with Mermaid';
      case AppLanguage.french:
        return 'Diagramme créé avec Mermaid';
    }
  }

  String get flowchart {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Fluxograma';
      case AppLanguage.english:
        return 'Flowchart';
      case AppLanguage.french:
        return 'Organigramme';
    }
  }

  String get flowchartDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Diagrama de fluxo';
      case AppLanguage.english:
        return 'Flow diagram';
      case AppLanguage.french:
        return 'Diagramme de flux';
    }
  }

  String get sequenceDiagram {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Diagrama de sequência';
      case AppLanguage.english:
        return 'Sequence diagram';
      case AppLanguage.french:
        return 'Diagramme de séquence';
    }
  }

  String get sequenceDiagramDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Diagrama de sequência UML';
      case AppLanguage.english:
        return 'UML sequence diagram';
      case AppLanguage.french:
        return 'Diagramme de séquence UML';
    }
  }

  String get classDiagram {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Diagrama de classe';
      case AppLanguage.english:
        return 'Class diagram';
      case AppLanguage.french:
        return 'Diagramme de classe';
    }
  }

  String get umlClassDiagram {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Diagrama de classe UML';
      case AppLanguage.english:
        return 'UML class diagram';
      case AppLanguage.french:
        return 'Diagramme de classe UML';
    }
  }

  String get erDiagram {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Diagrama ER';
      case AppLanguage.english:
        return 'ER diagram';
      case AppLanguage.french:
        return 'Diagramme ER';
    }
  }

  String get erDiagramDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Diagrama entidade-relacionamento';
      case AppLanguage.english:
        return 'Entity-relationship diagram';
      case AppLanguage.french:
        return 'Diagramme entité-relation';
    }
  }

  String get ganttChart {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Gráfico de Gantt';
      case AppLanguage.english:
        return 'Gantt chart';
      case AppLanguage.french:
        return 'Diagramme de Gantt';
    }
  }

  String get ganttChartDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Gráfico de cronograma';
      case AppLanguage.english:
        return 'Schedule chart';
      case AppLanguage.french:
        return 'Graphique de planning';
    }
  }

  String get table {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tabela';
      case AppLanguage.english:
        return 'Table';
      case AppLanguage.french:
        return 'Tableau';
    }
  }

  String get simpleTable {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tabela simples';
      case AppLanguage.english:
        return 'Simple table';
      case AppLanguage.french:
        return 'Tableau simple';
    }
  }

  String get table2x2 {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tabela 2x2';
      case AppLanguage.english:
        return '2x2 table';
      case AppLanguage.french:
        return 'Tableau 2x2';
    }
  }

  String get table2Columns {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tabela 2 colunas';
      case AppLanguage.english:
        return '2 columns table';
      case AppLanguage.french:
        return 'Tableau 2 colonnes';
    }
  }

  String get table3x3 {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tabela 3x3';
      case AppLanguage.english:
        return '3x3 table';
      case AppLanguage.french:
        return 'Tableau 3x3';
    }
  }

  String get table3Columns {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tabela 3 colunas';
      case AppLanguage.english:
        return '3 columns table';
      case AppLanguage.french:
        return 'Tableau 3 colonnes';
    }
  }

  String get table4x4 {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tabela 4x4';
      case AppLanguage.english:
        return '4x4 table';
      case AppLanguage.french:
        return 'Tableau 4x4';
    }
  }

  String get table4Columns {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tabela 4 colunas';
      case AppLanguage.english:
        return '4 columns table';
      case AppLanguage.french:
        return 'Tableau 4 colonnes';
    }
  }

  String get image {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Imagem';
      case AppLanguage.english:
        return 'Image';
      case AppLanguage.french:
        return 'Image';
    }
  }

  String get insertImage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Inserir imagem';
      case AppLanguage.english:
        return 'Insert image';
      case AppLanguage.french:
        return 'Insérer une image';
    }
  }

  String get video {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Vídeo';
      case AppLanguage.english:
        return 'Video';
      case AppLanguage.french:
        return 'Vidéo';
    }
  }

  String get insertVideo {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Inserir vídeo';
      case AppLanguage.english:
        return 'Insert video';
      case AppLanguage.french:
        return 'Insérer une vidéo';
    }
  }

  String get audio {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Áudio';
      case AppLanguage.english:
        return 'Audio';
      case AppLanguage.french:
        return 'Audio';
    }
  }

  String get insertAudio {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Inserir áudio';
      case AppLanguage.english:
        return 'Insert audio';
      case AppLanguage.french:
        return 'Insérer un audio';
    }
  }

  String get file {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Arquivo';
      case AppLanguage.english:
        return 'File';
      case AppLanguage.french:
        return 'Fichier';
    }
  }

  String get linkToFile {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Link para arquivo';
      case AppLanguage.english:
        return 'Link to file';
      case AppLanguage.french:
        return 'Lien vers le fichier';
    }
  }

  String get link {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Link';
      case AppLanguage.english:
        return 'Link';
      case AppLanguage.french:
        return 'Lien';
    }
  }

  String get externalLink {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Link externo';
      case AppLanguage.english:
        return 'External link';
      case AppLanguage.french:
        return 'Lien externe';
    }
  }

  String get pageLink {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Link de página';
      case AppLanguage.english:
        return 'Page link';
      case AppLanguage.french:
        return 'Lien de page';
    }
  }

  String get linkToAnotherPage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Link para outra página';
      case AppLanguage.english:
        return 'Link to another page';
      case AppLanguage.french:
        return 'Lien vers une autre page';
    }
  }

  String get emailLink {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Link de email';
      case AppLanguage.english:
        return 'Email link';
      case AppLanguage.french:
        return 'Lien email';
    }
  }

  String get divider {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Divisor';
      case AppLanguage.english:
        return 'Divider';
      case AppLanguage.french:
        return 'Séparateur';
    }
  }

  String get dividerLine {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Linha divisória';
      case AppLanguage.english:
        return 'Divider line';
      case AppLanguage.french:
        return 'Ligne de séparation';
    }
  }

  String get space {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Espaço';
      case AppLanguage.english:
        return 'Space';
      case AppLanguage.french:
        return 'Espace';
    }
  }

  String get verticalSpace {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Espaço vertical';
      case AppLanguage.english:
        return 'Vertical space';
      case AppLanguage.french:
        return 'Espace vertical';
    }
  }

  String get columns {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Colunas';
      case AppLanguage.english:
        return 'Columns';
      case AppLanguage.french:
        return 'Colonnes';
    }
  }

  String get columnLayout {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Layout em colunas';
      case AppLanguage.english:
        return 'Column layout';
      case AppLanguage.french:
        return 'Mise en page en colonnes';
    }
  }

  String get embed {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Incorporar';
      case AppLanguage.english:
        return 'Embed';
      case AppLanguage.french:
        return 'Intégrer';
    }
  }

  String get embedContent {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Incorporar conteúdo';
      case AppLanguage.english:
        return 'Embed content';
      case AppLanguage.french:
        return 'Intégrer du contenu';
    }
  }

  String get bookmark {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Favorito';
      case AppLanguage.english:
        return 'Bookmark';
      case AppLanguage.french:
        return 'Favori';
    }
  }

  String get saveLink {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Salvar link';
      case AppLanguage.english:
        return 'Save link';
      case AppLanguage.french:
        return 'Sauvegarder le lien';
    }
  }

  String get tableOfContents {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Índice';
      case AppLanguage.english:
        return 'Table of contents';
      case AppLanguage.french:
        return 'Table des matières';
    }
  }

  String get createTableOfContents {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Criar índice';
      case AppLanguage.english:
        return 'Create table of contents';
      case AppLanguage.french:
        return 'Créer la table des matières';
    }
  }

  String get note {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nota';
      case AppLanguage.english:
        return 'Note';
      case AppLanguage.french:
        return 'Note';
    }
  }

  String get noteBlock {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Bloco de nota';
      case AppLanguage.english:
        return 'Note block';
      case AppLanguage.french:
        return 'Bloc de note';
    }
  }

  String get warning {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Aviso';
      case AppLanguage.english:
        return 'Warning';
      case AppLanguage.french:
        return 'Avertissement';
    }
  }

  String get warningBlock {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Bloco de aviso';
      case AppLanguage.english:
        return 'Warning block';
      case AppLanguage.french:
        return 'Bloc d\'avertissement';
    }
  }

  String get errorBlock {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Bloco de erro';
      case AppLanguage.english:
        return 'Error block';
      case AppLanguage.french:
        return 'Bloc d\'erreur';
    }
  }

  String get success {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Sucesso';
      case AppLanguage.english:
        return 'Success';
      case AppLanguage.french:
        return 'Succès';
    }
  }

  String get successBlock {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Bloco de sucesso';
      case AppLanguage.english:
        return 'Success block';
      case AppLanguage.french:
        return 'Bloc de succès';
    }
  }

  String get information {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Informação';
      case AppLanguage.english:
        return 'Information';
      case AppLanguage.french:
        return 'Information';
    }
  }

  String get informationBlock {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Bloco de informação';
      case AppLanguage.english:
        return 'Information block';
      case AppLanguage.french:
        return 'Bloc d\'information';
    }
  }

  String get tip {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Dica';
      case AppLanguage.english:
        return 'Tip';
      case AppLanguage.french:
        return 'Conseil';
    }
  }

  String get tipBlock {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Bloco de dica';
      case AppLanguage.english:
        return 'Tip block';
      case AppLanguage.french:
        return 'Bloc de conseil';
    }
  }

  String get spoiler {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Spoiler';
      case AppLanguage.english:
        return 'Spoiler';
      case AppLanguage.french:
        return 'Spoiler';
    }
  }

  String get hiddenContent {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Conteúdo oculto';
      case AppLanguage.english:
        return 'Hidden content';
      case AppLanguage.french:
        return 'Contenu caché';
    }
  }

  String get collapsible {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Recolhível';
      case AppLanguage.english:
        return 'Collapsible';
      case AppLanguage.french:
        return 'Rétractable';
    }
  }

  String get collapsibleSection {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Seção recolhível';
      case AppLanguage.english:
        return 'Collapsible section';
      case AppLanguage.french:
        return 'Section rétractable';
    }
  }

  String get badge {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Badge';
      case AppLanguage.english:
        return 'Badge';
      case AppLanguage.french:
        return 'Badge';
    }
  }

  String get insertColoredBadge {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Inserir badge colorido';
      case AppLanguage.english:
        return 'Insert colored badge';
      case AppLanguage.french:
        return 'Insérer un badge coloré';
    }
  }

  String get highlightedText {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Texto destacado';
      case AppLanguage.english:
        return 'Highlighted text';
      case AppLanguage.french:
        return 'Texte surligné';
    }
  }

  String get highlightTextWithColor {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Destacar texto com cor';
      case AppLanguage.english:
        return 'Highlight text with color';
      case AppLanguage.french:
        return 'Surligner le texte avec une couleur';
    }
  }

  String get keyboardKey {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tecla';
      case AppLanguage.english:
        return 'Keyboard key';
      case AppLanguage.french:
        return 'Touche';
    }
  }

  String get representShortcutKey {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Representar tecla de atalho';
      case AppLanguage.english:
        return 'Represent shortcut key';
      case AppLanguage.french:
        return 'Représenter la touche de raccourci';
    }
  }

  String get subscript {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Subscrito';
      case AppLanguage.english:
        return 'Subscript';
      case AppLanguage.french:
        return 'Indice';
    }
  }

  String get subscriptText {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Texto em subscrito';
      case AppLanguage.english:
        return 'Subscript text';
      case AppLanguage.french:
        return 'Texte en indice';
    }
  }

  String get superscript {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Sobrescrito';
      case AppLanguage.english:
        return 'Superscript';
      case AppLanguage.french:
        return 'Exposant';
    }
  }

  String get superscriptText {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Texto em sobrescrito';
      case AppLanguage.english:
        return 'Superscript text';
      case AppLanguage.french:
        return 'Texte en exposant';
    }
  }

  String get progressBar {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Barra de progresso';
      case AppLanguage.english:
        return 'Progress bar';
      case AppLanguage.french:
        return 'Barre de progression';
    }
  }

  String get insertProgressBar {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Inserir barra de progresso';
      case AppLanguage.english:
        return 'Insert progress bar';
      case AppLanguage.french:
        return 'Insérer une barre de progression';
    }
  }

  String get details {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Detalhes';
      case AppLanguage.english:
        return 'Details';
      case AppLanguage.french:
        return 'Détails';
    }
  }

  String get expandableDetailsBlock {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Bloco de detalhes expansível';
      case AppLanguage.english:
        return 'Expandable details block';
      case AppLanguage.french:
        return 'Bloc de détails extensible';
    }
  }

  String get noteViaAI {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Nota via IA';
      case AppLanguage.english:
        return 'Note via AI';
      case AppLanguage.french:
        return 'Note via IA';
    }
  }

  String get generateContentWithAI {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Gerar conteúdo com IA';
      case AppLanguage.english:
        return 'Generate content with AI';
      case AppLanguage.french:
        return 'Générer du contenu avec l\'IA';
    }
  }

  // --- CATEGORIAS DE COMANDOS SLASH ---
  String get titles {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Títulos';
      case AppLanguage.english:
        return 'Titles';
      case AppLanguage.french:
        return 'Titres';
    }
  }

  String get lists {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Listas';
      case AppLanguage.english:
        return 'Lists';
      case AppLanguage.french:
        return 'Listes';
    }
  }

  String get quotes {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Citações';
      case AppLanguage.english:
        return 'Quotes';
      case AppLanguage.french:
        return 'Citations';
    }
  }

  String get code {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Código';
      case AppLanguage.english:
        return 'Code';
      case AppLanguage.french:
        return 'Code';
    }
  }

  String get math {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Matemática';
      case AppLanguage.english:
        return 'Math';
      case AppLanguage.french:
        return 'Mathématiques';
    }
  }

  String get diagrams {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Diagramas';
      case AppLanguage.english:
        return 'Diagrams';
      case AppLanguage.french:
        return 'Diagrammes';
    }
  }

  String get tables {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tabelas';
      case AppLanguage.english:
        return 'Tables';
      case AppLanguage.french:
        return 'Tableaux';
    }
  }

  String get media {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Mídia';
      case AppLanguage.english:
        return 'Media';
      case AppLanguage.french:
        return 'Médias';
    }
  }

  String get links {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Links';
      case AppLanguage.english:
        return 'Links';
      case AppLanguage.french:
        return 'Liens';
    }
  }

  String get layout {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Layout';
      case AppLanguage.english:
        return 'Layout';
      case AppLanguage.french:
        return 'Mise en page';
    }
  }

  String get advanced {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Avançado';
      case AppLanguage.english:
        return 'Advanced';
      case AppLanguage.french:
        return 'Avancé';
    }
  }

  String get artificialIntelligence {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Inteligência Artificial';
      case AppLanguage.english:
        return 'Artificial Intelligence';
      case AppLanguage.french:
        return 'Intelligence Artificielle';
    }
  }

  // --- STRINGS PARA TEMAS DE CÓDIGO ---
  String get codeTheme {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tema de código';
      case AppLanguage.english:
        return 'Code theme';
      case AppLanguage.french:
        return 'Thème de code';
    }
  }

  String get codeThemeDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Escolha o tema para blocos de código';
      case AppLanguage.english:
        return 'Choose the theme for code blocks';
      case AppLanguage.french:
        return 'Choisissez le thème pour les blocs de code';
    }
  }

  String get selectCodeTheme {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Selecionar tema de código';
      case AppLanguage.english:
        return 'Select code theme';
      case AppLanguage.french:
        return 'Sélectionner le thème de code';
    }
  }

  String get codeThemeChanged {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tema de código alterado';
      case AppLanguage.english:
        return 'Code theme changed';
      case AppLanguage.french:
        return 'Thème de code changé';
    }
  }

  String get darkThemes {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Temas escuros';
      case AppLanguage.english:
        return 'Dark themes';
      case AppLanguage.french:
        return 'Thèmes sombres';
    }
  }

  String get lightThemes {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Temas claros';
      case AppLanguage.english:
        return 'Light themes';
      case AppLanguage.french:
        return 'Thèmes clairs';
    }
  }

  String get preview {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Prévia';
      case AppLanguage.english:
        return 'Preview';
      case AppLanguage.french:
        return 'Aperçu';
    }
  }

  String get sampleCode {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Código de exemplo';
      case AppLanguage.english:
        return 'Sample code';
      case AppLanguage.french:
        return 'Code d\'exemple';
    }
  }

  String get applyTheme {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Aplicar tema';
      case AppLanguage.english:
        return 'Apply theme';
      case AppLanguage.french:
        return 'Appliquer le thème';
    }
  }

  String get resetToDefault {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Restaurar padrão';
      case AppLanguage.english:
        return 'Reset to default';
      case AppLanguage.french:
        return 'Réinitialiser par défaut';
    }
  }

  String get others {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Outros';
      case AppLanguage.english:
        return 'Others';
      case AppLanguage.french:
        return 'Autres';
    }
  }

  // --- STRINGS PARA ERROS DO EDITOR ---
  String get errorInsertingBlock {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao inserir bloco';
      case AppLanguage.english:
        return 'Error inserting block';
      case AppLanguage.french:
        return 'Erreur lors de l\'insertion du bloc';
    }
  }

  String get errorFormattingText {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao formatar texto';
      case AppLanguage.english:
        return 'Error formatting text';
      case AppLanguage.french:
        return 'Erreur lors du formatage du texte';
    }
  }

  String get errorInsertingLink {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao inserir link';
      case AppLanguage.english:
        return 'Error inserting link';
      case AppLanguage.french:
        return 'Erreur lors de l\'insertion du lien';
    }
  }

  String get errorInsertingTitle {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao inserir título';
      case AppLanguage.english:
        return 'Error inserting title';
      case AppLanguage.french:
        return 'Erreur lors de l\'insertion du titre';
    }
  }

  String get errorInsertingList {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao inserir lista';
      case AppLanguage.english:
        return 'Error inserting list';
      case AppLanguage.french:
        return 'Erreur lors de l\'insertion de la liste';
    }
  }

  String get errorInsertingNumberedList {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao inserir lista numerada';
      case AppLanguage.english:
        return 'Error inserting numbered list';
      case AppLanguage.french:
        return 'Erreur lors de l\'insertion de la liste numérotée';
    }
  }

  String get errorInsertingTask {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao inserir tarefa';
      case AppLanguage.english:
        return 'Error inserting task';
      case AppLanguage.french:
        return 'Erreur lors de l\'insertion de la tâche';
    }
  }

  String get errorUndoing {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao desfazer';
      case AppLanguage.english:
        return 'Error undoing';
      case AppLanguage.french:
        return 'Erreur lors de l\'annulation';
    }
  }

  String get errorRedoing {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao refazer';
      case AppLanguage.english:
        return 'Error redoing';
      case AppLanguage.french:
        return 'Erreur lors de la répétition';
    }
  }

  String get errorPastingFromClipboard {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao colar do clipboard';
      case AppLanguage.english:
        return 'Error pasting from clipboard';
      case AppLanguage.french:
        return 'Erreur lors du collage depuis le presse-papiers';
    }
  }

  // --- STRINGS FALTANTES PARA NOTION BLOCK TYPES ---
  String get template {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Modelo';
      case AppLanguage.english:
        return 'Template';
      case AppLanguage.french:
        return 'Modèle';
    }
  }

  String get map {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Mapa';
      case AppLanguage.english:
        return 'Map';
      case AppLanguage.french:
        return 'Carte';
    }
  }

  String get chart {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Gráfico';
      case AppLanguage.english:
        return 'Chart';
      case AppLanguage.french:
        return 'Graphique';
    }
  }

  String get timeline {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Linha do tempo';
      case AppLanguage.english:
        return 'Timeline';
      case AppLanguage.french:
        return 'Chronologie';
    }
  }

  String get form {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Formulário';
      case AppLanguage.english:
        return 'Form';
      case AppLanguage.french:
        return 'Formulaire';
    }
  }

  String get poll {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Enquete';
      case AppLanguage.english:
        return 'Poll';
      case AppLanguage.french:
        return 'Sondage';
    }
  }

  String get vote {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Votação';
      case AppLanguage.english:
        return 'Vote';
      case AppLanguage.french:
        return 'Vote';
    }
  }

  String get comment {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Comentário';
      case AppLanguage.english:
        return 'Comment';
      case AppLanguage.french:
        return 'Commentaire';
    }
  }

  String get annotation {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Anotação';
      case AppLanguage.english:
        return 'Annotation';
      case AppLanguage.french:
        return 'Annotation';
    }
  }

  String get version {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Versão';
      case AppLanguage.english:
        return 'Version';
      case AppLanguage.french:
        return 'Version';
    }
  }

  // --- STRINGS FALTANTES PARA SLASH COMMANDS ---
  String get todoListWithCheckboxes {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Lista de tarefas com caixas de seleção';
      case AppLanguage.english:
        return 'Todo list with checkboxes';
      case AppLanguage.french:
        return 'Liste de tâches avec cases à cocher';
    }
  }

  String get expandableList {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Lista expansível';
      case AppLanguage.english:
        return 'Expandable list';
      case AppLanguage.french:
        return 'Liste extensible';
    }
  }

  String get expandableListDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Lista que pode ser expandida ou recolhida';
      case AppLanguage.english:
        return 'List that can be expanded or collapsed';
      case AppLanguage.french:
        return 'Liste qui peut être développée ou réduite';
    }
  }

  String get calloutWithIcon {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Destaque com ícone';
      case AppLanguage.english:
        return 'Callout with icon';
      case AppLanguage.french:
        return 'Mise en évidence avec icône';
    }
  }

  String get equation {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Equação';
      case AppLanguage.english:
        return 'Equation';
      case AppLanguage.french:
        return 'Équation';
    }
  }

  String get mathEquation {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Equação matemática';
      case AppLanguage.english:
        return 'Math equation';
      case AppLanguage.french:
        return 'Équation mathématique';
    }
  }

  String get spacer {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Espaçador';
      case AppLanguage.english:
        return 'Spacer';
      case AppLanguage.french:
        return 'Espaceur';
    }
  }

  String get insertFile {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Inserir arquivo';
      case AppLanguage.english:
        return 'Insert file';
      case AppLanguage.french:
        return 'Insérer un fichier';
    }
  }

  String get webLink {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Link da web';
      case AppLanguage.english:
        return 'Web link';
      case AppLanguage.french:
        return 'Lien web';
    }
  }

  String get linkToExternalSite {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Link para site externo';
      case AppLanguage.english:
        return 'Link to external site';
      case AppLanguage.french:
        return 'Lien vers un site externe';
    }
  }

  String get createTable {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Criar tabela';
      case AppLanguage.english:
        return 'Create table';
      case AppLanguage.french:
        return 'Créer un tableau';
    }
  }

  String get database {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Base de dados';
      case AppLanguage.english:
        return 'Database';
      case AppLanguage.french:
        return 'Base de données';
    }
  }

  String get createDatabase {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Criar base de dados';
      case AppLanguage.english:
        return 'Create database';
      case AppLanguage.french:
        return 'Créer une base de données';
    }
  }

  String get embedExternalContent {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Incorporar conteúdo externo';
      case AppLanguage.english:
        return 'Embed external content';
      case AppLanguage.french:
        return 'Intégrer du contenu externe';
    }
  }

  String get saveLinkAsBookmark {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Salvar link como favorito';
      case AppLanguage.english:
        return 'Save link as bookmark';
      case AppLanguage.french:
        return 'Sauvegarder le lien comme favori';
    }
  }

  String get specials {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Especiais';
      case AppLanguage.english:
        return 'Specials';
      case AppLanguage.french:
        return 'Spéciaux';
    }
  }

  String get data {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Dados';
      case AppLanguage.english:
        return 'Data';
      case AppLanguage.french:
        return 'Données';
    }
  }

  // --- STRINGS FALTANTES PARA EDITOR CONTROLLER ---
  String get errorSaving {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Erro ao salvar';
      case AppLanguage.english:
        return 'Error saving';
      case AppLanguage.french:
        return 'Erreur lors de la sauvegarde';
    }
  }

  // --- STRINGS FALTANTES PARA SLASH MENU ---
  List<String> get slashCommandCategories {
    switch (_language) {
      case AppLanguage.portuguese:
        return ['Básico', 'Mídia', 'Dados', 'Especiais'];
      case AppLanguage.english:
        return ['Basic', 'Media', 'Data', 'Specials'];
      case AppLanguage.french:
        return ['Basique', 'Média', 'Données', 'Spéciaux'];
    }
  }

  String get slashCommandCategoryName {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Categoria';
      case AppLanguage.english:
        return 'Category';
      case AppLanguage.french:
        return 'Catégorie';
    }
  }

  // --- STRINGS FALTANTES PARA PAGE CONTENT WIDGET ---
  String get isDarkModeProvider {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Modo escuro';
      case AppLanguage.english:
        return 'Dark mode';
      case AppLanguage.french:
        return 'Mode sombre';
    }
  }

  // --- STRINGS FALTANTES PARA NOTION BLOCK TYPES ---
  String get column {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Coluna';
      case AppLanguage.english:
        return 'Column';
      case AppLanguage.french:
        return 'Colonne';
    }
  }

  String get databaseView {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Visualização da Base de Dados';
      case AppLanguage.english:
        return 'Database View';
      case AppLanguage.french:
        return 'Vue de la base de données';
    }
  }

  String get mention {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Menção';
      case AppLanguage.english:
        return 'Mention';
      case AppLanguage.french:
        return 'Mention';
    }
  }

  String get syncedBlock {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Bloco Sincronizado';
      case AppLanguage.english:
        return 'Synced Block';
      case AppLanguage.french:
        return 'Bloc synchronisé';
    }
  }

  String get selectSectionToStart {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Selecione uma seção no menu lateral para começar.';
      case AppLanguage.english:
        return 'Select a section in the sidebar to get started.';
      case AppLanguage.french:
        return 'Sélectionnez une section dans la barre latérale pour commencer.';
    }
  }

  String get useButtonsInTabs {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Use os botões + dentro de cada aba para adicionar documentos';
      case AppLanguage.english:
        return 'Use the + buttons within each tab to add documents';
      case AppLanguage.french:
        return 'Utilisez les boutons + dans chaque onglet pour ajouter des documents';
    }
  }

  String get lightTheme {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tema claro';
      case AppLanguage.english:
        return 'Light theme';
      case AppLanguage.french:
        return 'Thème clair';
    }
  }

  String get darkTheme {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tema escuro';
      case AppLanguage.english:
        return 'Dark theme';
      case AppLanguage.french:
        return 'Thème sombre';
    }
  }

  String get bloquinhoAIConnected {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Bloquinho AI: Conectado';
      case AppLanguage.english:
        return 'Bloquinho AI: Connected';
      case AppLanguage.french:
        return 'Bloquinho AI: Connecté';
    }
  }

  String get bloquinhoAIDisconnected {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Bloquinho AI: Desconectado';
      case AppLanguage.english:
        return 'Bloquinho AI: Disconnected';
      case AppLanguage.french:
        return 'Bloquinho AI: Déconnecté';
    }
  }

  String get aiOK {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'AI OK';
      case AppLanguage.english:
        return 'AI OK';
      case AppLanguage.french:
        return 'IA OK';
    }
  }

  String get aiKO {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'AI KO';
      case AppLanguage.english:
        return 'AI KO';
      case AppLanguage.french:
        return 'IA KO';
    }
  }

  String get breadcrumb {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Navegação';
      case AppLanguage.english:
        return 'Breadcrumb';
      case AppLanguage.french:
        return 'Fil d\'Ariane';
    }
  }

  String get columnList {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Lista de Colunas';
      case AppLanguage.english:
        return 'Column List';
      case AppLanguage.french:
        return 'Liste de colonnes';
    }
  }

  String get individualColumn {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Coluna Individual';
      case AppLanguage.english:
        return 'Individual Column';
      case AppLanguage.french:
        return 'Colonne individuelle';
    }
  }

  String get databaseViewDescription {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Visualização personalizada da base de dados';
      case AppLanguage.english:
        return 'Custom database view';
      case AppLanguage.french:
        return 'Vue personnalisée de la base de données';
    }
  }

  String get externalEmbed {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Incorporação Externa';
      case AppLanguage.english:
        return 'External Embed';
      case AppLanguage.french:
        return 'Intégration externe';
    }
  }

  // --- STRINGS FALTANTES IDENTIFICADAS NOS ERROS ---
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

  String get documents {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Documentos';
      case AppLanguage.english:
        return 'Documents';
      case AppLanguage.french:
        return 'Documents';
    }
  }

  String get bloquinho {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Bloquinho';
      case AppLanguage.english:
        return 'Bloquinho';
      case AppLanguage.french:
        return 'Bloquinho';
    }
  }

  String get system {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Sistema';
      case AppLanguage.english:
        return 'System';
      case AppLanguage.french:
        return 'Système';
    }
  }

  String get backup {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Backup';
      case AppLanguage.english:
        return 'Backup';
      case AppLanguage.french:
        return 'Sauvegarde';
    }
  }

  String get trash {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Lixeira';
      case AppLanguage.english:
        return 'Trash';
      case AppLanguage.french:
        return 'Corbeille';
    }
  }

  String get searchEverything {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Pesquisar tudo';
      case AppLanguage.english:
        return 'Search everything';
      case AppLanguage.french:
        return 'Tout rechercher';
    }
  }

  String get workspace {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Workspace';
      case AppLanguage.english:
        return 'Workspace';
      case AppLanguage.french:
        return 'Espace de travail';
    }
  }

  String get user {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Usuário';
      case AppLanguage.english:
        return 'User';
      case AppLanguage.french:
        return 'Utilisateur';
    }
  }

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

  String get settings {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Configurações';
      case AppLanguage.english:
        return 'Settings';
      case AppLanguage.french:
        return 'Paramètres';
    }
  }

  String get logout {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Sair';
      case AppLanguage.english:
        return 'Logout';
      case AppLanguage.french:
        return 'Déconnexion';
    }
  }

  String get logoutTitle {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Confirmar saída';
      case AppLanguage.english:
        return 'Confirm logout';
      case AppLanguage.french:
        return 'Confirmer la déconnexion';
    }
  }

  String get logoutMessage {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Tem certeza que deseja sair?';
      case AppLanguage.english:
        return 'Are you sure you want to logout?';
      case AppLanguage.french:
        return 'Êtes-vous sûr de vouloir vous déconnecter?';
    }
  }

  String get deleteAndLogout {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Excluir e sair';
      case AppLanguage.english:
        return 'Delete and logout';
      case AppLanguage.french:
        return 'Supprimer et se déconnecter';
    }
  }

  String get searchBloquinhoDatabase {
    switch (_language) {
      case AppLanguage.portuguese:
        return 'Pesquisar no Bloquinho e Base de Dados';
      case AppLanguage.english:
        return 'Search in Bloquinho and Database';
      case AppLanguage.french:
        return 'Rechercher dans Bloquinho et Base de données';
    }
  }
}

class AppStringsProvider {
  static AppStrings of(AppLanguage language) {
    return AppStrings(language);
  }
}
