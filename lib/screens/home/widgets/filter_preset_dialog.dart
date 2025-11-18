import 'package:flutter/material.dart';
import '../../../models/filter_options.dart';
import '../../../services/filter_preset_service.dart';

/// Dialog for managing filter presets
class FilterPresetDialog extends StatefulWidget {
  final FilterOptions currentFilters;
  final SortOptions? currentSort;
  final Function(FilterOptions, SortOptions?) onPresetSelected;

  const FilterPresetDialog({
    super.key,
    required this.currentFilters,
    this.currentSort,
    required this.onPresetSelected,
  });

  @override
  State<FilterPresetDialog> createState() => _FilterPresetDialogState();
}

class _FilterPresetDialogState extends State<FilterPresetDialog> {
  final FilterPresetService _presetService = FilterPresetService();
  final TextEditingController _nameController = TextEditingController();
  List<FilterPreset> _presets = [];

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadPresets() async {
    final presets = await _presetService.getPresets();
    setState(() {
      _presets = presets;
    });
  }

  Future<void> _savePreset() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for the preset')),
      );
      return;
    }

    final preset = FilterPreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      filters: widget.currentFilters,
      sort: widget.currentSort,
    );

    await _presetService.savePreset(preset);
    _nameController.clear();
    await _loadPresets();

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preset saved')));
    }
  }

  Future<void> _deletePreset(FilterPreset preset) async {
    await _presetService.deletePreset(preset.id);
    await _loadPresets();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preset deleted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter Presets', style: theme.textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Save current filters as preset
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Preset Name',
                hintText: 'Enter preset name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              icon: const Icon(Icons.save, size: 18),
              label: const Text('Save Current Filters'),
              onPressed: _savePreset,
            ),
            const SizedBox(height: 24),
            // List of saved presets
            Text('Saved Presets', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Expanded(
              child: _presets.isEmpty
                  ? Center(
                      child: Text(
                        'No presets saved',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _presets.length,
                      itemBuilder: (context, index) {
                        final preset = _presets[index];
                        return ListTile(
                          title: Text(preset.name),
                          subtitle: Text(
                            preset.filters.hasActiveFilters
                                ? 'Filters active'
                                : 'No filters',
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _deletePreset(preset),
                                tooltip: 'Delete',
                              ),
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () {
                                  widget.onPresetSelected(
                                    preset.filters,
                                    preset.sort,
                                  );
                                  Navigator.of(context).pop();
                                },
                                tooltip: 'Apply',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
