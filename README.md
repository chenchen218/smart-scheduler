# SmartScheduler 🚀

A modern, AI-powered Flutter application for intelligent task and event management with voice-to-text capabilities and smart scheduling suggestions.

## ✨ Features

### 🎯 Core Functionality

- **Task Management**: Automatic task generation with priority levels
- **Calendar Integration**: Interactive calendar with event management
- **Event Creation**: Rich event creation with priority, location, and tags
- **Smart Scheduling**: AI-powered scheduling suggestions
- **Voice Input**: Speech-to-text for hands-free event creation

### 🤖 AI Features

- **Voice-to-Text**: Create events using natural speech
- **Smart Scheduling**: AI suggests optimal times for events
- **Priority Management**: Intelligent priority assignment
- **Text-to-Speech**: Audio feedback for accessibility

### 🎨 Modern UI/UX

- **Material 3 Design**: Latest Material Design principles
- **Dark/Light Theme**: Automatic theme switching
- **Smooth Animations**: Optimized performance with modular architecture
- **Responsive Design**: Works on mobile, tablet, and web

## 🏗️ Architecture

### Modular Structure

The app follows a clean, modular architecture with separation of concerns:

```
lib/
├── main.dart                     # App entry point
├── theme/
│   └── app_theme.dart           # Centralized theming
├── models/
│   ├── task.dart                # Task data model
│   └── calendar_event.dart      # Event data model
├── service/
│   ├── calendar_service.dart    # Event CRUD operations
│   ├── local_storage_service.dart # Local data persistence
│   └── ai_service.dart         # AI features (voice, scheduling)
├── screens/
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

   The app uses Firebase for authentication. You have two options:

   #### Option A: Use Your Own Firebase Project (Recommended)

   1. **Create a Firebase project** at [Firebase Console](https://console.firebase.google.com)
   2. **Enable Authentication** with Email/Password and Google Sign-In
   3. **Copy the template** and add your credentials:
      ```bash
      cp setup_env.sh.template setup_env.sh
      ```
   4. **Edit `setup_env.sh`** with your Firebase project credentials:
      - `FIREBASE_PROJECT_ID`: Your Firebase project ID
      - `FIREBASE_WEB_API_KEY`: Your web API key
      - `FIREBASE_WEB_APP_ID`: Your web app ID
      - And other platform-specific credentials

   #### Option B: Use Mock Authentication (Development)

   The app includes mock authentication for development. No Firebase setup required.

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

  # Firebase Authentication
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  google_sign_in: ^6.1.6
  firebase_storage: ^11.5.6

  # AI & Voice Features
  speech_to_text: ^6.6.0
  flutter_tts: ^3.8.5
  permission_handler: ^11.2.0

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
- **Dynamic Theming**: Light/dark mode support
- **Responsive Layout**: Adapts to different screen sizes
- **Accessibility**: Screen reader support, high contrast

### Animations & Interactions

- **Smooth Transitions**: Optimized performance
- **Gesture Support**: Swipe-to-delete, pull-to-refresh
- **Micro-interactions**: Button feedback, loading states
- **List Animations**: Dynamic insertions/removals

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

## 🔐 Authentication

### Firebase Authentication

The app supports multiple authentication methods:

- **Email/Password**: Traditional email-based authentication
- **Google Sign-In**: One-click Google authentication
- **Mock Authentication**: Development mode for testing

### Security Features

- **Environment Variables**: Firebase credentials stored securely
- **User Isolation**: Each user's data is completely separate
- **Secure Storage**: Local data encrypted per user
- **No Hardcoded Secrets**: All credentials use environment variables

## 📈 Roadmap

### Upcoming Features

- [x] **Firebase Integration**: Authentication and user management
- [x] **User Isolation**: Secure per-user data storage
- [ ] **Cloud Sync**: Real-time data synchronization
- [ ] **Team Collaboration**: Shared calendars and tasks
- [ ] **Advanced AI**: Machine learning for better scheduling
- [ ] **Offline Support**: Full offline functionality
- [ ] **Widgets**: Home screen widgets for quick access

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
