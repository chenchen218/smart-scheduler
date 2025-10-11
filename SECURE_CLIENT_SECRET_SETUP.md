# Secure Client Secret Setup

## 🔒 Security Best Practices

**NEVER** put client secrets directly in your source code! Here's how to do it securely:

## 📋 Step-by-Step Setup

### 1. Get Your Client Secret

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to: APIs & Services > Credentials
3. Click on your OAuth client
4. Copy the "Client secret" (starts with `GOCSPX-`)

### 2. Update the Setup Script

Replace `YOUR_CLIENT_SECRET_HERE` in `setup_env.sh` with your actual client secret:

```bash
# Edit setup_env.sh and replace this line:
--dart-define=GOOGLE_CLIENT_SECRET=YOUR_CLIENT_SECRET_HERE

# With your actual client secret:
--dart-define=GOOGLE_CLIENT_SECRET=GOCSPX-your-actual-secret-here
```

### 3. Run the App Securely

```bash
# Use the setup script (recommended)
./setup_env.sh

# Or run directly with the secret
flutter run -d chrome --web-port=3000 --dart-define=GOOGLE_CLIENT_SECRET=GOCSPX-your-secret
```

## 🛡️ Security Notes

- ✅ **DO**: Use environment variables
- ✅ **DO**: Keep secrets out of version control
- ✅ **DO**: Use the setup script
- ❌ **DON'T**: Hardcode secrets in source code
- ❌ **DON'T**: Commit secrets to Git
- ❌ **DON'T**: Share secrets in chat/email

## 🔧 Alternative: Use .env File

For even better security, you can use a `.env` file:

1. Create `.env` file (add to `.gitignore`):

```
GOOGLE_CLIENT_SECRET=GOCSPX-your-secret-here
```

2. Load it in your Flutter app (requires additional package)

## 🚀 Ready to Test

Once you've updated `setup_env.sh` with your client secret, run:

```bash
./setup_env.sh
```

The OAuth flow should now work properly!
