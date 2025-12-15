class APIIndex {
  /// Without Auth
  static const String services = 'services';
  static const String equipment = 'equipment';

  /// Auth
  static const String register = 'doctor/register';
  static const String login = 'doctor/login';

  /// Verification
  static const String otpSend = 'doctor/otp/send';
  static const String otpVerify = 'doctor/otp/verify';

  /// Forgot Password
  static const String forgotPassword = 'doctor/forgot-password';

  /// Profile
  static const String getProfile = 'doctor/get-profile';
  static const String updateProfile = 'doctor/update-profile';
  static const String updatePassword = 'doctor/change-password';
  static const String updateWorkingDays = 'doctor/update-working-days';
  static const String recognitions = 'doctor/recognitions';

  /// Recharge
  static const String rechargePlans = 'doctor/recharge-plans';
  static const String createRechargePayment = 'doctor/recharge/payments';
  static const String walletTransactions = 'doctor/wallet/transactions';

  /// Service
  static const String doctorServices = 'doctor/services';
  static const String toggleService = 'doctor/toggle-service';

  /// Equipment
  static const String doctorEquipment = 'doctor/equipment';
  static const String toggleEquipment = 'doctor/toggle-equipment';

  /// Appointments
  static const String getAppointments = 'doctor/appointments/get';
  static const String requestsAccept = 'doctor/requests/accept';
  static const String requestsCancel = 'doctor/requests/cancel';
  static const String completeAppointment = 'doctor/appointments/complete';
}
