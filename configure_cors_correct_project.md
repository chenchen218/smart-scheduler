# Configure CORS for the Correct Project

## The Issue

Your Firebase project `to-do-list-2b175` appears as `firebase-adminsdk` in Google Cloud Console. This is normal - Firebase projects often have different names in Google Cloud Console.

## Solution: Configure CORS for `firebase-adminsdk`

### Step 1: Access the Correct Project

1. **Go to Google Cloud Console**: https://console.cloud.google.com/
2. **Select project**: `firebase-adminsdk` (the one you see in the image)
3. **Navigate to**: Cloud Storage → Browser
4. **Look for your bucket**: It should be named something like `firebase-adminsdk-xxxxx.appspot.com` or similar

### Step 2: Configure CORS

1. **Click on your storage bucket**
2. **Go to "Permissions" tab**
3. **Click "Add Principal" or "Edit CORS"**
4. **Add CORS configuration**:

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

### Step 3: Alternative - Use Command Line

If you have gcloud access, you can configure CORS directly:

```bash
# Create CORS configuration
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

# Apply CORS configuration (replace with your actual bucket name)
gsutil cors set cors.json gs://firebase-adminsdk-xxxxx.appspot.com
```

### Step 4: Find Your Actual Bucket Name

To find your exact bucket name:

1. In Google Cloud Console → Cloud Storage → Browser
2. Look for buckets that start with `firebase-adminsdk` or contain your Firebase project ID
3. The bucket name will be something like: `firebase-adminsdk-xxxxx.appspot.com`

## Why This Happens

- Firebase projects often get different names in Google Cloud Console
- The project ID in Firebase Console (`to-do-list-2b175`) is different from the Google Cloud project name (`firebase-adminsdk`)
- Both refer to the same underlying project, just with different display names

## Test After Configuration

After configuring CORS for the correct project, restart your Flutter app and try uploading a profile picture. The CORS errors should be resolved.
