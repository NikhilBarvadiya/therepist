import 'package:flutter/material.dart';

class ServiceModel {
  final int id;
  final String name;
  final String description;
  final IconData icon;
  bool isActive;
  final double rate;

  ServiceModel({required this.id, required this.name, required this.description, required this.icon, this.isActive = false, this.rate = 0.0});
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String password;
  final String specialty;
  final int experienceYears;
  final String clinicName;
  final String clinicAddress;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    required this.specialty,
    required this.experienceYears,
    required this.clinicName,
    required this.clinicAddress,
  });
}

class EquipmentModel {
  final int id;
  final String name;
  final String description;
  final IconData icon;
  bool isActive;
  final double rate;

  EquipmentModel({required this.id, required this.name, required this.description, required this.icon, this.isActive = false, required this.rate});

  EquipmentModel copyWith({int? id, String? name, String? description, IconData? icon, bool? isActive, double? rate}) {
    return EquipmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      rate: rate ?? this.rate,
    );
  }
}

class AppointmentModel {
  final int id;
  final String patientName;
  final String date;
  final String time;
  final String service;
  final String status;

  AppointmentModel({required this.id, required this.patientName, required this.date, required this.time, required this.service, required this.status});
}

class RequestModel {
  final int id;
  final String patientName;
  final String service;
  final String date;

  RequestModel({required this.id, required this.patientName, required this.service, required this.date});
}
