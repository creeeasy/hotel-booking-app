import 'package:fatiel/l10n/l10n.dart';
import 'package:flutter/material.dart';

String formatTimeDifference(BuildContext context, DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inMinutes < 1) return L10n.of(context).justNow;
  if (difference.inHours < 1) {
    return L10n.of(context).minutesAgo(difference.inMinutes);
  }
  if (difference.inDays < 1) {
    return L10n.of(context).hoursAgo(difference.inHours);
  }
  return L10n.of(context).daysAgo(difference.inDays);
}
