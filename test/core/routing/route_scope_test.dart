import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Structural guard for the open-core boundary: the free tier must not
/// carry subscription/payment routing, pages, providers, models, or the
/// premium infrastructure directory.
void main() {
  final routeNames =
      File('lib/core/routing/route_names.dart').readAsStringSync();
  final appRouter = File('lib/core/routing/app_router.dart').readAsStringSync();

  test('route_names declares no subscription/payment routes', () {
    expect(RegExp('subscription|payment', caseSensitive: false)
        .hasMatch(routeNames),
        isFalse);
  });

  test('app_router wires no subscription/payment routes', () {
    expect(RegExp('subscription|payment', caseSensitive: false)
        .hasMatch(appRouter),
        isFalse);
  });

  test('clinicCalendar constant exists but is not routed in free tier', () {
    expect(routeNames.contains('clinicCalendar'), isTrue);
    expect(appRouter.contains('clinicCalendar'), isFalse);
  });

  test('every GoRoute path comes from RouteNames', () {
    final paths = RegExp(r'path:\s*RouteNames\.(\w+)')
        .allMatches(appRouter)
        .map((m) => m.group(1)!)
        .toSet();
    expect(paths, isNotEmpty);
    for (final name in paths) {
      expect(routeNames.contains('static const String $name'), isTrue,
          reason: 'router uses RouteNames.$name which route_names.dart '
              'does not declare');
    }
  });

  test('premium pages/providers/models are absent', () {
    const absent = [
      'lib/features/doctor/presentation/pages/doctor_subscription_page.dart',
      'lib/features/doctor/presentation/pages/payment_success_page.dart',
      'lib/features/doctor/presentation/pages/payment_failure_page.dart',
      'lib/features/doctor/presentation/providers/subscription_provider.dart',
      'lib/models/payment_history.dart',
      'lib/models/payment_history.freezed.dart',
      'lib/models/payment_history.g.dart',
    ];
    for (final rel in absent) {
      expect(File(rel).existsSync(), isFalse, reason: '$rel must not ship');
    }
    expect(Directory('lib/core/infrastructure/premium').existsSync(), isFalse);
    expect(Directory('supabase/functions/chargily-webhook').existsSync(),
        isFalse);
    expect(Directory('supabase/functions/create-checkout').existsSync(),
        isFalse);
    expect(Directory('supabase/functions/send-appointment-reminder')
        .existsSync(),
        isFalse);
  });

  test('free keeps only the mock infrastructure', () {
    final entries = Directory('lib/core/infrastructure')
        .listSync()
        .map((e) => e.uri.pathSegments.where((s) => s.isNotEmpty).last)
        .toSet();
    expect(entries, contains('mock'));
    expect(entries.contains('premium'), isFalse);
  });
}
