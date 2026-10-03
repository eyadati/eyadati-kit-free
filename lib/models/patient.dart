class Patient {
  final String id;
  final String fullName;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? city;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? bloodType;
  final String? allergies;
  final String? medicalHistory;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Patient({
    required this.id,
    required this.fullName,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.city,
    this.emergencyContact,
    this.emergencyPhone,
    this.bloodType,
    this.allergies,
    this.medicalHistory,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      emergencyPhone: json['emergency_phone'] as String?,
      bloodType: json['blood_type'] as String?,
      allergies: json['allergies'] as String?,
      medicalHistory: json['medical_history'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth!.toIso8601String().split('T').first,
      if (gender != null) 'gender': gender,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (emergencyContact != null) 'emergency_contact': emergencyContact,
      if (emergencyPhone != null) 'emergency_phone': emergencyPhone,
      if (bloodType != null) 'blood_type': bloodType,
      if (allergies != null) 'allergies': allergies,
      if (medicalHistory != null) 'medical_history': medicalHistory,
      if (notes != null) 'notes': notes,
    };
  }

  Patient copyWith({
    String? id,
    String? fullName,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? city,
    String? emergencyContact,
    String? emergencyPhone,
    String? bloodType,
    String? allergies,
    String? medicalHistory,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      city: city ?? this.city,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}