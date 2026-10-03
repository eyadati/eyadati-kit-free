import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/utils/supabase_client.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/version_update_provider.dart';
import 'core/widgets/feedback/update_banner.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseInitializer.initialize();

  runApp(const ProviderScope(child: EyadatiApp()));
}

class EyadatiApp extends ConsumerStatefulWidget {
  const EyadatiApp({super.key});

  @override
  ConsumerState<EyadatiApp> createState() => _EyadatiAppState();
}

class _EyadatiAppState extends ConsumerState<EyadatiApp>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && kIsWeb) {
      _refreshOnResume();
    }
  }

  void _refreshOnResume() {
    ref.read(versionUpdateProvider.notifier).reconnect();

    final sw = html.window.navigator.serviceWorker;
    if (sw == null) return;
    sw.getRegistration().then((reg) {
      if (reg != null) reg.update();
    });

    sw.getRegistration().then((reg) {
      reg?.active?.postMessage('NOTIFICATIONS_VISIBLE');
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Eyadati',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final isRtl = ref.watch(localeProvider).languageCode == 'ar';
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: AppWithUpdateBanner(child: child ?? const SizedBox()),
        );
      },
    );
  }
}
