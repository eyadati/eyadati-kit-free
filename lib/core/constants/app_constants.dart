class AppConstants {
  static const String appName = 'Eyadati';
  static const String appDescription = 'Doctor Appointment Booking Platform';

  static const int defaultAppointmentDuration = 20;
  static const int defaultConsultationDuration = 40;
  static const int defaultOpeningHour = 9;
  static const int defaultClosingHour = 17;

  static const List<String> defaultWorkingDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
  ];
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String selectRole = '/select-role';

  static const String patientHome = '/patient';
  static const String patientDoctors = '/patient/doctors';
  static const String patientDoctorDetails = '/patient/doctors/:id';
  static const String patientBookAppointment = '/patient/doctors/:id/book';
  static const String patientAppointments = '/patient/appointments';
  static const String patientFavorites = '/patient/favorites';
  static const String patientProfile = '/patient/profile';

  static const String doctorHome = '/doctor';
  static const String doctorSchedule = '/doctor/schedule';
}
