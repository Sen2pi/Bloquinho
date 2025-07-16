# OAuth Setup Guide for Bloquinho Web App

## Overview
To enable cloud storage authentication in the Bloquinho web app, you need to configure OAuth applications for Google Drive and OneDrive.

## Google Drive Setup

### 1. Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google Drive API:
   - Navigate to "APIs & Services" > "Library"
   - Search for "Google Drive API"
   - Click "Enable"

### 2. Create OAuth 2.0 Credentials
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth 2.0 Client ID"
3. Choose "Web application" as the application type
4. Configure authorized origins:
   - Add your domain (e.g., `https://yourdomain.com`)
   - For development: `http://localhost:8080`
5. Configure redirect URIs:
   - Add your domain with `/web_auth.html` (e.g., `https://yourdomain.com/web_auth.html`)
   - For development: `http://localhost:8080/web_auth.html`
6. Save the Client ID and Client Secret

### 3. Get API Key
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "API Key"
3. Restrict the API key to Google Drive API only
4. Save the API Key

## OneDrive Setup

### 1. Create Azure App Registration
1. Go to [Azure Portal](https://portal.azure.com/)
2. Navigate to "Azure Active Directory" > "App registrations"
3. Click "New registration"
4. Configure:
   - Name: "Bloquinho Web App"
   - Supported account types: "Accounts in any organizational directory and personal Microsoft accounts"
   - Redirect URI: Web - `https://yourdomain.com/web_auth.html`
   - For development: `http://localhost:8080/web_auth.html`

### 2. Configure API Permissions
1. Go to "API permissions" in your app registration
2. Click "Add a permission"
3. Select "Microsoft Graph"
4. Choose "Delegated permissions"
5. Add the following permissions:
   - `Files.ReadWrite`
   - `Files.ReadWrite.All`
   - `User.Read`
6. Click "Grant admin consent" (if you have admin privileges)

### 3. Get Application ID
1. Go to "Overview" in your app registration
2. Copy the "Application (client) ID"

## Configuration

### 1. Update config.js
Edit `Site/config.js` and replace the placeholder values:

```javascript
const CONFIG = {
  google: {
    clientId: 'YOUR_ACTUAL_GOOGLE_CLIENT_ID.apps.googleusercontent.com',
    apiKey: 'YOUR_ACTUAL_GOOGLE_API_KEY',
    scopes: 'https://www.googleapis.com/auth/drive.file'
  },
  
  microsoft: {
    clientId: 'YOUR_ACTUAL_MICROSOFT_CLIENT_ID',
    scopes: ['Files.ReadWrite', 'Files.ReadWrite.All']
  }
};
```

### 2. Test the Setup
1. Start a local web server in the `Site` directory
2. Navigate to `web_auth.html`
3. Test authentication with both Google Drive and OneDrive
4. Verify that the `/Bloquinho` folder is created in the cloud storage

## Security Considerations

1. **Domain Restrictions**: Only add your actual domain to the authorized origins
2. **API Key Restrictions**: Restrict the Google API key to only the Google Drive API
3. **Scope Limitations**: Only request the minimum necessary permissions
4. **HTTPS**: Always use HTTPS in production
5. **Client Secret**: Never expose client secrets in client-side code

## Troubleshooting

### Common Issues
1. **CORS Errors**: Ensure your domain is added to authorized origins
2. **Redirect URI Mismatch**: Check that redirect URIs match exactly
3. **Permission Denied**: Verify that API permissions are granted
4. **Invalid Client**: Check that client IDs are correct

### Testing
1. Use browser developer tools to check for JavaScript errors
2. Verify that the OAuth flow redirects properly
3. Check that tokens are stored in localStorage
4. Confirm that the Bloquinho folder is created in cloud storage

## Development vs Production

### Development
- Use `http://localhost:8080` for origins and redirects
- Test with personal accounts first
- Use browser developer tools for debugging

### Production
- Use HTTPS domains only
- Test with multiple account types
- Monitor for authentication failures
- Implement proper error handling

## Support

For issues with OAuth setup:
1. Check the browser console for JavaScript errors
2. Verify API permissions in cloud consoles
3. Test with different accounts
4. Check network requests in browser dev tools

Remember to keep your client IDs and API keys secure and never commit them to version control!