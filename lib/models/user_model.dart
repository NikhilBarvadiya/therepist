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
  final String avatar;
  final String type;
  final int notificationRange;
  final List<Map<String, dynamic>> workingDays;
  final List<Map<String, dynamic>> services;
  final List<Map<String, dynamic>> equipment;
  final LocationModel location;

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
    required this.avatar,
    required this.type,
    required this.notificationRange,
    required this.workingDays,
    required this.services,
    required this.equipment,
    required this.location,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      password: '********',
      specialty: json['specialties'] != null && json['specialties'].isNotEmpty ? json['specialties'][0]['name'] ?? '' : '',
      experienceYears: json['experience'] ?? 0,
      clinicName: json['clinicName'] ?? '',
      clinicAddress: json['location'] != null ? json['location']['address'] ?? '' : '',
      avatar: json['avatar'] ?? '',
      type: json['type'] ?? 'Regular',
      notificationRange: json['notificationRange'] ?? 8,
      workingDays: List<Map<String, dynamic>>.from(json['workingDays'] ?? []),
      services: List<Map<String, dynamic>>.from(json['services'] ?? []),
      equipment: List<Map<String, dynamic>>.from(json['equipment'] ?? []),
      location: LocationModel(
        address: json['location'] != null ? json['location']['address'] ?? '' : '',
        coordinates: json['location'] != null ? List<String>.from(json['location']['coordinates'] ?? ['0.0', '0.0']) : ['0.0', '0.0'],
      ),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? mobile,
    String? password,
    String? specialty,
    int? experienceYears,
    String? clinicName,
    String? clinicAddress,
    String? avatar,
    String? type,
    int? notificationRange,
    List<Map<String, dynamic>>? workingDays,
    List<Map<String, dynamic>>? services,
    List<Map<String, dynamic>>? equipment,
    LocationModel? location,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      password: password ?? this.password,
      specialty: specialty ?? this.specialty,
      experienceYears: experienceYears ?? this.experienceYears,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      avatar: avatar ?? this.avatar,
      type: type ?? this.type,
      notificationRange: notificationRange ?? this.notificationRange,
      workingDays: workingDays ?? this.workingDays,
      services: services ?? this.services,
      equipment: equipment ?? this.equipment,
      location: location ?? this.location,
    );
  }
}

class LocationModel {
  final String address;
  final List<String> coordinates;

  LocationModel({required this.address, required this.coordinates});
}
