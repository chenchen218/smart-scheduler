import 'package:flutter/material.dart';
import '../../../models/calendar_event.dart';
import '../../../service/calendar_service.dart';
import '../../../service/ai_service.dart';

/// Controller for Add Event Screen
/// Manages state and business logic for event creation/editing
class AddEventController extends ChangeNotifier {
  final CalendarService _calendarService = CalendarService();
  final AIService _aiService = AIService();

  // Form controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();

  // Form state
  DateTime selectedDate = DateTime.now();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool isAllDay = false;
  Color selectedColor = Colors.blue;
  bool isCompleted = false;
  String priority = 'Medium';

  // Voice input state
  bool isListening = false;
  String voiceText = '';
  bool isAIServiceInitialized = false;

  // Smart scheduling state
  List<SmartSchedulingSuggestion> smartSuggestions = [];
  bool showSmartSuggestions = false;

  // Event to edit (if editing)
  CalendarEvent? eventToEdit;

  AddEventController({this.eventToEdit}) {
    if (eventToEdit != null) {
      _populateFields(eventToEdit!);
    }
    _initializeAIService();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    tagsController.dispose();
    if (isListening) {
      _aiService.stopListening();
    }
    super.dispose();
  }

  /// Initialize AI service for voice input and smart scheduling
  Future<void> _initializeAIService() async {
    try {
      isAIServiceInitialized = await _aiService.initialize();
      if (!isAIServiceInitialized) {
        print('AI service initialization failed');
      }
    } catch (e) {
      print('Error initializing AI service: $e');
    }
  }

  /// Populate form fields when editing an existing event
  void _populateFields(CalendarEvent event) {
    titleController.text = event.title;
    descriptionController.text = event.description;
    locationController.text = event.location ?? '';
    tagsController.text = event.tags.join(', ');
    selectedDate = event.date;
    startTime = event.startTime;
    endTime = event.endTime;
    isAllDay = event.isAllDay;
    selectedColor = event.color;
    isCompleted = event.isCompleted;
    priority = event.priority;
  }

  /// Start voice input for event creation
  Future<void> startVoiceInput() async {
    if (!isAIServiceInitialized) {
      _showSnackBar('AI service not initialized. Please try again.');
      return;
    }

    // Request microphone permission
    final hasPermission = await _aiService.requestMicrophonePermission();
    if (!hasPermission) {
      _showSnackBar('Microphone permission is required for voice input.');
      return;
    }

    isListening = true;
    voiceText = '';
    notifyListeners();

    await _aiService.startListening(
      onResult: (text) {
        voiceText = text;
        notifyListeners();
      },
      onError: (error) {
        isListening = false;
        notifyListeners();
        _showSnackBar('Voice input error: $error');
      },
    );
  }

  /// Stop voice input and process the recognized text
  Future<void> stopVoiceInput() async {
    await _aiService.stopListening();
    isListening = false;
    notifyListeners();

    if (voiceText.isNotEmpty) {
      _processVoiceInput(voiceText);
    }
  }

  /// Process voice input and populate form fields
  void _processVoiceInput(String voiceText) {
    final parsedData = _aiService.parseVoiceInput(voiceText);

    titleController.text = parsedData['title'] ?? '';
    descriptionController.text = parsedData['description'] ?? '';
    locationController.text = parsedData['location'] ?? '';
    priority = parsedData['priority'] ?? 'Medium';

    if (parsedData['date'] != null) {
      selectedDate = parsedData['date'];
    }

    if (parsedData['time'] != null) {
      final timeStr = parsedData['time'];
      final timeParts = timeStr.split(':');
      if (timeParts.length == 2) {
        startTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      }
    }

    if (parsedData['tags'] != null && parsedData['tags'].isNotEmpty) {
      tagsController.text = parsedData['tags'].join(', ');
    }

    notifyListeners();
    _showSnackBar('Voice input processed successfully!');
  }

  /// Generate smart scheduling suggestions
  Future<void> generateSmartSuggestions() async {
    if (titleController.text.trim().isEmpty) {
      _showSnackBar('Please enter an event title first.');
      return;
    }

    try {
      final existingEvents = await _calendarService.getEvents();
      final suggestions = _aiService.generateSmartSuggestions(
        existingEvents: existingEvents,
        eventTitle: titleController.text.trim(),
        priority: priority,
        preferredDate: selectedDate,
      );

      smartSuggestions = suggestions;
      showSmartSuggestions = true;
      notifyListeners();
    } catch (e) {
      _showSnackBar('Error generating smart suggestions: $e');
    }
  }

  /// Apply smart scheduling suggestion
  void applySuggestion(SmartSchedulingSuggestion suggestion) {
    selectedDate = suggestion.suggestedDateTime;
    startTime = TimeOfDay.fromDateTime(suggestion.suggestedDateTime);
    showSmartSuggestions = false;
    notifyListeners();
    _showSnackBar('Smart suggestion applied!');
  }

  /// Dismiss smart suggestions
  void dismissSmartSuggestions() {
    showSmartSuggestions = false;
    notifyListeners();
  }

  /// Update selected date
  void updateSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  /// Update selected time
  void updateSelectedTime(TimeOfDay? time, bool isStartTime) {
    if (isStartTime) {
      startTime = time;
    } else {
      endTime = time;
    }
    notifyListeners();
  }

  /// Update all day toggle
  void updateAllDay(bool value) {
    isAllDay = value;
    if (value) {
      startTime = null;
      endTime = null;
    }
    notifyListeners();
  }

  /// Update selected color
  void updateSelectedColor(Color color) {
    selectedColor = color;
    notifyListeners();
  }

  /// Update priority
  void updatePriority(String newPriority) {
    priority = newPriority;
    notifyListeners();
  }

  /// Update completion status
  void updateCompletionStatus(bool value) {
    isCompleted = value;
    notifyListeners();
  }

  /// Save event
  Future<bool> saveEvent() async {
    if (titleController.text.trim().isEmpty) {
      return false;
    }

    try {
      final event = CalendarEvent(
        id: eventToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        date: selectedDate,
        startTime: isAllDay ? null : startTime,
        endTime: isAllDay ? null : endTime,
        color: selectedColor,
        isAllDay: isAllDay,
        location: locationController.text.trim().isEmpty
            ? null
            : locationController.text.trim(),
        tags: tagsController.text.trim().isEmpty
            ? []
            : tagsController.text
                  .trim()
                  .split(',')
                  .map((e) => e.trim())
                  .toList(),
        isCompleted: isCompleted,
        priority: priority,
      );

      if (eventToEdit != null) {
        await _calendarService.updateEvent(event);
      } else {
        await _calendarService.createEvent(event);
      }

      return true;
    } catch (e) {
      _showSnackBar('Error saving event: $e');
      return false;
    }
  }

  /// Show snackbar message (placeholder - should be handled by UI)
  void _showSnackBar(String message) {
    print('SnackBar: $message');
  }
}
