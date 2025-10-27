import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'screens/home/home_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/auth/signin_screen.dart';
import 'screens/teams/team_list_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(MiniTodoApp());
}

class MiniTodoApp extends StatelessWidget {
  const MiniTodoApp({super.key});

  // Global navigator key for stable context access
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          // Initialize settings on first build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            settingsProvider.initializeSettings();
          });

          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Mini To-Do App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.themeModeForApp,
            home: const AuthWrapper(),
            routes: {'/teams': (context) => const TeamListScreen()},
          );
        },
      ),
    );
  }
}

/// Authentication Wrapper
/// Determines whether to show auth screens or main app based on auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while checking auth state
        if (!authProvider.state.isInitialized || authProvider.state.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        // Show error state if there's an error
        if (authProvider.state.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error: ${authProvider.state.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Try to reinitialize auth
                      authProvider.initializeAuth();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Show auth screens if not authenticated
        if (!authProvider.isAuthenticated) {
          return const SignInScreen();
        }

        // Show main app if authenticated
        return const MainNavigationScreen();
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: colorScheme.surface,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurfaceVariant,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_rounded),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
