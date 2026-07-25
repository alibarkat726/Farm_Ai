import 'package:flutter/material.dart';

import '../theme.dart';

class UrgencyBadge extends StatelessWidget {
  const UrgencyBadge({super.key, required this.urgency, this.large = false});

  final String urgency;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final color = urgencyColor(urgency);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 8 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Text(
        urgency.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: large ? 14 : 12,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class ConfidenceBadge extends StatelessWidget {
  const ConfidenceBadge({super.key, required this.confidence});

  final String confidence;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (confidence.toLowerCase()) {
      case 'high':
        color = OrchardColors.urgencyLow;
      case 'moderate':
        color = OrchardColors.urgencyModerate;
      default:
        color = OrchardColors.muted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${confidence[0].toUpperCase()}${confidence.substring(1)} confidence',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.icon});

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: OrchardColors.leafGreen, size: 22),
          const SizedBox(width: 8),
        ],
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
