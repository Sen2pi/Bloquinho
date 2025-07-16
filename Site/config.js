// Cloud Storage API Configuration
// Replace these with your actual API keys and client IDs

const CONFIG = {
  google: {
    // Get these from Google Cloud Console:
    // 1. Go to https://console.cloud.google.com/
    // 2. Create a new project or select existing
    // 3. Enable Google Drive API
    // 4. Create credentials (OAuth 2.0 Client ID)
    // 5. Add your domain to authorized origins
    clientId: 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com',
    apiKey: 'YOUR_GOOGLE_API_KEY',
    scopes: 'https://www.googleapis.com/auth/drive.file'
  },
  
  microsoft: {
    // Get these from Azure Portal:
    // 1. Go to https://portal.azure.com/
    // 2. Navigate to Azure Active Directory
    // 3. Go to App registrations
    // 4. Create a new registration
    // 5. Add your domain to redirect URIs
    // 6. Grant permissions for Files.ReadWrite
    clientId: 'YOUR_MICROSOFT_CLIENT_ID',
    scopes: ['Files.ReadWrite', 'Files.ReadWrite.All']
  }
};

// Export configuration
window.BLOQUINHO_CONFIG = CONFIG;