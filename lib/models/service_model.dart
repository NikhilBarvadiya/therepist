import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String name;
  final int? charge;
  final int? lowCharge;
  final int? highCharge;
  final IconData? icon;
  final String? description;
  bool isActive;

  ServiceModel({required this.id, required this.name, this.charge, this.lowCharge, this.highCharge, this.icon, this.description, required this.isActive});

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'],
      name: json['name'],
      charge: json['charge'] ?? 0,
      lowCharge: json['lowCharge'] ?? 0,
      highCharge: json['highCharge'] ?? 0,
      icon: _getIconFromString(json['icon'] ?? 'default'),
      isActive: json['isActive'] ?? true,
      description: json['description'] ?? 'Professional service with customized treatment plans.',
    );
  }

  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'psychology':
        return Icons.psychology;
      case 'sports_tennis':
        return Icons.sports_tennis;
      case 'pregnant_woman':
        return Icons.pregnant_woman;
      case 'directions_run':
        return Icons.directions_run;
      case 'elderly':
        return Icons.elderly;
      case 'child_care':
        return Icons.child_care;
      case 'healing':
        return Icons.healing;
      case 'spa':
        return Icons.spa;
      case 'touch_app':
        return Icons.touch_app;
      case 'medical_services':
        return Icons.medical_services;
      case 'light':
        return Icons.light;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'vibration':
        return Icons.vibration;
      default:
        return Icons.miscellaneous_services;
    }
  }
}
