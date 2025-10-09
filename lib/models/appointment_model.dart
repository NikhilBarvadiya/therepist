class AppointmentModel {
  final String id;
  final String patientName;
  final String patientMobile;
  final String patientEmail;
  final String patientAddress;
  final String serviceName;
  final int charge;
  final String preferredType;
  final String status;
  final DateTime requestedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentModel({
    required this.id,
    required this.patientName,
    required this.patientMobile,
    required this.patientEmail,
    required this.patientAddress,
    required this.serviceName,
    required this.charge,
    required this.preferredType,
    required this.status,
    required this.requestedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['_id'] ?? '',
      patientName: json['patient']?['name'] ?? '',
      patientMobile: json['patient']?['mobile'] ?? '',
      patientEmail: json['patient']?['email'] ?? '',
      patientAddress: json['patient']?['location']?['address'] ?? '',
      serviceName: json['service']?['name'] ?? '',
      charge: json['charge'] ?? 0,
      preferredType: json['preferredType'] ?? '',
      status: json['status'] ?? '',
      requestedAt: DateTime.tryParse(json['requestedAt'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'patientName': patientName,
      'patientMobile': patientMobile,
      'patientEmail': patientEmail,
      'patientAddress': patientAddress,
      'serviceName': serviceName,
      'charge': charge,
      'preferredType': preferredType,
      'status': status,
      'requestedAt': requestedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? patientName,
    String? patientMobile,
    String? patientEmail,
    String? patientAddress,
    String? serviceName,
    int? charge,
    String? preferredType,
    String? status,
    DateTime? requestedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      patientMobile: patientMobile ?? this.patientMobile,
      patientEmail: patientEmail ?? this.patientEmail,
      patientAddress: patientAddress ?? this.patientAddress,
      serviceName: serviceName ?? this.serviceName,
      charge: charge ?? this.charge,
      preferredType: preferredType ?? this.preferredType,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
