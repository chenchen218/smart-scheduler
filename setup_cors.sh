#!/bin/bash

# Firebase Storage CORS Setup Script
# This script configures CORS for Firebase Storage to allow web uploads

echo "Setting up Firebase Storage CORS configuration..."

# Check if gsutil is available
if ! command -v gsutil &> /dev/null; then
    echo "Error: gsutil is not installed or not in PATH"
    echo "Please install Google Cloud SDK and run 'gcloud auth login'"
    echo "Then run this script again."
    exit 1
fi

# Apply CORS configuration to Firebase Storage bucket
echo "Applying CORS configuration to Firebase Storage bucket..."
gsutil cors set cors.json gs://to-do-list-2b175.appspot.com

if [ $? -eq 0 ]; then
    echo "✅ CORS configuration applied successfully!"
    echo "You can now upload profile pictures from the web app."
else
    echo "❌ Failed to apply CORS configuration."
    echo "Please check your Firebase project settings and try again."
fi
