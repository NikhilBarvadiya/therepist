class APIIndex {
  /// Without Auth
  static const String services = 'services'; // done
  static const String equipment = 'equipment'; // done

  /// Auth
  static const String register = 'doctor/register'; // done
  static const String login = 'doctor/login'; // done
  static const String getProfile = 'doctor/get-profile'; // done
  static const String updateProfile = 'doctor/update-profile'; // done
  static const String updatePassword = 'doctor/change-password'; // done
  static const String updateWorkingDays = 'doctor/update-working-days'; // done

  /// Service
  static const String doctorServices = 'doctor/services'; // done
  static const String toggleService = 'doctor/toggle-service'; // done

  /// Equipment
  static const String doctorEquipment = 'doctor/equipment'; // done
  static const String toggleEquipment = 'doctor/toggle-equipment'; // done

  /// Appointments
  static const String getAppointments = 'doctor/appointments/get'; // done
  static const String requestsAccept = 'doctor/requests/accept'; // done
  static const String requestsCancel = 'doctor/requests/cancel'; // done
  static const String completeAppointment = 'doctor/appointments/complete'; // done
}
