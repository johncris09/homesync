import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/sync/sync_triggers.dart';
import '../l10n/app_localizations.dart';
import 'providers.dart';
import 'router.dart';
import 'theme.dart';

class HomeSyncApp extends ConsumerStatefulWidget {
  const HomeSyncApp({super.key, this.attachTriggers = true});

  /// Off in widget tests (no platform channels for connectivity).
  final bool attachTriggers;

  @override
  ConsumerState<HomeSyncApp> createState() => _HomeSyncAppState();
}

class _HomeSyncAppState extends ConsumerState<HomeSyncApp> {
  late final GoRouter _router;
  SyncTriggers? _triggers;

  @override
  void initState() {
    super.initState();
    final services = ref.read(servicesProvider);
    _router = buildRouter(auth: services.auth, lock: services.appLock);
    if (widget.attachTriggers) {
      _triggers = SyncTriggers(
        scheduler: services.scheduler,
        onPause: services.appLock.onPaused,
        onResume: services.appLock.onResumed,
      )..attach();
    }
  }

  @override
  void dispose() {
    _triggers?.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    theme: buildTheme(),
    routerConfig: _router,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
  );
}
