# Google Calendar API Setup Guide

## 🚀 Complete Setup Steps

### **Step 1: Enable Google Calendar API**

1. **Go to Google Cloud Console**: https://console.cloud.google.com/
2. **Select your project**: `to-do-list-2b175` (or create new)
3. **Navigate to**: APIs & Services → Library
4. **Search for**: "Google Calendar API"
5. **Click**: "Enable"

### **Step 2: Configure OAuth Consent Screen**

1. **Navigate to**: APIs & Services → OAuth consent screen
2. **User Type**: External
3. **Fill required fields**:
   - App name: `SmartScheduler`
   - User support email: `dawsonlee0512@gmail.com`
   - Developer contact: `dawsonlee0512@gmail.com`
4. **Scopes**: Add these scopes:
   - `https://www.googleapis.com/auth/calendar.readonly`
   - `https://www.googleapis.com/auth/calendar.events`
5. **Test users**: Add your email for testing

### **Step 3: Create OAuth 2.0 Credentials**

1. **Navigate to**: APIs & Services → Credentials
2. **Click**: "Create Credentials" → "OAuth client ID"
3. **Application type**: Web application
4. **Name**: `SmartScheduler Web Client`
5. **Authorized redirect URIs**:
   ```
   http://localhost:3000/oauth2redirect
   http://localhost:8080/oauth2redirect
   http://localhost:5000/oauth2redirect
   ```
6. **Click**: "Create"
7. **Copy the Client ID** (you already have this: `796545909849-d14htdi0bdehcljan5usm5lf4f7o4ah9.apps.googleusercontent.com`)

### **Step 4: Update Your Code**

The code is already updated with:

- ✅ OAuth 2.0 flow implementation
- ✅ Popup-based authentication
- ✅ Token exchange
- ✅ Calendar API integration

### **Step 5: Test the Integration**

1. **Run your app**: `./setup_env.sh`
2. **Navigate to**: Profile → Calendar Integration
3. **Click**: "Connect Google Calendar"
4. **Complete OAuth flow** in popup
5. **Verify**: Events should load from Google Calendar

## 🔧 Troubleshooting

### **Common Issues:**

1. **"redirect_uri_mismatch"**

   - Ensure redirect URIs in Google Console match your app
   - Check that you're using the correct port (3000)

2. **"access_denied"**

   - User denied permission
   - Check OAuth consent screen configuration

3. **"invalid_client"**

   - Verify Client ID is correct
   - Ensure OAuth client is configured for web

4. **Popup blocked**
   - Allow popups for localhost
   - Check browser popup settings

### **Debug Steps:**

1. **Check browser console** for errors
2. **Verify redirect URIs** in Google Console
3. **Test OAuth flow** manually
4. **Check network requests** in DevTools

## 📱 Mobile vs Web

| Platform    | Integration         | Authentication   |
| ----------- | ------------------- | ---------------- |
| **Web**     | Google Calendar API | OAuth 2.0 Popup  |
| **iOS**     | Device Calendar     | Permission-based |
| **Android** | Device Calendar     | Permission-based |

## 🎯 Expected Behavior

### **Web (Chrome/Firefox/Safari):**

1. Click "Connect Google Calendar"
2. OAuth popup opens
3. User grants permissions
4. Popup closes automatically
5. Calendar events load
6. Full Google Calendar sync

### **Mobile (iOS/Android):**

1. Click "Grant Permission"
2. System permission dialog
3. User grants calendar access
4. Device calendar events load
5. Native calendar integration

## 🚀 Next Steps After Setup

1. **Test the flow** end-to-end
2. **Add error handling** for edge cases
3. **Implement token refresh** for long sessions
4. **Add calendar selection** (multiple calendars)
5. **Sync events** bidirectionally

## 📚 Resources

- [Google Calendar API Documentation](https://developers.google.com/calendar/api)
- [OAuth 2.0 for Web Applications](https://developers.google.com/identity/protocols/oauth2/web-server)
- [Google Cloud Console](https://console.cloud.google.com/)

---

**Your SmartScheduler app now supports both device calendars (mobile) and Google Calendar (web) with a unified, platform-aware interface!** 🎉
