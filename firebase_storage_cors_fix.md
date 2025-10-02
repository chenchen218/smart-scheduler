# Firebase Storage CORS Fix

## The Problem

CORS (Cross-Origin Resource Sharing) errors occur when your web app (localhost) tries to access Firebase Storage from a different origin.

## Solution: Configure CORS at Bucket Level

### Option 1: Google Cloud Console (Recommended)

1. Go to: https://console.cloud.google.com/
2. Select project: `to-do-list-2b175`
3. Navigate to: **Cloud Storage → Browser**
4. Click on bucket: `to-do-list-2b175.appspot.com`
5. Go to **"Permissions"** tab
6. Click **"Add Principal"**
7. Add CORS configuration:

```json
[
  {
    "origin": ["*"],
    "method": ["GET", "PUT", "POST", "DELETE", "OPTIONS"],
    "responseHeader": ["*"],
    "maxAgeSeconds": 3600
  }
]
```

### Option 2: Firebase Console

1. Go to: https://console.firebase.google.com/
2. Select project: `to-do-list-2b175`
3. Go to **Storage → Rules**
4. Update rules to:

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

5. Click **"Publish"**

### Option 3: Command Line (If you have gcloud access)

```bash
# Set CORS configuration
gsutil cors set cors.json gs://to-do-list-2b175.appspot.com
```

Where `cors.json` contains:

```json
[
  {
    "origin": ["*"],
    "method": ["GET", "PUT", "POST", "DELETE", "OPTIONS"],
    "responseHeader": ["*"],
    "maxAgeSeconds": 3600
  }
]
```

## Test After Configuration

1. Restart your Flutter app
2. Try uploading a profile picture
3. Check for success messages in console

## Expected Success Messages

```
ProfileScreen: Firebase upload completed. URL: https://...
ProfileScreen: Profile update success: true
ProfileScreen: Building CircleAvatar with photoURL: https://...
```
