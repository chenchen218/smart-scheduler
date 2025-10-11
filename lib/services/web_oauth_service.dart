import 'dart:html' as html;
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Web OAuth Service for Google Calendar
/// Handles OAuth 2.0 flow for web platforms
class WebOAuthService {
  static final WebOAuthService _instance = WebOAuthService._internal();
  factory WebOAuthService() => _instance;
  WebOAuthService._internal();

  // OAuth configuration
  static const String _clientId =
      '796545909849-d14htdi0bdehcljan5usm5lf4f7o4ah9.apps.googleusercontent.com';
  static const String _redirectUri = 'http://localhost:3000/oauth2redirect';
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/calendar.readonly',
    'https://www.googleapis.com/auth/calendar.events',
  ];

  /// Start OAuth flow
  Future<bool> authenticate() async {
    if (!kIsWeb) {
      return false;
    }

    try {
      // Build OAuth URL
      final authUrl = _buildAuthUrl();

      // Redirect the main window to start OAuth flow
      html.window.location.href = authUrl;

      // Return false for now - the actual success will be handled in the callback
      return false;
    } catch (e) {
      print('WebOAuthService: Authentication failed: $e');
      return false;
    }
  }

  /// Handle OAuth callback and extract authorization code
  Future<bool> _handleOAuthCallback(String callbackUrl) async {
    try {
      final uri = Uri.parse(callbackUrl);
      final code = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];

      if (error != null) {
        print('OAuth error: $error');
        return false;
      }

      if (code != null) {
        // Check if PKCE verifier still exists
        final verifier = html.window.localStorage['pkce_code_verifier'];
        print('OAuth callback: PKCE verifier exists: ${verifier != null}');
        if (verifier != null) {
          print('OAuth callback: PKCE verifier length: ${verifier.length}');
        }

        // Store the authorization code
        await _storeAuthCode(code);
        print('OAuth authorization code stored successfully');
        return true;
      }

      return false;
    } catch (e) {
      print('Error handling OAuth callback: $e');
      return false;
    }
  }

  /// Build OAuth authorization URL with PKCE
  String _buildAuthUrl() {
    // Generate PKCE code verifier and challenge
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);

    // Store code verifier for later use
    html.window.localStorage['pkce_code_verifier'] = codeVerifier;

    // Debug PKCE values (lengths only)
    try {
      print('PKCE: verifier length=${codeVerifier.length}');
      print('PKCE: challenge length=${codeChallenge.length}');
      print('PKCE: redirectUri=$_redirectUri');
      print('PKCE: clientId=$_clientId');
    } catch (_) {}

    final params = {
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'response_type': 'code',
      'scope': _scopes.join(' '),
      'access_type': 'offline',
      'prompt': 'consent',
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
    };

    final queryString = params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');

    return 'https://accounts.google.com/o/oauth2/v2/auth?$queryString';
  }

  /// Generate PKCE code verifier
  String _generateCodeVerifier() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random();
    return List.generate(
      128,
      (i) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Generate PKCE code challenge
  String _generateCodeChallenge(String codeVerifier) {
    // Hash the code verifier with SHA256 and base64url encode it
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  /// Store authorization code
  Future<void> _storeAuthCode(String code) async {
    html.window.localStorage['google_auth_code'] = code;
    html.window.localStorage['google_auth_timestamp'] = DateTime.now()
        .millisecondsSinceEpoch
        .toString();
  }

  /// Get stored authorization code
  String? getStoredAuthCode() {
    if (!kIsWeb) return null;

    final code = html.window.localStorage['google_auth_code'];
    final timestamp = html.window.localStorage['google_auth_timestamp'];

    if (code != null && timestamp != null) {
      final authTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(timestamp),
      );
      final now = DateTime.now();

      // Check if code is not older than 10 minutes
      if (now.difference(authTime).inMinutes < 10) {
        return code;
      }
    }

    return null;
  }

  /// Clear stored credentials
  Future<void> clearCredentials() async {
    if (!kIsWeb) return;

    html.window.localStorage.remove('google_auth_code');
    html.window.localStorage.remove('google_auth_timestamp');
    html.window.localStorage.remove('google_access_token');
    html.window.localStorage.remove('google_refresh_token');
    html.window.localStorage.remove('pkce_code_verifier');
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    if (!kIsWeb) return false;
    return getStoredAuthCode() != null;
  }

  /// Check if we're on the OAuth callback page and handle it
  Future<bool> checkAndHandleCallback() async {
    if (!kIsWeb) return false;

    final currentUrl = html.window.location.href;
    if (currentUrl.contains('oauth2redirect')) {
      return await _handleOAuthCallback(currentUrl);
    }
    return false;
  }
}
