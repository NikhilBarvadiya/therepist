import 'package:flutter/material.dart';

class ServiceModel {
  final int id;
  final String name;
  final String description;
  final IconData icon;
  bool isActive;

  ServiceModel({required this.id, required this.name, required this.description, required this.icon, this.isActive = true});
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
