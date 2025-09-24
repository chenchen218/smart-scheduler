import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../service/ai_service.dart';

/// Smart Suggestions Widget
/// Displays AI-generated scheduling suggestions for events
class SmartSuggestionsWidget extends StatelessWidget {
  final List<SmartSchedulingSuggestion> suggestions;
  final Function(SmartSchedulingSuggestion) onApplySuggestion;
  final VoidCallback onDismiss;

  const SmartSuggestionsWidget({
    super.key,
    required this.suggestions,
    required this.onApplySuggestion,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Smart Scheduling Suggestions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onDismiss,
                  icon: Icon(
                    Icons.close_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  tooltip: 'Dismiss suggestions',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'AI has analyzed your schedule and suggests these optimal times:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ...suggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final suggestion = entry.value;
              return _buildSuggestionCard(
                context,
                suggestion,
                index + 1,
                onApplySuggestion,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    SmartSchedulingSuggestion suggestion,
    int rank,
    Function(SmartSchedulingSuggestion) onApply,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('EEEE, MMMM d');
    final confidence = (suggestion.confidence * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getRankColor(rank, colorScheme),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          timeFormat.format(suggestion.suggestedDateTime),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFormat.format(suggestion.suggestedDateTime),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              suggestion.reason,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  size: 16,
                  color: _getConfidenceColor(confidence, colorScheme),
                ),
                const SizedBox(width: 4),
                Text(
                  '$confidence% confidence',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getConfidenceColor(confidence, colorScheme),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => onApply(suggestion),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Apply'),
        ),
      ),
    );
  }

  Color _getRankColor(int rank, ColorScheme colorScheme) {
    switch (rank) {
      case 1:
        return Colors.amber[600]!;
      case 2:
        return Colors.grey[600]!;
      case 3:
        return Colors.brown[600]!;
      default:
        return colorScheme.primary;
    }
  }

  Color _getConfidenceColor(int confidence, ColorScheme colorScheme) {
    if (confidence >= 80) {
      return Colors.green[600]!;
    } else if (confidence >= 60) {
      return Colors.orange[600]!;
    } else {
      return Colors.red[600]!;
    }
  }
}
