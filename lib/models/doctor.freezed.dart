// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'doctor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Doctor _$DoctorFromJson(Map<String, dynamic> json) {
  return _Doctor.fromJson(json);
}

/// @nodoc
mixin _$Doctor {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get specialty => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get mapsLink => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  int get appointmentDuration => throw _privateConstructorUsedError;
  int get consultationDuration => throw _privateConstructorUsedError;
  bool get manualPause => throw _privateConstructorUsedError;
  bool get isTest => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  DateTime? get subscriptionEnd => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Doctor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Doctor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DoctorCopyWith<Doctor> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DoctorCopyWith<$Res> {
  factory $DoctorCopyWith(Doctor value, $Res Function(Doctor) then) =
      _$DoctorCopyWithImpl<$Res, Doctor>;
  @useResult
  $Res call({
    String id,
    String name,
    String specialty,
    String address,
    String? city,
    String? mapsLink,
    double? latitude,
    double? longitude,
    String? bio,
    String? photoUrl,
    int appointmentDuration,
    int consultationDuration,
    bool manualPause,
    bool isTest,
    String? phone,
    DateTime? subscriptionEnd,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$DoctorCopyWithImpl<$Res, $Val extends Doctor>
    implements $DoctorCopyWith<$Res> {
  _$DoctorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Doctor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? specialty = null,
    Object? address = null,
    Object? city = freezed,
    Object? mapsLink = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? bio = freezed,
    Object? photoUrl = freezed,
    Object? appointmentDuration = null,
    Object? consultationDuration = null,
    Object? manualPause = null,
    Object? isTest = null,
    Object? phone = freezed,
    Object? subscriptionEnd = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            specialty: null == specialty
                ? _value.specialty
                : specialty // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            city: freezed == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String?,
            mapsLink: freezed == mapsLink
                ? _value.mapsLink
                : mapsLink // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            bio: freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            appointmentDuration: null == appointmentDuration
                ? _value.appointmentDuration
                : appointmentDuration // ignore: cast_nullable_to_non_nullable
                      as int,
            consultationDuration: null == consultationDuration
                ? _value.consultationDuration
                : consultationDuration // ignore: cast_nullable_to_non_nullable
                      as int,
            manualPause: null == manualPause
                ? _value.manualPause
                : manualPause // ignore: cast_nullable_to_non_nullable
                      as bool,
            isTest: null == isTest
                ? _value.isTest
                : isTest // ignore: cast_nullable_to_non_nullable
                      as bool,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            subscriptionEnd: freezed == subscriptionEnd
                ? _value.subscriptionEnd
                : subscriptionEnd // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DoctorImplCopyWith<$Res> implements $DoctorCopyWith<$Res> {
  factory _$$DoctorImplCopyWith(
    _$DoctorImpl value,
    $Res Function(_$DoctorImpl) then,
  ) = __$$DoctorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String specialty,
    String address,
    String? city,
    String? mapsLink,
    double? latitude,
    double? longitude,
    String? bio,
    String? photoUrl,
    int appointmentDuration,
    int consultationDuration,
    bool manualPause,
    bool isTest,
    String? phone,
    DateTime? subscriptionEnd,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$DoctorImplCopyWithImpl<$Res>
    extends _$DoctorCopyWithImpl<$Res, _$DoctorImpl>
    implements _$$DoctorImplCopyWith<$Res> {
  __$$DoctorImplCopyWithImpl(
    _$DoctorImpl _value,
    $Res Function(_$DoctorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Doctor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? specialty = null,
    Object? address = null,
    Object? city = freezed,
    Object? mapsLink = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? bio = freezed,
    Object? photoUrl = freezed,
    Object? appointmentDuration = null,
    Object? consultationDuration = null,
    Object? manualPause = null,
    Object? isTest = null,
    Object? phone = freezed,
    Object? subscriptionEnd = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$DoctorImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        specialty: null == specialty
            ? _value.specialty
            : specialty // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        city: freezed == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String?,
        mapsLink: freezed == mapsLink
            ? _value.mapsLink
            : mapsLink // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        bio: freezed == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        appointmentDuration: null == appointmentDuration
            ? _value.appointmentDuration
            : appointmentDuration // ignore: cast_nullable_to_non_nullable
                  as int,
        consultationDuration: null == consultationDuration
            ? _value.consultationDuration
            : consultationDuration // ignore: cast_nullable_to_non_nullable
                  as int,
        manualPause: null == manualPause
            ? _value.manualPause
            : manualPause // ignore: cast_nullable_to_non_nullable
                  as bool,
        isTest: null == isTest
            ? _value.isTest
            : isTest // ignore: cast_nullable_to_non_nullable
                  as bool,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        subscriptionEnd: freezed == subscriptionEnd
            ? _value.subscriptionEnd
            : subscriptionEnd // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DoctorImpl implements _Doctor {
  const _$DoctorImpl({
    required this.id,
    required this.name,
    required this.specialty,
    required this.address,
    this.city,
    this.mapsLink,
    this.latitude,
    this.longitude,
    this.bio,
    this.photoUrl,
    this.appointmentDuration = 20,
    this.consultationDuration = 40,
    this.manualPause = false,
    this.isTest = false,
    this.phone,
    this.subscriptionEnd,
    this.createdAt,
  });

  factory _$DoctorImpl.fromJson(Map<String, dynamic> json) =>
      _$$DoctorImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String specialty;
  @override
  final String address;
  @override
  final String? city;
  @override
  final String? mapsLink;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? bio;
  @override
  final String? photoUrl;
  @override
  @JsonKey()
  final int appointmentDuration;
  @override
  @JsonKey()
  final int consultationDuration;
  @override
  @JsonKey()
  final bool manualPause;
  @override
  @JsonKey()
  final bool isTest;
  @override
  final String? phone;
  @override
  final DateTime? subscriptionEnd;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Doctor(id: $id, name: $name, specialty: $specialty, address: $address, city: $city, mapsLink: $mapsLink, latitude: $latitude, longitude: $longitude, bio: $bio, photoUrl: $photoUrl, appointmentDuration: $appointmentDuration, consultationDuration: $consultationDuration, manualPause: $manualPause, isTest: $isTest, phone: $phone, subscriptionEnd: $subscriptionEnd, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DoctorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.specialty, specialty) ||
                other.specialty == specialty) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.mapsLink, mapsLink) ||
                other.mapsLink == mapsLink) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.appointmentDuration, appointmentDuration) ||
                other.appointmentDuration == appointmentDuration) &&
            (identical(other.consultationDuration, consultationDuration) ||
                other.consultationDuration == consultationDuration) &&
            (identical(other.manualPause, manualPause) ||
                other.manualPause == manualPause) &&
            (identical(other.isTest, isTest) || other.isTest == isTest) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.subscriptionEnd, subscriptionEnd) ||
                other.subscriptionEnd == subscriptionEnd) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    specialty,
    address,
    city,
    mapsLink,
    latitude,
    longitude,
    bio,
    photoUrl,
    appointmentDuration,
    consultationDuration,
    manualPause,
    isTest,
    phone,
    subscriptionEnd,
    createdAt,
  );

  /// Create a copy of Doctor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DoctorImplCopyWith<_$DoctorImpl> get copyWith =>
      __$$DoctorImplCopyWithImpl<_$DoctorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DoctorImplToJson(this);
  }
}

abstract class _Doctor implements Doctor {
  const factory _Doctor({
    required final String id,
    required final String name,
    required final String specialty,
    required final String address,
    final String? city,
    final String? mapsLink,
    final double? latitude,
    final double? longitude,
    final String? bio,
    final String? photoUrl,
    final int appointmentDuration,
    final int consultationDuration,
    final bool manualPause,
    final bool isTest,
    final String? phone,
    final DateTime? subscriptionEnd,
    final DateTime? createdAt,
  }) = _$DoctorImpl;

  factory _Doctor.fromJson(Map<String, dynamic> json) = _$DoctorImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get specialty;
  @override
  String get address;
  @override
  String? get city;
  @override
  String? get mapsLink;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String? get bio;
  @override
  String? get photoUrl;
  @override
  int get appointmentDuration;
  @override
  int get consultationDuration;
  @override
  bool get manualPause;
  @override
  bool get isTest;
  @override
  String? get phone;
  @override
  DateTime? get subscriptionEnd;
  @override
  DateTime? get createdAt;

  /// Create a copy of Doctor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DoctorImplCopyWith<_$DoctorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DoctorWithProfile {
  Doctor get doctor => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// Create a copy of DoctorWithProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DoctorWithProfileCopyWith<DoctorWithProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DoctorWithProfileCopyWith<$Res> {
  factory $DoctorWithProfileCopyWith(
    DoctorWithProfile value,
    $Res Function(DoctorWithProfile) then,
  ) = _$DoctorWithProfileCopyWithImpl<$Res, DoctorWithProfile>;
  @useResult
  $Res call({Doctor doctor, String fullName, String? avatarUrl});

  $DoctorCopyWith<$Res> get doctor;
}

/// @nodoc
class _$DoctorWithProfileCopyWithImpl<$Res, $Val extends DoctorWithProfile>
    implements $DoctorWithProfileCopyWith<$Res> {
  _$DoctorWithProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DoctorWithProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? doctor = null,
    Object? fullName = null,
    Object? avatarUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            doctor: null == doctor
                ? _value.doctor
                : doctor // ignore: cast_nullable_to_non_nullable
                      as Doctor,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of DoctorWithProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DoctorCopyWith<$Res> get doctor {
    return $DoctorCopyWith<$Res>(_value.doctor, (value) {
      return _then(_value.copyWith(doctor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DoctorWithProfileImplCopyWith<$Res>
    implements $DoctorWithProfileCopyWith<$Res> {
  factory _$$DoctorWithProfileImplCopyWith(
    _$DoctorWithProfileImpl value,
    $Res Function(_$DoctorWithProfileImpl) then,
  ) = __$$DoctorWithProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Doctor doctor, String fullName, String? avatarUrl});

  @override
  $DoctorCopyWith<$Res> get doctor;
}

/// @nodoc
class __$$DoctorWithProfileImplCopyWithImpl<$Res>
    extends _$DoctorWithProfileCopyWithImpl<$Res, _$DoctorWithProfileImpl>
    implements _$$DoctorWithProfileImplCopyWith<$Res> {
  __$$DoctorWithProfileImplCopyWithImpl(
    _$DoctorWithProfileImpl _value,
    $Res Function(_$DoctorWithProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DoctorWithProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? doctor = null,
    Object? fullName = null,
    Object? avatarUrl = freezed,
  }) {
    return _then(
      _$DoctorWithProfileImpl(
        doctor: null == doctor
            ? _value.doctor
            : doctor // ignore: cast_nullable_to_non_nullable
                  as Doctor,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$DoctorWithProfileImpl implements _DoctorWithProfile {
  const _$DoctorWithProfileImpl({
    required this.doctor,
    required this.fullName,
    this.avatarUrl,
  });

  @override
  final Doctor doctor;
  @override
  final String fullName;
  @override
  final String? avatarUrl;

  @override
  String toString() {
    return 'DoctorWithProfile(doctor: $doctor, fullName: $fullName, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DoctorWithProfileImpl &&
            (identical(other.doctor, doctor) || other.doctor == doctor) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, doctor, fullName, avatarUrl);

  /// Create a copy of DoctorWithProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DoctorWithProfileImplCopyWith<_$DoctorWithProfileImpl> get copyWith =>
      __$$DoctorWithProfileImplCopyWithImpl<_$DoctorWithProfileImpl>(
        this,
        _$identity,
      );
}

abstract class _DoctorWithProfile implements DoctorWithProfile {
  const factory _DoctorWithProfile({
    required final Doctor doctor,
    required final String fullName,
    final String? avatarUrl,
  }) = _$DoctorWithProfileImpl;

  @override
  Doctor get doctor;
  @override
  String get fullName;
  @override
  String? get avatarUrl;

  /// Create a copy of DoctorWithProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DoctorWithProfileImplCopyWith<_$DoctorWithProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
