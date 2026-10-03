class SecurityValidator {
  static bool isValidUuid(String value) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(value);
  }

  static bool isValidDoctorOwnership(String userId, String doctorId) {
    return userId == doctorId;
  }

  static bool isValidPatientOwnership(String userId, String? patientId) {
    return patientId != null && userId == patientId;
  }

  static bool isValidAppointmentOwnership(String userId, String? doctorId, String? patientId) {
    return (doctorId != null && isValidDoctorOwnership(userId, doctorId)) ||
           isValidPatientOwnership(userId, patientId);
  }

  static bool canAccessAppointment(String userId, String? doctorId, String? patientId) {
    return isValidAppointmentOwnership(userId, doctorId, patientId);
  }

  static bool canModifyAppointment(String userId, String? doctorId, String? patientId, String status) {
    if (status != 'upcoming') {
      return false;
    }
    return (doctorId != null && isValidDoctorOwnership(userId, doctorId)) ||
           isValidPatientOwnership(userId, patientId);
  }

  static bool canCreateManualAppointment(String userId, String doctorId, bool isManual) {
    if (!isManual) return true;
    return isValidDoctorOwnership(userId, doctorId);
  }

  static bool canCreateOnlineAppointment(String userId, String doctorId, bool isManual) {
    if (isManual) return false;
    return true;
  }

  static bool sanitizeInput(String? value) {
    if (value == null) return true;
    final dangerousPatterns = [
      RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, multiLine: true),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
      RegExp(r'--', caseSensitive: false),
      RegExp(r'\/\*.*?\*\/', caseSensitive: false, multiLine: true),
    ];

    for (final pattern in dangerousPatterns) {
      if (pattern.hasMatch(value)) {
        return false;
      }
    }
    return true;
  }

  static String sanitizeHtml(String? value) {
    if (value == null) return '';
    return value
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }
}
