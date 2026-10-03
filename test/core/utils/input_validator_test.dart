import 'package:flutter_test/flutter_test.dart';

import 'package:eyadati_kit/core/utils/input_validator.dart';

void main() {
  group('validateEmail', () {
    test('null and empty are required errors', () {
      expect(InputValidator.validateEmail(null), 'Email is required');
      expect(InputValidator.validateEmail(''), 'Email is required');
    });

    test('rejects malformed addresses', () {
      expect(InputValidator.validateEmail('not-an-email'),
          'Please enter a valid email address');
      expect(InputValidator.validateEmail('a@b'), isNotNull);
      expect(InputValidator.validateEmail('a@b.c'), isNotNull); // 1-char TLD
    });

    test('accepts valid addresses', () {
      expect(InputValidator.validateEmail('doctor@example.com'), isNull);
      expect(InputValidator.validateEmail('a.b+c@sub.domain.dz'), isNull);
      expect(InputValidator.isValidEmail('doctor@example.com'), isTrue);
      expect(InputValidator.isValidEmail('nope'), isFalse);
    });
  });

  group('validatePassword', () {
    test('required / min length 6', () {
      expect(InputValidator.validatePassword(null), 'Password is required');
      expect(InputValidator.validatePassword(''), 'Password is required');
      expect(InputValidator.validatePassword('12345'),
          'Password must be at least 6 characters');
      expect(InputValidator.validatePassword('123456'), isNull);
    });
  });

  group('validatePhone', () {
    test('null or empty is allowed (optional field)', () {
      expect(InputValidator.validatePhone(null), isNull);
      expect(InputValidator.validatePhone(''), isNull);
    });

    test('cleans separators before validating', () {
      expect(InputValidator.validatePhone('+213 555 12 34 56'), isNull);
      expect(InputValidator.validatePhone('0555-123-456'), isNull);
      expect(InputValidator.validatePhone('abc'), isNotNull);
      expect(InputValidator.validatePhone('123'), isNotNull); // too short
    });
  });

  group('validateAlgerianPhone', () {
    test('null / empty required', () {
      expect(InputValidator.validateAlgerianPhone(null),
          'Phone number is required');
      expect(InputValidator.validateAlgerianPhone(''),
          'Phone number is required');
    });

    test('accepts 05/06/07 local and +213 international forms', () {
      expect(InputValidator.validateAlgerianPhone('0555123456'), isNull);
      expect(InputValidator.validateAlgerianPhone('05 55 12 34 56'), isNull);
      expect(InputValidator.validateAlgerianPhone('+213555123456'), isNull);
      expect(InputValidator.validateAlgerianPhone('0777123456'), isNull);
    });

    test('accepts international E.164 numbers', () {
      expect(InputValidator.validateAlgerianPhone('+15551234567'), isNull);
      expect(InputValidator.validateAlgerianPhone('+447911123456'), isNull);
      expect(InputValidator.validateAlgerianPhone('+33612345678'), isNull);
    });

    test('rejects invalid numbers with a message', () {
      expect(InputValidator.validateAlgerianPhone('0888123456'), isNotNull);
      expect(InputValidator.validateAlgerianPhone('12345'), isNotNull);
      expect(InputValidator.validateAlgerianPhone('not-a-number'), isNotNull);
      expect(InputValidator.validateAlgerianPhone('+0123456'), isNotNull);
      expect(InputValidator.validateAlgerianPhone('+12'), isNotNull);
      expect(
          InputValidator.validateAlgerianPhone('12345'),
          'Invalid number (e.g. +1 555 123 4567 or 05 55 12 34 56)',
      );
    });
  });

  group('phone formatting', () {
    test('formatPhoneForE164', () {
      expect(InputValidator.formatPhoneForE164('0555123456'), '+213555123456');
      expect(InputValidator.formatPhoneForE164('05 55 12 34 56'),
          '+213555123456');
      expect(InputValidator.formatPhoneForE164('+213555123456'),
          '+213555123456');
      expect(InputValidator.formatPhoneForE164('555123456'), '+213555123456');
    });

    test('formatPhoneLocal', () {
      expect(InputValidator.formatPhoneLocal('+213555123456'), '05 55 12 34 56');
      expect(InputValidator.formatPhoneLocal('213555123456'), '05 55 12 34 56');
      expect(InputValidator.formatPhoneLocal('0555123456'), '05 55 12 34 56');
      expect(InputValidator.formatPhoneLocal('05 55 12 34 56'), '05 55 12 34 56');
      expect(InputValidator.formatPhoneLocal('+15551234567'), '+15551234567');
    });
  });

  group('validateFullName / validateRequired', () {
    test('full name bounds', () {
      expect(InputValidator.validateFullName(null), 'Full name is required');
      expect(InputValidator.validateFullName(''), 'Full name is required');
      expect(InputValidator.validateFullName('A'), isNotNull);
      expect(InputValidator.validateFullName('Dr. A'), isNull);
      expect(
          InputValidator.validateFullName('x' * 101),
          'Name must be less than 100 characters');
    });

    test('validateRequired includes the field name', () {
      expect(InputValidator.validateRequired(null, 'City'), 'City is required');
      expect(InputValidator.validateRequired('Alger', 'City'), isNull);
    });
  });

  group('validateDuration', () {
    test('bounds 5..180 minutes', () {
      expect(InputValidator.validateDuration(null),
          'Duration must be greater than 0');
      expect(InputValidator.validateDuration(0),
          'Duration must be greater than 0');
      expect(InputValidator.validateDuration(4),
          'Duration must be at least 5 minutes');
      expect(InputValidator.validateDuration(30), isNull);
      expect(InputValidator.validateDuration(181),
          'Duration cannot exceed 3 hours');
    });
  });

  group('validateAppointmentDate', () {
    test('rejects null and past dates', () {
      expect(InputValidator.validateAppointmentDate(null),
          'Appointment date is required');
      expect(InputValidator.validateAppointmentDate(
              DateTime.now().subtract(const Duration(hours: 1))),
          'Cannot book appointments in the past');
    });

    test('rejects less than 30 minutes ahead', () {
      expect(InputValidator.validateAppointmentDate(
              DateTime.now().add(const Duration(minutes: 5))),
          'Appointments must be booked at least 30 minutes in advance');
    });

    test('accepts dates far in the future', () {
      expect(
          InputValidator.validateAppointmentDate(
              DateTime.now().add(const Duration(days: 1))),
          isNull);
    });
  });

  group('validateWorkingHours', () {
    test('int hours', () {
      expect(InputValidator.validateWorkingHours(-1, 18), 'Invalid opening hour');
      expect(InputValidator.validateWorkingHours(8, 25), 'Invalid closing hour');
      expect(InputValidator.validateWorkingHours(18, 8),
          'Opening time must be before closing time');
      expect(InputValidator.validateWorkingHours(9, 9),
          'Opening time must be before closing time');
      expect(InputValidator.validateWorkingHours(9, 18), isNull);
    });

    test('string hours', () {
      expect(InputValidator.validateWorkingHoursString(null, '18:00'),
          'Working hours are required');
      expect(InputValidator.validateWorkingHoursString('09:00', '18:00'), isNull);
      expect(InputValidator.validateWorkingHoursString('18:00', '09:00'),
          'Opening time must be before closing time');
      expect(InputValidator.validateWorkingHoursString('09:00', '09:30'),
          'Must work at least 1 hour');
      expect(InputValidator.validateWorkingHoursString('9am', '18:00'),
          'Invalid time format');
      expect(InputValidator.validateWorkingHoursString('09', '18'),
          'Invalid time format');
    });
  });

  group('optional text fields', () {
    test('city and bio allow empty but bound length', () {
      expect(InputValidator.validateCity(null), isNull);
      expect(InputValidator.validateCity(''), isNull);
      expect(InputValidator.validateCity('x' * 101), 'City name is too long');
      expect(InputValidator.validateBio(null), isNull);
      expect(InputValidator.validateBio('x' * 1001),
          'Bio must be less than 1000 characters');
      expect(InputValidator.validateBio('General practitioner'), isNull);
    });
  });
}
