# Fix CORS Properly for Firebase Storage

## The Real Solution

The CORS error occurs because Firebase Storage (which is Google Cloud Storage) needs CORS configuration at the bucket level. Here's how to fix it properly:

## Method 1: Google Cloud Console (Recommended)

1. **Go to Google Cloud Console**: https://console.cloud.google.com/
2. **Make sure you're logged in with the same account as your Firebase project**
3. **Select your project**: `to-do-list-2b175` (it should appear in the project selector)
4. **Navigate to**: Cloud Storage → Browser
5. **Click on your bucket**: `to-do-list-2b175.appspot.com`
6. **Go to "Permissions" tab**
7. **Click "Add Principal"**
8. **Add CORS configuration**:

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

## Method 2: Command Line (If you have gcloud access)

```bash
# Create CORS configuration file
cat > cors.json << EOF
[
  {
    "origin": ["*"],
    "method": ["GET", "PUT", "POST", "DELETE", "OPTIONS"],
    "responseHeader": ["*"],
    "maxAgeSeconds": 3600
  }
]
EOF

# Apply CORS configuration
gsutil cors set cors.json gs://to-do-list-2b175.appspot.com
```

## Method 3: Firebase Console Storage Rules (Alternative)

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select project**: `to-do-list-2b175`
3. **Go to Storage → Rules**
4. **Update rules to**:

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

5. **Click "Publish"**

## Why This Works

- **CORS configuration** allows your localhost development server to make requests to Firebase Storage
- **Storage rules** control who can access the files
- **Both are needed** for proper functionality

## Test After Configuration

1. Restart your Flutter app
2. Try uploading a profile picture
3. You should see success messages without CORS errors

## Expected Success Messages

```
ProfileScreen: Firebase upload completed. URL: https://firebasestorage.googleapis.com/...
ProfileScreen: Profile update success: true
```
