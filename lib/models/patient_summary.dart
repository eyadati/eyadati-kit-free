import 'package:eyadati_kit/models/appointment_data.dart';

class PatientSummary {
  final String patientId;
  final String patientName;
  final String? patientPhone;
  final String? patientAvatar;
  final int visitCount;
  final int noShowCount;
  final DateTime? lastNoShowAt;
  final DateTime lastVisitDate;
  final String? latestNotePreview;
  final List<AppointmentData> visits;
  final int globalTotal;
  final int globalNoShows;

  PatientSummary({
    required this.patientId,
    required this.patientName,
    this.patientPhone,
    this.patientAvatar,
    required this.visitCount,
    this.noShowCount = 0,
    this.lastNoShowAt,
    required this.lastVisitDate,
    this.latestNotePreview,
    required this.visits,
    this.globalTotal = 0,
    this.globalNoShows = 0,
  });

  static const int _minHistory = 3;

  int get totalGlobalAppts => globalTotal;
  int get totalGlobalNoShows => globalNoShows;

  bool get hasSufficientHistory => totalGlobalAppts >= _minHistory;

  double get attendanceRate {
    final total = totalGlobalAppts;
    if (total == 0) return 1.0;
    return (total - totalGlobalNoShows) / total;
  }
}
