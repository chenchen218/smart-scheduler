import 'package:flutter/material.dart';

/// Color Selection Widget for Add Event Screen
/// Allows users to select event color from predefined options
class ColorSelectionWidget extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  const ColorSelectionWidget({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Color',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
                      onTap: () => onColorChanged(color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: selectedColor == color
                              ? Border.all(
                                  color: colorScheme.onSurface,
                                  width: 3,
                                )
                              : null,
                        ),
                        child: selectedColor == color
                            ? Icon(Icons.check_rounded, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
