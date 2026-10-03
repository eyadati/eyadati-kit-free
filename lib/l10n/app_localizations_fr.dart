// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Eyadati';

  @override
  String get commonLoading => 'Chargement...';

  @override
  String get commonError => 'Erreur';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonSearch => 'Rechercher';

  @override
  String get commonNoResults => 'Aucun résultat';

  @override
  String get commonTryAgain => 'Réessayer';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonNext => 'Suivant';

  @override
  String get commonDone => 'Terminé';

  @override
  String get commonYes => 'Oui';

  @override
  String get commonNo => 'Non';

  @override
  String get commonOk => 'OK';

  @override
  String get commonMore => 'autres';

  @override
  String get validationEmailRequired => 'Email requis';

  @override
  String get validationEmailInvalid => 'Email invalide';

  @override
  String get validationPasswordRequired => 'Mot de passe requis';

  @override
  String get validationPasswordTooShort =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get validationNameRequired => 'Nom requis';

  @override
  String get validationPhoneRequired => 'Téléphone requis';

  @override
  String get validationConfirmPasswordRequired =>
      'Confirmer le mot de passe requis';

  @override
  String get validationPasswordsDoNotMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get authLoginTitle => 'Bienvenue';

  @override
  String get authLoginSubtitle => 'Connectez-vous à votre compte';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Mot de passe';

  @override
  String get authLoginButton => 'Se connecter';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authNoAccount => 'Vous n\'avez pas de compte ? ';

  @override
  String get authSignUp => 'S\'inscrire';

  @override
  String get authRegisterTitle => 'Créer un compte';

  @override
  String get authRegisterSubtitle => 'Rejoignez Eyadati';

  @override
  String get authNameLabel => 'Nom complet';

  @override
  String get authPhoneLabel => 'Téléphone';

  @override
  String get authConfirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get authRegisterButton => 'S\'inscrire';

  @override
  String get authHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get authLogIn => 'Se connecter';

  @override
  String get authForgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get authForgotPasswordSubtitle =>
      'Entrez votre email pour réinitialiser';

  @override
  String get authResetPasswordButton => 'Réinitialiser';

  @override
  String get authBackToLogin => 'Retour à la connexion';

  @override
  String get roleSelectTitle => 'Qui êtes-vous ?';

  @override
  String get roleSelectSubtitle => 'Choisissez votre rôle';

  @override
  String get rolePatient => 'Patient';

  @override
  String get rolePatientDesc => 'Prenez des rendez-vous avec des médecins';

  @override
  String get roleDoctor => 'Docteur';

  @override
  String get roleDoctorDesc => 'Gérez votre calendrier et vos patients';

  @override
  String get navHome => 'Accueil';

  @override
  String get navAppointments => 'Rendez-vous';

  @override
  String get navDoctors => 'Docteurs';

  @override
  String get navFavorites => 'Favoris';

  @override
  String get navProfile => 'Profil';

  @override
  String get navSettings => 'Paramètres';

  @override
  String patientHomeTitle(String name) {
    return 'Bonjour, $name';
  }

  @override
  String get patientHomeSubtitle => 'Comment allez-vous aujourd\'hui ?';

  @override
  String get patientUpcomingAppointments => 'Rendez-vous à venir';

  @override
  String get patientFindDoctor => 'Trouver un médecin';

  @override
  String get patientViewAll => 'Voir tout';

  @override
  String get patientNoAppointments => 'Aucun rendez-vous à venir';

  @override
  String get patientBookNow => 'Réserver maintenant';

  @override
  String get patientHomeNoAppointmentMsg =>
      'Appuyez sur le bouton ci-dessous pour trouver un médecin';

  @override
  String get doctorsBrowseTitle => 'Tous les médecins';

  @override
  String get doctorsSearchPlaceholder => 'Rechercher un médecin...';

  @override
  String get doctorsFilterSpecialty => 'Spécialité';

  @override
  String get doctorsFilterAvailability => 'Disponibilité';

  @override
  String get searchFilterRequired =>
      'Veuillez sélectionner une ville ou une spécialité';

  @override
  String get searchFilterCity => 'Ville';

  @override
  String get searchFilterCityHint => 'Sélectionner une ville';

  @override
  String get searchFilterSpecialtyHint => 'Sélectionner une spécialité';

  @override
  String get doctorResultsAvailable => 'Médecins disponibles';

  @override
  String get doctorResultsNoFavorites => 'Aucun favori trouvé';

  @override
  String get doctorResultsAddFavorites =>
      'Ajoutez des favoris pour les voir ici';

  @override
  String get doctorResultsTryOther => 'Essayez avec d\'autres critères';

  @override
  String get doctorsNoResults => 'Aucun médecin trouvé';

  @override
  String get doctorsViewProfile => 'Voir le profil';

  @override
  String get doctorsBookAppointment => 'Prendre rendez-vous';

  @override
  String get doctorDetailsTitle => 'Profil du médecin';

  @override
  String get doctorDetailsAbout => 'À propos';

  @override
  String get doctorDetailsSpecialties => 'Spécialités';

  @override
  String get doctorDetailsExperience => 'Expérience';

  @override
  String get doctorDetailsEducation => 'Formation';

  @override
  String get doctorDetailsWorkingHours => 'Heures de travail';

  @override
  String get doctorDetailsReviews => 'Avis';

  @override
  String get doctorDetailsInfo => 'Informations';

  @override
  String get doctorDetailsCity => 'Ville';

  @override
  String get doctorDetailsBookNow => 'Prendre rendez-vous';

  @override
  String get doctorDetailsAddFavorite => 'Ajouter aux favoris';

  @override
  String get doctorDetailsRemoveFavorite => 'Retirer des favoris';

  @override
  String get bookingSelectDate => 'Choisir une date';

  @override
  String get bookingSelectTime => 'Choisir une heure';

  @override
  String get bookingAppointmentType => 'Type de rendez-vous';

  @override
  String get bookingConsultation => 'Consultation';

  @override
  String get bookingRegularVisit => 'Visite régulière';

  @override
  String get bookingFollowUp => 'Suivi';

  @override
  String get bookingCheckUp => 'Bilan de santé';

  @override
  String get bookingConfirmDetails => 'Confirmer les détails';

  @override
  String get bookingSuccess => 'Rendez-vous confirmé !';

  @override
  String get bookingSuccessMessage =>
      'Votre rendez-vous a été enregistré avec succès.';

  @override
  String get bookingAddNotes => 'Notes (optionnel)';

  @override
  String get bookingConfirmButton => 'Confirmer le rendez-vous';

  @override
  String get bookingSelectSlot => 'Sélectionnez un créneau';

  @override
  String get bookingToday => 'Aujourd\'hui';

  @override
  String get bookingNotesHint => 'Ajoutez des notes pour le médecin...';

  @override
  String get bookingNoSlotsToday =>
      'Aucun créneau disponible aujourd\'hui (délai minimum 30min)';

  @override
  String get bookingNoSlotsDate => 'Aucun créneau disponible pour cette date';

  @override
  String get bookingUnavailableTitle => 'Réservation indisponible pour vous';

  @override
  String get bookingUnavailableMessage =>
      'Votre score de fiabilité est trop bas. Contactez le cabinet pour réserver.';

  @override
  String get bookingCallOffice => 'Appeler le cabinet';

  @override
  String get bookingPhoneUnavailable => 'Téléphone non disponible';

  @override
  String get bookingSelectTimeError => 'Veuillez sélectionner une heure';

  @override
  String get bookingUserNotConnectedError => 'Erreur: utilisateur non connecté';

  @override
  String get bookingSlotUnavailable => 'Ce créneau n\'est plus disponible';

  @override
  String bookingError(String error) {
    return 'Erreur: $error';
  }

  @override
  String get bookingSuccessViewButton => 'Voir mes rendez-vous';

  @override
  String get bookingLoading => 'En cours...';

  @override
  String bookingWarningMessage(int count) {
    return 'Attention : vous avez $count absences non justifiées. Après 3 absences, vous ne pourrez plus réserver en ligne.';
  }

  @override
  String bookingReliabilityLabel(int pct, String label) {
    return 'Fiabilité : $pct% ($label)';
  }

  @override
  String get bookingSelectDateError =>
      'Veuillez sélectionner une date et un horaire';

  @override
  String bookingSuccessWithDoctor(String doctorName) {
    return 'Votre rendez-vous avec $doctorName a été enregistré avec succès.';
  }

  @override
  String get bookingBackHome => 'Retour à l\'accueil';

  @override
  String get bookingNoSlotsAvailable => 'Aucun créneau disponible';

  @override
  String get bookingSelectDateHint =>
      'Sélectionnez une date pour voir les horaires';

  @override
  String get attendanceGood => 'Bon';

  @override
  String get attendanceAverage => 'Moyen';

  @override
  String get attendanceLow => 'Faible';

  @override
  String get appointmentsMyAppointments => 'Mes rendez-vous';

  @override
  String get appointmentsUpcoming => 'À venir';

  @override
  String get appointmentsPast => 'Passés';

  @override
  String get appointmentsCancelled => 'Annulés';

  @override
  String get appointmentsNoUpcoming => 'Aucun rendez-vous à venir';

  @override
  String get appointmentsNoPast => 'Aucun rendez-vous passé';

  @override
  String get appointmentsNoCancelled => 'Aucun rendez-vous annulé';

  @override
  String get appointmentsCancel => 'Annuler';

  @override
  String get appointmentsReschedule => 'Reprogrammer';

  @override
  String get appointmentsDetails => 'Détails';

  @override
  String get appointmentsStatusPending => 'En attente';

  @override
  String get appointmentsStatusConfirmed => 'Confirmé';

  @override
  String get appointmentsStatusCompleted => 'Terminé';

  @override
  String get appointmentsStatusCancelled => 'Annulé';

  @override
  String appointmentsWithDoctor(String name) {
    return 'avec Dr. $name';
  }

  @override
  String get cancelAppointmentConfirm =>
      'Êtes-vous sûr de vouloir annuler ce rendez-vous ?';

  @override
  String get cancelConfirmYes => 'Oui, annuler';

  @override
  String get appointmentCancelled => 'Rendez-vous annulé';

  @override
  String get cancelAppointmentError => 'Erreur lors de l\'annulation';

  @override
  String get clipboardCopied => 'Numéro copié';

  @override
  String get favoritesTitle => 'Mes favoris';

  @override
  String get favoritesEmpty => 'Aucun favori';

  @override
  String get favoritesEmptyMessage => 'Ajoutez des médecins à vos favoris';

  @override
  String get favoritesBrowseDoctors => 'Parcourir les médecins';

  @override
  String get profileTitle => 'Mon profil';

  @override
  String get profileEditProfile => 'Modifier le profil';

  @override
  String get profileAccountSettings => 'Compte';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileLogout => 'Déconnexion';

  @override
  String get profileDeleteAccount => 'Supprimer le compte';

  @override
  String get profileName => 'Nom';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePhone => 'Téléphone';

  @override
  String get profileDateOfBirth => 'Date de naissance';

  @override
  String get profilePersonalInfo => 'Informations personnelles';

  @override
  String get profileNameHint => 'Entrez votre nom';

  @override
  String get profileCity => 'Ville';

  @override
  String get profileCityHint => 'Sélectionnez votre ville';

  @override
  String get profileUpdateSuccess => 'Profil mis à jour';

  @override
  String get profileUpdateError => 'Erreur lors de la mise à jour';

  @override
  String get doctorDashboardTitle => 'Tableau de bord';

  @override
  String get doctorDashboardToday => 'Aujourd\'hui';

  @override
  String get doctorDashboardUpcomingAppointments => 'Rendez-vous à venir';

  @override
  String get doctorDashboardStats => 'Statistiques';

  @override
  String get doctorDashboardTodayAppointments => 'Rendez-vous du jour';

  @override
  String get doctorDashboardPatients => 'Patients';

  @override
  String get doctorDashboardThisWeek => 'Cette semaine';

  @override
  String get doctorDashboardEarnings => 'Revenus';

  @override
  String get doctorDashboardNoAppointments => 'Aucun rendez-vous aujourd\'hui';

  @override
  String get doctorDashboardViewSchedule => 'Voir le planning';

  @override
  String get doctorScheduleTitle => 'Planning';

  @override
  String get doctorScheduleManageAvailability => 'Gérer la disponibilité';

  @override
  String get doctorScheduleAddSlot => 'Ajouter un créneau';

  @override
  String get doctorScheduleEditSlot => 'Modifier le créneau';

  @override
  String get doctorScheduleDeleteSlot => 'Supprimer le créneau';

  @override
  String get doctorScheduleWorkingDays => 'Jours de travail';

  @override
  String get doctorScheduleWorkingHours => 'Heures de travail';

  @override
  String get doctorScheduleTimeSlots => 'Créneaux disponibles';

  @override
  String get doctorAppointmentsTitle => 'Rendez-vous';

  @override
  String get doctorAppointmentsPending => 'En attente';

  @override
  String get doctorAppointmentsConfirmed => 'Confirmés';

  @override
  String get doctorAppointmentsAll => 'Tous';

  @override
  String get doctorAppointmentsToday => 'Aujourd\'hui';

  @override
  String get doctorAppointmentsThisWeek => 'Cette semaine';

  @override
  String get doctorAppointmentsViewPatient => 'Voir le patient';

  @override
  String get doctorAppointmentsMarkComplete => 'Marquer comme terminé';

  @override
  String get doctorAppointmentsCancelAppointment => 'Annuler le rendez-vous';

  @override
  String get doctorProfileTitle => 'Mon profil';

  @override
  String get doctorProfileSpecialties => 'Spécialités';

  @override
  String get doctorProfileExperience => 'Années d\'expérience';

  @override
  String get doctorProfileEducation => 'Formation';

  @override
  String get doctorProfileAbout => 'À propos';

  @override
  String get doctorProfileConsultationFee => 'Frais de consultation';

  @override
  String get doctorProfileEditProfile => 'Modifier le profil';

  @override
  String get subscriptionTitle => 'Abonnement';

  @override
  String get subscriptionCurrentPlan => 'Plan actuel';

  @override
  String get subscriptionUpgrade => 'Mettre à niveau';

  @override
  String get subscriptionRenew => 'Renouveler';

  @override
  String get subscriptionCancel => 'Annuler l\'abonnement';

  @override
  String get subscriptionBillingHistory => 'Historique de facturation';

  @override
  String get subscriptionPaymentMethod => 'Méthode de paiement';

  @override
  String get subscriptionFree => 'Gratuit';

  @override
  String get subscriptionBasic => 'Basique';

  @override
  String get subscriptionPro => 'Pro';

  @override
  String get subscriptionUnlimitedAppointments => 'Rendez-vous illimités';

  @override
  String get subscriptionPrioritySupport => 'Support prioritaire';

  @override
  String get errorsGenericError => 'Une erreur est survenue';

  @override
  String get errorsNetworkError => 'Erreur de connexion';

  @override
  String get errorsServerError => 'Erreur serveur';

  @override
  String get errorsUnauthorized => 'Non autorisé';

  @override
  String get errorsNotFound => 'Non trouvé';

  @override
  String get errorsTryAgainLater => 'Réessayez plus tard';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusConfirmed => 'Confirmé';

  @override
  String get statusCancelled => 'Annulé';

  @override
  String get statusCompleted => 'Terminé';

  @override
  String get daysMonday => 'Lundi';

  @override
  String get daysTuesday => 'Mardi';

  @override
  String get daysWednesday => 'Mercredi';

  @override
  String get daysThursday => 'Jeudi';

  @override
  String get daysFriday => 'Vendredi';

  @override
  String get daysSaturday => 'Samedi';

  @override
  String get daysSunday => 'Dimanche';

  @override
  String get daysShortMon => 'Lun';

  @override
  String get daysShortTue => 'Mar';

  @override
  String get daysShortWed => 'Mer';

  @override
  String get daysShortThu => 'Jeu';

  @override
  String get daysShortFri => 'Ven';

  @override
  String get daysShortSat => 'Sam';

  @override
  String get daysShortSun => 'Dim';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsPrivacy => 'Confidentialité';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsLogoutConfirm =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPreferences => 'Préférences';

  @override
  String get settingsNotificationsEnabled => 'Activées';

  @override
  String get wrongPassword => 'Mot de passe incorrect';

  @override
  String get confirmPasswordTitle => 'Confirmer votre mot de passe';

  @override
  String get deleteAccountConfirmMessage =>
      'Cette action est irréversible. Toutes vos données (rendez-vous, favoris) seront définitivement effacées.';

  @override
  String get enterPasswordHint => 'Entrez votre mot de passe';

  @override
  String get logoutConfirmMessage =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get installBannerTitle => 'Installer Eyadati';

  @override
  String get installBannerSubtitle =>
      'Ajoutez Eyadati à votre écran d\'accueil';

  @override
  String get installBannerButton => 'Installer';

  @override
  String get timeMorning => 'Matin';

  @override
  String get timeAfternoon => 'Après-midi';

  @override
  String get timeEvening => 'Soir';

  @override
  String get bookingBookOnline => 'Réserver en ligne';
}
