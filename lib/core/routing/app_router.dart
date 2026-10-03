import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/select_role_page.dart';
import '../../features/patient/presentation/pages/patient_home_page.dart';
import '../../features/patient/presentation/pages/doctors_browse_page.dart';
import '../../features/patient/presentation/pages/doctor_details_page.dart';
import '../../features/patient/presentation/pages/booking_page.dart';
import '../../features/patient/presentation/pages/patient_appointments_page.dart';
import '../../features/patient/presentation/pages/favorites_page.dart';
import '../../features/patient/presentation/pages/patient_settings_page.dart';
import '../../features/patient/presentation/pages/patient_edit_profile_page.dart';
import '../../features/doctor/presentation/pages/doctor_dashboard_page.dart';
import '../../features/doctor/presentation/pages/doctor_setup_page.dart';
import '../../features/doctor/presentation/pages/doctor_calendar_page.dart';
import '../../features/doctor/presentation/pages/doctor_schedule_page.dart';
import '../../features/doctor/presentation/pages/doctor_settings_page.dart';
import '../../features/doctor/presentation/pages/doctor_patients_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// A notifier that bridges the Riverpod AuthState to GoRouter's refreshListenable.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: notifier,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      print('[RouterRedirect] location=${state.matchedLocation}, isInitialized=${authState.isInitialized}, isAuthenticated=${authState.isAuthenticated}, isDoctor=${authState.isDoctor}, setupCompleted=${authState.setupCompleted}');
      
      // If the app hasn't checked auth status yet, stay on splash screen
      if (!authState.isInitialized) {
        print('[RouterRedirect] Not initialized, staying on splash');
        return RouteNames.splash;
      }

      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.register ||
          state.matchedLocation == RouteNames.forgotPassword ||
          state.matchedLocation == RouteNames.splash;

      // 1. If not logged in and trying to access a protected route, go to login
      if (!isLoggedIn) {
        print('[RouterRedirect] Not logged in, auth route: $isAuthRoute');
        return isAuthRoute ? null : RouteNames.login;
      }

      // 2. If logged in but at an auth-only route (like Login or Splash)
      if (isLoggedIn && isAuthRoute) {
        print('[RouterRedirect] Logged in, at auth route');
        if (authState.isDoctor && !authState.setupCompleted) {
          print('[RouterRedirect] Doctor without setup, redirecting to setup');
          return RouteNames.doctorSetup;
        }
        print('[RouterRedirect] Redirecting to ${authState.isDoctor ? "doctor" : "patient"} home');
        return authState.isDoctor ? RouteNames.doctorDashboard : RouteNames.patientHome;
      }

      // 3. Doctor setup check - redirect to setup if not completed
      if (authState.isDoctor && !authState.setupCompleted) {
        print('[RouterRedirect] Doctor without setup, current location: ${state.matchedLocation}');
        if (state.matchedLocation != RouteNames.doctorSetup) {
          print('[RouterRedirect] Redirecting to setup');
          return RouteNames.doctorSetup;
        }
        print('[RouterRedirect] Already at setup, allowing access');
        return null; // Allow access to setup page
      }

      // 4. Allow access to setup page if already completed
      if (state.matchedLocation == RouteNames.doctorSetup && authState.setupCompleted) {
        print('[RouterRedirect] At setup but completed, redirecting to dashboard');
        return RouteNames.doctorDashboard;
      }

      // 5. Role-Based Access Control (RBAC)
      final isPatientRoute = state.matchedLocation.startsWith('/patient');
      final isDoctorRoute = state.matchedLocation.startsWith('/doctor');

      if (isPatientRoute && authState.isDoctor) {
        print('[RouterRedirect] Patient route but doctor, redirecting');
        return RouteNames.doctorDashboard;
      }

      if (isDoctorRoute && !authState.isDoctor) {
        print('[RouterRedirect] Doctor route but patient, redirecting to patient home');
        return RouteNames.patientHome;
      }

      print('[RouterRedirect] No redirect needed, allowing navigation');
      // Allow navigation if none of the above rules match
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RouteNames.selectRole,
        builder: (context, state) => const SelectRolePage(),
      ),
      GoRoute(
        path: RouteNames.patientHome,
        builder: (context, state) => const PatientHomePage(),
      ),
      GoRoute(
        path: RouteNames.patientDoctors,
        builder: (context, state) => const DoctorsBrowsePage(),
      ),
      GoRoute(
        path: RouteNames.patientDoctorDetails,
        builder: (context, state) => DoctorDetailsPage(
          doctorId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: RouteNames.patientBookAppointment,
        builder: (context, state) => BookingPage(
          doctorId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: RouteNames.patientAppointments,
        builder: (context, state) => const PatientAppointmentsPage(),
      ),
      GoRoute(
        path: RouteNames.patientFavorites,
        builder: (context, state) => const FavoritesPage(),
      ),
      GoRoute(
        path: RouteNames.patientProfile,
        builder: (context, state) => const PatientSettingsPage(),
      ),
      GoRoute(
        path: RouteNames.patientEditProfile,
        builder: (context, state) => const PatientEditProfilePage(),
      ),
      GoRoute(
        path: RouteNames.doctorDashboard,
        builder: (context, state) => const DoctorDashboardPage(),
      ),
      GoRoute(
        path: RouteNames.doctorSetup,
        builder: (context, state) => const DoctorSetupPage(),
      ),
      GoRoute(
        path: RouteNames.doctorCalendar,
        builder: (context, state) => DoctorCalendarPage(),
      ),
      GoRoute(
        path: RouteNames.doctorSchedule,
        builder: (context, state) => const DoctorSchedulePage(),
      ),
      GoRoute(
        path: RouteNames.doctorPatients,
        builder: (context, state) => DoctorPatientsPage(initialSearchQuery: state.extra as String?),
      ),
      GoRoute(
        path: RouteNames.doctorSettings,
        builder: (context, state) => const DoctorSettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page non trouvée : ${state.uri}'),
      ),
    ),
  );
});