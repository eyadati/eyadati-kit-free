import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class SpecialtyIcons {
  static final Map<String, IconData> icons = {
    'Dentiste': LucideIcons.smile,
    'Dentist': LucideIcons.smile,
    'Cardiologue': LucideIcons.heart,
    'Cardiologist': LucideIcons.heart,
    'Médecine générale': LucideIcons.stethoscope,
    'General Practitioner': LucideIcons.stethoscope,
    'Dermatologue': LucideIcons.hand,
    'Dermatologist': LucideIcons.hand,
    'Ophtalmologue': LucideIcons.eye,
    'Ophthalmologist': LucideIcons.eye,
    'Pédiatre': LucideIcons.baby,
    'Pediatrician': LucideIcons.baby,
    'Neurologue': LucideIcons.brain,
    'Neurologist': LucideIcons.brain,
    'Orthopédiste': LucideIcons.activity,
    'Orthopedist': LucideIcons.activity,
    'Gynécologue': LucideIcons.baby,
    'Gynecologist': LucideIcons.baby,
    'Urologue': LucideIcons.user,
    'Urologist': LucideIcons.user,
    'Psychiatre': LucideIcons.brain,
    'Psychiatrist': LucideIcons.brain,
    'Otorhinolaryngologue': LucideIcons.ear,
    'Otorhinolaryngologist': LucideIcons.ear,
    'Radiologue': LucideIcons.scan,
    'Radiologist': LucideIcons.scan,
    'Anesthésiste': LucideIcons.heart,
    'Anesthesiologist': LucideIcons.heart,
  };

  static IconData getIcon(String specialty) {
    return icons[specialty] ?? LucideIcons.stethoscope;
  }
}