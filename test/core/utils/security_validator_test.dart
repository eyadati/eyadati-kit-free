import 'package:flutter_test/flutter_test.dart';

import 'package:eyadati_kit/core/utils/security_validator.dart';

void main() {
  group('isValidUuid', () {
    test('accepts canonical uuid v4', () {
      expect(
          SecurityValidator.isValidUuid('123e4567-e89b-42d3-a456-426614174000'),
          isTrue);
      expect(
          SecurityValidator.isValidUuid('123E4567-E89B-42D3-A456-426614174000'),
          isTrue); // case-insensitive
    });

    test('rejects malformed values', () {
      expect(SecurityValidator.isValidUuid('not-a-uuid'), isFalse);
      expect(SecurityValidator.isValidUuid(''), isFalse);
      expect(SecurityValidator.isValidUuid('123e4567e89b42d3a456426614174000'),
          isFalse); // missing dashes
      expect(
          SecurityValidator.isValidUuid(
              '123e4567-e89b-42d3-a456-42661417400'), // too short
          isFalse);
    });
  });

  group('ownership checks', () {
    test('doctor ownership is a plain id match', () {
      expect(SecurityValidator.isValidDoctorOwnership('u1', 'u1'), isTrue);
      expect(SecurityValidator.isValidDoctorOwnership('u1', 'u2'), isFalse);
    });

    test('patient ownership requires a non-null id', () {
      expect(SecurityValidator.isValidPatientOwnership('u1', 'u1'), isTrue);
      expect(SecurityValidator.isValidPatientOwnership('u1', null), isFalse);
      expect(SecurityValidator.isValidPatientOwnership('u1', 'u2'), isFalse);
    });

    test('appointment access: either side may match', () {
      expect(SecurityValidator.isValidAppointmentOwnership('u1', 'u1', null),
          isTrue);
      expect(SecurityValidator.isValidAppointmentOwnership('u1', null, 'u1'),
          isTrue);
      expect(SecurityValidator.isValidAppointmentOwnership('u1', null, null),
          isFalse);
      expect(SecurityValidator.isValidAppointmentOwnership('u1', 'u2', 'u3'),
          isFalse);
      expect(SecurityValidator.canAccessAppointment('u1', 'u1', 'u3'), isTrue);
    });
  });

  group('appointment modification rules', () {
    test('only upcoming appointments can be modified', () {
      expect(SecurityValidator.canModifyAppointment('u1', 'u1', null, 'upcoming'),
          isTrue);
      expect(SecurityValidator.canModifyAppointment('u1', 'u1', null, 'done'),
          isFalse);
      expect(
          SecurityValidator.canModifyAppointment('u1', 'u1', null, 'cancelled'),
          isFalse);
      expect(SecurityValidator.canModifyAppointment('u2', 'u1', null, 'upcoming'),
          isFalse);
    });

    test('patient may modify own upcoming appointment', () {
      expect(SecurityValidator.canModifyAppointment('u1', null, 'u1', 'upcoming'),
          isTrue);
      expect(SecurityValidator.canModifyAppointment('u2', null, 'u1', 'upcoming'),
          isFalse);
    });
  });

  group('appointment creation rules', () {
    test('manual appointments require ownership', () {
      expect(
          SecurityValidator.canCreateManualAppointment('u1', 'u1', true), isTrue);
      expect(
          SecurityValidator.canCreateManualAppointment('u2', 'u1', true), isFalse);
      expect(
          SecurityValidator.canCreateManualAppointment('u2', 'u1', false), isTrue);
    });

    test('online appointments are never created by this path', () {
      expect(SecurityValidator.canCreateOnlineAppointment('u1', 'u1', false),
          isTrue);
      expect(SecurityValidator.canCreateOnlineAppointment('u1', 'u1', true),
          isFalse);
    });
  });

  group('sanitizeInput', () {
    test('null is safe', () {
      expect(SecurityValidator.sanitizeInput(null), isTrue);
    });

    test('rejects script / injection patterns', () {
      expect(
          SecurityValidator.sanitizeInput('<script>alert(1)</script>'), isFalse);
      expect(SecurityValidator.sanitizeInput('javascript:alert(1)'), isFalse);
      expect(SecurityValidator.sanitizeInput('img onerror=alert(1)'), isFalse);
      expect(SecurityValidator.sanitizeInput('drop table--patients'), isFalse);
      expect(SecurityValidator.sanitizeInput('/* comment */'), isFalse);
    });

    test('allows ordinary text', () {
      expect(SecurityValidator.sanitizeInput('Dr. Amina Belkacem'), isTrue);
      expect(SecurityValidator.sanitizeInput('consultation < 30 min'), isTrue);
      expect(SecurityValidator.sanitizeInput('0555 12 34 56'), isTrue);
    });
  });

  group('sanitizeHtml', () {
    test('null becomes empty string', () {
      expect(SecurityValidator.sanitizeHtml(null), '');
    });

    test('strips tags and escapes entities', () {
      expect(SecurityValidator.sanitizeHtml('<b>hello</b>'), 'hello');
      expect(SecurityValidator.sanitizeHtml('a & b'), 'a &amp; b');
      expect(SecurityValidator.sanitizeHtml('"quoted"'), '&quot;quoted&quot;');
      expect(SecurityValidator.sanitizeHtml("it's"), 'it&#x27;s');
      expect(SecurityValidator.sanitizeHtml("'quoted'"),
          '&#x27;quoted&#x27;');
    });
  });
}
