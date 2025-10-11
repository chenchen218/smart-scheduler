# SmartScheduler 🚀

Developer: Chen
A modern, AI-powered Flutter application for intelligent task and event management with voice-to-text capabilities, smart scheduling suggestions, and complete user authentication system.

## ✨ Features

### 🎯 Core Functionality

- **Task Management**: Automatic task generation with priority levels
- **Calendar Integration**: Interactive calendar with event management
- **Google Calendar Sync**: Real-time synchronization with Google Calendar
- **Event Creation**: Rich event creation with priority, location, and tags
- **Smart Scheduling**: AI-powered scheduling suggestions
- **Voice Input**: Speech-to-text for hands-free event creation
- **User Authentication**: Complete sign-in/sign-up system with Firebase
- **Profile Management**: User profiles with photo upload and settings
- **User Isolation**: Each user sees only their own data
- **Cross-Platform Events**: Local app events + Google Calendar events

### 🔐 Authentication & Security

- **Firebase Authentication**: Email/password and Google Sign-In
- **User Profiles**: Profile pictures, name editing, password changes
- **Secure Storage**: User-specific data isolation
- **Environment Variables**: Secure credential management
- **Mock Authentication**: Development mode for testing

### 🤖 AI Features

- **Voice-to-Text**: Create events using natural speech
- **Smart Scheduling**: AI suggests optimal times for events
- **Priority Management**: Intelligent priority assignment
- **Text-to-Speech**: Audio feedback for accessibility

### 🎨 Modern UI/UX

- **Material 3 Design**: Latest Material Design principles
- **Dark/Light Theme**: Automatic theme switching with user preferences
- **Smooth Animations**: Optimized performance with modular architecture
- **Responsive Design**: Works on mobile, tablet, and web
- **Profile Interface**: Modern profile management with image upload

## 🏗️ Architecture

### Modular Structure

The app follows a clean, modular architecture with separation of concerns:

```
lib/
├── main.dart                     # App entry point with Firebase initialization
├── firebase_options.dart        # Firebase configuration (environment variables)
├── theme/
│   └── app_theme.dart           # Centralized theming
├── models/
│   ├── task.dart                # Task data model
│   ├── calendar_event.dart      # Event data model
│   ├── user_model.dart          # User data model
│   └── auth_state.dart          # Authentication state model
├── providers/
│   ├── auth_provider.dart       # Authentication state management
│   └── settings_provider.dart   # User settings management
├── services/
│   ├── auth_service.dart        # Firebase authentication service
│   ├── mock_auth_service.dart   # Mock authentication for development
│   ├── image_upload_service.dart # Firebase Storage image upload
│   ├── settings_service.dart    # User settings persistence
│   ├── firestore_event_service.dart # Firestore event storage
│   ├── calendar_integration_service.dart # Google Calendar integration
│   ├── google_calendar_service.dart # Google Calendar API service
│   └── web_oauth_service.dart   # OAuth 2.0 for web platforms
├── config/
│   └── auth_config.dart         # Authentication configuration
├── service/
│   ├── calendar_service.dart    # Event CRUD operations
│   ├── local_storage_service.dart # Local data persistence
│   └── ai_service.dart         # AI features (voice, scheduling)
├── screens/
│   ├── auth/                    # Authentication screens
│   │   ├── signin_screen.dart
│   │   ├── signup_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── profile/                # Profile management
│   │   └── profile_screen.dart
│   ├── home/                    # Home screen module
│   │   ├── home_screen.dart
│   │   ├── controllers/
│   │   │   └── home_controller.dart
│   │   └── widgets/
│   │       ├── home_header.dart
│   │       ├── home_tab_navigation.dart
│   │       ├── task_list_widget.dart
│   │       └── event_list_widget.dart
│   ├── calendar/               # Calendar screen module
│   │   ├── calendar_screen.dart
│   │   ├── calendar_integration_screen.dart # Google Calendar integration UI
│   │   ├── controllers/
│   │   │   └── calendar_controller.dart
│   │   └── widgets/
│   │       ├── calendar_header.dart
│   │       ├── calendar_widget.dart
│   │       └── events_list_widget.dart
│   └── add_event/              # Add event screen module
│       ├── add_event_screen.dart
│       ├── controllers/
│       │   └── add_event_controller.dart
│       └── widgets/
│           ├── voice_input_section.dart
│           ├── priority_selection_widget.dart
│           └── color_selection_widget.dart
└── widgets/
    ├── task_card.dart          # Reusable task component
    └── event_card.dart         # Reusable event component
```

### 🎯 Design Patterns

- **MVC Architecture**: Controllers manage business logic
- **Provider Pattern**: State management with ChangeNotifier
- **Widget Composition**: Reusable, focused components
- **Service Layer**: Clean separation of data operations
- **Authentication Flow**: Secure user authentication with Firebase
- **User Isolation**: Per-user data storage and management

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Android Studio / VS Code
- Chrome (for web development)
- Firebase project (for authentication)

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd mini_todo_app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Firebase Setup**

   The app uses Firebase for authentication, storage, and Firestore database. You have two options:

   #### Option A: Use Your Own Firebase Project (Recommended)

   1. **Create a Firebase project** at [Firebase Console](https://console.firebase.google.com)
   2. **Enable Authentication** with Email/Password and Google Sign-In
   3. **Enable Firestore Database** for event storage
   4. **Enable Storage** for profile picture uploads
   5. **Configure Storage Rules** to allow authenticated users to upload
   6. **Set up Firestore Security Rules** for user data isolation
   7. **Copy the template** and add your credentials:
      ```bash
      cp setup_env.sh.template setup_env.sh
      ```
   8. **Edit `setup_env.sh`** with your Firebase project credentials:
      - `FIREBASE_PROJECT_ID`: Your Firebase project ID
      - `FIREBASE_WEB_API_KEY`: Your web API key
      - `FIREBASE_WEB_APP_ID`: Your web app ID
      - `GOOGLE_CLIENT_SECRET`: Your Google OAuth client secret
      - And other platform-specific credentials

   #### Option B: Use Mock Authentication (Development)

   The app includes mock authentication for development. No Firebase setup required.
   Set `useMockAuth = true` in `lib/config/auth_config.dart` for development.

4. **Run the application**

   ```bash
   # Using Firebase (with your credentials)
   ./setup_env.sh

   # Or manually with environment variables
   flutter run -d chrome \
     --dart-define=FIREBASE_PROJECT_ID=your-project-id \
     --dart-define=FIREBASE_WEB_API_KEY=your-api-key \
     # ... other variables
   ```

### 🔧 Development Setup

#### Web Development

```bash
flutter run -d chrome --web-renderer html
```

#### Mobile Development

```bash
# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios
```

## 📱 Platform Support

- ✅ **Web**: Chrome, Firefox, Safari, Edge
- ✅ **Android**: API 21+ (Android 5.0+)
- ✅ **iOS**: iOS 11.0+
- ✅ **macOS**: macOS 10.14+
- ✅ **Windows**: Windows 10+
- ✅ **Linux**: Ubuntu 18.04+

## 🛠️ Tech Stack

### Core Technologies

- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **Material 3**: Design system

### Key Dependencies

```yaml
dependencies:
  flutter: sdk

  # UI & Navigation
  provider: ^6.0.5
  table_calendar: ^3.0.9

  # Data & Storage
  shared_preferences: ^2.2.2

  # Firebase Authentication & Storage
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  firebase_storage: ^11.5.6
  cloud_firestore: ^4.13.6
  google_sign_in: ^6.1.6

  # Calendar Integration
  device_calendar: ^4.3.0
  googleapis: ^11.4.0
  googleapis_auth: ^1.4.1
  timezone: ^0.9.4
  crypto: ^3.0.3

  # AI & Voice Features
  speech_to_text: ^6.6.0
  flutter_tts: ^3.8.5
  permission_handler: ^11.2.0

  # Image & File Handling
  image_picker: ^1.0.4
  path: ^1.8.3

  # Utilities
  intl: ^0.19.0
  http: ^1.1.0
```

### AI & Voice Features

- **Speech-to-Text**: Native Flutter implementation
- **Text-to-Speech**: Cross-platform audio output
- **Smart Scheduling**: Custom AI algorithm
- **Voice Commands**: Natural language processing

## 🎨 UI/UX Features

### Design System

- **Material 3**: Latest design guidelines
- **Dynamic Theming**: Light/dark mode support with user preferences
- **Responsive Layout**: Adapts to different screen sizes
- **Accessibility**: Screen reader support, high contrast
- **Profile Interface**: Modern profile management with image upload

### Animations & Interactions

- **Smooth Transitions**: Optimized performance
- **Gesture Support**: Swipe-to-delete, pull-to-refresh
- **Micro-interactions**: Button feedback, loading states
- **List Animations**: Dynamic insertions/removals
- **Image Upload**: Drag-and-drop profile picture upload
- **Settings Toggle**: Smooth theme and notification toggles

## 👤 User Management Features

### Profile Management

- **Profile Pictures**: Upload, edit, and remove profile photos
- **Name Editing**: In-app display name updates
- **Password Changes**: Secure password updates with validation
- **Settings Persistence**: User preferences saved locally
- **Theme Management**: Light/dark mode with system preference

### Authentication Flow

- **Sign In/Sign Up**: Email/password and Google authentication
- **Password Recovery**: Email-based password reset
- **User Isolation**: Each user sees only their own data
- **Session Management**: Automatic login state persistence
- **Mock Authentication**: Development mode for testing

## 🔧 Configuration

### Permissions

The app requires the following permissions:

#### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

#### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone for voice input to create events and tasks.</string>
```

## 📊 Performance Optimizations

### Modular Architecture Benefits

- **Reduced Bundle Size**: Smaller, focused components
- **Faster Build Times**: Incremental compilation
- **Better Memory Management**: Proper disposal patterns
- **Optimized Rebuilds**: Targeted widget updates

### Animation Performance

- **Debounced Updates**: 16ms batching for smooth animations
- **Controller Pattern**: Centralized state management
- **Widget Optimization**: Const constructors where possible
- **Memory Management**: Proper timer cleanup

## 🧪 Testing

### Running Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/
```

### Test Coverage

- **Unit Tests**: Business logic and controllers
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end user flows

## 🚀 Deployment

### Web Deployment

```bash
# Build for web
flutter build web

# Deploy to Firebase Hosting
firebase deploy
```

### Mobile Deployment

```bash
# Android APK
flutter build apk --release

# iOS App Store
flutter build ios --release
```

## 🤝 Contributing

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Code Style

- Follow Dart/Flutter conventions
- Use meaningful variable names
- Add comments for complex logic
- Maintain consistent formatting

## 🔐 Authentication & User Management

### Firebase Authentication

The app supports multiple authentication methods:

- **Email/Password**: Traditional email-based authentication
- **Google Sign-In**: One-click Google authentication
- **Mock Authentication**: Development mode for testing
- **Password Reset**: Email-based password recovery

## 📅 Google Calendar Integration

### OAuth 2.0 with PKCE

The app integrates with Google Calendar using secure OAuth 2.0 with PKCE (Proof Key for Code Exchange):

- **Secure Authentication**: OAuth 2.0 flow with PKCE for web security
- **Real-time Sync**: Google Calendar events appear instantly in the app
- **Cross-Platform**: Works on web with proper OAuth flow
- **Event Merging**: Local app events + Google Calendar events displayed together
- **Permission Management**: Granular calendar access permissions

### Google Cloud Console Setup

1. **Enable Google Calendar API** in Google Cloud Console
2. **Create OAuth 2.0 Credentials** for web application
3. **Configure Redirect URIs** for OAuth callback
4. **Set up OAuth Consent Screen** with test users
5. **Add Client Secret** to environment variables

### Calendar Integration Features

- **Event Synchronization**: Real-time Google Calendar event fetching
- **Date Range Queries**: Efficient event loading for specific periods
- **Event Conflict Detection**: Identify scheduling conflicts
- **Source Identification**: Distinguish between local and Google events
- **Offline Fallback**: Local storage when Google Calendar unavailable

## 🗄️ Firestore Database Setup

### Database Structure

```
users/{userId}/events/{eventId}
```

### Event Data Model

```json
{
  "id": "event_123",
  "title": "Meeting with Team",
  "description": "Weekly standup",
  "date": "2025-10-15T10:00:00.000Z",
  "startDate": "2025-10-15T10:00:00.000Z",
  "endDate": "2025-10-15T11:00:00.000Z",
  "priority": "high",
  "isCompleted": false,
  "source": "app",
  "externalId": null,
  "calendarId": null
}
```

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/events/{eventId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Data Flow Architecture

1. **Primary Storage**: Firestore for cloud-based event storage
2. **Fallback Storage**: Local storage when Firestore unavailable
3. **Event Merging**: Local events + Google Calendar events
4. **Real-time Updates**: Events sync across devices
5. **User Isolation**: Each user sees only their own data

### User Profile Features

- **Profile Pictures**: Upload and manage profile photos
- **Name Editing**: Update display name
- **Password Changes**: Secure password updates
- **Settings Management**: User preferences and theme settings
- **Account Management**: Sign out and account deletion

### Security Features

- **Environment Variables**: Firebase credentials stored securely
- **User Isolation**: Each user's data is completely separate
- **Secure Storage**: Local data encrypted per user
- **No Hardcoded Secrets**: All credentials use environment variables
- **CORS Configuration**: Proper cross-origin setup for web uploads
- **Firebase Storage Rules**: Secure file upload permissions

## 📈 Roadmap

### Upcoming Features

- [x] **Firebase Integration**: Authentication and user management
- [x] **User Isolation**: Secure per-user data storage
- [x] **Profile Management**: User profiles with photo upload
- [x] **Settings Management**: User preferences and theme settings
- [x] **Google Calendar Integration**: Real-time sync with Google Calendar
- [x] **Firestore Database**: Cloud-based event storage
- [x] **OAuth 2.0 with PKCE**: Secure Google Calendar authentication
- [ ] **Cloud Sync**: Real-time data synchronization
- [ ] **Team Collaboration**: Shared calendars and tasks
- [ ] **Advanced AI**: Machine learning for better scheduling
- [ ] **Offline Support**: Full offline functionality
- [ ] **Widgets**: Home screen widgets for quick access
- [ ] **Push Notifications**: Event reminders and updates

### Performance Improvements

- [ ] **Lazy Loading**: On-demand data loading
- [ ] **Caching**: Intelligent data caching
- [ ] **Background Sync**: Automatic data synchronization
- [ ] **Push Notifications**: Event reminders

## 🐛 Troubleshooting

### Common Issues

#### Firebase Authentication Issues

- **Invalid API Key**: Ensure your Firebase credentials are correct in `setup_env.sh`
- **Google Sign-In Not Working**: Check that Google Sign-In is enabled in Firebase Console
- **Environment Variables Not Loading**: Verify you're using `./setup_env.sh` to run the app
- **Profile Picture Upload Fails**: Check Firebase Storage rules and CORS configuration
- **Storage Rules Error**: Update Firebase Storage rules to allow authenticated users

#### Voice Input Not Working

- Check microphone permissions
- Ensure device has microphone access
- Try restarting the app

#### Performance Issues

- Clear app data and restart
- Check for memory leaks in DevTools
- Optimize widget rebuilds

#### Build Errors

- Run `flutter clean`
- Delete `pubspec.lock`
- Run `flutter pub get`

#### Environment Setup Issues

- **Script not executable**: Run `chmod +x setup_env.sh`
- **Template not found**: Copy `setup_env.sh.template` to `setup_env.sh`
- **Credentials missing**: Check that all Firebase environment variables are set
- **CORS errors**: Ensure Firebase Storage CORS is configured for your domain
- **Storage bucket mismatch**: Verify bucket name uses `.firebasestorage.app` not `.appspot.com`

#### Google Calendar Integration Issues

- **OAuth redirect mismatch**: Ensure redirect URI in Google Cloud Console matches `http://localhost:3000/oauth2redirect`
- **Client secret missing**: Add `GOOGLE_CLIENT_SECRET` to `setup_env.sh`
- **OAuth consent screen**: Configure OAuth consent screen with test users in Google Cloud Console
- **Calendar API not enabled**: Enable Google Calendar API in Google Cloud Console
- **PKCE code verifier missing**: Clear stored data and retry OAuth flow
- **DateTime timezone errors**: Fixed in latest version with proper UTC DateTime handling
- **Google events not appearing**: Check OAuth authentication status and event fetching logs

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team**: For the amazing framework
- **Material Design**: For the design system
- **Open Source Community**: For the excellent packages

## 📞 Support

For support, email support@smartscheduler.app or create an issue on GitHub.

---

**SmartScheduler** - Intelligent task and event management made simple! 🚀
