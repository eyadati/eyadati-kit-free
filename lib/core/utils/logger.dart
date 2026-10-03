enum LogLevel { debug, info, warning, error, critical }

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? context;
  final Map<String, dynamic>? metadata;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.context,
    this.metadata,
  });

  String get levelString {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.critical:
        return 'CRITICAL';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': levelString,
      'message': message,
      'context': context,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('[$timestamp] ');
    buffer.write('[$levelString] ');
    if (context != null) {
      buffer.write('[$context] ');
    }
    buffer.write(message);
    if (metadata != null && metadata!.isNotEmpty) {
      buffer.write(' | $metadata');
    }
    return buffer.toString();
  }
}

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  final List<LogEntry> _logs = [];
  final int _maxLogs = 1000;
  bool _isDebugMode = false;

  void setDebugMode(bool enabled) {
    _isDebugMode = enabled;
  }

  void _addLog(LogEntry entry) {
    if (!_isDebugMode && entry.level == LogLevel.debug) {
      return;
    }

    _logs.add(entry);
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

    _printLog(entry);
  }

  void _printLog(LogEntry entry) {
    if (_isDebugMode) {
      print(entry.toString());
    }
  }

  void debug(String message, {String? context, Map<String, dynamic>? metadata}) {
    _addLog(LogEntry(
      timestamp: DateTime.now(),
      level: LogLevel.debug,
      message: message,
      context: context,
      metadata: metadata,
    ));
  }

  void info(String message, {String? context, Map<String, dynamic>? metadata}) {
    _addLog(LogEntry(
      timestamp: DateTime.now(),
      level: LogLevel.info,
      message: message,
      context: context,
      metadata: metadata,
    ));
  }

  void warning(String message, {String? context, Map<String, dynamic>? metadata}) {
    _addLog(LogEntry(
      timestamp: DateTime.now(),
      level: LogLevel.warning,
      message: message,
      context: context,
      metadata: metadata,
    ));
  }

  void error(String message, {String? context, Map<String, dynamic>? metadata}) {
    _addLog(LogEntry(
      timestamp: DateTime.now(),
      level: LogLevel.error,
      message: message,
      context: context,
      metadata: metadata,
    ));
  }

  void critical(String message, {String? context, Map<String, dynamic>? metadata}) {
    _addLog(LogEntry(
      timestamp: DateTime.now(),
      level: LogLevel.critical,
      message: message,
      context: context,
      metadata: metadata,
    ));
  }

  List<LogEntry> getLogs({LogLevel? minLevel, int? limit}) {
    var logs = _logs.toList();

    if (minLevel != null) {
      logs = logs.where((log) => log.level.index >= minLevel.index).toList();
    }

    if (limit != null && limit > 0) {
      logs = logs.take(limit).toList();
    }

    return logs;
  }

  List<LogEntry> getLogsByContext(String context) {
    return _logs.where((log) => log.context == context).toList();
  }

  List<LogEntry> getRecentErrors({int limit = 50}) {
    return _logs
        .where((log) =>
            log.level == LogLevel.error ||
            log.level == LogLevel.critical)
        .take(limit)
        .toList();
  }

  void clearLogs() {
    _logs.clear();
  }

  Map<String, dynamic> getLogsSummary() {
    return {
      'total_logs': _logs.length,
      'debug': _logs.where((l) => l.level == LogLevel.debug).length,
      'info': _logs.where((l) => l.level == LogLevel.info).length,
      'warning': _logs.where((l) => l.level == LogLevel.warning).length,
      'error': _logs.where((l) => l.level == LogLevel.error).length,
      'critical': _logs.where((l) => l.level == LogLevel.critical).length,
      'oldest': _logs.isNotEmpty ? _logs.first.timestamp.toIso8601String() : null,
      'newest': _logs.isNotEmpty ? _logs.last.timestamp.toIso8601String() : null,
    };
  }
}

class AuthLogger {
  static final AppLogger _logger = AppLogger();

  static void logSignIn(String userId, {bool success = true}) {
    _logger.info(
      success ? 'User signed in' : 'Failed sign in attempt',
      context: 'Auth',
      metadata: {'user_id': userId, 'success': success},
    );
  }

  static void logSignUp(String userId, String role) {
    _logger.info(
      'New user registered',
      context: 'Auth',
      metadata: {'user_id': userId, 'role': role},
    );
  }

  static void logSignOut(String userId) {
    _logger.info(
      'User signed out',
      context: 'Auth',
      metadata: {'user_id': userId},
    );
  }

  static void logAuthError(String error, {String? userId}) {
    _logger.error(
      'Authentication error',
      context: 'Auth',
      metadata: {'error': error, 'user_id': userId},
    );
  }
}

class BookingLogger {
  static final AppLogger _logger = AppLogger();

  static void logBookingCreated(String appointmentId, String doctorId, String patientId) {
    _logger.info(
      'Appointment booked',
      context: 'Booking',
      metadata: {
        'appointment_id': appointmentId,
        'doctor_id': doctorId,
        'patient_id': patientId,
      },
    );
  }

  static void logBookingCancelled(String appointmentId, String cancelledBy) {
    _logger.info(
      'Appointment cancelled',
      context: 'Booking',
      metadata: {
        'appointment_id': appointmentId,
        'cancelled_by': cancelledBy,
      },
    );
  }

  static void logBookingFailed(String error, {String? doctorId, String? patientId}) {
    _logger.error(
      'Booking failed',
      context: 'Booking',
      metadata: {
        'error': error,
        'doctor_id': doctorId,
        'patient_id': patientId,
      },
    );
  }

  static void logStatusUpdate(String appointmentId, String oldStatus, String newStatus) {
    _logger.info(
      'Appointment status updated',
      context: 'Booking',
      metadata: {
        'appointment_id': appointmentId,
        'old_status': oldStatus,
        'new_status': newStatus,
      },
    );
  }
}

class SecurityLogger {
  static final AppLogger _logger = AppLogger();

  static void logValidationFailure(String context, String field, String reason) {
    _logger.warning(
      'Input validation failed',
      context: 'Security',
      metadata: {
        'context': context,
        'field': field,
        'reason': reason,
      },
    );
  }

  static void logOwnershipViolation(String userId, String resource, String action) {
    _logger.warning(
      'Ownership violation attempt',
      context: 'Security',
      metadata: {
        'user_id': userId,
        'resource': resource,
        'action': action,
      },
    );
  }

  static void logSuspiciousActivity(String description, {String? userId, String? ipAddress}) {
    _logger.warning(
      'Suspicious activity detected',
      context: 'Security',
      metadata: {
        'description': description,
        'user_id': userId,
        'ip_address': ipAddress,
      },
    );
  }
}
