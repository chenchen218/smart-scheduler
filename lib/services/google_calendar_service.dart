import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import 'web_oauth_service.dart';

/// Google Calendar Service for Web Integration
/// Handles Google Calendar API operations for web platforms
class GoogleCalendarService {
  static final GoogleCalendarService _instance =
      GoogleCalendarService._internal();
  factory GoogleCalendarService() => _instance;
  GoogleCalendarService._internal();

  // Google Calendar API configuration
  static const String _clientId =
      '796545909849-d14htdi0bdehcljan5usm5lf4f7o4ah9.apps.googleusercontent.com';
  static const String _redirectUri = 'http://localhost:3000/oauth2redirect';

  // Get client secret from environment variable
  static String get _clientSecret {
    const clientSecret = String.fromEnvironment('GOOGLE_CLIENT_SECRET');
    if (clientSecret.isEmpty) {
      throw Exception('GOOGLE_CLIENT_SECRET environment variable is not set');
    }
    return clientSecret;
  }

  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/calendar.readonly',
    'https://www.googleapis.com/auth/calendar.events',
  ];

  calendar.CalendarApi? _calendarApi;
  AuthClient? _authClient;
  bool _isAuthenticated = false;
  final WebOAuthService _oauthService = WebOAuthService();

  /// Check if user is authenticated with Google Calendar
  bool get isAuthenticated => _isAuthenticated;

  /// Initialize Google Calendar service
  Future<bool> initialize() async {
    if (!kIsWeb) {
      return false; // Only available on web
    }

    try {
      // First, check if we're returning from OAuth callback
      final callbackHandled = await _oauthService.checkAndHandleCallback();
      if (callbackHandled) {
        print('OAuth callback handled successfully');
      }

      // Check if we have OAuth authorization code
      final authCode = _oauthService.getStoredAuthCode();
      if (authCode != null) {
        print('Found stored authorization code, exchanging for tokens...');
        // Exchange code for tokens
        final credentials = await _exchangeCodeForTokens(authCode);
        if (credentials != null) {
          _authClient = authenticatedClient(http.Client(), credentials);
          _calendarApi = calendar.CalendarApi(_authClient!);
          _isAuthenticated = true;
          print('Google Calendar authentication successful');
          return true;
        }
      }
      return false;
    } catch (e) {
      print('GoogleCalendarService: Initialization failed: $e');
      return false;
    }
  }

  /// Authenticate with Google Calendar
  Future<bool> authenticate() async {
    if (!kIsWeb) {
      return false;
    }

    try {
      print(
        'GoogleCalendarService: Starting Google Calendar authentication...',
      );

      // Start OAuth flow
      final success = await _oauthService.authenticate();

      if (success) {
        // Initialize with the new credentials
        return await initialize();
      }

      return false;
    } catch (e) {
      print('GoogleCalendarService: Authentication failed: $e');
      return false;
    }
  }

  /// Get list of available calendars
  Future<List<CalendarInfo>> getCalendars() async {
    if (!_isAuthenticated || _calendarApi == null) {
      throw Exception('Not authenticated with Google Calendar');
    }

    try {
      final calendarList = await _calendarApi!.calendarList.list();
      return calendarList.items
              ?.map(
                (cal) => CalendarInfo(
                  id: cal.id ?? '',
                  name: cal.summary ?? 'Untitled Calendar',
                  description: cal.description ?? '',
                  color: cal.backgroundColor ?? '#4285f4',
                  isPrimary: cal.primary ?? false,
                ),
              )
              .toList() ??
          [];
    } catch (e) {
      throw Exception('Failed to fetch calendars: $e');
    }
  }

  /// Get events from a specific calendar
  Future<List<CalendarEvent>> getEvents({
    String? calendarId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isAuthenticated || _calendarApi == null) {
      throw Exception('Not authenticated with Google Calendar');
    }

    try {
      final events = await _calendarApi!.events.list(
        calendarId ?? 'primary',
        timeMin: startDate,
        timeMax: endDate,
        singleEvents: true,
        orderBy: 'startTime',
      );

      return events.items
              ?.map((event) => _convertGoogleEventToAppEvent(event))
              .toList() ??
          [];
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  /// Get today's events
  Future<List<CalendarEvent>> getTodaysEvents() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return getEvents(startDate: startOfDay, endDate: endOfDay);
  }

  /// Create a new event
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    if (!_isAuthenticated || _calendarApi == null) {
      throw Exception('Not authenticated with Google Calendar');
    }

    try {
      final googleEvent = _convertAppEventToGoogleEvent(event);
      final createdEvent = await _calendarApi!.events.insert(
        googleEvent,
        'primary',
      );

      return _convertGoogleEventToAppEvent(createdEvent);
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  /// Update an existing event
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    if (!_isAuthenticated || _calendarApi == null) {
      throw Exception('Not authenticated with Google Calendar');
    }

    try {
      final googleEvent = _convertAppEventToGoogleEvent(event);
      final updatedEvent = await _calendarApi!.events.update(
        googleEvent,
        'primary',
        event.externalId ?? event.id,
      );

      return _convertGoogleEventToAppEvent(updatedEvent);
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  /// Delete an event
  Future<bool> deleteEvent(String eventId) async {
    if (!_isAuthenticated || _calendarApi == null) {
      throw Exception('Not authenticated with Google Calendar');
    }

    try {
      await _calendarApi!.events.delete('primary', eventId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  /// Sign out from Google Calendar
  Future<void> signOut() async {
    _authClient?.close();
    _calendarApi = null;
    _isAuthenticated = false;
    await _clearStoredCredentials();
  }

  /// Clear all stored OAuth data and start fresh
  Future<void> clearStoredData() async {
    await _oauthService.clearCredentials();
    _authClient?.close();
    _calendarApi = null;
    _isAuthenticated = false;
  }

  /// Convert Google Calendar event to app event model
  CalendarEvent _convertGoogleEventToAppEvent(calendar.Event googleEvent) {
    final start = googleEvent.start?.dateTime ?? googleEvent.start?.date;
    final end = googleEvent.end?.dateTime ?? googleEvent.end?.date;

    return CalendarEvent(
      id: googleEvent.id ?? '',
      title: googleEvent.summary ?? 'Untitled Event',
      description: googleEvent.description ?? '',
      date: start?.toLocal() ?? DateTime.now(),
      startTime: start != null ? TimeOfDay.fromDateTime(start.toLocal()) : null,
      endTime: end != null ? TimeOfDay.fromDateTime(end.toLocal()) : null,
      isAllDay: googleEvent.start?.date != null,
      location: googleEvent.location,
      color: _parseGoogleColor(googleEvent.colorId),
      source: 'google_calendar',
      externalId: googleEvent.id,
      calendarId: 'primary',
      startDate: start?.toLocal(),
      endDate: end?.toLocal(),
    );
  }

  /// Convert app event model to Google Calendar event
  calendar.Event _convertAppEventToGoogleEvent(CalendarEvent event) {
    final startDateTime = event.startDate ?? DateTime.now();
    final endDateTime =
        event.endDate ?? startDateTime.add(const Duration(hours: 1));

    return calendar.Event(
      summary: event.title,
      description: event.description,
      location: event.location,
      start: calendar.EventDateTime(dateTime: startDateTime, timeZone: 'UTC'),
      end: calendar.EventDateTime(dateTime: endDateTime, timeZone: 'UTC'),
    );
  }

  /// Parse Google Calendar color ID to Flutter Color
  Color _parseGoogleColor(String? colorId) {
    final colorMap = {
      '1': const Color(0xFFA4BDFC), // Lavender
      '2': const Color(0xFF7AE7BF), // Sage
      '3': const Color(0xFFDBADFF), // Grape
      '4': const Color(0xFFFF887C), // Flamingo
      '5': const Color(0xFFFFB878), // Banana
      '6': const Color(0xFFFBD75B), // Tangerine
      '7': const Color(0xFFFF8A80), // Peacock
      '8': const Color(0xFFA4E56E), // Graphite
      '9': const Color(0xFF51B749), // Blueberry
      '10': const Color(0xFFE8F0FE), // Basil
      '11': const Color(0xFFFCE4EC), // Tomato
    };

    return colorMap[colorId] ?? const Color(0xFF4285F4); // Default blue
  }

  /// Exchange authorization code for access tokens using PKCE
  Future<AccessCredentials?> _exchangeCodeForTokens(String authCode) async {
    try {
      // Get the PKCE code verifier from localStorage
      final codeVerifier = html.window.localStorage['pkce_code_verifier'];
      if (codeVerifier == null) {
        print('PKCE code verifier not found');
        return null;
      }

      final requestBody = Uri(
        queryParameters: {
          'client_id': _clientId,
          'code': authCode,
          'grant_type': 'authorization_code',
          'redirect_uri': _redirectUri,
          'code_verifier': codeVerifier,
          'client_secret': _clientSecret,
        },
      ).query;

      print('Token exchange request body: $requestBody');
      print('Token exchange URL: https://oauth2.googleapis.com/token');
      print(
        'Token exchange headers: Content-Type: application/x-www-form-urlencoded',
      );

      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestBody,
      );

      print('Token exchange response status: ${response.statusCode}');
      print('Token exchange response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Token exchange successful');
        return AccessCredentials(
          AccessToken(
            'Bearer',
            data['access_token'],
            DateTime.now().add(Duration(seconds: data['expires_in'])),
          ),
          data['refresh_token'],
          _scopes,
        );
      } else {
        print(
          'Token exchange failed with status ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Token exchange error: $e');
      return null;
    }
  }

  /// Clear stored credentials
  Future<void> _clearStoredCredentials() async {
    // In a real implementation, you would:
    // 1. Clear localStorage/sessionStorage
    // 2. Revoke tokens with Google
  }
}

/// Calendar information model
class CalendarInfo {
  final String id;
  final String name;
  final String description;
  final String color;
  final bool isPrimary;

  CalendarInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.isPrimary,
  });
}
