import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calendar_event.dart';
import '../service/calendar_service.dart';
import '../service/ai_service.dart';

class AddEventScreen extends StatefulWidget {
  final CalendarEvent? eventToEdit;
  final DateTime? initialDate;

  const AddEventScreen({super.key, this.eventToEdit, this.initialDate});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isAllDay = false;
  Color _selectedColor = Colors.blue;
  bool _isCompleted = false;
  String _priority = 'Medium'; // Default priority

  final CalendarService _calendarService = CalendarService();
  final AIService _aiService = AIService();

  // Voice input state
  bool _isListening = false;
  String _voiceText = '';
  bool _isAIServiceInitialized = false;

  // Smart scheduling state
  List<SmartSchedulingSuggestion> _smartSuggestions = [];
  bool _showSmartSuggestions = false;

  @override
  void initState() {
    super.initState();
    if (widget.eventToEdit != null) {
      _populateFields(widget.eventToEdit!);
    } else if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
    _initializeAIService();
  }

  void _populateFields(CalendarEvent event) {
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _locationController.text = event.location ?? '';
    _tagsController.text = event.tags.join(', ');
    _selectedDate = event.date;
    _startTime = event.startTime;
    _endTime = event.endTime;
    _isAllDay = event.isAllDay;
    _selectedColor = event.color;
    _isCompleted = event.isCompleted;
    _priority = event.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    if (_isListening) {
      _aiService.stopListening();
    }
    super.dispose();
  }

  /// Initialize AI service for voice input and smart scheduling
  Future<void> _initializeAIService() async {
    try {
      _isAIServiceInitialized = await _aiService.initialize();
      if (!_isAIServiceInitialized) {
        print('AI service initialization failed');
      }
    } catch (e) {
      print('Error initializing AI service: $e');
    }
  }

  /// Start voice input for event creation
  Future<void> _startVoiceInput() async {
    if (!_isAIServiceInitialized) {
      _showSnackBar('AI service not initialized. Please try again.');
      return;
    }

    // Request microphone permission
    final hasPermission = await _aiService.requestMicrophonePermission();
    if (!hasPermission) {
      _showSnackBar('Microphone permission is required for voice input.');
      return;
    }

    setState(() {
      _isListening = true;
      _voiceText = '';
    });

    await _aiService.startListening(
      onResult: (text) {
        setState(() {
          _voiceText = text;
        });
      },
      onError: (error) {
        setState(() {
          _isListening = false;
        });
        _showSnackBar('Voice input error: $error');
      },
    );
  }

  /// Stop voice input and process the recognized text
  Future<void> _stopVoiceInput() async {
    await _aiService.stopListening();
    setState(() {
      _isListening = false;
    });

    if (_voiceText.isNotEmpty) {
      _processVoiceInput(_voiceText);
    }
  }

  /// Process voice input and populate form fields
  void _processVoiceInput(String voiceText) {
    final parsedData = _aiService.parseVoiceInput(voiceText);

    setState(() {
      _titleController.text = parsedData['title'] ?? '';
      _descriptionController.text = parsedData['description'] ?? '';
      _locationController.text = parsedData['location'] ?? '';
      _priority = parsedData['priority'] ?? 'Medium';

      if (parsedData['date'] != null) {
        _selectedDate = parsedData['date'];
      }

      if (parsedData['time'] != null) {
        final timeStr = parsedData['time'];
        final timeParts = timeStr.split(':');
        if (timeParts.length == 2) {
          _startTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        }
      }

      if (parsedData['tags'] != null && parsedData['tags'].isNotEmpty) {
        _tagsController.text = parsedData['tags'].join(', ');
      }
    });

    _showSnackBar('Voice input processed successfully!');
  }

  /// Generate smart scheduling suggestions
  Future<void> _generateSmartSuggestions() async {
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Please enter an event title first.');
      return;
    }

    try {
      final existingEvents = await _calendarService.getEvents();
      final suggestions = _aiService.generateSmartSuggestions(
        existingEvents: existingEvents,
        eventTitle: _titleController.text.trim(),
        priority: _priority,
        preferredDate: _selectedDate,
      );

      setState(() {
        _smartSuggestions = suggestions;
        _showSmartSuggestions = true;
      });
    } catch (e) {
      _showSnackBar('Error generating smart suggestions: $e');
    }
  }

  /// Apply smart scheduling suggestion
  void _applySuggestion(SmartSchedulingSuggestion suggestion) {
    setState(() {
      _selectedDate = suggestion.suggestedDateTime;
      _startTime = TimeOfDay.fromDateTime(suggestion.suggestedDateTime);
      _showSmartSuggestions = false;
    });
    _showSnackBar('Smart suggestion applied!');
  }

  /// Show snackbar message
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    }
  }

  /// Show alternative times dialog
  void _showAlternativeTimes(SmartSchedulingSuggestion suggestion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Alternative Times'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: suggestion.alternativeTimes.map((time) {
            return ListTile(
              leading: Icon(Icons.schedule_rounded),
              title: Text(DateFormat('EEEE, MMMM d, y • h:mm a').format(time)),
              onTap: () {
                Navigator.pop(context);
                _applySuggestion(
                  SmartSchedulingSuggestion(
                    suggestedDateTime: time,
                    confidence:
                        suggestion.confidence *
                        0.8, // Slightly lower confidence
                    reason: 'Alternative time slot',
                    alternativeTimes: [],
                  ),
                );
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        final event = CalendarEvent(
          id:
              widget.eventToEdit?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          date: _selectedDate,
          startTime: _isAllDay ? null : _startTime,
          endTime: _isAllDay ? null : _endTime,
          color: _selectedColor,
          isAllDay: _isAllDay,
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          tags: _tagsController.text.trim().isEmpty
              ? []
              : _tagsController.text
                    .trim()
                    .split(',')
                    .map((e) => e.trim())
                    .toList(),
          isCompleted: _isCompleted,
          priority: _priority,
        );

        if (widget.eventToEdit != null) {
          await _calendarService.updateEvent(event);
        } else {
          await _calendarService.createEvent(event);
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving event: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  /// Builds a priority selection button with circular design
  Widget _buildPriorityButton(String priority, Color color, IconData icon) {
    final isSelected = _priority == priority;
    return GestureDetector(
      onTap: () {
        setState(() {
          _priority = priority;
        });
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.3),
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: color, width: 4) : null,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 40,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            priority,
            style: TextStyle(
              color: isSelected ? color : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.eventToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'Add Event'),
        actions: [
          TextButton(
            onPressed: _saveEvent,
            child: Text(
              'Save',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.3),
              colorScheme.secondaryContainer.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Event Title',
                      hintText: 'Enter event title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Voice Input Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.mic_rounded,
                                color: _isListening
                                    ? Colors.red
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Voice Input',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              if (_isListening)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Listening...',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isListening
                                      ? _stopVoiceInput
                                      : _startVoiceInput,
                                  icon: Icon(
                                    _isListening
                                        ? Icons.stop_rounded
                                        : Icons.mic_rounded,
                                    size: 20,
                                  ),
                                  label: Text(
                                    _isListening
                                        ? 'Stop Recording'
                                        : 'Start Voice Input',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isListening
                                        ? Colors.red
                                        : Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _generateSmartSuggestions,
                                  icon: Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 20,
                                  ),
                                  label: Text('Smart Schedule'),
                                ),
                              ),
                            ],
                          ),
                          if (_voiceText.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Recognized Text:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _voiceText,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Enter event description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Date and Time Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date & Time',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          // Date
                          ListTile(
                            leading: Icon(Icons.calendar_today_rounded),
                            title: Text('Date'),
                            subtitle: Text(
                              DateFormat(
                                'EEEE, MMMM d, y',
                              ).format(_selectedDate),
                            ),
                            trailing: Icon(Icons.chevron_right_rounded),
                            onTap: _selectDate,
                          ),
                          // All Day Toggle
                          SwitchListTile(
                            title: Text('All Day'),
                            subtitle: Text(
                              _isAllDay
                                  ? 'Event lasts all day'
                                  : 'Set specific times',
                            ),
                            value: _isAllDay,
                            onChanged: (value) {
                              setState(() {
                                _isAllDay = value;
                                if (value) {
                                  _startTime = null;
                                  _endTime = null;
                                }
                              });
                            },
                          ),
                          // Start Time
                          if (!_isAllDay) ...[
                            ListTile(
                              leading: Icon(Icons.access_time_rounded),
                              title: Text('Start Time'),
                              subtitle: Text(
                                _startTime?.format(context) ??
                                    'Select start time',
                              ),
                              trailing: Icon(Icons.chevron_right_rounded),
                              onTap: () => _selectTime(true),
                            ),
                            // End Time
                            ListTile(
                              leading: Icon(Icons.access_time_rounded),
                              title: Text('End Time'),
                              subtitle: Text(
                                _endTime?.format(context) ?? 'Select end time',
                              ),
                              trailing: Icon(Icons.chevron_right_rounded),
                              onTap: () => _selectTime(false),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location (Optional)',
                      hintText: 'Enter event location',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tags
                  TextFormField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags (Optional)',
                      hintText: 'Enter tags separated by commas',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Priority Selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PRIORITY',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildPriorityButton(
                                'Low',
                                Colors.green,
                                Icons.sentiment_satisfied_rounded,
                              ),
                              _buildPriorityButton(
                                'Medium',
                                Colors.orange,
                                Icons.sentiment_neutral_rounded,
                              ),
                              _buildPriorityButton(
                                'High',
                                Colors.red,
                                Icons.sentiment_dissatisfied_rounded,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Smart Scheduling Suggestions
                  if (_showSmartSuggestions &&
                      _smartSuggestions.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Smart Scheduling Suggestions',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _showSmartSuggestions = false;
                                    });
                                  },
                                  icon: Icon(Icons.close_rounded),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ..._smartSuggestions.map((suggestion) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.schedule_rounded,
                                          size: 16,
                                          color: Colors.blue[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat(
                                            'EEEE, MMMM d, y • h:mm a',
                                          ).format(
                                            suggestion.suggestedDateTime,
                                          ),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            '${(suggestion.confidence * 100).toInt()}%',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      suggestion.reason,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () =>
                                                _applySuggestion(suggestion),
                                            icon: Icon(
                                              Icons.check_rounded,
                                              size: 16,
                                            ),
                                            label: Text('Apply'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.blue,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (suggestion
                                            .alternativeTimes
                                            .isNotEmpty)
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () {
                                                // Show alternative times
                                                _showAlternativeTimes(
                                                  suggestion,
                                                );
                                              },
                                              icon: Icon(
                                                Icons.more_time_rounded,
                                                size: 16,
                                              ),
                                              label: Text('Alternatives'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor:
                                                    Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Color Selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Color',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            children:
                                [
                                  Colors.blue,
                                  Colors.red,
                                  Colors.green,
                                  Colors.orange,
                                  Colors.purple,
                                  Colors.teal,
                                  Colors.pink,
                                  Colors.indigo,
                                ].map((color) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedColor = color;
                                      });
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: _selectedColor == color
                                            ? Border.all(
                                                color: colorScheme.onSurface,
                                                width: 3,
                                              )
                                            : null,
                                      ),
                                      child: _selectedColor == color
                                          ? Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Completed Toggle (only for editing)
                  if (isEditing) ...[
                    Card(
                      child: SwitchListTile(
                        title: Text('Mark as Completed'),
                        subtitle: Text(
                          _isCompleted
                              ? 'Event is completed'
                              : 'Event is pending',
                        ),
                        value: _isCompleted,
                        onChanged: (value) {
                          setState(() {
                            _isCompleted = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
