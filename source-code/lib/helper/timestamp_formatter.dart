String formatTimeDifference(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inHours < 1) return '${difference.inMinutes} minutes ago';
  if (difference.inDays < 1) return '${difference.inHours} hours ago';
  return '${difference.inDays} days ago';
}
