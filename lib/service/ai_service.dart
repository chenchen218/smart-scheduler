import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/calendar_event.dart';

/// AI Service for SmartScheduler app
/// Handles voice-to-text, text-to-speech, and smart scheduling algorithms
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Speech recognition
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  // Voice processing state
  bool _isListening = false;
  bool _isSpeaking = false;
  String _lastRecognizedText = '';

  /// Initialize AI services
  Future<bool> initialize() async {
    try {
      // Initialize speech recognition
      bool available = await _speechToText.initialize(
        onError: (error) => print('Speech recognition error: $error'),
        onStatus: (status) => print('Speech recognition status: $status'),
      );

      // Initialize text-to-speech
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      return available;
    } catch (e) {
      print('Error initializing AI services: $e');
      return false;
    }
  }

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      print('Error requesting microphone permission: $e');
      return false;
    }
  }

  /// Start listening for voice input
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
  }) async {
    try {
      if (!_isListening) {
        _isListening = true;
        await _speechToText.listen(
          onResult: (result) {
            _lastRecognizedText = result.recognizedWords;
            onResult(result.recognizedWords);
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          localeId: "en_US",
          onSoundLevelChange: (level) {
            // Handle sound level changes for UI feedback
          },
        );
      }
    } catch (e) {
      _isListening = false;
      onError('Error starting speech recognition: $e');
    }
  }

  /// Stop listening for voice input
  Future<void> stopListening() async {
    try {
      if (_isListening) {
        await _speechToText.stop();
        _isListening = false;
      }
    } catch (e) {
      print('Error stopping speech recognition: $e');
    }
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Get last recognized text
  String get lastRecognizedText => _lastRecognizedText;

  /// Speak text using text-to-speech
  Future<void> speak(String text) async {
    try {
      if (!_isSpeaking && text.isNotEmpty) {
        _isSpeaking = true;
        await _flutterTts.speak(text);

        // Wait for speech to complete
        _flutterTts.setCompletionHandler(() {
          _isSpeaking = false;
        });
      }
    } catch (e) {
      _isSpeaking = false;
      print('Error speaking text: $e');
    }
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    try {
      if (_isSpeaking) {
        await _flutterTts.stop();
        _isSpeaking = false;
      }
    } catch (e) {
      print('Error stopping speech: $e');
    }
  }

  /// Check if currently speaking
  bool get isSpeaking => _isSpeaking;

  /// Parse voice input to extract event details
  Map<String, dynamic> parseVoiceInput(String voiceText) {
    final text = voiceText.toLowerCase();
    final result = <String, dynamic>{
      'title': '',
      'description': '',
      'priority': 'Medium',
      'date': DateTime.now(),
      'time': '09:00',
      'location': '',
      'tags': <String>[],
    };

    // Extract title (usually the first part)
    final words = text.split(' ');
    if (words.isNotEmpty) {
      result['title'] = words.take(3).join(' ').trim();
    }

    // Extract priority keywords
    if (text.contains('urgent') ||
        text.contains('important') ||
        text.contains('high')) {
      result['priority'] = 'High';
    } else if (text.contains('low') || text.contains('minor')) {
      result['priority'] = 'Low';
    }

    // Extract time keywords
    if (text.contains('morning') || text.contains('am')) {
      result['time'] = '09:00';
    } else if (text.contains('afternoon')) {
      result['time'] = '14:00';
    } else if (text.contains('evening') || text.contains('pm')) {
      result['time'] = '18:00';
    }

    // Extract date keywords
    if (text.contains('today')) {
      result['date'] = DateTime.now();
    } else if (text.contains('tomorrow')) {
      result['date'] = DateTime.now().add(const Duration(days: 1));
    } else if (text.contains('next week')) {
      result['date'] = DateTime.now().add(const Duration(days: 7));
    }

    // Extract location keywords
    if (text.contains('at home') || text.contains('home')) {
      result['location'] = 'Home';
    } else if (text.contains('office') || text.contains('work')) {
      result['location'] = 'Office';
    }

    // Extract tags
    final tagKeywords = [
      'meeting',
      'call',
      'appointment',
      'deadline',
      'reminder',
    ];
    for (final keyword in tagKeywords) {
      if (text.contains(keyword)) {
        result['tags'].add(keyword);
      }
    }

    return result;
  }

  /// Generate smart scheduling suggestions
  List<SmartSchedulingSuggestion> generateSmartSuggestions({
    required List<CalendarEvent> existingEvents,
    required String eventTitle,
    required String priority,
    required DateTime preferredDate,
  }) {
    final suggestions = <SmartSchedulingSuggestion>[];

    // Analyze existing events for conflicts
    final conflicts = _findConflicts(existingEvents, preferredDate);

    // Generate time slots based on priority
    final timeSlots = _generateTimeSlots(priority, conflicts);

    // Create suggestions
    for (int i = 0; i < timeSlots.length && i < 3; i++) {
      final slot = timeSlots[i];
      final suggestion = SmartSchedulingSuggestion(
        suggestedDateTime: slot,
        confidence: _calculateConfidence(slot, priority, conflicts),
        reason: _generateReason(slot, priority, conflicts),
        alternativeTimes: _generateAlternatives(slot, timeSlots),
      );
      suggestions.add(suggestion);
    }

    return suggestions;
  }

  /// Find scheduling conflicts
  List<DateTime> _findConflicts(List<CalendarEvent> events, DateTime date) {
    final conflicts = <DateTime>[];
    final targetDate = DateTime(date.year, date.month, date.day);

    for (final event in events) {
      final eventDate = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      if (eventDate.isAtSameMomentAs(targetDate)) {
        conflicts.add(event.date);
      }
    }

    return conflicts;
  }

  /// Generate optimal time slots
  List<DateTime> _generateTimeSlots(String priority, List<DateTime> conflicts) {
    final slots = <DateTime>[];
    final baseDate = DateTime.now();

    // Define optimal times based on priority
    List<int> optimalHours;
    switch (priority.toLowerCase()) {
      case 'high':
        optimalHours = [9, 10, 11, 14, 15]; // Peak productivity hours
        break;
      case 'medium':
        optimalHours = [10, 11, 14, 15, 16];
        break;
      case 'low':
        optimalHours = [16, 17, 18, 19];
        break;
      default:
        optimalHours = [10, 11, 14, 15];
    }

    // Generate slots avoiding conflicts
    for (final hour in optimalHours) {
      final slot = DateTime(baseDate.year, baseDate.month, baseDate.day, hour);
      if (!_hasConflict(slot, conflicts)) {
        slots.add(slot);
      }
    }

    // Sort by optimal time
    slots.sort((a, b) => a.hour.compareTo(b.hour));
    return slots;
  }

  /// Check if time slot has conflict
  bool _hasConflict(DateTime slot, List<DateTime> conflicts) {
    for (final conflict in conflicts) {
      if ((slot.hour == conflict.hour) ||
          (slot.hour == conflict.hour - 1) ||
          (slot.hour == conflict.hour + 1)) {
        return true;
      }
    }
    return false;
  }

  /// Calculate confidence score for suggestion
  double _calculateConfidence(
    DateTime slot,
    String priority,
    List<DateTime> conflicts,
  ) {
    double confidence = 0.8; // Base confidence

    // Adjust based on priority
    switch (priority.toLowerCase()) {
      case 'high':
        if (slot.hour >= 9 && slot.hour <= 11) confidence += 0.2;
        break;
      case 'medium':
        if (slot.hour >= 10 && slot.hour <= 15) confidence += 0.1;
        break;
      case 'low':
        if (slot.hour >= 16 && slot.hour <= 18) confidence += 0.1;
        break;
    }

    // Reduce confidence if conflicts exist
    if (conflicts.isNotEmpty) confidence -= 0.1;

    return confidence.clamp(0.0, 1.0);
  }

  /// Generate reason for suggestion
  String _generateReason(
    DateTime slot,
    String priority,
    List<DateTime> conflicts,
  ) {
    final hour = slot.hour;
    final timeOfDay = _getTimeOfDay(hour);

    if (conflicts.isEmpty) {
      return "Optimal $timeOfDay slot with no conflicts";
    } else {
      return "Good $timeOfDay slot, minimal conflicts";
    }
  }

  /// Get time of day description
  String _getTimeOfDay(int hour) {
    if (hour < 12) return "morning";
    if (hour < 17) return "afternoon";
    return "evening";
  }

  /// Generate alternative time suggestions
  List<DateTime> _generateAlternatives(
    DateTime primary,
    List<DateTime> allSlots,
  ) {
    return allSlots.where((slot) => slot != primary).take(2).toList();
  }

  /// Analyze user patterns for better suggestions
  Map<String, dynamic> analyzeUserPatterns(List<CalendarEvent> events) {
    if (events.isEmpty) {
      return {
        'preferredHours': [10, 14, 16],
        'preferredDays': ['Monday', 'Tuesday', 'Wednesday'],
        'averageEventDuration': 60,
        'mostProductiveTime': 'morning',
      };
    }

    // Analyze preferred hours
    final hourCounts = <int, int>{};
    for (final event in events) {
      final hour = event.date.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    final preferredHours = hourCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Analyze preferred days
    final dayCounts = <String, int>{};
    for (final event in events) {
      final dayName = _getDayName(event.date.weekday);
      dayCounts[dayName] = (dayCounts[dayName] ?? 0) + 1;
    }

    final preferredDays = dayCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'preferredHours': preferredHours.take(3).map((e) => e.key).toList(),
      'preferredDays': preferredDays.take(3).map((e) => e.key).toList(),
      'averageEventDuration': 60, // Default 1 hour
      'mostProductiveTime': _getMostProductiveTime(preferredHours),
    };
  }

  /// Get day name from weekday number
  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  /// Get most productive time of day
  String _getMostProductiveTime(List<MapEntry<int, int>> hourCounts) {
    if (hourCounts.isEmpty) return 'morning';

    final topHour = hourCounts.first.key;
    if (topHour < 12) return 'morning';
    if (topHour < 17) return 'afternoon';
    return 'evening';
  }
}

/// Smart scheduling suggestion model
class SmartSchedulingSuggestion {
  final DateTime suggestedDateTime;
  final double confidence;
  final String reason;
  final List<DateTime> alternativeTimes;

  SmartSchedulingSuggestion({
    required this.suggestedDateTime,
    required this.confidence,
    required this.reason,
    required this.alternativeTimes,
  });
}
