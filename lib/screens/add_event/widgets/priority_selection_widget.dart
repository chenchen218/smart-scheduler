import 'package:flutter/material.dart';

/// Priority Selection Widget for Add Event Screen
/// Allows users to select event priority (Low, Medium, High)
class PrioritySelectionWidget extends StatelessWidget {
  final String selectedPriority;
  final ValueChanged<String> onPriorityChanged;

  const PrioritySelectionWidget({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PRIORITY',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
    );
  }

  /// Builds a priority selection button with circular design
  Widget _buildPriorityButton(String priority, Color color, IconData icon) {
    final isSelected = selectedPriority == priority;
    return GestureDetector(
      onTap: () => onPriorityChanged(priority),
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
}
