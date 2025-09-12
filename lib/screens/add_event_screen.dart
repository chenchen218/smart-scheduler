import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calendar_event.dart';
import '../service/calendar_service.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.eventToEdit != null) {
      _populateFields(widget.eventToEdit!);
    } else if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
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
    super.dispose();
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
