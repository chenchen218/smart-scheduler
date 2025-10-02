# Firebase Console CORS Fix (Easier Method)

## Why Use Firebase Console Instead?

Your Firebase project `to-do-list-2b175` already exists and has Storage enabled. We can configure CORS directly through Firebase Console without needing Google Cloud Console.

## Step-by-Step Instructions

### Method 1: Firebase Console Storage Rules (Recommended)

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project**: `to-do-list-2b175`
3. **Navigate to**: Storage → Rules
4. **Replace the existing rules with**:

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to upload profile pictures
    match /profile_pictures/{allPaths=**} {
      allow read, write: if request.auth != null;
    }

    // Allow all authenticated users to read and write (development only)
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

5. **Click "Publish"**

### Method 2: Firebase Console Storage Settings

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project**: `to-do-list-2b175`
3. **Navigate to**: Storage → Files
4. **Look for "CORS" or "Settings" options**
5. **Configure CORS to allow localhost**

### Method 3: Test Without CORS (Temporary)

If CORS configuration is complex, we can temporarily modify the upload approach to work around CORS restrictions.

## Expected Result

After updating the Storage rules, restart your Flutter app and try uploading a profile picture. You should see:

```
ProfileScreen: Firebase upload completed. URL: https://...
ProfileScreen: Profile update success: true
```

## If Still Getting CORS Errors

The Storage rules approach should resolve most CORS issues. If you still get errors, we can implement a server-side upload solution or use Firebase Functions as a proxy.
