import 'package:flutter/material.dart';
import '../../../models/recurrence_pattern.dart';

/// Widget for selecting recurrence pattern for events
class RecurrenceSelectionWidget extends StatefulWidget {
  final RecurrencePattern? initialPattern;
  final Function(RecurrencePattern?) onChanged;

  const RecurrenceSelectionWidget({
    super.key,
    this.initialPattern,
    required this.onChanged,
  });

  @override
  State<RecurrenceSelectionWidget> createState() =>
      _RecurrenceSelectionWidgetState();
}

class _RecurrenceSelectionWidgetState extends State<RecurrenceSelectionWidget> {
  RecurrencePattern? _selectedPattern;
  RecurrenceType _selectedType = RecurrenceType.none;
  int _interval = 1;
  DateTime? _endDate;
  int? _occurrenceCount;

  @override
  void initState() {
    super.initState();
    if (widget.initialPattern != null) {
      _selectedPattern = widget.initialPattern;
      _selectedType = widget.initialPattern!.type;
      _interval = widget.initialPattern!.interval;
      _endDate = widget.initialPattern!.endDate;
      _occurrenceCount = widget.initialPattern!.occurrenceCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Repeat'),
      subtitle: Text(
        _selectedPattern?.toDisplayString() ?? 'No repeat',
        style: TextStyle(
          color: _selectedType == RecurrenceType.none
              ? Colors.grey
              : Theme.of(context).colorScheme.primary,
        ),
      ),
      leading: Icon(
        Icons.repeat,
        color: _selectedType == RecurrenceType.none
            ? Colors.grey
            : Theme.of(context).colorScheme.primary,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recurrence type selection
              _buildRecurrenceTypeSelector(),
              const SizedBox(height: 16),

              // Interval selector (if not "none")
              if (_selectedType != RecurrenceType.none) ...[
                _buildIntervalSelector(),
                const SizedBox(height: 16),
              ],

              // End date/occurrence count selector
              if (_selectedType != RecurrenceType.none) ...[
                _buildEndOptions(),
                const SizedBox(height: 16),
              ],

              // Apply button
              if (_selectedType != RecurrenceType.none)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyPattern,
                    child: const Text('Apply'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecurrenceTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Repeat', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: RecurrenceType.values.map((type) {
            if (type == RecurrenceType.custom) return const SizedBox.shrink();
            return ChoiceChip(
              label: Text(_getTypeLabel(type)),
              selected: _selectedType == type,
              onSelected: (selected) {
                setState(() {
                  _selectedType = selected ? type : RecurrenceType.none;
                  if (_selectedType == RecurrenceType.none) {
                    _selectedPattern = null;
                    widget.onChanged(null);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIntervalSelector() {
    if (_selectedType == RecurrenceType.none) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        const Text('Every '),
        SizedBox(
          width: 80,
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            controller: TextEditingController(text: _interval.toString())
              ..selection = TextSelection.collapsed(
                offset: _interval.toString().length,
              ),
            onChanged: (value) {
              setState(() {
                _interval = int.tryParse(value) ?? 1;
                if (_interval < 1) _interval = 1;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(_getIntervalUnit()),
      ],
    );
  }

  Widget _buildEndOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ends', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        RadioListTile<EndOption>(
          title: const Text('Never'),
          value: EndOption.never,
          groupValue: _getCurrentEndOption(),
          onChanged: (value) {
            setState(() {
              _endDate = null;
              _occurrenceCount = null;
            });
          },
        ),
        RadioListTile<EndOption>(
          title: const Text('On date'),
          value: EndOption.onDate,
          groupValue: _getCurrentEndOption(),
          onChanged: (value) {
            setState(() {
              _endDate = DateTime.now().add(const Duration(days: 30));
              _occurrenceCount = null;
            });
          },
        ),
        if (_getCurrentEndOption() == EndOption.onDate)
          Padding(
            padding: const EdgeInsets.only(left: 48.0),
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate:
                      _endDate ?? DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                );
                if (date != null) {
                  setState(() {
                    _endDate = date;
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _endDate != null
                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                      : 'Select date',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        RadioListTile<EndOption>(
          title: const Text('After'),
          value: EndOption.after,
          groupValue: _getCurrentEndOption(),
          onChanged: (value) {
            setState(() {
              _occurrenceCount = 10;
              _endDate = null;
            });
          },
        ),
        if (_getCurrentEndOption() == EndOption.after)
          Padding(
            padding: const EdgeInsets.only(left: 48.0),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    controller:
                        TextEditingController(
                            text: _occurrenceCount?.toString() ?? '10',
                          )
                          ..selection = TextSelection.collapsed(
                            offset:
                                (_occurrenceCount?.toString() ?? '10').length,
                          ),
                    onChanged: (value) {
                      setState(() {
                        _occurrenceCount = int.tryParse(value);
                        if (_occurrenceCount != null && _occurrenceCount! < 1) {
                          _occurrenceCount = 1;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Text('occurrences'),
              ],
            ),
          ),
      ],
    );
  }

  EndOption _getCurrentEndOption() {
    if (_endDate != null) return EndOption.onDate;
    if (_occurrenceCount != null) return EndOption.after;
    return EndOption.never;
  }

  String _getTypeLabel(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return 'None';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.yearly:
        return 'Yearly';
      case RecurrenceType.custom:
        return 'Custom';
    }
  }

  String _getIntervalUnit() {
    switch (_selectedType) {
      case RecurrenceType.daily:
        return _interval == 1 ? 'day' : 'days';
      case RecurrenceType.weekly:
        return _interval == 1 ? 'week' : 'weeks';
      case RecurrenceType.monthly:
        return _interval == 1 ? 'month' : 'months';
      case RecurrenceType.yearly:
        return _interval == 1 ? 'year' : 'years';
      default:
        return '';
    }
  }

  void _applyPattern() {
    RecurrencePattern? pattern;

    switch (_selectedType) {
      case RecurrenceType.none:
        pattern = null;
        break;
      case RecurrenceType.daily:
        pattern = RecurrencePattern.daily(
          interval: _interval,
          occurrenceCount: _occurrenceCount,
          endDate: _endDate,
        );
        break;
      case RecurrenceType.weekly:
        pattern = RecurrencePattern.weekly(
          interval: _interval,
          occurrenceCount: _occurrenceCount,
          endDate: _endDate,
        );
        break;
      case RecurrenceType.monthly:
        pattern = RecurrencePattern.monthly(
          interval: _interval,
          occurrenceCount: _occurrenceCount,
          endDate: _endDate,
        );
        break;
      case RecurrenceType.yearly:
        pattern = RecurrencePattern.yearly(
          interval: _interval,
          occurrenceCount: _occurrenceCount,
          endDate: _endDate,
        );
        break;
      case RecurrenceType.custom:
        // Custom not implemented yet
        break;
    }

    setState(() {
      _selectedPattern = pattern;
    });
    widget.onChanged(pattern);
  }
}

enum EndOption { never, onDate, after }
