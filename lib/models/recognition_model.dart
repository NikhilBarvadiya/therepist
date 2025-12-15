import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Recognition {
  final String id;
  final List<String> images;
  final String title;
  final String description;
  final String doctorId;
  final String doctorName;
  final String doctorClinicName;
  final String? doctorProfileImage;
  final bool showOnFeed;
  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;
  final bool isActive;
  final DateTime createdAt;

  Recognition({
    required this.id,
    required this.images,
    required this.title,
    required this.description,
    required this.doctorId,
    required this.doctorName,
    required this.doctorClinicName,
    this.doctorProfileImage,
    required this.showOnFeed,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.isActive,
    required this.createdAt,
  });

  factory Recognition.fromJson(Map<String, dynamic> json) {
    List<String> imagesList = [];
    if (json['image'] is List) {
      imagesList = (json['image'] as List).map((img) => img.toString()).toList();
    } else if (json['image'] is String) {
      imagesList = [json['image']];
    }
    String doctorName = '';
    String doctorClinicName = '';
    String? doctorProfileImage;
    if (json['doctorId'] is Map) {
      final doctorData = json['doctorId'] as Map<String, dynamic>;
      doctorName = doctorData['name']?.toString() ?? '';
      doctorClinicName = doctorData['clinicName']?.toString() ?? '';
      doctorProfileImage = doctorData['profileImage']?.toString();
    }
    return Recognition(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      images: imagesList,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      doctorId: json['doctorId']?.toString() ?? '',
      doctorName: doctorName,
      doctorClinicName: doctorClinicName,
      doctorProfileImage: doctorProfileImage,
      showOnFeed: json['showOnFeed'] ?? false,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'].toString()).toLocal() : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'].toString()).toLocal() : DateTime.now(),
      durationDays: json['durationDays'] is int
          ? json['durationDays']
          : json['durationDays'] is String
          ? int.tryParse(json['durationDays']) ?? 0
          : 0,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()).toLocal() : DateTime.now(),
    );
  }

  String get formattedDate {
    return DateFormat('dd MMM yyyy').format(createdAt);
  }

  String get formattedTime {
    return DateFormat('hh:mm a').format(createdAt);
  }

  String get formattedDateTime {
    return '$formattedDate • $formattedTime';
  }

  String get formattedStartDate {
    return DateFormat('dd MMM yyyy').format(startDate);
  }

  String get formattedEndDate {
    return DateFormat('dd MMM yyyy').format(endDate);
  }

  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  bool get isActiveNow {
    return isActive && !isExpired && showOnFeed;
  }

  int get daysRemaining {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    return difference.inDays;
  }

  String get statusText {
    if (!isActive) return 'Inactive';
    if (isExpired) return 'Expired';
    if (daysRemaining <= 0) return 'Expires today';
    if (daysRemaining <= 7) return 'Expires in $daysRemaining days';
    return 'Active';
  }

  Color get statusColor {
    if (!isActive) return Colors.grey.shade600;
    if (isExpired) return Colors.red.shade600;
    if (daysRemaining <= 0) return Colors.orange.shade600;
    if (daysRemaining <= 7) return Colors.orange.shade600;
    return Colors.green.shade600;
  }
}
