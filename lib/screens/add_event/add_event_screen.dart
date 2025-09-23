import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/calendar_event.dart';
import 'widgets/voice_input_section.dart';
import 'widgets/priority_selection_widget.dart';
import 'widgets/color_selection_widget.dart';
import 'controllers/add_event_controller.dart';

/// Add Event Screen - Modularized Version
/// Main screen for creating and editing calendar events
class AddEventScreen extends StatefulWidget {
  final CalendarEvent? eventToEdit;
  final DateTime? initialDate;

  const AddEventScreen({super.key, this.eventToEdit, this.initialDate});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  late AddEventController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = AddEventController(eventToEdit: widget.eventToEdit);
    if (widget.initialDate != null) {
      _controller.updateSelectedDate(widget.initialDate!);
    }
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    setState(() {});
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _controller.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _controller.selectedDate) {
      _controller.updateSelectedDate(picked);
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_controller.startTime ?? TimeOfDay.now())
          : (_controller.endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      _controller.updateSelectedTime(picked, isStartTime);
    }
  }

  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      final success = await _controller.saveEvent();
      if (success && mounted) {
        Navigator.pop(context, true);
      }
    }
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
                fontSize: 18,
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
                    controller: _controller.titleController,
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
                  VoiceInputSection(
                    isListening: _controller.isListening,
                    voiceText: _controller.voiceText,
                    onStartVoiceInput: _controller.startVoiceInput,
                    onStopVoiceInput: _controller.stopVoiceInput,
                    onGenerateSmartSuggestions:
                        _controller.generateSmartSuggestions,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _controller.descriptionController,
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
                              ).format(_controller.selectedDate),
                            ),
                            trailing: Icon(Icons.chevron_right_rounded),
                            onTap: _selectDate,
                          ),
                          // All Day Toggle
                          SwitchListTile(
                            title: Text('All Day'),
                            subtitle: Text(
                              _controller.isAllDay
                                  ? 'Event lasts all day'
                                  : 'Set specific times',
                            ),
                            value: _controller.isAllDay,
                            onChanged: _controller.updateAllDay,
                          ),
                          // Start Time
                          if (!_controller.isAllDay) ...[
                            ListTile(
                              leading: Icon(Icons.access_time_rounded),
                              title: Text('Start Time'),
                              subtitle: Text(
                                _controller.startTime?.format(context) ??
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
                                _controller.endTime?.format(context) ??
                                    'Select end time',
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
                    controller: _controller.locationController,
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
                    controller: _controller.tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags (Optional)',
                      hintText: 'Enter tags separated by commas',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Priority Selection
                  PrioritySelectionWidget(
                    selectedPriority: _controller.priority,
                    onPriorityChanged: _controller.updatePriority,
                  ),
                  const SizedBox(height: 16),

                  // Color Selection
                  ColorSelectionWidget(
                    selectedColor: _controller.selectedColor,
                    onColorChanged: _controller.updateSelectedColor,
                  ),
                  const SizedBox(height: 16),

                  // Completed Toggle (only for editing)
                  if (isEditing) ...[
                    Card(
                      child: SwitchListTile(
                        title: Text('Mark as Completed'),
                        subtitle: Text(
                          _controller.isCompleted
                              ? 'Event is completed'
                              : 'Event is pending',
                        ),
                        value: _controller.isCompleted,
                        onChanged: _controller.updateCompletionStatus,
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
