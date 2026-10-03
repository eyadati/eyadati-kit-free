// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'عياداتي';

  @override
  String get commonLoading => 'جاري التحميل...';

  @override
  String get commonError => 'خطأ';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonSearch => 'بحث';

  @override
  String get commonNoResults => 'لا توجد نتائج';

  @override
  String get commonTryAgain => 'حاول مرة أخرى';

  @override
  String get commonContinue => 'متابعة';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonNext => 'التالي';

  @override
  String get commonDone => 'تم';

  @override
  String get commonYes => 'نعم';

  @override
  String get commonNo => 'لا';

  @override
  String get commonOk => 'حسناً';

  @override
  String get commonMore => 'أخرى';

  @override
  String get validationEmailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get validationEmailInvalid => 'البريد الإلكتروني غير صالح';

  @override
  String get validationPasswordRequired => 'كلمة المرور مطلوبة';

  @override
  String get validationPasswordTooShort =>
      'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل';

  @override
  String get validationNameRequired => 'الاسم مطلوب';

  @override
  String get validationPhoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get validationConfirmPasswordRequired => 'تأكيد كلمة المرور مطلوب';

  @override
  String get validationPasswordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get authLoginTitle => 'مرحباً';

  @override
  String get authLoginSubtitle => 'سجل الدخول إلى حسابك';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authLoginButton => 'تسجيل الدخول';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authNoAccount => 'ليس لديك حساب؟ ';

  @override
  String get authSignUp => 'سجل';

  @override
  String get authRegisterTitle => 'إنشاء حساب';

  @override
  String get authRegisterSubtitle => 'انضم إلى عياداتي';

  @override
  String get authNameLabel => 'الاسم الكامل';

  @override
  String get authPhoneLabel => 'رقم الهاتف';

  @override
  String get authConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get authRegisterButton => 'سجل';

  @override
  String get authHaveAccount => 'لديك حساب؟ ';

  @override
  String get authLogIn => 'تسجيل الدخول';

  @override
  String get authForgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get authForgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني لإعادة التعيين';

  @override
  String get authResetPasswordButton => 'إعادة التعيين';

  @override
  String get authBackToLogin => 'رجوع لتسجيل الدخول';

  @override
  String get roleSelectTitle => 'من أنت؟';

  @override
  String get roleSelectSubtitle => 'اختر دورك';

  @override
  String get rolePatient => 'مريض';

  @override
  String get rolePatientDesc => 'احجز مواعيد مع الأطباء';

  @override
  String get roleDoctor => 'طبيب';

  @override
  String get roleDoctorDesc => 'إدارة جدولك ومرضاك';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navAppointments => 'المواعيد';

  @override
  String get navDoctors => 'الأطباء';

  @override
  String get navFavorites => 'المفضلة';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String patientHomeTitle(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get patientHomeSubtitle => 'كيف حالك اليوم؟';

  @override
  String get patientUpcomingAppointments => 'المواعيد القادمة';

  @override
  String get patientFindDoctor => 'ابحث عن طبيب';

  @override
  String get patientViewAll => 'عرض الكل';

  @override
  String get patientNoAppointments => 'لا توجد مواعيد قادمة';

  @override
  String get patientBookNow => 'احجز الآن';

  @override
  String get patientHomeNoAppointmentMsg => 'اضغط على الزر أدناه للبحث عن طبيب';

  @override
  String get doctorsBrowseTitle => 'جميع الأطباء';

  @override
  String get doctorsSearchPlaceholder => 'ابحث عن طبيب...';

  @override
  String get doctorsFilterSpecialty => 'التخصص';

  @override
  String get doctorsFilterAvailability => 'التوفر';

  @override
  String get searchFilterRequired => 'الرجاء اختيار مدينة أو تخصص';

  @override
  String get searchFilterCity => 'المدينة';

  @override
  String get searchFilterCityHint => 'اختر مدينة';

  @override
  String get searchFilterSpecialtyHint => 'اختر تخصصاً';

  @override
  String get doctorResultsAvailable => 'الأطباء المتاحون';

  @override
  String get doctorResultsNoFavorites => 'لم يتم العثور على مفضلات';

  @override
  String get doctorResultsAddFavorites => 'أضف أطباء إلى مفضلاتك لرؤيتهم هنا';

  @override
  String get doctorResultsTryOther => 'جرب معايير أخرى';

  @override
  String get doctorsNoResults => 'لم يتم العثور على أطباء';

  @override
  String get doctorsViewProfile => 'عرض الملف';

  @override
  String get doctorsBookAppointment => 'احجز موعد';

  @override
  String get doctorDetailsTitle => 'ملف الطبيب';

  @override
  String get doctorDetailsAbout => 'عن الطبيب';

  @override
  String get doctorDetailsSpecialties => 'التخصصات';

  @override
  String get doctorDetailsExperience => 'الخبرة';

  @override
  String get doctorDetailsEducation => 'التعليم';

  @override
  String get doctorDetailsWorkingHours => 'ساعات العمل';

  @override
  String get doctorDetailsReviews => 'التقييمات';

  @override
  String get doctorDetailsInfo => 'المعلومات';

  @override
  String get doctorDetailsCity => 'المدينة';

  @override
  String get doctorDetailsBookNow => 'احجز الآن';

  @override
  String get doctorDetailsAddFavorite => 'إضافة للمفضلة';

  @override
  String get doctorDetailsRemoveFavorite => 'إزالة من المفضلة';

  @override
  String get bookingSelectDate => 'اختر التاريخ';

  @override
  String get bookingSelectTime => 'اختر الوقت';

  @override
  String get bookingAppointmentType => 'نوع الموعد';

  @override
  String get bookingConsultation => 'استشارة';

  @override
  String get bookingRegularVisit => 'زيارة منتظمة';

  @override
  String get bookingFollowUp => 'متابعة';

  @override
  String get bookingCheckUp => 'فحص صحي';

  @override
  String get bookingConfirmDetails => 'تأكيد التفاصيل';

  @override
  String get bookingSuccess => 'تم تأكيد الموعد!';

  @override
  String get bookingSuccessMessage => 'تم تسجيل موعدك بنجاح';

  @override
  String get bookingAddNotes => 'ملاحظات (اختياري)';

  @override
  String get bookingConfirmButton => 'تأكيد الموعد';

  @override
  String get bookingSelectSlot => 'اختر موعداً';

  @override
  String get bookingToday => 'اليوم';

  @override
  String get bookingNotesHint => 'أضف ملاحظات للطبيب...';

  @override
  String get bookingNoSlotsToday =>
      'لا توجد مواعيد متاحة اليوم (الحد الأدنى 30 دقيقة)';

  @override
  String get bookingNoSlotsDate => 'لا توجد مواعيد متاحة لهذا التاريخ';

  @override
  String get bookingUnavailableTitle => 'الحجز غير متاح لك';

  @override
  String get bookingUnavailableMessage =>
      'نسبة الموثوقية لديك منخفضة جداً. اتصل بالعيادة للحجز.';

  @override
  String get bookingCallOffice => 'اتصل بالعيادة';

  @override
  String get bookingPhoneUnavailable => 'رقم الهاتف غير متاح';

  @override
  String get bookingSelectTimeError => 'الرجاء اختيار وقت';

  @override
  String get bookingUserNotConnectedError => 'خطأ: المستخدم غير متصل';

  @override
  String get bookingSlotUnavailable => 'هذا الموعد غير متاح';

  @override
  String bookingError(String error) {
    return 'خطأ: $error';
  }

  @override
  String get bookingSuccessViewButton => 'عرض مواعيدي';

  @override
  String get bookingLoading => 'جاري...';

  @override
  String bookingWarningMessage(int count) {
    return 'تنبيه: لديك $count غيابات غير مبررة. بعد 3 غيابات، لن تتمكن من الحجز عبر الإنترنت.';
  }

  @override
  String bookingReliabilityLabel(int pct, String label) {
    return 'الموثوقية: $pct% ($label)';
  }

  @override
  String get bookingSelectDateError => 'الرجاء تحديد التاريخ والوقت';

  @override
  String bookingSuccessWithDoctor(String doctorName) {
    return 'تم تسجيل موعدك مع $doctorName بنجاح';
  }

  @override
  String get bookingBackHome => 'العودة إلى الرئيسية';

  @override
  String get bookingNoSlotsAvailable => 'لا توجد مواعيد متاحة';

  @override
  String get bookingSelectDateHint => 'اختر تاريخاً لعرض الأوقات المتاحة';

  @override
  String get attendanceGood => 'جيد';

  @override
  String get attendanceAverage => 'متوسط';

  @override
  String get attendanceLow => 'ضعيف';

  @override
  String get appointmentsMyAppointments => 'مواعيدي';

  @override
  String get appointmentsUpcoming => 'قادمة';

  @override
  String get appointmentsPast => 'سابقة';

  @override
  String get appointmentsCancelled => 'ملغاة';

  @override
  String get appointmentsNoUpcoming => 'لا توجد مواعيد قادمة';

  @override
  String get appointmentsNoPast => 'لا توجد مواعيد سابقة';

  @override
  String get appointmentsNoCancelled => 'لا توجد مواعيد ملغاة';

  @override
  String get appointmentsCancel => 'إلغاء';

  @override
  String get appointmentsReschedule => 'إعادة جدولة';

  @override
  String get appointmentsDetails => 'التفاصيل';

  @override
  String get appointmentsStatusPending => 'قيد الانتظار';

  @override
  String get appointmentsStatusConfirmed => 'مؤكد';

  @override
  String get appointmentsStatusCompleted => 'مكتمل';

  @override
  String get appointmentsStatusCancelled => 'ملغى';

  @override
  String appointmentsWithDoctor(String name) {
    return 'مع د. $name';
  }

  @override
  String get cancelAppointmentConfirm =>
      'هل أنت متأكد أنك تريد إلغاء هذا الموعد؟';

  @override
  String get cancelConfirmYes => 'نعم، إلغاء';

  @override
  String get appointmentCancelled => 'تم إلغاء الموعد';

  @override
  String get cancelAppointmentError => 'خطأ أثناء الإلغاء';

  @override
  String get clipboardCopied => 'تم نسخ الرقم';

  @override
  String get favoritesTitle => 'مفضلاتي';

  @override
  String get favoritesEmpty => 'لا توجد مفضلات';

  @override
  String get favoritesEmptyMessage => 'أضف أطباء إلى مفضلاتك';

  @override
  String get favoritesBrowseDoctors => 'تصفح الأطباء';

  @override
  String get profileTitle => 'ملفي الشخصي';

  @override
  String get profileEditProfile => 'تعديل الملف';

  @override
  String get profileAccountSettings => 'الحساب';

  @override
  String get profileNotifications => 'الإشعارات';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get profileLogout => 'تسجيل الخروج';

  @override
  String get profileDeleteAccount => 'حذف الحساب';

  @override
  String get profileName => 'الاسم';

  @override
  String get profileEmail => 'البريد الإلكتروني';

  @override
  String get profilePhone => 'الهاتف';

  @override
  String get profileDateOfBirth => 'تاريخ الميلاد';

  @override
  String get profilePersonalInfo => 'المعلومات الشخصية';

  @override
  String get profileNameHint => 'أدخل اسمك';

  @override
  String get profileCity => 'المدينة';

  @override
  String get profileCityHint => 'اختر مدينتك';

  @override
  String get profileUpdateSuccess => 'تم تحديث الملف الشخصي';

  @override
  String get profileUpdateError => 'خطأ أثناء التحديث';

  @override
  String get doctorDashboardTitle => 'لوحة التحكم';

  @override
  String get doctorDashboardToday => 'اليوم';

  @override
  String get doctorDashboardUpcomingAppointments => 'المواعيد القادمة';

  @override
  String get doctorDashboardStats => 'الإحصائيات';

  @override
  String get doctorDashboardTodayAppointments => 'مواعيد اليوم';

  @override
  String get doctorDashboardPatients => 'المرضى';

  @override
  String get doctorDashboardThisWeek => 'هذا الأسبوع';

  @override
  String get doctorDashboardEarnings => 'الأرباح';

  @override
  String get doctorDashboardNoAppointments => 'لا توجد مواعيد اليوم';

  @override
  String get doctorDashboardViewSchedule => 'عرض الجدول';

  @override
  String get doctorScheduleTitle => 'الجدول';

  @override
  String get doctorScheduleManageAvailability => 'إدارة التوفر';

  @override
  String get doctorScheduleAddSlot => 'إضافة موعد';

  @override
  String get doctorScheduleEditSlot => 'تعديل الموعد';

  @override
  String get doctorScheduleDeleteSlot => 'حذف الموعد';

  @override
  String get doctorScheduleWorkingDays => 'أيام العمل';

  @override
  String get doctorScheduleWorkingHours => 'ساعات العمل';

  @override
  String get doctorScheduleTimeSlots => 'الأوقات المتاحة';

  @override
  String get doctorAppointmentsTitle => 'المواعيد';

  @override
  String get doctorAppointmentsPending => 'قيد الانتظار';

  @override
  String get doctorAppointmentsConfirmed => 'مؤكدة';

  @override
  String get doctorAppointmentsAll => 'الكل';

  @override
  String get doctorAppointmentsToday => 'اليوم';

  @override
  String get doctorAppointmentsThisWeek => 'هذا الأسبوع';

  @override
  String get doctorAppointmentsViewPatient => 'عرض المريض';

  @override
  String get doctorAppointmentsMarkComplete => 'وضع كـ مكتمل';

  @override
  String get doctorAppointmentsCancelAppointment => 'إلغاء الموعد';

  @override
  String get doctorProfileTitle => 'ملفي الشخصي';

  @override
  String get doctorProfileSpecialties => 'التخصصات';

  @override
  String get doctorProfileExperience => 'سنوات الخبرة';

  @override
  String get doctorProfileEducation => 'التعليم';

  @override
  String get doctorProfileAbout => 'عن الطبيب';

  @override
  String get doctorProfileConsultationFee => 'رسوم الاستشارة';

  @override
  String get doctorProfileEditProfile => 'تعديل الملف';

  @override
  String get subscriptionTitle => 'الاشتراك';

  @override
  String get subscriptionCurrentPlan => 'الباقة الحالية';

  @override
  String get subscriptionUpgrade => 'ترقية';

  @override
  String get subscriptionRenew => 'تجديد';

  @override
  String get subscriptionCancel => 'إلغاء الاشتراك';

  @override
  String get subscriptionBillingHistory => 'سجل الفواتير';

  @override
  String get subscriptionPaymentMethod => 'طريقة الدفع';

  @override
  String get subscriptionFree => 'مجاني';

  @override
  String get subscriptionBasic => 'أساسي';

  @override
  String get subscriptionPro => 'احترافي';

  @override
  String get subscriptionUnlimitedAppointments => 'مواعيد غير محدودة';

  @override
  String get subscriptionPrioritySupport => 'دعم أولوي';

  @override
  String get errorsGenericError => 'حدث خطأ';

  @override
  String get errorsNetworkError => 'خطأ في الاتصال';

  @override
  String get errorsServerError => 'خطأ في الخادم';

  @override
  String get errorsUnauthorized => 'غير مصرح';

  @override
  String get errorsNotFound => 'غير موجود';

  @override
  String get errorsTryAgainLater => 'حاول مرة أخرى لاحقاً';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusConfirmed => 'مؤكد';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get daysMonday => 'الإثنين';

  @override
  String get daysTuesday => 'الثلاثاء';

  @override
  String get daysWednesday => 'الأربعاء';

  @override
  String get daysThursday => 'الخميس';

  @override
  String get daysFriday => 'الجمعة';

  @override
  String get daysSaturday => 'السبت';

  @override
  String get daysSunday => 'الأحد';

  @override
  String get daysShortMon => 'إث';

  @override
  String get daysShortTue => 'ث';

  @override
  String get daysShortWed => 'أر';

  @override
  String get daysShortThu => 'خ';

  @override
  String get daysShortFri => 'ج';

  @override
  String get daysShortSat => 'س';

  @override
  String get daysShortSun => 'أحد';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsAccount => 'الحساب';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsPrivacy => 'الخصوصية';

  @override
  String get settingsAbout => 'حول';

  @override
  String get settingsLogoutConfirm => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get settingsVersion => 'الإصدار';

  @override
  String get settingsPreferences => 'التفضيلات';

  @override
  String get settingsNotificationsEnabled => 'مفعلة';

  @override
  String get wrongPassword => 'كلمة المرور غير صحيحة';

  @override
  String get confirmPasswordTitle => 'تأكيد كلمة المرور';

  @override
  String get deleteAccountConfirmMessage =>
      'هذا الإجراء لا رجعة فيه. جميع بياناتك (المواعيد، المفضلة) سيتم حذفها نهائياً.';

  @override
  String get enterPasswordHint => 'أدخل كلمة المرور';

  @override
  String get logoutConfirmMessage => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get installBannerTitle => 'تثبيت عياداتي';

  @override
  String get installBannerSubtitle => 'أضف عياداتي إلى شاشتك الرئيسية';

  @override
  String get installBannerButton => 'تثبيت';

  @override
  String get timeMorning => 'صباحاً';

  @override
  String get timeAfternoon => 'مساءً';

  @override
  String get timeEvening => 'ليلاً';

  @override
  String get bookingBookOnline => 'احجز عبر الإنترنت';
}
