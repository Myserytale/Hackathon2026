import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HashChip extends StatelessWidget {
  final String hash;

  const HashChip({super.key, required this.hash});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock, size: 16, color: AppTheme.ledgerGreen),
          const SizedBox(width: 8),
          Text(
            "Hash: ${hash.substring(0, 12)}...",
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}
