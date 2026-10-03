class RouteNames {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String selectRole = '/select-role';

  static const String patientHome = '/patient/home';
  static const String patientDoctors = '/patient/doctors';
  static const String patientDoctorDetails = '/patient/doctors/:id';
  static const String patientBookAppointment = '/patient/doctors/:id/book';
  static const String patientAppointments = '/patient/appointments';
  static const String patientFavorites = '/patient/favorites';
  static const String patientProfile = '/patient/profile';
  static const String patientEditProfile = '/patient/profile/edit';

  static const String doctorDashboard = '/doctor/dashboard';
  static const String doctorSetup = '/doctor/setup';
  static const String doctorCalendar = '/doctor/calendar';
  static const String doctorSchedule = '/doctor/schedule';
  static const String doctorPatients = '/doctor/patients';
  static const String doctorSettings = '/doctor/settings';

  static const String clinicCalendar = '/clinic/calendar';
}