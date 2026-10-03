// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Appointment _$AppointmentFromJson(Map<String, dynamic> json) {
  return _Appointment.fromJson(json);
}

/// @nodoc
mixin _$Appointment {
  String get id => throw _privateConstructorUsedError;
  String get doctorId => throw _privateConstructorUsedError;
  String? get patientId => throw _privateConstructorUsedError;
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  AppointmentStatus get status => throw _privateConstructorUsedError;
  BookingType get bookingType => throw _privateConstructorUsedError;
  bool get isConsultation => throw _privateConstructorUsedError;
  String get patientNameSnapshot => throw _privateConstructorUsedError;
  String? get patientPhoneSnapshot => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get attendanceStatus => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Appointment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Appointment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppointmentCopyWith<Appointment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppointmentCopyWith<$Res> {
  factory $AppointmentCopyWith(
    Appointment value,
    $Res Function(Appointment) then,
  ) = _$AppointmentCopyWithImpl<$Res, Appointment>;
  @useResult
  $Res call({
    String id,
    String doctorId,
    String? patientId,
    DateTime scheduledAt,
    int duration,
    AppointmentStatus status,
    BookingType bookingType,
    bool isConsultation,
    String patientNameSnapshot,
    String? patientPhoneSnapshot,
    String? notes,
    String? attendanceStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$AppointmentCopyWithImpl<$Res, $Val extends Appointment>
    implements $AppointmentCopyWith<$Res> {
  _$AppointmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Appointment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? doctorId = null,
    Object? patientId = freezed,
    Object? scheduledAt = null,
    Object? duration = null,
    Object? status = null,
    Object? bookingType = null,
    Object? isConsultation = null,
    Object? patientNameSnapshot = null,
    Object? patientPhoneSnapshot = freezed,
    Object? notes = freezed,
    Object? attendanceStatus = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            doctorId: null == doctorId
                ? _value.doctorId
                : doctorId // ignore: cast_nullable_to_non_nullable
                      as String,
            patientId: freezed == patientId
                ? _value.patientId
                : patientId // ignore: cast_nullable_to_non_nullable
                      as String?,
            scheduledAt: null == scheduledAt
                ? _value.scheduledAt
                : scheduledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as AppointmentStatus,
            bookingType: null == bookingType
                ? _value.bookingType
                : bookingType // ignore: cast_nullable_to_non_nullable
                      as BookingType,
            isConsultation: null == isConsultation
                ? _value.isConsultation
                : isConsultation // ignore: cast_nullable_to_non_nullable
                      as bool,
            patientNameSnapshot: null == patientNameSnapshot
                ? _value.patientNameSnapshot
                : patientNameSnapshot // ignore: cast_nullable_to_non_nullable
                      as String,
            patientPhoneSnapshot: freezed == patientPhoneSnapshot
                ? _value.patientPhoneSnapshot
                : patientPhoneSnapshot // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            attendanceStatus: freezed == attendanceStatus
                ? _value.attendanceStatus
                : attendanceStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppointmentImplCopyWith<$Res>
    implements $AppointmentCopyWith<$Res> {
  factory _$$AppointmentImplCopyWith(
    _$AppointmentImpl value,
    $Res Function(_$AppointmentImpl) then,
  ) = __$$AppointmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String doctorId,
    String? patientId,
    DateTime scheduledAt,
    int duration,
    AppointmentStatus status,
    BookingType bookingType,
    bool isConsultation,
    String patientNameSnapshot,
    String? patientPhoneSnapshot,
    String? notes,
    String? attendanceStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$AppointmentImplCopyWithImpl<$Res>
    extends _$AppointmentCopyWithImpl<$Res, _$AppointmentImpl>
    implements _$$AppointmentImplCopyWith<$Res> {
  __$$AppointmentImplCopyWithImpl(
    _$AppointmentImpl _value,
    $Res Function(_$AppointmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Appointment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? doctorId = null,
    Object? patientId = freezed,
    Object? scheduledAt = null,
    Object? duration = null,
    Object? status = null,
    Object? bookingType = null,
    Object? isConsultation = null,
    Object? patientNameSnapshot = null,
    Object? patientPhoneSnapshot = freezed,
    Object? notes = freezed,
    Object? attendanceStatus = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$AppointmentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        doctorId: null == doctorId
            ? _value.doctorId
            : doctorId // ignore: cast_nullable_to_non_nullable
                  as String,
        patientId: freezed == patientId
            ? _value.patientId
            : patientId // ignore: cast_nullable_to_non_nullable
                  as String?,
        scheduledAt: null == scheduledAt
            ? _value.scheduledAt
            : scheduledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as AppointmentStatus,
        bookingType: null == bookingType
            ? _value.bookingType
            : bookingType // ignore: cast_nullable_to_non_nullable
                  as BookingType,
        isConsultation: null == isConsultation
            ? _value.isConsultation
            : isConsultation // ignore: cast_nullable_to_non_nullable
                  as bool,
        patientNameSnapshot: null == patientNameSnapshot
            ? _value.patientNameSnapshot
            : patientNameSnapshot // ignore: cast_nullable_to_non_nullable
                  as String,
        patientPhoneSnapshot: freezed == patientPhoneSnapshot
            ? _value.patientPhoneSnapshot
            : patientPhoneSnapshot // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        attendanceStatus: freezed == attendanceStatus
            ? _value.attendanceStatus
            : attendanceStatus // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppointmentImpl implements _Appointment {
  const _$AppointmentImpl({
    required this.id,
    required this.doctorId,
    this.patientId,
    required this.scheduledAt,
    required this.duration,
    required this.status,
    required this.bookingType,
    this.isConsultation = false,
    required this.patientNameSnapshot,
    this.patientPhoneSnapshot,
    this.notes,
    this.attendanceStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory _$AppointmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppointmentImplFromJson(json);

  @override
  final String id;
  @override
  final String doctorId;
  @override
  final String? patientId;
  @override
  final DateTime scheduledAt;
  @override
  final int duration;
  @override
  final AppointmentStatus status;
  @override
  final BookingType bookingType;
  @override
  @JsonKey()
  final bool isConsultation;
  @override
  final String patientNameSnapshot;
  @override
  final String? patientPhoneSnapshot;
  @override
  final String? notes;
  @override
  final String? attendanceStatus;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Appointment(id: $id, doctorId: $doctorId, patientId: $patientId, scheduledAt: $scheduledAt, duration: $duration, status: $status, bookingType: $bookingType, isConsultation: $isConsultation, patientNameSnapshot: $patientNameSnapshot, patientPhoneSnapshot: $patientPhoneSnapshot, notes: $notes, attendanceStatus: $attendanceStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppointmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.bookingType, bookingType) ||
                other.bookingType == bookingType) &&
            (identical(other.isConsultation, isConsultation) ||
                other.isConsultation == isConsultation) &&
            (identical(other.patientNameSnapshot, patientNameSnapshot) ||
                other.patientNameSnapshot == patientNameSnapshot) &&
            (identical(other.patientPhoneSnapshot, patientPhoneSnapshot) ||
                other.patientPhoneSnapshot == patientPhoneSnapshot) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.attendanceStatus, attendanceStatus) ||
                other.attendanceStatus == attendanceStatus) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    doctorId,
    patientId,
    scheduledAt,
    duration,
    status,
    bookingType,
    isConsultation,
    patientNameSnapshot,
    patientPhoneSnapshot,
    notes,
    attendanceStatus,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Appointment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppointmentImplCopyWith<_$AppointmentImpl> get copyWith =>
      __$$AppointmentImplCopyWithImpl<_$AppointmentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppointmentImplToJson(this);
  }
}

abstract class _Appointment implements Appointment {
  const factory _Appointment({
    required final String id,
    required final String doctorId,
    final String? patientId,
    required final DateTime scheduledAt,
    required final int duration,
    required final AppointmentStatus status,
    required final BookingType bookingType,
    final bool isConsultation,
    required final String patientNameSnapshot,
    final String? patientPhoneSnapshot,
    final String? notes,
    final String? attendanceStatus,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$AppointmentImpl;

  factory _Appointment.fromJson(Map<String, dynamic> json) =
      _$AppointmentImpl.fromJson;

  @override
  String get id;
  @override
  String get doctorId;
  @override
  String? get patientId;
  @override
  DateTime get scheduledAt;
  @override
  int get duration;
  @override
  AppointmentStatus get status;
  @override
  BookingType get bookingType;
  @override
  bool get isConsultation;
  @override
  String get patientNameSnapshot;
  @override
  String? get patientPhoneSnapshot;
  @override
  String? get notes;
  @override
  String? get attendanceStatus;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Appointment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppointmentImplCopyWith<_$AppointmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TimeSlot {
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime get endTime => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;

  /// Create a copy of TimeSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeSlotCopyWith<TimeSlot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeSlotCopyWith<$Res> {
  factory $TimeSlotCopyWith(TimeSlot value, $Res Function(TimeSlot) then) =
      _$TimeSlotCopyWithImpl<$Res, TimeSlot>;
  @useResult
  $Res call({
    DateTime startTime,
    DateTime endTime,
    int durationMinutes,
    bool isAvailable,
  });
}

/// @nodoc
class _$TimeSlotCopyWithImpl<$Res, $Val extends TimeSlot>
    implements $TimeSlotCopyWith<$Res> {
  _$TimeSlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startTime = null,
    Object? endTime = null,
    Object? durationMinutes = null,
    Object? isAvailable = null,
  }) {
    return _then(
      _value.copyWith(
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            durationMinutes: null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            isAvailable: null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimeSlotImplCopyWith<$Res>
    implements $TimeSlotCopyWith<$Res> {
  factory _$$TimeSlotImplCopyWith(
    _$TimeSlotImpl value,
    $Res Function(_$TimeSlotImpl) then,
  ) = __$$TimeSlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime startTime,
    DateTime endTime,
    int durationMinutes,
    bool isAvailable,
  });
}

/// @nodoc
class __$$TimeSlotImplCopyWithImpl<$Res>
    extends _$TimeSlotCopyWithImpl<$Res, _$TimeSlotImpl>
    implements _$$TimeSlotImplCopyWith<$Res> {
  __$$TimeSlotImplCopyWithImpl(
    _$TimeSlotImpl _value,
    $Res Function(_$TimeSlotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimeSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startTime = null,
    Object? endTime = null,
    Object? durationMinutes = null,
    Object? isAvailable = null,
  }) {
    return _then(
      _$TimeSlotImpl(
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        durationMinutes: null == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        isAvailable: null == isAvailable
            ? _value.isAvailable
            : isAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$TimeSlotImpl implements _TimeSlot {
  const _$TimeSlotImpl({
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.isAvailable = false,
  });

  @override
  final DateTime startTime;
  @override
  final DateTime endTime;
  @override
  final int durationMinutes;
  @override
  @JsonKey()
  final bool isAvailable;

  @override
  String toString() {
    return 'TimeSlot(startTime: $startTime, endTime: $endTime, durationMinutes: $durationMinutes, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeSlotImpl &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    startTime,
    endTime,
    durationMinutes,
    isAvailable,
  );

  /// Create a copy of TimeSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeSlotImplCopyWith<_$TimeSlotImpl> get copyWith =>
      __$$TimeSlotImplCopyWithImpl<_$TimeSlotImpl>(this, _$identity);
}

abstract class _TimeSlot implements TimeSlot {
  const factory _TimeSlot({
    required final DateTime startTime,
    required final DateTime endTime,
    required final int durationMinutes,
    final bool isAvailable,
  }) = _$TimeSlotImpl;

  @override
  DateTime get startTime;
  @override
  DateTime get endTime;
  @override
  int get durationMinutes;
  @override
  bool get isAvailable;

  /// Create a copy of TimeSlot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeSlotImplCopyWith<_$TimeSlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CreateAppointmentParams {
  String get doctorId => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  String get patientName => throw _privateConstructorUsedError;
  String? get patientPhone => throw _privateConstructorUsedError;
  bool get isConsultation => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Create a copy of CreateAppointmentParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateAppointmentParamsCopyWith<CreateAppointmentParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateAppointmentParamsCopyWith<$Res> {
  factory $CreateAppointmentParamsCopyWith(
    CreateAppointmentParams value,
    $Res Function(CreateAppointmentParams) then,
  ) = _$CreateAppointmentParamsCopyWithImpl<$Res, CreateAppointmentParams>;
  @useResult
  $Res call({
    String doctorId,
    String patientId,
    DateTime scheduledAt,
    int duration,
    String patientName,
    String? patientPhone,
    bool isConsultation,
    String? notes,
  });
}

/// @nodoc
class _$CreateAppointmentParamsCopyWithImpl<
  $Res,
  $Val extends CreateAppointmentParams
>
    implements $CreateAppointmentParamsCopyWith<$Res> {
  _$CreateAppointmentParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateAppointmentParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? doctorId = null,
    Object? patientId = null,
    Object? scheduledAt = null,
    Object? duration = null,
    Object? patientName = null,
    Object? patientPhone = freezed,
    Object? isConsultation = null,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            doctorId: null == doctorId
                ? _value.doctorId
                : doctorId // ignore: cast_nullable_to_non_nullable
                      as String,
            patientId: null == patientId
                ? _value.patientId
                : patientId // ignore: cast_nullable_to_non_nullable
                      as String,
            scheduledAt: null == scheduledAt
                ? _value.scheduledAt
                : scheduledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int,
            patientName: null == patientName
                ? _value.patientName
                : patientName // ignore: cast_nullable_to_non_nullable
                      as String,
            patientPhone: freezed == patientPhone
                ? _value.patientPhone
                : patientPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            isConsultation: null == isConsultation
                ? _value.isConsultation
                : isConsultation // ignore: cast_nullable_to_non_nullable
                      as bool,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateAppointmentParamsImplCopyWith<$Res>
    implements $CreateAppointmentParamsCopyWith<$Res> {
  factory _$$CreateAppointmentParamsImplCopyWith(
    _$CreateAppointmentParamsImpl value,
    $Res Function(_$CreateAppointmentParamsImpl) then,
  ) = __$$CreateAppointmentParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String doctorId,
    String patientId,
    DateTime scheduledAt,
    int duration,
    String patientName,
    String? patientPhone,
    bool isConsultation,
    String? notes,
  });
}

/// @nodoc
class __$$CreateAppointmentParamsImplCopyWithImpl<$Res>
    extends
        _$CreateAppointmentParamsCopyWithImpl<
          $Res,
          _$CreateAppointmentParamsImpl
        >
    implements _$$CreateAppointmentParamsImplCopyWith<$Res> {
  __$$CreateAppointmentParamsImplCopyWithImpl(
    _$CreateAppointmentParamsImpl _value,
    $Res Function(_$CreateAppointmentParamsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateAppointmentParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? doctorId = null,
    Object? patientId = null,
    Object? scheduledAt = null,
    Object? duration = null,
    Object? patientName = null,
    Object? patientPhone = freezed,
    Object? isConsultation = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$CreateAppointmentParamsImpl(
        doctorId: null == doctorId
            ? _value.doctorId
            : doctorId // ignore: cast_nullable_to_non_nullable
                  as String,
        patientId: null == patientId
            ? _value.patientId
            : patientId // ignore: cast_nullable_to_non_nullable
                  as String,
        scheduledAt: null == scheduledAt
            ? _value.scheduledAt
            : scheduledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int,
        patientName: null == patientName
            ? _value.patientName
            : patientName // ignore: cast_nullable_to_non_nullable
                  as String,
        patientPhone: freezed == patientPhone
            ? _value.patientPhone
            : patientPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        isConsultation: null == isConsultation
            ? _value.isConsultation
            : isConsultation // ignore: cast_nullable_to_non_nullable
                  as bool,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$CreateAppointmentParamsImpl implements _CreateAppointmentParams {
  const _$CreateAppointmentParamsImpl({
    required this.doctorId,
    required this.patientId,
    required this.scheduledAt,
    required this.duration,
    required this.patientName,
    this.patientPhone,
    this.isConsultation = false,
    this.notes,
  });

  @override
  final String doctorId;
  @override
  final String patientId;
  @override
  final DateTime scheduledAt;
  @override
  final int duration;
  @override
  final String patientName;
  @override
  final String? patientPhone;
  @override
  @JsonKey()
  final bool isConsultation;
  @override
  final String? notes;

  @override
  String toString() {
    return 'CreateAppointmentParams(doctorId: $doctorId, patientId: $patientId, scheduledAt: $scheduledAt, duration: $duration, patientName: $patientName, patientPhone: $patientPhone, isConsultation: $isConsultation, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateAppointmentParamsImpl &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.patientName, patientName) ||
                other.patientName == patientName) &&
            (identical(other.patientPhone, patientPhone) ||
                other.patientPhone == patientPhone) &&
            (identical(other.isConsultation, isConsultation) ||
                other.isConsultation == isConsultation) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    doctorId,
    patientId,
    scheduledAt,
    duration,
    patientName,
    patientPhone,
    isConsultation,
    notes,
  );

  /// Create a copy of CreateAppointmentParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateAppointmentParamsImplCopyWith<_$CreateAppointmentParamsImpl>
  get copyWith =>
      __$$CreateAppointmentParamsImplCopyWithImpl<
        _$CreateAppointmentParamsImpl
      >(this, _$identity);
}

abstract class _CreateAppointmentParams implements CreateAppointmentParams {
  const factory _CreateAppointmentParams({
    required final String doctorId,
    required final String patientId,
    required final DateTime scheduledAt,
    required final int duration,
    required final String patientName,
    final String? patientPhone,
    final bool isConsultation,
    final String? notes,
  }) = _$CreateAppointmentParamsImpl;

  @override
  String get doctorId;
  @override
  String get patientId;
  @override
  DateTime get scheduledAt;
  @override
  int get duration;
  @override
  String get patientName;
  @override
  String? get patientPhone;
  @override
  bool get isConsultation;
  @override
  String? get notes;

  /// Create a copy of CreateAppointmentParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateAppointmentParamsImplCopyWith<_$CreateAppointmentParamsImpl>
  get copyWith => throw _privateConstructorUsedError;
}
