class PatientNote {
  final String id;
  final String patientId;
  final String doctorId;
  final String appointmentId;
  final String noteText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? appointmentDate;

  PatientNote({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentId,
    required this.noteText,
    required this.createdAt,
    required this.updatedAt,
    this.appointmentDate,
  });

  factory PatientNote.fromMap(Map<String, dynamic> map) {
    return PatientNote(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      doctorId: map['doctor_id'] as String,
      appointmentId: map['appointment_id'] as String,
      noteText: map['note_text'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      appointmentDate: map['appointment_date'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patient_id': patientId,
      'doctor_id': doctorId,
      'appointment_id': appointmentId,
      'note_text': noteText,
    };
  }
}
