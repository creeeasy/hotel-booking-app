import 'package:fatiel/enum/activity_type.dart';
import 'package:flutter/material.dart';

class ActivityItem {
  final ActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;

  ActivityItem({
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
  });
}
