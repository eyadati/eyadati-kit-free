import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'Eyadati'**
  String get appName;

  /// No description provided for @commonLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get commonError;

  /// No description provided for @commonRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonRetry;

  /// No description provided for @commonSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get commonConfirm;

  /// No description provided for @commonDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get commonEdit;

  /// No description provided for @commonClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;

  /// No description provided for @commonSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get commonSearch;

  /// No description provided for @commonNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get commonNoResults;

  /// No description provided for @commonTryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonTryAgain;

  /// No description provided for @commonContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get commonContinue;

  /// No description provided for @commonBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get commonNext;

  /// No description provided for @commonDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get commonDone;

  /// No description provided for @commonYes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get commonNo;

  /// No description provided for @commonOk.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonMore.
  ///
  /// In fr, this message translates to:
  /// **'autres'**
  String get commonMore;

  /// No description provided for @validationEmailRequired.
  ///
  /// In fr, this message translates to:
  /// **'Email requis'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe requis'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 8 caractères'**
  String get validationPasswordTooShort;

  /// No description provided for @validationNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Nom requis'**
  String get validationNameRequired;

  /// No description provided for @validationPhoneRequired.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone requis'**
  String get validationPhoneRequired;

  /// No description provided for @validationConfirmPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe requis'**
  String get validationConfirmPasswordRequired;

  /// No description provided for @validationPasswordsDoNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get validationPasswordsDoNotMatch;

  /// No description provided for @authLoginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous à votre compte'**
  String get authLoginSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get authPasswordLabel;

  /// No description provided for @authLoginButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authLoginButton;

  /// No description provided for @authForgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get authForgotPassword;

  /// No description provided for @authNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas de compte ? '**
  String get authNoAccount;

  /// No description provided for @authSignUp.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get authSignUp;

  /// No description provided for @authRegisterTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez Eyadati'**
  String get authRegisterSubtitle;

  /// No description provided for @authNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get authNameLabel;

  /// No description provided for @authPhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get authPhoneLabel;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authRegisterButton.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get authRegisterButton;

  /// No description provided for @authHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà un compte ? '**
  String get authHaveAccount;

  /// No description provided for @authLogIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authLogIn;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre email pour réinitialiser'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authResetPasswordButton.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get authResetPasswordButton;

  /// No description provided for @authBackToLogin.
  ///
  /// In fr, this message translates to:
  /// **'Retour à la connexion'**
  String get authBackToLogin;

  /// No description provided for @roleSelectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Qui êtes-vous ?'**
  String get roleSelectTitle;

  /// No description provided for @roleSelectSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre rôle'**
  String get roleSelectSubtitle;

  /// No description provided for @rolePatient.
  ///
  /// In fr, this message translates to:
  /// **'Patient'**
  String get rolePatient;

  /// No description provided for @rolePatientDesc.
  ///
  /// In fr, this message translates to:
  /// **'Prenez des rendez-vous avec des médecins'**
  String get rolePatientDesc;

  /// No description provided for @roleDoctor.
  ///
  /// In fr, this message translates to:
  /// **'Docteur'**
  String get roleDoctor;

  /// No description provided for @roleDoctorDesc.
  ///
  /// In fr, this message translates to:
  /// **'Gérez votre calendrier et vos patients'**
  String get roleDoctorDesc;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navAppointments.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous'**
  String get navAppointments;

  /// No description provided for @navDoctors.
  ///
  /// In fr, this message translates to:
  /// **'Docteurs'**
  String get navDoctors;

  /// No description provided for @navFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get navFavorites;

  /// No description provided for @navProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get navSettings;

  /// No description provided for @patientHomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour, {name}'**
  String patientHomeTitle(String name);

  /// No description provided for @patientHomeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Comment allez-vous aujourd\'hui ?'**
  String get patientHomeSubtitle;

  /// No description provided for @patientUpcomingAppointments.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous à venir'**
  String get patientUpcomingAppointments;

  /// No description provided for @patientFindDoctor.
  ///
  /// In fr, this message translates to:
  /// **'Trouver un médecin'**
  String get patientFindDoctor;

  /// No description provided for @patientViewAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get patientViewAll;

  /// No description provided for @patientNoAppointments.
  ///
  /// In fr, this message translates to:
  /// **'Aucun rendez-vous à venir'**
  String get patientNoAppointments;

  /// No description provided for @patientBookNow.
  ///
  /// In fr, this message translates to:
  /// **'Réserver maintenant'**
  String get patientBookNow;

  /// No description provided for @patientHomeNoAppointmentMsg.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur le bouton ci-dessous pour trouver un médecin'**
  String get patientHomeNoAppointmentMsg;

  /// No description provided for @doctorsBrowseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tous les médecins'**
  String get doctorsBrowseTitle;

  /// No description provided for @doctorsSearchPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un médecin...'**
  String get doctorsSearchPlaceholder;

  /// No description provided for @doctorsFilterSpecialty.
  ///
  /// In fr, this message translates to:
  /// **'Spécialité'**
  String get doctorsFilterSpecialty;

  /// No description provided for @doctorsFilterAvailability.
  ///
  /// In fr, this message translates to:
  /// **'Disponibilité'**
  String get doctorsFilterAvailability;

  /// No description provided for @searchFilterRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner une ville ou une spécialité'**
  String get searchFilterRequired;

  /// No description provided for @searchFilterCity.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get searchFilterCity;

  /// No description provided for @searchFilterCityHint.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une ville'**
  String get searchFilterCityHint;

  /// No description provided for @searchFilterSpecialtyHint.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une spécialité'**
  String get searchFilterSpecialtyHint;

  /// No description provided for @doctorResultsAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Médecins disponibles'**
  String get doctorResultsAvailable;

  /// No description provided for @doctorResultsNoFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Aucun favori trouvé'**
  String get doctorResultsNoFavorites;

  /// No description provided for @doctorResultsAddFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez des favoris pour les voir ici'**
  String get doctorResultsAddFavorites;

  /// No description provided for @doctorResultsTryOther.
  ///
  /// In fr, this message translates to:
  /// **'Essayez avec d\'autres critères'**
  String get doctorResultsTryOther;

  /// No description provided for @doctorsNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun médecin trouvé'**
  String get doctorsNoResults;

  /// No description provided for @doctorsViewProfile.
  ///
  /// In fr, this message translates to:
  /// **'Voir le profil'**
  String get doctorsViewProfile;

  /// No description provided for @doctorsBookAppointment.
  ///
  /// In fr, this message translates to:
  /// **'Prendre rendez-vous'**
  String get doctorsBookAppointment;

  /// No description provided for @doctorDetailsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil du médecin'**
  String get doctorDetailsTitle;

  /// No description provided for @doctorDetailsAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get doctorDetailsAbout;

  /// No description provided for @doctorDetailsSpecialties.
  ///
  /// In fr, this message translates to:
  /// **'Spécialités'**
  String get doctorDetailsSpecialties;

  /// No description provided for @doctorDetailsExperience.
  ///
  /// In fr, this message translates to:
  /// **'Expérience'**
  String get doctorDetailsExperience;

  /// No description provided for @doctorDetailsEducation.
  ///
  /// In fr, this message translates to:
  /// **'Formation'**
  String get doctorDetailsEducation;

  /// No description provided for @doctorDetailsWorkingHours.
  ///
  /// In fr, this message translates to:
  /// **'Heures de travail'**
  String get doctorDetailsWorkingHours;

  /// No description provided for @doctorDetailsReviews.
  ///
  /// In fr, this message translates to:
  /// **'Avis'**
  String get doctorDetailsReviews;

  /// No description provided for @doctorDetailsInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get doctorDetailsInfo;

  /// No description provided for @doctorDetailsCity.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get doctorDetailsCity;

  /// No description provided for @doctorDetailsBookNow.
  ///
  /// In fr, this message translates to:
  /// **'Prendre rendez-vous'**
  String get doctorDetailsBookNow;

  /// No description provided for @doctorDetailsAddFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux favoris'**
  String get doctorDetailsAddFavorite;

  /// No description provided for @doctorDetailsRemoveFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Retirer des favoris'**
  String get doctorDetailsRemoveFavorite;

  /// No description provided for @bookingSelectDate.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une date'**
  String get bookingSelectDate;

  /// No description provided for @bookingSelectTime.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une heure'**
  String get bookingSelectTime;

  /// No description provided for @bookingAppointmentType.
  ///
  /// In fr, this message translates to:
  /// **'Type de rendez-vous'**
  String get bookingAppointmentType;

  /// No description provided for @bookingConsultation.
  ///
  /// In fr, this message translates to:
  /// **'Consultation'**
  String get bookingConsultation;

  /// No description provided for @bookingRegularVisit.
  ///
  /// In fr, this message translates to:
  /// **'Visite régulière'**
  String get bookingRegularVisit;

  /// No description provided for @bookingFollowUp.
  ///
  /// In fr, this message translates to:
  /// **'Suivi'**
  String get bookingFollowUp;

  /// No description provided for @bookingCheckUp.
  ///
  /// In fr, this message translates to:
  /// **'Bilan de santé'**
  String get bookingCheckUp;

  /// No description provided for @bookingConfirmDetails.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer les détails'**
  String get bookingConfirmDetails;

  /// No description provided for @bookingSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous confirmé !'**
  String get bookingSuccess;

  /// No description provided for @bookingSuccessMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre rendez-vous a été enregistré avec succès.'**
  String get bookingSuccessMessage;

  /// No description provided for @bookingAddNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes (optionnel)'**
  String get bookingAddNotes;

  /// No description provided for @bookingConfirmButton.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le rendez-vous'**
  String get bookingConfirmButton;

  /// No description provided for @bookingSelectSlot.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez un créneau'**
  String get bookingSelectSlot;

  /// No description provided for @bookingToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get bookingToday;

  /// No description provided for @bookingNotesHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez des notes pour le médecin...'**
  String get bookingNotesHint;

  /// No description provided for @bookingNoSlotsToday.
  ///
  /// In fr, this message translates to:
  /// **'Aucun créneau disponible aujourd\'hui (délai minimum 30min)'**
  String get bookingNoSlotsToday;

  /// No description provided for @bookingNoSlotsDate.
  ///
  /// In fr, this message translates to:
  /// **'Aucun créneau disponible pour cette date'**
  String get bookingNoSlotsDate;

  /// No description provided for @bookingUnavailableTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réservation indisponible pour vous'**
  String get bookingUnavailableTitle;

  /// No description provided for @bookingUnavailableMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre score de fiabilité est trop bas. Contactez le cabinet pour réserver.'**
  String get bookingUnavailableMessage;

  /// No description provided for @bookingCallOffice.
  ///
  /// In fr, this message translates to:
  /// **'Appeler le cabinet'**
  String get bookingCallOffice;

  /// No description provided for @bookingPhoneUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone non disponible'**
  String get bookingPhoneUnavailable;

  /// No description provided for @bookingSelectTimeError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner une heure'**
  String get bookingSelectTimeError;

  /// No description provided for @bookingUserNotConnectedError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur: utilisateur non connecté'**
  String get bookingUserNotConnectedError;

  /// No description provided for @bookingSlotUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Ce créneau n\'est plus disponible'**
  String get bookingSlotUnavailable;

  /// No description provided for @bookingError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur: {error}'**
  String bookingError(String error);

  /// No description provided for @bookingSuccessViewButton.
  ///
  /// In fr, this message translates to:
  /// **'Voir mes rendez-vous'**
  String get bookingSuccessViewButton;

  /// No description provided for @bookingLoading.
  ///
  /// In fr, this message translates to:
  /// **'En cours...'**
  String get bookingLoading;

  /// No description provided for @bookingWarningMessage.
  ///
  /// In fr, this message translates to:
  /// **'Attention : vous avez {count} absences non justifiées. Après 3 absences, vous ne pourrez plus réserver en ligne.'**
  String bookingWarningMessage(int count);

  /// No description provided for @bookingReliabilityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fiabilité : {pct}% ({label})'**
  String bookingReliabilityLabel(int pct, String label);

  /// No description provided for @bookingSelectDateError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner une date et un horaire'**
  String get bookingSelectDateError;

  /// No description provided for @bookingSuccessWithDoctor.
  ///
  /// In fr, this message translates to:
  /// **'Votre rendez-vous avec {doctorName} a été enregistré avec succès.'**
  String bookingSuccessWithDoctor(String doctorName);

  /// No description provided for @bookingBackHome.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'accueil'**
  String get bookingBackHome;

  /// No description provided for @bookingNoSlotsAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun créneau disponible'**
  String get bookingNoSlotsAvailable;

  /// No description provided for @bookingSelectDateHint.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez une date pour voir les horaires'**
  String get bookingSelectDateHint;

  /// No description provided for @attendanceGood.
  ///
  /// In fr, this message translates to:
  /// **'Bon'**
  String get attendanceGood;

  /// No description provided for @attendanceAverage.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get attendanceAverage;

  /// No description provided for @attendanceLow.
  ///
  /// In fr, this message translates to:
  /// **'Faible'**
  String get attendanceLow;

  /// No description provided for @appointmentsMyAppointments.
  ///
  /// In fr, this message translates to:
  /// **'Mes rendez-vous'**
  String get appointmentsMyAppointments;

  /// No description provided for @appointmentsUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get appointmentsUpcoming;

  /// No description provided for @appointmentsPast.
  ///
  /// In fr, this message translates to:
  /// **'Passés'**
  String get appointmentsPast;

  /// No description provided for @appointmentsCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulés'**
  String get appointmentsCancelled;

  /// No description provided for @appointmentsNoUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'Aucun rendez-vous à venir'**
  String get appointmentsNoUpcoming;

  /// No description provided for @appointmentsNoPast.
  ///
  /// In fr, this message translates to:
  /// **'Aucun rendez-vous passé'**
  String get appointmentsNoPast;

  /// No description provided for @appointmentsNoCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Aucun rendez-vous annulé'**
  String get appointmentsNoCancelled;

  /// No description provided for @appointmentsCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get appointmentsCancel;

  /// No description provided for @appointmentsReschedule.
  ///
  /// In fr, this message translates to:
  /// **'Reprogrammer'**
  String get appointmentsReschedule;

  /// No description provided for @appointmentsDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails'**
  String get appointmentsDetails;

  /// No description provided for @appointmentsStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get appointmentsStatusPending;

  /// No description provided for @appointmentsStatusConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmé'**
  String get appointmentsStatusConfirmed;

  /// No description provided for @appointmentsStatusCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get appointmentsStatusCompleted;

  /// No description provided for @appointmentsStatusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get appointmentsStatusCancelled;

  /// No description provided for @appointmentsWithDoctor.
  ///
  /// In fr, this message translates to:
  /// **'avec Dr. {name}'**
  String appointmentsWithDoctor(String name);

  /// No description provided for @cancelAppointmentConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir annuler ce rendez-vous ?'**
  String get cancelAppointmentConfirm;

  /// No description provided for @cancelConfirmYes.
  ///
  /// In fr, this message translates to:
  /// **'Oui, annuler'**
  String get cancelConfirmYes;

  /// No description provided for @appointmentCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous annulé'**
  String get appointmentCancelled;

  /// No description provided for @cancelAppointmentError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'annulation'**
  String get cancelAppointmentError;

  /// No description provided for @clipboardCopied.
  ///
  /// In fr, this message translates to:
  /// **'Numéro copié'**
  String get clipboardCopied;

  /// No description provided for @favoritesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes favoris'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun favori'**
  String get favoritesEmpty;

  /// No description provided for @favoritesEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez des médecins à vos favoris'**
  String get favoritesEmptyMessage;

  /// No description provided for @favoritesBrowseDoctors.
  ///
  /// In fr, this message translates to:
  /// **'Parcourir les médecins'**
  String get favoritesBrowseDoctors;

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get profileTitle;

  /// No description provided for @profileEditProfile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get profileEditProfile;

  /// No description provided for @profileAccountSettings.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get profileAccountSettings;

  /// No description provided for @profileNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get profileLanguage;

  /// No description provided for @profileLogout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get profileLogout;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte'**
  String get profileDeleteAccount;

  /// No description provided for @profileName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get profileName;

  /// No description provided for @profileEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profilePhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get profilePhone;

  /// No description provided for @profileDateOfBirth.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance'**
  String get profileDateOfBirth;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get profilePersonalInfo;

  /// No description provided for @profileNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre nom'**
  String get profileNameHint;

  /// No description provided for @profileCity.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get profileCity;

  /// No description provided for @profileCityHint.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez votre ville'**
  String get profileCityHint;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour'**
  String get profileUpdateSuccess;

  /// No description provided for @profileUpdateError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la mise à jour'**
  String get profileUpdateError;

  /// No description provided for @doctorDashboardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get doctorDashboardTitle;

  /// No description provided for @doctorDashboardToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get doctorDashboardToday;

  /// No description provided for @doctorDashboardUpcomingAppointments.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous à venir'**
  String get doctorDashboardUpcomingAppointments;

  /// No description provided for @doctorDashboardStats.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get doctorDashboardStats;

  /// No description provided for @doctorDashboardTodayAppointments.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous du jour'**
  String get doctorDashboardTodayAppointments;

  /// No description provided for @doctorDashboardPatients.
  ///
  /// In fr, this message translates to:
  /// **'Patients'**
  String get doctorDashboardPatients;

  /// No description provided for @doctorDashboardThisWeek.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get doctorDashboardThisWeek;

  /// No description provided for @doctorDashboardEarnings.
  ///
  /// In fr, this message translates to:
  /// **'Revenus'**
  String get doctorDashboardEarnings;

  /// No description provided for @doctorDashboardNoAppointments.
  ///
  /// In fr, this message translates to:
  /// **'Aucun rendez-vous aujourd\'hui'**
  String get doctorDashboardNoAppointments;

  /// No description provided for @doctorDashboardViewSchedule.
  ///
  /// In fr, this message translates to:
  /// **'Voir le planning'**
  String get doctorDashboardViewSchedule;

  /// No description provided for @doctorScheduleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Planning'**
  String get doctorScheduleTitle;

  /// No description provided for @doctorScheduleManageAvailability.
  ///
  /// In fr, this message translates to:
  /// **'Gérer la disponibilité'**
  String get doctorScheduleManageAvailability;

  /// No description provided for @doctorScheduleAddSlot.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un créneau'**
  String get doctorScheduleAddSlot;

  /// No description provided for @doctorScheduleEditSlot.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le créneau'**
  String get doctorScheduleEditSlot;

  /// No description provided for @doctorScheduleDeleteSlot.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le créneau'**
  String get doctorScheduleDeleteSlot;

  /// No description provided for @doctorScheduleWorkingDays.
  ///
  /// In fr, this message translates to:
  /// **'Jours de travail'**
  String get doctorScheduleWorkingDays;

  /// No description provided for @doctorScheduleWorkingHours.
  ///
  /// In fr, this message translates to:
  /// **'Heures de travail'**
  String get doctorScheduleWorkingHours;

  /// No description provided for @doctorScheduleTimeSlots.
  ///
  /// In fr, this message translates to:
  /// **'Créneaux disponibles'**
  String get doctorScheduleTimeSlots;

  /// No description provided for @doctorAppointmentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous'**
  String get doctorAppointmentsTitle;

  /// No description provided for @doctorAppointmentsPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get doctorAppointmentsPending;

  /// No description provided for @doctorAppointmentsConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmés'**
  String get doctorAppointmentsConfirmed;

  /// No description provided for @doctorAppointmentsAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get doctorAppointmentsAll;

  /// No description provided for @doctorAppointmentsToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get doctorAppointmentsToday;

  /// No description provided for @doctorAppointmentsThisWeek.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get doctorAppointmentsThisWeek;

  /// No description provided for @doctorAppointmentsViewPatient.
  ///
  /// In fr, this message translates to:
  /// **'Voir le patient'**
  String get doctorAppointmentsViewPatient;

  /// No description provided for @doctorAppointmentsMarkComplete.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme terminé'**
  String get doctorAppointmentsMarkComplete;

  /// No description provided for @doctorAppointmentsCancelAppointment.
  ///
  /// In fr, this message translates to:
  /// **'Annuler le rendez-vous'**
  String get doctorAppointmentsCancelAppointment;

  /// No description provided for @doctorProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get doctorProfileTitle;

  /// No description provided for @doctorProfileSpecialties.
  ///
  /// In fr, this message translates to:
  /// **'Spécialités'**
  String get doctorProfileSpecialties;

  /// No description provided for @doctorProfileExperience.
  ///
  /// In fr, this message translates to:
  /// **'Années d\'expérience'**
  String get doctorProfileExperience;

  /// No description provided for @doctorProfileEducation.
  ///
  /// In fr, this message translates to:
  /// **'Formation'**
  String get doctorProfileEducation;

  /// No description provided for @doctorProfileAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get doctorProfileAbout;

  /// No description provided for @doctorProfileConsultationFee.
  ///
  /// In fr, this message translates to:
  /// **'Frais de consultation'**
  String get doctorProfileConsultationFee;

  /// No description provided for @doctorProfileEditProfile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get doctorProfileEditProfile;

  /// No description provided for @subscriptionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Abonnement'**
  String get subscriptionTitle;

  /// No description provided for @subscriptionCurrentPlan.
  ///
  /// In fr, this message translates to:
  /// **'Plan actuel'**
  String get subscriptionCurrentPlan;

  /// No description provided for @subscriptionUpgrade.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à niveau'**
  String get subscriptionUpgrade;

  /// No description provided for @subscriptionRenew.
  ///
  /// In fr, this message translates to:
  /// **'Renouveler'**
  String get subscriptionRenew;

  /// No description provided for @subscriptionCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler l\'abonnement'**
  String get subscriptionCancel;

  /// No description provided for @subscriptionBillingHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique de facturation'**
  String get subscriptionBillingHistory;

  /// No description provided for @subscriptionPaymentMethod.
  ///
  /// In fr, this message translates to:
  /// **'Méthode de paiement'**
  String get subscriptionPaymentMethod;

  /// No description provided for @subscriptionFree.
  ///
  /// In fr, this message translates to:
  /// **'Gratuit'**
  String get subscriptionFree;

  /// No description provided for @subscriptionBasic.
  ///
  /// In fr, this message translates to:
  /// **'Basique'**
  String get subscriptionBasic;

  /// No description provided for @subscriptionPro.
  ///
  /// In fr, this message translates to:
  /// **'Pro'**
  String get subscriptionPro;

  /// No description provided for @subscriptionUnlimitedAppointments.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous illimités'**
  String get subscriptionUnlimitedAppointments;

  /// No description provided for @subscriptionPrioritySupport.
  ///
  /// In fr, this message translates to:
  /// **'Support prioritaire'**
  String get subscriptionPrioritySupport;

  /// No description provided for @errorsGenericError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue'**
  String get errorsGenericError;

  /// No description provided for @errorsNetworkError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion'**
  String get errorsNetworkError;

  /// No description provided for @errorsServerError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur serveur'**
  String get errorsServerError;

  /// No description provided for @errorsUnauthorized.
  ///
  /// In fr, this message translates to:
  /// **'Non autorisé'**
  String get errorsUnauthorized;

  /// No description provided for @errorsNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Non trouvé'**
  String get errorsNotFound;

  /// No description provided for @errorsTryAgainLater.
  ///
  /// In fr, this message translates to:
  /// **'Réessayez plus tard'**
  String get errorsTryAgainLater;

  /// No description provided for @statusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmé'**
  String get statusConfirmed;

  /// No description provided for @statusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get statusCancelled;

  /// No description provided for @statusCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get statusCompleted;

  /// No description provided for @daysMonday.
  ///
  /// In fr, this message translates to:
  /// **'Lundi'**
  String get daysMonday;

  /// No description provided for @daysTuesday.
  ///
  /// In fr, this message translates to:
  /// **'Mardi'**
  String get daysTuesday;

  /// No description provided for @daysWednesday.
  ///
  /// In fr, this message translates to:
  /// **'Mercredi'**
  String get daysWednesday;

  /// No description provided for @daysThursday.
  ///
  /// In fr, this message translates to:
  /// **'Jeudi'**
  String get daysThursday;

  /// No description provided for @daysFriday.
  ///
  /// In fr, this message translates to:
  /// **'Vendredi'**
  String get daysFriday;

  /// No description provided for @daysSaturday.
  ///
  /// In fr, this message translates to:
  /// **'Samedi'**
  String get daysSaturday;

  /// No description provided for @daysSunday.
  ///
  /// In fr, this message translates to:
  /// **'Dimanche'**
  String get daysSunday;

  /// No description provided for @daysShortMon.
  ///
  /// In fr, this message translates to:
  /// **'Lun'**
  String get daysShortMon;

  /// No description provided for @daysShortTue.
  ///
  /// In fr, this message translates to:
  /// **'Mar'**
  String get daysShortTue;

  /// No description provided for @daysShortWed.
  ///
  /// In fr, this message translates to:
  /// **'Mer'**
  String get daysShortWed;

  /// No description provided for @daysShortThu.
  ///
  /// In fr, this message translates to:
  /// **'Jeu'**
  String get daysShortThu;

  /// No description provided for @daysShortFri.
  ///
  /// In fr, this message translates to:
  /// **'Ven'**
  String get daysShortFri;

  /// No description provided for @daysShortSat.
  ///
  /// In fr, this message translates to:
  /// **'Sam'**
  String get daysShortSat;

  /// No description provided for @daysShortSun.
  ///
  /// In fr, this message translates to:
  /// **'Dim'**
  String get daysShortSun;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get settingsAccount;

  /// No description provided for @settingsNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @settingsPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get settingsPrivacy;

  /// No description provided for @settingsAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get settingsAbout;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir vous déconnecter ?'**
  String get settingsLogoutConfirm;

  /// No description provided for @settingsVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsPreferences.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get settingsPreferences;

  /// No description provided for @settingsNotificationsEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Activées'**
  String get settingsNotificationsEnabled;

  /// No description provided for @wrongPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe incorrect'**
  String get wrongPassword;

  /// No description provided for @confirmPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer votre mot de passe'**
  String get confirmPasswordTitle;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible. Toutes vos données (rendez-vous, favoris) seront définitivement effacées.'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @enterPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre mot de passe'**
  String get enterPasswordHint;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir vous déconnecter ?'**
  String get logoutConfirmMessage;

  /// No description provided for @installBannerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Installer Eyadati'**
  String get installBannerTitle;

  /// No description provided for @installBannerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez Eyadati à votre écran d\'accueil'**
  String get installBannerSubtitle;

  /// No description provided for @installBannerButton.
  ///
  /// In fr, this message translates to:
  /// **'Installer'**
  String get installBannerButton;

  /// No description provided for @timeMorning.
  ///
  /// In fr, this message translates to:
  /// **'Matin'**
  String get timeMorning;

  /// No description provided for @timeAfternoon.
  ///
  /// In fr, this message translates to:
  /// **'Après-midi'**
  String get timeAfternoon;

  /// No description provided for @timeEvening.
  ///
  /// In fr, this message translates to:
  /// **'Soir'**
  String get timeEvening;

  /// No description provided for @bookingBookOnline.
  ///
  /// In fr, this message translates to:
  /// **'Réserver en ligne'**
  String get bookingBookOnline;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
