# Get Google OAuth Client ID for Web

## Steps to get your OAuth Client ID:

### Method 1: Firebase Console (Easiest)

1. Go to: https://console.firebase.google.com/project/to-do-list-2b175/settings/general
2. Scroll to "Your apps" section
3. Click on the Web app
4. Copy the "Web client ID"

### Method 2: Google Cloud Console

1. Go to: https://console.cloud.google.com/apis/credentials?project=to-do-list-2b175
2. Find "OAuth 2.0 Client IDs"
3. Look for "Web client (auto created by Google Service)"
4. Copy the Client ID

## After getting the Client ID:

Replace this line in `web/index.html`:

```html
<meta
  name="google-signin-client_id"
  content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com"
/>
```

With your actual Client ID:

```html
<meta
  name="google-signin-client_id"
  content="796545909849-XXXXXXXXXXXXXXXXX.apps.googleusercontent.com"
/>
```

## Enable Google Sign-In:

1. Go to: https://console.firebase.google.com/project/to-do-list-2b175/authentication/providers
2. Click on "Google" provider
3. Toggle "Enable"
4. Set support email
5. Save

## Test:

```bash
./setup_env.sh
```

Then click "Continue with Google" button!
