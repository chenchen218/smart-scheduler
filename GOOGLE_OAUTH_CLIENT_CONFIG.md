# Google OAuth Client Configuration for PKCE

## Issue: "client_secret is missing" Error

The token exchange is failing because Google's OAuth endpoint expects a `client_secret` parameter even for PKCE flows in some configurations.

## Solution 1: Code Fix (Already Applied)

I've removed the `client_secret` parameter entirely from the token exchange request since PKCE flows don't require it.

## Solution 2: Google Cloud Console Configuration

If the issue persists, you may need to configure your OAuth client properly:

### Steps to Check/Update OAuth Client Configuration:

1. **Go to Google Cloud Console**

   - Navigate to: https://console.cloud.google.com/
   - Select your project: `to-do-list-2b175`

2. **Go to APIs & Services > Credentials**

   - Click on your OAuth 2.0 Client ID (the one ending in `...apps.googleusercontent.com`)

3. **Check Application Type**

   - Ensure it's set to "Web application"
   - If it's "Desktop application" or "Mobile application", change it to "Web application"

4. **Verify Authorized Redirect URIs**

   - Make sure these URIs are included:
     - `http://localhost:3000/oauth2redirect`
     - `http://localhost:8080/oauth2redirect`
     - `http://localhost:5000/oauth2redirect`

5. **OAuth Consent Screen Configuration**
   - Go to "OAuth consent screen"
   - Ensure "Publishing status" is set to "Testing"
   - Add your email (`dawsonlee0512@gmail.com`) as a test user
   - Add these scopes:
     - `https://www.googleapis.com/auth/calendar.readonly`
     - `https://www.googleapis.com/auth/calendar.events`

## Testing the Fix

After applying the code fix:

1. **Restart your Flutter app** (hot restart might not be enough)
2. **Clear browser cache** (Ctrl+Shift+R or Cmd+Shift+R)
3. **Try the "Connect Google Calendar" button again**

## Expected Behavior

You should now see:

- `Token exchange request body: ...` in the console
- `Token exchange successful` instead of the error
- Google Calendar events appearing in your app

## If Still Not Working

If you still get the "client_secret is missing" error, the issue is likely with your OAuth client configuration. Try this:

### Create a New PKCE-Compatible OAuth Client:

1. **Go to Google Cloud Console**

   - Navigate to: https://console.cloud.google.com/
   - Select your project: `to-do-list-2b175`

2. **Go to APIs & Services > Credentials**

   - Click "Create Credentials" > "OAuth client ID"

3. **Create New OAuth Client for PKCE**

   - **Application type**: Choose "Web application"
   - **Name**: "SmartScheduler PKCE Client"
   - **Authorized redirect URIs**: Add these URIs:
     - `http://localhost:3000/oauth2redirect`
     - `http://localhost:8080/oauth2redirect`
     - `http://localhost:5000/oauth2redirect`
   - **Authorized JavaScript origins**: Add:
     - `http://localhost:3000`
     - `http://localhost:8080`
     - `http://localhost:5000`

4. **Important: Configure for PKCE**

   - After creating the client, click on it to edit
   - Look for "Application type" - it should be "Web application"
   - **Do NOT** add a client secret (leave it empty)
   - The client should work with PKCE without requiring a client_secret

5. **Update Your Code with New Client ID**
   - Copy the new Client ID from Google Cloud Console
   - Update the `_clientId` in your code with the new Client ID

The new OAuth client should be properly configured for PKCE flows.
