import '../models/app_language.dart';

class AppStrings {
  final AppLanguage _language;

  AppStrings(this._language);

  // Método auxiliar para obter string baseada no idioma
  String _getString(String key) {
    switch (_language) {
      case AppLanguage.portuguese:
        return _portugueseStrings[key] ?? key;
      case AppLanguage.english:
        return _englishStrings[key] ?? key;
      case AppLanguage.french:
        return _frenchStrings[key] ?? key;
    }
  }

  // Onboarding
  String get welcomeTitle => _getString('welcomeTitle');
  String get welcomeSubtitle => _getString('welcomeSubtitle');
  String get languageSelectionTitle => _getString('languageSelectionTitle');
  String get languageSelectionSubtitle =>
      _getString('languageSelectionSubtitle');
  String get profileCreationTitle => _getString('profileCreationTitle');
  String get profileCreationSubtitle => _getString('profileCreationSubtitle');
  String get storageSelectionTitle => _getString('storageSelectionTitle');
  String get storageSelectionSubtitle => _getString('storageSelectionSubtitle');
  String get continueButton => _getString('continueButton');
  String get backButton => _getString('backButton');
  String get skipButton => _getString('skipButton');
  String get finishButton => _getString('finishButton');

  // Novas strings do onboarding
  String get chooseLanguage => _getString('chooseLanguage');
  String get languageDescription => _getString('languageDescription');
  String get welcomeToBloquinho => _getString('welcomeToBloquinho');
  String get workspaceDescription => _getString('workspaceDescription');
  String get startButton => _getString('startButton');
  String get createProfile => _getString('createProfile');
  String get profileDescription => _getString('profileDescription');
  String get addPhoto => _getString('addPhoto');
  String get fullName => _getString('fullName');
  String get email => _getString('email');
  String get chooseStorage => _getString('chooseStorage');
  String get storageDescription => _getString('storageDescription');
  String get completedButton => _getString('completedButton');
  String get startUsingButton => _getString('startUsingButton');

  // Campos do perfil
  String get nameLabel => _getString('nameLabel');
  String get nameHint => _getString('nameHint');
  String get emailLabel => _getString('emailLabel');
  String get emailHint => _getString('emailHint');
  String get profilePhoto => _getString('profilePhoto');
  String get selectPhoto => _getString('selectPhoto');
  String get takePhoto => _getString('takePhoto');
  String get removePhoto => _getString('removePhoto');

  // Armazenamento
  String get localStorage => _getString('localStorage');
  String get googleDrive => _getString('googleDrive');
  String get oneDrive => _getString('oneDrive');
  String get localStorageDescription => _getString('localStorageDescription');
  String get googleDriveDescription => _getString('googleDriveDescription');
  String get oneDriveDescription => _getString('oneDriveDescription');
  String get localStorageWarning => _getString('localStorageWarning');

  // Validações
  String get pleaseEnterName => _getString('pleaseEnterName');
  String get pleaseEnterEmail => _getString('pleaseEnterEmail');
  String get pleaseEnterValidEmail => _getString('pleaseEnterValidEmail');

  // Mensagens de erro
  String get errorCreatingUser => _getString('errorCreatingUser');

  // Database System Translations
  String get clickToChooseStatus => _getString('clickToChooseStatus');

  // Profile Screen Translations
  String get profile => _getString('profile');
  String get editProfile => _getString('editProfile');
  String get createNewProfile => _getString('createNewProfile');
  String get deleteProfile => _getString('deleteProfile');
  String get exportData => _getString('exportData');
  String get refresh => _getString('refresh');
  String get settings => _getString('settings');
  String get language => _getString('language');
  String get changeLanguage => _getString('changeLanguage');
  String get interfaceLanguageDescription =>
      _getString('interfaceLanguageDescription');

  // Novas strings do profile
  String get languageChanged => _getString('languageChanged');
  String get cancel => _getString('cancel');
  String get delete => _getString('delete');
  String get errorDeletingProfile => _getString('errorDeletingProfile');

  // Database strings
  String get clickToSetDateTime => _getString('clickToSetDateTime');
  String get selectDate => _getString('selectDate');
  String get next => _getString('next');
  String get selectTime => _getString('selectTime');
  String get save => _getString('save');
  String get back => _getString('back');
  String get today => _getString('today');
  String get tomorrow => _getString('tomorrow');
  String get yesterday => _getString('yesterday');

  // Sidebar e Workspaces
  String get sidebarSystem => _getString('sidebarSystem');
  String get sidebarBackup => _getString('sidebarBackup');
  String get sidebarTrash => _getString('sidebarTrash');
  String get sidebarProfile => _getString('sidebarProfile');
  String get sidebarSettings => _getString('sidebarSettings');
  String get sidebarLogout => _getString('sidebarLogout');
  String get sidebarUser => _getString('sidebarUser');
  String get sidebarWorkspace => _getString('sidebarWorkspace');
  String get sidebarThemeLight => _getString('sidebarThemeLight');
  String get sidebarThemeDark => _getString('sidebarThemeDark');

  // Workspaces
  String get workspaceWork => _getString('workspaceWork');
  String get workspacePersonal => _getString('workspacePersonal');
  String get workspaceSchool => _getString('workspaceSchool');
  String get workspaceProjects => _getString('workspaceProjects');

  // Seções
  String get sectionDocuments => _getString('sectionDocuments');
  String get sectionPasswords => _getString('sectionPasswords');
  String get sectionAgenda => _getString('sectionAgenda');
  String get sectionDatabase => _getString('sectionDatabase');

  // Diálogos e Confirmações
  String get logoutConfirmTitle => _getString('logoutConfirmTitle');
  String get logoutConfirmMessage => _getString('logoutConfirmMessage');
  String get logoutConfirmCancel => _getString('logoutConfirmCancel');
  String get logoutConfirmDelete => _getString('logoutConfirmDelete');

  // Profile Details
  String get personalInfo => _getString('personalInfo');
  String get bio => _getString('bio');
  String get bioHint => _getString('bioHint');
  String get phone => _getString('phone');
  String get phoneHint => _getString('phoneHint');
  String get location => _getString('location');
  String get locationHint => _getString('locationHint');
  String get website => _getString('website');
  String get websiteHint => _getString('websiteHint');
  String get profession => _getString('profession');
  String get professionHint => _getString('professionHint');
  String get birthDate => _getString('birthDate');
  String get birthDateHint => _getString('birthDateHint');
  String get interests => _getString('interests');
  String get interestsHint => _getString('interestsHint');
  String get isPublic => _getString('isPublic');
  String get isPublicDescription => _getString('isPublicDescription');

  // Profile Actions
  String get saveButton => _getString('saveButton');
  String get cancelButton => _getString('cancelButton');
  String get deleteButton => _getString('deleteButton');
  String get confirmDeleteProfile => _getString('confirmDeleteProfile');
  String get deleteProfileWarning => _getString('deleteProfileWarning');
  String get deleteProfileDescription => _getString('deleteProfileDescription');
  String get tryAgain => _getString('tryAgain');
  String get noProfileFound => _getString('noProfileFound');
  String get createProfileToStart => _getString('createProfileToStart');

  // Profile Stats
  String get totalPages => _getString('totalPages');
  String get totalDocuments => _getString('totalDocuments');
  String get totalPasswords => _getString('totalPasswords');
  String get totalAgendaItems => _getString('totalAgendaItems');
  String get lastModified => _getString('lastModified');
  String get memberSince => _getString('memberSince');

  // Profile States
  String get loadingProfile => _getString('loadingProfile');
  String get errorLoadingProfile => _getString('errorLoadingProfile');
  String get profileSaved => _getString('profileSaved');
  String get profileDeleted => _getString('profileDeleted');

  // Language Selection
  String get portuguese => _getString('portuguese');
  String get english => _getString('english');
  String get french => _getString('french');

  // Storage Settings
  String get storageSettings => _getString('storageSettings');
  String get storageProvider => _getString('storageProvider');
  String get storageProviderDescription =>
      _getString('storageProviderDescription');
  String get syncEnabled => _getString('syncEnabled');
  String get autoSync => _getString('autoSync');
  String get manualSync => _getString('manualSync');
  String get lastSync => _getString('lastSync');
  String get syncNow => _getString('syncNow');
  String get syncStatus => _getString('syncStatus');
  String get connected => _getString('connected');
  String get disconnected => _getString('disconnected');
  String get connecting => _getString('connecting');
  String get syncing => _getString('syncing');
  String get syncError => _getString('syncError');

  // Backup
  String get backup => _getString('backup');
  String get backupAndSync => _getString('backupAndSync');
  String get createBackup => _getString('createBackup');
  String get restoreBackup => _getString('restoreBackup');
  String get importBackup => _getString('importBackup');
  String get exportBackup => _getString('exportBackup');
  String get backupCreated => _getString('backupCreated');
  String get backupRestored => _getString('backupRestored');
  String get backupImported => _getString('backupImported');
  String get backupExported => _getString('backupExported');
  String get backupError => _getString('backupError');

  // Settings
  String get settingsTitle => _getString('settingsTitle');
  String get settingsLanguage => _getString('settingsLanguage');
  String get settingsLanguageDescription =>
      _getString('settingsLanguageDescription');
  String get settingsTheme => _getString('settingsTheme');
  String get settingsThemeDescription => _getString('settingsThemeDescription');
  String get settingsBackup => _getString('settingsBackup');
  String get settingsBackupDescription =>
      _getString('settingsBackupDescription');
  String get settingsStorage => _getString('settingsStorage');
  String get settingsStorageDescription =>
      _getString('settingsStorageDescription');
  String get settingsProfile => _getString('settingsProfile');
  String get settingsProfileDescription =>
      _getString('settingsProfileDescription');

  // Erros e Estados
  String get errorSavingPage => _getString('errorSavingPage');
  String get errorLoadingPage => _getString('errorLoadingPage');
  String get errorNoProfile => _getString('errorNoProfile');
  String get errorNoWorkspace => _getString('errorNoWorkspace');
  String get errorNoData => _getString('errorNoData');

  // Sucessos
  String get successProfileSaved => _getString('successProfileSaved');
  String get successPageSaved => _getString('successPageSaved');
  String get successSettingsSaved => _getString('successSettingsSaved');
  String get successBackupCreated => _getString('successBackupCreated');

  // Estados de Loading
  String get loadingPage => _getString('loadingPage');
  String get loadingSettings => _getString('loadingSettings');
  String get loadingBackup => _getString('loadingBackup');
  String get loadingSync => _getString('loadingSync');

  // Informações
  String get infoNoPages => _getString('infoNoPages');
  String get infoNoDocuments => _getString('infoNoDocuments');
  String get infoNoPasswords => _getString('infoNoPasswords');
  String get infoNoAgenda => _getString('infoNoAgenda');
  String get infoNoDatabase => _getString('infoNoDatabase');
  String get infoNoBackups => _getString('infoNoBackups');

  // Ações básicas
  String get actionCreate => _getString('actionCreate');
  String get actionEdit => _getString('actionEdit');
  String get actionDelete => _getString('actionDelete');
  String get actionSave => _getString('actionSave');
  String get actionCancel => _getString('actionCancel');
  String get actionConfirm => _getString('actionConfirm');
  String get actionClose => _getString('actionClose');
  String get actionRefresh => _getString('actionRefresh');
  String get actionSync => _getString('actionSync');
  String get actionBackup => _getString('actionBackup');
  String get actionRestore => _getString('actionRestore');
  String get actionImport => _getString('actionImport');
  String get actionExport => _getString('actionExport');
  String get actionShare => _getString('actionShare');
  String get actionSearch => _getString('actionSearch');
  String get actionView => _getString('actionView');

  // Maps de strings por idioma
  static const Map<String, String> _portugueseStrings = {
    'welcomeTitle': 'Bem-vindo ao Bloquinho',
    'welcomeSubtitle': 'Seu workspace pessoal organizado',
    'languageSelectionTitle': 'Escolha seu idioma',
    'languageSelectionSubtitle':
        'Você pode alterar isso depois nas configurações',
    'profileCreationTitle': 'Crie seu perfil',
    'profileCreationSubtitle': 'Configure suas informações básicas',
    'storageSelectionTitle': 'Escolha o armazenamento',
    'storageSelectionSubtitle': 'Onde seus dados serão salvos',
    'continueButton': 'Continuar',
    'backButton': 'Voltar',
    'skipButton': 'Pular',
    'finishButton': 'Finalizar',
    'chooseLanguage': 'Escolha seu idioma',
    'languageDescription': 'Você pode alterar isso depois nas configurações',
    'welcomeToBloquinho': 'Bem-vindo ao Bloquinho',
    'workspaceDescription': 'Seu workspace pessoal organizado',
    'startButton': 'Começar',
    'createProfile': 'Crie seu perfil',
    'profileDescription': 'Configure suas informações básicas',
    'addPhoto': 'Adicionar foto',
    'fullName': 'Nome completo',
    'email': 'Email',
    'chooseStorage': 'Escolha o armazenamento',
    'storageDescription': 'Onde seus dados serão salvos',
    'completedButton': 'Concluído',
    'startUsingButton': 'Começar a usar',
    'nameLabel': 'Nome',
    'nameHint': 'Digite seu nome completo',
    'emailLabel': 'Email',
    'emailHint': 'Digite seu email',
    'profilePhoto': 'Foto do perfil',
    'selectPhoto': 'Selecionar foto',
    'takePhoto': 'Tirar foto',
    'removePhoto': 'Remover foto',
    'localStorage': 'Armazenamento Local',
    'googleDrive': 'Google Drive',
    'oneDrive': 'OneDrive',
    'localStorageDescription': 'Dados salvos apenas neste dispositivo',
    'googleDriveDescription': 'Sincronizar com Google Drive (15GB grátis)',
    'oneDriveDescription': 'Sincronizar com OneDrive (5GB grátis)',
    'localStorageWarning':
        'Os dados não serão sincronizados entre dispositivos',
    'pleaseEnterName': 'Por favor, insira seu nome',
    'pleaseEnterEmail': 'Por favor, insira seu email',
    'pleaseEnterValidEmail': 'Por favor, insira um email válido',
    'errorCreatingUser': 'Erro ao criar usuário',
    'clickToChooseStatus': 'Clique para escolher status',
    'profile': 'Perfil',
    'editProfile': 'Editar Perfil',
    'createNewProfile': 'Criar Perfil',
    'deleteProfile': 'Excluir Perfil',
    'exportData': 'Exportar Dados',
    'refresh': 'Atualizar',
    'settings': 'Configurações',
    'language': 'Idioma',
    'changeLanguage': 'Alterar idioma',
    'interfaceLanguageDescription': 'Escolha o idioma da interface',
    'languageChanged': 'Idioma alterado com sucesso',
    'cancel': 'Cancelar',
    'delete': 'Excluir',
    'errorDeletingProfile': 'Erro ao excluir perfil',
    'clickToSetDateTime': 'Clique para definir data/hora',
    'selectDate': 'Selecionar data',
    'next': 'Próximo',
    'selectTime': 'Selecionar hora',
    'save': 'Salvar',
    'back': 'Voltar',
    'today': 'Hoje',
    'tomorrow': 'Amanhã',
    'yesterday': 'Ontem',
    'sidebarSystem': 'Sistema',
    'sidebarBackup': 'Backup',
    'sidebarTrash': 'Lixeira',
    'sidebarProfile': 'Perfil',
    'sidebarSettings': 'Configurações',
    'sidebarLogout': 'Sair',
    'sidebarUser': 'Usuário',
    'sidebarWorkspace': 'Workspace',
    'sidebarThemeLight': 'Tema claro',
    'sidebarThemeDark': 'Tema escuro',
    'workspaceWork': 'Trabalho',
    'workspacePersonal': 'Pessoal',
    'workspaceSchool': 'Escola',
    'workspaceProjects': 'Projetos',
    'sectionDocuments': 'Documentos',
    'sectionPasswords': 'Senhas',
    'sectionAgenda': 'Agenda',
    'sectionDatabase': 'Base de Dados',
    'logoutConfirmTitle': 'Sair e apagar dados locais?',
    'logoutConfirmMessage':
        'Tem certeza que deseja sair? Isso irá remover seu perfil e TODOS os dados locais deste dispositivo.\n\n⚠️ Recomenda-se fazer um backup antes de continuar.\n\nEsta ação não pode ser desfeita.',
    'logoutConfirmCancel': 'Cancelar',
    'logoutConfirmDelete': 'Apagar e Sair',
    'personalInfo': 'Informações Pessoais',
    'bio': 'Biografia',
    'bioHint': 'Conte um pouco sobre você...',
    'phone': 'Telefone',
    'phoneHint': '(11) 99999-9999',
    'location': 'Localização',
    'locationHint': 'Cidade, Estado',
    'website': 'Website',
    'websiteHint': 'https://exemplo.com',
    'profession': 'Profissão',
    'professionHint': 'Sua profissão atual',
    'birthDate': 'Data de Nascimento',
    'birthDateHint': 'DD/MM/AAAA',
    'interests': 'Interesses',
    'interestsHint': 'Adicione seus interesses...',
    'isPublic': 'Perfil público',
    'isPublicDescription': 'Permitir que outros vejam seu perfil',
    'saveButton': 'Salvar',
    'cancelButton': 'Cancelar',
    'deleteButton': 'Excluir',
    'confirmDeleteProfile': 'Confirmar exclusão',
    'deleteProfileWarning': 'Esta ação não pode ser desfeita',
    'deleteProfileDescription':
        'Todos os dados do perfil serão permanentemente removidos',
    'tryAgain': 'Tentar novamente',
    'noProfileFound': 'Nenhum perfil encontrado',
    'createProfileToStart': 'Crie um perfil para começar',
    'totalPages': 'Total de páginas',
    'totalDocuments': 'Total de documentos',
    'totalPasswords': 'Total de senhas',
    'totalAgendaItems': 'Total de itens da agenda',
    'lastModified': 'Última modificação',
    'memberSince': 'Membro desde',
    'loadingProfile': 'Carregando perfil...',
    'errorLoadingProfile': 'Erro ao carregar perfil',
    'profileSaved': 'Perfil salvo com sucesso',
    'profileDeleted': 'Perfil excluído com sucesso',
    'portuguese': 'Português',
    'english': 'English',
    'french': 'Français',
    'storageSettings': 'Configurações de Armazenamento',
    'storageProvider': 'Provedor de Armazenamento',
    'storageProviderDescription': 'Escolha onde seus dados serão salvos',
    'syncEnabled': 'Sincronização ativada',
    'autoSync': 'Sincronização automática',
    'manualSync': 'Sincronização manual',
    'lastSync': 'Última sincronização',
    'syncNow': 'Sincronizar agora',
    'syncStatus': 'Status da sincronização',
    'connected': 'Conectado',
    'disconnected': 'Desconectado',
    'connecting': 'Conectando...',
    'syncing': 'Sincronizando...',
    'syncError': 'Erro na sincronização',
    'backup': 'Backup',
    'backupAndSync': 'Backup e Sincronização',
    'createBackup': 'Criar backup',
    'restoreBackup': 'Restaurar backup',
    'importBackup': 'Importar backup',
    'exportBackup': 'Exportar backup',
    'backupCreated': 'Backup criado com sucesso',
    'backupRestored': 'Backup restaurado com sucesso',
    'backupImported': 'Backup importado com sucesso',
    'backupExported': 'Backup exportado com sucesso',
    'backupError': 'Erro no backup',
    'settingsTitle': 'Configurações',
    'settingsLanguage': 'Idioma',
    'settingsLanguageDescription': 'Escolha o idioma da interface',
    'settingsTheme': 'Tema',
    'settingsThemeDescription': 'Escolha entre tema claro ou escuro',
    'settingsBackup': 'Backup',
    'settingsBackupDescription': 'Configure backups automáticos',
    'settingsStorage': 'Armazenamento',
    'settingsStorageDescription': 'Configure provedores de armazenamento',
    'settingsProfile': 'Perfil',
    'settingsProfileDescription': 'Gerencie suas informações pessoais',
    'errorSavingPage': 'Erro ao salvar página',
    'errorLoadingPage': 'Erro ao carregar página',
    'errorNoProfile': 'Nenhum perfil encontrado',
    'errorNoWorkspace': 'Nenhum workspace encontrado',
    'errorNoData': 'Nenhum dado encontrado',
    'successProfileSaved': 'Perfil salvo com sucesso',
    'successPageSaved': 'Página salva com sucesso',
    'successSettingsSaved': 'Configurações salvas com sucesso',
    'successBackupCreated': 'Backup criado com sucesso',
    'loadingPage': 'Carregando página...',
    'loadingSettings': 'Carregando configurações...',
    'loadingBackup': 'Criando backup...',
    'loadingSync': 'Sincronizando...',
    'infoNoPages': 'Nenhuma página encontrada',
    'infoNoDocuments': 'Nenhum documento encontrado',
    'infoNoPasswords': 'Nenhuma senha encontrada',
    'infoNoAgenda': 'Nenhum item da agenda encontrado',
    'infoNoDatabase': 'Nenhum banco de dados encontrado',
    'infoNoBackups': 'Nenhum backup encontrado',
    'actionCreate': 'Criar',
    'actionEdit': 'Editar',
    'actionDelete': 'Excluir',
    'actionSave': 'Salvar',
    'actionCancel': 'Cancelar',
    'actionConfirm': 'Confirmar',
    'actionClose': 'Fechar',
    'actionRefresh': 'Atualizar',
    'actionSync': 'Sincronizar',
    'actionBackup': 'Backup',
    'actionRestore': 'Restaurar',
    'actionImport': 'Importar',
    'actionExport': 'Exportar',
    'actionShare': 'Compartilhar',
    'actionSearch': 'Pesquisar',
    'actionView': 'Visualizar',
  };

  static const Map<String, String> _englishStrings = {
    'welcomeTitle': 'Welcome to Bloquinho',
    'welcomeSubtitle': 'Your organized personal workspace',
    'languageSelectionTitle': 'Choose your language',
    'languageSelectionSubtitle': 'You can change this later in settings',
    'profileCreationTitle': 'Create your profile',
    'profileCreationSubtitle': 'Set up your basic information',
    'storageSelectionTitle': 'Choose storage',
    'storageSelectionSubtitle': 'Where your data will be saved',
    'continueButton': 'Continue',
    'backButton': 'Back',
    'skipButton': 'Skip',
    'finishButton': 'Finish',
    'chooseLanguage': 'Choose your language',
    'languageDescription': 'You can change this later in settings',
    'welcomeToBloquinho': 'Welcome to Bloquinho',
    'workspaceDescription': 'Your organized personal workspace',
    'startButton': 'Start',
    'createProfile': 'Create your profile',
    'profileDescription': 'Set up your basic information',
    'addPhoto': 'Add photo',
    'fullName': 'Full name',
    'email': 'Email',
    'chooseStorage': 'Choose storage',
    'storageDescription': 'Where your data will be saved',
    'completedButton': 'Completed',
    'startUsingButton': 'Start using',
    'nameLabel': 'Name',
    'nameHint': 'Enter your full name',
    'emailLabel': 'Email',
    'emailHint': 'Enter your email',
    'profilePhoto': 'Profile photo',
    'selectPhoto': 'Select photo',
    'takePhoto': 'Take photo',
    'removePhoto': 'Remove photo',
    'localStorage': 'Local Storage',
    'googleDrive': 'Google Drive',
    'oneDrive': 'OneDrive',
    'localStorageDescription': 'Data saved only on this device',
    'googleDriveDescription': 'Sync with Google Drive (15GB free)',
    'oneDriveDescription': 'Sync with OneDrive (5GB free)',
    'localStorageWarning': 'Data will not be synchronized between devices',
    'pleaseEnterName': 'Please enter your name',
    'pleaseEnterEmail': 'Please enter your email',
    'pleaseEnterValidEmail': 'Please enter a valid email',
    'errorCreatingUser': 'Error creating user',
    'clickToChooseStatus': 'Click to choose status',
    'profile': 'Profile',
    'editProfile': 'Edit Profile',
    'createNewProfile': 'Create Profile',
    'deleteProfile': 'Delete Profile',
    'exportData': 'Export Data',
    'refresh': 'Refresh',
    'settings': 'Settings',
    'language': 'Language',
    'changeLanguage': 'Change language',
    'interfaceLanguageDescription': 'Choose interface language',
    'languageChanged': 'Language changed successfully',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'errorDeletingProfile': 'Error deleting profile',
    'clickToSetDateTime': 'Click to set date/time',
    'selectDate': 'Select date',
    'next': 'Next',
    'selectTime': 'Select time',
    'save': 'Save',
    'back': 'Back',
    'today': 'Today',
    'tomorrow': 'Tomorrow',
    'yesterday': 'Yesterday',
    'sidebarSystem': 'System',
    'sidebarBackup': 'Backup',
    'sidebarTrash': 'Trash',
    'sidebarProfile': 'Profile',
    'sidebarSettings': 'Settings',
    'sidebarLogout': 'Logout',
    'sidebarUser': 'User',
    'sidebarWorkspace': 'Workspace',
    'sidebarThemeLight': 'Light theme',
    'sidebarThemeDark': 'Dark theme',
    'workspaceWork': 'Work',
    'workspacePersonal': 'Personal',
    'workspaceSchool': 'School',
    'workspaceProjects': 'Projects',
    'sectionDocuments': 'Documents',
    'sectionPasswords': 'Passwords',
    'sectionAgenda': 'Agenda',
    'sectionDatabase': 'Database',
    'logoutConfirmTitle': 'Logout and delete local data?',
    'logoutConfirmMessage':
        'Are you sure you want to logout? This will remove your profile and ALL local data from this device.\n\n⚠️ It is recommended to make a backup before continuing.\n\nThis action cannot be undone.',
    'logoutConfirmCancel': 'Cancel',
    'logoutConfirmDelete': 'Delete and Logout',
    'personalInfo': 'Personal Information',
    'bio': 'Biography',
    'bioHint': 'Tell us a bit about yourself...',
    'phone': 'Phone',
    'phoneHint': '(11) 99999-9999',
    'location': 'Location',
    'locationHint': 'City, State',
    'website': 'Website',
    'websiteHint': 'https://example.com',
    'profession': 'Profession',
    'professionHint': 'Your current profession',
    'birthDate': 'Birth Date',
    'birthDateHint': 'DD/MM/YYYY',
    'interests': 'Interests',
    'interestsHint': 'Add your interests...',
    'isPublic': 'Public profile',
    'isPublicDescription': 'Allow others to see your profile',
    'saveButton': 'Save',
    'cancelButton': 'Cancel',
    'deleteButton': 'Delete',
    'confirmDeleteProfile': 'Confirm deletion',
    'deleteProfileWarning': 'This action cannot be undone',
    'deleteProfileDescription': 'All profile data will be permanently removed',
    'tryAgain': 'Try again',
    'noProfileFound': 'No profile found',
    'createProfileToStart': 'Create a profile to get started',
    'totalPages': 'Total pages',
    'totalDocuments': 'Total documents',
    'totalPasswords': 'Total passwords',
    'totalAgendaItems': 'Total agenda items',
    'lastModified': 'Last modified',
    'memberSince': 'Member since',
    'loadingProfile': 'Loading profile...',
    'errorLoadingProfile': 'Error loading profile',
    'profileSaved': 'Profile saved successfully',
    'profileDeleted': 'Profile deleted successfully',
    'portuguese': 'Português',
    'english': 'English',
    'french': 'Français',
    'storageSettings': 'Storage Settings',
    'storageProvider': 'Storage Provider',
    'storageProviderDescription': 'Choose where your data will be saved',
    'syncEnabled': 'Sync enabled',
    'autoSync': 'Auto sync',
    'manualSync': 'Manual sync',
    'lastSync': 'Last sync',
    'syncNow': 'Sync now',
    'syncStatus': 'Sync status',
    'connected': 'Connected',
    'disconnected': 'Disconnected',
    'connecting': 'Connecting...',
    'syncing': 'Syncing...',
    'syncError': 'Sync error',
    'backup': 'Backup',
    'backupAndSync': 'Backup and Sync',
    'createBackup': 'Create backup',
    'restoreBackup': 'Restore backup',
    'importBackup': 'Import backup',
    'exportBackup': 'Export backup',
    'backupCreated': 'Backup created successfully',
    'backupRestored': 'Backup restored successfully',
    'backupImported': 'Backup imported successfully',
    'backupExported': 'Backup exported successfully',
    'backupError': 'Backup error',
    'settingsTitle': 'Settings',
    'settingsLanguage': 'Language',
    'settingsLanguageDescription': 'Choose interface language',
    'settingsTheme': 'Theme',
    'settingsThemeDescription': 'Choose between light or dark theme',
    'settingsBackup': 'Backup',
    'settingsBackupDescription': 'Configure automatic backups',
    'settingsStorage': 'Storage',
    'settingsStorageDescription': 'Configure storage providers',
    'settingsProfile': 'Profile',
    'settingsProfileDescription': 'Manage your personal information',
    'errorSavingPage': 'Error saving page',
    'errorLoadingPage': 'Error loading page',
    'errorNoProfile': 'No profile found',
    'errorNoWorkspace': 'No workspace found',
    'errorNoData': 'No data found',
    'successProfileSaved': 'Profile saved successfully',
    'successPageSaved': 'Page saved successfully',
    'successSettingsSaved': 'Settings saved successfully',
    'successBackupCreated': 'Backup created successfully',
    'loadingPage': 'Loading page...',
    'loadingSettings': 'Loading settings...',
    'loadingBackup': 'Creating backup...',
    'loadingSync': 'Syncing...',
    'infoNoPages': 'No pages found',
    'infoNoDocuments': 'No documents found',
    'infoNoPasswords': 'No passwords found',
    'infoNoAgenda': 'No agenda items found',
    'infoNoDatabase': 'No database found',
    'infoNoBackups': 'No backups found',
    'actionCreate': 'Create',
    'actionEdit': 'Edit',
    'actionDelete': 'Delete',
    'actionSave': 'Save',
    'actionCancel': 'Cancel',
    'actionConfirm': 'Confirm',
    'actionClose': 'Close',
    'actionRefresh': 'Refresh',
    'actionSync': 'Sync',
    'actionBackup': 'Backup',
    'actionRestore': 'Restore',
    'actionImport': 'Import',
    'actionExport': 'Export',
    'actionShare': 'Share',
    'actionSearch': 'Search',
    'actionView': 'View',
  };

  static const Map<String, String> _frenchStrings = {
    'welcomeTitle': 'Bienvenue sur Bloquinho',
    'welcomeSubtitle': 'Votre espace de travail personnel organisé',
    'languageSelectionTitle': 'Choisissez votre langue',
    'languageSelectionSubtitle':
        'Vous pouvez changer cela plus tard dans les paramètres',
    'profileCreationTitle': 'Créez votre profil',
    'profileCreationSubtitle': 'Configurez vos informations de base',
    'storageSelectionTitle': 'Choisissez le stockage',
    'storageSelectionSubtitle': 'Où vos données seront sauvegardées',
    'continueButton': 'Continuer',
    'backButton': 'Retour',
    'skipButton': 'Passer',
    'finishButton': 'Terminer',
    'chooseLanguage': 'Choisissez votre langue',
    'languageDescription':
        'Vous pouvez changer cela plus tard dans les paramètres',
    'welcomeToBloquinho': 'Bienvenue sur Bloquinho',
    'workspaceDescription': 'Votre espace de travail personnel organisé',
    'startButton': 'Commencer',
    'createProfile': 'Créez votre profil',
    'profileDescription': 'Configurez vos informations de base',
    'addPhoto': 'Ajouter une photo',
    'fullName': 'Nom complet',
    'email': 'Email',
    'chooseStorage': 'Choisissez le stockage',
    'storageDescription': 'Où vos données seront sauvegardées',
    'completedButton': 'Terminé',
    'startUsingButton': 'Commencer à utiliser',
    'nameLabel': 'Nom',
    'nameHint': 'Entrez votre nom complet',
    'emailLabel': 'Email',
    'emailHint': 'Entrez votre email',
    'profilePhoto': 'Photo de profil',
    'selectPhoto': 'Sélectionner une photo',
    'takePhoto': 'Prendre une photo',
    'removePhoto': 'Supprimer la photo',
    'localStorage': 'Stockage Local',
    'googleDrive': 'Google Drive',
    'oneDrive': 'OneDrive',
    'localStorageDescription':
        'Données sauvegardées uniquement sur cet appareil',
    'googleDriveDescription': 'Synchroniser avec Google Drive (15GB gratuits)',
    'oneDriveDescription': 'Synchroniser avec OneDrive (5GB gratuits)',
    'localStorageWarning':
        'Les données ne seront pas synchronisées entre les appareils',
    'pleaseEnterName': 'Veuillez saisir votre nom',
    'pleaseEnterEmail': 'Veuillez saisir votre email',
    'pleaseEnterValidEmail': 'Veuillez saisir un email valide',
    'errorCreatingUser': 'Erreur lors de la création de l\'utilisateur',
    'clickToChooseStatus': 'Cliquez pour choisir le statut',
    'profile': 'Profil',
    'editProfile': 'Modifier le profil',
    'createNewProfile': 'Créer un profil',
    'deleteProfile': 'Supprimer le profil',
    'exportData': 'Exporter les données',
    'refresh': 'Actualiser',
    'settings': 'Paramètres',
    'language': 'Langue',
    'changeLanguage': 'Changer de langue',
    'interfaceLanguageDescription': 'Choisir la langue de l\'interface',
    'languageChanged': 'Langue changée avec succès',
    'cancel': 'Annuler',
    'delete': 'Supprimer',
    'errorDeletingProfile': 'Erreur lors de la suppression du profil',
    'clickToSetDateTime': 'Cliquez pour définir la date/heure',
    'selectDate': 'Sélectionner la date',
    'next': 'Suivant',
    'selectTime': 'Sélectionner l\'heure',
    'save': 'Enregistrer',
    'back': 'Retour',
    'today': 'Aujourd\'hui',
    'tomorrow': 'Demain',
    'yesterday': 'Hier',
    'sidebarSystem': 'Système',
    'sidebarBackup': 'Sauvegarde',
    'sidebarTrash': 'Corbeille',
    'sidebarProfile': 'Profil',
    'sidebarSettings': 'Paramètres',
    'sidebarLogout': 'Déconnexion',
    'sidebarUser': 'Utilisateur',
    'sidebarWorkspace': 'Espace de travail',
    'sidebarThemeLight': 'Thème clair',
    'sidebarThemeDark': 'Thème sombre',
    'workspaceWork': 'Travail',
    'workspacePersonal': 'Personnel',
    'workspaceSchool': 'École',
    'workspaceProjects': 'Projets',
    'sectionDocuments': 'Documents',
    'sectionPasswords': 'Mots de passe',
    'sectionAgenda': 'Agenda',
    'sectionDatabase': 'Base de données',
    'logoutConfirmTitle': 'Se déconnecter et supprimer les données locales?',
    'logoutConfirmMessage':
        'Êtes-vous sûr de vouloir vous déconnecter? Cela supprimera votre profil et TOUTES les données locales de cet appareil.\n\n⚠️ Il est recommandé de faire une sauvegarde avant de continuer.\n\nCette action ne peut pas être annulée.',
    'logoutConfirmCancel': 'Annuler',
    'logoutConfirmDelete': 'Supprimer et se déconnecter',
    'personalInfo': 'Informations personnelles',
    'bio': 'Biographie',
    'bioHint': 'Parlez-nous un peu de vous...',
    'phone': 'Téléphone',
    'phoneHint': '(11) 99999-9999',
    'location': 'Localisation',
    'locationHint': 'Ville, État',
    'website': 'Site web',
    'websiteHint': 'https://exemple.com',
    'profession': 'Profession',
    'professionHint': 'Votre profession actuelle',
    'birthDate': 'Date de naissance',
    'birthDateHint': 'JJ/MM/AAAA',
    'interests': 'Intérêts',
    'interestsHint': 'Ajoutez vos intérêts...',
    'isPublic': 'Profil public',
    'isPublicDescription': 'Permettre aux autres de voir votre profil',
    'saveButton': 'Enregistrer',
    'cancelButton': 'Annuler',
    'deleteButton': 'Supprimer',
    'confirmDeleteProfile': 'Confirmer la suppression',
    'deleteProfileWarning': 'Cette action ne peut pas être annulée',
    'deleteProfileDescription':
        'Toutes les données du profil seront définitivement supprimées',
    'tryAgain': 'Réessayer',
    'noProfileFound': 'Aucun profil trouvé',
    'createProfileToStart': 'Créez un profil pour commencer',
    'totalPages': 'Total des pages',
    'totalDocuments': 'Total des documents',
    'totalPasswords': 'Total des mots de passe',
    'totalAgendaItems': 'Total des éléments de l\'agenda',
    'lastModified': 'Dernière modification',
    'memberSince': 'Membre depuis',
    'loadingProfile': 'Chargement du profil...',
    'errorLoadingProfile': 'Erreur lors du chargement du profil',
    'profileSaved': 'Profil enregistré avec succès',
    'profileDeleted': 'Profil supprimé avec succès',
    'portuguese': 'Português',
    'english': 'English',
    'french': 'Français',
    'storageSettings': 'Paramètres de stockage',
    'storageProvider': 'Fournisseur de stockage',
    'storageProviderDescription':
        'Choisissez où vos données seront sauvegardées',
    'syncEnabled': 'Synchronisation activée',
    'autoSync': 'Synchronisation automatique',
    'manualSync': 'Synchronisation manuelle',
    'lastSync': 'Dernière synchronisation',
    'syncNow': 'Synchroniser maintenant',
    'syncStatus': 'Statut de synchronisation',
    'connected': 'Connecté',
    'disconnected': 'Déconnecté',
    'connecting': 'Connexion...',
    'syncing': 'Synchronisation...',
    'syncError': 'Erreur de synchronisation',
    'backup': 'Sauvegarde',
    'backupAndSync': 'Sauvegarde et synchronisation',
    'createBackup': 'Créer une sauvegarde',
    'restoreBackup': 'Restaurer la sauvegarde',
    'importBackup': 'Importer la sauvegarde',
    'exportBackup': 'Exporter la sauvegarde',
    'backupCreated': 'Sauvegarde créée avec succès',
    'backupRestored': 'Sauvegarde restaurée avec succès',
    'backupImported': 'Sauvegarde importée avec succès',
    'backupExported': 'Sauvegarde exportée avec succès',
    'backupError': 'Erreur de sauvegarde',
    'settingsTitle': 'Paramètres',
    'settingsLanguage': 'Langue',
    'settingsLanguageDescription': 'Choisir la langue de l\'interface',
    'settingsTheme': 'Thème',
    'settingsThemeDescription': 'Choisir entre thème clair ou sombre',
    'settingsBackup': 'Sauvegarde',
    'settingsBackupDescription': 'Configurer les sauvegardes automatiques',
    'settingsStorage': 'Stockage',
    'settingsStorageDescription': 'Configurer les fournisseurs de stockage',
    'settingsProfile': 'Profil',
    'settingsProfileDescription': 'Gérer vos informations personnelles',
    'errorSavingPage': 'Erreur lors de l\'enregistrement de la page',
    'errorLoadingPage': 'Erreur lors du chargement de la page',
    'errorNoProfile': 'Aucun profil trouvé',
    'errorNoWorkspace': 'Aucun espace de travail trouvé',
    'errorNoData': 'Aucune donnée trouvée',
    'successProfileSaved': 'Profil enregistré avec succès',
    'successPageSaved': 'Page enregistrée avec succès',
    'successSettingsSaved': 'Paramètres enregistrés avec succès',
    'successBackupCreated': 'Sauvegarde créée avec succès',
    'loadingPage': 'Chargement de la page...',
    'loadingSettings': 'Chargement des paramètres...',
    'loadingBackup': 'Création de la sauvegarde...',
    'loadingSync': 'Synchronisation...',
    'infoNoPages': 'Aucune page trouvée',
    'infoNoDocuments': 'Aucun document trouvé',
    'infoNoPasswords': 'Aucun mot de passe trouvé',
    'infoNoAgenda': 'Aucun élément d\'agenda trouvé',
    'infoNoDatabase': 'Aucune base de données trouvée',
    'infoNoBackups': 'Aucune sauvegarde trouvée',
    'actionCreate': 'Créer',
    'actionEdit': 'Modifier',
    'actionDelete': 'Supprimer',
    'actionSave': 'Enregistrer',
    'actionCancel': 'Annuler',
    'actionConfirm': 'Confirmer',
    'actionClose': 'Fermer',
    'actionRefresh': 'Actualiser',
    'actionSync': 'Synchroniser',
    'actionBackup': 'Sauvegarde',
    'actionRestore': 'Restaurer',
    'actionImport': 'Importer',
    'actionExport': 'Exporter',
    'actionShare': 'Partager',
    'actionSearch': 'Rechercher',
    'actionView': 'Afficher',
  };
}

class AppStringsProvider {
  static AppStrings of(AppLanguage language) {
    return AppStrings(language);
  }
}
