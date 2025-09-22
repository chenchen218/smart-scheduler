import 'package:flutter/material.dart';

/// Voice Input Section Widget for Add Event Screen
/// Handles voice recognition and smart scheduling functionality
class VoiceInputSection extends StatelessWidget {
  final bool isListening;
  final String voiceText;
  final VoidCallback onStartVoiceInput;
  final VoidCallback onStopVoiceInput;
  final VoidCallback onGenerateSmartSuggestions;

  const VoiceInputSection({
    super.key,
    required this.isListening,
    required this.voiceText,
    required this.onStartVoiceInput,
    required this.onStopVoiceInput,
    required this.onGenerateSmartSuggestions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.mic_rounded,
                  color: isListening ? Colors.red : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Voice Input',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (isListening)
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
                    onPressed: isListening
                        ? onStopVoiceInput
                        : onStartVoiceInput,
                    icon: Icon(
                      isListening ? Icons.stop_rounded : Icons.mic_rounded,
                      size: 20,
                    ),
                    label: Text(
                      isListening ? 'Stop Recording' : 'Start Voice Input',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isListening ? Colors.red : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onGenerateSmartSuggestions,
                    icon: Icon(Icons.auto_awesome_rounded, size: 20),
                    label: Text('Smart Schedule'),
                  ),
                ),
              ],
            ),
            if (voiceText.isNotEmpty) ...[
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
                    Text(voiceText, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
