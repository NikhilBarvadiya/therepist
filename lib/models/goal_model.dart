import 'package:flutter/material.dart';

class GoalModel {
  final String id;
  final String patientId;
  final String patientName;
  final String patientImage;
  final String title;
  final String description;
  final String therapyType; // CBT, DBT, EMDR, etc.
  final String category; // anxiety, depression, trauma, etc.
  final double currentValue;
  final double targetValue;
  final String unit; // sessions, score, rating, etc.
  final Color color;
  final IconData icon;
  final DateTime startDate;
  final DateTime endDate;
  final String frequency; // daily, weekly, biweekly
  final List<GoalMilestone> milestones;
  final List<SessionRecord> sessions;
  final String status; // active, upcoming, completed, critical
  final String priority; // low, medium, high, critical
  final String notes;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<DateTime> completedDates;
  final bool isActive;
  final bool isCompleted;
  final bool isExpired;

  GoalModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientImage,
    required this.title,
    required this.description,
    required this.therapyType,
    required this.category,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.color,
    required this.icon,
    required this.startDate,
    required this.endDate,
    required this.frequency,
    required this.milestones,
    required this.sessions,
    required this.status,
    required this.priority,
    required this.notes,
    required this.createdAt,
    this.completedAt,
    required this.completedDates,
    required this.isActive,
    required this.isCompleted,
    required this.isExpired,
  });

  double get progress => currentValue / targetValue;

  String get progressPercentage => (progress * 100).toStringAsFixed(0);

  int get remainingDays => endDate.difference(DateTime.now()).inDays;

  int get totalDays => endDate.difference(startDate).inDays;

  int get elapsedDays => DateTime.now().difference(startDate).inDays;

  bool get isOnTrack => progress >= (elapsedDays / totalDays);

  bool get isBehind => progress < (elapsedDays / totalDays) * 0.7;

  int get streak {
    if (completedDates.isEmpty) return 0;
    completedDates.sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime currentDate = DateTime.now();
    while (completedDates.contains(DateTime(currentDate.year, currentDate.month, currentDate.day))) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

class GoalMilestone {
  final String id;
  final String title;
  final String description;
  final double targetValue;
  final bool isCompleted;
  final DateTime? completedAt;
  final String notes;

  GoalMilestone({required this.id, required this.title, required this.description, required this.targetValue, required this.isCompleted, this.completedAt, required this.notes});
}

class SessionRecord {
  final String id;
  final DateTime date;
  final double progressValue;
  final String notes;
  final String therapistNotes;
  final List<String> attachments; // audio, notes, etc.

  SessionRecord({required this.id, required this.date, required this.progressValue, required this.notes, required this.therapistNotes, required this.attachments});
}
