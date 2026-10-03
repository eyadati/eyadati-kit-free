import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../providers/auth_provider.dart';
import '../../../../core/widgets/feedback/loading_indicator.dart';
import '../../../../core/constants/app_colors.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    print('[SplashPage] initState called');
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    print('[SplashPage] _checkAuth started');
    await Future.delayed(const Duration(seconds: 1));
    print('[SplashPage] delay completed');
    if (!mounted) {
      print('[SplashPage] not mounted, returning');
      return;
    }

    await ref.read(authProvider.notifier).checkAuthStatus();
    print('[SplashPage] checkAuthStatus completed');

    if (!mounted) {
      print('[SplashPage] not mounted after check, returning');
      return;
    }

    final authState = ref.read(authProvider);
    print(
      '[SplashPage] authState - isInitialized: ${authState.isInitialized}, isAuthenticated: ${authState.isAuthenticated}, isDoctor: ${authState.isDoctor}',
    );

    if (authState.isAuthenticated) {
      print('[SplashPage] navigating to home');
      context.go(
        authState.isDoctor
            ? RouteNames.doctorDashboard
            : RouteNames.patientHome,
      );
    } else {
      print('[SplashPage] navigating to login');
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Eyadati',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 48),
            const LoadingIndicator(color: AppColors.white, size: 32),
          ],
        ),
      ),
    );
  }
}
