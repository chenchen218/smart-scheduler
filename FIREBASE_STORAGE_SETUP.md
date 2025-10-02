# Firebase Storage Setup for Profile Picture Uploads

## Issue

Profile picture uploads are failing with CORS errors when running on localhost. This is because Firebase Storage blocks cross-origin requests by default.

## Solutions

### Option 1: Configure CORS (Recommended)

1. **Install Google Cloud SDK** (if not already installed):

   ```bash
   # On macOS with Homebrew
   brew install google-cloud-sdk

   # Or download from: https://cloud.google.com/sdk/docs/install
   ```

2. **Authenticate with Google Cloud**:

   ```bash
   gcloud auth login
   ```

3. **Set your project**:

   ```bash
   gcloud config set project to-do-list-2b175
   ```

4. **Apply CORS configuration**:
   ```bash
   ./setup_cors.sh
   ```

### Option 2: Update Firebase Storage Rules

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project**: `to-do-list-2b175`
3. **Navigate to Storage** → **Rules**
4. **Replace the rules** with the content from `storage.rules`
5. **Publish the rules**

### Option 3: Use Firebase Emulator (Development)

1. **Install Firebase CLI**:

   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:

   ```bash
   firebase login
   ```

3. **Start emulators**:

   ```bash
   firebase emulators:start --only storage
   ```

4. **Update your app** to use emulator (add to `main.dart`):
   ```dart
   // Add this after Firebase.initializeApp()
   FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
   ```

## Verification

After applying any of the above solutions:

1. **Restart your Flutter app**:

   ```bash
   ./setup_env.sh
   ```

2. **Try uploading a profile picture** from the Profile tab
3. **Check the console** for successful upload logs

## Expected Success Logs

```
ProfileScreen: Context mounted: true
ProfileScreen: Showing loading dialog...
ProfileScreen: Creating ImageUploadService...
ProfileScreen: Starting Firebase upload from bytes...
ImageUploadService: Profile picture uploaded successfully from bytes: https://...
ProfileScreen: Firebase upload completed. URL: https://...
ProfileScreen: Profile update success: true
ProfileScreen: Building CircleAvatar with photoURL: https://...
```

## Troubleshooting

- **CORS still failing**: Make sure you've applied the CORS configuration correctly
- **Authentication errors**: Check that your Firebase project has Storage enabled
- **Permission denied**: Verify your Storage rules allow authenticated users
- **Network errors**: Ensure your Firebase project is properly configured

## Production Considerations

For production deployment:

1. Use proper Storage security rules
2. Implement file type validation
3. Add file size limits
4. Use proper CORS configuration for your domain
