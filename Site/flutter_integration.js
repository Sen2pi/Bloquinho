/**
 * Flutter Web Integration Script
 * Integra o site estático com a aplicação Flutter web
 */

class FlutterWebIntegration {
  constructor() {
    this.flutterAppLoaded = false;
    this.authStateListeners = [];
    this.initializeIntegration();
  }

  async initializeIntegration() {
    // Verificar se é uma página que precisa do Flutter
    const currentPath = window.location.pathname;
    
    if (currentPath.includes('app.html')) {
      await this.loadFlutterApp();
    }
    
    // Configurar listeners para mudanças de autenticação
    this.setupAuthStateListeners();
  }

  async loadFlutterApp() {
    try {
      // Verificar se há autenticação válida
      const authData = this.getAuthData();
      if (!authData) {
        window.location.href = 'web_auth.html';
        return;
      }

      // Configurar container para Flutter
      const container = document.getElementById('flutter-app-container');
      if (!container) {
        console.error('Flutter container not found');
        return;
      }

      // Simular carregamento do Flutter
      // Em produção, aqui seria carregado o build do Flutter
      this.showFlutterPlaceholder(container);
      
      // Marcar como carregado
      this.flutterAppLoaded = true;
      
      // Notificar listeners
      this.notifyAuthStateListeners({ 
        authenticated: true, 
        flutterLoaded: true 
      });

    } catch (error) {
      console.error('Error loading Flutter app:', error);
      this.showFlutterError();
    }
  }

  showFlutterPlaceholder(container) {
    // Criar iframe para Flutter ou carregar diretamente
    const iframe = document.createElement('iframe');
    iframe.id = 'flutter-iframe';
    iframe.src = this.getFlutterBuildPath();
    iframe.style.width = '100%';
    iframe.style.height = '100%';
    iframe.style.border = 'none';
    iframe.style.background = '#f8f9fa';
    
    // Placeholder enquanto Flutter não está disponível
    container.innerHTML = `
      <div style="display: flex; flex-direction: column; justify-content: center; align-items: center; height: 100%; background: #f8f9fa; color: #8B4513;">
        <img src="public/logo.png" alt="Bloquinho" style="width: 80px; height: 80px; margin-bottom: 20px; border-radius: 12px;">
        <h2 style="margin-bottom: 10px;">Bloquinho Web App</h2>
        <p style="margin-bottom: 20px; text-align: center; max-width: 400px;">
          Bem-vindo ao Bloquinho! Sua aplicação Flutter está sendo carregada.
        </p>
        <div style="width: 300px; height: 4px; background: #e0e0e0; border-radius: 2px; overflow: hidden;">
          <div style="width: 100%; height: 100%; background: #8B4513; animation: loading 2s ease-in-out infinite;"></div>
        </div>
        <p style="margin-top: 15px; font-size: 14px; color: #666;">
          Conectado com ${this.getStorageProviderName()}
        </p>
      </div>
      <style>
        @keyframes loading {
          0% { transform: translateX(-100%); }
          100% { transform: translateX(100%); }
        }
      </style>
    `;
    
    // Simular carregamento completado após 3 segundos
    setTimeout(() => {
      container.innerHTML = `
        <div style="display: flex; flex-direction: column; justify-content: center; align-items: center; height: 100%; background: #f8f9fa; color: #8B4513;">
          <img src="public/logo.png" alt="Bloquinho" style="width: 80px; height: 80px; margin-bottom: 20px; border-radius: 12px;">
          <h2 style="margin-bottom: 10px;">Bloquinho Web App</h2>
          <p style="margin-bottom: 20px; text-align: center; max-width: 500px;">
            Sua aplicação Flutter está pronta! Em uma implementação real, 
            o Flutter seria carregado aqui permitindo acesso completo a todos os recursos do Bloquinho.
          </p>
          <div style="background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); max-width: 500px;">
            <h3 style="margin-bottom: 15px; color: #8B4513;">Recursos Disponíveis:</h3>
            <ul style="text-align: left; color: #666; line-height: 1.6;">
              <li>📝 Editor de notas com Markdown</li>
              <li>📅 Agenda e gerenciamento de tarefas</li>
              <li>🗃️ Sistema de base de dados</li>
              <li>🔐 Gestor de senhas</li>
              <li>📎 Anexos e documentos</li>
              <li>🧮 Suporte a LaTeX e fórmulas</li>
              <li>📊 Diagramas Mermaid</li>
              <li>🤖 Assistente de IA</li>
            </ul>
          </div>
          <p style="margin-top: 20px; font-size: 14px; color: #666;">
            Dados sincronizados com ${this.getStorageProviderName()}
          </p>
        </div>
      `;
    }, 3000);
  }

  getFlutterBuildPath() {
    // Em produção, retornaria o caminho para o build do Flutter
    // Por exemplo: './flutter_build/index.html'
    return 'about:blank'; // Placeholder
  }

  getStorageProviderName() {
    const authData = this.getAuthData();
    if (!authData) return 'Cloud Storage';
    
    try {
      const parsed = JSON.parse(authData);
      const provider = parsed.storage_settings?.provider;
      
      switch (provider) {
        case 'googleDrive':
          return 'Google Drive';
        case 'oneDrive':
          return 'OneDrive';
        default:
          return 'Cloud Storage';
      }
    } catch (e) {
      return 'Cloud Storage';
    }
  }

  showFlutterError() {
    const errorContainer = document.getElementById('error-container');
    if (errorContainer) {
      errorContainer.style.display = 'flex';
    }
    
    const loadingContainer = document.getElementById('loading-container');
    if (loadingContainer) {
      loadingContainer.style.display = 'none';
    }
  }

  getAuthData() {
    return localStorage.getItem('bloquinho_auth_data');
  }

  setAuthData(data) {
    localStorage.setItem('bloquinho_auth_data', JSON.stringify(data));
    this.notifyAuthStateListeners({ authenticated: true, data });
  }

  clearAuthData() {
    localStorage.removeItem('bloquinho_auth_data');
    this.notifyAuthStateListeners({ authenticated: false });
  }

  setupAuthStateListeners() {
    // Listener para mudanças no localStorage
    window.addEventListener('storage', (e) => {
      if (e.key === 'bloquinho_auth_data') {
        const authenticated = e.newValue !== null;
        this.notifyAuthStateListeners({ authenticated });
      }
    });
  }

  addAuthStateListener(callback) {
    this.authStateListeners.push(callback);
  }

  removeAuthStateListener(callback) {
    const index = this.authStateListeners.indexOf(callback);
    if (index > -1) {
      this.authStateListeners.splice(index, 1);
    }
  }

  notifyAuthStateListeners(state) {
    this.authStateListeners.forEach(callback => {
      try {
        callback(state);
      } catch (error) {
        console.error('Error in auth state listener:', error);
      }
    });
  }

  // Métodos para comunicação com Flutter
  sendMessageToFlutter(message) {
    if (!this.flutterAppLoaded) {
      console.warn('Flutter app not loaded yet');
      return;
    }

    const iframe = document.getElementById('flutter-iframe');
    if (iframe && iframe.contentWindow) {
      iframe.contentWindow.postMessage(message, '*');
    }
  }

  // Método para receber mensagens do Flutter
  setupFlutterMessageListener() {
    window.addEventListener('message', (event) => {
      if (event.source === document.getElementById('flutter-iframe')?.contentWindow) {
        this.handleFlutterMessage(event.data);
      }
    });
  }

  handleFlutterMessage(message) {
    console.log('Message from Flutter:', message);
    
    // Processar mensagens do Flutter
    switch (message.type) {
      case 'auth_request':
        this.handleAuthRequest(message.data);
        break;
      case 'storage_sync':
        this.handleStorageSync(message.data);
        break;
      case 'navigation':
        this.handleNavigation(message.data);
        break;
      default:
        console.log('Unknown message type:', message.type);
    }
  }

  handleAuthRequest(data) {
    // Processar solicitação de autenticação do Flutter
    const authData = this.getAuthData();
    this.sendMessageToFlutter({
      type: 'auth_response',
      data: authData ? JSON.parse(authData) : null
    });
  }

  handleStorageSync(data) {
    // Processar sincronização de dados
    console.log('Storage sync requested:', data);
  }

  handleNavigation(data) {
    // Processar navegação
    if (data.url) {
      window.location.href = data.url;
    }
  }
}

// Inicializar integração quando o DOM estiver pronto
document.addEventListener('DOMContentLoaded', () => {
  window.flutterIntegration = new FlutterWebIntegration();
});

// Exportar para uso global
window.FlutterWebIntegration = FlutterWebIntegration;