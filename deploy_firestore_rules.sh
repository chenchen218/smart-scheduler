#!/bin/bash

# Deploy Firestore Security Rules
# This script deploys the firestore.rules file to your Firebase project

echo "🚀 Deploying Firestore Security Rules..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install it first:"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    echo "🔐 Please login to Firebase first:"
    echo "firebase login"
    exit 1
fi

# Deploy the rules
echo "📝 Deploying security rules..."
firebase deploy --only firestore:rules

if [ $? -eq 0 ]; then
    echo "✅ Firestore security rules deployed successfully!"
    echo "🔒 Your database is now secure with proper user isolation."
    echo "📊 You can verify the rules in the Firebase Console under Firestore > Rules"
else
    echo "❌ Failed to deploy rules. Please check your Firebase configuration."
    exit 1
fi
