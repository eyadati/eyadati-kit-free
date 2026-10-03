import 'package:flutter/material.dart';
import 'package:eyadati_kit/core/utils/logger.dart';

class AppErrorHandler {
  static void handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String context = 'Global',
    bool showSnackBar = true,
    BuildContext? contextForSnackBar,
  }) {
    // 1. Log the error
    AppLogger().error(
      error.toString(),
      context: context,
      metadata: stackTrace != null ? {'stack': stackTrace.toString()} : null,
    );

    // 2. User Feedback
    if (showSnackBar && contextForSnackBar != null) {
      ScaffoldMessenger.of(contextForSnackBar).showSnackBar(
        SnackBar(
          content: Text(_getFriendlyMessage(error)),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static String _getFriendlyMessage(dynamic error) {
    if (error is String) return error;
    if (error.toString().contains('network')) {
      return 'Erreur de connexion. Veuillez vérifier votre internet.';
    }
    if (error.toString().contains('auth')) {
      return 'Erreur d\'authentification. Veuillez vous reconnecter.';
    }
    return 'Une erreur inattendue est survenue. Veuillez réessayer.';
  }
}
